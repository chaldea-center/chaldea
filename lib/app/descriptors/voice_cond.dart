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
  final bool? useAnd;
  @override
  final TextStyle? style;
  @override
  final double? textScaleFactor;
  @override
  final InlineSpan? leading;
  @override
  final String? unknownMsg;
  @override
  final EdgeInsetsGeometry? padding;

  const VoiceCondDescriptor({
    super.key,
    required this.condType,
    required this.value,
    this.valueList = const [],
    this.style,
    this.textScaleFactor,
    this.leading,
    this.useAnd,
    this.unknownMsg,
    this.padding,
  });

  @override
  List<InlineSpan> buildContent(BuildContext context) {
    switch (condType) {
      case VoiceCondType.birthDay:
        return localized(
          jp: null,
          cn: () => text('生日'),
          tw: () => text('生日'),
          na: () => text('Player birthday'),
          kr: null,
        );
      case VoiceCondType.countStop:
        return localized(
          jp: null,
          cn: () => text('最终再临'),
          tw: () => text('最終再臨'),
          na: () => text('Final ascension'),
          kr: null,
        );
      case VoiceCondType.event:
        return localized(
          jp: null,
          cn: () => text('活动举行中'),
          tw: () => text('活動舉行中'),
          na: () => text('An event is available'),
          kr: null,
        );
      case VoiceCondType.eventPeriod:
        return localized(
          jp: null,
          cn: () => text('活动举行期间'),
          tw: () => text('活動舉行期間'),
          na: () => text('During event'),
          kr: null,
        );
      case VoiceCondType.eventEnd:
        return localized(
          jp: null,
          cn: () => text('活动已结束'),
          tw: () => text('活動已結束'),
          na: () => text('Event ended'),
          kr: null,
        );
      case VoiceCondType.eventNoend:
        return localized(
          jp: null,
          cn: () => text('活动未结束'),
          tw: () => text('活動未結束'),
          na: () => text('Event hasn\'t ended'),
          kr: null,
        );
      case VoiceCondType.eventShopPurchase:
        return localized(
          jp: null,
          cn: () => text('活动商店购买语音'),
          tw: () => text('活動商店購買語音'),
          na: () => text('Event shop purchase line'),
          kr: null,
        );
      case VoiceCondType.spacificShopPurchase:
        return localized(
          jp: null,
          cn: () => text('活动商店特殊购买语音'),
          tw: () => text('活動商店特殊購買語音'),
          na: () => text('Event specific shop purchase line'),
          kr: null,
        );

      case VoiceCondType.eventMissionAction:
        return localized(
          jp: null,
          cn: () => text('活动任务语音'),
          tw: () => text('活動任務語音'),
          na: () => text('Event mission line'),
          kr: null,
        );
      case VoiceCondType.friendship:
      case VoiceCondType.friendshipAbove:
        return localized(
          jp: null,
          cn: () => text('羁绊Lv.$value'),
          tw: () => text('羈絆Lv.$value'),
          na: () => text('Bond level $value'),
          kr: null,
        );
      case VoiceCondType.friendshipBelow:
        return localized(
          jp: null,
          cn: () => text('羁绊等级不高于Lv.$value'),
          tw: () => text('羈絆等級不高於Lv.$value'),
          na: () => text('Bond level $value or less'),
          kr: null,
        );
      case VoiceCondType.masterMission:
        return text('${S.current.master_mission} $value');
      case VoiceCondType.levelUp:
        return localized(jp: null, cn: null, tw: null, na: () => text('Level up'), kr: null);
      case VoiceCondType.limitCount:
        return text('${S.current.ascension} $value');
      case VoiceCondType.limitCountCommon:
        return text('${S.current.ascension} 2');
      case VoiceCondType.limitCountAbove:
        return text('${S.current.ascension} $value');
      case VoiceCondType.costume:
        return text('${S.current.costume} ${db.gameData.costumes[value]?.lName.l ?? value}');
      case VoiceCondType.isnewWar:
        final war = db.gameData.wars[value];
        final warName = war?.lLongName.l ?? value.toString();
        return localized(
          jp: null,
          cn: () => text('$warName已开放'),
          tw: () => text('$warName已開放'),
          na: () => text('War $warName opened'),
          kr: null,
        );
      case VoiceCondType.questClear:
        return localized(
          jp: null,
          cn: () => rich('已通关', quests(context)),
          tw: () => rich('已通關', quests(context)),
          na: () => rich('Cleared ', quests(context)),
          kr: null,
        );
      case VoiceCondType.notQuestClear:
        return localized(
          jp: null,
          cn: () => rich('未通关', quests(context)),
          tw: () => rich('未通關', quests(context)),
          na: () => rich('Hasn\'t cleared ', quests(context)),
          kr: null,
        );
      case VoiceCondType.svtGet:
        return localized(
          jp: null,
          cn: () => rich('持有', servants(context)),
          tw: () => rich('持有', servants(context)),
          na: () => rich('Presence of ', servants(context)),
          kr: null,
        );
      case VoiceCondType.svtGroup:
        return localized(
          jp: null,
          cn: () => rich('持有任意一个: ', MultiDescriptor.servants(context, valueList)),
          tw: () => rich('持有任意一個: ', MultiDescriptor.servants(context, valueList)),
          na: () => rich('Presence any of following: ', MultiDescriptor.servants(context, valueList)),
          kr: null,
        );
      default:
        break;
    }
    return wrapMsg(
      localized(
        jp: null,
        cn: () => text('未知条件(${condType.name}): $value'),
        tw: () => text('未知條件(${condType.name}): $value'),
        na: () => text('Unknown Cond(${condType.name}): $value'),
        kr: null,
      ),
    );
  }
}
