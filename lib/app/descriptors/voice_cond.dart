import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'descriptor_base.dart';
import 'multi_entry.dart';

class VoiceCondDescriptor extends StatelessWidget with DescriptorBase {
  final VoiceCondType condType;
  final int value;
  final List<int> valueList;
  @override
  List<int> get targetIds => [value];
  @override
  final TextStyle? style;
  @override
  final double? textScaleFactor;
  @override
  final InlineSpan? leading;

  const VoiceCondDescriptor({
    Key? key,
    required this.condType,
    required this.value,
    this.valueList = const [],
    this.style,
    this.textScaleFactor,
    this.leading,
  }) : super(key: key);

  @override
  List<InlineSpan> buildContent(BuildContext context) {
    switch (condType) {
      case VoiceCondType.birthDay:
        return localized(
          jp: null,
          cn: () => text('生日'),
          tw: null,
          na: () => text('Player birthday'),
          kr: null,
        );
      case VoiceCondType.countStop:
        return localized(
          jp: null,
          cn: () => text('最终再临'),
          tw: null,
          na: () => text('Final ascension'),
          kr: null,
        );
      case VoiceCondType.event:
        return localized(
          jp: null,
          cn: () => text('活动举行中'),
          tw: null,
          na: () => text('An event is available'),
          kr: null,
        );
      case VoiceCondType.eventPeriod:
        return localized(
          jp: null,
          cn: () => text('活动举行期间'),
          tw: null,
          na: () => text('During event'),
          kr: null,
        );
      case VoiceCondType.eventEnd:
        return localized(
          jp: null,
          cn: () => text('活动已结束'),
          tw: null,
          na: () => text('Event ended'),
          kr: null,
        );
      case VoiceCondType.eventNoend:
        return localized(
          jp: null,
          cn: () => text('活动未结束'),
          tw: null,
          na: () => text('Event hasn\'t ended'),
          kr: null,
        );
      case VoiceCondType.eventShopPurchase:
        return localized(
          jp: null,
          cn: () => text('活动商店购买语音'),
          tw: null,
          na: () => text('Event shop purchase line'),
          kr: null,
        );
      case VoiceCondType.spacificShopPurchase:
        return localized(
          jp: null,
          cn: () => text('活动商店特殊购买语音'),
          tw: null,
          na: () => text('Event specific shop purchase line'),
          kr: null,
        );

      case VoiceCondType.eventMissionAction:
        return localized(
          jp: null,
          cn: () => text('活动任务语音'),
          tw: null,
          na: () => text('Event mission line'),
          kr: null,
        );
      case VoiceCondType.friendship:
      case VoiceCondType.friendshipAbove:
        return localized(
          jp: null,
          cn: () => text('羁绊Lv.$value'),
          tw: null,
          na: () => text('Bond level $value'),
          kr: null,
        );
      case VoiceCondType.friendshipBelow:
        return localized(
          jp: null,
          cn: () => text('羁绊等级不高于Lv.$value'),
          tw: null,
          na: () => text('Bond level $value or less'),
          kr: null,
        );
      case VoiceCondType.masterMission:
        return text('${S.current.master_mission} $value');
      case VoiceCondType.levelUp:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => text('Level up'),
          kr: null,
        );
      case VoiceCondType.limitCount:
        return text('${S.current.ascension} $value');
      case VoiceCondType.limitCountCommon:
        return text('${S.current.ascension} 2');
      case VoiceCondType.limitCountAbove:
        return text('${S.current.ascension} $value');
      case VoiceCondType.costume:
        return text(
            '${S.current.costume} ${db.gameData.costumes[value]?.lName.l ?? value}');
      case VoiceCondType.isnewWar:
        final war = db.gameData.wars[value];
        final warName = war?.lLongName.l ?? value.toString();
        return localized(
          jp: null,
          cn: () => text('$warName已开放'),
          tw: null,
          na: () => text('War $warName opened'),
          kr: null,
        );
      case VoiceCondType.questClear:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '已通关', quests(context)),
          tw: null,
          na: () => combineToRich(context, 'Cleared ', quests(context)),
          kr: null,
        );
      case VoiceCondType.notQuestClear:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '未通关', quests(context)),
          tw: null,
          na: () => combineToRich(context, 'Hasn\'t cleared ', quests(context)),
          kr: null,
        );
      case VoiceCondType.svtGet:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '持有', servants(context)),
          tw: null,
          na: () => combineToRich(context, 'Presence of ', servants(context)),
          kr: null,
        );
      case VoiceCondType.svtGroup:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '持有任意一个: ',
              MultiDescriptor.servants(context, valueList)),
          tw: null,
          na: () => combineToRich(context, 'Presence any of following: ',
              MultiDescriptor.servants(context, valueList)),
          kr: null,
        );
      default:
        break;
    }
    return localized(
      jp: null,
      cn: () => text('未知条件(${condType.name}): $value'),
      tw: null,
      na: () => text('Unknown Cond(${condType.name}): $value'),
      kr: null,
    );
  }
}
