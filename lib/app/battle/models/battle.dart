import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/battle/functions/damage.dart';
import 'package:chaldea/app/battle/functions/gain_np.dart';
import 'package:chaldea/app/battle/functions/gain_star.dart';
import 'package:chaldea/app/battle/models/command_card.dart';
import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../functions/function_executor.dart';
import '../interactions/_delegate.dart';
import '../interactions/choose_targets.dart';
import '../interactions/tailored_execution_confirm.dart';
import 'ai.dart';
import 'buff.dart';
import 'skill.dart';
import 'svt_entity.dart';
import 'user.dart';

export 'buff.dart';
export 'skill.dart';
export 'svt_entity.dart';
export 'craft_essence_entity.dart';
export 'card_dmg.dart';
export 'command_card.dart';
export 'user.dart';

class BattleRuntime {
  BattleData battleData;
  Region? region;
  BattleOptions originalOptions;
  QuestPhase originalQuest;

  BattleRuntime({
    required this.battleData,
    required this.region,
    required this.originalOptions,
    required this.originalQuest,
  });

  BattleShareData getShareData({bool allowNotWin = false, bool isCritTeam = false, bool includeReplayData = true}) {
    assert(battleData.isBattleWin || allowNotWin);
    return BattleShareData(
      appBuild: AppInfo.buildNumber,
      quest: BattleQuestInfo.quest(originalQuest),
      formation: originalOptions.formation.toFormationData(),
      delegate: includeReplayData ? battleData.replayDataRecord.copy() : null,
      actions: includeReplayData ? battleData.recorder.toUploadRecords() : null,
      options: originalOptions.toShareData(),
      isCritTeam: isCritTeam,
    );
  }
}

class BattleData {
  static const kValidTotalStarMax = 99;
  static const kValidViewStarMax = 49;
  static const kValidStarMax = 50;

  static const kMaxCommand = 3;
  static const playerOnFieldCount = 3;

  static final DataVals artsChainVals = DataVals({'Rate': 5000, 'Value': 2000});
  static final DataVals quickChainVals = DataVals({'Rate': 5000, 'Value': 20});
  static final DataVals cardDamageVals = DataVals({'Rate': 1000, 'Value': 1000});

  /// Log all action histories, pop/undo/copy should not involve this filed!
  final List<BattleData> snapshots = [];

  /// User action records, should be copied/saved to snapshots
  BattleRecordManager recorder = BattleRecordManager();
  BattleDelegate? delegate;
  BattleReplayDelegateData replayDataRecord = BattleReplayDelegateData();
  BattleOptionsRuntime options = BattleOptionsRuntime();
  final BattleLogger battleLogger = BattleLogger();
  BuildContext? context;

  bool get mounted => context != null && context!.mounted;

  QuestPhase? niceQuest;
  int? get eventId => niceQuest?.war?.eventId;
  Stage? curStage;
  FieldAiManager fieldAi = FieldAiManager();

  int enemyOnFieldCount = 3;
  List<BattleServantData?> backupEnemies = [];
  List<BattleServantData?> backupAllyServants = [];
  List<bool> enemyValidAppear = [];
  List<BattleServantData?> onFieldEnemies = [];
  List<BattleServantData?> onFieldAllyServants = [];
  Map<DeckType, List<QuestEnemy>> enemyDecks = {};
  Map<int, CommandCardData> deadAttackCommandDict = {}; // <uniqueId, card>

  int enemyTargetIndex = 0;
  int playerTargetIndex = 0;

  BattleServantData? get targetedEnemy =>
      onFieldEnemies.length > enemyTargetIndex && enemyTargetIndex >= 0 ? onFieldEnemies[enemyTargetIndex] : null;

  BattleServantData? get targetedPlayer => onFieldAllyServants.length > playerTargetIndex && playerTargetIndex >= 0
      ? onFieldAllyServants[playerTargetIndex]
      : null;

  BattleServantData? getTargetedAlly(final BattleServantData? svt, {bool defaultToPlayer = true}) {
    return svt?.isPlayer ?? defaultToPlayer ? targetedPlayer : targetedEnemy;
  }

  BattleServantData? getTargetedEnemy(final BattleServantData? svt, {bool defaultToPlayer = true}) {
    return svt?.isPlayer ?? defaultToPlayer ? targetedEnemy : targetedPlayer;
  }

  List<BattleServantData> get nonnullEnemies => _getNonnull(onFieldEnemies);

  List<BattleServantData> get nonnullPlayers => _getNonnull(onFieldAllyServants);

  List<BattleServantData> get nonnullActors => [...nonnullEnemies, ...nonnullPlayers];

  List<BattleServantData> get nonnullBackupEnemies => _getNonnull(backupEnemies);

  List<BattleServantData> get nonnullBackupPlayers => _getNonnull(backupAllyServants);

  List<BattleServantData> get nonnullAllActors => [...nonnullActors, ...nonnullBackupEnemies, ...nonnullBackupPlayers];

  BattleServantData? getServantData(int uniqueId, {bool onFieldOnly = false}) {
    final targets = onFieldOnly
        ? [...onFieldAllyServants, ...onFieldEnemies]
        : [...onFieldAllyServants, ...onFieldEnemies, ...backupAllyServants, ...backupEnemies];
    return targets.firstWhereOrNull((e) => e?.uniqueId == uniqueId);
  }

  bool get isWaveCleared => backupEnemies.isEmpty && nonnullEnemies.isEmpty;

  bool get isUseGrandBoard => niceQuest?.extraDetail?.isUseGrandBoard == 1;

  List<BuffData> fieldBuffs = [];
  MysticCode? mysticCode;
  int mysticCodeLv = 10;
  List<BattleSkillInfoData> masterSkillInfo = []; //BattleSkillInfoData

  bool isFirstSkillInTurn = true;

  bool isPlayerTurn = true;
  int waveCount = 0;
  int turnCount = 0;
  int totalTurnCount = 0;

  double criticalStars = 0;
  int _uniqueIndex = 1;
  int _addOrder = 1;
  int cardDealt = 0;
  Set<int> currentCards = {};
  Set<int> remainingCards = {};

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

  // used by checkDuplicate related checks. Map<funcIndex, Map<funcId, Map<uniqueId, function result>>>
  final Map<int, Map<int, Map<int, bool>>> checkDuplicateFuncData = {};
  // representing functions results of a skill, used by triggerPosition checks. List<Map<uniqueId, function result>>,
  List<Map<int, bool>?> get functionResults => _functionResultsStack.last;

  // this is a list of list to prevent mismatch when a function executes another function
  final List<List<Map<int, bool>?>> _functionResultsStack = [];
  final List<Map<int, bool>> _curFuncResults = [];

  void setFuncResult(final int uniqueId, final bool result) {
    _curFuncResults.last[uniqueId] = result;
  }

  bool getCurFuncResult(final int uniqueId) {
    return _curFuncResults.last[uniqueId] ?? false;
  }

  Future<T> withFunctions<T>(final FutureOr<T> Function() onExecute) async {
    final sanityCheck = _functionResultsStack.length;
    final List<Map<int, bool>?> funcsStacks = [];
    try {
      _functionResultsStack.add(funcsStacks);
      return await onExecute();
    } finally {
      StackMismatchException.checkPopStack(_functionResultsStack, funcsStacks, sanityCheck);
      _functionResultsStack.removeLast();
    }
  }

