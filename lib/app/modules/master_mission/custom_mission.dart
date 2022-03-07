import 'package:flutter/material.dart';

/// mission.detail:
///   case DetailCondType.defeatEnemyIndividuality:
///   case DetailCondType.enemyIndividualityKillNum:
///     enemies with all these traits

enum MissionTargetType {
  trait,
  quest,
  servant,
  servantClass,
  enemyClass,
  enemyNotServantClass
}

class MissionTarget {
  MissionTargetType type;
  int num;
  List<int> ids;
  MissionTarget({required this.type, required this.num, required this.ids});
}

class CustomMissionPage extends StatefulWidget {
  final List<MissionTarget> missions;
  final int? warId;
  CustomMissionPage({Key? key, this.missions = const [], this.warId})
      : super(key: key);

  @override
  State<CustomMissionPage> createState() => _CustomMissionPageState();
}

class _CustomMissionPageState extends State<CustomMissionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Missions')),
    );
  }
}
