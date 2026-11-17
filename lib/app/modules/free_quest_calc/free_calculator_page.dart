import 'package:flutter/scheduler.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/analysis/analysis.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../war/wars_page.dart';
import 'input_tab.dart';
import 'quest_efficiency_tab.dart';
import 'quest_plan_tab.dart';

class FreeQuestCalcPage extends StatefulWidget {
  final Map<int, int>? objectiveCounts;

  FreeQuestCalcPage({super.key, this.objectiveCounts});

  /// Ask for item abundance (bronze/silver/gold), then open this page with
  /// [objectiveCounts]. Shared by item list and item statistics entries.
  static Future<void> showPlanDialog(BuildContext context, Map<int, int> objectiveCounts) async {
    await _FreeQuestAbundantDialog(objectiveCounts: objectiveCounts).showDialog(context);
  }

  @override
  _FreeQuestCalcPageState createState() => _FreeQuestCalcPageState();
}

class _FreeQuestAbundantDialog extends StatefulWidget {
  final Map<int, int> objectiveCounts;

  const _FreeQuestAbundantDialog({required this.objectiveCounts});

  @override
  State<_FreeQuestAbundantDialog> createState() => _FreeQuestAbundantDialogState();
}

class _FreeQuestAbundantDialogState extends State<_FreeQuestAbundantDialog> {
  late final List<TextEditingController> _controllers = List.generate(
    3,
    (index) => TextEditingController(text: db.userData.itemAbundantValue[index].toString()),
  );

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleConfirmDialog(
      title: Text(S.current.item_exceed_hint, style: const TextStyle(fontSize: 16)),
      confirmText: S.current.plan,
      content: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (int index = 0; index < 3; index++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text([S.current.bronze, S.current.silver, S.current.gold][index]),
                SizedBox(
                  width: 40,
                  child: TextFormField(
                    controller: _controllers[index],
                    keyboardType: const TextInputType.numberWithOptions(signed: true),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(isDense: true),
                    onChanged: (s) {
                      if (s == '-') {
                        db.userData.itemAbundantValue[index] = 0;
                      } else {
                        db.userData.itemAbundantValue[index] = int.tryParse(s) ?? db.userData.itemAbundantValue[index];
                      }
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
      onTapOk: () {
        Future.delayed(const Duration(milliseconds: 500), () {
          router.push(
            url: Routes.freeCalc,
            child: FreeQuestCalcPage(objectiveCounts: widget.objectiveCounts),
          );
        });
      },
      actions: [
        TextButton(
          onPressed: () {
            for (final controller in _controllers) {
              controller.text = '0';
            }
            db.userData.itemAbundantValue.fillRange(0, db.userData.itemAbundantValue.length, 0);
          },
          child: Text(S.current.clear),
        ),
      ],
    );
  }
}

class _FreeQuestCalcPageState extends State<FreeQuestCalcPage> with SingleTickerProviderStateMixin {
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
        title: Text(S.current.free_quest_calculator),
        actions: [ChaldeaUrl.docsHelpBtn('free_calculator')],
        bottom: FixedHeight.tabBar(
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: [
              Tab(text: S.current.demands),
              Tab(text: S.current.plan),
              Tab(text: S.current.efficiency),
              Tab(text: S.current.free_quest),
            ],
            onTap: (_) {
              FocusScope.of(context).unfocus();
            },
          ),
        ),
      ),
      body: InheritSelectionArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.translucent,
          child: TabBarView(
            controller: _tabController,
            children: [
              KeepAliveBuilder(
                builder: (context) => DropCalcInputTab(objectiveCounts: widget.objectiveCounts, onSolved: onSolved),
              ),
              KeepAliveBuilder(builder: (context) => QuestPlanTab(solution: solution)),
              KeepAliveBuilder(builder: (context) => QuestEfficiencyTab(solution: solution)),
              KeepAliveBuilder(
                builder: (context) {
                  return WarListPage(
                    wars: [
                      for (final war in db.gameData.wars.values)
                        if (war.isMainStory && war.spots.isNotEmpty ||
                            war.id == WarId.chaldeaGate ||
                            war.id == WarId.grandBoardWar)
                          war,
                    ],
                  );
                },
              ),
            ],
          ),
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
      AppAnalysis.instance.logEvent('free_calc');
      // if change tab index immediately, the second tab won't re-render
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (!mounted) return;
        if (solution!.destination > 0 && solution!.destination < 3) {
          _tabController.index = solution!.destination;
        } else {
          _tabController.index = 1;
        }
      });
    }
  }
}