  Future<T> withFunction<T>(final FutureOr<T> Function() onExecute) async {
    final sanityCheckCurFuncResults = _curFuncResults.length;
    final Map<int, bool> funcStacks = {};
    try {
      _curFuncResults.add(funcStacks);
      return await onExecute();
    } finally {
      StackMismatchException.checkPopStack(_curFuncResults, funcStacks, sanityCheckCurFuncResults);
      _curFuncResults.removeLast();
    }
  }

  Future<T> withAction<T>(final FutureOr<T> Function() onExecute) async {
    checkDuplicateFuncData.clear();
    try {
      return await onExecute();
    } finally {
      _useBuffOnce();
      checkActorStatus();
      for (final svt in nonnullActors) {
        await svt.activateBuff(this, BuffAction.functionFieldIndividualityChanged);
        svt.receivedFunctionsList.clear();
      }
    }
  }

  // this is for logging only
  NiceFunction? curFunc;

  void updateLastFuncResults(final int funcId, final int funcIndex) {
    functionResults.add(HashMap<int, bool>.from(_curFuncResults.last));
    if (checkDuplicateFuncData[funcIndex] == null) {
      checkDuplicateFuncData[funcIndex] = {};
    }
    checkDuplicateFuncData[funcIndex]![funcId] = HashMap<int, bool>.from(_curFuncResults.last);
  }

  bool get isBattleWin {
    return waveCount >= Maths.max(niceQuest?.stages.map((e) => e.wave) ?? [], -1) &&
        (curStage == null || (backupEnemies.isEmpty && onFieldEnemies.every((e) => e == null)));
  }

  bool get isBattleFinished => nonnullEnemies.isEmpty || nonnullPlayers.isEmpty;

  Future<void> init(
    final QuestPhase quest,
    final List<PlayerSvtData?> playerSettings,
    final MysticCodeData? mysticCodeData,
  ) async {
    _copyRateUpEnemies(quest);
    niceQuest = quest;
    waveCount = 1;
    turnCount = 0;
    recorder.progressWave(waveCount);
    totalTurnCount = 0;
    criticalStars = 0;

    _functionResultsStack.clear();
    _curFuncResults.clear();

    _uniqueIndex = 1;
    enemyDecks.clear();
    enemyTargetIndex = 0;
    playerTargetIndex = 0;

    fieldBuffs.clear();

    backupAllyServants = List.generate(playerSettings.length, (idx) {
      final svtSetting = playerSettings[idx];
      return svtSetting == null || svtSetting.svt == null
          ? null
          : BattleServantData.fromPlayerSvtData(
              svtSetting,
              getNextUniqueId(),
              startingPosition: idx + 1,
              isUseGrandBoard: isUseGrandBoard,
            );
    });
    await _fetchWaveEnemies();

    final overwriteEquip = quest.extraDetail?.getMergedOverwriteEquipSkills();
    if (overwriteEquip != null && overwriteEquip.skills.isNotEmpty) {
      mysticCode = await overwriteEquip.toMysticCode();
      mysticCodeLv = overwriteEquip.skillLv;
    } else {
      if (mysticCodeData != null && mysticCodeData.enabled) {
        mysticCode = mysticCodeData.mysticCode;
        mysticCodeLv = mysticCodeData.level;
      } else {
        mysticCode = null;
        mysticCodeLv = 10;
      }
    }
    if (mysticCode != null) {
      masterSkillInfo = [
        for (int index = 0; index < mysticCode!.skills.length; index++)
          BattleSkillInfoData(mysticCode!.skills[index], skillNum: index + 1, type: SkillInfoType.masterEquip)
            ..skillLv = mysticCodeLv,
      ];
    }

    for (final actor in backupAllyServants) {
      await actor?.initScript(this);
    }
    await initActorSkills(backupAllyServants);

    onFieldAllyServants = List.filled(playerOnFieldCount, null);
    while (backupAllyServants.isNotEmpty && onFieldAllyServants.contains(null)) {
      final svt = backupAllyServants.removeAt(0);
      final nextIndex = onFieldAllyServants.indexOf(null);
      svt?.deckIndex = nextIndex + 1;
      onFieldAllyServants[nextIndex] = svt;
    }

    onFieldEnemies = List.filled(enemyOnFieldCount, null);
    for (int index = 0; index < backupEnemies.length; index += 1) {
      final enemy = backupEnemies[index];
      if (enemy == null) {
        backupEnemies.removeAt(index);
        index -= 1;
        continue;
      }

      if (enemy.deckIndex <= onFieldEnemies.length) {
        backupEnemies.removeAt(index);
        index -= 1;
        onFieldEnemies[enemy.deckIndex - 1] = enemy;
      }
    }

    updateFieldIndex();
    updateTargetedIndex();

    final enemies = [...onFieldEnemies, ...backupEnemies];
    for (final actor in enemies) {
      await actor?.initScript(this);
    }
    await initActorSkills(enemies);

    // start wave
    await fieldAi.actWaveStart(this);

    for (final svt in nonnullActors) {
      await svt.enterField(this);
    }
    await fieldAi.actWaveStartAnimation(this);

    for (final svt in nonnullActors) {
      await svt.activateBuff(this, BuffAction.functionWavestart);
    }

    for (final svt in nonnullActors) {
      await svt.svtAi.reactionWaveStart(this, svt);
    }

    await _nextTurn();
  }

  void _copyRateUpEnemies(QuestPhase quest) {
    if (!kDebugMode) return;
    if (quest.war?.event == null) return;
    if (options.disableEvent) return;
    for (final stage in quest.stages) {
      stage.enemies.removeWhere((enemy) => enemy.deck == DeckType.enemy && enemy.infoScript.isAddition);
      final initEnemies = stage.enemies.where((e) => e.deck == DeckType.enemy).toList();
      for (final indiv in options.enemyRateUp.toList()..sort()) {
        for (final enemy in initEnemies) {
          if (enemy.traits.contains(indiv)) {
            final enemy2 = QuestEnemy.fromJson(enemy.toJson());
            enemy2.infoScript.source['isAddition'] = 1;
            enemy2.npcId = Maths.max(stage.enemies.map((e) => e.npcId)) + 1;
            int deckId = 1;
            final usedDeckIds = <int>{
              ...stage.enemies.where((e) => e.deck == DeckType.enemy).map((e) => e.deckId),
              ...?stage.NoEntryIds,
            };
            while (usedDeckIds.contains(deckId)) {
              deckId += 1;
            }
            enemy2.deckId = deckId;
            stage.enemies.add(enemy2);
          }
        }
      }
    }
  }

  /// after init or shift, call battleData.initActorSkills to preserve skill order
  Future<void> initActorSkills(final List<BattleServantData?> allActors) async {
    for (final actor in allActors) {
      await actor?.activateClassPassive(this);
      await actor?.activateClassBoard(this);
    }
    for (final actor in allActors) {
      await actor?.activateEquip(this);
    }
    for (final actor in allActors) {
      await actor?.activateExtraPassive(this);
    }
    for (final actor in allActors) {
      await actor?.activateAdditionalPassive(this);
    }
  }

  void refillCardDeck() {
    cardDealt = 0;
    currentCards.clear();
    remainingCards.clear();
    bool hasDoNotSelect = false;
    for (final svt in nonnullPlayers) {
      if (svt.hasBuffNoProbabilityCheck(BuffAction.donotSelectCommandcard)) {
        hasDoNotSelect = true;
        continue;
      }

      remainingCards.addAll(svt.getCards().map((card) => cardDeckIndex(svt, card)));
    }
    cardDealt = 5;
    currentCards.addAll(remainingCards);
    if (hasDoNotSelect) {
      remainingCards.clear();
    }
  }

