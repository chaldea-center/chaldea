import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'descriptor_base.dart';

class CondTargetValueDescriptor extends StatelessWidget with DescriptorBase {
  final CondType condType;
  final int target;
  final int value;
  final String? forceFalseDescription;
  @override
  List<int> get targetIds => [target];
  @override
  final TextStyle? style;
  @override
  final double? textScaleFactor;

  const CondTargetValueDescriptor({
    Key? key,
    required this.condType,
    required this.target,
    required this.value,
    this.forceFalseDescription,
    this.style,
    this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (condType) {
      case CondType.none:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => text('NONE'),
          kr: null,
        );
      case CondType.questClear:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '通关', quests(context)),
          tw: null,
          na: () =>
              combineToRich(context, 'Has cleared quest ', quests(context)),
          kr: null,
        );
      case CondType.svtLimit:
        return localized(
          jp: null,
          cn: () => combineToRich(
              context, null, servants(context), '达到灵基再临第$value阶段'),
          tw: null,
          na: () => combineToRich(
            context,
            null,
            servants(context),
            ' at ascension $value',
          ),
          kr: null,
        );
      case CondType.svtGet:
        return localized(
          jp: null,
          cn: () => combineToRich(context, null, servants(context), '在灵基一览中'),
          tw: null,
          na: () => combineToRich(
            context,
            null,
            servants(context),
            ' in Spirit Origin Collection',
          ),
          kr: null,
        );
      case CondType.svtFriendship:
        return localized(
          jp: null,
          cn: () =>
              combineToRich(context, null, servants(context), '的羁绊等级为$value'),
          tw: null,
          na: () => combineToRich(
            context,
            null,
            servants(context),
            ' at bond level $value',
          ),
          kr: null,
        );
      case CondType.svtFriendshipBelow:
        return localized(
          jp: null,
          cn: () => combineToRich(
              context, null, servants(context), '的羁绊等级为$value或以下'),
          tw: null,
          na: () => combineToRich(
            context,
            null,
            servants(context),
            ' at bond level $value or lower',
          ),
          kr: null,
        );
      case CondType.svtFriendshipAbove:
        return localized(
          jp: null,
          cn: () => combineToRich(
              context, null, servants(context), '的羁绊等级为$value或以上'),
          tw: null,
          na: () => combineToRich(
            context,
            null,
            servants(context),
            ' at bond level $value',
          ),
          kr: null,
        );
      case CondType.costumeGet:
        final costume = db.gameData.servantsById[target]?.profile.costume.values
            .firstWhereOrNull((c) => c.id == value);
        final costumeName = costume?.lName.l.replaceAll('\n', ' ');
        return localized(
          jp: null,
          cn: () => text('获得灵衣 $costumeName'),
          tw: null,
          na: () => text('Costume $costumeName get'),
          kr: null,
        );
      case CondType.eventEnd:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '活动', event(context), '结束'),
          tw: null,
          na: () =>
              combineToRich(context, 'Event ', event(context), ' has ended'),
          kr: null,
        );
      case CondType.questNotClear:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '未通关', quests(context)),
          tw: null,
          na: () =>
              combineToRich(context, 'Has not cleared quest ', quests(context)),
          kr: null,
        );
      case CondType.svtHaving:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '持有从者', servants(context)),
          tw: null,
          na: () =>
              combineToRich(context, 'Presence of Servant ', servants(context)),
          kr: null,
        );
      case CondType.questClearPhase:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '已通关', quests(context), '进度$value'),
          tw: null,
          na: () => combineToRich(
              context, 'Has cleared arrow $value of quest', quests(context)),
          kr: null,
        );
      case CondType.notQuestClearPhase:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '未通关', quests(context), '进度$value'),
          tw: null,
          na: () => combineToRich(context,
              'Has not cleared arrow $value of quest', quests(context)),
          kr: null,
        );
      case CondType.svtRecoverd:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => text('Servant Recovered'),
          kr: null,
        );
      case CondType.eventRewardDispCount:
        return localized(
          jp: null,
          cn: () => combineToRich(
              context, null, event(context), ' 活动语音，且至少${value - 1}条其他语音已播放过'),
          tw: null,
          na: () => combineToRich(context, 'Event ', event(context),
              ' reward voice line and at least ${value - 1} other reward lines played before this one'),
          kr: null,
        );
      case CondType.playerGenderType:
        bool isMale = target == 1;
        return localized(
          jp: null,
          cn: () => text('使用${isMale ? "男性" : "女性"}主人公'),
          tw: null,
          na: () => text('Using ${isMale ? "male" : "female"} protagonist'),
          kr: null,
        );
      case CondType.forceFalse:
        final desc =
            forceFalseDescription == null ? '' : ' ($forceFalseDescription)';
        return localized(
          jp: null,
          cn: () => text('不可能$desc'),
          tw: null,
          na: () => text('Not Possible$desc'),
          kr: null,
        );
      case CondType.limitCountAbove:
        return localized(
          jp: null,
          cn: () =>
              combineToRich(context, '从者', servants(context), '的灵基再临 ≥ $value'),
          tw: null,
          na: () => combineToRich(
            context,
            'Servant',
            servants(context),
            ' at ascension ≥ $value',
          ),
          kr: null,
        );
      case CondType.limitCountBelow:
        return localized(
          jp: null,
          cn: () =>
              combineToRich(context, '从者', servants(context), '的灵基再临 ≤ $value'),
          tw: null,
          na: () => combineToRich(
            context,
            'Servant',
            servants(context),
            ' at ascension ≤ $value',
          ),
          kr: null,
        );
      case CondType.date:
        if (value == 0) return const SizedBox();
        final time = DateTime.fromMillisecondsSinceEpoch(value * 1000)
            .toStringShort(omitSec: true);
        return localized(
          jp: null,
          cn: () => text('$time后开放'),
          tw: null,
          na: () => text('After $time'),
          kr: null,
        );
      case CondType.itemGet:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '拥有', items(context), '×$value'),
          tw: null,
          na: () => combineToRich(context, 'Has ', items(context), '×$value'),
          kr: null,
        );
      case CondType.notItemGet:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '未拥有', items(context), '×$value'),
          tw: null,
          na: () => combineToRich(
              context, "Doesn't have ", items(context), '×$value'),
          kr: null,
        );
      case CondType.eventTotalPoint:
        // target=event id
        return localized(
          jp: null,
          cn: () => text('获得活动点数$value点'),
          tw: null,
          na: () => text('Reach $value event points'),
          kr: null,
        );
      default:
        break;
    }
    return localized(
      jp: null,
      cn: () => text('未知条件(${condType.name}): $value, 目标$target'),
      tw: null,
      na: () => text('Unknown Cond(${condType.name}): $value, target $target'),
      kr: null,
    );
  }
}
