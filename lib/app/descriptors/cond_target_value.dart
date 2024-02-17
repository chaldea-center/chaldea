import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:chaldea/app/descriptors/cond_target_num.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'descriptor_base.dart';
import 'multi_entry.dart';

class CondTargetValueDescriptor extends StatelessWidget with DescriptorBase {
  final CondType condType;
  final int target;
  final int value;
  final String? forceFalseDescription;
  @override
  List<int> get targetIds => [target];
  @override
  final bool? useAnd;
  @override
  final TextStyle? style;
  @override
  final double? textScaleFactor;
  @override
  final InlineSpan? leading;
  final List<EventMission> missions;
  @override
  final String? unknownMsg;
  @override
  final EdgeInsetsGeometry? padding;

  const CondTargetValueDescriptor({
    super.key,
    required this.condType,
    required this.target,
    required this.value,
    this.forceFalseDescription,
    this.style,
    this.textScaleFactor,
    this.leading,
    this.missions = const [],
    this.useAnd,
    this.unknownMsg,
    this.padding,
  });
  CondTargetValueDescriptor.commonRelease({
    super.key,
    required CommonRelease commonRelease,
    this.forceFalseDescription,
    this.style,
    this.textScaleFactor,
    this.leading,
    this.missions = const [],
    this.useAnd,
    this.unknownMsg,
    this.padding,
  })  : condType = commonRelease.condType,
        target = commonRelease.condId,
        value = commonRelease.condNum;

