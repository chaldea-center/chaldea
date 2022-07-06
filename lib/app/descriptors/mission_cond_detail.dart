import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'descriptor_base.dart';

class MissionCondDetailDescriptor extends StatelessWidget with DescriptorBase {
  final int targetNum;
  final EventMissionConditionDetail detail;
  @override
  final TextStyle? style;
  @override
  final double? textScaleFactor;

  const MissionCondDetailDescriptor({
    Key? key,
    required this.targetNum,
    required this.detail,
    this.style,
    this.textScaleFactor,
  }) : super(key: key);

  @override
  List<int> get targetIds => detail.targetIds;

  @override
  Widget build(BuildContext context) {
    switch (detail.missionCondType) {
      case DetailCondType.questClearIndividuality:
        return localized(
          jp: () => combineToRich(
              context, null, traits(context), 'フィールドのクエストを$targetNum回クリアせよ'),
          cn: () => combineToRich(
              context, '通关$targetNum次场地为', traits(context), '的关卡'),
          tw: null,
          na: () => combineToRich(
            context,
            'Clear $targetNum quests with fields ',
            traits(context),
          ),
          kr: null,
        );
      case DetailCondType.questClearNum1:
      case DetailCondType.questClearNum2:
        if (targetIds.length == 1 && targetIds.first == 0) {
          return localized(
            jp: () => text('いずれかのクエストを$targetNum回クリアせよ'),
            cn: () => text('通关$targetNum次任意关卡'),
            tw: null,
            na: () => text('Complete any quest $targetNum times'),
            kr: null,
          );
        } else {
          return localized(
            jp: () => combineToRich(
                context, '以下のクエストを$targetNum回クリアせよ', quests(context)),
            cn: () =>
                combineToRich(context, '通关$targetNum次以下关卡', quests(context)),
            tw: null,
            na: () => combineToRich(
                context, '$targetNum runs of quests ', quests(context)),
            kr: null,
          );
        }
      case DetailCondType.questClearNumIncludingGrailFront:
        return localized(
          jp: () => text('いずれかのクエスト（聖杯戦線含め）を$targetNum回クリアせよ'),
          cn: () => text('通关$targetNum次任意关卡(包括圣杯战线)'),
          tw: null,
          na: () => text(
              'Clear any quest including grail front quest $targetNum times'),
          kr: null,
        );
      case DetailCondType.mainQuestDone:
        return localized(
          jp: () => text('1部または2部のメインクエストを$targetNum回クリアせよ'),
          cn: () => text('通关$targetNum次第一部和第二部的主线关卡'),
          tw: null,
          na: () =>
              text('Clear any main quest in Arc 1 and Arc 2 $targetNum times'),
          kr: null,
        );
      case DetailCondType.enemyKillNum:
        return localized(
          jp: () => combineToRich(
              context, null, servants(context), 'の敵を$targetNum体倒せ'),
          cn: () =>
              combineToRich(context, '击败$targetNum个敌人:', servants(context)),
          tw: null,
          na: () => combineToRich(
            context,
            'Defeat $targetNum from enemies ',
            servants(context),
          ),
          kr: null,
        );
      case DetailCondType.defeatEnemyIndividuality:
      case DetailCondType.enemyIndividualityKillNum:
        return localized(
          jp: () => combineToRich(
              context, null, traits(context), '特性を持つ敵を$targetNum体倒せ'),
          cn: () => combineToRich(
              context, '击败$targetNum个持有', traits(context), '特性的敌人'),
          tw: null,
          na: () => combineToRich(context,
              'Defeat $targetNum enemies with traits ', traits(context)),
          kr: null,
        );
      case DetailCondType.defeatServantClass:
        return localized(
          jp: () => combineToRich(
              context, null, svtClasses(context), 'クラスのサーヴァントを$targetNum骑倒せ'),
          cn: () => combineToRich(
              context, '击败$targetNum骑', svtClasses(context), '职阶中任意一种从者'),
          tw: null,
          na: () => combineToRich(context,
              'Defeat $targetNum servants with class ', svtClasses(context)),
          kr: null,
        );
      case DetailCondType.defeatEnemyClass:
        return localized(
          jp: () => combineToRich(
              context, null, svtClasses(context), 'クラスの敵を$targetNum骑倒せ'),
          cn: () => combineToRich(
              context, '击败$targetNum骑', svtClasses(context), '职阶中任意一种敌人'),
          tw: null,
          na: () => combineToRich(
            context,
            'Defeat $targetNum enemies with class ',
            svtClasses(context),
          ),
          kr: null,
        );
      case DetailCondType.defeatEnemyNotServantClass:
        return localized(
          jp: () => combineToRich(context, null, svtClasses(context),
              'クラスの敵を$targetNum骑倒せ(サーヴァント及び一部ボスなどは除く)'),
          cn: () => combineToRich(context, '击败$targetNum骑', svtClasses(context),
              '职阶中任意一种敌人(从者及部分首领级敌方除外)'),
          tw: null,
          na: () => combineToRich(
            context,
            'Defeat $targetNum enemies with class ',
            svtClasses(context),
            ' (excluding Servants and certain bosses)',
          ),
          kr: null,
        );
      case DetailCondType.battleSvtClassInDeck:
        return localized(
          jp: () => combineToRich(context, null, svtClasses(context),
              'クラスのサーヴァントを1騎以上編成して、いずれかのクエストを$targetNum回クリアせよ'),
          cn: () => combineToRich(context, '在队伍中编入至少1骑以上', svtClasses(context),
              '职阶从者，并完成任意关卡$targetNum次'),
          tw: null,
          na: () => combineToRich(
            context,
            'Put one or more servants with class',
            svtClasses(context),
            ' in your Party and complete any quest $targetNum times',
          ),
          kr: null,
        );
      case DetailCondType.itemGetBattle:
      case DetailCondType.itemGetTotal:
        return localized(
          jp: () =>
              combineToRich(context, '戦利品で', items(context), 'を$targetNum個集めろ'),
          cn: () =>
              combineToRich(context, '通过战利品获得$targetNum个道具', items(context)),
          tw: null,
          na: () => combineToRich(
            context,
            'Obtain $targetNum ',
            items(context),
            ' as battle drop',
          ),
          kr: null,
        );
      case DetailCondType.battleSvtIndividualityInDeck:
        return localized(
          jp: () => combineToRich(context, null, traits(context),
              '属性を持つサーヴァントを1騎以上編成して、いずれかのクエストを$targetNum回クリアせよ'),
          cn: () => combineToRich(context, '在队伍内编入至少1骑以上持有', traits(context),
              '属性的从者，并完成任意关卡$targetNum次'),
          tw: null,
          na: () => combineToRich(
            context,
            'Put servants with traits',
            traits(context),
            ' in your Party and complete Quests $targetNum times',
          ),
          kr: null,
        );
      case DetailCondType.battleSvtIdInDeck1:
      case DetailCondType.battleSvtIdInDeck2:
        return localized(
          jp: () => combineToRich(context, null, servants(context),
              'のサーヴァントを1騎以上編成して、いずれかのクエストを$targetNum回クリアせよ'),
          cn: () => combineToRich(context, '在队伍内编入至少1骑以上', servants(context),
              '从者，并完成任意关卡$targetNum次'),
          tw: null,
          na: () => combineToRich(context, 'Put servants ', servants(context),
              ' in your Party and complete Quests $targetNum times'),
          kr: null,
        );
      case DetailCondType.svtGetBattle:
        return localized(
          jp: () => text('戦利品で種火を$targetNum個集めろ'),
          cn: () => text('获取$targetNum个种火作为战利品'),
          tw: null,
          na: () => text('Acquire $targetNum embers through battle'),
          kr: null,
        );
      case DetailCondType.friendPointSummon:
        return localized(
          jp: () => text('フレンドポイント召喚を$targetNum回実行せよ'),
          cn: () => text('完成$targetNum次友情点召唤'),
          tw: null,
          na: () => text('Perform $targetNum Friend Point Summons'),
          kr: null,
        );
    }
    return localized(
      jp: () =>
          text('不明な条件(${detail.missionCondType}): $targetIds, $targetNum'),
      cn: () => text('未知条件(${detail.missionCondType}): $targetIds, $targetNum'),
      tw: null,
      na: () => text(
          'Unknown CondDetail(${detail.missionCondType}): $targetIds, $targetNum'),
      kr: null,
    );
  }
}
