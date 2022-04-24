import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'tabs/exchange_ticket_tab.dart';
import 'tabs/limit_event_tab.dart';
import 'tabs/main_story_tab.dart';

class EventListPage extends StatefulWidget {
  EventListPage({Key? key}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool get reversed => db.settings.display.eventsReversed;

  bool get showOutdated => db.settings.display.eventsShowOutdated;
  bool showSpecialRewards = false;

  List<String> get tabNames => [
        S.current.limited_event,
        S.current.main_story,
        S.current.exchange_ticket,
      ];
  List<ScrollController> scrollControllers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabNames.length, vsync: this);
    scrollControllers =
        List.generate(tabNames.length, (index) => ScrollController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.event_title),
        titleSpacing: 0,
        leading: const MasterBackButton(),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                db.settings.display.eventsShowOutdated = !showOutdated;
                db.saveSettings();
              });
            },
            tooltip: S.current.outdated,
            icon: Icon(
                showOutdated ? Icons.timer_off_outlined : Icons.timer_outlined),
          ),
          IconButton(
            icon: FaIcon(
              reversed
                  ? FontAwesomeIcons.arrowDownWideShort
                  : FontAwesomeIcons.arrowUpWideShort,
              size: 20,
            ),
            tooltip: S.current.sort_order,
            onPressed: () {
              setState(() => db.settings.display.eventsReversed = !reversed);
              db.saveSettings();
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(
                  showSpecialRewards
                      ? 'Hide Special Rewards'
                      : 'Show Special Rewards',
                ),
                onTap: () {
                  setState(() {
                    showSpecialRewards = !showSpecialRewards;
                  });
                },
              )
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabNames.map((name) => Tab(text: name)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          KeepAliveBuilder(
            builder: (_) => LimitEventTab(
              reversed: reversed,
              showOutdated: showOutdated,
              showSpecialRewards: showSpecialRewards,
              scrollController: scrollControllers[0],
            ),
          ),
          KeepAliveBuilder(
            builder: (_) => MainStoryTab(
              reversed: reversed,
              showOutdated: showOutdated,
              showSpecialRewards: showSpecialRewards,
              scrollController: scrollControllers[1],
            ),
          ),
          KeepAliveBuilder(
              builder: (_) => ExchangeTicketTab(
                  reversed: reversed, showOutdated: showOutdated)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    for (var controller in scrollControllers) {
      controller.dispose();
    }
  }
}
