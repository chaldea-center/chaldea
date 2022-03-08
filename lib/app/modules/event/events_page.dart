import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  bool get reversed => db2.settings.display.eventsReversed;

  bool get showOutdated => db2.settings.display.eventsShowOutdated;
  bool showSpecialRewards = false;

  List<String> get tabNames => [
        S.current.limited_event,
        S.current.main_record,
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
                db2.settings.display.eventsShowOutdated = !showOutdated;
                db2.saveSettings();
              });
            },
            tooltip: 'Outdated',
            icon: Icon(showOutdated ? Icons.timer_off : Icons.timer),
          ),
          IconButton(
            icon: FaIcon(
              reversed
                  ? FontAwesomeIcons.sortAmountDown
                  : FontAwesomeIcons.sortAmountUp,
              size: 20,
            ),
            tooltip: 'Reversed',
            onPressed: () {
              setState(() => db2.settings.display.eventsReversed = !reversed);
              db2.saveSettings();
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
