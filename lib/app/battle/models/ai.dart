import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/gamedata/individuality.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

import 'battle.dart';

/// - currently only check mainAis
/// - Should allow [NiceAiActType.skillIdCheckbuff] too

mixin _AiManagerBase {
  bool hasOnlyOneSkill(List<NiceAi> ais) {
    return ais.where((ai) => ai.aiAct.type == NiceAiActType.skillId && ai.aiAct.skill != null).length == 1;
  }
}

class FieldAiManager with _AiManagerBase {
  final List<FieldAi> aiIds;
  FieldAiManager([this.aiIds = const []]);

  List<NiceAiCollection> fieldAis = [];

  Future<void> fetchAiData() async {
    final List<NiceAiCollection> ais = [];
    for (final aiId in aiIds) {
      final ai = await showEasyLoading(() => AtlasApi.ai(AiType.field, aiId.id), mask: true);
      if (ai != null) {
        ais.add(ai);
      }
    }
    fieldAis = ais;
  }

  Future<void> simpleAiAct(BattleData battleData, AiTiming timing) async {
    for (final aiCollection in fieldAis) {
      final mainAis = NiceAiCollection.sortedAis(aiCollection.mainAis);
      if (!hasOnlyOneSkill(mainAis)) continue;
      for (final ai in mainAis) {
        if (ai.timing != timing.value) continue;
        if (ai.cond == NiceAiCond.none ||
            (ai.cond == NiceAiCond.turn && ai.vals.firstOrNull == 1) ||
            (ai.cond == NiceAiCond.commonReleaseId && await AiCondEvaluator.isAllowedCommonRelease(ai.vals))) {
          if (ai.aiAct.type == NiceAiActType.skillId && ai.aiAct.target == NiceAiActTarget.random) {
            final skill = ai.aiAct.skill;
            if (skill == null) continue;
            final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.fieldAi, skillLv: ai.aiAct.skillLv ?? 1);
            await skillInfo.activate(battleData, defaultToPlayer: true);
            battleData.recorder.skill(
              prefix: 'FieldAI: ',
              battleData: battleData,
              activator: null,
              skill: skillInfo,
              fromPlayer: true,
              uploadEligible: battleData.niceQuest?.isLaplaceNeedAi == true,
            );
            break;
          }
        }
      }
    }
  }

  Future<void> actWaveStart(BattleData battleData) async {
    await simpleAiAct(battleData, AiTiming.waveStart);
  }

  Future<void> actWaveStartAnimation(BattleData battleData) async {
    await simpleAiAct(battleData, AiTiming.beforeWaveStartAnimation);
  }

  Future<void> actTurnStart(BattleData battleData) async {
    if (battleData.turnCount > 0) {
      // since no real AI logic yet
      return;
    }
    await simpleAiAct(battleData, AiTiming.turnStart);
  }
}

class SvtAiManager with _AiManagerBase {
  final EnemyAi? enemyAi;
  Set<int> usedAiReactionTurnStart = {};
  SvtAiManager(this.enemyAi);
  NiceAiCollection? aiCollection;

  Future<void> fetchAiData() async {
    final aiId = enemyAi?.aiId ?? 0;
    if (aiId == 0) return;
    aiCollection = await showEasyLoading(() => AtlasApi.ai(AiType.svt, aiId), mask: true);
  }