  int cardDeckIndex(final BattleServantData svt, final CommandCardData card) {
    return svt.fieldIndex * 5 + card.cardIndex;
  }

  bool cardInDeck(final BattleServantData svt, final CommandCardData card) {
    return currentCards.contains(cardDeckIndex(svt, card));
  }

  bool fixCommandCard() {
    for (final svt in nonnullPlayers) {
      if (svt.hasBuffNoProbabilityCheck(BuffAction.fixCommandcard)) {
        return true;
      }
    }
    return false;
  }

  int getNextAddOrder() {
    return _addOrder++;
  }

  int getNextUniqueId() {
    return _uniqueIndex++;
  }

  Future<void> _nextTurn() async {
    await _replenishActors();
    bool addTurn = true;

    if (isWaveCleared) {
      addTurn = await _nextWave();
    }
    if (addTurn) {
      turnCount += 1;
      totalTurnCount += 1;
      recorder.progressTurn(totalTurnCount);
      battleLogger.action('${S.current.battle_turn} $totalTurnCount');
    }

    // start of ally turn
    await withAction(() async {
      for (final svt in nonnullPlayers) {
        await svt.startOfMyTurn(this);
      }

      for (final svt in nonnullActors) {
        await svt.svtAi.reactionTurnStart(this, svt);
      }

      if (!fixCommandCard()) {
        cardDealt += 5;
        currentCards.clear();
        currentCards.addAll(remainingCards);
        if (remainingCards.isEmpty || cardDealt > nonnullPlayers.length * 5) {
          refillCardDeck();
        }

        for (final svt in nonnullPlayers) {
          if (svt.hasBuffNoProbabilityCheck(BuffAction.donotSelectCommandcard)) {
            refillCardDeck();
            break;
          }
        }
      }
    });
  }

  Future<bool> _nextWave() async {
    if (niceQuest?.stages.every((s) => s.wave < waveCount + 1) == true) {
      recorder.messageRich(
        BattleMessageRecord('Battle Win \\(^o^)/', alignment: Alignment.center, style: const TextStyle(fontSize: 20)),
      );
      return false;
    }
    waveCount += 1;
    recorder.progressWave(waveCount);
    turnCount = 0;

    await _fetchWaveEnemies();

    onFieldEnemies = List.filled(enemyOnFieldCount, null);
    for (int index = 0; index < backupEnemies.length; index += 1) {
      final enemy = backupEnemies[index];
      if (enemy == null) {
        backupEnemies.removeAt(index);
        index -= 1;
        continue;
      }

      if (enemy.deckIndex <= onFieldEnemies.length) {
        backupEnemies.removeAt(index);
        index -= 1;
        onFieldEnemies[enemy.deckIndex - 1] = enemy;
      }
    }

    updateFieldIndex();
    updateTargetedIndex();

    final List<BattleServantData?> newEnemies = [...onFieldEnemies, ...backupEnemies];
    for (final actor in newEnemies) {
      await actor?.initScript(this);
    }
    await initActorSkills(newEnemies);

    await fieldAi.actWaveStart(this);

    for (final enemy in nonnullEnemies) {
      await enemy.enterField(this);
    }

    for (final actor in nonnullActors) {
      await actor.activateBuff(this, BuffAction.functionWavestart);
    }
    for (final svt in nonnullActors) {
      await svt.svtAi.reactionWaveStart(this, svt);
    }

    return true;
  }

  Future<void> _replenishActors({final bool replenishAlly = true, final bool replenishEnemy = true}) async {
    final List<BattleServantData> newActors = [];

    if (replenishAlly) {
      for (int index = 0; index < onFieldAllyServants.length; index += 1) {
        if (onFieldAllyServants[index] == null && backupAllyServants.isNotEmpty) {
          BattleServantData? nextSvt;
          while (backupAllyServants.isNotEmpty && nextSvt == null) {
            nextSvt = backupAllyServants.removeAt(0);
          }
          if (nextSvt != null) {
            onFieldAllyServants[index] = nextSvt;
            nextSvt.fieldIndex = index;
            newActors.add(nextSvt);
          }
        }
      }

      playerTargetIndex = getNonNullTargetIndex(onFieldAllyServants, playerTargetIndex, false);
    }

    if (replenishEnemy) {
      final List<int> indices;
      if (curStage?.enemyEntryOrder != null) {
        final indexed = curStage!.enemyEntryOrder!.indexed.toList().sortReturn((a, b) => a.$2.compareTo(b.$2));
        indices = indexed.map((item) => item.$1).toList();
      } else {
        indices = List.generate(onFieldEnemies.length, (idx) => idx);
      }

      for (int index = 0; index < indices.length; index += 1) {
        final fieldIndex = indices[index];
        if (!enemyValidAppear[fieldIndex]) {
          continue;
        }

        if (onFieldEnemies[fieldIndex] == null && backupEnemies.isNotEmpty) {
          BattleServantData? nextSvt;
          while (backupEnemies.isNotEmpty && nextSvt == null) {
            nextSvt = backupEnemies.removeAt(0);
          }
          if (nextSvt != null) {
            onFieldEnemies[fieldIndex] = nextSvt;
            nextSvt.fieldIndex = fieldIndex;
            newActors.add(nextSvt);
          }
        }
      }

      enemyTargetIndex = getNonNullTargetIndex(onFieldEnemies, enemyTargetIndex, true);
    }

    for (final svt in newActors) {
      await svt.enterField(this);
    }
  }

