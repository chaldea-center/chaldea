import 'package:chaldea/app/battle/functions/damage.dart';
import 'package:chaldea/app/battle/functions/gain_np.dart';
import 'package:chaldea/app/battle/functions/gain_star.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/battle/models/command_card.dart';
import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
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

  int enemyOnFieldCount = 3;
  List<BattleServantData?> enemyDataList = [];
  List<BattleServantData?> playerDataList = [];
  List<BattleServantData?> onFieldEnemies = [];
  List<BattleServantData?> onFieldAllyServants = [];
  Map<DeckType, List<QuestEnemy>> enemyDecks = {};

  int enemyTargetIndex = 0;
  int allyTargetIndex = 0;

  BattleServantData? get targetedEnemy =>
      onFieldEnemies.length > enemyTargetIndex ? onFieldEnemies[enemyTargetIndex] : null;

  BattleServantData? get targetedAlly =>
      onFieldAllyServants.length > allyTargetIndex ? onFieldAllyServants[allyTargetIndex] : null;

  List<BattleServantData> get nonnullEnemies => _getNonnull(onFieldEnemies);

  List<BattleServantData> get nonnullAllies => _getNonnull(onFieldAllyServants);

  List<BattleServantData> get nonnullActors => [...nonnullAllies, ...nonnullEnemies];

  List<BattleServantData> get nonnullBackupEnemies => _getNonnull(enemyDataList);

  List<BattleServantData> get nonnullBackupAllies => _getNonnull(playerDataList);

  bool get isBattleFinished => nonnullEnemies.isEmpty || nonnullAllies.isEmpty;
  List<BuffData> fieldBuffs = [];
  MysticCode? mysticCode;
  int mysticCodeLv = 10;
  List<BattleSkillInfoData> masterSkillInfo = []; //BattleSkillInfoData

  int waveCount = 0;
  int turnCount = 1;
  int totalTurnCount = 0;

  double criticalStars = 0;
  int uniqueIndex = 1;

  int fixedRandom = ConstData.constants.attackRateRandomMin;
  int probabilityThreshold = 1000;
  bool isAfter7thAnni = true;

  final BattleLogger logger = BattleLogger();

  // unused fields
  // int countEnemyAttack = 0;
  // List<int> playerEntryIds = [-1, -1, -1]; // unique id
  // List<int> enemyEntryIds = [-1, -1, -1]; // unique id
  // BattleData? data;
  // BattleInfoData battleInfo;
  // QuestEntity questEnt;
  // QuestPhaseEntity questPhaseEnt;

  // List<BattleSkillInfoData> boostSkillInfo;
  // List fieldDataList = []; //BattleFieldData

  // List<int> questIndividuality = [];

  // int limitTurnCount = 0;
  // int limitAct = 0;
  // List<int> turnEffect = [];
  // int turnEffectType = 0;
  // int globalTargetId = -1;
  // int lockTargetId = -1;
  // ComboData comboData;
  // List commandCodeInfos = []; //CommandCodeInfo

  // int addCriticalStars = 0;
  // int subCriticalCount = 0;
  // int prevCriticalStars = 0;
  // bool isCalcCritical = true;
  // List<DataVals>performedValsList=[];

  // int lastActId = 0;
  // int prevTargetId = 0;

  bool previousFunctionResult = true;
  CommandCardData? currentCard;
  final List<BuffData?> _currentBuff = [];
  final List<BattleServantData> _activator = [];
  final List<BattleServantData> _target = [];

  void setCurrentBuff(final BuffData buff) {
    _currentBuff.add(buff);
  }

  BuffData? get currentBuff => _currentBuff.isNotEmpty ? _currentBuff.last : null;

  void unsetCurrentBuff() {
    _currentBuff.removeLast();
  }

  void setActivator(final BattleServantData svt) {
    _activator.add(svt);
  }

  BattleServantData? get activator => _activator.isNotEmpty ? _activator.last : null;

  void unsetActivator() {
    _activator.removeLast();
  }

  void setTarget(final BattleServantData svt) {
    _target.add(svt);
  }

  BattleServantData? get target => _target.isNotEmpty ? _target.last : null;

  void unsetTarget() {
    _target.removeLast();
  }

  void init(final QuestPhase quest, final List<PlayerSvtData?> playerSettings, final MysticCodeData? mysticCodeData) {
    niceQuest = quest;
    waveCount = 1;
    turnCount = 0;
    totalTurnCount = 0;
    criticalStars = 0;

    previousFunctionResult = true;
    uniqueIndex = 1;
    fixedRandom = ConstData.constants.attackRateRandomMin;
    probabilityThreshold = 1000;
    isAfter7thAnni = true;
    enemyDecks.clear();
    enemyTargetIndex = 0;
    allyTargetIndex = 0;

    onFieldAllyServants.clear();
    onFieldEnemies.clear();
    playerDataList = playerSettings
        .map((svtSetting) =>
            svtSetting == null || svtSetting.svt == null ? null : BattleServantData.fromPlayerSvtData(svtSetting))
        .toList();
    _fetchWaveEnemies();

    playerDataList.forEach((svt) {
      svt?.init(this);
      svt?.uniqueId = uniqueIndex;
      uniqueIndex += 1;
    });
    enemyDataList.forEach((enemy) {
      enemy?.init(this);
      enemy?.uniqueId = uniqueIndex;
      uniqueIndex += 1;
    });

    mysticCode = mysticCodeData?.mysticCode;
    mysticCodeLv = mysticCodeData?.level ?? 10;
    if (mysticCode != null) {
      masterSkillInfo = mysticCode!.skills.map((skill) => BattleSkillInfoData(skill)..skillLv = mysticCodeLv).toList();
    }

    _initOnField(playerDataList, onFieldAllyServants, playerOnFieldCount);
    _initOnField(enemyDataList, onFieldEnemies, enemyOnFieldCount);
    allyTargetIndex = getNonNullTargetIndex(onFieldAllyServants, allyTargetIndex);
    enemyTargetIndex = getNonNullTargetIndex(onFieldEnemies, enemyTargetIndex);

    nonnullActors.forEach((element) {
      element.enterField(this);
    });

    nextTurn();
  }

  void nextTurn() {
    turnCount += 1;
    totalTurnCount += 1;

    logger.action('Turn $totalTurnCount start');

    replenishActors();

    if (enemyDataList.isEmpty && nonnullEnemies.isEmpty) {
      nextWave();
    }
    // start of ally turn
    nonnullAllies.forEach((svt) {
      svt.startOfMyTurn(this);
    });
  }

  void nextWave() {
    waveCount += 1;
    turnCount = 1;

    _fetchWaveEnemies();
    enemyDataList.forEach((enemy) {
      enemy?.init(this);
      enemy?.uniqueId = uniqueIndex;
      uniqueIndex += 1;
    });

    onFieldEnemies.clear();
    _initOnField(enemyDataList, onFieldEnemies, enemyOnFieldCount);
    enemyTargetIndex = getNonNullTargetIndex(onFieldEnemies, enemyTargetIndex);

    nonnullEnemies.forEach((element) {
      element.enterField(this);
    });
  }

  void replenishActors() {
    final List<BattleServantData> newActors = [
      ..._populateListAndReturnNewActors(onFieldEnemies, enemyDataList),
      ..._populateListAndReturnNewActors(onFieldAllyServants, playerDataList)
    ];

    newActors.forEach((actor) {
      actor.enterField(this);
    });
  }

  static List<BattleServantData> _populateListAndReturnNewActors(
    final List<BattleServantData?> toList,
    final List<BattleServantData?> fromList,
  ) {
    final List<BattleServantData> newActors = [];
    for (int i = 0; i < toList.length; i += 1) {
      if (toList[i] == null && fromList.isNotEmpty) {
        BattleServantData? nextEnemy;
        while (fromList.isNotEmpty && nextEnemy == null) {
          nextEnemy = fromList.removeAt(0);
        }
        if (nextEnemy != null) {
          toList[i] = nextEnemy;
          newActors.add(nextEnemy);
        }
      }
    }
    return newActors;
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
          enemyDecks[enemy.deck]!.add(enemy);
        }
      }
    }
  }

  void _initOnField(
    final List<BattleServantData?> dataList,
    final List<BattleServantData?> onFieldList,
    final int maxCount,
  ) {
    while (dataList.isNotEmpty && onFieldList.length < maxCount) {
      final svt = dataList.removeAt(0);
      svt?.deckIndex = onFieldList.length + 1;
      onFieldList.add(svt);
    }
  }

  List<BattleServantData> _getNonnull(final List<BattleServantData?> list) {
    List<BattleServantData> results = [];
    for (final nullableSvt in list) {
      if (nullableSvt != null) {
        results.add(nullableSvt);
      }
    }
    return results;
  }

  void changeStar(final num change) {
    criticalStars += change;
    criticalStars.clamp(0, kValidTotalStarMax);
  }

  List<NiceTrait> getFieldTraits() {
    // TODO (battle): account for add & remove field traits
    return niceQuest?.individuality ?? [];
  }

  bool checkTargetTraits(final Iterable<NiceTrait> requiredTraits, {final int? checkIndivType}) {
    if (requiredTraits.isEmpty) {
      return true;
    }

    final List<NiceTrait> currentTraits = [];
    currentTraits.addAll(target?.getTraits() ?? []);
    currentTraits.addAll(currentBuff?.traits ?? []);
    currentTraits.addAll(currentCard?.traits ?? []);

    if (checkIndivType == 1 || checkIndivType == 3) {
      return containsAllTraits(currentTraits, requiredTraits);
    } else {
      return containsAnyTraits(currentTraits, requiredTraits);
    }
  }

  bool checkActivatorTraits(final Iterable<NiceTrait> requiredTraits, {final int? checkIndivType}) {
    if (requiredTraits.isEmpty) {
      return true;
    }

    final List<NiceTrait> currentTraits = [];
    currentTraits.addAll(activator?.getTraits() ?? []);
    currentTraits.addAll(currentBuff?.traits ?? []);
    currentTraits.addAll(currentCard?.traits ?? []);

    if (checkIndivType == 1 || checkIndivType == 3) {
      return containsAllTraits(currentTraits, requiredTraits);
    } else {
      return containsAnyTraits(currentTraits, requiredTraits);
    }
  }

  bool isActorOnField(final int actorUniqueId) {
    return nonnullAllies.any((svt) => svt.uniqueId == actorUniqueId) ||
        nonnullEnemies.any((svt) => svt.uniqueId == actorUniqueId);
  }

  void checkBuffStatus() {
    nonnullActors.forEach((svt) {
      svt.checkBuffStatus();
    });
  }

  bool canUseNp(final int servantIndex) {
    if (onFieldAllyServants[servantIndex] == null) {
      return false;
    }

    return onFieldAllyServants[servantIndex]!.canNP(this);
  }

  bool canUseSkill(final int servantIndex, final int skillIndex) {
    if (onFieldAllyServants[servantIndex] == null) {
      return false;
    }

    return onFieldAllyServants[servantIndex]!.canActivateSkill(this, skillIndex);
  }

  void activateSvtSkill(final int servantIndex, final int skillIndex) {
    if (onFieldAllyServants[servantIndex] == null || isBattleFinished) {
      return;
    }

    final svt = onFieldAllyServants[servantIndex]!;
    logger.action('Activate ${svt.lBattleName} (Pos ${servantIndex + 1}) skill ${skillIndex + 1}: '
        '${svt.getSkillName(skillIndex)}');
    copy();
    svt.activateSkill(this, skillIndex);
  }

  bool canUseMysticCodeSkill(final int skillIndex) {
    if (masterSkillInfo.length <= skillIndex) {
      return false;
    }

    // TODO (battle): condition checking
    return masterSkillInfo[skillIndex].canActivate;
  }

  void activateMysticCodeSKill(final int skillIndex) {
    if (masterSkillInfo.length <= skillIndex || isBattleFinished) {
      return;
    }

    logger.action('Activate master skill ${skillIndex + 1}: ${masterSkillInfo[skillIndex].skill.lName.l}');
    copy();
    masterSkillInfo[skillIndex].activate(this);
  }

  void playerTurn(final List<CombatAction> actions) {
    if (actions.isEmpty || isBattleFinished) {
      return;
    }

    copy();
    criticalStars = 0;

    // assumption: only Quick, Arts, and Buster are ever listed as viable actions
    final cardTypesSet = actions.map((action) => action.cardData.cardType).toSet();
    final isTypeChain = actions.length == 3 && cardTypesSet.length == 1;
    final isMightyChain = cardTypesSet.length == 3 && isAfter7thAnni;
    final CardType firstCardType = actions[0].cardData.cardType;
    if (isTypeChain) {
      applyTypeChain(firstCardType, actions);
    }

    final previousTargetIndex = allyTargetIndex;
    int extraOvercharge = 0;
    for (int i = 0; i < actions.length; i += 1) {
      if (nonnullEnemies.isNotEmpty) {
        final action = actions[i];
        currentCard = action.cardData;
        allyTargetIndex = onFieldAllyServants.indexOf(action.actor); // help damageFunction identify attacker

        if (currentCard!.isNP && action.actor.canNP(this)) {
          action.actor.activateBuffOnActions(this, [BuffAction.functionAttackBefore, BuffAction.functionNpattack]);
          action.actor.activateNP(this, extraOvercharge);
          extraOvercharge += 1;

          nonnullEnemies.forEach((svt) {
            if (svt.attacked) svt.activateBuffOnAction(this, BuffAction.functionDamage);
          });
        } else if (!currentCard!.isNP && action.actor.canCommandCard(this)) {
          extraOvercharge = 0;
          executePlayerCard(action.actor, currentCard!, i + 1, isTypeChain, isMightyChain, firstCardType);
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

      executePlayerCard(actor, currentCard!, 4, isTypeChain, isMightyChain, firstCardType);

      currentCard = null;

      removeDeadActors();
      checkBuffStatus();
    }

    // end player turn
    endPlayerTurn();

    startEnemyTurn();
    endEnemyTurn();

    nextTurn();

    allyTargetIndex = previousTargetIndex;
  }

  void skipWave() {
    if (isBattleFinished) {
      return;
    }

    logger.action('Skip current wave ($waveCount)');
    copy();

    onFieldEnemies.clear();
    enemyDataList.clear();

    endPlayerTurn();

    startEnemyTurn();
    endEnemyTurn();

    nextTurn();
  }

  void endPlayerTurn() {
    nonnullAllies.forEach((svt) {
      svt.endOfMyTurn(this);
    });

    nonnullEnemies.forEach((svt) {
      svt.endOfYourTurn(this);
    });

    masterSkillInfo.forEach((skill) {
      skill.turnEnd();
    });

    removeDeadActors();
  }

  void startEnemyTurn() {
    nonnullEnemies.forEach((svt) {
      if (svt.hp <= 0) {
        svt.shift(this);
      }
      svt.startOfMyTurn(this);
    });
  }

  void endEnemyTurn() {
    nonnullEnemies.forEach((svt) {
      svt.endOfMyTurn(this);
    });

    nonnullAllies.forEach((svt) {
      svt.endOfYourTurn(this);
    });

    removeDeadActors();
  }

  void executePlayerCard(
    final BattleServantData actor,
    final CommandCardData card,
    final int chainPos,
    final bool isTypeChain,
    final bool isMightyChain,
    final CardType firstCardType,
  ) {
    actor.activateBuffOnActions(
        this,
        [
          BuffAction.functionAttackBefore,
          BuffAction.functionCommandattackBefore,
          BuffAction.functionCommandcodeattack,
        ],
        card.commandCodeBuffs);

    setActivator(actor);

    final List<BattleServantData> targets = [];
    if (card.cardDetail.attackType == CommandCardAttackType.all) {
      targets.addAll(nonnullEnemies);
    } else {
      targets.add(targetedEnemy!);
    }
    Damage.damage(this, cardDamage, targets, chainPos, isTypeChain, isMightyChain, firstCardType);

    unsetActivator();

    actor.activateBuffOnActions(
        this,
        [
          BuffAction.functionAttack,
          BuffAction.functionCommandattack,
          BuffAction.functionCommandcodeattackAfter,
        ],
        card.commandCodeBuffs);

    targets.forEach((svt) {
      svt.activateBuffOnAction(this, BuffAction.functionDamage);
    });
  }

  void applyTypeChain(final CardType cardType, final List<CombatAction> actions) {
    if (cardType == CardType.quick) {
      final dataValToUse = isAfter7thAnni ? quickChainAfter7thAnni : quickChainBefore7thAnni;
      GainStar.gainStar(this, dataValToUse);
    } else if (cardType == CardType.arts) {
      final targets = actions.map((action) => action.actor).toSet();
      GainNP.gainNP(this, artsChain, targets);
    }
  }

  void chargeAllyNP() {
    if (isBattleFinished) {
      return;
    }

    logger.action('CUSTOM ACTION: charge 100% NP for all allies');
    copy();

    GainNP.gainNP(this, DataVals({'Rate': 5000, 'Value': 10000}), nonnullAllies);
  }

  void removeDeadActors() {
    removeDeadActorsFromList(onFieldAllyServants);
    removeDeadActorsFromList(onFieldEnemies);
    allyTargetIndex = getNonNullTargetIndex(onFieldAllyServants, allyTargetIndex);
    enemyTargetIndex = getNonNullTargetIndex(onFieldEnemies, enemyTargetIndex);
  }

  void removeDeadActorsFromList(final List<BattleServantData?> actorList) {
    for (int i = 0; i < actorList.length; i += 1) {
      if (actorList[i] == null) {
        continue;
      }

      final actor = actorList[i]!;
      if (actor.hp <= 0 && !actor.hasNextShift()) {
        if (!actor.activateGuts(this)) {
          // TODO (battle): There is a bug that will reset accumulation damage when deathEffect is triggered
          // not verified for gutsEffect
          actor.death(this);
          actorList[i] = null;
        }
      }
    }
  }

  int getNonNullTargetIndex(final List<BattleServantData?> actorList, final int targetIndex) {
    if (actorList.length > targetIndex && actorList[targetIndex] != null) {
      return targetIndex;
    }

    for (int i = 0; i < actorList.length; i += 1) {
      if (actorList[i] != null) {
        return i;
      }
    }
    return 0;
  }

  static bool shouldRemoveDeadActors(final List<CombatAction> actions, final int index) {
    final action = actions[index];
    if (action.cardData.isNP) {
      return true;
    }

    if (index < actions.length - 1) {
      final nextAction = actions[index + 1];
      return nextAction.cardData.isNP || nextAction.actor != action.actor;
    } else {
      return !isBraveChain(actions);
    }
  }

  static bool isBraveChain(final List<CombatAction> actions) {
    return actions.length == kMaxCommand && actions.map((action) => action.actor).toSet().length == 1;
  }

  final List<BattleData> copies = [];

  void copy() {
    final BattleData copy = BattleData()
    ..niceQuest = niceQuest
    ..curStage = curStage
    ..enemyOnFieldCount = enemyOnFieldCount
    ..enemyDataList = enemyDataList.map((e) => e?.copy()).toList()
    ..playerDataList = playerDataList.map((e) => e?.copy()).toList()
    ..onFieldEnemies = onFieldEnemies.map((e) => e?.copy()).toList()
    ..onFieldAllyServants = onFieldAllyServants.map((e) => e?.copy()).toList()
    ..enemyDecks = enemyDecks
    ..enemyTargetIndex = enemyTargetIndex
    ..allyTargetIndex = allyTargetIndex
    ..fieldBuffs = fieldBuffs.map((e) => e.copy()).toList()
    ..mysticCode = mysticCode
    ..mysticCodeLv = mysticCodeLv
    ..masterSkillInfo = masterSkillInfo.map((e) => e.copy()).toList()
    ..waveCount = waveCount
    ..turnCount = turnCount
    ..totalTurnCount = totalTurnCount
    ..criticalStars = criticalStars
    ..uniqueIndex = uniqueIndex
    ..fixedRandom = fixedRandom
    ..probabilityThreshold = probabilityThreshold
    ..isAfter7thAnni = isAfter7thAnni;

    copies.add(copy);
  }

  void undo() {
    if (copies.isEmpty) {
      return;
    }

    logger.action('Undo previous action');
    final BattleData copy = copies.removeLast();
    this
      ..niceQuest = copy.niceQuest
      ..curStage = copy.curStage
      ..enemyOnFieldCount = copy.enemyOnFieldCount
      ..enemyDataList = copy.enemyDataList
      ..playerDataList = copy.playerDataList
      ..onFieldEnemies = copy.onFieldEnemies
      ..onFieldAllyServants = copy.onFieldAllyServants
      ..enemyDecks = copy.enemyDecks
      ..enemyTargetIndex = copy.enemyTargetIndex
      ..allyTargetIndex = copy.allyTargetIndex
      ..fieldBuffs = copy.fieldBuffs
      ..mysticCode = copy.mysticCode
      ..mysticCodeLv = copy.mysticCodeLv
      ..masterSkillInfo = copy.masterSkillInfo
      ..waveCount = copy.waveCount
      ..turnCount = copy.turnCount
      ..totalTurnCount = copy.totalTurnCount
      ..criticalStars = copy.criticalStars
      ..uniqueIndex = copy.uniqueIndex
      ..fixedRandom = copy.fixedRandom
      ..probabilityThreshold = copy.probabilityThreshold
      ..isAfter7thAnni = copy.isAfter7thAnni;
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
