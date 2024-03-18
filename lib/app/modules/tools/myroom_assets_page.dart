import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../api/chaldea.dart';
import '../common/filter_group.dart';

class MyRoomAssetsPage extends StatefulWidget {
  const MyRoomAssetsPage({super.key});

  @override
  State<MyRoomAssetsPage> createState() => _MyRoomAssetsPageState();
}

class _MyRoomAssetsPageState extends State<MyRoomAssetsPage>
    with RegionBasedState<List<MstMyRoomAdd>, MyRoomAssetsPage>, SingleTickerProviderStateMixin {
  bool useFullscreen = true;
  late final tabController = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    region = Region.jp;
    doFetchData();
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
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(
                onTap: doFetchData,
                child: Text(S.current.refresh),
              ),
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
          })
        ],
        bottom: FixedHeight.tabBar(
            TabBar(controller: tabController, tabs: [Tab(text: S.current.background), Tab(text: S.current.bgm)])),
      ),
      body: buildBody(context),
    );
  }

  @override
  Widget buildContent(BuildContext context, List<MstMyRoomAdd> data) {
    final asset = AssetURL(region ?? Region.jp);
    List<Widget> views = [];
    for (final type in [MyRoomAddOverwriteType.bgImage, MyRoomAddOverwriteType.bgm]) {
      Map<String, List<MstMyRoomAdd>> grouped = {};
      for (final room in data) {
        if (room.type == type.id && room.overwriteId > 0) {
          grouped.putIfAbsent('${room.id}.${room.startedAt}.${room.endedAt}', () => []).add(room);
        }
      }
      grouped = sortDict(grouped, compare: (a, b) => b.value.first.startedAt.compareTo(a.value.first.startedAt));
      final groupList = grouped.values.toList();
      Widget view = ListView.builder(
        itemCount: groupList.length,
        itemBuilder: (context, index) {
          final rooms = groupList[index];
          bool checkTime(int? a, int b) {
            if (a == null) return false;
            return (a - b).abs() <= 3600 * 5;
          }

          return SimpleAccordion(
            key: Key('room_group_${type.id}_${_t}_$index'),
            expanded: expanded,
            headerBuilder: (context, _) {
              final room = rooms.first;
              final wars = <NiceWar>{};
              final events = <Event>{};
              final event = db.gameData.events[room.id];
              if (room.id > 1000 && event != null) {
                final start = event.startTimeOf(region), end = event.endTimeOf(region);
                if (start != null &&
                    end != null &&
                    room.startedAt >= start - 3600 * 5 &&
                    room.endedAt <= end + 3600 * 5) {
                  events.add(event);
                }
              }
              if (events.isEmpty) {
                events.addAll(db.gameData.events.values.where((event) {
                  return [EventType.eventQuest, EventType.warBoard, EventType.mcCampaign].contains(event.type) &&
                      (checkTime(event.startTimeOf(region), room.startedAt) &&
                          checkTime(event.endTimeOf(region), room.endedAt));
                }));
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
                ...wars.map((e) => e.lName.l.setMaxLines(1))
              };

              return ListTile(
                dense: true,
                title: Text('${room.startedAt.sec2date().toStringShort()}~${room.endedAt.sec2date().toStringShort()}'),
                subtitle: subtitles.isNotEmpty ? Text(subtitles.join('\n')) : null,
                isThreeLine: subtitles.length > 1,
              );
            },
            contentBuilder: (context) {
              List<Widget> children = [];
              for (final room in rooms) {
                if (room.type == MyRoomAddOverwriteType.bgImage.id && room.overwriteId > 0) {
                  final url = asset.back(room.overwriteId, useFullscreen);
                  children.add(ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: CachedImage(
                      imageUrl: url,
                      placeholder: (_, __) => AspectRatio(
                        aspectRatio: url.endsWith('_1344_626.png') ? 1344 / 626 : 1024 / 626,
                      ),
                      showSaveOnLongPress: true,
                      viewFullOnTap: true,
                      cachedOption: CachedImageOption(
                        errorWidget: (context, url, error) => Center(
                          child: Text(url.breakWord),
                        ),
                      ),
                    ),
                  ));
                } else if (room.type == MyRoomAddOverwriteType.bgm.id && room.overwriteId > 0) {
                  final bgm = db.gameData.bgms[room.overwriteId];
                  children.add(ListTile(
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
                  ));
                }
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: divideList(children, const SizedBox(height: 4)),
              );
            },
          );
        },
      );
      if (type == MyRoomAddOverwriteType.bgImage) {
        view = Column(
          children: [
            Expanded(child: view),
            kDefaultDivider,
            SafeArea(
              child: ButtonBar(
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
                  )
                ],
              ),
            )
          ],
        );
      }
      views.add(view);
    }

    return TabBarView(controller: tabController, children: views);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }
}