  Future<void> _fetchWaveEnemies() async {
    curStage = niceQuest?.stages.firstWhereOrNull((s) => s.wave == waveCount);
    enemyOnFieldCount = curStage?.enemyFieldPosCount ?? 3;
    backupEnemies = List.filled(enemyOnFieldCount, null, growable: true);
    enemyValidAppear = List.filled(enemyOnFieldCount, true);
    final noEntryIds = curStage?.NoEntryIds;
    if (noEntryIds != null) {
      for (final noEntryDeckIndex in noEntryIds) {
        if (noEntryDeckIndex > 0 && noEntryDeckIndex <= enemyValidAppear.length) {
          enemyValidAppear[noEntryDeckIndex - 1] = false;
        }
      }
    }
    enemyDecks.clear();

    if (curStage != null) {
      for (final enemy in curStage!.enemies) {
        if (enemy.deck == DeckType.enemy) {
          if (enemy.deckId > backupEnemies.length) {
            backupEnemies.length = enemy.deckId;
          }

          final actor = backupEnemies[enemy.deckId - 1] = BattleServantData.fromEnemy(
            enemy,
            getNextUniqueId(),
            niceQuest?.war?.eventId,
          );
          if (options.simulateEnemy) {
            await actor.loadEnemySvtData(this);
          }
        } else {
          enemyDecks.putIfAbsent(enemy.deck, () => []).add(enemy);
          if (enemy.deck.isInShiftDeck && enemy.deck != DeckType.shift) {
            enemyDecks.putIfAbsent(DeckType.shift, () => []).add(enemy);
          }
        }
      }
      fieldAi = FieldAiManager(curStage!.fieldAis);
    } else {
      fieldAi = FieldAiManager();
    }
    if (options.simulateAi) {
      await fieldAi.fetchAiData();
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
    criticalStars = criticalStars.clamp(0, kValidTotalStarMax).toDouble();
  }

  List<int> getQuestIndividuality() {
    final List<int> allTraits = [];
    allTraits.addAll(niceQuest!.questIndividuality);

    final List<int> removeTraitIds = [];
    for (final svt in nonnullActors) {
      for (final buff in svt.battleBuff.validBuffs) {
        if (buff.buff.type == BuffType.fieldIndividuality &&
            buff.shouldActivateBuffNoProbabilityCheck(svt.getTraits())) {
          if ((buff.vals.Value ?? 0) != 0) allTraits.add(buff.vals.Value!);
        } else if (buff.buff.type == BuffType.subFieldIndividuality &&
            buff.shouldActivateBuffNoProbabilityCheck(svt.getTraits())) {
          removeTraitIds.addAll(buff.vals.TargetList!.map((traitId) => traitId));
        }
      }
    }
    allTraits.removeWhere((trait) => removeTraitIds.contains(trait.abs()));

    final List<int> traitsOnField = [];
    // final List<int> removeTraitIdsOnField = [];
    for (final buff in fieldBuffs) {
      if (buff.buff.type == BuffType.toFieldChangeField) {
        traitsOnField.addAll(buff.vals.FieldIndividuality ?? []);
      } else if (buff.buff.type == BuffType.toFieldSubIndividualityField) {
        // TODO: ???
      }
    }
    allTraits.addAll(traitsOnField);
    return allTraits;
  }

  bool isActorOnField(final int actorUniqueId) {
    return nonnullActors.any((svt) => svt.uniqueId == actorUniqueId);
  }

  bool isActorMainTarget(final BattleServantData target) {
    return target.isPlayer
        ? onFieldAllyServants[playerTargetIndex] == target
        : onFieldEnemies[enemyTargetIndex] == target;
  }

  void checkActorStatus() {
    for (final svt in nonnullActors) {
      svt.updateActState(this);
    }

    updateFieldIndex();
  }

  void updateFieldIndex() {
    for (int index = 0; index < onFieldAllyServants.length; index += 1) {
      onFieldAllyServants[index]?.fieldIndex = index;
    }
    for (int index = 0; index < backupAllyServants.length; index += 1) {
      backupAllyServants[index]?.fieldIndex = onFieldAllyServants.length + index;
    }
    for (int index = 0; index < onFieldEnemies.length; index += 1) {
      onFieldEnemies[index]?.fieldIndex = index;
    }
    for (int index = 0; index < backupEnemies.length; index += 1) {
      backupEnemies[index]?.fieldIndex = onFieldEnemies.length + index;
    }
  }

  void _useBuffOnce() {
    for (final svt in [...nonnullActors, ...nonnullBackupPlayers, ...nonnullBackupEnemies]) {
      svt.useBuffOnce();
    }
  }

  bool canSelectNp(final int servantIndex) {
    if (onFieldAllyServants[servantIndex] == null) {
      return false;
    }

    return onFieldAllyServants[servantIndex]!.canSelectNP(this);
  }

  // NOTE: this is different from canSelectNP
  bool canUseNp(final int servantIndex) {
    if (onFieldAllyServants[servantIndex] == null) {
      return false;
    }

    return onFieldAllyServants[servantIndex]!.canNP();
  }

  /// Only check skill sealed
  bool isSkillSealed(final int servantIndex, final int skillIndex) {
    if (onFieldAllyServants[servantIndex] == null) {
      return false;
    }

    return onFieldAllyServants[servantIndex]!.isSkillSealed(skillIndex);
  }

  /// Check canAct and skill script
  bool isSkillCondFailed(final int servantIndex, final int skillIndex) {
    if (onFieldAllyServants[servantIndex] == null) {
      return false;
    }

    return onFieldAllyServants[servantIndex]!.isSkillCondFailed(this, skillIndex);
  }

  bool canUseSvtSkillIgnoreCoolDown(final int servantIndex, final int skillIndex) {
    if (onFieldAllyServants[servantIndex] == null) {
      return false;
    }

    return onFieldAllyServants[servantIndex]!.canUseSkillIgnoreCoolDown(this, skillIndex);
  }

  bool _executing = false;
  bool get isRunning => _executing;
  Future<T?> tryAcquire<T>(Future<T> Function() task) async {
    if (_executing) {
      EasyLoading.showError('Previous task is still running');
      return null;
    }
    _executing = true;
    try {
      return await task();
    } finally {
      _executing = false;
    }
  }

  Future<T?> recordError<T>({required bool save, required String action, required Future<T> Function() task}) async {
    return tryAcquire<T?>(() async {
      bool _saved = false;
      try {
        if (save) {
          pushSnapshot();
          _saved = true;
        }
        for (final actor in nonnullActors) {
          actor.triggeredSkillIds.clear();
        }
        return await task();
      } on BattleCancelException catch (e) {
        final msg = "Cancel Action($action): ${e.msg}";
        battleLogger.action(msg);
        if (e.toast) {
          EasyLoading.showToast(msg);
        }
        if (_saved) popSnapshot();
        return null;
      } catch (e, s) {
        battleLogger.error("Failed: $action");
        logger.e('Battle action failed: $action', e, s);
        logger.i(battleLogger.logs.join("\n"));
        if (mounted) EasyLoading.showError('${S.current.failed}\n\n$e');
        if (save) popSnapshot();
        rethrow;
      } finally {
        for (final actor in nonnullActors) {
          actor.triggeredSkillIds.clear();
        }
      }
    });
  }

  Future<void> _acquireTarget(int? svtIndex, int skillIndex, BattleSkillInfoData? skillInfo) async {
    if (!options.manualAllySkillTarget) return;
    skillInfo ??= svtIndex == null
        ? masterSkillInfo.getOrNull(skillIndex)
        : onFieldAllyServants.getOrNull(svtIndex)?.skillInfoList.getOrNull(skillIndex);
    if (skillInfo == null) return;
    final curSkill = skillInfo.skill;
    if (curSkill == null) return;

    final targetFunc = curSkill.functions.firstWhereOrNull((func) => func.funcTargetType.needNormalOneTarget);
    if (targetFunc != null) {
      final selectedTargets = await ChooseTargetsDialog.show(
        this,
        targetType: targetFunc.funcTargetType,
        targets: nonnullPlayers,
        minCount: 1,
        maxCount: 1,
        autoConfirmOneTarget: true,
      );
      if (selectedTargets != null && selectedTargets.length == 1) {
        final targetIndex = onFieldAllyServants.indexOf(selectedTargets.single);
        if (targetIndex >= 0) {
          playerTargetIndex = targetIndex;
        }
      }
    }
  }

  Future<void> activateSvtSkill(final int servantIndex, final int skillIndex) async {
    final svt = onFieldAllyServants.getOrNull(servantIndex);
    if (svt == null || isBattleFinished) return;

    battleLogger.action(
      '${svt.lBattleName} - ${S.current.active_skill} ${skillIndex + 1}: ${svt.getSkillName(skillIndex)}',
    );
    return recordError(
      save: true,
      action: 'svt_skill-${servantIndex + 1}-${skillIndex + 1}',
      task: () async {
        await withAction(() async {
          await _acquireTarget(servantIndex, skillIndex, null);
          recorder.skillActivation(this, servantIndex, skillIndex);
          await svt.activateSkill(this, skillIndex);
          isFirstSkillInTurn = false;
        });
      },
    );
  }

  bool canUseMysticCodeSkillIgnoreCoolDown(final int skillIndex) {
    if (masterSkillInfo.length <= skillIndex || skillIndex < 0) {
      return false;
    }

    final skill = masterSkillInfo[skillIndex].skill;
    if (skill == null) {
      return true; // enable update
    }

    if (skill.functions.any((func) => func.funcType == FuncType.replaceMember)) {
      return nonnullBackupPlayers.isNotEmpty && nonnullPlayers.where((svt) => svt.canOrderChange()).isNotEmpty;
    }

    return true;
  }

  Future<void> activateMysticCodeSkill(final int skillIndex) async {
    final skillInfo = masterSkillInfo.getOrNull(skillIndex);
    if (skillInfo == null || skillInfo.chargeTurn > 0 || isBattleFinished) {
      return;
    }

    battleLogger.action(
      '${S.current.mystic_code} - ${S.current.active_skill} ${skillIndex + 1}: '
      '${skillInfo.lName}',
    );
    return recordError(
      save: true,
      action: 'mystic_code_skill-${skillIndex + 1}',
      task: () async {
        await withAction(() async {
          await _acquireTarget(null, skillIndex, skillInfo);
          recorder.skillActivation(this, null, skillIndex);
          await skillInfo.activate(this);
          recorder.skill(battleData: this, activator: null, skill: skillInfo, fromPlayer: true, uploadEligible: true);
        });
      },
    );
  }

  Future<void> activateCustomSkill(
    final BattleServantData? actor,
    final BaseSkill skill,
    final int skillLv,
    final bool isAlly,
  ) async {
    await recordError(
      save: true,
      action: 'custom_skill-${skill.id}',
      task: () async {
        await withAction(() async {
          battleLogger.action(
            '${actor == null ? S.current.battle_no_source : actor.lBattleName}'
            ' - ${S.current.skill}: ${skill.lName.l}',
          );
          final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.custom, skillLv: skillLv);
          await skillInfo.activate(this, activator: actor, defaultToPlayer: isAlly);
          recorder.skill(
            battleData: this,
            activator: actor,
            skill: skillInfo,
            fromPlayer: isAlly,
            uploadEligible: false,
          );
        });
      },
    );
  }

