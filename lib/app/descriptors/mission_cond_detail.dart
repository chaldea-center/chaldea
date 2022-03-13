import 'package:chaldea/models/models.dart';
import 'package:flutter/material.dart';

import 'descriptor_base.dart';
import 'multi_entry.dart';

class MissionCondDetailDescriptor extends StatelessWidget with DescriptorBase {
  final int targetNum;
  final EventMissionConditionDetail detail;

  const MissionCondDetailDescriptor(
      {Key? key, required this.targetNum, required this.detail})
      : super(key: key);

  List<int> get targetIds => detail.targetIds;

  @override
  Widget build(BuildContext context) {
    return MappingBase<WidgetBuilder>(
      // jp: buildJP,
      // cn: buildCN,
      // tw: buildTW,
      na: buildNA,
      // kr: buildKR,
    ).l!(context);
  }

  @override
  Widget buildCN(BuildContext context) {
    // TODO: implement buildCN
    throw UnimplementedError();
  }

  @override
  Widget buildJP(BuildContext context) {
    // TODO: implement buildJP
    throw UnimplementedError();
  }

  @override
  Widget buildKR(BuildContext context) {
    // TODO: implement buildKR
    throw UnimplementedError();
  }

  @override
  Widget buildNA(BuildContext context) {
    switch (detail.missionCondType) {
      case DetailCondType.questClearNum1:
      case DetailCondType.questClearNum2:
        if (targetIds.length == 1 && targetIds.first == 0) {
          return Text('Complete any quest $targetNum times');
        } else {
          return combineToRich(
            context,
            '$targetNum runs of quests ',
            MultiDescriptor.quests(context, targetIds),
          );
        }
      case DetailCondType.questClearNumIncludingGrailFront:
        return Text(
            'Clear any quest including grail front quest $targetNum times');
      case DetailCondType.mainQuestDone:
        return Text('Clear any main quest in Arc 1 and Arc 2 $targetNum times');
      case DetailCondType.enemyKillNum:
        return combineToRich(
          context,
          'Defeat $targetNum from enemies ',
          MultiDescriptor.servants(context, targetIds),
        );
      case DetailCondType.defeatEnemyIndividuality:
      case DetailCondType.enemyIndividualityKillNum:
        return combineToRich(
          context,
          'Defeat $targetNum enemies with traits ',
          MultiDescriptor.traits(context, targetIds),
        );
      case DetailCondType.defeatServantClass:
        return Text('Defeat $targetNum servants with class $targetIds');
      case DetailCondType.defeatEnemyClass:
        return Text('Defeat $targetNum enemies with class $targetIds');
      case DetailCondType.defeatEnemyNotServantClass:
        return Text(
            'Defeat $targetNum servants with class $targetIds  (excluding Servants and certain bosses)');
      case DetailCondType.battleSvtClassInDeck:
        return Text(
            'Put one or more servants with class $targetIds  in your Party and complete any quest $targetNum times');
      case DetailCondType.itemGetBattle:
      case DetailCondType.itemGetTotal:
        return combineToRich(
          context,
          'Obtain $targetNum ',
          MultiDescriptor.items(context, targetIds),
          ' as battle drop',
        );
      case DetailCondType.battleSvtIndividualityInDeck:
        return combineToRich(
          context,
          'Put servants with traits',
          MultiDescriptor.traits(context, targetIds),
          ' in your Party and complete Quests $targetNum times',
        );
      case DetailCondType.battleSvtIdInDeck1:
      case DetailCondType.battleSvtIdInDeck2:
        return Text(
            'Put servants $targetIds in your Party and complete Quests $targetNum times');
      case DetailCondType.svtGetBattle:
        return Text('Acquire $targetNum embers through battle');
      case DetailCondType.friendPointSummon:
        return Text('Perform $targetNum Friend Point Summons');
    }
    return Text('Unknown CondDetail: ${detail.missionCondType}');
  }

  @override
  Widget buildTW(BuildContext context) {
    // TODO: implement buildTW
    throw UnimplementedError();
  }
}
