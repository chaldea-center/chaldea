import 'package:chaldea/app/battle/functions/damage.dart';
import 'package:chaldea/app/battle/functions/gain_np.dart';
import 'package:chaldea/app/battle/functions/gain_star.dart';
import 'package:chaldea/app/battle/models/command_card.dart';
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

  static final DataVals artsChain = DataVals({'Rate': 5000, 'Value': 2000});
  static final DataVals quickChainBefore7thAnni = DataVals({'Rate': 5000, 'Value': 10});
  static final DataVals quickChainAfter7thAnni = DataVals({'Rate': 5000, 'Value': 20});
  static final DataVals cardDamage = DataVals({'Rate': 1000, 'Value': 1000});

  QuestPhase? niceQuest;
  Stage? curStage;

  int countEnemyAttack = 0;

  // List<int> playerEntryIds = [-1, -1, -1]; // unique id
  // List<int> enemyEntryIds = [-1, -1, -1]; // unique id
  int enemyOnFieldCount = 3;
  List<BattleServantData?> enemyDataList = [];
  List<BattleServantData?> playerDataList = [];
  List<BattleServantData?> onFieldEnemies = [];
  List<BattleServantData?> onFieldAllyServants = [];
  Map<DeckType, List<BattleServantData>> enemyDecks = {};

  int enemyTargetIndex = 0;
  int allyTargetIndex = 0;

  BattleServantData? get targetedEnemy => onFieldEnemies[enemyTargetIndex];

  BattleServantData? get targetedAlly => onFieldAllyServants[allyTargetIndex];

  List<BattleServantData> get aliveEnemies => _getNonnull(onFieldEnemies);

  List<BattleServantData> get aliveAllies => _getNonnull(onFieldAllyServants);

  List<BattleServantData> get aliveActors => [...aliveAllies, ...aliveEnemies];

  List<BattleServantData> get nonnullBackupEnemies => _getNonnull(enemyDataList);

  List<BattleServantData> get nonnullBackupAllies => _getNonnull(playerDataList);

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
  bool previousFunctionResult = true;

  int fixedRandom = db.gameData.constData.constants.attackRateRandomMin;
  int probabilityThreshold = 1000;
  bool isAfter7thAnni = true;

  CommandCardData? currentCard;
  final List<BuffData?> _currentBuff = [];
  final List<BattleServantData> _activator = [];
  final List<BattleServantData> _target = [];

  void setCurrentBuff(BuffData buff) {
    _currentBuff.add(buff);
  }

  BuffData? get currentBuff => _currentBuff.isNotEmpty ? _currentBuff.last : null;

  void unsetCurrentBuff() {
    _currentBuff.removeLast();
  }

  void setActivator(BattleServantData svt) {
    _activator.add(svt);
  }

  BattleServantData? get activator => _activator.isNotEmpty ? _activator.last : null;

  void unsetActivator() {
    _activator.removeLast();
  }

  void setTarget(BattleServantData svt) {
    _target.add(svt);
  }

  BattleServantData get target => _target.last;

  void unsetTarget() {
    _target.removeLast();
  }

  void init(QuestPhase quest, List<BattleServantData?> playerParty, MysticCode? selectedMC) {
    niceQuest = quest;
    waveCount = 1;
    turnCount = 0;
    totalTurnCount = 0;
    criticalStars = 0;
    lastActId = 0;
    prevTargetId = 0;

    playerDataList = playerParty.map((e) => e?.copy()).toList();
    _fetchWaveEnemies();

    playerDataList.forEach((svt) {
      svt?.init(this);
    });
    enemyDataList.forEach((enemy) {
      enemy?.init(this);
    });

    mysticCode = selectedMC;
    mysticCodeLv = db.curUser.mysticCodes[mysticCode?.id] ?? 10;

    _initOnField(playerDataList, onFieldAllyServants, playerOnFieldCount);
    _initOnField(enemyDataList, onFieldEnemies, enemyOnFieldCount);

    aliveActors.forEach((element) {
      element.enterField(this);
    });

    nextTurn();
  }

  void nextTurn() {
    turnCount += 1;
    totalTurnCount += 1;

    if (enemyDataList.isEmpty && onFieldEnemies.every((enemy) => enemy == null)) {
      nextWave();
    }
    // start of ally turn
    aliveActors.forEach((svt) {svt.startOfMyTurn(this);});
  }

  void nextWave() {
    waveCount += 1;
    turnCount = 0;

    _fetchWaveEnemies();
    enemyDataList.forEach((enemy) {
      enemy?.init(this);
    });
  }

  void _fetchWaveEnemies() {
    curStage = niceQuest?.stages.firstWhereOrNull((s) => s.wave == waveCount);
    enemyOnFieldCount = curStage?.enemyFieldPosCount ?? 3;
    enemyDataList = List.filled(enemyOnFieldCount, null, growable: true);
    enemyDecks.clear();

    if (curStage != null) {
      for (final enemy in curStage!.enemies) {
        if (enemy.deck == DeckType.enemy) {
          if (enemy.deckId > enemyDataList.length) {
            enemyDataList.length = enemy.deckId;
          }

          enemyDataList[enemy.deckId - 1] = BattleServantData.fromEnemy(enemy);
        } else {
          if (!enemyDecks.containsKey(enemy.deck)) {
            enemyDecks[enemy.deck] = [];
          }
          enemyDecks[enemy.deck]!.add(BattleServantData.fromEnemy(enemy));
        }
      }
    }
  }

  void _initOnField(List<BattleServantData?> dataList, List<BattleServantData?> onFieldList, int maxCount) {
    while (dataList.isNotEmpty && onFieldList.length < maxCount) {
      final svt = dataList.removeAt(0);
      svt?.deckIndex = onFieldList.length + 1;
      onFieldList.add(svt);
    }
  }

  List<BattleServantData> _getNonnull(List<BattleServantData?> list) {
    List<BattleServantData> results = [];
    for (BattleServantData? nullableSvt in list) {
      if (nullableSvt != null) {
        results.add(nullableSvt);
      }
    }
    return results;
  }

  void changeStar(int change) {
    criticalStars += change;
    criticalStars.clamp(0, kValidTotalStarMax);
  }

  List<NiceTrait> getFieldTraits() {
    // TODO (battle): account for add & remove field traits
    return niceQuest?.individuality ?? [];
  }

  bool checkTargetTraits(Iterable<NiceTrait> requiredTraits) {
    return target.checkTraits(requiredTraits) ||
        (currentBuff?.checkTraits(requiredTraits) ?? false) ||
        (currentCard?.checkTraits(requiredTraits) ?? false);
  }

  bool checkActivatorTraits(Iterable<NiceTrait> requiredTraits) {
    return (activator?.checkTraits(requiredTraits) ?? false) ||
        (currentBuff?.checkTraits(requiredTraits) ?? false) ||
        (currentCard?.checkTraits(requiredTraits) ?? false);
  }

  bool isActorOnField(int actorUniqueId) {
    return aliveAllies.any((svt) => svt.uniqueId == actorUniqueId) ||
        aliveEnemies.any((svt) => svt.uniqueId == actorUniqueId);
  }

  void checkBuffStatus() {
    aliveActors.forEach((svt) {
      svt.checkBuffStatus();
    });
  }

  void executeCombatActions(List<CombatAction> actions) {
    criticalStars = 0;

    if (actions.isEmpty) {
      return;
    }

    // assumption: only Quick, Arts, and Buster are ever listed as viable actions
    final cardTypesSet = actions.map((action) => action.cardData.cardType).toSet();
    bool isTypeChain = cardTypesSet.length == 1;
    bool isMightyChain = cardTypesSet.length == 3;
    CardType firstCardType = actions[0].cardData.cardType;
    if (isTypeChain) {
      applyTypeChain(firstCardType, actions);
    }

    int extraOvercharge = 0;
    for (int i = 0; i < actions.length; i += 1) {
      if (aliveEnemies.isNotEmpty) {
        final action = actions[i];
        currentCard = action.cardData;
        allyTargetIndex = onFieldAllyServants.indexOf(action.actor); // help damageFunction identify attacker
        if (currentCard!.isNP && action.actor.canNP(this)) {
          action.actor.activateNP(this, extraOvercharge);
          extraOvercharge += 1;
        } else if (!currentCard!.isNP && action.actor.canCommandCard(this)) {
          extraOvercharge = 0;
          setActivator(action.actor);

          final List<BattleServantData> targets = [];
          if (currentCard!.cardDetail.attackType == CommandCardAttackType.all) {
            targets.addAll(aliveEnemies);
          } else {
            targets.add(targetedEnemy!);
          }
          damage(this, cardDamage, targets, i + 1, isTypeChain, isMightyChain, firstCardType);

          unsetActivator();
        }

        if (shouldRemoveDeadActors(actions, i)) {
          removeDeadActors();
        }

        currentCard = null;
      }

      checkBuffStatus();
    }

    if (isBraveChain(actions) && targetedEnemy != null) {
      final actor = actions[0].actor;
      currentCard = actor.getExtraCard();
      setActivator(actor);

      final List<BattleServantData> targets = [];
      if (currentCard!.cardDetail.attackType == CommandCardAttackType.all) {
        targets.addAll(aliveEnemies);
      } else {
        targets.add(targetedEnemy!);
      }
      damage(this, cardDamage, targets, 4, isTypeChain, isMightyChain, firstCardType);

      removeDeadActors();

      unsetActivator();
      currentCard = null;
    }

    aliveEnemies.forEach((actor) {
      actor.clearAccumulationDamage();
    });
  }

  void applyTypeChain(CardType cardType, List<CombatAction> actions) {
    if (cardType == CardType.quick) {
      final dataValToUse = isAfter7thAnni ? quickChainAfter7thAnni : quickChainBefore7thAnni;
      gainStar(this, dataValToUse);
    } else if (cardType == CardType.arts) {
      final targets = actions.map((action) => action.actor).toSet();
      gainNP(this, artsChain, targets);
    }
  }

  void removeDeadActors() {
    removeDeadActorsFromList(onFieldAllyServants);
    removeDeadActorsFromList(onFieldEnemies);
    allyTargetIndex = getNonNullTargetIndex(onFieldAllyServants, allyTargetIndex);
    enemyTargetIndex = getNonNullTargetIndex(onFieldEnemies, enemyTargetIndex);
  }

  void removeDeadActorsFromList(List<BattleServantData?> actorList) {
    for (int i = 0; i < actorList.length; i += 1) {
      if (actorList[i] == null) {
        continue;
      }

      final actor = actorList[i]!;
      if (actor.hp <= 0 && !actor.hasNextShift()) {
        if (!actor.activateGuts(this)) {
          actor.death(this);
          actorList[i] = null;
        }
      }
    }
  }

  int getNonNullTargetIndex(List<BattleServantData?> actorList, int targetIndex) {
    if (targetIndex >= actorList.length || actorList[targetIndex] == null) {
      for (int i = 0; i < actorList.length; i += 1) {
        if (actorList[i] != null) {
          return i;
        }
      }
    }
    return 0;
  }

  static bool shouldRemoveDeadActors(List<CombatAction> actions, int index) {
    final action = actions[index];
    if (action.cardData.isNP) {
      return true;
    }

    if (index < actions.length - 1) {
      final nextAction = actions[index + 1];
      return nextAction.cardData.isNP || nextAction.actor != action.actor;
    } else {
      return isBraveChain(actions);
    }
  }

  static bool isBraveChain(List<CombatAction> actions) {
    return actions.length == kMaxCommand && actions.map((action) => action.actor).toSet().length == 1;
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