  Future<void> playerTurn(final List<CombatAction> actions, {bool allowSkip = false}) async {
    assert(isPlayerTurn);
    if (isBattleFinished) return;
    if (actions.isEmpty && !allowSkip) return;

    return recordError(
      save: true,
      action: 'play_turn-${actions.length} cards',
      task: () async {
        recorder.initiateAttacks(this, actions);
        criticalStars = 0;

        // this would take out cards after they are played
        for (final action in actions) {
          if (!action.cardData.isTD) {
            remainingCards.remove(cardDeckIndex(action.actor, action.cardData));
          }
        }

        final chainType = _decideChainType(actions);
        if (chainType.isBraveChain()) {
          final actor = actions[0].actor;
          final extraCard = actor.getExtraCard();
          if (extraCard != null) actions.add(CombatAction(actor, extraCard));
        }
        for (final action in actions) {
          action.cardData.chainType = chainType;
        }

        final int firstCardType =
            // after 7th Anniversary, invalid first card can provide bonus
            actions.isNotEmpty ? actions.first.cardData.cardType : CardType.blank.value;
        await _applyColorChainFunction(chainType, actions);

        // confirm card selection & set targetNum
        for (final action in actions) {
          await action.confirmCardSelection(this);
        }

        int extraOvercharge = 0;
        for (int i = 0; i < actions.length; i += 1) {
          await withAction(() async {
            if (nonnullEnemies.isNotEmpty) {
              final action = actions[i];
              final actor = action.actor;

              // need to sync card data because the actor might have transformed
              final actualCard = getActualCard(action);
              if (actualCard.isTD) {
                for (final enemy in nonnullEnemies) {
                  enemy.clearReducedHp();
                }
              }

              if (onFieldAllyServants.contains(actor) && action.isValid(this)) {
                recorder.startPlayerCard(actor, actualCard);

                if (actualCard.isTD) {
                  actualCard.np = actor.np;
                  await actor.activateNP(this, actualCard, extraOvercharge);
                  extraOvercharge += 1;
                } else {
                  extraOvercharge = 0;
                  await _executeCommandCard(
                    actor: actor,
                    card: actualCard,
                    chainPos: i + 1,
                    chainType: actualCard.chainType,
                    firstCardType: firstCardType,
                    isPlayer: true,
                    isComboStart: isComboStart(actions, i),
                    isComboEnd: isComboEnd(actions, i),
                  );
                }
                for (final enemy in nonnullEnemies) {
                  if (enemy.attacked) {
                    await enemy.activateBuff(this, BuffAction.functionDamage, opponent: actor, card: actualCard);
                    enemy.attacked = false;
                  }
                }
                recorder.endPlayerCard(actor, actualCard);
              }

              if (shouldRemoveDeadActors(actions, i)) {
                await _removeDeadActors();
              }
            }

            checkActorStatus();
          });
        }

        // end player turn
        await _endPlayerTurn();

        await _startEnemyTurn();
        if (!options.simulateEnemy || nonnullEnemies.isEmpty) {
          await _endEnemyTurn();
          await _nextTurn();
        }

        updateTargetedIndex();
      },
    );
  }

  BattleChainType _decideChainType(List<CombatAction> actions) {
    BattleChainType _decideNoCheckValid(List<CombatAction> _actions) {
      final cardTypesSet = _actions.map((action) => action.cardData.cardType).toSet();
      if (_actions.length != kMaxCommand) return BattleChainType.none;

      return BattleChainType.fromBasicChains(
        artsChain: cardTypesSet.every(CardType.isArts),
        busterChain: cardTypesSet.every(CardType.isBuster),
        quickChain: cardTypesSet.every(CardType.isQuick),
        mightyChain:
            cardTypesSet.any(CardType.isArts) &&
            cardTypesSet.any(CardType.isBuster) &&
            cardTypesSet.any(CardType.isQuick),
        braveChain: _actions.map((action) => action.actor).toSet().length == 1,
      );
    }

    final validActions = actions.where((action) => action.isValid(this)).toList();
    final originalChainType = _decideNoCheckValid(actions);
    final realChainType = _decideNoCheckValid(validActions);
    if (realChainType.isValidChain()) return realChainType;
    if (originalChainType.isValidChain()) return BattleChainType.error;
    return BattleChainType.none;
  }

  static CommandCardData getActualCard(final CombatAction combatAction) {
    final cardData = combatAction.cardData;
    final actor = combatAction.actor;
    CommandCardData outCardData =
        (cardData.isTD
            ? actor.getNPCard()
            : CardType.isExtra(cardData.cardType)
            ? actor.getExtraCard()
            : actor.getCards().getOrNull(cardData.cardIndex)) ??
        cardData;
    outCardData
      ..critical = cardData.critical
      ..chainType = cardData.chainType;
    return outCardData;
  }

