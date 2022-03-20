import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'input_tab.dart';
import 'scheme.dart';

class CustomMissionPage extends StatelessWidget {
  final List<CustomMission> missions;
  final int? warId;

  CustomMissionPage({Key? key, this.missions = const [], this.warId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Missions'),
          bottom: const TabBar(
            tabs: [
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
        body: TabBarView(children: [
          KeepAliveBuilder(
              builder: (context) => MissionInputTab(missions: missions)),
          const SizedBox(),
          const SizedBox(),
        ]),
      ),
    );
  }

  void _onSolved() {
    //
  }
}
