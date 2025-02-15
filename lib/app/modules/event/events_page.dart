import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/builders.dart';
import '../common/filter_page_base.dart';
import 'filter.dart';
import 'tabs/campaign_tab.dart';
import 'tabs/exchange_ticket_tab.dart';
import 'tabs/limit_event_tab.dart';
import 'tabs/main_story_tab.dart';

class EventListPage extends StatefulWidget {
  EventListPage({super.key});

  @override
  State<StatefulWidget> createState() => EventListPageState();
}

class EventListPageState extends State<EventListPage>
    with SearchableListState<Event, EventListPage>, SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  Iterable<Event> get wholeData => db.gameData.events.values;

  final filterData = db.settings.filters.eventFilterData;
  List<String> get tabNames => [
    S.current.limited_event,
    S.current.main_story,
    S.current.exchange_ticket,
    S.current.event_campaign,
  ];

  bool get shouldEnableSearch => _tabController.index == 0 || _tabController.index == 3;
  bool get shouldShowFilter => _tabController.index == 0 || _tabController.index == 2 || _tabController.index == 3;

  @override
  void initState() {
    super.initState();
    if (db.settings.autoResetFilter) {
      filterData.reset();
    }
    _tabController = TabController(length: tabNames.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    filterShownList();
    List<Event> limitEvents = [], campaigns = [];

    for (final event in shownList) {
      if (const [EventType.eventQuest, EventType.warBoard].contains(event.type)) {
        limitEvents.add(event);
      } else if (event.type == EventType.mcCampaign) {
        if (filterData.showCampaign) limitEvents.add(event);
      } else {
        campaigns.add(event);
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: db.onUserData((context, snapshot) {
          return AutoSizeText.rich(
            TextSpan(
              text: S.current.event,
              children: [
                if (!db.curUser.sameEventPlan)
                  TextSpan(text: ' (${db.curUser.getFriendlyPlanName()})', style: const TextStyle(fontSize: 14)),
              ],
            ),
            maxLines: 1,
          );
        }),
        bottom:
            showSearchBar && shouldEnableSearch
                ? searchBar
                : FixedHeight.tabBar(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    tabs: tabNames.map((name) => Tab(text: name)).toList(),
                  ),
                ),
        actions: actions,
      ),
      body: InheritSelectionArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return db.onUserData(
              (context, snapshot) => TabBarView(
                controller: _tabController,
                children: <Widget>[
                  KeepAliveBuilder(
                    builder:
                        (_) => LimitEventTab(
                          limitEvents: limitEvents,
                          reversed: filterData.reversed,
                          showOutdated: filterData.showOutdated,
                          showSpecialRewards: filterData.showSpecialRewards,
                          // showEmpty: filterData.showEmpty,
                          showEmpty: true,
                          showBanner: filterData.showBanner && constraints.maxWidth > 290,
                        ),
                  ),
                  KeepAliveBuilder(
                    builder:
                        (_) => MainStoryTab(
                          reversed: filterData.reversed,
                          showOutdated: filterData.showOutdated,
                          showSpecialRewards: filterData.showSpecialRewards,
                          showBanner: filterData.showBanner && constraints.maxWidth > 420,
                        ),
                  ),
                  KeepAliveBuilder(
                    builder:
                        (_) => ExchangeTicketTab(reversed: filterData.reversed, showOutdated: filterData.showOutdated),
                  ),
                  KeepAliveBuilder(
                    builder:
                        (_) => CampaignEventTab(
                          campaignEvents: campaigns,
                          reversed: filterData.reversed,
                          showOutdated: filterData.showOutdated,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> get actions {
    return <Widget>[
      if (shouldEnableSearch) searchIcon,
      if (shouldShowFilter)
        IconButton(
          icon: const Icon(Icons.filter_alt),
          tooltip: S.current.filter,
          onPressed:
              () => FilterPage.show(
                context: context,
                builder:
                    (context) => EventFilterPage(
                      filterData: filterData,
                      onChanged: (_) {
                        if (mounted) setState(() {});
                      },
                    ),
              ),
        ),
      IconButton(
        icon: FaIcon(
          filterData.reversed ? FontAwesomeIcons.arrowDownWideShort : FontAwesomeIcons.arrowUpWideShort,
          size: 20,
        ),
        tooltip: S.current.sort_order,
        onPressed: () {
          setState(() => filterData.reversed = !filterData.reversed);
          db.saveSettings();
        },
      ),
      PopupMenuButton(
        itemBuilder:
            (context) => [
              PopupMenuItem(
                child: Text(S.current.select_plan),
                onTap: () {
                  SharedBuilder.showSwitchPlanDialog(
                    context: context,
                    onChange: (index) {
                      db.curUser.curSvtPlanNo = index;
                      db.curUser.ensurePlanLarger();
                      db.itemCenter.calculate();
                    },
                  );
                },
              ),
              PopupMenuItem(
                child: Text(S.current.copy_plan_menu),
                onTap: () {
                  copyPlan();
                },
              ),
              PopupMenuItem(
                child: Text(
                  filterData.showSpecialRewards ? S.current.special_reward_hide : S.current.special_reward_show,
                ),
                onTap: () {
                  setState(() {
                    filterData.showSpecialRewards = !filterData.showSpecialRewards;
                  });
                },
              ),
            ],
      ),
    ];
  }

  @override
  Widget buildScrollable({bool useGrid = false}) {
    return RefreshIndicator(
      child: super.buildScrollable(useGrid: useGrid),
      onRefresh: () async {
        final cards = await AtlasApi.basicCraftEssences(expireAfter: Duration.zero) ?? [];
        int _added = 0;
        for (final basicCard in cards) {
          if (db.gameData.craftEssences.containsKey(basicCard.collectionNo)) {
            continue;
          }
          final card = await AtlasApi.ce(basicCard.id);
          if (card == null) continue;
          db.gameData.craftEssences[card.collectionNo] = card;
          _added += 1;
        }
        if (_added > 0) {
          db.gameData.preprocess();
          db.notifyAppUpdate();
          EasyLoading.showSuccess('+ $_added ${S.current.craft_essence} !');
        }
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget listItemBuilder(Event event) => throw UnimplementedError();

  @override
  Widget gridItemBuilder(Event event) => throw UnimplementedError();

  @override
  bool filter(Event event) {
    if (filterData.ongoing.options.isNotEmpty) {
      if (filterData.ongoing.options.every((region) => !event.isOnGoing(region))) {
        return false;
      }
    }
    if (!filterData.eventType.matchOne(event.type)) {
      return false;
    }
    if (!filterData.campaignType.matchAny(event.campaigns.map((e) => e.target))) {
      return false;
    }
    if (filterData.contentType.options.isNotEmpty) {
      final war = event.warIds.isEmpty ? null : db.gameData.wars[event.warIds.first];
      final Set<EventCustomType> types = {
        if (event.lotteries.isNotEmpty) EventCustomType.lottery,
        if (event.isRaidEvent) EventCustomType.raid,
        if (event.pointRewards.isNotEmpty) EventCustomType.point,
        if (event.missions.isNotEmpty) EventCustomType.mission,
        if (event.randomMissions.isNotEmpty) EventCustomType.special,
        if (event.shop.isNotEmpty) EventCustomType.shop,
        if (event.towers.isNotEmpty) EventCustomType.tower,
        if (event.treasureBoxes.isNotEmpty) EventCustomType.special,
        if (event.digging != null) EventCustomType.special,
        if (event.cooltime != null) EventCustomType.special,
        if (event.recipes.isNotEmpty) EventCustomType.special,
        if (event.fortifications.isNotEmpty) EventCustomType.special,
        if (event.tradeGoods.isNotEmpty) EventCustomType.special,
        if (event.bulletinBoards.isNotEmpty) EventCustomType.bulletinBoard,
        if (event.type == EventType.warBoard) EventCustomType.warBoard,
        if (event.isExchangeSvtEvent || event.id == 80335) EventCustomType.exchangeSvt, // plus 6th Anni SSR
        if (war != null && war.id > 1000 && war.parentWars.contains(WarId.mainInterlude)) EventCustomType.mainInterlude,
        if (event.isHuntingEvent) EventCustomType.hunting,
      };
      if (types.isEmpty) types.add(EventCustomType.others);
      if (!filterData.contentType.matchAny(types)) {
        return false;
      }
    }
    return true;
  }

  @override
  Iterable<String?> getSummary(Event event) sync* {
    yield event.id.toString();
    yield* SearchUtil.getAllKeys(event.lName);
    yield* SearchUtil.getAllKeys(event.lShortName);
  }

  void copyPlan() {
    if (db.curUser.sameEventPlan) {
      EasyLoading.showInfo(S.current.same_event_plan);
      return;
    }
    showDialog(
      context: context,
      useRootNavigator: false,
      builder:
          (context) => SimpleDialog(
            title: Text(S.current.select_copy_plan_source),
            children: List.generate(db.curUser.plans.length, (index) {
              bool isCur = index == db.curUser.curSvtPlanNo;
              String title = db.curUser.getFriendlyPlanName(index);
              if (isCur) title += ' (${S.current.current_})';
              return ListTile(
                title: Text(title),
                onTap:
                    isCur
                        ? null
                        : () {
                          final src = UserPlan.fromJson(jsonDecode(jsonEncode(db.curUser.plans[index])));
                          db.curPlan_
                            ..limitEvents = src.limitEvents
                            ..mainStories = src.mainStories
                            ..tickets = src.tickets;
                          db.itemCenter.calculate();
                          Navigator.of(context).pop();
                        },
              );
            }),
          ),
    );
  }
}
