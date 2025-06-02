import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/master_mission/solver/scheme.dart';
import 'package:chaldea/app/modules/war/war_detail_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/animation_on_scroll.dart';
import 'package:chaldea/widgets/carousel_util.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/not_found.dart';
import '../item/item_select.dart';
import 'detail/_bonus_enemy_cond.dart';
import 'detail/bonus.dart';
import 'detail/bulletin_board.dart';
import 'detail/campaign.dart';
import 'detail/command_assist.dart';
import 'detail/cooltime.dart';
import 'detail/digging.dart';
import 'detail/fortification.dart';
import 'detail/heel_portrait.dart';
import 'detail/lottery.dart';
import 'detail/mission.dart';
import 'detail/mission_target.dart';
import 'detail/mm.dart';
import 'detail/mural.dart';
import 'detail/points.dart';
import 'detail/random_mission.dart';
import 'detail/recipe.dart';
import 'detail/reward_scene.dart';
import 'detail/shop.dart';
import 'detail/towers.dart';
import 'detail/trade.dart';
import 'detail/treasure_box.dart';
import 'detail/voice.dart';
import 'detail/war_board.dart';

class EventDetailPage extends StatefulWidget {
  final int? eventId;
  final Event? event;
  final Region? region;

  EventDetailPage({super.key, this.eventId, this.event, this.region});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  Event? _event;
  Region _region = Region.jp;

