import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/master_mission/solver/scheme.dart';
import 'package:chaldea/models/models.dart';
import 'descriptor_base.dart';
import 'multi_entry.dart';

class MissionCondDetailDescriptor extends StatelessWidget with DescriptorBase {
  final int? targetNum;
  final EventMissionConditionDetail detail;
  final bool? _useAnd;
  @override
  final TextStyle? style;
  @override
  final double? textScaleFactor;
  @override
  final InlineSpan? leading;

  const MissionCondDetailDescriptor({
    super.key,
    required this.targetNum,
    required this.detail,
    this.style,
    this.textScaleFactor,
    this.leading,
    bool? useAnd,
  }) : _useAnd = useAnd;

  @override
  bool? get useAnd {
    if (_useAnd != null) return _useAnd;
    final type = CustomMission.kDetailCondMapping[detail.missionCondType];
    switch (type) {
      case CustomMissionType.trait:
        // https://github.com/atlasacademy/apps/commit/5f989cd9979a3f6313cc3e7eb349f7487bf607a7
        if (detail.missionCondType ==
            DetailCondType.enemyIndividualityKillNum) {
          return false;
        } else if (detail.missionCondType ==
            DetailCondType.defeatEnemyIndividuality) {
          return true;
        }
        return true;
      case CustomMissionType.questTrait:
        return false;
      case CustomMissionType.quest:
      case CustomMissionType.enemy:
      case CustomMissionType.servantClass:
      case CustomMissionType.enemyClass:
      case CustomMissionType.enemyNotServantClass:
        return false;
      case null:
        return null;
    }
  }

  @override
  List<int> get targetIds => detail.targetIds;

