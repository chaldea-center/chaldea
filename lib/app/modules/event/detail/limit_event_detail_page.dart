import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/carousel_util.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../common/not_found.dart';
import '../../quest/quest_list.dart';
import 'bonus.dart';
import 'lottery.dart';
import 'mission.dart';
import 'points.dart';
import 'shop.dart';
import 'towers.dart';
import 'treasure_box.dart';

class EventDetailPage extends StatefulWidget {
  final int? eventId;
  final Event? event;

  EventDetailPage({Key? key, this.eventId, this.event}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  Event? _event;
  Region _region = Region.jp;

  Event get event => _event!;

  @override
  void initState() {
    super.initState();
    _event = widget.event ?? db.gameData.events[widget.eventId];
  }

  @override
  Widget build(BuildContext context) {
    if (_event == null) {
      return NotFoundPage(
        title: 'Event ${widget.eventId}',
        url: Routes.eventI(widget.eventId ?? 0),
      );
    }
    List<Tab> tabs = [];
    List<Widget> views = [];

    void _addTab(String tabName, Widget view) {
      tabs.add(Tab(text: tabName));
      views.add(view);
    }

    _addTab(
      S.current.overview,
      KeepAliveBuilder(
        builder: (context) => EventItemsOverview(event: event, region: _region),
      ),
    );
    if (db.gameData.craftEssences.values
            .any((ce) => ce.eventSkills(event.id).isNotEmpty) ||
        db.gameData.servants.values
            .any((svt) => svt.eventSkills(event.id).isNotEmpty)) {
      _addTab(S.current.event_bonus, EventBonusTab(event: event));
    }

    List<int> shopSlots = event.shop.map((e) => e.slot).toSet().toList()
      ..sort();
    for (final slot in shopSlots) {
      _addTab(
        S.current.event_shop + (shopSlots.length > 1 ? ' ${slot + 1}' : ''),
        EventShopsPage(event: event, slot: slot),
      );
    }
    List<int> rewardGroups =
        event.rewards.map((e) => e.groupId).toSet().toList()..sort();
    for (final groupId in rewardGroups) {
      EventPointGroup? pointGroup =
          event.pointGroups.firstWhereOrNull((e) => e.groupId == groupId);
      String? pointName;
      if (pointGroup != null) {
        pointName =
            db.gameData.mappingData.itemNames[pointGroup.name]?.ofRegion() ??
                pointGroup.name;
      }
      pointName ??= S.current.event_point_reward +
          (rewardGroups.length > 1 ? ' $groupId' : '');
      tabs.add(Tab(
        child: Text.rich(TextSpan(children: [
          if (pointGroup != null)
            CenterWidgetSpan(
                child: db.getIconImage(pointGroup.icon, width: 24)),
          TextSpan(text: pointName),
        ])),
      ));
      views.add(EventPointsPage(event: event, groupId: groupId));
    }
    if (event.missions.isNotEmpty) {
      _addTab(S.current.mission, EventMissionsPage(event: event));
    }

    for (final tower in event.towers) {
      _addTab(tower.name, EventTowersPage(event: event, tower: tower));
    }
    for (int index = 0; index < event.lotteries.length; index++) {
      _addTab(
        S.current.event_lottery +
            (event.lotteries.length > 1 ? ' ${index + 1}' : ''),
        EventLotteryTab(event: event, lottery: event.lotteries[index]),
      );
    }
    if (event.treasureBoxes.isNotEmpty) {
      _addTab(S.current.event_treasure_box, EventTreasureBoxTab(event: event));
    }
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            event.shownName.replaceAll('\n', ' '),
            maxLines: 1,
          ),
          centerTitle: false,
          actions: [popupMenu],
          bottom:
              tabs.length > 1 ? TabBar(tabs: tabs, isScrollable: true) : null,
        ),
        body: TabBarView(children: views),
      ),
    );
  }

  Widget get popupMenu {
    final eventId = widget.event?.id ?? widget.eventId;

    return PopupMenuButton(
      itemBuilder: (context) => [
        ...SharedBuilder.websitesPopupMenuItems(
          atlas: Atlas.dbEvent(event.id),
          mooncell: event.extra.mcLink,
          fandom: event.extra.fandomLink,
        ),
        ...SharedBuilder.noticeLinkPopupMenuItems(
            noticeLink: event.extra.noticeLink),
        if (eventId != null && eventId > 0)
          PopupMenuItem(
            child: const Text('Switch Region'),
            onTap: () async {
              await null;
              final jpEvent = db.gameData.events[eventId];
              final startTime =
                  jpEvent?.extra.startTime.copyWith(jp: jpEvent.startedAt);
              showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) {
                  return SimpleDialog(
                    children: [
                      for (final region in Region.values)
                        ListTile(
                          title: Text(region.name.toUpperCase()),
                          enabled: startTime?.ofRegion(region) != null,
                          onTap: () async {
                            Navigator.pop(context);
                            _changeRegion(region, eventId);
                          },
                        ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.clear),
                      )
                    ],
                  );
                },
              );
            },
          ),
      ],
    );
  }

  void _changeRegion(Region region, int eventId) async {
    EasyLoading.show(status: 'Loading', maskType: EasyLoadingMaskType.clear);
    Event? newEvent;
    if (region == Region.jp) {
      newEvent = db.gameData.events[eventId];
    } else {
      newEvent = await AtlasApi.event(eventId, region: region);
      newEvent?.calcItems(db.gameData);
    }
    _region = region;
    _event = newEvent;
    if (mounted) {
      setState(() {});
    }
    EasyLoading.dismiss();
  }
}

