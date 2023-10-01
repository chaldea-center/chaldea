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
  Future<List<MstMyRoomAdd>?> fetchData(Region? r) {
    CachedApi.cacheManager.clearFailed();
    return CachedApi.cacheManager.getModel(
      'https://git.atlasacademy.io/atlasacademy/fgo-game-data/raw/branch/${r ?? Region.jp}/master/mstMyroomAdd.json',
      (list) {
        return List<Map>.from(list).map((e) => MstMyRoomAdd.fromJson(Map.from(e))).toList();
      },
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
          grouped.putIfAbsent('${room.startedAt}.${room.endedAt}', () => []).add(room);
        }
      }
      grouped = sortDict(grouped, compare: (a, b) => b.value.first.startedAt.compareTo(a.value.first.startedAt));
      final groupList = grouped.values.toList();
      Widget view = ListView.builder(
        itemCount: groupList.length,
        itemBuilder: (context, index) {
          final rooms = groupList[index];
          return SimpleAccordion(
            key: Key('room_group_${type.id}_${_t}_$index'),
            expanded: expanded,
            headerBuilder: (context, _) {
              final room = rooms.first;
              final wars = <NiceWar>{};
              final events = db.gameData.events.values.where((event) {
                return [EventType.eventQuest, EventType.warBoard].contains(event.type) &&
                    (event.startTimeOf(region) == room.startedAt || event.endTimeOf(region) == room.endedAt);
              }).toSet();
              for (final room in rooms) {
                bool isMain = false;
                if (region == Region.cn || region == Region.tw) {
                  isMain = room.endedAt > kNeverClosedTimestampCN;
                } else {
                  isMain = room.endedAt > kNeverClosedTimestamp;
                }
                if (room.condType == 1 || room.condType == 46) {
                  final war = db.gameData.quests[room.condValue]?.war;
                  final event = war?.eventReal;
                  if (isMain && event == null && war != null) {
                    wars.add(war);
                  } else if (event != null) {
                    events.add(event);
                  }
                }
              }

              return ListTile(
                dense: true,
                title: Text('${room.startedAt.sec2date().toDateString()}~${room.endedAt.sec2date().toDateString()}'),
                subtitle: events.isNotEmpty || wars.isNotEmpty
                    ? Text(<String>[
                        ...events.take(2).map((e) => e.lShortName.l.setMaxLines(1)),
                        ...wars.map((e) => e.lName.l.setMaxLines(1))
                      ].join('\n'))
                    : null,
                isThreeLine: events.length > 1,
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