  Future<void> activateCounter(BattleServantData svt) async {
    return recordError(
      save: true,
      action: 'counter-function',
      task: () async {
        if (svt.isEnemy) {
          battleLogger.error('Skip Enemy Counter Function');
          return;
        }
        final counterCard = await svt.getCounterCard(this);
        if (counterCard == null) return;
        final action = CombatAction(svt, counterCard);
        if (nonnullEnemies.isEmpty) return;
        await action.confirmCardSelection(this);
        recorder.initiateAttacks(this, [action]);
        await withAction(() async {
          if (!onFieldAllyServants.contains(action.actor) || !action.isValidCounter(this)) return;
          recorder.startPlayerCard(action.actor, action.cardData);
          if (action.cardData.isTD) {
            final td = action.cardData.td!, buff = action.cardData.counterBuff!;
            await FunctionExecutor.executeFunctions(
              this,
              td.functions,
              buff.vals.CounterLv ?? 1,
              script: td.script,
              activator: svt,
              targetedAlly: targetedPlayer,
              targetedEnemy: targetedEnemy,
              card: action.cardData,
              overchargeLvl: buff.vals.CounterOc ?? 1,
            );
          } else {
            await _executeCommandCard(
              actor: action.actor,
              card: action.cardData,
              chainPos: 1,
              chainType: BattleChainType.none,
              firstCardType: CardType.blank.value,
              isComboStart: false,
              isComboEnd: false,
              isPlayer: action.actor.isPlayer,
            );
          }

          for (final enemy in nonnullEnemies) {
            if (enemy.attacked) {
              await enemy.activateBuff(this, BuffAction.functionDamage, opponent: action.actor, card: action.cardData);
              enemy.attacked = false;
            }
          }
          recorder.endPlayerCard(action.actor, action.cardData);
          await _removeDeadActors();
        });

        checkActorStatus();
      },
    );
  }

  Future<void> playEnemyCard(CombatAction action) async {
    assert(!isPlayerTurn);
    if (isBattleFinished) {
      return;
    }

    return recordError(
      save: true,
      action: 'enemy_card-${CardType.getName(action.cardData.cardType)}',
      task: () async {
        await action.confirmCardSelection(this);
        // recorder.initiateAttacks(this, [action]);
        await withAction(() async {
          if (nonnullPlayers.isNotEmpty) {
            if (onFieldEnemies.contains(action.actor) && action.isValid(this)) {
              recorder.startPlayerCard(action.actor, action.cardData);
              if (action.cardData.isTD) {
                for (final svt in nonnullPlayers) {
                  svt.clearReducedHp();
                }
              }

              if (action.cardData.isTD) {
                await action.actor.activateNP(this, action.cardData, 0);
              } else {
                await _executeCommandCard(
                  actor: action.actor,
                  card: action.cardData,
                  chainPos: 1,
                  chainType: BattleChainType.none,
                  firstCardType: CardType.none.value,
                  isPlayer: false,
                  isComboStart: false,
                  isComboEnd: false,
                );
              }

              for (final svt in nonnullPlayers) {
                if (svt.attacked) {
                  await svt.activateBuff(
                    this,
                    BuffAction.functionDamage,
                    opponent: action.actor,
                    card: action.cardData,
                  );
                  svt.attacked = false;
                }
              }
              recorder.endPlayerCard(action.actor, action.cardData);
            }

            if (shouldRemoveDeadActors([action], 0)) {
              await _removeDeadActors();
            }
          }

          checkActorStatus();
        });

        updateTargetedIndex();
      },
    );
  }

  Future<void> endEnemyActions() async {
    assert(!isPlayerTurn);
    // don't skip even no enemy on field. Field AI can do something at this time.
    // if (isBattleFinished) return;
    return recordError(
      save: true,
      action: 'enemy_end',
      task: () async {
        await _endEnemyTurn();
        await _nextTurn();
      },
    );
  }

  Future<void> skipTurn() async {
    if (isPlayerTurn) {
      await playerTurn([], allowSkip: true);
    } else {
      await endEnemyActions();
    }
  }

  Future<void> skipWave() async {
    if (isBattleFinished) {
      return;
    }
    battleLogger.action('${S.current.battle_skip_current_wave} ($waveCount)');
    return recordError(
      save: true,
      action: 'skip-wave-$waveCount',
      task: () async {
        recorder.skipWave(waveCount);

        onFieldEnemies.fillRange(0, onFieldEnemies.length);
        backupEnemies.clear();

        await _endPlayerTurn();

        await _startEnemyTurn();
        await _endEnemyTurn();

        await _nextTurn();
      },
    );
  }

  Future<void> _endPlayerTurn() async {
    await withAction(() async {
      for (final svt in nonnullPlayers) {
        await svt.endOfMyTurn(this);
      }

      for (final svt in nonnullEnemies) {
        await svt.endOfYourTurn(this);
      }

      for (final skill in masterSkillInfo) {
        skill.turnEnd();
      }

      for (final svt in nonnullPlayers) {
        if (svt.hasBuffNoProbabilityCheck(BuffAction.donotSelectCommandcard)) {
          refillCardDeck();
          break;
        }
      }

      await _removeDeadActors();

      for (final buff in fieldBuffs) {
        buff.turnPass();
      }
      fieldBuffs.removeWhere((buff) => buff.checkBuffClear());

      isFirstSkillInTurn = true;
    });
  }

  Future<void> _startEnemyTurn() async {
    isPlayerTurn = false;
    await withAction(() async {
      for (final svt in nonnullEnemies) {
        if (svt.hp <= 0) {
          bool hasGuts = await svt.activateGuts(this);
          if (!hasGuts) {
            await svt.shift(this);
            await initActorSkills([svt]);
            await svt.svtAi.afterTurnPlayerEnd(this, svt);
          }
        }
        await svt.startOfMyTurn(this);
      }
    });
  }

  Future<void> _endEnemyTurn() async {
    await withAction(() async {
      for (final svt in nonnullEnemies) {
        await svt.endOfMyTurn(this);
      }

      for (final svt in nonnullPlayers) {
        await svt.endOfYourTurn(this);
      }

      for (final svt in nonnullPlayers) {
        if (svt.hasBuffNoProbabilityCheck(BuffAction.donotSelectCommandcard)) {
          refillCardDeck();
          break;
        }
      }

      await _removeDeadActors();

      for (final buff in fieldBuffs) {
        buff.turnPass();
      }
      fieldBuffs.removeWhere((buff) => buff.checkBuffClear());
    });
    isFirstSkillInTurn = true;
    isPlayerTurn = true;
  }

  Future<void> _executeCommandCard({
    required BattleServantData actor,
    required CommandCardData card,
    required int chainPos,
    required BattleChainType chainType,
    required int firstCardType,
    required bool isComboStart,
    required bool isComboEnd,
    required bool isPlayer,
  }) async {
    if (isPlayer) {
      await actor.activateCommandCode(this, card.cardIndex);
    }

    await withFunctions(() async {
      await withFunction(() async {
        final List<BattleServantData> targets = [];
        if (card.cardDetail.attackType == CommandCardAttackType.all) {
          targets.addAll(isPlayer ? nonnullEnemies : nonnullPlayers);
        } else {
          targets.add(isPlayer ? targetedEnemy! : targetedPlayer!);
        }

        await Damage.damage(
          this,
          null,
          cardDamageVals,
          actor,
          targets,
          card,
          chainPos: chainPos,
          chainType: chainType,
          firstCardType: firstCardType,
          isComboStart: isComboStart,
          isComboEnd: isComboEnd,
        );
      });
    });

    actor.clearCommandCodeBuffs();
  }

  Future<void> _applyColorChainFunction(BattleChainType chainType, List<CombatAction> actions) async {
    if (!chainType.isSameColorChain()) return;
    battleLogger.action('${chainType.name} Chain');
    await withFunctions(() async {
      await withFunction(() async {
        if (chainType.isQuickChain()) {
          final dataValToUse = quickChainVals;
          GainStar.gainStar(this, dataValToUse, null);
        } else if (chainType.isArtsChain()) {
          final targets = actions.map((action) => action.actor).toSet();
          GainNp.gainNp(this, artsChainVals, targets);
        }
      });
    });
  }

