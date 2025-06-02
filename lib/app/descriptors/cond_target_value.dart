import 'package:intl/intl.dart';

import 'package:chaldea/app/descriptors/cond_target_num.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
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
  }) : condType = commonRelease.condType,
       target = commonRelease.condId,
       value = commonRelease.condNum;

  @override
  List<InlineSpan> buildContent(BuildContext context) {
    switch (condType) {
      case CondType.none:
        return localized(jp: null, cn: null, tw: () => text('NONE'), na: () => text('NONE'), kr: null);
      case CondType.questClear:
        return localized(
          jp: () => rich(null, quests(context), 'をクリアした'),
          cn: () => rich('通关', quests(context)),
          tw: () => rich('通關', quests(context)),
          na: () => rich('Has cleared quest ', quests(context)),
          kr: null,
        );
      case CondType.questClearBeforeEventStart:
        return localized(
          jp: null,
          cn: () => rich('在活动', MultiDescriptor.events(context, [value]), '开始前通关', quests(context)),
          tw: () => rich('在活動', MultiDescriptor.events(context, [value]), '開始前通關', quests(context)),
          na: () => rich('Clear ', quests(context), ' before event start', MultiDescriptor.events(context, [value])),
          kr: null,
        );
      case CondType.beforeQuestClearTime:
        final time = DateTime.fromMillisecondsSinceEpoch(value * 1000).toStringShort(omitSec: true);
        return localized(
          jp: null,
          cn: () => rich('在$time前通关', quests(context)),
          tw: () => rich('在$time前通關', quests(context)),
          na: () => rich('Clear ', quests(context), ' before $time'),
          kr: null,
        );
      case CondType.afterQuestClearTime:
        final time = DateTime.fromMillisecondsSinceEpoch(value * 1000).toStringShort(omitSec: true);
        return localized(
          jp: null,
          cn: () => rich('在$time后通关', quests(context)),
          tw: () => rich('在$time後通關', quests(context)),
          na: () => rich('Clear ', quests(context), ' after $time'),
          kr: null,
        );
      case CondType.notQuestClearBeforeEventStart:
        return localized(
          jp: null,
          cn: () => rich('在活动', MultiDescriptor.events(context, [value]), '开始前未通关', quests(context)),
          tw: () => rich('在活動', MultiDescriptor.events(context, [value]), '開始前未通關', quests(context)),
          na: () => rich(
            'Have not cleared ',
            quests(context),
            ' before event start',
            MultiDescriptor.events(context, [value]),
          ),
          kr: null,
        );
      case CondType.questAvailable:
        return localized(
          jp: null,
          cn: () => rich('关卡可用中', quests(context)),
          tw: () => rich('關卡可用中', quests(context)),
          na: () => rich('Quest', quests(context), "available"),
          kr: null,
        );
      case CondType.svtLevel:
        return localized(
          jp: null,
          cn: () => rich('从者等级达到Lv.$value', servants(context)),
          tw: null,
          na: () => rich('Servant level reaches Lv.$value', quests(context), ""),
          kr: null,
        );
      case CondType.svtLimit:
        return localized(
          jp: () => rich(null, servants(context), 'の霊基再臨を$value段階目にする'),
          cn: () => rich(null, servants(context), '达到灵基再临第$value阶段'),
          tw: () => rich(null, servants(context), '達到靈基再臨第$value階段'),
          na: () => rich(null, servants(context), ' at ascension $value'),
          kr: null,
        );
      case CondType.svtGet:
        return localized(
          jp: () => rich(null, servants(context), 'は霊基一覧の中にいる'),
          cn: () => rich(null, servants(context), '在灵基一览中'),
          tw: () => rich(null, servants(context), '在靈基一覽中'),
          na: () => rich(null, servants(context), ' in Spirit Origin Collection'),
          kr: null,
        );
      case CondType.svtFriendship:
        return localized(
          jp: () => rich(null, servants(context), 'の絆レベルが$valueになる'),
          cn: () => rich(null, servants(context), '的羁绊等级达到$value'),
          tw: () => rich(null, servants(context), '的羈絆等級達到$value'),
          na: () => rich(null, servants(context), ' at bond level $value'),
          kr: null,
        );
      case CondType.svtFriendshipBelow:
        return localized(
          jp: () => rich(null, servants(context), 'の絆レベルは$value以下'),
          cn: () => rich(null, servants(context), '的羁绊等级为$value或以下'),
          tw: () => rich(null, servants(context), '的羈絆等級為$value或以下'),
          na: () => rich(null, servants(context), ' at bond level $value or lower'),
          kr: null,
        );
      case CondType.svtFriendshipAbove:
        return localized(
          jp: () => rich(null, servants(context), 'の絆レベルは$value以上'),
          cn: () => rich(null, servants(context), '的羁绊等级为$value或以上'),
          tw: () => rich(null, servants(context), '的羈絆等級為$value或以上'),
          na: () => rich(null, servants(context), ' at bond level $value'),
          kr: null,
        );
      case CondType.eventEnd:
        return localized(
          jp: () => rich('イベント', events(context), 'は終了した'),
          cn: () => rich('活动', events(context), '结束'),
          tw: () => rich('活動', events(context), '結束'),
          na: () => rich('Event ', events(context), ' has ended'),
          kr: null,
        );
      case CondType.questNotClear:
        return localized(
          jp: () => rich(null, quests(context), 'をクリアされていません'),
          cn: () => rich('未通关', quests(context)),
          tw: () => rich('未通關', quests(context)),
          na: () => rich('Has not cleared quest ', quests(context)),
          kr: null,
        );
      case CondType.svtHaving:
        return localized(
          jp: () => rich('サーヴァント', servants(context), 'を持っている'),
          cn: () => rich('持有从者', servants(context)),
          tw: () => rich('持有從者', servants(context)),
          na: () => rich('Presence of Servant ', servants(context)),
          kr: null,
        );
      case CondType.questClearPhase:
        return localized(
          jp: () => rich(null, quests(context), '進行度$valueをクリアした'),
          cn: () => rich('已通关', quests(context), '进度$value'),
          tw: () => rich('已通關', quests(context), '進度$value'),
          na: () => rich('Has cleared arrow $value of quest', quests(context)),
          kr: null,
        );
      case CondType.notQuestClearPhase:
        return localized(
          jp: () => rich(null, quests(context), '進行度$valueをクリアしていません'),
          cn: () => rich('未通关', quests(context), '进度$value'),
          tw: () => rich('未通關', quests(context), '進度$value'),
          na: () => rich('Has not cleared arrow $value of quest', quests(context)),
          kr: null,
        );
      case CondType.questGroupClear:
        final questIds = db.gameData.others.getQuestsOfGroup(QuestGroupType.questRelease, target);
        final questSpans = MultiDescriptor.quests(context, questIds, useAnd: useAnd);
        return localized(
          jp: () => rich('クエストを$value種クリア', questSpans),
          cn: () => rich('通关$value个关卡', questSpans),
          tw: () => rich('通關$value個關卡', questSpans),
          na: () => rich('Clear $value quests of ', questSpans),
          kr: null,
        );
      case CondType.notQuestGroupClear:
        final questIds = db.gameData.others.getQuestsOfGroup(QuestGroupType.questRelease, target);
        final questSpans = MultiDescriptor.quests(context, questIds, useAnd: useAnd);
        return localized(
          jp: null,
          cn: () => rich('(?)未通关$value个关卡', questSpans),
          tw: () => rich('(?)未通關$value個關卡', questSpans),
          na: () => rich('(?)Have not cleared $value quests of ', questSpans),
          kr: null,
        );
      case CondType.latestQuestPhaseEqual:
      case CondType.notLatestQuestPhaseEqual:
        final relation = {CondType.latestQuestPhaseEqual: '=', CondType.notLatestQuestPhaseEqual: '!='}[condType]!;
        return localized(
          jp: null,
          cn: () => rich(null, quests(context), '最新进度 $relation$value'),
          tw: null,
          na: () => rich(null, quests(context), 'latest quest arrow $relation$value'),
          kr: null,
        );
      case CondType.questChallengeNum:
      case CondType.questChallengeNumBelow:
      case CondType.questChallengeNumEqual:
        final relation = {
          CondType.questChallengeNum: '≥',
          CondType.questChallengeNumBelow: '<',
          CondType.questChallengeNumEqual: '=',
        }[condType]!;
        return localized(
          jp: null,
          cn: () => rich('关卡挑战次数$relation$value', quests(context)),
          tw: null,
          na: () => rich('Quest challenge num $relation$value', quests(context)),
          kr: null,
        );
      case CondType.playQuestPhase:
        return localized(
          jp: null,
          cn: () => rich('正在挑战关卡', quests(context), '进度$value'),
          tw: null,
          na: () => rich('Playing quest', quests(context), 'arrow $value'),
          kr: null,
        );
      case CondType.notPlayQuestPhase:
        return localized(
          jp: null,
          cn: () => rich('未在挑战关卡', quests(context), '进度$value'),
          tw: null,
          na: () => rich('Not playing quest', quests(context), 'arrow $value'),
          kr: null,
        );
      case CondType.questResetAvailable:
        return localized(
          jp: null,
          cn: () => rich('关卡可重置', quests(context)),
          tw: null,
          na: () => rich('Quest reset available', quests(context)),
          kr: null,
        );
      case CondType.elapsedTimeAfterQuestClear:
        final duration = (value / 3600).format();
        return localized(
          jp: null,
          cn: () => rich('关卡通关后经过$duration小时', quests(context)),
          tw: null,
          na: () => rich('Elapsed $duration hours after quest cleared', quests(context)),
          kr: null,
        );
      case CondType.svtRecoverd:
        return localized(jp: null, cn: null, tw: () => text('從者已回復'), na: () => text('Servant Recovered'), kr: null);
      case CondType.eventRewardDispCount:
        return localized(
          jp: () => rich(null, events(context), ' のイベントボイス、および少なくとも${value - 1}の他のボイスが再生されました'),
          cn: () => rich(null, events(context), ' 活动语音，且至少${value - 1}条其他语音已播放过'),
          tw: () => rich(null, events(context), ' 活動語音，且至少${value - 1}條其他語音已播放過'),
          na: () => rich(
            'Event ',
            events(context),
            ' reward voice line and at least ${value - 1} other reward lines played before this one',
          ),
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
          jp: () => rich(null, servants(context), 'の霊基再臨を ≥ $value段階目にする'),
          cn: () => rich(null, servants(context), '的灵基再临 ≥ $value'),
          tw: () => rich(null, servants(context), '的靈基再臨 ≥ $value'),
          na: () => rich(null, servants(context), ' at ascension ≥ $value'),
          kr: null,
        );
      case CondType.limitCountBelow:
        return localized(
          jp: () => rich(null, servants(context), 'の霊基再臨を ≤ $value段階目にする'),
          cn: () => rich(null, servants(context), '的灵基再临 ≤ $value'),
          tw: () => rich(null, servants(context), '的靈基再臨 ≤ $value'),
          na: () => rich(null, servants(context), ' at ascension ≤ $value'),
          kr: null,
        );
      case CondType.limitCountMaxAbove:
      case CondType.limitCountMaxBelow:
      case CondType.limitCountMaxEqual:
        final arrow = {
          CondType.limitCountMaxAbove: "≥",
          CondType.limitCountMaxBelow: "≤",
          CondType.limitCountMaxEqual: "=",
        }[condType]!;
        return localized(
          jp: () => rich(null, servants(context), '最大の霊基再臨を $arrow $value段階目にする'),
          cn: () => rich(null, servants(context), '的最高灵基再临 $arrow $value'),
          tw: () => rich(null, servants(context), '的最高靈基再臨 $arrow $value'),
          na: () => rich(null, servants(context), ' at max ascension $arrow $value'),
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
      case CondType.beforeSpecifiedDate:
        final time = DateTime.fromMillisecondsSinceEpoch(value * 1000).toStringShort(omitSec: true);
        return localized(
          jp: () => text('$time前に開放'),
          cn: () => text('$time前开放'),
          tw: () => text('$time前開放'),
          na: () => text('Before $time'),
          kr: null,
        );
      case CondType.itemGet:
        return localized(
          jp: () => rich('アイテム', items(context), '×$valueを持っている'),
          cn: () => rich('拥有', items(context), '×$value'),
          tw: () => rich('持有', items(context), '×$value'),
          na: () => rich('Has ', items(context), '×$value'),
          kr: null,
        );
      case CondType.notItemGet:
        return localized(
          jp: () => rich('アイテム', items(context), '×$valueを持っていません'),
          cn: () => rich('未拥有', items(context), '×$value'),
          tw: () => rich('未持有', items(context), '×$value'),
          na: () => rich("Doesn't have ", items(context), '×$value'),
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
        final group = db.gameData.others.getEventPointGroup(null, target);
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
          jp: () => rich('交換したサーヴァント', events(context)),
          cn: () => rich('兑换的从者', events(context)),
          tw: null,
          na: () => rich("Exchanged Servant", events(context)),
          kr: null,
        );
      case CondType.commonRelease:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => rich('Common Release', MultiDescriptor.commonRelease(context, [target])),
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
          jp: () => rich('ミッションを達成しない(報酬を受け取り): ', missionList(context, missionMap)),
          cn: () => rich('未达成任务(领取奖励): ', missionList(context, missionMap)),
          tw: () => rich('未達成任務(領取獎勵): ', missionList(context, missionMap)),
          na: () => rich('Have not achieved mission (claim rewards): ', missionList(context, missionMap)),
          kr: null,
        );
      case CondType.eventMissionGroupAchieve:
        final group = db.gameData.events.values.expand((e) => e.missionGroups).firstWhereOrNull((e) => e.id == target);
        if (group == null) break;
        final _missionList = MultiDescriptor.missions(context, group.missionIds, {}, useAnd: useAnd);
        return localized(
          jp: null,
          cn: () => rich('达成其中$value个任务(领取奖励): ', _missionList),
          tw: null,
          na: () => rich('Have achieved $value missions (claim rewards): ', _missionList),
          kr: null,
        );
      case CondType.equipWithTargetCostume:
        final costume = db.gameData.servantsById[target]?.profile.costume.values.firstWhereOrNull((e) => e.id == value);
        if (costume == null) {
          return localized(
            jp: null,
            cn: () => rich('从者', servants(context), '使用灵基$value'),
            tw: null,
            na: () => rich('Servant', servants(context), 'using Ascension $value'),
            kr: null,
          );
        } else {
          final costumeSpans = [
            CenterWidgetSpan(
              child: GameCardMixin.cardIconBuilder(
                context: context,
                icon: costume.borderedIcon,
                onTap: costume.routeTo,
                width: 32,
              ),
            ),
            SharedBuilder.textButtonSpan(context: context, text: costume.lName.l, onTap: costume.routeTo),
          ];
          return localized(
            jp: null,
            cn: () => rich('从者', servants(context), '装备灵衣', costumeSpans),
            tw: null,
            na: () => rich('Servant', servants(context), 'equips costume', costumeSpans),
            kr: null,
          );
        }
      // redirect to CondTargetNum
      case CondType.costumeGet:
      case CondType.notCostumeGet:
      case CondType.purchaseShop:
      case CondType.notShopPurchase:
      case CondType.svtCostumeReleased:
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
        return rich("CommonValue$target $arrow$value", [
          if (closedMessage != null && closedMessage.isNotEmpty)
            TextSpan(text: ' ($closedMessage)', style: Theme.of(context).textTheme.bodySmall),
        ]);
      case CondType.warClear:
        // value = 0/1 ?
        return localized(
          jp: () => rich(null, wars(context), 'をクリアした'),
          cn: () => rich('通关', wars(context)),
          tw: () => rich('通關', wars(context)),
          na: () => rich('Has cleared war ', wars(context)),
          kr: null,
        );

      case CondType.notWarClear:
        return localized(
          jp: () => rich(null, wars(context), 'をクリアされていません'),
          cn: () => rich('未通关', wars(context)),
          tw: () => rich('未通關', wars(context)),
          na: () => rich('Has not cleared war ', wars(context)),
          kr: null,
        );
      case CondType.shopFlagOn:
      case CondType.shopFlagOff:
        final status = {CondType.shopFlagOn: 'On', CondType.shopFlagOff: 'Off'}[condType]!;
        final flagName = UserShopFlag.values.where((e) => e.value & value != 0).map((e) => e.name).join('/');
        return localized(
          jp: null,
          cn: () => rich('商店 flag $value($flagName) $status ', shops(context)),
          tw: null,
          na: () => rich('Shop flag $value($flagName) $status ', shops(context)),
          kr: null,
        );
      default:
        break;
    }
    return [
      TextSpan(
        children: wrapMsg(
          localized(
            jp: () => text('不明な条件(${condType.name}): $value, $target'),
            cn: () => text('未知条件(${condType.name}): $value, $target'),
            tw: () => text('未知條件(${condType.name}): $value, $target'),
            na: () => text('Unknown Cond(${condType.name}): $value, $target'),
            kr: null,
          ),
        ),
        // style: kDebugMode ? const TextStyle(color: Colors.red) : null,
      ),
    ];
  }
}
