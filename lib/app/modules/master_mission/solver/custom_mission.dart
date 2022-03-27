import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'input_tab.dart';
import 'scheme.dart';
import 'solution_tab.dart';

class CustomMissionPage extends StatefulWidget {
  final List<CustomMission> initMissions;
  final int? initWarId;

  CustomMissionPage({Key? key, this.initMissions = const [], this.initWarId})
      : super(key: key);

  @override
  State<CustomMissionPage> createState() => _CustomMissionPageState();
}

class _CustomMissionPageState extends State<CustomMissionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MissionSolution? solution;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Custom Missions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Missions'),
            Tab(text: 'Solution'),
            Tab(text: 'Quests')
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                SimpleCancelOkDialog(
                  title: Text(S.current.master_mission),
                  content: const Text(
                    'For Main Story Free: only include extra one daily quest(door/QP, 10AP)',
                  ),
                ).showDialog(context);
              },
              icon: const Icon(Icons.help_outline),
              tooltip: S.current.help)
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveBuilder(
            builder: (context) => MissionInputTab(
              initMissions: widget.initMissions,
              initWarId: widget.initWarId,
              onSolved: _onSolved,
            ),
          ),
          KeepAliveBuilder(
              builder: (context) => MissionSolutionTab(solution: solution)),
          KeepAliveBuilder(
            builder: (context) => MissionSolutionTab(
              solution: solution,
              showResult: false,
            ),
          ),
        ],
      ),
    );
  }

  void _onSolved(MissionSolution s) {
    if (mounted) {
      setState(() {
        solution = s;
      });
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _tabController.index = 1;
      });
    }
  }
}