class EventItemsOverview extends StatefulWidget {
  final Event event;
  final Region region;
  const EventItemsOverview(
      {Key? key, required this.event, required this.region})
      : super(key: key);

  @override
  State<EventItemsOverview> createState() => _EventItemsOverviewState();
}

class _EventItemsOverviewState extends State<EventItemsOverview> {
  Event get event => widget.event;

  @override
  Widget build(BuildContext context) {
    final plan = db.curUser.eventPlanOf(event.id);
    final banners = [
      ...event.extra.titleBanner.values.whereType<String>(),
    ];

    List<Widget> children = [
      if (banners.isNotEmpty)
        CarouselUtil.limitHeightWidget(context: context, imageUrls: banners),
    ];
    List<Widget> rows = [
      CustomTableRow(children: [
        TableCellData(
          text: event.shownName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
          color: TableCellData.resolveHeaderColor(context),
        )
      ]),
      if (!Transl.isJP)
        CustomTableRow(children: [
          TableCellData(
            text: event.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
            color: TableCellData.resolveHeaderColor(context).withOpacity(0.5),
          )
        ]),
      // if (event.banner != null)
      //   CustomTableRow(children: [
      //     TableCellData(text: 'Banner', isHeader: true),
      //     TableCellData(
      //       flex: 3,
      //       child: Center(child: db.getIconImage(event.banner, height: 48)),
      //     ),
      //   ]),
    ];
    String _timeText(Region r, int? start, int? end) =>
        '${r.name.toUpperCase()}: ${start?.toDateTimeString() ?? "?"} ~ '
        '${end?.toDateTimeString() ?? "?"}';
    final eventJp = db.gameData.events[event.id];
    List<String> timeInfo = [
      _timeText(widget.region, event.startedAt, event.endedAt),
      if (widget.region != db.curUser.region)
        _timeText(
            db.curUser.region,
            event.extra.startTime.ofRegion(db.curUser.region),
            event.extra.endTime.ofRegion(db.curUser.region)),
      if (Region.jp != widget.region && Region.jp != widget.region)
        _timeText(Region.jp, eventJp?.startedAt, eventJp?.endedAt)
    ];
    for (final time in timeInfo) {
      rows.add(CustomTableRow(
        children: [
          TableCellData(
            text: time,
            maxLines: 1,
            style: const TextStyle(fontSize: 14),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
          )
        ],
      ));
    }

    children.add(CustomTable(children: rows));

    List<Widget> warTiles = [];
    for (final warId in event.warIds) {
      warTiles.add(LayoutBuilder(builder: (context, constraints) {
        final war = db.gameData.wars[warId];
        String title = war == null ? 'War $warId' : war.lLongName.l;
        final height = min(constraints.maxWidth / 2, 164.0) / 142 * 354;
        return ListTile(
          leading: war?.banner == null
              ? null
              : db.getIconImage(war!.banner, height: height),
          horizontalTitleGap: 8,
          title: Text(title, maxLines: 1, textScaleFactor: 0.8),
          onTap: () {
            router.push(url: Routes.warI(warId));
          },
        );
      }));
    }
    if (event.extra.huntingQuestIds.isNotEmpty) {
      warTiles.add(ListTile(
        title: Text(S.current.hunting_quest),
        trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
        onTap: () {
          router.push(
            child: QuestListPage(
              title: S.current.hunting_quest,
              quests: event.extra.huntingQuestIds
                  .map((e) => db.gameData.quests[e])
                  .whereType<Quest>()
                  .toList(),
            ),
          );
        },
      ));
    }

    if (warTiles.isNotEmpty) {
      children.add(TileGroup(header: S.current.war_title, children: warTiles));
    }

    if (!event.isEmpty) {
      children.add(db.onUserData(
        (context, snapshot) => CheckboxListTile(
          title: const Text('ALL'),
          value: plan.enabled,
          onChanged: (v) {
            if (v != null) plan.enabled = v;
            event.updateStat();
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ));
    }

    if (event.itemWarReward.isNotEmpty) {
      children.addAll(_buildSwitchGroup(
        value: () => plan.questReward,
        enabled: () => plan.enabled,
        onChanged: (v) {
          plan.questReward = v;
          event.updateStat();
        },
        title: S.current.game_rewards,
        items: event.itemWarReward,
      ));
    }
    if (event.itemWarDrop.isNotEmpty) {
      children.addAll(_buildSwitchGroup(
        value: () => plan.fixedDrop,
        enabled: () => plan.enabled,
        onChanged: (v) {
          plan.fixedDrop = v;
          event.updateStat();
        },
        title: S.current.quest_fixed_drop,
        items: event.itemWarDrop,
      ));
    }
    if (event.shop.isNotEmpty) {
      children.addAll(_buildSwitchGroup(
        value: () => plan.shop,
        enabled: () => plan.enabled,
        onChanged: (v) {
          plan.shop = v;
          event.updateStat();
        },
        title: S.current.event_shop,
        items: event.itemShop,
      ));
    }
    if (event.rewards.isNotEmpty) {
      children.addAll(_buildSwitchGroup(
        value: () => plan.point,
        enabled: () => plan.enabled,
        onChanged: (v) {
          plan.point = v;
          event.updateStat();
        },
        title: S.current.event_point_reward,
        items: event.itemPointReward,
      ));
    }
    if (event.missions.isNotEmpty) {
      children.addAll(_buildSwitchGroup(
        value: () => plan.mission,
        enabled: () => plan.enabled,
        onChanged: (v) {
          plan.mission = v;
          event.updateStat();
        },
        title: S.current.mission,
        items: event.itemMission,
      ));
    }

    if (event.towers.isNotEmpty) {
      children.addAll(_buildSwitchGroup(
        value: () => plan.tower,
        enabled: () => plan.enabled,
        onChanged: (v) {
          plan.tower = v;
          event.updateStat();
        },
        title: S.current.event_tower,
        items: event.itemTower,
      ));
    }

    for (final lottery in event.lotteries) {
      children.addAll([
        ListTile(
          title: Text(lottery.limited
              ? S.current.event_lottery_limited
              : S.current.event_lottery_unlimited),
          subtitle: lottery.limited
              ? Text(
                  S.current.event_lottery_limit_hint(lottery.maxBoxIndex + 1))
              : null,
          trailing: _inputGroup(
            value: () => plan.lotteries[lottery.id],
            onChanged: (value) {
              if (value < 0) return;
              if (lottery.limited && value > lottery.maxBoxIndex + 1) return;
              plan.lotteries[lottery.id] = value;
            },
            tag: 'lottery_${lottery.id}',
            readOnly: !plan.enabled,
          ),
        ),
        SharedBuilder.groupItems(
          context: context,
          items: lottery.lastBoxItems,
          width: 48,
        ),
      ]);
      final boxesDetail = event.itemLottery[lottery.id];
      if (boxesDetail == null || boxesDetail.isEmpty) continue;
      List<Widget> boxes = [];
      for (final boxIndex in boxesDetail.keys.toList()..sort()) {
        final boxItems = Map.of(boxesDetail[boxIndex]!);
        lottery.lastBoxItems.forEach((key, value) {
          boxItems.addNum(key, -value);
        });
        boxItems.removeWhere((key, value) => value == 0);
        if (boxItems.isEmpty) continue;
        boxes.add(ListTile(
          leading: Text('No.${boxIndex + 1}'),
          title: SharedBuilder.itemGrid(
            context: context,
            items: boxItems.entries,
            width: 48,
          ),
        ));
      }
      if (boxes.isNotEmpty) {
        children.add(TileGroup(children: boxes));
      }
    }

    for (int boxIndex = 0; boxIndex < event.treasureBoxes.length; boxIndex++) {
      final box = event.treasureBoxes[boxIndex];
      final Map<int, int> boxItems = event.itemTreasureBox[box.id] ?? {};
      children.addAll([
        ListTile(
            title: Text('${S.current.event_treasure_box} ${boxIndex + 1}')),
        TileGroup(
          children: [
            for (final itemId in boxItems.keys)
              ListTile(
                leading: GameCardMixin.anyCardItemBuilder(
                    context: context, id: itemId, width: 36),
                title: Text(
                    '${GameCardMixin.anyCardItemName(itemId).l} x ${boxItems[itemId]}'),
                trailing: _inputGroup(
                  value: () => plan.treasureBoxItems[box.id]?[itemId],
                  onChanged: (value) {
                    plan.treasureBoxItems
                        .putIfAbsent(box.id, () => {})[itemId] = value;
                  },
                  tag: 'treasure_box_${box.id}_$itemId',
                  readOnly: !plan.enabled,
                ),
              )
          ],
        )
      ]);
    }

    return ListView.builder(
      itemBuilder: (context, index) => children[index],
      itemCount: children.length,
    );
  }

  List<Widget> _buildSwitchGroup({
    required bool Function() value,
    required bool Function() enabled,
    required ValueChanged<bool> onChanged,
    required String title,
    required Map<int, int> items,
  }) {
    return [
      db.onUserData(
        (context, snapshot) => CheckboxListTile(
          value: value(),
          onChanged: enabled()
              ? (v) {
                  if (v != null) onChanged(v);
                }
              : null,
          title: Text(title),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
      SharedBuilder.groupItems(
        context: context,
        items: items,
        width: 48,
      )
    ];
  }

  Widget _inputGroup({
    required int? Function() value,
    required ValueChanged<int> onChanged,
    required String tag,
    required bool readOnly,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        db.onUserData(
          (context, snapshot) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(value()?.toString() ?? '0'),
          ),
        ),
        SizedBox(
          width: 64,
          child: TextField(
            readOnly: readOnly,
            onChanged: (v) {
              int? n;
              if (v.trim().isEmpty) {
                n = 0;
              } else {
                n = int.tryParse(v);
              }
              if (n != null && n >= 0) {
                EasyDebounce.debounce(
                  tag,
                  const Duration(milliseconds: 500),
                  () {
                    onChanged(n!);
                    event.updateStat();
                  },
                );
              }
            },
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ],
    );
  }
}