  Future<void> reactionWaveStart(BattleData battleData, BattleServantData actor) async {
    if (aiCollection == null || battleData.niceQuest == null) return;
    final mainAis = NiceAiCollection.sortedAis(aiCollection!.mainAis);
    final isFinalChapterRaid = battleData.niceQuest!.isAnyRaid && battleData.niceQuest!.warId == 407;
    if (!hasOnlyOneSkill(mainAis) && !isFinalChapterRaid) return;
    for (final ai in mainAis) {
      if (ai.actNum == NiceAiActNum.reactionWavestart &&
          (ai.cond == NiceAiCond.none || isFinalChapterRaid) &&
          ai.aiAct.type == NiceAiActType.skillId &&
          ai.aiAct.target == NiceAiActTarget.random &&
          ai.aiAct.targetIndividuality.isEmpty) {
        final skill = ai.aiAct.skill;
        if (skill == null) continue;
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtAi, skillLv: ai.aiAct.skillLv ?? 1);
        await skillInfo.activate(battleData, activator: actor, defaultToPlayer: false);
        battleData.recorder.skill(
          prefix: 'SvtAI: ',
          battleData: battleData,
          activator: actor,
          skill: skillInfo,
          fromPlayer: actor.isPlayer,
          uploadEligible: battleData.niceQuest?.isLaplaceNeedAi == true,
        );
        break;
      }
    }
  }

  // after shift servant only
  Future<void> afterTurnPlayerEnd(BattleData battleData, BattleServantData actor) async {
    if (aiCollection == null) return;
    final mainAis = NiceAiCollection.sortedAis(aiCollection!.mainAis);
    if (!hasOnlyOneSkill(mainAis)) return;
    for (final ai in mainAis) {
      if (ai.actNum == NiceAiActNum.afterTurnPlayerEnd &&
          ai.cond == NiceAiCond.none &&
          ai.aiAct.type == NiceAiActType.skillId &&
          ai.aiAct.target == NiceAiActTarget.random &&
          ai.aiAct.targetIndividuality.isEmpty) {
        final skill = ai.aiAct.skill;
        if (skill == null) continue;
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtAi, skillLv: ai.aiAct.skillLv ?? 1);
        await skillInfo.activate(battleData, activator: actor, defaultToPlayer: false);
        battleData.recorder.skill(
          prefix: 'SvtAI: ',
          battleData: battleData,
          activator: actor,
          skill: skillInfo,
          fromPlayer: actor.isPlayer,
          uploadEligible: battleData.niceQuest?.isLaplaceNeedAi == true,
        );
        break;
      }
    }
  }

  // after firstEntry only, activate once per svt
  Future<void> reactionTurnStart(BattleData battleData, BattleServantData actor) async {
    if (aiCollection == null) return;
    final mainAis = NiceAiCollection.sortedAis(aiCollection!.mainAis);
    if (!hasOnlyOneSkill(mainAis)) return;
    for (final ai in mainAis) {
      if (usedAiReactionTurnStart.contains(ai.id)) continue;
      if (ai.actNum == NiceAiActNum.reactionTurnstart &&
          ai.cond == NiceAiCond.none &&
          ai.aiAct.type == NiceAiActType.skillId &&
          ai.aiAct.target == NiceAiActTarget.random &&
          ai.aiAct.targetIndividuality.isEmpty) {
        final skill = ai.aiAct.skill;
        if (skill == null) continue;
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtAi, skillLv: ai.aiAct.skillLv ?? 1);
        await skillInfo.activate(battleData, activator: actor, defaultToPlayer: false);
        usedAiReactionTurnStart.add(ai.id);
        battleData.recorder.skill(
          prefix: 'SvtAI: ',
          battleData: battleData,
          activator: actor,
          skill: skillInfo,
          fromPlayer: actor.isPlayer,
          uploadEligible: battleData.niceQuest?.isLaplaceNeedAi == true,
        );
        break;
      }
    }
  }

  /// For now this is exclusively for Grand Duel Assassin's AI
  Future<void> reactionPlayerActionStart(BattleData battleData, BattleServantData actor) async {
    final questId = battleData.niceQuest?.id ?? 0;
    if (aiCollection == null ||
        !ConstGameData.grandDuelAssassinFreeQuestIds.contains(questId) ||
        enemyAi?.aiId != ConstGameData.grandDualAssassinFreeBaseSvtAiId)
      return;

    final mainAis = NiceAiCollection.sortedAis(aiCollection!.mainAis);
    for (final ai in mainAis) {
      // grande dual assassin hardcoded logic for func target
      final targetIndex = battleData.turnCount % 3 - 1;
      final target = battleData.onFieldAllyServants.getOrNull(targetIndex);

      if (ai.actNum == NiceAiActNum.reactionPlayeractionstart &&
          await AiCondEvaluator.evaluate(ai, battleData, actor, target)) {
        if (ai.aiAct.type != NiceAiActType.skillId) {
          // other aiActType treated as no-op
          return;
        }

        final skill = ai.aiAct.skill;
        if (skill == null) return;
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtAi, skillLv: ai.aiAct.skillLv ?? 1);
        await skillInfo.activate(battleData, activator: actor, defaultToPlayer: false, preferredEnemy: target);
        battleData.recorder.skill(
          prefix: 'SvtAI: ',
          battleData: battleData,
          activator: actor,
          skill: skillInfo,
          fromPlayer: actor.isPlayer,
          uploadEligible: battleData.niceQuest?.isLaplaceNeedAi == true,
        );
        break;
      }
    }
  }
}

