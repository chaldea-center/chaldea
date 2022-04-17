import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
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
    switch (detail.missionCondType) {
      case DetailCondType.questClearIndividuality:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            'Clear $targetNum quests with fields ',
            MultiDescriptor.traits(context, targetIds),
          ),
          kr: null,
        );
      case DetailCondType.questClearNum1:
      case DetailCondType.questClearNum2:
        if (targetIds.length == 1 && targetIds.first == 0) {
          return localized(
            jp: null,
            cn: null,
            tw: null,
            na: () => Text('Complete any quest $targetNum times'),
            kr: null,
          );
        } else {
          return localized(
            jp: null,
            cn: null,
            tw: null,
            na: () => combineToRich(
              context,
              '$targetNum runs of quests ',
              MultiDescriptor.quests(context, targetIds),
            ),
            kr: null,
          );
        }
      case DetailCondType.questClearNumIncludingGrailFront:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => Text(
              'Clear any quest including grail front quest $targetNum times'),
          kr: null,
        );
      case DetailCondType.mainQuestDone:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () =>
              Text('Clear any main quest in Arc 1 and Arc 2 $targetNum times'),
          kr: null,
        );
      case DetailCondType.enemyKillNum:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            'Defeat $targetNum from enemies ',
            MultiDescriptor.servants(context, targetIds),
          ),
          kr: null,
        );
      case DetailCondType.defeatEnemyIndividuality:
      case DetailCondType.enemyIndividualityKillNum:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            'Defeat $targetNum enemies with traits ',
            MultiDescriptor.traits(context, targetIds),
          ),
          kr: null,
        );
      case DetailCondType.defeatServantClass:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            'Defeat $targetNum servants with class ',
            MultiDescriptor.svtClass(context, targetIds),
          ),
          kr: null,
        );
      case DetailCondType.defeatEnemyClass:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            'Defeat $targetNum enemies with class ',
            MultiDescriptor.svtClass(context, targetIds),
          ),
          kr: null,
        );
      case DetailCondType.defeatEnemyNotServantClass:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            'Defeat $targetNum enemies with class ',
            MultiDescriptor.svtClass(context, targetIds),
            ' (excluding Servants and certain bosses)',
          ),
          kr: null,
        );
      case DetailCondType.battleSvtClassInDeck:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => Text(
              'Put one or more servants with class $targetIds  in your Party and complete any quest $targetNum times'),
          kr: null,
        );
      case DetailCondType.itemGetBattle:
      case DetailCondType.itemGetTotal:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            'Obtain $targetNum ',
            MultiDescriptor.items(context, targetIds),
            ' as battle drop',
          ),
          kr: null,
        );
      case DetailCondType.battleSvtIndividualityInDeck:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            'Put servants with traits',
            MultiDescriptor.traits(context, targetIds),
            ' in your Party and complete Quests $targetNum times',
          ),
          kr: null,
        );
      case DetailCondType.battleSvtIdInDeck1:
      case DetailCondType.battleSvtIdInDeck2:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => Text(
              'Put servants $targetIds in your Party and complete Quests $targetNum times'),
          kr: null,
        );
      case DetailCondType.svtGetBattle:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => Text('Acquire $targetNum embers through battle'),
          kr: null,
        );
      case DetailCondType.friendPointSummon:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => Text('Perform $targetNum Friend Point Summons'),
          kr: null,
        );
    }
    return localized(
      jp: null,
      cn: null,
      tw: null,
      na: () => Text('Unknown CondDetail: ${detail.missionCondType}'),
      kr: null,
    );
  }
}
