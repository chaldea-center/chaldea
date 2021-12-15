import 'package:chaldea/components/components.dart';
import 'package:flutter/scheduler.dart';

import 'input_tab.dart';
import 'quest_efficiency_tab.dart';
import 'quest_plan_tab.dart';
import 'quest_query_tab.dart';

class FreeQuestCalculatorPage extends StatefulWidget {
  final Map<String, int>? objectiveCounts;

  FreeQuestCalculatorPage({Key? key, this.objectiveCounts}) : super(key: key);

  @override
  _FreeQuestCalculatorPageState createState() =>
      _FreeQuestCalculatorPageState();
}

class _FreeQuestCalculatorPageState extends State<FreeQuestCalculatorPage>
    with SingleTickerProviderStateMixin {
  GLPKSolution? solution;
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
          isScrollable: !Language.isCN,
          tabs: [
            Tab(text: LocalizedText.of(chs: '需求', jpn: 'アイテム', eng: 'Demands', kor: '아이템')),
            Tab(text: S.of(context).plan),
            Tab(text: S.of(context).efficiency),
            Tab(text: S.of(context).free_quest)
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

  void onSolved(GLPKSolution? s) {
    if (s == null) {
      EasyLoading.showToast('no solution');
    } else {
      setState(() {
        solution = s;
      });
      // if change tab index immediately, the second tab won't re-render
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        if (solution!.destination > 0 && solution!.destination < 3) {
          _tabController.index = solution!.destination;
        } else {
          _tabController.index = 1;
        }
      });
    }
  }
}
