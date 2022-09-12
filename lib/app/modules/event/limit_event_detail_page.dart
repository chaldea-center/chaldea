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
import 'package:chaldea/widgets/animation_on_scroll.dart';
import 'package:chaldea/widgets/carousel_util.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/not_found.dart';
import '../quest/quest_list.dart';
import 'detail/bonus.dart';
import 'detail/bulletin_board.dart';
import 'detail/cooltime.dart';
import 'detail/digging.dart';
import 'detail/lottery.dart';
import 'detail/mission.dart';
import 'detail/points.dart';
import 'detail/shop.dart';
import 'detail/towers.dart';
import 'detail/treasure_box.dart';

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
    if (event.bulletinBoards.isNotEmpty) {
      _addTab(
          S.current.event_bulletin_board, EventBulletinBoardPage(event: event));
    }
    if (event.digging != null) {
      _addTab(S.current.event_digging,
          EventDiggingTab(event: event, digging: event.digging!));
    }
    if (event.cooltime != null) {
      _addTab(S.current.event_cooltime, EventCooltimePage(event: event));
    }
    if (db.gameData.craftEssences.values
            .any((ce) => ce.eventSkills(event).isNotEmpty) ||
        db.gameData.servantsNoDup.values
            .any((svt) => svt.eventSkills(event.id).isNotEmpty)) {
      _addTab(S.current.event_bonus, EventBonusTab(event: event));
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
          bottom: tabs.length > 1
              ? FixedHeight.tabBar(TabBar(tabs: tabs, isScrollable: true))
              : null,
        ),
        body: TabBarView(children: views),
      ),
    );
  }

  Widget get popupMenu {
    final eventId = widget.event?.id ?? widget.eventId;
    return PopupMenuButton<dynamic>(
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          height: 32,
          child: Text('No.$eventId', textScaleFactor: 0.9),
        ),
        const PopupMenuDivider(),
        ...SharedBuilder.websitesPopupMenuItems(
          atlas: Atlas.dbEvent(event.id),
          mooncell: event.extra.mcLink,
          fandom: event.extra.fandomLink,
        ),
        ...SharedBuilder.noticeLinkPopupMenuItems(
            noticeLink: event.extra.noticeLink),
        if (eventId != null && eventId > 0)
          PopupMenuItem(
            child: Text(S.current.switch_region),
            onTap: () async {
              await null;
              _showSwitchRegion();
            },
          ),
      ],
    );
  }

  void _showSwitchRegion() {
    final eventId = widget.event?.id ?? widget.eventId;
    if (eventId == null || !mounted) return;
    final jpEvent = db.gameData.events[eventId];
    final startTime = jpEvent?.extra.startTime.copyWith(jp: jpEvent.startedAt);
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => SimpleDialog(
        children: [
          for (final region in Region.values)
            ListTile(
              title: Text(region.localName),
              enabled: startTime?.ofRegion(region) != null,
              onTap: () async {
                Navigator.pop(context);
                EasyLoading.show(
                    status: 'Loading', maskType: EasyLoadingMaskType.clear);
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
              },
            ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.clear),
          )
        ],
      ),
    );
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
  late final ScrollController _scrollController;

  Event get event => widget.event;

  LimitEventPlan get plan => db.curUser.limitEventPlanOf(event.id);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final banners = [
      ...event.extra.resolvedBanner.values.whereType<String>(),
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
          title: Text(
            title,
            maxLines: 1,
            textScaleFactor: 0.8,
            overflow: TextOverflow.ellipsis,
          ),
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

    int grailToCrystalCount = event.statItemFixed[Items.grailToCrystalId] ?? 0;
    if (grailToCrystalCount > 0) {
      children.add(db.onUserData(
        (context, snapshot) {
          plan.rerunGrails = plan.rerunGrails.clamp(0, grailToCrystalCount);
          var replacedGrails = grailToCrystalCount - plan.rerunGrails;
          return ListTile(
            title: Text(S.current.rerun_event),
            subtitle: Text(S.current.event_rerun_replace_grail(
                replacedGrails, grailToCrystalCount)),
            trailing: DropdownButton<int>(
              value: plan.rerunGrails,
              items: List.generate(grailToCrystalCount + 1, (index) {
                return DropdownMenuItem(
                    value: index,
                    child: Text((grailToCrystalCount - index).toString()));
              }),
              onChanged: (v) {
                if (v != null) plan.rerunGrails = v;
                event.updateStat();
              },
            ),
          );
        },
      ));
    }

    if (!event.isEmpty) {
      children.add(db.onUserData(
        (context, snapshot) => SimpleAccordion(
          headerBuilder: (context, _) {
            return CheckboxListTile(
              title: Text(S.current.plan),
              value: plan.enabled,
              onChanged: (v) {
                if (v != null) plan.enabled = v;
                event.updateStat();
              },
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
          contentBuilder: (context) {
            final plan2 = plan.copy()..enabled = true;
            final items = db.itemCenter.calcOneEvent(event, plan2);
            return TileGroup(
              children: [
                SharedBuilder.groupItems(
                  context: context,
                  items: items,
                  width: 48,
                )
              ],
            );
          },
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
        title: S.current.quest_reward,
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
      children.add(db.onUserData((context, snapshot) {
        Map<int, int> shopItems = {};
        int excludeCount = 0;
        for (final shopId in event.itemShop.keys) {
          if (plan.shopExcludes.contains(shopId)) {
            excludeCount += 1;
          } else {
            shopItems.addDict(event.itemShop[shopId]!);
          }
        }
        return Column(
          children: _buildSwitchGroup(
            value: () => plan.shop,
            enabled: () => plan.enabled,
            onChanged: (v) {
              plan.shop = v;
              event.updateStat();
            },
            title: S.current.event_shop,
            subtitle:
                excludeCount > 0 ? '$excludeCount ${S.current.ignore}' : null,
            items: shopItems,
          ),
        );
      }));
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
            showValue: true,
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
                title: Text([
                  GameCardMixin.anyCardItemName(itemId).l,
                  if (boxItems[itemId] != 1) ' × ${boxItems[itemId]}'
                ].join()),
                trailing: _inputGroup(
                  value: () => plan.treasureBoxItems[box.id]?[itemId],
                  onChanged: (value) {
                    plan.treasureBoxItems
                        .putIfAbsent(box.id, () => {})[itemId] = value;
                  },
                  tag: 'treasure_box_${box.id}_$itemId',
                ),
              )
          ],
        )
      ]);
    }

    if (event.digging != null) {
      final items = Item.sortMapByPriority(event.itemDigging,
          reversed: false, category: true);
      children.add(ListTile(title: Text(S.current.event_digging)));
      children.add(TileGroup(
        children: [
          for (final itemId in items.keys)
            ListTile(
              leading: GameCardMixin.anyCardItemBuilder(
                  context: context, id: itemId, width: 36),
              title: Text(GameCardMixin.anyCardItemName(itemId).l +
                  (items[itemId] == 1 ? '' : ' x ${items[itemId]}')),
              trailing: _inputGroup(
                value: () => plan.digging[itemId],
                onChanged: (value) {
                  plan.digging[itemId] = value;
                },
                tag: 'event_digging_$itemId',
              ),
            )
        ],
      ));
    }

    for (final extraItems in event.extra.extraFixedItems) {
      children.addAll(_buildSwitchGroup(
        value: () => plan.extraFixedItems[extraItems.id] ?? false,
        enabled: () => plan.enabled,
        onChanged: (v) {
          plan.extraFixedItems[extraItems.id] = v;
          event.updateStat();
        },
        title: '${S.current.event_item_fixed_extra} ${extraItems.id}',
        subtitle: extraItems.detail.l,
        items: extraItems.items,
      ));
    }

    for (final extraItems in event.extra.extraItems) {
      children.add(ListTile(
        title: Text('${S.current.event_item_extra} ${extraItems.id}'),
        subtitle: extraItems.detail.l?.toText(),
      ));
      children.add(TileGroup(
        children: [
          for (final itemId in extraItems.items.keys)
            ListTile(
              leading: Item.iconBuilder(
                  context: context, item: null, itemId: itemId, width: 36),
              title: Text(Item.getName(itemId)),
              subtitle: extraItems.items[itemId]?.l?.toText(),
              trailing: _inputGroup(
                value: () => plan.extraItems[extraItems.id]?[itemId],
                onChanged: (value) {
                  plan.extraItems.putIfAbsent(extraItems.id, () => {})[itemId] =
                      value;
                },
                tag: 'extra_item_${extraItems.id}_$itemId',
              ),
            )
        ],
      ));
    }

    if (event.extra.relatedSummons.isNotEmpty) {
      children.add(ListTile(title: Text(S.current.summon)));
      children.add(TileGroup(
        children: List.generate(event.extra.relatedSummons.length, (index) {
          final summonKey = event.extra.relatedSummons[index];
          final summon = db.gameData.wiki.summons[summonKey];
          return ListTile(
            dense: true,
            title: Text(summon == null ? summonKey : summon.lName),
            onTap: summon == null ? null : () => summon.routeTo(),
          );
        }),
      ));
    }

    return UserScrollListener(
      shouldAnimate: (userScroll) => userScroll.metrics.axis == Axis.vertical,
      initForward: true,
      builder: (context, animationController) => Scaffold(
        floatingActionButton: ScaleTransition(
          scale: animationController,
          child: db.onUserData(
            (context, snapshot) => FloatingActionButton(
              backgroundColor: plan.enabled ? null : Colors.grey,
              onPressed: plan.enabled
                  ? () => _ArchiveEventDialog(event: event, initPlan: plan)
                      .showDialog(context)
                  : null,
              child: const Icon(Icons.archive_outlined),
            ),
          ),
        ),
        body: ListView.builder(
          controller: _scrollController,
          itemBuilder: (context, index) => children[index],
          itemCount: children.length,
        ),
      ),
    );
  }

  List<Widget> _buildSwitchGroup({
    required bool Function() value,
    required bool Function() enabled,
    required ValueChanged<bool> onChanged,
    required String title,
    String? subtitle,
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
          title: Text(
            title,
            textScaleFactor: subtitle == null ? 0.9 : null,
          ),
          subtitle: subtitle?.toText(),
          controlAffinity: ListTileControlAffinity.leading,
          dense: subtitle != null,
        ),
      ),
      SharedBuilder.groupItems(
        context: context,
        items: items,
        width: 48,
      )
    ];
  }

  final Map<String, TextEditingController> _controllers = {};

  Widget _inputGroup({
    required int? Function() value,
    required ValueChanged<int> onChanged,
    required String tag,
    bool showValue = false,
    // required bool readOnly,
  }) {
    Widget child = SizedBox(
      width: 64,
      child: TextFormField(
        // readOnly: readOnly,
        controller: _controllers[tag] ??=
            TextEditingController(text: value()?.toString()),
        onChanged: (v) {
          int? n;
          if (v.trim().isEmpty) {
            n = 0;
          } else {
            n = int.tryParse(v);
          }
          if (n != null && n >= 0) {
            onChanged(n);
            EasyDebounce.debounce(
              tag,
              const Duration(milliseconds: 500),
              () {
                event.updateStat();
              },
            );
          }
        },
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          // hintText: value()?.toString(),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
    if (showValue) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showValue)
            db.onUserData(
              (context, snapshot) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(value()?.toString() ?? '0'),
              ),
            ),
          child,
        ],
      );
    }
    return child;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
  }
}

