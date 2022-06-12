import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/builders.dart';
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
              // PopupMenuItem(
              //   child: Text(
              //     showSpecialRewards
              //         ? 'Hide Special Rewards'
              //         : 'Show Special Rewards',
              //   ),
              //   onTap: () {
              //     setState(() {
              //       showSpecialRewards = !showSpecialRewards;
              //     });
              //   },
              // )
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabNames.map((name) => Tab(text: name)).toList(),
        ),
      ),
      body: db.onUserData(
        (context, snapshot) => TabBarView(
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