  Future<void> chargeAllyNP() async {
    if (isBattleFinished) {
      return;
    }
    // 宝具充填
    // 出撃中のサーヴァント全員の宝具ゲージを+100％する
    final skill = CommonCustomSkills.chargeAllAlliesNP;

    battleLogger.action(S.current.battle_charge_party);

    return recordError(
      save: true,
      action: S.current.battle_charge_party,
      task: () async {
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.commandSpell);
        await skillInfo.activate(this);
        recorder.skill(battleData: this, activator: null, skill: skillInfo, fromPlayer: true, uploadEligible: false);
      },
    );
  }

  Future<void> commandSpellRepairHp() {
    final skill = CommonCustomSkills.csRepairHp;
    final csRepairHpName = '${S.current.command_spell}: ${Transl.skillNames('霊基修復').l}';

    return recordError(
      save: true,
      action: csRepairHpName,
      task: () async {
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.commandSpell);
        await _acquireTarget(null, -1, skillInfo);
        await skillInfo.activate(this);
        recorder.skill(battleData: this, activator: null, skill: skillInfo, fromPlayer: true, uploadEligible: false);
      },
    );
  }

  Future<void> commandSpellReleaseNP() {
    final skill = CommonCustomSkills.csRepairNp;
    final csReleaseNpName = '${S.current.command_spell}: ${Transl.skillNames('宝具解放').l}';
    battleLogger.action(csReleaseNpName);

    return recordError(
      save: true,
      action: csReleaseNpName,
      task: () async {
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.commandSpell);
        await _acquireTarget(null, -1, skillInfo);
        await skillInfo.activate(this);
        recorder.skill(battleData: this, activator: null, skill: skillInfo, fromPlayer: true, uploadEligible: false);
      },
    );
  }

  Future<void> resetPlayerSkillCD({required bool isMysticCode, required BattleServantData? svt}) async {
    return recordError(
      save: true,
      action: 'resetSkillCD',
      task: () async {
        recorder.reasons.setReplay(S.current.reset_skill_cd);
        if (isMysticCode) {
          for (final skill in masterSkillInfo) {
            skill.chargeTurn = 0;
          }
          recorder.message("${S.current.reset_skill_cd} (${S.current.mystic_code})");
        } else if (svt != null) {
          for (final skill in svt.skillInfoList) {
            skill.chargeTurn = 0;
          }
          recorder.message(S.current.reset_skill_cd, target: svt);
        }
      },
    );
  }

  Future<void> _removeDeadActors() async {
    await _removeDeadActorsFromList(onFieldAllyServants);
    await _removeDeadActorsFromList(onFieldEnemies);
    updateTargetedIndex();

    if (niceQuest != null && niceQuest!.flags.contains(QuestFlag.enemyImmediateAppear)) {
      await _replenishActors(replenishAlly: false);
    }
  }

  Future<void> _removeDeadActorsFromList(final List<BattleServantData?> actorList) async {
    for (int i = 0; i < actorList.length; i += 1) {
      if (actorList[i] == null) {
        continue;
      }

      final actor = actorList[i]!;
      if (actor.hp > 0 || actor.hasNextShift(this)) {
        continue;
      }

      bool hasGuts = false;
      await actor.activateGuts(this).then((value) => hasGuts = value);
      if (!hasGuts) {
        await actor.death(this);

        if (actor.lastHitBy != null) {
          await actor.lastHitBy!.activateBuff(
            this,
            BuffAction.functionDeadattack,
            opponent: actor,
            card: actor.lastHitByCard,
          );
        }
        actorList[i] = null;
        actor.fieldIndex = -1;
      }
    }
  }

  void updateTargetedIndex() {
    playerTargetIndex = getNonNullTargetIndex(onFieldAllyServants, playerTargetIndex, false);
    enemyTargetIndex = getNonNullTargetIndex(onFieldEnemies, enemyTargetIndex, true);
  }

  int getNonNullTargetIndex(List<BattleServantData?> actorList, final int targetIndex, bool isEnemy) {
    if (actorList.length > targetIndex && targetIndex >= 0 && actorList[targetIndex] != null) {
      return targetIndex;
    }
    if (isEnemy && niceQuest?.flags.contains(QuestFlag.enemyImmediateAppear) == true) {
      final minUniqueId = Maths.min(actorList.whereType<BattleServantData>().map((e) => e.uniqueId), -1);
      if (minUniqueId < 0) return -1;
      for (final (index, actor) in actorList.indexed) {
        if (actor?.uniqueId == minUniqueId) {
          return index;
        }
      }
    } else if (isEnemy && curStage?.enemyAutoTargetOrder != null) {
      final targetOrder = curStage!.enemyAutoTargetOrder!;
      final BattleServantData? actor = actorList.fold(null, (prevActor, actor) {
        if (prevActor == null) return actor;
        if (actor == null) return prevActor;

        final prevActorOrder = targetOrder[prevActor.fieldIndex];
        final curActorOrder = targetOrder[actor.fieldIndex];
        return prevActorOrder < curActorOrder ? prevActor : actor;
      });
      if (actor != null) {
        return actor.fieldIndex;
      }
    } else {
      for (final (index, actor) in actorList.indexed) {
        if (actor != null) return index;
      }
    }

    return -1;
  }

  List<BattleServantData> getBuffConditionTargets(BuffConditionTargetType targetType, BattleServantData self) {
    final List<BattleServantData> targets = [];

    final isAlly = self.isPlayer;
    final List<BattleServantData> backupAllies = isAlly ? nonnullBackupPlayers : nonnullBackupEnemies;
    final List<BattleServantData> aliveAllies = isAlly ? nonnullPlayers : nonnullEnemies;

    final List<BattleServantData> backupEnemies = isAlly ? nonnullBackupEnemies : nonnullBackupPlayers;
    final List<BattleServantData> aliveEnemies = isAlly ? nonnullEnemies : nonnullPlayers;
    switch (targetType) {
      case BuffConditionTargetType.none:
        targets.add(self);
        break;
      case BuffConditionTargetType.ptAll:
        targets.addAll(aliveAllies);
        break;
      case BuffConditionTargetType.enemyAll:
        targets.addAll(aliveEnemies);
        break;
      case BuffConditionTargetType.fieldAll:
        targets.addAll(aliveAllies);
        targets.addAll(aliveEnemies);
        break;
      case BuffConditionTargetType.ptFull:
        targets.addAll(aliveAllies);
        targets.addAll(backupAllies);
        break;
      case BuffConditionTargetType.enemyFull:
        targets.addAll(aliveEnemies);
        targets.addAll(backupEnemies);
        break;
      case BuffConditionTargetType.ptOtherAll:
        targets.addAll(aliveAllies);
        targets.remove(self);
        break;
      case BuffConditionTargetType.ptOtherFull:
        targets.addAll(aliveAllies);
        targets.addAll(backupAllies);
        targets.remove(self);
        break;
      case BuffConditionTargetType.fieldOtherAll:
        targets.addAll(aliveAllies);
        targets.addAll(aliveEnemies);
        targets.remove(self);
        break;
    }

    return targets;
  }

  static bool shouldRemoveDeadActors(final List<CombatAction> actions, final int index) {
    final currentAction = actions[index];
    final currentActualCard = getActualCard(currentAction);
    if (currentActualCard.isTD ||
        currentActualCard.cardDetail.attackType == CommandCardAttackType.all ||
        index == actions.length - 1) {
      return true;
    }

    final nextAction = actions[index + 1];
    final nextActualCard = getActualCard(nextAction);
    return nextActualCard.isTD ||
        nextActualCard.cardDetail.attackType == CommandCardAttackType.all ||
        nextAction.actor != currentAction.actor;
  }

  static bool isNormalCard(final CombatAction action) {
    final card = getActualCard(action);

    return !card.isTD && card.cardDetail.attackType != CommandCardAttackType.all;
  }

  static bool isComboStart(final List<CombatAction> actions, final int index) {
    // previousAction check
    final previousAction = actions.getOrNull(index - 1);
    final currentAction = actions[index];
    if (previousAction != null) {
      if (isNormalCard(previousAction) && previousAction.actor == currentAction.actor) {
        return false;
      }
    }

    // currentAction check
    final nextAction = actions.getOrNull(index + 1);
    if (!isNormalCard(currentAction) || nextAction == null) {
      return false;
    }

    // nextAction check
    return isNormalCard(nextAction) && nextAction.actor == currentAction.actor;
  }

  static bool isComboEnd(final List<CombatAction> actions, final int index) {
    // previousAction check
    final previousAction = actions.getOrNull(index - 1);
    final currentAction = actions[index];
    if (previousAction == null || !isNormalCard(previousAction) || previousAction.actor != currentAction.actor) {
      return false;
    }

    // currentAction check
    if (!isNormalCard(currentAction)) {
      return false;
    }

    // nextAction check
    final nextAction = actions.getOrNull(index + 1);
    return nextAction == null || !isNormalCard(nextAction) || nextAction.actor != currentAction.actor;
  }

  Future<bool> canActivate(final int activationRate, final String description) async {
    if (activationRate <= 0) {
      return false;
    }

    final curResult = options.threshold <= activationRate;

    if (activationRate < 1000 && options.tailoredExecution) {
      if (delegate?.canActivate != null) {
        return await delegate!.canActivate!.call(curResult);
      } else if (mounted) {
        final curResultString = curResult ? S.current.success : S.current.failed;
        final String details =
            '${S.current.results}: $curResultString => '
            '${S.current.battle_activate_probability}: '
            '${(activationRate / 10).toStringAsFixed(1)}% '
            'vs ${S.current.probability_expectation}: '
            '${(options.threshold / 10).toStringAsFixed(1)}%';
        final result = await TailoredExecutionConfirm.show(
          context: context!,
          description: description,
          details: details,
        );
        replayDataRecord.canActivateDecisions.add(result);
        return result;
      }
    }

    return curResult;
  }

  Future<bool> canActivateFunction(final int activationRate) async {
    final String funcString;
    if (curFunc != null && mounted) {
      final function = curFunc!;
      final fieldTraitString = function.funcquestTvals.isNotEmpty
          ? ' - ${S.current.battle_require_field_traits} ${function.funcquestTvals.map(Transl.traitName).toList()}'
          : '';
      final targetTraitString = function.functvals.isNotEmpty
          ? ' - ${S.current.battle_require_opponent_traits} ${function.functvals.map(Transl.traitName).toList()}'
          : '';
      funcString =
          '${function.lPopupText.l}'
          '$fieldTraitString'
          '$targetTraitString';
    } else {
      funcString = '';
    }
    return await canActivate(activationRate, funcString);
  }

  void pushSnapshot() {
    final BattleData copy = BattleData()
      ..niceQuest = niceQuest
      ..curStage = curStage
      ..fieldAi = fieldAi
      ..enemyOnFieldCount = enemyOnFieldCount
      ..enemyValidAppear = enemyValidAppear.toList()
      ..backupEnemies = backupEnemies.map((e) => e?.copy()).toList()
      ..backupAllyServants = backupAllyServants.map((e) => e?.copy()).toList()
      ..onFieldEnemies = onFieldEnemies.map((e) => e?.copy()).toList()
      ..onFieldAllyServants = onFieldAllyServants.map((e) => e?.copy()).toList()
      ..enemyDecks = enemyDecks
      ..enemyTargetIndex = enemyTargetIndex
      ..playerTargetIndex = playerTargetIndex
      ..fieldBuffs = fieldBuffs.map((e) => e.copy()).toList()
      ..mysticCode = mysticCode
      ..mysticCodeLv = mysticCodeLv
      ..masterSkillInfo = masterSkillInfo.map((e) => e.copy()).toList()
      ..isFirstSkillInTurn = isFirstSkillInTurn
      ..isPlayerTurn = isPlayerTurn
      ..waveCount = waveCount
      ..turnCount = turnCount
      ..totalTurnCount = totalTurnCount
      ..criticalStars = criticalStars
      .._uniqueIndex = _uniqueIndex
      ..cardDealt = cardDealt
      ..currentCards = currentCards.toSet()
      ..remainingCards = remainingCards.toSet()
      ..options = options.copy()
      ..recorder = recorder.copy()
      ..replayDataRecord = replayDataRecord.copy()
      ..deadAttackCommandDict = deadAttackCommandDict.map((key, value) => MapEntry(key, value.copy()));

    snapshots.add(copy);
  }

  void popSnapshot() {
    if (snapshots.isEmpty) return;

    battleLogger.action(S.current.battle_undo);
    final BattleData copy = snapshots.removeLast();
    this
      ..niceQuest = copy.niceQuest
      ..curStage = copy.curStage
      ..fieldAi = copy.fieldAi
      ..enemyOnFieldCount = copy.enemyOnFieldCount
      ..enemyValidAppear = copy.enemyValidAppear
      ..backupEnemies = copy.backupEnemies
      ..backupAllyServants = copy.backupAllyServants
      ..onFieldEnemies = copy.onFieldEnemies
      ..onFieldAllyServants = copy.onFieldAllyServants
      ..enemyDecks = copy.enemyDecks
      ..enemyTargetIndex = copy.enemyTargetIndex
      ..playerTargetIndex = copy.playerTargetIndex
      ..fieldBuffs = copy.fieldBuffs
      ..mysticCode = copy.mysticCode
      ..mysticCodeLv = copy.mysticCodeLv
      ..masterSkillInfo = copy.masterSkillInfo
      ..isFirstSkillInTurn = copy.isFirstSkillInTurn
      ..isPlayerTurn = copy.isPlayerTurn
      ..waveCount = copy.waveCount
      ..turnCount = copy.turnCount
      ..totalTurnCount = copy.totalTurnCount
      ..criticalStars = copy.criticalStars
      .._uniqueIndex = copy._uniqueIndex
      ..cardDealt = copy.cardDealt
      ..currentCards = copy.currentCards
      ..remainingCards = copy.remainingCards
      ..options = copy.options
      ..recorder = copy.recorder
      ..replayDataRecord = copy.replayDataRecord
      ..deadAttackCommandDict = copy.deadAttackCommandDict.map((key, value) => MapEntry(key, value.copy()));
  }
}

class StackMismatchException implements Exception {
  final String message;
  StackMismatchException([this.message = '']);

  @override
  String toString() {
    return 'StackMismatchException: $message';
  }

  static T checkPopStack<T>(List<T> stack, T last, int lengthAfterPop) {
    if (stack.isEmpty) {
      throw StackMismatchException("Stack is empty but going to pop $last");
    }
    final lastInStack = stack.last;
    if (lastInStack != last) {
      throw StackMismatchException("Stack last member mismatch: ${stack.lastOrNull}(last in stack)!=$last");
    }
    if (stack.length - 1 != lengthAfterPop) {
      throw StackMismatchException("Stack length mismatch: ${stack.length}-1 != $lengthAfterPop");
    }
    return lastInStack;
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
