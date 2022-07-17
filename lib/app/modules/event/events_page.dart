import 'dart:convert';

import 'package:flutter/material.dart';

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
import 'tabs/exchange_ticket_tab.dart';
import 'tabs/limit_event_tab.dart';
import 'tabs/main_story_tab.dart';

class EventListPage extends StatefulWidget {
  EventListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EventListPageState();
}

class EventListPageState extends State<EventListPage>
    with
        SearchableListState<Event, EventListPage>,
        SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  Iterable<Event> get wholeData => db.gameData.events.values;

  final filterData = db.settings.eventFilterData;
  List<String> get tabNames => [
        S.current.limited_event,
        S.current.main_story,
        S.current.exchange_ticket,
      ];
  List<ScrollController> scrollControllers = [];

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
    scrollControllers =
        List.generate(tabNames.length, (index) => ScrollController());
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    for (var controller in scrollControllers) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    filterShownList();
    return Scaffold(
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: db.onUserData((context, snapshot) {
          return AutoSizeText.rich(
            TextSpan(
              text: S.current.event_title,
              children: [
                if (!db.curUser.sameEventPlan)
                  TextSpan(
                    text: ' (${db.curUser.getFriendlyPlanName()})',
                    style: const TextStyle(fontSize: 14),
                  )
              ],
            ),
            maxLines: 1,
          );
        }),
        bottom: showSearchBar && _tabController.index == 0
            ? searchBar
            : FixedHeight.tabBar(TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: tabNames.map((name) => Tab(text: name)).toList(),
              )),
        actions: actions,
      ),
      body: db.onUserData(
        (context, snapshot) => TabBarView(
          controller: _tabController,
          children: <Widget>[
            KeepAliveBuilder(
              builder: (_) => LimitEventTab(
                limitEvents: shownList,
                reversed: filterData.reversed,
                showOutdated: filterData.showOutdated,
                showSpecialRewards: filterData.showSpecialRewards,
                scrollController: scrollControllers[0],
              ),
            ),
            KeepAliveBuilder(
              builder: (_) => MainStoryTab(
                reversed: filterData.reversed,
                showOutdated: filterData.showOutdated,
                showSpecialRewards: filterData.showSpecialRewards,
                scrollController: scrollControllers[1],
              ),
            ),
            KeepAliveBuilder(
                builder: (_) => ExchangeTicketTab(
                    reversed: filterData.reversed,
                    showOutdated: filterData.showOutdated)),
          ],
        ),
      ),
    );
  }

  List<Widget> get actions {
    return <Widget>[
      if (_tabController.index == 0) searchIcon,
      if (_tabController.index == 0)
        IconButton(
          icon: const Icon(Icons.filter_alt),
          tooltip: S.current.filter,
          onPressed: () => FilterPage.show(
            context: context,
            builder: (context) => EventFilterPage(
              filterData: filterData,
              onChanged: (_) {
                if (mounted) setState(() {});
              },
            ),
          ),
        ),
      IconButton(
        icon: FaIcon(
          filterData.reversed
              ? FontAwesomeIcons.arrowDownWideShort
              : FontAwesomeIcons.arrowUpWideShort,
          size: 20,
        ),
        tooltip: S.current.sort_order,
        onPressed: () {
          setState(() => filterData.reversed = !filterData.reversed);
          db.saveSettings();
        },
      ),
      PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Text(S.current.select_plan),
            onTap: () async {
              await null;
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
            onTap: () async {
              await null;
              copyPlan();
            },
          ),
          PopupMenuItem(
            child: Text(
              filterData.showSpecialRewards
                  ? S.current.special_reward_hide
                  : S.current.special_reward_show,
            ),
            onTap: () {
              setState(() {
                filterData.showSpecialRewards = !filterData.showSpecialRewards;
              });
            },
          )
        ],
      ),
    ];
  }

  @override
  Widget buildScrollable({bool useGrid = false}) {
    return RefreshIndicator(
      child: super.buildScrollable(useGrid: useGrid),
      onRefresh: () async {
        final cards =
            await AtlasApi.basicCraftEssences(expireAfter: Duration.zero) ?? [];
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
    if (filterData.type.options.isNotEmpty) {
      final List<EventCustomType> types = [
        if (event.lotteries.isNotEmpty) EventCustomType.lottery,
        if (event.rewards.isNotEmpty) EventCustomType.point,
        if (event.towers.isNotEmpty) EventCustomType.tower,
        if (event.treasureBoxes.isNotEmpty) EventCustomType.treasureBox,
        if (event.digging != null) EventCustomType.digging,
        if (event.missions.isNotEmpty) EventCustomType.mission,
        if (event.type == EventType.warBoard) EventCustomType.warBoard,
        if (db.gameData.wars[event.warIds.getOrNull(0)]?.parentWarId == 1004)
          EventCustomType.mainInterlude,
        if (event.extra.huntingQuestIds.isNotEmpty) EventCustomType.hunting,
      ];
      if (!filterData.type.matchAny(types)) {
        return false;
      }
    }
    return true;
  }

  @override
  Iterable<String?> getSummary(Event event) sync* {
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
      builder: (context) => SimpleDialog(
        title: Text(S.current.select_copy_plan_source),
        children: List.generate(db.curUser.plans.length, (index) {
          bool isCur = index == db.curUser.curSvtPlanNo;
          String title = db.curUser.getFriendlyPlanName(index);
          if (isCur) title += ' (${S.current.current_})';
          return ListTile(
            title: Text(title),
            onTap: isCur
                ? null
                : () {
                    final src = UserPlan.fromJson(
                        jsonDecode(jsonEncode(db.curUser.plans[index])));
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
