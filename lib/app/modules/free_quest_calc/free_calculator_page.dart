import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'input_tab.dart';
import 'quest_efficiency_tab.dart';
import 'quest_plan_tab.dart';
import 'quest_query_tab.dart';

class FreeQuestCalcPage extends StatefulWidget {
  final Map<int, int>? objectiveCounts;

  FreeQuestCalcPage({Key? key, this.objectiveCounts}) : super(key: key);

  @override
  _FreeQuestCalcPageState createState() => _FreeQuestCalcPageState();
}

class _FreeQuestCalcPageState extends State<FreeQuestCalcPage>
    with SingleTickerProviderStateMixin {
  LPSolution? solution;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: Text(S.of(context).free_quest_calculator),
        actions: [
          MarkdownHelpPage.buildHelpBtn(context, 'free_quest_planning.md')
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: S.current.demands),
            Tab(text: S.current.plan),
            Tab(text: S.current.efficiency),
            Tab(text: S.current.free_quest)
          ],
          onTap: (_) {
            FocusScope.of(context).unfocus();
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: TabBarView(
          controller: _tabController,
          children: [
            KeepAliveBuilder(
                builder: (context) => DropCalcInputTab(
                    objectiveCounts: widget.objectiveCounts,
                    onSolved: onSolved)),
            KeepAliveBuilder(
                builder: (context) => QuestPlanTab(solution: solution)),
            KeepAliveBuilder(
                builder: (context) => QuestEfficiencyTab(solution: solution)),
            KeepAliveBuilder(builder: (context) => FreeQuestQueryTab())
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
        if (solution!.destination > 0 && solution!.destination < 3) {
          _tabController.index = solution!.destination;
        } else {
          _tabController.index = 1;
        }
      });
    }
  }
}