  Event get event => _event!;
  int? get eventId => _event?.id ?? widget.event?.id ?? widget.eventId;

  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _region = widget.region ?? Region.jp;
    if (widget.event == null) {
      fetchData(_region);
    } else {
      _event = widget.event;
    }
  }

  Future<void> fetchData(Region region, {bool force = false}) async {
    if (eventId == null) return;
    Event? newEvent;
    if (region == Region.jp && !force) {
      newEvent = db.gameData.events[eventId];
    }
    if (newEvent == null) {
      _loading = true;
      if (mounted) setState(() {});
      EasyLoading.show();
      newEvent = await AtlasApi.event(eventId!, region: region, expireAfter: force ? Duration.zero : null);
      EasyLoading.dismiss();
      newEvent?.calcItems(db.gameData);
      _loading = false;
    }
    _region = region;
    _event = newEvent;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_event == null) {
      return NotFoundPage(title: 'Event ${widget.eventId}', url: Routes.eventI(widget.eventId ?? 0), loading: _loading);
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
    // special event mechanisms
    for (int index = 0; index < event.lotteries.length; index++) {
      _addTab(
        S.current.event_lottery + (event.lotteries.length > 1 ? ' ${index + 1}' : ''),
        EventLotteryTab(event: event, lottery: event.lotteries[index]),
      );
    }
    if (event.murals.isNotEmpty) {
      _addTab(S.current.event_mural, EventMuralPage(event: event));
    }
    if (event.heelPortraits.isNotEmpty) {
      // before tower
      _addTab(S.current.event_heel, EventHeelPortraitPage(event: event));
    }
    if (event.towers.isNotEmpty) {
      final tabName = event.towers.length == 1
          ? Transl.misc2('TowerName', event.towers.first.name)
          : S.current.event_tower;
      _addTab(tabName, EventTowersPage(towers: event.towers));
    }
    if (event.warBoards.isNotEmpty) {
      _addTab(S.current.war_board, EventWarBoardTab(event: event));
    }
    if (event.treasureBoxes.isNotEmpty) {
      _addTab(S.current.event_treasure_box, EventTreasureBoxTab(event: event));
    }
    if (event.cooltime != null) {
      _addTab(S.current.event_cooltime, EventCooltimePage(event: event));
    }
    if (event.recipes.isNotEmpty) {
      _addTab(S.current.event_recipe, EventRecipePage(event: event));
    }
    if (event.digging != null) {
      _addTab(S.current.event_digging, EventDiggingTab(event: event, digging: event.digging!));
    }
    if (event.fortifications.isNotEmpty) {
      _addTab(S.current.event_fortification, EventFortificationPage(event: event));
    }
    if (event.tradeGoods.isNotEmpty) {
      _addTab(S.current.event_trade, EventTradePage(event: event));
    }
    // missions
    if (event.randomMissions.isNotEmpty) {
      _addTab(S.current.detective_mission, EventRandomMissionsPage(event: event));
    }
    final normalMissions = event.missions.where((e) => e.type != MissionType.random).toList();
    if (normalMissions.isNotEmpty) {
      _addTab(
        S.current.mission,
        EventMissionsPage(event: event, missions: normalMissions, onSwitchRegion: _showSwitchRegion),
      );
    }
    if (event.missions.isNotEmpty && event.warIds.isNotEmpty) {
      if (event.missions.any(
        (em) =>
            CustomMission.fromEventMission(em)?.conds.any((cond) => cond.type.isTraitType || cond.type.isClassType) ==
            true,
      )) {
        _addTab(S.current.mission_target, KeepAliveBuilder(builder: (context) => EventMissionTargetPage(event: event)));
      }
    }
    // point rewards
    if (event.pointRewards.isNotEmpty) {
      _addTab(S.current.event_point_reward, EventPointsPage(event: event));
    }

    // shop last
    List<int> shopSlots = event.shop.map((e) => e.slot).toSet().toList();
    shopSlots.sort();
    for (int index = 0; index < shopSlots.length; index++) {
      final shops = event.shop.where((s) => s.slot == shopSlots[index]).toList();
      shops.sort2((e) => e.priority);
      _addTab(
        S.current.shop + (shopSlots.length > 1 ? ' ${index + 1}' : ''),
        EventShopsPage(event: event, shops: shops, region: widget.region),
      );
    }
    if (event.commandAssists.isNotEmpty) {
      _addTab(S.current.command_assist, EventCommandAssistPage(event: event));
    }
    if (db.gameData.craftEssences.values.any((ce) => ce.eventSkills(event.id).isNotEmpty) ||
        db.gameData.servantsNoDup.values.any(
          (svt) => svt.eventSkills(eventId: event.id, includeZero: false).isNotEmpty,
        )) {
      _addTab(S.current.event_bonus, EventBonusTab(event: event));
    }
    if (event.bulletinBoards.isNotEmpty) {
      _addTab(S.current.event_bulletin_board, EventBulletinBoardPage(event: event, onSwitchRegion: _showSwitchRegion));
    }
    if (event.voices.isNotEmpty) {
      _addTab(S.current.voice, EventVoicePage(event: event));
    }
    if (event.rewardScenes.isNotEmpty) {
      _addTab('Scenes', EventRewardScenePage(event: event));
    }
    if ((db.gameData.events.values.any((e) => EventRelatedCampaigns.isRelatedCampaign(_region, event, e)))) {
      // if (event.type == EventType.eventQuest &&
      //     (event.campaigns.isNotEmpty ||
      //         db.gameData.events.values.any((e) => EventRelatedCampaigns.isRelatedCampaign(_region, event, e)))) {
      _addTab(S.current.event_campaign, EventRelatedCampaigns(event: event, region: _region));
    }
    final mms = db.gameData.masterMissions.values.where(event.isRelatedMasterMission).toList();
    if (mms.isNotEmpty) {
      _addTab(S.current.master_mission, EventRelatedMMPage(event: event, mms: mms));
    }
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(event.shownName.replaceAll('\n', ' '), maxLines: 1),
          centerTitle: false,
          actions: [popupMenu],
          bottom: tabs.length > 1
              ? FixedHeight.tabBar(TabBar(tabs: tabs, isScrollable: true, tabAlignment: TabAlignment.center))
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
        PopupMenuItem(enabled: false, height: 32, child: Text('No.$eventId', textScaler: const TextScaler.linear(0.9))),
        const PopupMenuDivider(),
        ...SharedBuilder.websitesPopupMenuItems(
          atlas: event.id < 0 ? null : Atlas.dbEvent(event.id, _region),
          mooncell: event.extra.mcLink,
          fandom: event.extra.fandomLink,
        ),
        ...SharedBuilder.noticeLinkPopupMenuItems(noticeLink: event.extra.noticeLink),
        if (eventId != null && eventId > 0) ...[
          PopupMenuItem(
            child: Text(S.current.switch_region),
            onTap: () {
              _showSwitchRegion();
            },
          ),
          PopupMenuItem(
            child: Text(S.current.refresh),
            onTap: () {
              fetchData(_region, force: true);
            },
          ),
        ],
      ],
    );
  }

  void _showSwitchRegion() {
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
                fetchData(region);
              },
            ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
    );
  }
}

class EventItemsOverview extends StatefulWidget {
  final Event event;
  final Region region;
  const EventItemsOverview({super.key, required this.event, required this.region});

  @override
  State<EventItemsOverview> createState() => _EventItemsOverviewState();
}

class _EventItemsOverviewState extends State<EventItemsOverview> {
  late final ScrollController _scrollController = ScrollController();

  Event get event => widget.event;

