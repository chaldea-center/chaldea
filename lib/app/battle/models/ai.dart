import 'package:chaldea/app/api/atlas.dart';
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
      final ai = await showEasyLoading(() => AtlasApi.ai(AiType.field, aiId.id));
      if (ai != null) {
        ais.add(ai);
      }
    }
    fieldAis = ais;
  }

  Future<void> actWaveStart(BattleData battleData) async {
    for (final aiCollection in fieldAis) {
      final mainAis = NiceAiCollection.sortedAis(aiCollection.mainAis);
      if (!hasOnlyOneSkill(mainAis)) continue;
      for (final ai in mainAis) {
        if (ai.timingDescription != AiTiming.waveStart) continue;
        if (ai.cond == NiceAiCond.none || (ai.cond == NiceAiCond.turn && ai.vals.firstOrNull == 1)) {
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
              uploadEligible: battleData.niceQuest?.isLaplaceAllowAi == true,
            );
            break;
          }
        }
      }
    }
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
    aiCollection = await showEasyLoading(() => AtlasApi.ai(AiType.svt, aiId));
  }

  Future<void> reactionWaveStart(BattleData battleData, BattleServantData actor) async {
    if (aiCollection == null) return;
    final mainAis = NiceAiCollection.sortedAis(aiCollection!.mainAis);
    if (!hasOnlyOneSkill(mainAis)) return;
    for (final ai in mainAis) {
      if (ai.actNum == NiceAiActNum.reactionWavestart &&
          ai.cond == NiceAiCond.none &&
          ai.aiAct.type == NiceAiActType.skillId &&
          ai.aiAct.target == NiceAiActTarget.random) {
        final skill = ai.aiAct.skill;
        if (skill == null) continue;
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtAi, skillLv: ai.aiAct.skillLv ?? 1);
        await battleData.withActivator(actor, () => skillInfo.activate(battleData, defaultToPlayer: false));
        battleData.recorder.skill(
          prefix: 'SvtAI: ',
          battleData: battleData,
          activator: actor,
          skill: skillInfo,
          fromPlayer: actor.isPlayer,
          uploadEligible: battleData.niceQuest?.isLaplaceAllowAi == true,
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
          ai.aiAct.target == NiceAiActTarget.random) {
        final skill = ai.aiAct.skill;
        if (skill == null) continue;
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtAi, skillLv: ai.aiAct.skillLv ?? 1);
        await battleData.withActivator(actor, () => skillInfo.activate(battleData, defaultToPlayer: false));
        battleData.recorder.skill(
          prefix: 'SvtAI: ',
          battleData: battleData,
          activator: actor,
          skill: skillInfo,
          fromPlayer: actor.isPlayer,
          uploadEligible: battleData.niceQuest?.isLaplaceAllowAi == true,
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
          ai.aiAct.target == NiceAiActTarget.random) {
        final skill = ai.aiAct.skill;
        if (skill == null) continue;
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtAi, skillLv: ai.aiAct.skillLv ?? 1);
        await battleData.withActivator(actor, () => skillInfo.activate(battleData, defaultToPlayer: false));
        usedAiReactionTurnStart.add(ai.id);
        battleData.recorder.skill(
          prefix: 'SvtAI: ',
          battleData: battleData,
          activator: actor,
          skill: skillInfo,
          fromPlayer: actor.isPlayer,
          uploadEligible: battleData.niceQuest?.isLaplaceAllowAi == true,
        );
        break;
      }
    }
  }
}
