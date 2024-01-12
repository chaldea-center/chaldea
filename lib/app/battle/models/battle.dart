import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/battle/functions/damage.dart';
import 'package:chaldea/app/battle/functions/gain_np.dart';
import 'package:chaldea/app/battle/functions/gain_star.dart';
import 'package:chaldea/app/battle/models/command_card.dart';
import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
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
  List<BattleServantData?> enemyDataList = [];
  List<BattleServantData?> playerDataList = [];
  List<bool> enemyValidAppear = [];
  List<BattleServantData?> onFieldEnemies = [];
  List<BattleServantData?> onFieldAllyServants = [];
  Map<DeckType, List<QuestEnemy>> enemyDecks = {};

  int enemyTargetIndex = 0;
  int playerTargetIndex = 0;

  BattleServantData? get targetedEnemy =>
      onFieldEnemies.length > enemyTargetIndex && enemyTargetIndex >= 0 ? onFieldEnemies[enemyTargetIndex] : null;

  BattleServantData? get targetedPlayer => onFieldAllyServants.length > playerTargetIndex && playerTargetIndex >= 0
      ? onFieldAllyServants[playerTargetIndex]
      : null;

  List<BattleServantData> get nonnullEnemies => _getNonnull(onFieldEnemies);

  List<BattleServantData> get nonnullPlayers => _getNonnull(onFieldAllyServants);

  List<BattleServantData> get nonnullActors => [...nonnullEnemies, ...nonnullPlayers];

  List<BattleServantData> get nonnullBackupEnemies => _getNonnull(enemyDataList);

  List<BattleServantData> get nonnullBackupPlayers => _getNonnull(playerDataList);

  BattleServantData? getServantData(int uniqueId, {bool onFieldOnly = false}) {
    final targets = onFieldOnly
        ? [...onFieldAllyServants, ...onFieldEnemies]
        : [...onFieldAllyServants, ...onFieldEnemies, ...playerDataList, ...enemyDataList];
    return targets.firstWhereOrNull((e) => e?.uniqueId == uniqueId);
  }

  bool get isWaveCleared => enemyDataList.isEmpty && nonnullEnemies.isEmpty;

  List<BuffData> fieldBuffs = [];
  MysticCode? mysticCode;
  int mysticCodeLv = 10;
  List<BattleSkillInfoData> masterSkillInfo = []; //BattleSkillInfoData

  bool isPlayerTurn = true;
  int waveCount = 0;
  int turnCount = 0;
  int totalTurnCount = 0;

  double criticalStars = 0;
  int _uniqueIndex = 1;

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

  final Map<int, int> damageHistory = {}; // uniqueId to uniqueId
  final Map<int, Map<int, bool>> actionHistory = {};
  // should not be read, as this represent a build-in-progress svtUniqueId to funcResult map for the current function
  Map<int, bool> get curFuncResults => _curFuncResults.last;
  List<Map<int, bool>?> get uniqueIdToFuncResultsList => _uniqueIdToFuncResultsList.last;

  final List<Map<int, bool>> _curFuncResults = [];
  final List<List<Map<int, bool>?>> _uniqueIdToFuncResultsList = [];

  Future<T> withFunctions<T>(final FutureOr<T> Function() onExecute) async {
    final sanityCheck = _uniqueIdToFuncResultsList.length;
    final List<Map<int, bool>?> funcsStacks = [];
    try {
      _uniqueIdToFuncResultsList.add(funcsStacks);
      return await onExecute();
    } finally {
      StackMismatchException.checkPopStack(_uniqueIdToFuncResultsList, funcsStacks, sanityCheck);
      _uniqueIdToFuncResultsList.removeLast();
    }
  }

  Future<T> withFunction<T>(final FutureOr<T> Function() onExecute) async {
    final sanityCheck = _curFuncResults.length;
    final Map<int, bool> funcStacks = {};
    try {
      _curFuncResults.add(funcStacks);
      return await onExecute();
    } finally {
      StackMismatchException.checkPopStack(_curFuncResults, funcStacks, sanityCheck);
      _curFuncResults.removeLast();
    }
  }

  Future<T> withAction<T>(final FutureOr<T> Function() onExecute) async {
    actionHistory.clear();
    try {
      return await onExecute();
    } finally {
      _useBuffOnce();
    }
  }

  final List<CommandCardData?> _currentCard = [];
  final List<BuffData?> _currentBuff = [];
  final List<BattleServantData?> _activator = [];
  final List<BattleServantData?> _target = [];

  // this is for logging only
  NiceFunction? curFunc;

  void updateLastFuncResults(final int funcId) {
    uniqueIdToFuncResultsList.add(HashMap<int, bool>.from(curFuncResults));
    actionHistory[funcId] = HashMap<int, bool>.from(curFuncResults);
  }

  BuffData? get currentBuff => _currentBuff.isNotEmpty ? _currentBuff.last : null;

  Future<T> withBuff<T>(final BuffData? buff, final FutureOr<T> Function() onExecute) async {
    final sanityCheck = _currentBuff.length;
    try {
      _currentBuff.add(buff);
      return await onExecute();
    } finally {
      StackMismatchException.checkPopStack(_currentBuff, buff, sanityCheck);
      _currentBuff.removeLast();
    }
  }

  T withBuffSync<T>(final BuffData? buff, final T Function() onExecute) {
    final sanityCheck = _currentBuff.length;
    try {
      _currentBuff.add(buff);
      return onExecute();
    } finally {
      StackMismatchException.checkPopStack(_currentBuff, buff, sanityCheck);
      _currentBuff.removeLast();
    }
  }

  CommandCardData? get currentCard => _currentCard.isNotEmpty ? _currentCard.last : null;

  Future<T> withCard<T>(final CommandCardData? card, final FutureOr<T> Function() onExecute) async {
    final sanityCheck = _currentCard.length;
    try {
      _currentCard.add(card);
      return await onExecute();
    } finally {
      StackMismatchException.checkPopStack(_currentCard, card, sanityCheck);
      _currentCard.removeLast();
    }
  }

  T withCardSync<T>(final CommandCardData? card, final T Function() onExecute) {
    final sanityCheck = _currentCard.length;
    try {
      _currentCard.add(card);
      return onExecute();
    } finally {
      StackMismatchException.checkPopStack(_currentCard, card, sanityCheck);
      _currentCard.removeLast();
    }
  }

  BattleServantData? get activator => _activator.isNotEmpty ? _activator.last : null;

  Future<T> withActivator<T>(final BattleServantData? activator, final FutureOr<T> Function() onExecute) async {
    final sanityCheck = _activator.length;
    try {
      _activator.add(activator);
      return await onExecute();
    } finally {
      StackMismatchException.checkPopStack(_activator, activator, sanityCheck);
      _activator.removeLast();
    }
  }

  T withActivatorSync<T>(final BattleServantData? activator, final T Function() onExecute) {
    final sanityCheck = _activator.length;
    try {
      _activator.add(activator);
      return onExecute();
    } finally {
      StackMismatchException.checkPopStack(_activator, activator, sanityCheck);
      _activator.removeLast();
    }
  }

  BattleServantData? get target => _target.isNotEmpty ? _target.last : null;

  Future<T> withTarget<T>(final BattleServantData? target, final FutureOr<T> Function() onExecute) async {
    final sanityCheck = _target.length;
    try {
      _target.add(target);
      return await onExecute();
    } finally {
      StackMismatchException.checkPopStack(_target, target, sanityCheck);
      _target.removeLast();
    }
  }

  T withTargetSync<T>(final BattleServantData? target, final T Function() onExecute) {
    final sanityCheck = _target.length;
    try {
      _target.add(target);
      return onExecute();
    } finally {
      StackMismatchException.checkPopStack(_target, target, sanityCheck);
      _target.removeLast();
    }
  }

  BattleServantData? getOpponent(final BattleServantData self) {
    return target == self ? activator : target;
  }

  bool get isBattleWin {
    return waveCount >= Maths.max(niceQuest?.stages.map((e) => e.wave) ?? [], -1) &&
        (curStage == null || (enemyDataList.isEmpty && onFieldEnemies.every((e) => e == null)));
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

    _uniqueIdToFuncResultsList.clear();
    _curFuncResults.clear();
    _currentCard.clear();
    _currentBuff.clear();
    _activator.clear();
    _target.clear();

    _uniqueIndex = 1;
    enemyDecks.clear();
    enemyTargetIndex = 0;
    playerTargetIndex = 0;

    fieldBuffs.clear();

    playerDataList = playerSettings
        .map((svtSetting) => svtSetting == null || svtSetting.svt == null
            ? null
            : BattleServantData.fromPlayerSvtData(svtSetting, getNextUniqueId()))
        .toList();
    await _fetchWaveEnemies();

    final overwriteEquip = quest.extraDetail?.overwriteEquipSkills;
    if (overwriteEquip != null && overwriteEquip.skillIds.isNotEmpty) {
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

    onFieldAllyServants = List.filled(playerOnFieldCount, null);
    while (playerDataList.isNotEmpty && onFieldAllyServants.contains(null)) {
      final svt = playerDataList.removeAt(0);
      final nextIndex = onFieldAllyServants.indexOf(null);
      svt?.deckIndex = nextIndex + 1;
      onFieldAllyServants[nextIndex] = svt;
    }

    onFieldEnemies = List.filled(enemyOnFieldCount, null);
    for (int index = 0; index < enemyDataList.length; index += 1) {
      final enemy = enemyDataList[index];
      if (enemy == null) {
        enemyDataList.removeAt(index);
        index -= 1;
        continue;
      }

      if (enemy.deckIndex <= onFieldEnemies.length) {
        enemyDataList.removeAt(index);
        index -= 1;
        onFieldEnemies[enemy.deckIndex - 1] = enemy;
      }
    }

    _updateTargetedIndex();

    final List<BattleServantData?> allActors = [
      ...onFieldEnemies,
      ...enemyDataList,
      ...onFieldAllyServants,
      ...playerDataList,
    ];

    for (final actor in allActors) {
      await actor?.initScript(this);
    }
    await initActorSkills(allActors);

    // start wave
    await fieldAi.actWaveStart(this);

    for (final svt in nonnullActors) {
      await svt.enterField(this);
    }

    for (final svt in nonnullActors) {
      await svt.activateBuffOnAction(this, BuffAction.functionWavestart);
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
          if (enemy.traits.any((e) => e.id == indiv)) {
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
    });
    for (final svt in nonnullActors) {
      await svt.svtAi.reactionTurnStart(this, svt);
    }
  }

  Future<bool> _nextWave() async {
    if (niceQuest?.stages.every((s) => s.wave < waveCount + 1) == true) {
      recorder.messageRich(BattleMessageRecord('Battle Win \\(^o^)/',
          alignment: Alignment.center, style: const TextStyle(fontSize: 20)));
      return false;
    }
    waveCount += 1;
    recorder.progressWave(waveCount);
    turnCount = 0;

    await _fetchWaveEnemies();

    onFieldEnemies = List.filled(enemyOnFieldCount, null);
    for (int index = 0; index < enemyDataList.length; index += 1) {
      final enemy = enemyDataList[index];
      if (enemy == null) {
        enemyDataList.removeAt(index);
        index -= 1;
        continue;
      }

      if (enemy.deckIndex <= onFieldEnemies.length) {
        enemyDataList.removeAt(index);
        index -= 1;
        onFieldEnemies[enemy.deckIndex - 1] = enemy;
      }
    }

    _updateTargetedIndex();

    final List<BattleServantData?> newEnemies = [...onFieldEnemies, ...enemyDataList];
    for (final actor in newEnemies) {
      await actor?.initScript(this);
    }
    await initActorSkills(newEnemies);

    await fieldAi.actWaveStart(this);

    for (final enemy in nonnullEnemies) {
      await enemy.enterField(this);
    }

    for (final actor in nonnullActors) {
      await actor.activateBuffOnAction(this, BuffAction.functionWavestart);
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
        if (onFieldAllyServants[index] == null && playerDataList.isNotEmpty) {
          BattleServantData? nextSvt;
          while (playerDataList.isNotEmpty && nextSvt == null) {
            nextSvt = playerDataList.removeAt(0);
          }
          if (nextSvt != null) {
            onFieldAllyServants[index] = nextSvt;
            newActors.add(nextSvt);
          }
        }
      }

      playerTargetIndex = getNonNullTargetIndex(onFieldAllyServants, playerTargetIndex);
    }

    if (replenishEnemy) {
      for (int index = 0; index < onFieldEnemies.length; index += 1) {
        if (!enemyValidAppear[index]) {
          continue;
        }

        if (onFieldEnemies[index] == null && enemyDataList.isNotEmpty) {
          BattleServantData? nextSvt;
          while (enemyDataList.isNotEmpty && nextSvt == null) {
            nextSvt = enemyDataList.removeAt(0);
          }
          if (nextSvt != null) {
            onFieldEnemies[index] = nextSvt;
            newActors.add(nextSvt);
          }
        }
      }

      enemyTargetIndex = getNonNullTargetIndex(onFieldEnemies, enemyTargetIndex);
    }

    for (final svt in newActors) {
      await svt.enterField(this);
    }
  }

  Future<void> _fetchWaveEnemies() async {
    curStage = niceQuest?.stages.firstWhereOrNull((s) => s.wave == waveCount);
    enemyOnFieldCount = curStage?.enemyFieldPosCount ?? 3;
    enemyDataList = List.filled(enemyOnFieldCount, null, growable: true);
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
          if (enemy.deckId > enemyDataList.length) {
            enemyDataList.length = enemy.deckId;
          }

          final actor = enemyDataList[enemy.deckId - 1] = BattleServantData.fromEnemy(enemy, getNextUniqueId());
          if (options.simulateEnemy) {
            await actor.loadEnemySvtData(this);
          }
        } else {
          if (!enemyDecks.containsKey(enemy.deck)) {
            enemyDecks[enemy.deck] = [];
          }
          enemyDecks[enemy.deck]!.add(enemy);
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

  List<NiceTrait> getFieldTraits() {
    final List<NiceTrait> allTraits = [];
    allTraits.addAll(niceQuest!.individuality);

    final List<int> removeTraitIds = [];
    for (final svt in nonnullActors) {
      for (final buff in svt.battleBuff.validBuffs) {
        if (buff.buff.type == BuffType.fieldIndividuality && buff.shouldApplyBuff(this, svt)) {
          allTraits.add(NiceTrait(id: buff.vals.Value ?? 0));
        } else if (buff.buff.type == BuffType.subFieldIndividuality && buff.shouldApplyBuff(this, svt)) {
          removeTraitIds.addAll(buff.vals.TargetList!.map((traitId) => traitId));
        }
      }
    }
    allTraits.removeWhere((trait) => removeTraitIds.contains(trait.id));

    final List<NiceTrait> traitsOnField = [];
    // final List<int> removeTraitIdsOnField = [];
    for (final buff in fieldBuffs) {
      if (buff.buff.type == BuffType.toFieldChangeField) {
        traitsOnField.addAll((buff.vals.FieldIndividuality ?? []).map((e) => NiceTrait(id: e)));
      } else if (buff.buff.type == BuffType.toFieldSubIndividualityField) {
        //
      }
    }
    allTraits.addAll(traitsOnField);
    return allTraits;
  }

  bool checkTraits(final CheckTraitParameters params) {
    if (params.requiredTraits.isEmpty) {
      return true;
    }

    final List<NiceTrait> currentTraits = [];

    final actor = params.actor;
    if (actor != null) {
      if (params.checkActorTraits) {
        currentTraits.addAll(actor.getTraits(this));
      }

      if (params.checkActorBuffTraits) {
        currentTraits.addAll(actor.getBuffTraits(
          this,
          activeOnly: params.checkActiveBuffOnly,
          ignoreIrremovable: params.ignoreIrremovableBuff,
        ));
      }

      if (params.checkActorNpTraits) {
        final currentNp = actor.getNPCard();
        if (currentNp != null) {
          currentTraits.addAll(currentNp.traits);
        }
      }
    }

    if (params.checkCurrentBuffTraits && currentBuff != null) {
      if (!params.ignoreIrremovableBuff || !currentBuff!.irremovable) {
        currentTraits.addAll(currentBuff!.traits);
      }
    }

    if (params.checkCurrentCardTraits && currentCard != null) {
      currentTraits.addAll(currentCard!.traits);
      if (currentCard!.critical) {
        currentTraits.add(NiceTrait(id: Trait.criticalHit.id));
      }
    }

    if (params.checkQuestTraits) {
      currentTraits.addAll(getFieldTraits());
    }

    if (params.requireAtLeast != null) {
      return countAnyTraits(currentTraits, params.requiredTraits) >= params.requireAtLeast!;
    } else {
      return checkTraitFunction(
        currentTraits,
        params.requiredTraits,
        params.positiveMatchFunction,
        params.negativeMatchFunction,
      );
    }
  }

  bool isActorOnField(final int actorUniqueId) {
    return nonnullActors.any((svt) => svt.uniqueId == actorUniqueId);
  }

  void checkActorStatus() {
    for (final svt in nonnullActors) {
      svt.updateActState(this);
    }

    for (int index = 0; index < onFieldAllyServants.length; index += 1) {
      onFieldAllyServants[index]?.fieldIndex = index;
    }
    for (int index = 0; index < playerDataList.length; index += 1) {
      playerDataList[index]?.fieldIndex = onFieldAllyServants.length + index;
    }
    for (int index = 0; index < onFieldEnemies.length; index += 1) {
      onFieldEnemies[index]?.fieldIndex = index;
    }
    for (int index = 0; index < enemyDataList.length; index += 1) {
      enemyDataList[index]?.fieldIndex = onFieldEnemies.length + index;
    }
  }

  void _useBuffOnce() {
    for (final svt in nonnullActors) {
      svt.useBuffOnce(this);
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

  Future<T?> recordError<T>({
    required bool save,
    required String action,
    required Future<T> Function() task,
  }) async {
    return tryAcquire<T?>(() async {
      bool _saved = false;
      try {
        if (save) {
          pushSnapshot();
          _saved = true;
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
      }
    });
  }

  Future<void> _acquireTarget(int? svtIndex, int skillIndex, BattleSkillInfoData? skillInfo) async {
    if (!options.manualAllySkillTarget) return;
    skillInfo ??= svtIndex == null
        ? masterSkillInfo.getOrNull(skillIndex)
        : onFieldAllyServants.getOrNull(svtIndex)?.skillInfoList.getOrNull(skillIndex);
    if (skillInfo == null) return;
    final curSkill = await skillInfo.getSkill();
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

    battleLogger
        .action('${svt.lBattleName} - ${S.current.active_skill} ${skillIndex + 1}: ${svt.getSkillName(skillIndex)}');
    return recordError(
      save: true,
      action: 'svt_skill-${servantIndex + 1}-${skillIndex + 1}',
      task: () async {
        await withAction(() async {
          await _acquireTarget(servantIndex, skillIndex, null);
          recorder.skillActivation(this, servantIndex, skillIndex);
          await svt.activateSkill(this, skillIndex);
        });
      },
    );
  }

  bool canUseMysticCodeSkillIgnoreCoolDown(final int skillIndex) {
    if (masterSkillInfo.length <= skillIndex || skillIndex < 0) {
      return false;
    }

    final skill = masterSkillInfo[skillIndex].proximateSkill;
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

    battleLogger.action('${S.current.mystic_code} - ${S.current.active_skill} ${skillIndex + 1}: '
        '${skillInfo.lName}');
    return recordError(
      save: true,
      action: 'mystic_code_skill-${skillIndex + 1}',
      task: () async {
        await withAction(() async {
          await _acquireTarget(null, skillIndex, skillInfo);
          recorder.skillActivation(this, null, skillIndex);
          await withActivator(null, () => skillInfo.activate(this));
          recorder.skill(
            battleData: this,
            activator: null,
            skill: skillInfo,
            fromPlayer: true,
            uploadEligible: true,
          );
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
          await withActivator(actor, () async {
            battleLogger.action('${actor == null ? S.current.battle_no_source : actor.lBattleName}'
                ' - ${S.current.skill}: ${skill.lName.l}');
            final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.custom, skillLv: skillLv);
            await skillInfo.activate(this, defaultToPlayer: isAlly);
            recorder.skill(
              battleData: this,
              activator: activator,
              skill: skillInfo,
              fromPlayer: isAlly,
              uploadEligible: false,
            );
          });
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

        // assumption: only Quick, Arts, and Buster are ever listed as viable actions
        final validActions = actions.where((action) => action.isValid(this)).toList();
        final cardTypesSet = validActions.map((action) => action.cardData.cardType).toSet();
        final isTypeChain = validActions.length == 3 && cardTypesSet.length == 1;
        final isMightyChain = cardTypesSet.length == 3 && options.mightyChain;
        final isBraveChain =
            validActions.length == kMaxCommand && validActions.map((action) => action.actor).toSet().length == 1;
        if (isBraveChain) {
          final actor = actions[0].actor;
          final extraCard = actor.getExtraCard();
          if (extraCard != null) actions.add(CombatAction(actor, extraCard));
        }

        final CardType firstCardType = actions.isEmpty
            ? CardType.blank
            : options.mightyChain || actions[0].isValid(this)
                ? actions[0].cardData.cardType
                : CardType.blank;
        if (isTypeChain) {
          await _applyTypeChain(firstCardType, actions);
        }
        int extraOvercharge = 0;
        for (int i = 0; i < actions.length; i += 1) {
          await withAction(() async {
            if (nonnullEnemies.isNotEmpty) {
              final action = actions[i];
              await withCard(action.cardData, () async {
                if (onFieldAllyServants.contains(action.actor) && action.isValid(this)) {
                  recorder.startPlayerCard(action.actor, action.cardData);

                  if (action.cardData.isTD) {
                    action.cardData.np = action.actor.np;
                    await action.actor.activateNP(this, action.cardData, extraOvercharge);
                    extraOvercharge += 1;
                  } else {
                    extraOvercharge = 0;
                    await _executeCommandCard(
                      actor: action.actor,
                      card: action.cardData,
                      chainPos: i + 1,
                      isTypeChain: isTypeChain,
                      isMightyChain: isMightyChain,
                      firstCardType: firstCardType,
                      isPlayer: true,
                    );
                  }
                  for (final enemy in nonnullEnemies) {
                    if (enemy.attacked) {
                      await withTarget(action.actor, () async {
                        await enemy.activateBuffOnAction(this, BuffAction.functionDamage);
                      });
                      enemy.attacked = false;
                    }
                  }
                  recorder.endPlayerCard(action.actor, action.cardData);
                }

                if (shouldRemoveDeadActors(actions, i)) {
                  await _removeDeadActors();
                }
              });
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

        _updateTargetedIndex();
      },
    );
  }

  Future<void> activateCounter(BattleServantData svt) async {
    return recordError(
      save: true,
      action: 'counter-td',
      task: () async {
        if (svt.isEnemy) {
          battleLogger.error('Skip Enemy Counter NP');
          return;
        }
        final tdCard = await svt.getCounterNPCard(this);
        if (tdCard == null) return;
        final action = CombatAction(svt, tdCard);
        if (nonnullEnemies.isEmpty) return;
        recorder.initiateAttacks(this, [action]);
        await withAction(() async {
          await withActivator(svt, () async {
            await withCard(action.cardData, () async {
              if (!onFieldAllyServants.contains(action.actor) || action.isValid(this)) return;
              recorder.startPlayerCard(action.actor, action.cardData);
              final td = action.cardData.td!, buff = action.cardData.counterBuff!;
              await FunctionExecutor.executeFunctions(this, td.functions, buff.vals.CounterLv ?? 1,
                  script: td.script, overchargeLvl: buff.vals.CounterOc ?? 1);

              for (final enemy in nonnullEnemies) {
                if (enemy.attacked) {
                  await withTarget(action.actor, () async {
                    await enemy.activateBuffOnAction(this, BuffAction.functionDamage);
                  });
                  enemy.attacked = false;
                }
              }
              recorder.endPlayerCard(action.actor, action.cardData);
              await _removeDeadActors();
            });

            checkActorStatus();
          });
        });
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
      action: 'enemy_card-${action.cardData.cardType.name}',
      task: () async {
        // recorder.initiateAttacks(this, [action]);
        await withAction(() async {
          if (nonnullPlayers.isNotEmpty) {
            await withCard(action.cardData, () async {
              if (onFieldEnemies.contains(action.actor) && action.isValid(this)) {
                recorder.startPlayerCard(action.actor, action.cardData);

                if (action.cardData.isTD) {
                  await action.actor.activateNP(this, action.cardData, 0);
                } else {
                  await _executeCommandCard(
                    actor: action.actor,
                    card: action.cardData,
                    chainPos: 1,
                    isTypeChain: false,
                    isMightyChain: false,
                    firstCardType: CardType.none,
                    isPlayer: false,
                  );
                }

                for (final svt in nonnullPlayers) {
                  if (svt.attacked) {
                    await withTarget(action.actor, () async {
                      await svt.activateBuffOnAction(this, BuffAction.functionDamage);
                    });
                    svt.attacked = false;
                  }
                }
                recorder.endPlayerCard(action.actor, action.cardData);
              }

              if (shouldRemoveDeadActors([action], 0)) {
                await _removeDeadActors();
              }
            });
          }

          checkActorStatus();
        });

        _updateTargetedIndex();
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
        enemyDataList.clear();

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

      await _removeDeadActors();

      for (final buff in fieldBuffs) {
        buff.turnPass();
      }
      fieldBuffs.removeWhere((buff) => buff.checkBuffClear());
    });
  }

  Future<void> _startEnemyTurn() async {
    isPlayerTurn = false;
    await withAction(() async {
      for (final svt in nonnullEnemies) {
        if (svt.hp <= 0) {
          await svt.shift(this);
          await initActorSkills([svt]);
          await svt.svtAi.afterTurnPlayerEnd(this, svt);
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

      await _removeDeadActors();

      for (final buff in fieldBuffs) {
        buff.turnPass();
      }
      fieldBuffs.removeWhere((buff) => buff.checkBuffClear());
    });
    isPlayerTurn = true;
  }

  Future<void> _executeCommandCard({
    required BattleServantData actor,
    required CommandCardData card,
    required int chainPos,
    required bool isTypeChain,
    required bool isMightyChain,
    required CardType firstCardType,
    required bool isPlayer,
  }) async {
    if (isPlayer) {
      await actor.activateCommandCode(this, card.cardIndex);
    }

    await withFunctions(() async {
      await withFunction(() async {
        final List<BattleServantData> targets = [];
        await withActivator(actor, () async {
          if (card.cardDetail.attackType == CommandCardAttackType.all) {
            targets.addAll(isPlayer ? nonnullEnemies : nonnullPlayers);
          } else {
            targets.add(isPlayer ? targetedEnemy! : targetedPlayer!);
          }

          await Damage.damage(
            this,
            null,
            cardDamage,
            targets,
            chainPos: chainPos,
            isTypeChain: isTypeChain,
            isMightyChain: isMightyChain,
            firstCardType: firstCardType,
          );
        });
      });
    });

    actor.clearCommandCodeBuffs();
  }

  Future<void> _applyTypeChain(final CardType cardType, final List<CombatAction> actions) async {
    battleLogger.action('${cardType.name} Chain');
    await withFunctions(() async {
      await withFunction(() async {
        if (cardType == CardType.quick) {
          final dataValToUse = options.mightyChain ? quickChainAfter7thAnni : quickChainBefore7thAnni;
          GainStar.gainStar(this, dataValToUse);
        } else if (cardType == CardType.arts) {
          final targets = actions.map((action) => action.actor).toSet();
          GainNP.gainNP(this, artsChain, targets);
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
        await withActivator(null, () => skillInfo.activate(this));
        recorder.skill(
          battleData: this,
          activator: null,
          skill: skillInfo,
          fromPlayer: true,
          uploadEligible: false,
        );
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
        await withActivator(null, () => skillInfo.activate(this));
        recorder.skill(
          battleData: this,
          activator: null,
          skill: skillInfo,
          fromPlayer: true,
          uploadEligible: false,
        );
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
        await withActivator(null, () => skillInfo.activate(this));
        recorder.skill(
          battleData: this,
          activator: null,
          skill: skillInfo,
          fromPlayer: true,
          uploadEligible: false,
        );
      },
    );
  }

  Future<void> resetPlayerSkillCD({required bool isMysticCode, required BattleServantData? svt}) async {
    return recordError(
      save: true,
      action: 'resetSkillCD',
      task: () async {
        recorder.setIllegal(S.current.reset_skill_cd);
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
    damageHistory.clear();
    _updateTargetedIndex();

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
      if (actor.hp <= 0) {
        bool hasGuts = false;
        await actor.activateGuts(this).then((value) => hasGuts = value);
        if (!hasGuts && !actor.hasNextShift(this)) {
          await actor.death(this);

          final lastAttackerUniqueId = damageHistory[actor.uniqueId];
          if (lastAttackerUniqueId != null) {
            final killer = getServantData(lastAttackerUniqueId);
            if (killer != null) {
              await withTarget(actor, () async {
                await killer.activateBuffOnAction(this, BuffAction.functionDeadattack);
              });
            }
          }
          actorList[i] = null;
          actor.fieldIndex = -1;
          if (actor.isPlayer) {
            for (final svt in nonnullPlayers) {
              svt.battleBuff.removeBuffWithTrait(NiceTrait(id: Trait.buffLockCardsDeck.id));
            }
          }
        }
      }
    }
  }

  void _updateTargetedIndex() {
    playerTargetIndex = getNonNullTargetIndex(onFieldAllyServants, playerTargetIndex);
    enemyTargetIndex = getNonNullTargetIndex(onFieldEnemies, enemyTargetIndex);
  }

  int getNonNullTargetIndex(final List<BattleServantData?> actorList, final int targetIndex) {
    if (actorList.length > targetIndex && targetIndex >= 0 && actorList[targetIndex] != null) {
      return targetIndex;
    }

    for (int i = 0; i < actorList.length; i += 1) {
      if (actorList[i] != null) {
        return i;
      }
    }
    return -1;
  }

  bool shouldRemoveDeadActors(final List<CombatAction> actions, final int index) {
    final action = actions[index];
    if (action.cardData.isTD ||
        action.cardData.cardDetail.attackType == CommandCardAttackType.all ||
        index == actions.length - 1) {
      return true;
    }

    final nextAction = actions[index + 1];
    return nextAction.cardData.isTD ||
        nextAction.cardData.cardDetail.attackType == CommandCardAttackType.all ||
        nextAction.actor != action.actor;
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
        final String details = '${S.current.results}: $curResultString => '
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
          ? ' - ${S.current.battle_require_field_traits} ${function.funcquestTvals.map((e) => e.shownName()).toList()}'
          : '';
      final targetTraitString = function.functvals.isNotEmpty
          ? ' - ${S.current.battle_require_opponent_traits} ${function.functvals.map((e) => e.shownName()).toList()}'
          : '';
      final targetString = target != null ? ' vs ${target!.lBattleName}' : '';
      funcString = '${activator?.lBattleName ?? S.current.battle_no_source} - '
          '${function.lPopupText.l}'
          '$fieldTraitString'
          '$targetTraitString'
          '$targetString';
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
      ..enemyDataList = enemyDataList.map((e) => e?.copy()).toList()
      ..playerDataList = playerDataList.map((e) => e?.copy()).toList()
      ..onFieldEnemies = onFieldEnemies.map((e) => e?.copy()).toList()
      ..onFieldAllyServants = onFieldAllyServants.map((e) => e?.copy()).toList()
      ..enemyDecks = enemyDecks
      ..enemyTargetIndex = enemyTargetIndex
      ..playerTargetIndex = playerTargetIndex
      ..fieldBuffs = fieldBuffs.map((e) => e.copy()).toList()
      ..mysticCode = mysticCode
      ..mysticCodeLv = mysticCodeLv
      ..masterSkillInfo = masterSkillInfo.map((e) => e.copy()).toList()
      ..isPlayerTurn = isPlayerTurn
      ..waveCount = waveCount
      ..turnCount = turnCount
      ..totalTurnCount = totalTurnCount
      ..criticalStars = criticalStars
      .._uniqueIndex = _uniqueIndex
      ..options = options.copy()
      ..recorder = recorder.copy()
      ..replayDataRecord = replayDataRecord.copy();

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
      ..enemyDataList = copy.enemyDataList
      ..playerDataList = copy.playerDataList
      ..onFieldEnemies = copy.onFieldEnemies
      ..onFieldAllyServants = copy.onFieldAllyServants
      ..enemyDecks = copy.enemyDecks
      ..enemyTargetIndex = copy.enemyTargetIndex
      ..playerTargetIndex = copy.playerTargetIndex
      ..fieldBuffs = copy.fieldBuffs
      ..mysticCode = copy.mysticCode
      ..mysticCodeLv = copy.mysticCodeLv
      ..masterSkillInfo = copy.masterSkillInfo
      ..isPlayerTurn = copy.isPlayerTurn
      ..waveCount = copy.waveCount
      ..turnCount = copy.turnCount
      ..totalTurnCount = copy.totalTurnCount
      ..criticalStars = copy.criticalStars
      .._uniqueIndex = copy._uniqueIndex
      ..options = copy.options
      ..recorder = copy.recorder
      ..replayDataRecord = copy.replayDataRecord;
  }

  // replay
  Future<void> replay(BattleShareData replayActions) async {
    recorder.setIllegal('Replaying team');
    options.manualAllySkillTarget = false;
    delegate = BattleReplayDelegate(replayActions.delegate ?? BattleReplayDelegateData());
    for (final action in replayActions.actions) {
      playerTargetIndex = action.options.playerTarget;
      enemyTargetIndex = action.options.enemyTarget;
      options.random = action.options.random;
      options.threshold = action.options.threshold;
      options.tailoredExecution = action.options.tailoredExecution;
      if (action.type == BattleRecordDataType.skill) {
        await _replaySkill(action);
      } else if (action.type == BattleRecordDataType.attack) {
        await _replayBattle(action);
      }
    }
    delegate = null;
  }

  Future<void> _replaySkill(BattleRecordData action) async {
    if (action.skill == null) return;

    if (action.svt == null) {
      await activateMysticCodeSkill(action.skill!);
    } else {
      await activateSvtSkill(action.svt!, action.skill!);
    }
  }

  Future<void> _replayBattle(BattleRecordData action) async {
    if (action.attacks == null) return;

    final List<CombatAction> actions = [];
    for (final attackRecord in action.attacks!) {
      final svt = onFieldAllyServants[attackRecord.svt];
      if (svt == null) continue;

      final cardIndex = attackRecord.card;

      CommandCardData? card;
      if (attackRecord.isTD) {
        card = svt.getNPCard();
      } else if (cardIndex != null) {
        final cards = svt.getCards();
        if (cardIndex < 0 || cardIndex >= cards.length) {
          continue;
        }
        card = cards[cardIndex];
      }

      if (card == null) {
        continue;
      }
      card.critical = attackRecord.critical;

      actions.add(CombatAction(svt, card));
    }

    await playerTurn(actions);
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