  @override
  List<InlineSpan> buildContent(BuildContext context) {
    switch (condType) {
      case CondType.none:
        return localized(
          jp: null,
          cn: null,
          tw: () => text('NONE'),
          na: () => text('NONE'),
          kr: null,
        );
      case CondType.questClear:
        return localized(
          jp: () => rich(context, null, quests(context), 'をクリアした'),
          cn: () => rich(context, '通关', quests(context)),
          tw: () => rich(context, '通關', quests(context)),
          na: () => rich(context, 'Has cleared quest ', quests(context)),
          kr: null,
        );
      case CondType.questClearBeforeEventStart:
        return localized(
          jp: null,
          cn: () => rich(context, '在活动', MultiDescriptor.events(context, [value]), '开始前通关', quests(context)),
          tw: () => rich(context, '在活動', MultiDescriptor.events(context, [value]), '開始前通關', quests(context)),
          na: () =>
              rich(context, 'Clear ', quests(context), ' before event start', MultiDescriptor.events(context, [value])),
          kr: null,
        );
      case CondType.notQuestClearBeforeEventStart:
        return localized(
          jp: null,
          cn: () => rich(context, '在活动', MultiDescriptor.events(context, [value]), '开始前未通关', quests(context)),
          tw: () => rich(context, '在活動', MultiDescriptor.events(context, [value]), '開始前未通關', quests(context)),
          na: () => rich(context, 'Have not cleared ', quests(context), ' before event start',
              MultiDescriptor.events(context, [value])),
          kr: null,
        );
      case CondType.questAvailable:
        return localized(
          jp: null,
          cn: () => rich(context, '关卡可用中', quests(context)),
          tw: () => rich(context, '關卡可用中', quests(context)),
          na: () => rich(context, 'Quest', quests(context), "available"),
          kr: null,
        );
      case CondType.svtLimit:
        return localized(
          jp: () => rich(context, null, servants(context), 'の霊基再臨を$value段階目にする'),
          cn: () => rich(context, null, servants(context), '达到灵基再临第$value阶段'),
          tw: () => rich(context, null, servants(context), '達到靈基再臨第$value階段'),
          na: () => rich(context, null, servants(context), ' at ascension $value'),
          kr: null,
        );
      case CondType.svtGet:
        return localized(
          jp: () => rich(context, null, servants(context), 'は霊基一覧の中にいる'),
          cn: () => rich(context, null, servants(context), '在灵基一览中'),
          tw: () => rich(context, null, servants(context), '在靈基一覽中'),
          na: () => rich(context, null, servants(context), ' in Spirit Origin Collection'),
          kr: null,
        );
      case CondType.svtFriendship:
        return localized(
          jp: () => rich(context, null, servants(context), 'の絆レベルが$valueになる'),
          cn: () => rich(context, null, servants(context), '的羁绊等级达到$value'),
          tw: () => rich(context, null, servants(context), '的羈絆等級達到$value'),
          na: () => rich(context, null, servants(context), ' at bond level $value'),
          kr: null,
        );
      case CondType.svtFriendshipBelow:
        return localized(
          jp: () => rich(context, null, servants(context), 'の絆レベルは$value以下'),
          cn: () => rich(context, null, servants(context), '的羁绊等级为$value或以下'),
          tw: () => rich(context, null, servants(context), '的羈絆等級為$value或以下'),
          na: () => rich(context, null, servants(context), ' at bond level $value or lower'),
          kr: null,
        );
      case CondType.svtFriendshipAbove:
        return localized(
          jp: () => rich(context, null, servants(context), 'の絆レベルは$value以上'),
          cn: () => rich(context, null, servants(context), '的羁绊等级为$value或以上'),
          tw: () => rich(context, null, servants(context), '的羈絆等級為$value或以上'),
          na: () => rich(context, null, servants(context), ' at bond level $value'),
          kr: null,
        );
      case CondType.eventEnd:
        return localized(
          jp: () => rich(context, 'イベント', events(context), 'は終了した'),
          cn: () => rich(context, '活动', events(context), '结束'),
          tw: () => rich(context, '活動', events(context), '結束'),
          na: () => rich(context, 'Event ', events(context), ' has ended'),
          kr: null,
        );
      case CondType.questNotClear:
        return localized(
          jp: () => rich(context, null, quests(context), 'をクリアされていません'),
          cn: () => rich(context, '未通关', quests(context)),
          tw: () => rich(context, '未通關', quests(context)),
          na: () => rich(context, 'Has not cleared quest ', quests(context)),
          kr: null,
        );
      case CondType.svtHaving:
        return localized(
          jp: () => rich(context, 'サーヴァント', servants(context), 'を持っている'),
          cn: () => rich(context, '持有从者', servants(context)),
          tw: () => rich(context, '持有從者', servants(context)),
          na: () => rich(context, 'Presence of Servant ', servants(context)),
          kr: null,
        );
      case CondType.questClearPhase:
        return localized(
          jp: () => rich(context, null, quests(context), '進行度$valueをクリアした'),
          cn: () => rich(context, '已通关', quests(context), '进度$value'),
          tw: () => rich(context, '已通關', quests(context), '進度$value'),
          na: () => rich(context, 'Has cleared arrow $value of quest', quests(context)),
          kr: null,
        );
      case CondType.notQuestClearPhase:
        return localized(
          jp: () => rich(context, null, quests(context), '進行度$valueをクリアしていません'),
          cn: () => rich(context, '未通关', quests(context), '进度$value'),
          tw: () => rich(context, '未通關', quests(context), '進度$value'),
          na: () => rich(context, 'Has not cleared arrow $value of quest', quests(context)),
          kr: null,
        );
      case CondType.questGroupClear:
        final questIds = db.gameData.others.getQuestsOfGroup(QuestGroupType.questRelease, target);
        final questSpans = MultiDescriptor.quests(context, questIds, useAnd: useAnd);
        return localized(
          jp: () => rich(context, 'クエストを$value種クリア', questSpans),
          cn: () => rich(context, '通关$value个关卡', questSpans),
          tw: () => rich(context, '通關$value個關卡', questSpans),
          na: () => rich(context, 'Clear $value quests of ', questSpans),
          kr: null,
        );
      case CondType.notQuestGroupClear:
        final questIds = db.gameData.others.getQuestsOfGroup(QuestGroupType.questRelease, target);
        final questSpans = MultiDescriptor.quests(context, questIds, useAnd: useAnd);
        return localized(
          jp: null,
          cn: () => rich(context, '(?)未通关$value个关卡', questSpans),
          tw: () => rich(context, '(?)未通關$value個關卡', questSpans),
          na: () => rich(context, '(?)Have not cleared $value quests of ', questSpans),
          kr: null,
        );
      case CondType.questResetAvailable:
        return localized(
          jp: null,
          cn: () => rich(context, '关卡可重置', quests(context)),
          tw: null,
          na: () => rich(context, 'Quest reset available', quests(context)),
          kr: null,
        );
      case CondType.svtRecoverd:
        return localized(
          jp: null,
          cn: null,
          tw: () => text('從者已回復'),
          na: () => text('Servant Recovered'),
          kr: null,
        );
      case CondType.eventRewardDispCount:
        return localized(
          jp: () => rich(context, null, events(context), ' のイベントボイス、および少なくとも${value - 1}の他のボイスが再生されました'),
          cn: () => rich(context, null, events(context), ' 活动语音，且至少${value - 1}条其他语音已播放过'),
          tw: () => rich(context, null, events(context), ' 活動語音，且至少${value - 1}條其他語音已播放過'),
          na: () => rich(context, 'Event ', events(context),
              ' reward voice line and at least ${value - 1} other reward lines played before this one'),
          kr: null,
        );
      case CondType.playerGenderType:
        bool isMale = target == 1;
        return localized(
          jp: () => text('使用${isMale ? "男性" : "女性"}主人公'),
          cn: () => text('使用${isMale ? "男性" : "女性"}主人公'),
          tw: () => text('使用${isMale ? "男性" : "女性"}主人公'),
          na: () => text('Using ${isMale ? "male" : "female"} protagonist'),
          kr: null,
        );
      case CondType.forceFalse:
        final desc = forceFalseDescription == null ? '' : ' ($forceFalseDescription)';
        return localized(
          jp: () => text('不可能です$desc'),
          cn: () => text('不可能$desc'),
          tw: () => text('不可能$desc'),
          na: () => text('Not Possible$desc'),
          kr: null,
        );
      case CondType.limitCountAbove:
        return localized(
          jp: () => rich(context, null, servants(context), 'の霊基再臨を ≥ $value段階目にする'),
          cn: () => rich(context, '从者', servants(context), '的灵基再临 ≥ $value'),
          tw: () => rich(context, '從者', servants(context), '的靈基再臨 ≥ $value'),
          na: () => rich(context, 'Servant', servants(context), ' at ascension ≥ $value'),
          kr: null,
        );
      case CondType.limitCountBelow:
        return localized(
          jp: () => rich(context, null, servants(context), 'の霊基再臨を ≤ $value段階目にする'),
          cn: () => rich(context, '从者', servants(context), '的灵基再临 ≤ $value'),
          tw: () => rich(context, '從者', servants(context), '的靈基再臨 ≤ $value'),
          na: () => rich(context, 'Servant', servants(context), ' at ascension ≤ $value'),
          kr: null,
        );
      case CondType.date:
        // if (value == 0) return [];
        final time = DateTime.fromMillisecondsSinceEpoch(value * 1000).toStringShort(omitSec: true);
        return localized(
          jp: () => text('$time以降に開放'),
          cn: () => text('$time后开放'),
          tw: () => text('$time後開放'),
          na: () => text('After $time'),
          kr: null,
        );
      case CondType.itemGet:
        return localized(
          jp: () => rich(context, 'アイテム', items(context), '×$valueを持っている'),
          cn: () => rich(context, '拥有', items(context), '×$value'),
          tw: () => rich(context, '持有', items(context), '×$value'),
          na: () => rich(context, 'Has ', items(context), '×$value'),
          kr: null,
        );
      case CondType.notItemGet:
        return localized(
          jp: () => rich(context, 'アイテム', items(context), '×$valueを持っていません'),
          cn: () => rich(context, '未拥有', items(context), '×$value'),
          tw: () => rich(context, '未持有', items(context), '×$value'),
          na: () => rich(context, "Doesn't have ", items(context), '×$value'),
          kr: null,
        );
      case CondType.eventTotalPoint:
      case CondType.eventPoint:
        // target=event id
        return localized(
          jp: () => text('イベントポイントを$value点獲得'),
          cn: () => text('活动点数达到$value点'),
          tw: () => text('活動點數達到$value點'),
          na: () => text('Reach $value event points'),
          kr: null,
        );
      case CondType.eventGroupPoint:
      case CondType.eventNormaPointClear:
        final group = db.gameData.others.eventPointGroups[target];
        final groupName = group?.lName.l ?? target.toString();
        return localized(
          jp: () => text('イベントポイント$groupNameを$value点獲得'),
          cn: () => text('活动点数$groupName达到$value点'),
          tw: () => text('活動點數$groupName達到$value點'),
          na: () => text('Reach $value event points for $groupName'),
          kr: null,
        );
      case CondType.eventFortificationRewardNum:
        return localized(
          jp: () => text('梁山泊の活動報酬を$value回達成'),
          cn: () => text('梁山泊活动奖励达成$value次'),
          tw: null,
          na: () => text('Achieve Fortification rewards $value times'),
          kr: null,
        );
      case CondType.exchangeSvt:
        return localized(
          jp: () => rich(context, '交換したサーヴァント', events(context)),
          cn: () => rich(context, '兑换的从者', events(context)),
          tw: null,
          na: () => rich(context, "Exchanged Servant", events(context)),
          kr: null,
        );
      case CondType.commonRelease:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => rich(context, 'Common Release', MultiDescriptor.commonRelease(context, [target])),
          kr: null,
        );
      case CondType.weekdays:
        List<String> weekdays = [];
        target;
        for (int day = 1; day <= 7; day++) {
          if (target & (1 << (day % 7 + 1)) != 0) {
            weekdays.add(DateFormat('EEEE').format(DateTime(2000, 1, 2 + day)));
          }
        }
        if (weekdays.isEmpty) break;
        return [TextSpan(text: weekdays.join(' / '))];
      case CondType.notEventMissionAchieve:
        var missionMap = {for (final m in missions) m.id: m};
        return localized(
          jp: () => rich(context, 'ミッションを達成しない(報酬を受け取り): ', missionList(context, missionMap)),
          cn: () => rich(context, '未达成任务(领取奖励): ', missionList(context, missionMap)),
          tw: () => rich(context, '未達成任務(領取獎勵): ', missionList(context, missionMap)),
          na: () => rich(context, 'Have not achieved mission (claim rewards): ', missionList(context, missionMap)),
          kr: null,
        );
      // redirect to CondTargetNum
      case CondType.costumeGet:
      case CondType.notCostumeGet:
      case CondType.purchaseShop:
      case CondType.notShopPurchase:
        return CondTargetNumDescriptor(
          condType: condType,
          targetNum: value,
          targetIds: [target],
          unknownMsg: unknownMsg,
        ).buildContent(context);
      case CondType.eventMissionClear:
      case CondType.eventMissionAchieve:
        return CondTargetNumDescriptor(
          condType: condType,
          targetNum: 1,
          targetIds: [target],
          missions: missions,
          unknownMsg: unknownMsg,
        ).buildContent(context);
      case CondType.commonValueAbove:
      case CondType.commonValueBelow:
      case CondType.commonValueEqual:
        // UserGameCommonEntity
        final arrow = {
          CondType.commonValueAbove: "≥",
          CondType.commonValueBelow: "≤",
          CondType.commonValueEqual: "=",
        }[condType]!;
        String? closedMessage = unknownMsg?.replaceAll("\n", "");
        return rich(
          context,
          "CommonValue$target $arrow$value",
          [
            if (closedMessage != null && closedMessage.isNotEmpty)
              TextSpan(text: ' ($closedMessage)', style: Theme.of(context).textTheme.bodySmall),
          ],
        );
      default:
        break;
    }
    return wrapMsg(localized(
      jp: () => text('不明な条件(${condType.name}): $value, $target'),
      cn: () => text('未知条件(${condType.name}): $value, $target'),
      tw: () => text('未知條件(${condType.name}): $value, $target'),
      na: () => text('Unknown Cond(${condType.name}): $value, $target'),
      kr: null,
    ));
  }
}