  @override
  List<InlineSpan> buildContent(BuildContext context) {
    String targetNum = this.targetNum?.toString() ?? 'x';
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
          kr: () => combineToRich(
              context, null, traits(context), '필드의 프리 퀘스트를 $targetNum회 클리어'),
        );
      case DetailCondType.questClearNum1:
      case DetailCondType.questClearNum2:
        if (targetIds.length == 1 && targetIds.first == 0) {
          return localized(
            jp: () => text('いずれかのクエストを$targetNum回クリアせよ'),
            cn: () => text('通关$targetNum次任意关卡'),
            tw: null,
            na: () => text('Complete any quest $targetNum times'),
            kr: () => text('퀘스트를 $targetNum회 클리어'),
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
            kr: () => combineToRich(
                context, '아래의 퀘스트를 $targetNum회 클리어', quests(context)),
          );
        }
      case DetailCondType.questClearNumIncludingGrailFront:
        return localized(
          jp: () => text('いずれかのクエスト（聖杯戦線含め）を$targetNum回クリアせよ'),
          cn: () => text('通关$targetNum次任意关卡(包括圣杯战线)'),
          tw: null,
          na: () => text(
              'Clear any quest including grail front quest $targetNum times'),
          kr: () => text('퀘스트를 (성배전선 포함) $targetNum회 클리어'),
        );
      case DetailCondType.mainQuestDone:
        return localized(
          jp: () => text('1部または2部のメインクエストを$targetNum回クリアせよ'),
          cn: () => text('通关$targetNum次第一部和第二部的主线关卡'),
          tw: null,
          na: () =>
              text('Clear any main quest in Arc 1 and Arc 2 $targetNum times'),
          kr: () => text('1부 또는 2부의 메인 퀘스트를 $targetNum회 클리어'),
        );
      case DetailCondType.enemyKillNum:
      case DetailCondType.targetQuestEnemyKillNum:
        return localized(
          context: context,
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
          kr: () => combineToRich(
              context, null, servants(context), '계열의 적을 $targetNum마리 처치'),
        );
      case DetailCondType.defeatEnemyIndividuality:
      case DetailCondType.enemyIndividualityKillNum:
      case DetailCondType.targetQuestEnemyIndividualityKillNum:
        return localized(
          context: context,
          jp: () => combineToRich(
              context, null, traits(context), '特性を持つ敵を$targetNum体倒せ'),
          cn: () => combineToRich(
              context, '击败$targetNum个持有', traits(context), '特性的敌人'),
          tw: null,
          na: () => combineToRich(context,
              'Defeat $targetNum enemies with traits ', traits(context)),
          kr: () => combineToRich(
              context, null, traits(context), '속성을 가진 적을 $targetNum마리 처치'),
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
          kr: () => combineToRich(
              context, null, svtClasses(context), '클래스의 서번트를 $targetNum기 처치'),
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
          kr: () => combineToRich(
              context, null, svtClasses(context), '클래스의 적을 $targetNum마리 처치'),
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
          kr: () => combineToRich(context, null, svtClasses(context),
              '클래스의 적을 $targetNum마리 처치 (서번트 및 일부 보스 등은 제외)'),
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
          kr: () => combineToRich(context, null, svtClasses(context),
              '클래스의 서번트를 1기 이상 편성해서 전투 진행을 $targetNum회 완료'),
        );
      case DetailCondType.itemGetBattle:
      case DetailCondType.itemGetTotal:
      case DetailCondType.targetQuestItemGetTotal:
        return localized(
          context: context,
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
          kr: () => combineToRich(
              context, '전리품으로 ', items(context), ' 중 하나를 $targetNum개 획득'),
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
          kr: () => combineToRich(context, null, traits(context),
              '특성을 가진 서번트를 1기 이상 편성해서 전투 진행을 $targetNum회 완료'),
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
          kr: () => combineToRich(context, null, servants(context),
              '를 1기 이상 편성해서 전투 진행을 $targetNum회 완료'),
        );
      case DetailCondType.svtGetBattle:
        return localized(
          jp: () => text('戦利品で種火を$targetNum個集めろ'),
          cn: () => text('获取$targetNum个种火作为战利品'),
          tw: null,
          na: () => text('Acquire $targetNum embers through battle'),
          kr: () => text('전리품으로 종화를 $targetNum개 획득'),
        );
      case DetailCondType.friendPointSummon:
        return localized(
          jp: () => text('フレンドポイント召喚を$targetNum回実行せよ'),
          cn: () => text('完成$targetNum次友情点召唤'),
          tw: null,
          na: () => text('Perform $targetNum Friend Point Summons'),
          kr: () => text('친구 포인트 소환을 $targetNum회 실행'),
        );
    }
    return localized(
      jp: () =>
          text('不明な条件(${detail.missionCondType}): $targetIds, $targetNum'),
      cn: () => text('未知条件(${detail.missionCondType}): $targetIds, $targetNum'),
      tw: null,
      na: () => text(
          'Unknown CondDetail(${detail.missionCondType}): $targetIds, $targetNum'),
      kr: () =>
          text('알 수 없는 조건(${detail.missionCondType}): $targetIds, $targetNum'),
    );
  }

  @override
  List<InlineSpan> localized({
    BuildContext? context,
    required List<InlineSpan> Function()? jp,
    required List<InlineSpan> Function()? cn,
    required List<InlineSpan> Function()? tw,
    required List<InlineSpan> Function()? na,
    required List<InlineSpan> Function()? kr,
  }) {
    final spans = super.localized(jp: jp, cn: cn, tw: tw, na: na, kr: kr);
    if (detail.targetQuestIndividualities.isEmpty) return spans;
    assert(context != null);
    final questTraits =
        detail.targetQuestIndividualities.map((e) => e.signedId).toList();
    return [
      ...spans,
      if (context != null)
        ...super.localized(
          jp: null,
          cn: () => combineToRich(null, '[所需关卡特性: ',
              MultiDescriptor.traits(context, questTraits), ']'),
          tw: null,
          na: () => combineToRich(null, '[Required Quest Trait: ',
              MultiDescriptor.traits(context, questTraits), ']'),
          kr: null,
        )
    ];
  }
}