class AiCondEvaluator {
  AiCondEvaluator._();

  static Future<bool> evaluate(
    NiceAi ai,
    BattleData battleData,
    BattleServantData actor,
    BattleServantData? targetOverride,
  ) async {
    bool result = false;
    switch (ai.cond) {
      case NiceAiCond.none:
        result = true;
      case NiceAiCond.turn:
        result = battleData.turnCount == ai.vals.firstOrNull;
      case NiceAiCond.commonReleaseId:
        result = await isAllowedCommonRelease(ai.vals);
      case NiceAiCond.checkSelfIndividuality:
        result = Individuality.checkSignedIndividualities2(
          self: actor.getTraits(),
          signedTarget: ai.vals,
          matchedFunc: Individuality.isMatchArray,
          mismatchFunc: Individuality.isMatchArray,
        );
      case NiceAiCond.checkSelfBuffIndividuality:
        result = Individuality.checkSignedIndividualities2(
          self: actor.getBuffTraits(),
          signedTarget: ai.vals,
          matchedFunc: Individuality.isMatchArray,
          mismatchFunc: Individuality.isMatchArray,
        );
      case NiceAiCond.existIndividualityOpponentFront:
        // we don't have proper AI logic yet so allowing overrides for now
        final target = targetOverride ?? battleData.onFieldAllyServants.getOrNull(0);
        result = Individuality.checkSignedIndividualities2(
          self: target?.getTraits(),
          signedTarget: ai.vals,
          matchedFunc: Individuality.isMatchArray,
          mismatchFunc: Individuality.isMatchArray,
        );
      case NiceAiCond.existIndividualityOpponentCenter:
        final target = targetOverride ?? battleData.onFieldAllyServants.getOrNull(1);
        result = Individuality.checkSignedIndividualities2(
          self: target?.getTraits(),
          signedTarget: ai.vals,
          matchedFunc: Individuality.isMatchArray,
          mismatchFunc: Individuality.isMatchArray,
        );
      case NiceAiCond.existIndividualityOpponentBack:
        final target = targetOverride ?? battleData.onFieldAllyServants.getOrNull(2);
        result = Individuality.checkSignedIndividualities2(
          self: target?.getTraits(),
          signedTarget: ai.vals,
          matchedFunc: Individuality.isMatchArray,
          mismatchFunc: Individuality.isMatchArray,
        );
      default:
        result = false;
    }

    if (ai.condNegative) {
      result = !result;
    }
    return result;
  }

  static Future<bool> isAllowedCommonRelease(List<int> aiVals) async {
    if (aiVals.isEmpty) return true;
    final commonReleaseId = aiVals.first;
    assert(aiVals.where((e) => e > 10).length == 1, 'Ai contains multiple ids for common release cond: $aiVals');
    final releases = await showEasyLoading(() => AtlasApi.commonRelease(commonReleaseId), mask: true);
    if (releases == null) return true;
    if (CommonRelease.check(releases, _checkOneRelease) == false) {
      return false;
    }
    return true;
  }

  static bool? _checkOneRelease(CommonRelease release) {
    if (const <CondType>{.questClearPhase, .questClear}.contains(release.condType)) {
      return true;
    }
    return null;
  }
}