  LimitEventPlan get plan => db.curUser.limitEventPlanOf(event.id);

  @override
  Widget build(BuildContext context) {
    final banners = event.extra.allBanners;
    if (banners.isEmpty && event.shopBanner != null) banners.add(event.shopBanner!);

    List<Widget> children = [
      if (banners.isNotEmpty) CarouselUtil.limitHeightWidget(context: context, imageUrls: banners),
    ];
    Set<String> shownNames = {event.lName.l}, jpNames = {event.name};
    for (final eventAdd in event.eventAdds) {
      if (eventAdd.overwriteType == EventOverwriteType.name && eventAdd.overwriteText.isNotEmpty) {
        shownNames.add(Transl.eventNames(eventAdd.overwriteText).l);
        jpNames.add(eventAdd.overwriteText);
      }
    }

    List<Widget> rows = [
      CustomTableRow(
        children: [
          TableCellData(
            text: shownNames.join('\n'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
            color: TableCellData.resolveHeaderColor(context),
          ),
        ],
      ),
      if (!Transl.isJP)
        CustomTableRow(
          children: [
            TableCellData(
              text: jpNames.join('\n'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              color: TableCellData.resolveHeaderColor(context).withAlpha(128),
            ),
          ],
        ),
      if (event.type != EventType.eventQuest) CustomTableRow.fromTexts(texts: [(event.type.name)]),
    ];
    final eventJp = db.gameData.events[event.id];
    final startTime = event.extra.startTime.copyWith(jp: eventJp?.startedAt);
    final endTime = event.extra.endTime.copyWith(jp: eventJp?.endedAt);
    if (widget.region != Region.jp) {
      startTime.update(event.startedAt, widget.region);
      endTime.update(event.endedAt, widget.region);
    }
    rows.add(
      CustomTableRow.fromChildren(
        children: [
          _EventTime(
            startTime: startTime,
            endTime: endTime,
            shownRegions: {Region.jp, db.curUser.region, widget.region},
            format: (v) => v?.sec2date().toStringShort(omitSec: true) ?? '?',
          ),
        ],
      ),
    );

    if (event.id < 0) {
      rows.add(
        CustomTableRow.fromChildren(
          children: [Text('* Campaign info from Mooncell wiki *', style: Theme.of(context).textTheme.bodySmall)],
        ),
      );
    }

    children.add(CustomTable(selectable: true, children: rows));
    if (event.type == EventType.questCampaign) {
      children.add(SFooter(S.current.ap_campaign_time_mismatch_hint));
    }

    List<Widget> warTiles = [];
    for (final warId in event.warIds) {
      warTiles.add(
        LayoutBuilder(
          builder: (context, constraints) {
            final war = db.gameData.wars[warId];
            String title = war == null ? 'War $warId' : war.lLongName.l;
            final height = min(constraints.maxWidth / 2, 164.0) / 142 * 354;
            return ListTile(
              leading: war?.shownBanner == null ? null : db.getIconImage(war?.shownBanner, height: height),
              horizontalTitleGap: 8,
              title: Text(
                title,
                maxLines: 1,
                textScaler: const TextScaler.linear(0.8),
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                router.push(url: Routes.warI(warId));
              },
            );
          },
        ),
      );
    }

    // extra quests not in wars
    Set<int> warQuestIds = {};
    for (final warId in event.warIds) {
      warQuestIds.addAll(db.gameData.wars[warId]?.quests.map((e) => e.id) ?? {});
    }
    if (warTiles.isNotEmpty) {
      children.add(TileGroup(header: S.current.war, children: warTiles));
    }
    // quests
    final originEventQuestIds = db.gameData.others.eventQuestGroups[event.id] ?? [];
    Set<int> extraQuestIds = originEventQuestIds.toSet().difference(warQuestIds);
    if (event.isAdvancedQuestEvent) {
      final advancedQuests = db.gameData.wars[WarId.advanced]?.quests.where((q) => q.openedAt == event.startedAt) ?? [];
      // advanced 1 contains all quests
      extraQuestIds.removeWhere((e) => db.gameData.quests[e]?.warId == WarId.advanced);
      extraQuestIds.addAll(advancedQuests.map((e) => e.id));
    }
    final extraQuests = extraQuestIds.map((e) => db.gameData.quests[e]).whereType<Quest>().toList();

    if (extraQuests.isNotEmpty) {
      children.add(addQuestCategoryTile(context: context, event: event, extraQuests: extraQuests));
    }

    // Mahoyo bonus enemy
    if (event.id == 80472) {
      children.add(
        TileGroup(
          header: 'Temp Data',
          children: [
            ListTile(
              dense: true,
              title: Text(M.of(cn: "追加怪物的条件", na: "Bonus Enemy Conditions")),
              subtitle: Text(M.of(cn: "仅活动期间可用", na: "Only available during event")),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {
                if (widget.region == Region.jp && event.endedAt < DateTime.now().timestamp) {
                  SimpleConfirmDialog(
                    title: Text(S.current.hint),
                    content: Text(
                      "${S.current.event}:\n- if ${S.current.ended}: "
                      "${S.current.quest}→${S.current.additional_enemy}→${S.current.condition}🔍",
                    ),
                    onTapOk: () {
                      router.pushPage(BonusEnemyCondPage(event: event, region: widget.region));
                    },
                  ).showDialog(context);
                } else {
                  router.pushPage(BonusEnemyCondPage(event: event, region: widget.region));
                }
              },
            ),
          ],
        ),
      );
    }
    // event svt
    List<Widget> svtTiles = [];
    for (final eventSvt in event.svts) {
      final svt = db.gameData.entities[eventSvt.svtId];
      if (svt?.type == SvtType.svtMaterialTd) continue;
      svtTiles.add(
        ListTile(
          dense: true,
          leading: svt?.iconBuilder(
            context: context,
            overrideIcon: db.gameData.servantsById[eventSvt.svtId]?.borderedIcon,
          ),
          title: Text(svt?.lName.l ?? "SVT ${eventSvt.svtId}"),
          onTap: () {
            router.push(url: Routes.servantI(eventSvt.svtId));
          },
          trailing: eventSvt.releaseConditions.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    SimpleConfirmDialog(
                      title: Text(S.current.condition),
                      scrollable: true,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final release in eventSvt.releaseConditions)
                            CondTargetValueDescriptor.commonRelease(commonRelease: release, textScaleFactor: 0.8),
                        ],
                      ),
                    ).showDialog(context);
                  },
                  icon: const Icon(Icons.info_outline),
                ),
        ),
      );
    }
    if (svtTiles.isNotEmpty) {
      children.add(TileGroup(header: S.current.event_svt, children: svtTiles));
    }

    int grailToCrystalCount = event.statItemFixed[Items.grailToCrystalId] ?? 0;
    if (grailToCrystalCount > 0) {
      children.add(
        db.onUserData((context, snapshot) {
          plan.rerunGrails = plan.rerunGrails.clamp(0, grailToCrystalCount);
          var replacedGrails = grailToCrystalCount - plan.rerunGrails;
          return ListTile(
            title: Text(S.current.rerun_event),
            subtitle: Text(S.current.event_rerun_replace_grail(replacedGrails, grailToCrystalCount)),
            trailing: DropdownButton<int>(
              value: plan.rerunGrails,
              items: List.generate(grailToCrystalCount + 1, (index) {
                return DropdownMenuItem(value: index, child: Text((grailToCrystalCount - index).toString()));
              }),
              onChanged: (v) {
                if (v != null) plan.rerunGrails = v;
                event.updateStat();
              },
            ),
          );
        }),
      );
    }

    if (!event.isEmpty) {
      children.add(
        db.onUserData(
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
                children: [SharedBuilder.groupItems(context: context, items: items, width: 48)],
              );
            },
          ),
        ),
      );
    }
    if (event.itemWarReward.isNotEmpty) {
      children.addAll(
        _buildSwitchGroup(
          value: () => plan.questReward,
          enabled: () => plan.enabled,
          onChanged: (v) {
            plan.questReward = v;
            event.updateStat();
          },
          title: S.current.quest_reward,
          items: event.itemWarReward,
        ),
      );
    }
    if (event.itemWarDrop.isNotEmpty) {
      children.addAll(
        _buildSwitchGroup(
          value: () => plan.fixedDrop,
          enabled: () => plan.enabled,
          onChanged: (v) {
            plan.fixedDrop = v;
            event.updateStat();
          },
          title: S.current.quest_fixed_drop,
          items: event.itemWarDrop,
        ),
      );
    }
    if (event.shop.isNotEmpty) {
      children.add(
        db.onUserData((context, snapshot) {
          Map<int, int> shopItems = {};
          int customCount = 0;
          for (final shop in event.shop) {
            int count = plan.shopBuyCount[shop.id] ?? shop.limitNum;
            if (count != shop.limitNum) {
              customCount += 1;
            }
            shopItems.addDict(event.itemShop[shop.id]?.multiple(count) ?? {});
          }
          return Column(
            children: _buildSwitchGroup(
              value: () => plan.shop,
              enabled: () => plan.enabled,
              onChanged: (v) {
                plan.shop = v;
                event.updateStat();
              },
              title: S.current.shop,
              subtitle: customCount > 0 ? '$customCount Customized' : null,
              items: shopItems,
            ),
          );
        }),
      );
    }
    if (event.pointRewards.isNotEmpty) {
      children.addAll(
        _buildSwitchGroup(
          value: () => plan.point,
          enabled: () => plan.enabled,
          onChanged: (v) {
            plan.point = v;
            event.updateStat();
          },
          title: S.current.event_point_reward,
          items: event.itemPointReward,
        ),
      );
    }
    if (event.missions.isNotEmpty) {
      children.addAll(
        _buildSwitchGroup(
          value: () => plan.mission,
          enabled: () => plan.enabled,
          onChanged: (v) {
            plan.mission = v;
            event.updateStat();
          },
          title: S.current.mission,
          items: event.itemMission,
        ),
      );
    }

    if (event.towers.isNotEmpty) {
      children.addAll(
        _buildSwitchGroup(
          value: () => plan.tower,
          enabled: () => plan.enabled,
          onChanged: (v) {
            plan.tower = v;
            event.updateStat();
          },
          title: S.current.event_tower,
          items: event.itemTower,
        ),
      );
    }

    if (event.warBoards.isNotEmpty) {
      children.addAll(
        _buildSwitchGroup(
          value: () => plan.warBoard,
          enabled: () => plan.enabled,
          onChanged: (v) {
            plan.warBoard = v;
            event.updateStat();
          },
          title: '${S.current.war_board} (${S.current.event_treasure_box})',
          items: event.itemWarBoard,
        ),
      );
    }

    for (final lottery in event.lotteries) {
      children.addAll([
        ListTile(
          title: Text(lottery.limited ? S.current.event_lottery_limited : S.current.event_lottery_unlimited),
          subtitle: lottery.limited ? Text(S.current.event_lottery_limit_hint(lottery.maxBoxIndex + 1)) : null,
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
        SharedBuilder.groupItems(context: context, items: lottery.lastBoxItems, width: 48),
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
        boxes.add(
          ListTile(
            dense: true,
            leading: Text('No.${boxIndex + 1}'),
            title: SharedBuilder.itemGrid(context: context, items: boxItems.entries, width: 32),
          ),
        );
      }
      if (boxes.isNotEmpty) {
        children.add(TileGroup(children: boxes));
      }
    }

    for (int boxIndex = 0; boxIndex < event.treasureBoxes.length; boxIndex++) {
      final box = event.treasureBoxes[boxIndex];
      final Map<int, int> boxItems = event.itemTreasureBox[box.id] ?? {};
      children.addAll([
        ListTile(title: Text('${S.current.event_treasure_box} ${boxIndex + 1}')),
        TileGroup(
          children: [
            for (final itemId in boxItems.keys)
              ListTile(
                dense: true,
                leading: db.onUserData(
                  (context, snapshot) => Item.iconBuilder(
                    context: context,
                    item: null,
                    itemId: itemId,
                    text: [
                      db.curUser.items[itemId] ?? 0,
                      db.itemCenter.itemLeft[itemId] ?? 0,
                    ].map((e) => e.format()).join('\n'),
                  ),
                ),
                title: Text(
                  [GameCardMixin.anyCardItemName(itemId).l, if (boxItems[itemId] != 1) ' × ${boxItems[itemId]}'].join(),
                ),
                trailing: _inputGroup(
                  value: () => plan.treasureBoxItems[box.id]?[itemId],
                  onChanged: (value) {
                    plan.treasureBoxItems.putIfAbsent(box.id, () => {})[itemId] = value;
                  },
                  tag: 'treasure_box_${box.id}_$itemId',
                ),
              ),
          ],
        ),
      ]);
    }

    for (final extraItems in event.extra.extraFixedItems) {
      children.addAll(
        _buildSwitchGroup(
          value: () => plan.extraFixedItems[extraItems.id] ?? false,
          enabled: () => plan.enabled,
          onChanged: (v) {
            plan.extraFixedItems[extraItems.id] = v;
            event.updateStat();
          },
          title: '${S.current.event_item_fixed_extra} ${extraItems.id}',
          subtitle: extraItems.detail.l,
          items: extraItems.items,
        ),
      );
    }

    for (final extraItems in event.extra.extraItems) {
      children.add(
        ListTile(
          title: Text('${S.current.event_item_extra} ${extraItems.id}'),
          subtitle: extraItems.detail.l?.toText(),
        ),
      );
      children.add(
        TileGroup(
          children: [
            for (final itemId in extraItems.items.keys)
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                minVerticalPadding: 0,
                leading: db.onUserData(
                  (context, snapshot) => Item.iconBuilder(
                    context: context,
                    item: null,
                    itemId: itemId,
                    // width: 32,
                    text: [
                      db.curUser.items[itemId] ?? 0,
                      db.itemCenter.itemLeft[itemId] ?? 0,
                    ].map((e) => e.format()).join('\n'),
                  ),
                ),
                title: Text(Item.getName(itemId)),
                subtitle: extraItems.items[itemId]?.l?.toText(),
                horizontalTitleGap: 8,
                trailing: _inputGroup(
                  value: () => plan.extraItems[extraItems.id]?[itemId],
                  onChanged: (value) {
                    plan.extraItems.putIfAbsent(extraItems.id, () => {})[itemId] = value;
                  },
                  tag: 'extra_item_${extraItems.id}_$itemId',
                ),
              ),
          ],
        ),
      );
    }

    if (!event.isEmpty) {
      children.add(
        ListTile(
          title: Text(S.current.event_custom_item),
          trailing: IconButton(
            onPressed: () {
              router.push(
                child: ItemSelectPage(
                  disabledItems: plan.customItems.keys.toList(),
                  onSelected: (v) {
                    plan.customItems[v] = 0;
                    event.updateStat();
                    if (mounted) setState(() {});
                  },
                ),
              );
            },
            icon: const Icon(Icons.add),
            tooltip: S.current.add,
          ),
        ),
      );
      final itemIds = Item.sortMapByPriority(plan.customItems, category: true, removeZero: false).keys.toList();
      children.add(
        TileGroup(
          children: [
            if (itemIds.isEmpty)
              ListTile(
                title: Text(S.current.event_custom_item_empty_hint, style: Theme.of(context).textTheme.bodySmall),
              ),
            for (final itemId in itemIds)
              ListTile(
                leading: db.onUserData(
                  (context, snapshot) => Item.iconBuilder(
                    context: context,
                    item: null,
                    itemId: itemId,
                    width: 42,
                    text: [
                      db.curUser.items[itemId] ?? 0,
                      db.itemCenter.itemLeft[itemId] ?? 0,
                    ].map((e) => e.format()).join('\n'),
                  ),
                ),
                title: Text(Item.getName(itemId)),
                horizontalTitleGap: 8,
                trailing: Wrap(
                  children: [
                    _inputGroup(
                      value: () => plan.customItems[itemId],
                      onChanged: (value) {
                        plan.customItems[itemId] = value;
                      },
                      tag: 'custom_item_$itemId',
                    ),
                    IconButton(
                      onPressed: () {
                        plan.customItems.remove(itemId);
                        event.updateStat();
                        if (mounted) setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                      color: Theme.of(context).colorScheme.error,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 48),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    if (event.campaignQuests.isNotEmpty || event.campaigns.isNotEmpty) {
      children.add(EventCampaignDetail(event: event, region: widget.region));
    }

    if (event.type == EventType.interludeCampaign) {
      List<Quest> quests = db.gameData.quests.values
          .where((quest) => quest.releaseOverwrites.any((e) => e.eventId == event.id))
          .toList();
      quests.sort2((e) => -e.priority);
      if (quests.isNotEmpty) {
        children.add(
          TileGroup(
            header: S.current.interlude,
            children: quests.map((quest) {
              final svtId = quest.releaseConditions
                  .firstWhereOrNull((release) => [CondType.svtGet, CondType.svtFriendship].contains(release.type))
                  ?.targetId;
              final svt = db.gameData.servantsById[svtId];
              final status = svt?.status;
              final releaseOverwrites = quest.releaseOverwrites.where((e) => e.eventId == event.id).toList();
              releaseOverwrites.sortByList((e) => [e.startedAt, e.endedAt, e.priority]);
              final sameReleaseTime = releaseOverwrites.map((e) => '${e.startedAt}-${e.endedAt}').toSet().length <= 1;
              List<Widget> releaseChildren = [];
              Widget fmtDateRange(int start, int end) => Text(
                '${start.sec2date().toCustomString(second: false)} ~ ${start.sec2date().toCustomString(year: false, second: false)}',
                style: const TextStyle(fontSize: 12),
              );
              for (final (index, release) in releaseOverwrites.indexed) {
                releaseChildren.add(
                  CondTargetValueDescriptor(
                    condType: release.condType,
                    target: release.condId,
                    value: release.condNum,
                    unknownMsg: release.closedMessage,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
                if (!sameReleaseTime) {
                  final nextRelease = releaseOverwrites.getOrNull(index + 1);
                  if (nextRelease == null ||
                      nextRelease.startedAt != release.startedAt ||
                      nextRelease.endedAt != release.endedAt) {
                    releaseChildren.add(fmtDateRange(release.startedAt, release.endedAt));
                  }
                }
              }
              if (sameReleaseTime &&
                  releaseOverwrites.isNotEmpty &&
                  (releaseOverwrites.first.startedAt != event.startedAt ||
                      releaseOverwrites.first.endedAt != event.endedAt)) {
                releaseChildren.add(fmtDateRange(releaseOverwrites.first.startedAt, releaseOverwrites.first.endedAt));
              }

              return ListTile(
                leading: svt == null
                    ? const SizedBox.shrink()
                    : svt.iconBuilder(
                        context: context,
                        width: 40,
                        text: status != null && status.favorite ? 'NP${status.cur.npLv}' : '',
                      ),
                title: Text(quest.lName.l),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: releaseChildren),
                onTap: quest.routeTo,
              );
            }).toList(),
          ),
        );
      }
    }

    final summons = event.extra.relatedSummons;
    if (summons.isNotEmpty) {
      children.add(ListTile(title: Text(S.current.summon_banner)));
      summons.sort2((summon) => summon.startTime.l ?? 0);
      children.add(
        TileGroup(
          children: List.generate(summons.length, (index) {
            final summon = summons[index];
            return ListTile(dense: true, title: Text(summon.lName.l), onTap: () => summon.routeTo());
          }),
        ),
      );
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
                  ? () async {
                      await _ArchiveEventDialog(event: event, initPlan: plan).showDialog(context);
                      if (mounted) setState(() {});
                    }
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
          title: Text(title, textScaler: subtitle == null ? const TextScaler.linear(0.9) : null),
          subtitle: subtitle?.toText(),
          controlAffinity: ListTileControlAffinity.leading,
          dense: subtitle != null,
        ),
      ),
      SharedBuilder.groupItems(context: context, items: items, width: 48),
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
    final v = value() ?? 0;
    final controller = _controllers[tag] ??= TextEditingController(text: value()?.toString());
    if ((int.tryParse(controller.text) ?? 0) != v) {
      controller.text = v.toString();
    }
    Widget child = SizedBox(
      width: 64,
      child: TextFormField(
        // readOnly: readOnly,
        controller: controller,
        onChanged: (v) {
          int? n;
          if (v.trim().isEmpty) {
            n = 0;
          } else {
            n = int.tryParse(v);
          }
          if (n != null && n >= 0) {
            onChanged(n);
            EasyDebounce.debounce(tag, const Duration(milliseconds: 500), () {
              event.updateStat();
            });
          }
        },
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          // hintText: value()?.toString(),
        ),
        keyboardType: const TextInputType.numberWithOptions(signed: true),
      ),
    );
    if (showValue) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showValue)
            db.onUserData(
              (context, snapshot) =>
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(value()?.toString() ?? '0')),
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
  const _ArchiveEventDialog({required this.event, required this.initPlan});

  @override
  State<_ArchiveEventDialog> createState() => __ArchiveEventDialogState();
}

class __ArchiveEventDialogState extends State<_ArchiveEventDialog> {
  late final LimitEventPlan plan;
  Event get event => widget.event;

  Map<int, int> items = {};

  Map<int, bool> lotteries = {};
  Map<int, bool> treasureBoxes = {};
  Map<int, bool> extraItems = {};
  bool customItem = true;

  @override
  void initState() {
    super.initState();
    plan = widget.initPlan.copy();
    customItem = widget.initPlan.customItems.isNotEmpty;
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
      children.add(
        CheckboxListTile(
          title: Text(title),
          subtitle: subtitle?.toText(),
          value: value,
          onChanged: (v) {
            setState(() {
              if (v != null) onChanged(v);
            });
          },
        ),
      );
    }

    if (event.itemWarReward.isNotEmpty) {
      _addOption(title: S.current.game_rewards, value: plan.questReward, onChanged: (v) => plan.questReward = v);
    }
    if (event.itemWarDrop.isNotEmpty) {
      _addOption(title: S.current.quest_fixed_drop, value: plan.fixedDrop, onChanged: (v) => plan.fixedDrop = v);
    }
    if (event.shop.isNotEmpty) {
      _addOption(title: S.current.shop, value: plan.shop, onChanged: (v) => plan.shop = v);
    }
    if (event.pointRewards.isNotEmpty) {
      _addOption(title: S.current.event_point_reward, value: plan.point, onChanged: (v) => plan.point = v);
    }
    if (event.missions.isNotEmpty) {
      _addOption(title: S.current.mission, value: plan.mission, onChanged: (v) => plan.mission = v);
    }
    if (event.towers.isNotEmpty) {
      _addOption(title: S.current.event_tower, value: plan.tower, onChanged: (v) => plan.tower = v);
    }
    if (event.warBoards.isNotEmpty) {
      _addOption(title: S.current.war_board, value: plan.warBoard, onChanged: (v) => plan.warBoard = v);
    }
    for (final lottery in event.lotteries) {
      _addOption(
        title: '${lottery.limited ? S.current.event_lottery_limited : S.current.event_lottery_unlimited} ${lottery.id}',
        subtitle: '${plan.lotteries[lottery.id] ?? 0}/${lottery.limited ? lottery.maxBoxIndex : "∞"}',
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
    if (plan.customItems.isNotEmpty) {
      _addOption(title: S.current.event_custom_item, value: customItem, onChanged: (v) => customItem = v);
    }
    if (items.values.any((v) => v != 0)) {
      children.add(SharedBuilder.groupItems(context: context, items: items, width: 36));
    } else {
      children.add(const ListTile(title: Text('No item')));
    }
    children.add(const SFooter('GrailToLore: not included'));

    return SimpleConfirmDialog(
      contentPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 24.0),
      title: Text(S.current.event_collect_items),
      content: SingleChildScrollView(child: Column(children: children)),
      scrollable: true,
      onTapOk: archiveItems,
    );
  }

  void calcItems() {
    final plan2 = plan.copy();
    plan2.enabled = true;
    plan2.lotteries.removeWhere((key, value) => lotteries[key] != true);
    plan2.treasureBoxItems.removeWhere((key, value) => treasureBoxes[key] != true);
    plan2.extraItems.removeWhere((key, value) => extraItems[key] != true);
    if (!customItem) plan2.customItems.clear();
    items = db.itemCenter.calcOneEvent(event, plan2, includingGrailToLore: false);
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
    if (plan.warBoard) widget.initPlan.warBoard = false;
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
    if (customItem) {
      widget.initPlan.customItems = widget.initPlan.customItems.map((key, value) => MapEntry(key, 0));
    }
    db.curUser.items.addDict(items);
    event.updateStat();
    EasyLoading.showSuccess('${S.current.success}: ${S.current.event_collect_items}');
  }
}

class _EventTime extends StatefulWidget {
  final MappingBase<int> startTime;
  final MappingBase<int>? endTime;
  final Iterable<Region> shownRegions;
  final String Function(int? time) format;
  const _EventTime({required this.startTime, this.endTime, required this.shownRegions, required this.format});

  @override
  State<_EventTime> createState() => __EventTimeState();
}

class __EventTimeState extends State<_EventTime> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    bool hasExtra = false;
    final shownRegions = widget.shownRegions.toList();
    for (final region in Region.values) {
      String? timeStr;
      final start = widget.startTime.ofRegion(region),
          end = widget.endTime?.ofRegion(region),
          now = DateTime.now().timestamp;
      if (start == null && end == null && region != Region.jp) continue;
      if (widget.endTime == null) {
        timeStr = '${region.upper}: ${widget.format(start)}';
      } else {
        timeStr = '${region.upper}: ${widget.format(start)} ~ ${widget.format(end)}';
      }
      bool ongoing = start != null && end != null && now >= start && now <= end;
      if (shownRegions.contains(region) || showAll) {
        children.add(
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '● ',
                  style: TextStyle(color: ongoing ? Colors.green : Colors.transparent),
                ),
                TextSpan(text: timeStr),
              ],
            ),
            style: const TextStyle(fontSize: 14, fontFamily: kMonoFont),
            textAlign: TextAlign.center,
          ),
        );
      }
      if (!shownRegions.contains(region)) hasExtra = true;
    }
    Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
    if (hasExtra) {
      child = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: child),
          Icon(showAll ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16),
        ],
      );
    }
    return InkWell(
      onTap: () {
        setState(() {
          showAll = !showAll;
        });
      },
      child: child,
    );
  }
}
