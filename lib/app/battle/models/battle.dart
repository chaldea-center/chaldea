import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'buff.dart';
import 'skill.dart';
import 'svt_entity.dart';

class BattleData {
  static const kValidTotalStarMax = 99;
  static const kValidViewStarMax = 49;
  static const kValidStarMax = 50;

  static const kMaxCommand = 3;
  static const playerOnFieldCount = 3;

  QuestPhase? niceQuest;
  Stage? curStage;

  int countEnemyAttack = 0;
  // List<int> playerEntryIds = [-1, -1, -1]; // unique id
  // List<int> enemyEntryIds = [-1, -1, -1]; // unique id
  int enemyOnFieldCount = 3;
  List<BattleServantData?> enemyDataList = [];
  List<BattleServantData?> playerDataList = [];

  // BattleData? data;
  // BattleInfoData battleInfo;
  // QuestEntity questEnt;
  // QuestPhaseEntity questPhaseEnt;
  List<int> questIndividuality = [];
  List<BuffData> fieldBuffs = [];
  MysticCode? mysticCode;
  int mysticCodeLv = 10;
  List<BattleSkillInfoData> masterSkillInfo = []; //BattleSkillInfoData
  // List<BattleSkillInfoData> boostSkillInfo;
  // List fieldDataList = []; //BattleFieldData

  int waveCount = 0;
  int turnCount = 1;
  int totalTurnCount = 0;
  // int limitTurnCount = 0;
  // int limitAct = 0;
  // List<int> turnEffect = [];
  // int turnEffectType = 0;
  // int globalTargetId = -1;
  // int lockTargetId = -1;
  // ComboData comboData;
  // List commandCodeInfos = []; //CommandCodeInfo
  int criticalStars = 0;
  // int addCriticalStars = 0;
  // int subCriticalCount = 0;
  // int prevCriticalStars = 0;
  // bool isCalcCritical = true;
  // List<DataVals>performedValsList=[];
  int lastActId = 0;
  int prevTargetId = 0;

  void init(QuestPhase quest, List<BattleServantData?> playerParty) {
    niceQuest = quest;
    waveCount = 1;
    turnCount = 1;
    totalTurnCount = 0;
    criticalStars = 0;
    lastActId = 0;
    prevTargetId = 0;
    final stage =
        curStage = quest.stages.firstWhereOrNull((s) => s.wave == waveCount);
    enemyOnFieldCount = curStage?.enemyFieldPosCount ?? 3;
    enemyDataList = List.filled(enemyOnFieldCount, null, growable: true);
    playerDataList = playerParty.map((e) => e?.copy()).toList();
    if (stage != null) {
      for (final enemy in stage.enemies) {
        if (enemy.deck != DeckType.enemy) continue;
        if (enemy.deckId > enemyDataList.length) {
          enemyDataList.length = enemy.deckId;
          enemyDataList[enemy.deckId - 1] = BattleServantData.fromEnemy(enemy);
        }
      }
    }
  }

  void nextTurn() {
    turnCount += 1;
    totalTurnCount += 1;
  }

  void nextWave() {
    waveCount += 1;
    turnCount = 0;
    curStage = niceQuest?.stages.firstWhereOrNull((s) => s.wave == waveCount);
    enemyOnFieldCount = curStage?.enemyFieldPosCount ?? 3;
    enemyDataList = List.filled(enemyOnFieldCount, null, growable: true);
    if (curStage != null) {
      for (final enemy in curStage!.enemies) {
        if (enemy.deck != DeckType.enemy) continue;
        if (enemy.deckId > enemyDataList.length) {
          enemyDataList.length = enemy.deckId;
          enemyDataList[enemy.deckId - 1] = BattleServantData.fromEnemy(enemy);
        }
      }
    }
  }
}

