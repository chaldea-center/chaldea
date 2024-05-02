import 'package:flutter/scheduler.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'event_input.dart';
import 'quest_plan_tab.dart';

class EventItemCalcPage extends StatefulWidget {
  final int warId;
  final Map<int, int>? objectiveCounts;

  EventItemCalcPage({super.key, required this.warId, this.objectiveCounts});

  @override
  _EventItemCalcPageState createState() => _EventItemCalcPageState();
}

class _EventItemCalcPageState extends State<EventItemCalcPage> with SingleTickerProviderStateMixin {
  LPSolution? solution;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.free_quest_calculator),
        bottom: FixedHeight.tabBar(TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: [
            Tab(text: S.current.demands),
            Tab(text: S.current.plan),
          ],
        )),
      ),
      body: InheritSelectionArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            KeepAliveBuilder(
                builder: (context) => EventItemInputTab(
                    warId: widget.warId, objectiveCounts: widget.objectiveCounts, onSolved: onSolved)),
            KeepAliveBuilder(builder: (context) => QuestPlanTab(solution: solution)),
          ],
        ),
      ),
    );
  }

  void onSolved(LPSolution? s) {
    if (s == null) {
      EasyLoading.showToast('no solution');
    } else {
      setState(() {
        solution = s;
      });
      // if change tab index immediately, the second tab won't re-render
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (!mounted) return;
        if (solution!.destination > 0 && solution!.destination < _tabController.length) {
          _tabController.index = solution!.destination;
        } else {
          _tabController.index = 1;
        }
      });
    }
  }
}
