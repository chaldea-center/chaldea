import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../api/chaldea.dart';
import '../common/filter_group.dart';

enum _MyRoomChangeType {
  bgImage([
    MyRoomAddOverwriteType.bgImage,
    MyRoomAddOverwriteType.servantOverlayObject,
    MyRoomAddOverwriteType.backObject,
  ]),
  bgm([MyRoomAddOverwriteType.bgm]),
  special([
    MyRoomAddOverwriteType.servantOverlayObject,
    MyRoomAddOverwriteType.backObject,
    MyRoomAddOverwriteType.bgImageMultiple,
  ]);

  const _MyRoomChangeType(this.types);
  final List<MyRoomAddOverwriteType> types;
}

class MyRoomAssetsPage extends StatefulWidget {
  const MyRoomAssetsPage({super.key});

  @override
  State<MyRoomAssetsPage> createState() => _MyRoomAssetsPageState();
}

class _MyRoomAssetsPageState extends State<MyRoomAssetsPage>
    with RegionBasedState<List<MstMyRoomAdd>, MyRoomAssetsPage>, SingleTickerProviderStateMixin {
  bool useFullscreen = true;
  late final tabController = TabController(length: _MyRoomChangeType.values.length, vsync: this);

  @override
  void initState() {
    super.initState();
    region = Region.jp;
    doFetchData();
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Future<List<MstMyRoomAdd>?> fetchData(Region? r, {Duration? expireAfter}) {
    CachedApi.cacheManager.clearFailed();
    return CachedApi.cacheManager.getModel(
      'https://git.atlasacademy.io/atlasacademy/fgo-game-data/raw/branch/${r ?? Region.jp}/master/mstMyroomAdd.json',
      (list) {
        return List<Map>.from(list).map((e) => MstMyRoomAdd.fromJson(Map.from(e))).toList();
      },
      expireAfter: expireAfter,
    );
  }

  int _t = DateTime.now().timestamp;
  bool expanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(S.current.my_room, maxLines: 1, minFontSize: 10),
        actions: [
          dropdownRegion(),
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(onTap: doFetchData, child: Text(S.current.refresh)),
                PopupMenuItem(
                  onTap: () {
                    expanded = false;
                    _t = DateTime.now().timestamp;
                    if (mounted) setState(() {});
                  },
                  child: Text(S.current.collapse),
                ),
                PopupMenuItem(
                  onTap: () {
                    expanded = true;
                    _t = DateTime.now().timestamp;
                    if (mounted) setState(() {});
                  },
                  child: Text(S.current.expand),
                ),
              ];
            },
          ),
        ],
        bottom: FixedHeight.tabBar(
          TabBar(
            controller: tabController,
            tabs: [Tab(text: S.current.background), Tab(text: S.current.bgm), Tab(text: S.current.general_special)],
          ),
        ),
      ),
      body: buildBody(context),
    );
  }

  @override
  Widget buildContent(BuildContext context, List<MstMyRoomAdd> data) {
    List<Widget> views = [];
    for (final changeType in _MyRoomChangeType.values) {
      Map<String, List<MstMyRoomAdd>> grouped = {};
      for (final room in data) {
        if (changeType.types.any((e) => e.value == room.type) && room.overwriteId > 0) {
          grouped.putIfAbsent('${room.id}.${room.startedAt}.${room.endedAt}', () => []).add(room);
        }
      }
      final groupList = grouped.values.toList();
      groupList.sort2((e) => -e.first.startedAt);
      Widget view = ListView.builder(
        itemCount: groupList.length,
        itemBuilder: (context, index) {
          final rooms = groupList[index];
          return SimpleAccordion(
            key: Key('room_group_${changeType.name}_${_t}_$index'),
            expanded: expanded,
            headerBuilder: (context, _) => buildHeader(context, rooms),
            contentBuilder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: divideList([
                  for (final room in rooms) buildOneRoom(context, room),
                ], const SizedBox(height: 4)),
              );
            },
          );
        },
      );
      view = wrapButtonBar(context, changeType, view);
      views.add(view);
    }

    return TabBarView(controller: tabController, children: views);
  }

  bool checkTime(int? a, int b) {
    if (a == null) return false;
    return (a - b).abs() <= 3600 * 5;
  }

  Widget buildHeader(BuildContext context, List<MstMyRoomAdd> rooms) {
    final room = rooms.first;
    final wars = <NiceWar>{};
    final events = <Event>{};
    final event = db.gameData.events[room.id];
    if (room.id > 1000 && event != null) {
      final start = event.startTimeOf(region), end = event.endTimeOf(region);
      if (start != null && end != null && room.startedAt >= start - 3600 * 5 && room.endedAt <= end + 3600 * 5) {
        events.add(event);
      }
    }
    if (events.isEmpty) {
      const eventTypes = [EventType.eventQuest, EventType.warBoard, EventType.mcCampaign];
      final candidateEvents = db.gameData.events.values.where((event) => eventTypes.contains(event.type)).toList();
      events.addAll(
        candidateEvents.where(
          (event) =>
              (checkTime(event.startTimeOf(region), room.startedAt) &&
                  checkTime(event.endTime2Of(region), room.endedAt)),
        ),
      );
      if (events.isEmpty) {
        final inRangeEvents =
            candidateEvents
                .where(
                  (event) =>
                      (event.startTimeOf(region) ?? 0) <= room.startedAt &&
                      room.endedAt <= (event.endTime2Of(region) ?? 0),
                )
                .toList();
        if (inRangeEvents.length == 1) {
          events.add(inRangeEvents.single);
        } else {
          final sameStartEvents =
              candidateEvents
                  .where(
                    (event) =>
                        (event.startTimeOf(region) == room.startedAt && room.endedAt <= (event.endTimeOf(region) ?? 0)),
                  )
                  .toList();
          if (sameStartEvents.isNotEmpty) {
            events.add(sameStartEvents.first);
          }
        }
      }
    }
    for (final room in rooms) {
      bool isMain = room.id < 1000;
      if (room.condType == 1 || room.condType == 46) {
        final war = db.gameData.quests[room.condValue]?.war;
        final event = war?.eventReal;
        if (isMain && event == null && war != null) {
          wars.add(war);
        }
      }
    }

    final subtitles = <String>{
      ...events.take(2).map((e) => e.lShortName.l.setMaxLines(1)),
      ...wars.map((e) => e.lName.l.setMaxLines(1)),
    };

    return ListTile(
      dense: true,
      title: Text('${room.startedAt.sec2date().toStringShort()}~${room.endedAt.sec2date().toStringShort()}'),
      subtitle: subtitles.isNotEmpty ? Text(subtitles.join('\n')) : null,
      isThreeLine: subtitles.length > 1,
    );
  }

  Widget _buildImage(String url, double maxHeight, double? aspectRatio) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: CachedImage(
        imageUrl: url,
        placeholder: (_, __) => AspectRatio(aspectRatio: aspectRatio ?? 1344 / 626),
        showSaveOnLongPress: true,
        viewFullOnTap: true,
        cachedOption: CachedImageOption(errorWidget: (context, url, error) => Center(child: Text(url.breakWord))),
      ),
    );
  }

  Widget buildOneRoom(BuildContext context, MstMyRoomAdd room) {
    final asset = AssetURL(region ?? Region.jp);
    switch (room.type2) {
      case MyRoomAddOverwriteType.bgImage:
        return _buildImage(asset.back(room.overwriteId, useFullscreen), 300, useFullscreen ? 1344 / 626 : 1024 / 626);
      case MyRoomAddOverwriteType.bgm:
        final bgm = db.gameData.bgms[room.overwriteId];
        return ListTile(
          dense: true,
          minLeadingWidth: 0,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
          leading: db.getIconImage(
            bgm?.logo,
            aspectRatio: 124 / 60,
            width: 56,
            placeholder: (context) => const SizedBox.shrink(),
          ),
          horizontalTitleGap: 8,
          title: Text(bgm?.tooltip ?? '${S.current.bgm} ${room.overwriteId}'),
          selected: true,
          onTap: () {
            router.push(url: Routes.bgmI(room.overwriteId));
          },
        );
      case MyRoomAddOverwriteType.servantOverlayObject:
        return _buildImage(
          '${asset.extractDir}/MyRoom/FrontObject/${room.overwriteId}/${room.overwriteId}.png',
          300 * (useFullscreen ? 1344 / 626 : 1024 / 626),
          1024 / 1024,
        );
      case MyRoomAddOverwriteType.backObject:
        return _buildImage(
          '${asset.extractDir}/MyRoom/BackObject/${room.overwriteId}/ef_MyRoomObj_at.png',
          300 * (useFullscreen ? 1344 / 626 : 1024 / 626),
          1024 / 1024,
        );
      case MyRoomAddOverwriteType.bgImageMultiple:
      case MyRoomAddOverwriteType.unknown:
        return ListTile(
          dense: true,
          minLeadingWidth: 0,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
          title: Text('${S.current.unknown}: id ${room.id} type ${room.type}, overwriteId ${room.overwriteId}'),
        );
    }
  }

  Widget wrapButtonBar(BuildContext context, _MyRoomChangeType changeType, Widget child) {
    if (changeType == _MyRoomChangeType.bgImage) {
      return Column(
        children: [
          Expanded(child: child),
          kDefaultDivider,
          SafeArea(
            child: OverflowBar(
              alignment: MainAxisAlignment.center,
              children: [
                FilterGroup<bool>(
                  options: const [false, true],
                  values: FilterRadioData.nonnull(useFullscreen),
                  combined: true,
                  optionBuilder: (value) => Text(value ? '1344×626' : '1024×626'),
                  onFilterChanged: (v, _) {
                    setState(() {
                      useFullscreen = v.radioValue!;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }
    return child;
  }
}