// TACTICAL_START
// START_PLAYERTURN
// COMMAND_BEFORE
// // FIELDAI_START_PLAYERTURN
// // NPCAI_START_PLAYERTURN
// COMMAND_ATTACK_1
// COUNTER_FUNC_ENEMY
// CHECK_OVERKILL
// CHECK_IMMEDIATE_ENTRY
// START_IMMEDIATE_ENTRY
// AFTER_IMMEDIATE_ENTRY
// COMMAND_ATTACK_2
// COUNTER_FUNC_ENEMY
// CHECK_OVERKILL
// CHECK_IMMEDIATE_ENTRY
// START_IMMEDIATE_ENTRY
// AFTER_IMMEDIATE_ENTRY
// COMMAND_ATTACK_3
// COUNTER_FUNC_ENEMY
// CHECK_OVERKILL
// CHECK_IMMEDIATE_ENTRY
// START_IMMEDIATE_ENTRY
// AFTER_IMMEDIATE_ENTRY
// COMMAND_ADDATTACK
// COUNTER_FUNC_ENEMY
// COMMAND_AFTER
// CHECK_IMMEDIATE_ENTRY
// START_IMMEDIATE_ENTRY
// AFTER_IMMEDIATE_ENTRY
// GET_DROPITEM
// COMMAND_WAIT
// REACTION_PLAYERACTIONEND
// REFLECTION_ENEMY
// PLAYER_ENDTURN
// FIELDAI_END_PLAYERTURN
// NPCAI_END_PLAYERTURN
// BUFF_ADDPARAM_ENEMY
// UPDATE_SHIFTSERVANT
// AFTER_SHIFTSERVANT
// PLAYER_ATTACK_TERM
// START_ENEMYTURN
// FIELDAI_START_ENEMYTURN
// NPCAI_START_ENEMYTURN
// REACTION_STARTENEMY
// RESET_ENEMYACTLIST
// ENEMY_ATTACK_NORMAL_AI
// COUNTER_FUNC_PLAYER
// CHECK_IMMEDIATE_ENTRY
// START_IMMEDIATE_ENTRY
// AFTER_IMMEDIATE_ENTRY
// ENEMY_ATTACK_NORMAL_AI
// COUNTER_FUNC_PLAYER
// CHECK_IMMEDIATE_ENTRY
// START_IMMEDIATE_ENTRY
// AFTER_IMMEDIATE_ENTRY
// ENEMY_ATTACK_NORMAL_AI
// COUNTER_FUNC_PLAYER
// CHECK_IMMEDIATE_ENTRY
// START_IMMEDIATE_ENTRY
// AFTER_IMMEDIATE_ENTRY
// ENEMY_ATTACK_NORMAL_AI
// COUNTER_FUNC_PLAYER
// CHECK_IMMEDIATE_ENTRY
// START_IMMEDIATE_ENTRY
// AFTER_IMMEDIATE_ENTRY
// ENEMY_ATTACK_NORMAL_AI
// COUNTER_FUNC_PLAYER
// CHECK_IMMEDIATE_ENTRY
// START_IMMEDIATE_ENTRY
// AFTER_IMMEDIATE_ENTRY
// ENEMY_ATTACK_NORMAL_AI
// COUNTER_FUNC_PLAYER
// CHECK_IMMEDIATE_ENTRY
// START_IMMEDIATE_ENTRY
// AFTER_IMMEDIATE_ENTRY
// ENEMY_ATTACK_NORMAL_AI
// COUNTER_FUNC_PLAYER
// CHECK_IMMEDIATE_ENTRY
// START_IMMEDIATE_ENTRY
// AFTER_IMMEDIATE_ENTRY
// ENEMY_ATTACK_NORMAL_AI
// COUNTER_FUNC_PLAYER
// CHECK_IMMEDIATE_ENTRY
// START_IMMEDIATE_ENTRY
// AFTER_IMMEDIATE_ENTRY
// ENEMY_ATTACK_NORMAL_AI
// COUNTER_FUNC_PLAYER
// CHECK_IMMEDIATE_ENTRY
// START_IMMEDIATE_ENTRY
// AFTER_IMMEDIATE_ENTRY
// REACTION_ENDENEMY
// LAST_BACKSTEP
// REFLECTION_PLAYER
// ENEMY_ENDTURN
// FIELDAI_END_ENEMYTURN
// NPCAI_END_ENEMYTURN
// BUFF_ADDPARAM_PLAYER
// ENEMY_ENDWAIT
// GET_DROPITEM
// ENEMY_ATTACK_TERM
