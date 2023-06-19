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
import '../interactions/_delegate.dart';
import '../interactions/tailored_execution_confirm.dart';
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
  Stage? curStage;

  int enemyOnFieldCount = 3;
  List<BattleServantData?> enemyDataList = [];
  List<BattleServantData?> playerDataList = [];
  List<bool> enemyValidAppear = [];
  List<BattleServantData?> onFieldEnemies = [];
  List<BattleServantData?> onFieldAllyServants = [];
  Map<DeckType, List<QuestEnemy>> enemyDecks = {};

  int enemyTargetIndex = 0;
  int allyTargetIndex = 0;

  BattleServantData? get targetedEnemy =>
      onFieldEnemies.length > enemyTargetIndex && enemyTargetIndex >= 0 ? onFieldEnemies[enemyTargetIndex] : null;

  BattleServantData? get targetedAlly => onFieldAllyServants.length > allyTargetIndex && allyTargetIndex >= 0
      ? onFieldAllyServants[allyTargetIndex]
      : null;

  List<BattleServantData> get nonnullEnemies => _getNonnull(onFieldEnemies);

  List<BattleServantData> get nonnullAllies => _getNonnull(onFieldAllyServants);

  List<BattleServantData> get nonnullActors => [...nonnullAllies, ...nonnullEnemies];

  List<BattleServantData> get nonnullBackupEnemies => _getNonnull(enemyDataList);

  List<BattleServantData> get nonnullBackupAllies => _getNonnull(playerDataList);

  List<BuffData> fieldBuffs = [];
  MysticCode? mysticCode;
  int mysticCodeLv = 10;
  List<BattleSkillInfoData> masterSkillInfo = []; //BattleSkillInfoData

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

  // should not be read, as this represent a build-in-progress svtUniqueId to funcResult map for the current function
  final Map<int, bool> curFuncResults = {};

  final Map<int, bool> uniqueIdToLastFuncResultMap = {};
  CommandCardData? currentCard;
  final List<BuffData?> _currentBuff = [];
  final List<BattleServantData> _activator = [];
  final List<BattleServantData> _target = [];

  // this is for logging only
  NiceFunction? curFunc;

  void updateLastFuncResults() {
    uniqueIdToLastFuncResultMap.clear();
    uniqueIdToLastFuncResultMap.addAll(curFuncResults);
  }

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

  bool get isBattleWin {
    return waveCount >= Maths.max(niceQuest?.stages.map((e) => e.wave) ?? [], -1) &&
        (curStage == null || (enemyDataList.isEmpty && onFieldEnemies.every((e) => e == null)));
  }

  bool get isBattleFinished => nonnullEnemies.isEmpty || nonnullAllies.isEmpty;

  Future<void> init(
    final QuestPhase quest,
    final List<PlayerSvtData?> playerSettings,
    final MysticCodeData? mysticCodeData,
  ) async {
    niceQuest = quest;
    waveCount = 1;
    turnCount = 0;
    recorder.progressWave(waveCount);
    totalTurnCount = 0;
    criticalStars = 0;

    uniqueIdToLastFuncResultMap.clear();
    _currentBuff.clear();
    _activator.clear();
    _target.clear();

    _uniqueIndex = 1;
    enemyDecks.clear();
    enemyTargetIndex = 0;
    allyTargetIndex = 0;

    fieldBuffs.clear();

    playerDataList = playerSettings
        .map((svtSetting) => svtSetting == null || svtSetting.svt == null
            ? null
            : BattleServantData.fromPlayerSvtData(svtSetting, getNextUniqueId()))
        .toList();
    _fetchWaveEnemies();

    final overwriteEquip = quest.extraDetail?.overwriteEquipSkills;
    if (overwriteEquip != null && overwriteEquip.skillIds.isNotEmpty) {
      mysticCode = await overwriteEquip.toMysticCode();
      mysticCodeLv = overwriteEquip.skillLv;
    } else {
      mysticCode = mysticCodeData?.mysticCode;
      mysticCodeLv = mysticCodeData?.level ?? 10;
    }
    if (mysticCode != null) {
      masterSkillInfo = [
        for (int index = 0; index < mysticCode!.skills.length; index++)
          BattleSkillInfoData(mysticCode!.skills[index], skillNum: index + 1)..skillLv = mysticCodeLv,
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

    allyTargetIndex = getNonNullTargetIndex(onFieldAllyServants, allyTargetIndex);
    enemyTargetIndex = getNonNullTargetIndex(onFieldEnemies, enemyTargetIndex);

    final List<BattleServantData?> allActors = [
      ...onFieldEnemies,
      ...enemyDataList,
      ...onFieldAllyServants,
      ...playerDataList,
    ];

    for (final actor in allActors) {
      actor?.initScript(this);
    }
    await initActorSkills(allActors);

    for (final svt in nonnullActors) {
      await svt.enterField(this);
    }

    await nextTurn();
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

  Future<void> nextTurn() async {
    await replenishActors();
    bool addTurn = true;

    if (enemyDataList.isEmpty && nonnullEnemies.isEmpty) {
      addTurn = await nextWave();
    }
    if (addTurn) {
      turnCount += 1;
      totalTurnCount += 1;
      recorder.progressTurn(totalTurnCount);
      battleLogger.action('${S.current.battle_turn} $totalTurnCount');
    }

    // start of ally turn
    for (final svt in nonnullAllies) {
      await svt.startOfMyTurn(this);
    }
  }

  Future<bool> nextWave() async {
    if (niceQuest?.stages.every((s) => s.wave < waveCount + 1) == true) {
      recorder.message('Win');
      return false;
    }
    waveCount += 1;
    recorder.progressWave(waveCount);
    turnCount = 0;

    _fetchWaveEnemies();

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

    enemyTargetIndex = getNonNullTargetIndex(onFieldEnemies, enemyTargetIndex);

    final List<BattleServantData?> newEnemies = [...onFieldEnemies, ...enemyDataList];
    for (final actor in newEnemies) {
      actor?.initScript(this);
    }
    await initActorSkills(newEnemies);

    for (final enemy in nonnullEnemies) {
      await enemy.enterField(this);
    }
    return true;
  }

  Future<void> replenishActors({final bool replenishAlly = true, final bool replenishEnemy = true}) async {
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

      allyTargetIndex = getNonNullTargetIndex(onFieldAllyServants, allyTargetIndex);
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

  void _fetchWaveEnemies() {
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

          enemyDataList[enemy.deckId - 1] = BattleServantData.fromEnemy(enemy, getNextUniqueId());
        } else {
          if (!enemyDecks.containsKey(enemy.deck)) {
            enemyDecks[enemy.deck] = [];
          }
          enemyDecks[enemy.deck]!.add(enemy);
        }
      }
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

    bool fieldTraitCheck(final NiceTrait trait) {
      // > 3000 is a buff trait
      return trait.id < 3000;
    }

    final List<int> removeTraitIds = [];
    for (final svt in nonnullActors) {
      setActivator(svt);
      for (final buff in svt.battleBuff.allBuffs) {
        if (buff.buff.type == BuffType.fieldIndividuality && buff.shouldApplyBuff(this, false)) {
          allTraits.addAll(buff.traits.where((trait) => fieldTraitCheck(trait)));
        } else if (buff.buff.type == BuffType.subFieldIndividuality && buff.shouldApplyBuff(this, false)) {
          removeTraitIds.addAll(buff.vals.TargetList!.map((traitId) => traitId));
        }
      }
      unsetActivator();
    }

    fieldBuffs
        .where((buff) => buff.buff.type == BuffType.toFieldChangeField)
        .forEach((buff) => allTraits.addAll(buff.traits.where((trait) => fieldTraitCheck(trait))));

    allTraits.removeWhere((trait) => removeTraitIds.contains(trait.id));

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
        final currentNp = actor.getNPCard(this);
        if (currentNp != null) {
          currentTraits.addAll(currentNp.traits);
        }
      }
    }

    if (params.checkCurrentBuffTraits && currentBuff != null) {
      currentTraits.addAll(currentBuff!.traits);
    }

    if (params.checkCurrentCardTraits && currentCard != null) {
      currentTraits.addAll(currentCard!.traits);
      if (currentCard!.isCritical) {
        currentTraits.add(NiceTrait(id: Trait.criticalHit.id));
      }
    }

    if (params.checkQuestTraits) {
      currentTraits.addAll(getFieldTraits());
    }

    if (params.checkIndivType == 1 || params.checkIndivType == 3) {
      return containsAllTraits(currentTraits, params.requiredTraits);
    } else {
      return containsAnyTraits(currentTraits, params.requiredTraits);
    }
  }

  bool isActorOnField(final int actorUniqueId) {
    return nonnullActors.any((svt) => svt.uniqueId == actorUniqueId);
  }

  void checkBuffStatus() {
    nonnullActors.forEach((svt) {
      svt.checkBuffStatus(this);
    });

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

    return onFieldAllyServants[servantIndex]!.canNP(this);
  }

  /// Only check skill sealed
  bool isSkillSealed(final int servantIndex, final int skillIndex) {
    if (onFieldAllyServants[servantIndex] == null) {
      return false;
    }

    return onFieldAllyServants[servantIndex]!.isSkillSealed(this, skillIndex);
  }

  /// Check canAct and skill script
  bool isSkillCondFailed(final int servantIndex, final int skillIndex) {
    if (onFieldAllyServants[servantIndex] == null) {
      return false;
    }

    return onFieldAllyServants[servantIndex]!.isCondFailed(this, skillIndex);
  }

  bool canUseSvtSkillIgnoreCoolDown(final int servantIndex, final int skillIndex) {
    if (onFieldAllyServants[servantIndex] == null) {
      return false;
    }

    return onFieldAllyServants[servantIndex]!.canUseSkillIgnoreCoolDown(this, skillIndex);
  }

  Future<T> recordError<T>({
    required bool save,
    required String action,
    required Future<T> Function() task,
  }) async {
    try {
      if (save) pushSnapshot();
      return await task();
    } catch (e, s) {
      battleLogger.error("Failed: $action");
      logger.e('Battle action failed: $action', e, s);
      logger.i(battleLogger.logs.join("\n"));
      if (mounted) EasyLoading.showError('${S.current.failed}\n\n$e');
      if (save) popSnapshot();
      rethrow;
    }
  }

  Future<void> activateSvtSkill(final int servantIndex, final int skillIndex) async {
    if (onFieldAllyServants[servantIndex] == null || isBattleFinished) {
      return;
    }

    final svt = onFieldAllyServants[servantIndex]!;
    battleLogger
        .action('${svt.lBattleName} - ${S.current.active_skill} ${skillIndex + 1}: ${svt.getSkillName(skillIndex)}');
    return recordError(
      save: true,
      action: 'svt_skill-${servantIndex + 1}-${skillIndex + 1}',
      task: () async {
        recorder.skillActivation(this, servantIndex, skillIndex);
        await svt.activateSkill(this, skillIndex);
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
      return nonnullBackupAllies.isNotEmpty && nonnullAllies.where((svt) => svt.canOrderChange(this)).isNotEmpty;
    }

    return true;
  }

  Future<void> activateMysticCodeSKill(final int skillIndex) async {
    if (masterSkillInfo.length <= skillIndex || isBattleFinished) {
      return;
    }

    battleLogger.action('${S.current.mystic_code} - ${S.current.active_skill} ${skillIndex + 1}: '
        '${masterSkillInfo[skillIndex].lName}');
    return recordError(
      save: true,
      action: 'mystic_code_skill-${skillIndex + 1}',
      task: () async {
        recorder.skillActivation(this, null, skillIndex);
        int effectiveness = 1000;
        for (final svt in nonnullAllies) {
          effectiveness += await svt.getBuffValueOnAction(this, BuffAction.masterSkillValueUp);
        }
        await masterSkillInfo[skillIndex].activate(this, effectiveness: effectiveness != 1000 ? effectiveness : null);
        recorder.skill(
          battleData: this,
          activator: null,
          skill: masterSkillInfo[skillIndex],
          type: SkillInfoType.mysticCode,
          fromPlayer: true,
          uploadEligible: true,
        );
        return;
      },
    );
  }

  Future<void> playerTurn(final List<CombatAction> actions) async {
    if (actions.isEmpty || isBattleFinished) {
      return;
    }

    return recordError(
      save: true,
      action: 'play_turn-${actions.length} cards',
      task: () async {
        recorder.initiateAttacks(this, actions);
        criticalStars = 0;

        // assumption: only Quick, Arts, and Buster are ever listed as viable actions
        final cardTypesSet =
            actions.where((action) => action.isValid(this)).map((action) => action.cardData.cardType).toSet();
        final isTypeChain = actions.length == 3 && cardTypesSet.length == 1;
        final isMightyChain = cardTypesSet.length == 3 && options.isAfter7thAnni;
        final isBraveChain = actions.where((action) => action.isValid(this)).length == kMaxCommand &&
            actions.map((action) => action.actor).toSet().length == 1;
        if (isBraveChain) {
          final actor = actions[0].actor;
          final extraCard = actor.getExtraCard(this);
          if (extraCard != null) actions.add(CombatAction(actor, extraCard));
        }

        final CardType firstCardType =
            options.isAfter7thAnni || actions[0].isValid(this) ? actions[0].cardData.cardType : CardType.blank;
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

            if (allyTargetIndex != -1 && action.isValid(this)) {
              recorder.startPlayerCard(action.actor, action.cardData);

              if (action.cardData.isNP) {
                await action.actor
                    .activateBuffOnActions(this, [BuffAction.functionAttackBefore, BuffAction.functionNpattack]);
                await action.actor.activateNP(this, extraOvercharge);
                await action.actor.activateBuffOnAction(this, BuffAction.functionAttackAfter);
                extraOvercharge += 1;

                for (final svt in nonnullEnemies) {
                  if (svt.attacked) await svt.activateBuffOnAction(this, BuffAction.functionDamage);
                }
              } else {
                extraOvercharge = 0;
                await executePlayerCard(
                  action.actor,
                  action.cardData,
                  i + 1,
                  isTypeChain,
                  isMightyChain,
                  firstCardType,
                );
              }
              recorder.endPlayerCard(action.actor, action.cardData);
            }

            if (shouldRemoveDeadActors(actions, i)) {
              await removeDeadActors();
            }

            currentCard = null;
          }

          checkBuffStatus();
        }

        // end player turn
        await endPlayerTurn();

        await startEnemyTurn();
        await endEnemyTurn();

        await nextTurn();

        allyTargetIndex = previousTargetIndex;
      },
    );
  }

  Future<void> skipWave() async {
    if (isBattleFinished) {
      return;
    }
    recorder.skipWave(waveCount);
    battleLogger.action('${S.current.battle_skip_current_wave} ($waveCount)');
    pushSnapshot();

    onFieldEnemies.fillRange(0, onFieldEnemies.length);
    enemyDataList.clear();

    await endPlayerTurn();

    await startEnemyTurn();
    await endEnemyTurn();

    await nextTurn();
  }

  Future<void> endPlayerTurn() async {
    for (final svt in nonnullAllies) {
      await svt.endOfMyTurn(this);
    }

    for (final svt in nonnullEnemies) {
      await svt.endOfYourTurn(this);
    }

    for (final skill in masterSkillInfo) {
      skill.turnEnd();
    }

    await removeDeadActors();

    for (final buff in fieldBuffs) {
      buff.turnPass();
    }
    fieldBuffs.removeWhere((buff) => !buff.isActive);
  }

  Future<void> startEnemyTurn() async {
    for (final svt in nonnullEnemies) {
      if (svt.hp <= 0) {
        svt.shift(this);
        await initActorSkills([svt]);
      }
      await svt.startOfMyTurn(this);
    }
  }

  Future<void> endEnemyTurn() async {
    for (final svt in nonnullEnemies) {
      await svt.endOfMyTurn(this);
    }

    for (final svt in nonnullAllies) {
      await svt.endOfYourTurn(this);
    }

    await removeDeadActors();

    for (final buff in fieldBuffs) {
      buff.turnPass();
    }
    fieldBuffs.removeWhere((buff) => !buff.isActive);
  }

  Future<void> executePlayerCard(
    final BattleServantData actor,
    final CommandCardData card,
    final int chainPos,
    final bool isTypeChain,
    final bool isMightyChain,
    final CardType firstCardType,
  ) async {
    await actor.activateCommandCode(this, card.cardIndex);

    await actor.activateBuffOnActions(this, [
      BuffAction.functionAttackBefore,
      BuffAction.functionCommandattackBefore,
      BuffAction.functionCommandcodeattackBefore,
    ]);

    setActivator(actor);

    final List<BattleServantData> targets = [];
    if (card.cardDetail.attackType == CommandCardAttackType.all) {
      targets.addAll(nonnullEnemies);
    } else {
      targets.add(targetedEnemy!);
    }
    await Damage.damage(this, null, cardDamage, targets, chainPos, isTypeChain, isMightyChain, firstCardType);

    unsetActivator();

    await actor.activateBuffOnActions(this, [
      BuffAction.functionAttackAfter,
      BuffAction.functionCommandattackAfter,
      BuffAction.functionCommandcodeattackAfter,
    ]);

    actor.clearCommandCodeBuffs();

    for (final svt in targets) {
      await svt.activateBuffOnAction(this, BuffAction.functionDamage);
    }
  }

  void applyTypeChain(final CardType cardType, final List<CombatAction> actions) {
    battleLogger.action('${cardType.name} Chain');
    if (cardType == CardType.quick) {
      final dataValToUse = options.isAfter7thAnni ? quickChainAfter7thAnni : quickChainBefore7thAnni;
      GainStar.gainStar(this, dataValToUse);
    } else if (cardType == CardType.arts) {
      final targets = actions.map((action) => action.actor).toSet();
      GainNP.gainNP(this, artsChain, targets);
    }
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
        await BattleSkillInfoData.activateSkill(this, skill, 1, defaultToPlayer: true);
        recorder.skill(
          battleData: this,
          activator: null,
          skill: BattleSkillInfoData(skill),
          type: SkillInfoType.commandSpell,
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
        await BattleSkillInfoData.activateSkill(this, skill, 1, defaultToPlayer: true);
        recorder.skill(
          battleData: this,
          activator: null,
          skill: BattleSkillInfoData(skill),
          type: SkillInfoType.commandSpell,
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
        await BattleSkillInfoData.activateSkill(this, skill, 1, defaultToPlayer: true);
        recorder.skill(
          battleData: this,
          activator: null,
          skill: BattleSkillInfoData(skill),
          type: SkillInfoType.commandSpell,
          fromPlayer: true,
          uploadEligible: false,
        );
      },
    );
  }

  Future<void> resetPlayerSkillCD(bool isMysticCode) async {
    recorder.isUploadEligible = false;
    return recordError(
      save: true,
      action: 'resetSkillCD',
      task: () async {
        if (isMysticCode) {
          for (final skill in masterSkillInfo) {
            skill.chargeTurn = 0;
          }
          recorder.message("${S.current.reset_skill_cd} (${S.current.mystic_code})", null);
        } else {
          final ally = targetedAlly;
          if (ally == null) return;
          for (final skill in ally.skillInfoList) {
            skill.chargeTurn = 0;
          }
          recorder.message(S.current.reset_skill_cd, ally);
        }
      },
    );
  }

  Future<void> removeDeadActors() async {
    await removeDeadActorsFromList(onFieldAllyServants);
    await removeDeadActorsFromList(onFieldEnemies);
    allyTargetIndex = getNonNullTargetIndex(onFieldAllyServants, allyTargetIndex);
    enemyTargetIndex = getNonNullTargetIndex(onFieldEnemies, enemyTargetIndex);

    if (niceQuest != null && niceQuest!.flags.contains(QuestFlag.enemyImmediateAppear)) {
      await replenishActors(replenishAlly: false);
    }
  }

  Future<void> removeDeadActorsFromList(final List<BattleServantData?> actorList) async {
    for (int i = 0; i < actorList.length; i += 1) {
      if (actorList[i] == null) {
        continue;
      }

      final actor = actorList[i]!;
      if (actor.hp <= 0 && !actor.hasNextShift(this)) {
        bool hasGuts = false;
        await actor.activateGuts(this).then((value) => hasGuts = value);
        if (!hasGuts) {
          await actor.death(this);
          if (actor.lastHitBy != null) {
            await actor.lastHitBy!.activateBuffOnAction(this, BuffAction.functionDeadattack);
          }
          actorList[i] = null;
          actor.fieldIndex = -1;
          if (actor.isPlayer) {
            nonnullAllies.forEach((svt) {
              svt.removeBuffWithTrait(NiceTrait(id: Trait.buffLockCardsDeck.id));
            });
          }
        }
      }
    }
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
    if (action.cardData.isNP || index == actions.length - 1) {
      return true;
    }

    final nextAction = actions[index + 1];
    return nextAction.cardData.isNP || nextAction.actor != action.actor;
  }

  Future<bool> canActivate(final int activationRate, final String description) async {
    if (activationRate <= 0) {
      return false;
    }

    final curResult = options.probabilityThreshold <= activationRate;

    if (activationRate < 1000 && options.tailoredExecution) {
      if (delegate?.canActivate != null) {
        return await delegate!.canActivate!.call(curResult);
      } else if (mounted) {
        final curResultString = curResult ? S.current.success : S.current.failed;
        final String details = '${S.current.results}: $curResultString => '
            '${S.current.battle_activate_probability}: '
            '${(activationRate / 10).toStringAsFixed(1)}% '
            'vs ${S.current.probability_expectation}: '
            '${(options.probabilityThreshold / 10).toStringAsFixed(1)}%';
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
      ..enemyOnFieldCount = enemyOnFieldCount
      ..enemyValidAppear = enemyValidAppear.toList()
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
      ..enemyOnFieldCount = copy.enemyOnFieldCount
      ..enemyValidAppear = copy.enemyValidAppear
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
      .._uniqueIndex = copy._uniqueIndex
      ..options = copy.options
      ..recorder = copy.recorder
      ..replayDataRecord = copy.replayDataRecord;
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