class _ArchiveEventDialog extends StatefulWidget {
  final Event event;
  final LimitEventPlan initPlan;
  const _ArchiveEventDialog(
      {Key? key, required this.event, required this.initPlan})
      : super(key: key);

  @override
  State<_ArchiveEventDialog> createState() => __ArchiveEventDialogState();
}

class __ArchiveEventDialogState extends State<_ArchiveEventDialog> {
  late final LimitEventPlan plan;
  Map<int, int> items = {};

  Map<int, bool> lotteries = {};
  Map<int, bool> treasureBoxes = {};
  Map<int, bool> extraItems = {};
  Event get event => widget.event;
  @override
  void initState() {
    super.initState();
    plan = widget.initPlan.copy();
  }

  @override
  Widget build(BuildContext context) {
    calcItems();
    List<Widget> children = [];
    void _addOption({
      required String title,
      required bool value,
      required ValueChanged<bool> onChanged,
      String? subtitle,
    }) {
      children.add(CheckboxListTile(
        title: Text(title),
        subtitle: subtitle?.toText(),
        value: value,
        onChanged: (v) {
          setState(() {
            if (v != null) onChanged(v);
          });
        },
      ));
    }

    if (event.itemWarReward.isNotEmpty) {
      _addOption(
        title: S.current.game_rewards,
        value: plan.questReward,
        onChanged: (v) => plan.questReward = v,
      );
    }
    if (event.itemWarDrop.isNotEmpty) {
      _addOption(
        title: S.current.quest_fixed_drop,
        value: plan.fixedDrop,
        onChanged: (v) => plan.fixedDrop = v,
      );
    }
    if (event.shop.isNotEmpty) {
      _addOption(
        title: S.current.event_shop,
        value: plan.shop,
        onChanged: (v) => plan.shop = v,
      );
    }
    if (event.rewards.isNotEmpty) {
      _addOption(
        title: S.current.event_point_reward,
        value: plan.point,
        onChanged: (v) => plan.point = v,
      );
    }
    if (event.missions.isNotEmpty) {
      _addOption(
        title: S.current.mission,
        value: plan.mission,
        onChanged: (v) => plan.mission = v,
      );
    }
    if (event.towers.isNotEmpty) {
      _addOption(
        title: S.current.event_tower,
        value: plan.tower,
        onChanged: (v) => plan.tower = v,
      );
    }
    for (final lottery in event.lotteries) {
      _addOption(
        title:
            '${lottery.limited ? S.current.event_lottery_limited : S.current.event_lottery_unlimited} ${lottery.id}',
        subtitle:
            '${plan.lotteries[lottery.id] ?? 0}/${lottery.limited ? lottery.maxBoxIndex : "∞"}',
        value: lotteries[lottery.id] ?? false,
        onChanged: (v) => lotteries[lottery.id] = v,
      );
    }
    for (int boxIndex = 0; boxIndex < event.treasureBoxes.length; boxIndex++) {
      final box = event.treasureBoxes[boxIndex];
      _addOption(
        title: '${S.current.event_treasure_box} ${boxIndex + 1}(${box.id})',
        value: treasureBoxes[box.id] ?? false,
        onChanged: (v) => treasureBoxes[box.id] = v,
      );
    }
    for (final detail in event.extra.extraFixedItems) {
      _addOption(
        title: '${S.current.event_item_fixed_extra} ${detail.id}',
        value: plan.extraFixedItems[detail.id] ?? false,
        onChanged: (v) => plan.extraFixedItems[detail.id] = v,
      );
    }
    for (final detail in event.extra.extraItems) {
      _addOption(
        title: '${S.current.event_item_extra} ${detail.id}',
        value: extraItems[detail.id] ?? false,
        onChanged: (v) => extraItems[detail.id] = v,
      );
    }
    if (items.values.any((v) => v != 0)) {
      children.add(
          SharedBuilder.groupItems(context: context, items: items, width: 36));
    } else {
      children.add(const ListTile(title: Text('No item')));
    }
    children.add(const SFooter('GrailToLore: not included'));

    return SimpleCancelOkDialog(
      contentPadding:
          const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 24.0),
      title: Text(S.current.event_collect_items),
      content: SingleChildScrollView(
        child: Column(children: children),
      ),
      scrollable: true,
      onTapOk: archiveItems,
    );
  }

  void calcItems() {
    final plan2 = plan.copy();
    plan2.enabled = true;
    plan2.lotteries.removeWhere((key, value) => lotteries[key] != true);
    plan2.treasureBoxItems
        .removeWhere((key, value) => treasureBoxes[key] != true);
    plan2.extraItems.removeWhere((key, value) => extraItems[key] != true);
    items =
        db.itemCenter.calcOneEvent(event, plan2, includingGrailToLore: false);
    final validItems = db.itemCenter.validItems;
    items.removeWhere((key, value) => !validItems.contains(key));
  }

  void archiveItems() {
    if (plan.fixedDrop) widget.initPlan.fixedDrop = false;
    if (plan.questReward) widget.initPlan.questReward = false;
    if (plan.shop) widget.initPlan.shop = false;
    if (plan.point) widget.initPlan.point = false;
    if (plan.mission) widget.initPlan.mission = false;
    if (plan.tower) widget.initPlan.tower = false;
    lotteries.forEach((key, value) {
      if (value) widget.initPlan.lotteries[key] = 0;
    });
    treasureBoxes.forEach((key, value) {
      if (value) widget.initPlan.treasureBoxItems[key]?.clear();
    });
    plan.extraFixedItems.forEach((key, value) {
      if (value) widget.initPlan.extraFixedItems[key] = false;
    });
    extraItems.forEach((key, value) {
      if (value) widget.initPlan.extraItems[key]?.clear();
    });
    db.curUser.items.addDict(items);
    event.updateStat();
    EasyLoading.showSuccess(
        '${S.current.success}: ${S.current.event_collect_items}');
  }
}
