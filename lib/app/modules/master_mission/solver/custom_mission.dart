import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'input_tab.dart';
import 'scheme.dart';
import 'solution_tab.dart';

class CustomMissionPage extends StatefulWidget {
  final List<CustomMission> initMissions;
  final int? initWarId;

  CustomMissionPage({super.key, this.initMissions = const [], this.initWarId});

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
        title: Text(S.current.custom_mission),
        bottom: FixedHeight.tabBar(TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: S.current.mission),
            Tab(text: S.current.master_mission_solution),
            Tab(text: S.current.master_mission_related_quest)
          ],
        )),
        actions: [
          SharedBuilder.docsHelpBtn('master_mission.html'),
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
