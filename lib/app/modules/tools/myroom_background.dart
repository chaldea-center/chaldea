import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';

class MyRoomBGAssetsPage extends StatefulWidget {
  const MyRoomBGAssetsPage({super.key});

  @override
  State<MyRoomBGAssetsPage> createState() => _MyRoomBGAssetsPageState();
}

// public enum MyRoomAddEntity.OverwriteType
// {
// 	BG_IMAGE = 1,
// 	BGM = 2,
// 	SERVANT_OVERLAY_OBJECT = 6,
// 	BG_IMAGE_MULTIPLE = 7,
// 	BACK_OBJECT = 8,
// }

class MstMyRoomAdd {
  // [id] is not unique
  int id;
  int type;
  int priority;
  int overwriteId;
  int condType;
  int condValue; // 1,46, 113-commonRelease
  int condValue2;
  int startedAt;
  int endedAt;

  MstMyRoomAdd({
    required this.id,
    required this.type,
    required this.priority,
    required this.overwriteId,
    required this.condType,
    required this.condValue,
    required this.condValue2,
    required this.startedAt,
    required this.endedAt,
  });

  factory MstMyRoomAdd.fromJson(Map<String, dynamic> json) {
    return MstMyRoomAdd(
      id: json['id'],
      type: json['type'],
      priority: json['priority'],
      overwriteId: json['overwriteId'],
      condType: json['condType'],
      condValue: json['condValue'],
      condValue2: json['condValue2'],
      startedAt: json['startedAt'],
      endedAt: json['endedAt'],
    );
  }
}

class _MyRoomBGAssetsPageState extends State<MyRoomBGAssetsPage>
    with RegionBasedState<List<MstMyRoomAdd>, MyRoomBGAssetsPage> {
  List<String> assets = [];

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
        final data = List<Map>.from(list).map((e) => MstMyRoomAdd.fromJson(Map.from(e))).toList();
        return data.where((e) => e.type == 1 && e.overwriteId > 0).toList();
      },
    );
  }

  int _t = DateTime.now().timestamp;
  bool expanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(S.current.my_room_background, maxLines: 1, minFontSize: 10),
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
      ),
      body: buildBody(context),
    );
  }

  @override
  Widget buildContent(BuildContext context, List<MstMyRoomAdd> data) {
    final asset = AssetURL(region ?? Region.jp);
    Map<String, List<MstMyRoomAdd>> grouped = {};
    for (final room in data) {
      grouped.putIfAbsent('${room.startedAt}.${room.endedAt}', () => []).add(room);
    }
    grouped = sortDict(grouped, compare: (a, b) => b.value.first.startedAt.compareTo(a.value.first.startedAt));
    final groupList = grouped.values.toList();

    return ListView.builder(
      itemCount: groupList.length,
      itemBuilder: (context, index) {
        final rooms = groupList[index];
        return SimpleAccordion(
          key: Key('room_group_${_t}_$index'),
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
                final event = war?.event;
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
              subtitle: Text(<String>[
                ...events.take(2).map((e) => e.lShortName.l.setMaxLines(1)),
                ...wars.map((e) => e.lName.l.setMaxLines(1))
              ].join('\n')),
              isThreeLine: events.length > 1,
            );
          },
          contentBuilder: (context) {
            List<Widget> children = [];
            for (final room in rooms) {
              for (final fs in [true, false]) {
                final url = asset.back(room.overwriteId, fs);
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
  }
}
