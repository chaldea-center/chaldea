import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'battle.dart';

class FieldAiManager {
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
      for (final ai in mainAis) {
        if (ai.cond == NiceAiCond.none || (ai.cond == NiceAiCond.turn && ai.vals.firstOrNull == 1)) {
          if (ai.aiAct.type == NiceAiActType.skillId && ai.aiAct.target == NiceAiActTarget.random) {
            final skill = ai.aiAct.skill;
            if (skill == null) continue;
            final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.none, skillLv: ai.aiAct.skillLv ?? 1);
            await skillInfo.activate(battleData, defaultToPlayer: true);
            break;
          }
        }
      }
    }
  }
}

class SvtAiManager {
  final EnemyAi? enemyAi;
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
    for (final ai in mainAis) {
      if (ai.cond == NiceAiCond.none &&
          ai.aiAct.type == NiceAiActType.skillId &&
          ai.aiAct.target == NiceAiActTarget.random) {
        final skill = ai.aiAct.skill;
        if (skill == null) continue;
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.none, skillLv: ai.aiAct.skillLv ?? 1);
        await battleData.withActivator(actor, () => skillInfo.activate(battleData, defaultToPlayer: false));
        break;
      }
    }
  }

  Future<void> afterTurnPlayerEnd(BattleData battleData, BattleServantData actor) async {
    if (aiCollection == null) return;
    print('SVT AI afterTurnPlayerEnd: $actor');
    final mainAis = NiceAiCollection.sortedAis(aiCollection!.mainAis);
    for (final ai in mainAis) {
      if (ai.cond == NiceAiCond.none &&
          ai.aiAct.type == NiceAiActType.skillId &&
          ai.aiAct.target == NiceAiActTarget.random) {
        final skill = ai.aiAct.skill;
        if (skill == null) continue;
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.none, skillLv: ai.aiAct.skillLv ?? 1);
        await battleData.withActivator(actor, () => skillInfo.activate(battleData, defaultToPlayer: false));
        break;
      }
    }
  }
}
