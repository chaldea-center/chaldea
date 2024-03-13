import 'dart:math';

import 'package:flutter/widgets.dart';

import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import '../models/battle.dart';

class BattleCancelException implements Exception {
  final String msg;
  final bool toast;
  const BattleCancelException([this.msg = "", this.toast = false]);

  @override
  String toString() {
    return "BattleCancelException: $msg, $toast";
  }
}

class BattleLogger {
  final List<BattleLog> logs = [];

  void _log(final BattleLogType type, final String log) {
    logs.add(BattleLog(type, log));
  }

  void action(final String log) {
    _log(BattleLogType.action, log);
  }

  void function(final String log) {
    _log(BattleLogType.function, log);
  }

  void debug(final String log) {
    _log(BattleLogType.debug, log);
  }

  void error(String log) {
    _log(BattleLogType.error, log);
  }
}

class BattleLog {
  final BattleLogType type;
  final String log;

  BattleLog(this.type, this.log);

  @override
  String toString() => "BattleLog(${type.name}): $log";
}

enum BattleLogType { debug, function, action, error }

class BattleRecordManager {
  List<BattleRecord> records = [];
  Set<String> illegalReasons = {};
  BattleRecordManager();

  bool get isUploadEligible => illegalReasons.isEmpty;
  void setIllegal(String reason) => illegalReasons.add(reason);

  BattleRecordManager copy() {
    return BattleRecordManager()
      ..illegalReasons = illegalReasons.toSet()
      ..records = records.toList()
      .._cardHistory = _cardHistory.toList();
  }

  void message(String msg, {BattleServantData? target}) {
    records.add(BattleMessageRecord(msg, target: target));
  }

  void messageRich(BattleMessageRecord msg) {
    records.add(msg);
  }

  void progressWave(int wave) {
    records.add(BattleProgressWaveRecord(wave));
  }

  void skipWave(int wave) {
    setIllegal('Skip Wave $wave');
    records.add(BattleSkipWaveRecord(wave));
  }

  void progressTurn(int turn) {
    records.add(BattleProgressTurnRecord(turn));
  }

  void skillActivation(final BattleData battleData, final int? svt, final int skill) {
    records.add(BattleSkillActivationRecord(
      playerTarget: battleData.playerTargetIndex,
      enemyTarget: battleData.enemyTargetIndex,
      random: battleData.options.random,
      threshold: battleData.options.threshold,
      tailoredExecution: battleData.options.tailoredExecution,
      svt: svt,
      skill: skill,
    ));
  }

  void skill({
    required BattleData battleData,
    required BattleServantData? activator,
    required BattleSkillInfoData skill,
    required bool fromPlayer,
    required bool uploadEligible,
    String? prefix,
    BattleSkillParams? param,
  }) {
    if (!uploadEligible) {
      setIllegal('${S.current.skill} ${skill.type.name}: ${skill.lName}');
    }

    records.add(BattleSkillRecord(
      prefix: prefix,
      activator: activator,
      targetPlayerSvt: battleData.targetedPlayer,
      targetEnemySvt: battleData.targetedEnemy,
      skill: skill,
      fromPlayer: fromPlayer,
      param: param,
    ));
  }

  void orderChange({required BattleServantData onField, required BattleServantData backup}) {
    records.add(BattleOrderChangeRecord(onField: onField, backup: backup));
  }

  List<_BattleCardTempData> _cardHistory = [];

  void initiateAttacks(final BattleData battleData, final List<CombatAction> combatActions) {
    records.add(BattleAttacksInitiationRecord(
      playerTarget: battleData.playerTargetIndex,
      enemyTarget: battleData.enemyTargetIndex,
      random: battleData.options.random,
      threshold: battleData.options.threshold,
      tailoredExecution: battleData.options.tailoredExecution,
      attacks: combatActions,
    ));
  }

  void startPlayerCard(BattleServantData activator, CommandCardData card) {
    _cardHistory.add(_BattleCardTempData(activator, card));
  }

  void setOverCharge(BattleServantData activator, CommandCardData card, int oc) {
    final last = _cardHistory.lastOrNull;
    assert(last != null && last.actor == activator && last.card == card);
    if (last != null && last.actor == activator && last.card == card) {
      card.oc = oc;
    } else {
      assert(() {
        throw Exception("last card is not desired");
      }());
    }
  }

  void attack(BattleServantData activator, BattleAttackRecord record) {
    final _last = _cardHistory.lastOrNull;
    assert(_last == null || _last.actor.uniqueId == activator.uniqueId);
    if (_last != null) {
      record.card = _last.card;
      _last.hasAttack = true;
    }
    if (record.targets.isNotEmpty) records.add(record);
  }

  void endPlayerCard(BattleServantData activator, CommandCardData card) {
    final _last = _cardHistory.removeLast();
    assert(_last.actor.uniqueId == activator.uniqueId && _last.card?.cardIndex == card.cardIndex);
    if (!_last.hasAttack) {
      // supporter TD
      records.add(BattleAttackRecord(
          activator: activator, card: card, targets: [], damage: 0, attackNp: 0, defenseNp: 0, star: 0));
    }
  }

  void instantDeath(BattleInstantDeathRecord record) {
    final card = _cardHistory.lastWhereOrNull((card) => card.actor.uniqueId == record.activator?.uniqueId);
    record.card = card?.card;
    records.add(record);
  }

  // move to somewhere else
  void determineUploadEligibility(final QuestPhase questPhase, final BattleOptions options) {
    if (questPhase.id <= 0) {
      setIllegal('${S.current.general_custom}: ${S.current.quest} ${questPhase.id}');
    }
    if (options.pointBuffs.isNotEmpty) {
      // setIllegal(S.current.event_point);
    }
    if (options.disableEvent) {
      setIllegal('${S.current.options}: ${S.current.disable_event_effects}');
    }
    if (options.simulateEnemy) {
      setIllegal('${S.current.options}: ${S.current.simulate_enemy_actions}');
    }
    if (questPhase.isLaplaceNeedAi) {
      if (!options.simulateAi) {
        setIllegal("${S.current.options}: ${S.current.simulate_simple_ai} must be enabled");
      }
    } else {
      if (options.simulateAi) {
        setIllegal('${S.current.options}: ${S.current.simulate_simple_ai}');
      }
    }

    if (options.formation.allSvts.where((e) => e.supportType != SupportSvtType.none).length > 1) {
      setIllegal('${S.current.support_servant}: ＞1');
    }
    final maxCost = Maths.max(ConstData.userLevel.values.map((e) => e.maxCost), 115);
    if (options.formation.totalCost > maxCost) {
      setIllegal('COST ${options.formation.totalCost}>$maxCost');
    }

    for (final svtData in options.formation.allSvts) {
      _checkSvtEligible(svtData);
    }
  }

  void _checkSvtEligible(PlayerSvtData svtData) {
    final svt = svtData.svt;
    if (svt == null) return;
    final svtName = svt.lName.l;
    if (svtData.supportType == SupportSvtType.npc) {
      setIllegal('Guest Support/NPC: $svtName');
    }
    if (!svt.isUserSvt) {
      setIllegal('Not player servant: $svtName');
    }
    if (svtData.customPassives.isNotEmpty) {
      setIllegal('${S.current.extra_passive}(${S.current.general_custom})');
    }
    if (svtData.disabledExtraSkills.isNotEmpty) {
      setIllegal("${svtData.disabledExtraSkills.length} disabled extra skills");
    }
    if (svtData.fixedAtk != null || svtData.fixedHp != null) {
      setIllegal('Fixed HP or ATK (mainly Guest Support). If you see this msg, tell me the bug.');
    }
    final dbSvt = db.gameData.servantsById[svt.id];
    if (dbSvt == null) {
      setIllegal('Servant not in database');
      return;
    }
    for (final skillNum in kActiveSkillNums) {
      final skillId = svtData.skills.getOrNull(skillNum - 1)?.id;
      if (skillId == null) continue;
      final validSkills = BattleUtils.getShownSkills(dbSvt, svtData.limitCount, skillNum).map((e) => e.id).toSet();
      if (!validSkills.contains(skillId)) {
        setIllegal('${S.current.custom_skill} $skillNum - ID $skillId, valid: $validSkills');
      }
    }
    final validTds = BattleUtils.getShownTds(dbSvt, svtData.limitCount).map((e) => e.id).toSet();
    if (svtData.td != null && !validTds.contains(svtData.td?.id)) {
      setIllegal('${S.current.general_custom} ${S.current.noble_phantasm}: ID ${svtData.td!.id}, valid: $validTds');
    }
    if (svtData.ce != null && svtData.ce!.collectionNo <= 0) {
      setIllegal('${S.current.craft_essence}: ID ${svtData.ce!.id}, not player CE');
    }

    // coin
    int requiredCoins = 0, maxCoins = 0;
    int? summonCoin = svt.coin?.summonNum ?? 0;
    if (summonCoin > 0 && svt.rarity >= 4 && svtData.tdLv < 5 && svt.extra.obtains.any((e) => e.isSummonable)) {
      maxCoins = summonCoin * svtData.tdLv + 180;
      requiredCoins += max(((svtData.lv - 100) / 2).ceil() * 30, 0);
      requiredCoins += svtData.appendLvs.where((e) => e > 0).length * 120;
      if (requiredCoins > maxCoins) {
        setIllegal('${S.current.servant_coin}(${svt.lName.l}): required $requiredCoins, '
            'but max $maxCoins at ${S.current.np_short}${svtData.tdLv} & ${S.current.bond}15 ');
      }
    }
  }

  Set<String> checkExtraIllegalReason(BattleReplayDelegateData delegate) {
    final reasons = <String>{};
    const kMaxRNG = 950, kMinProb = 80;
    int countLargeRng = 0, countProb = 0;
    bool tailoredExecution = delegate.damageSelections.isNotEmpty || delegate.canActivateDecisions.isNotEmpty;
    for (final record in toUploadRecords()) {
      if (record.options.random >= kMaxRNG) {
        countLargeRng += 1;
      }
      tailoredExecution |= record.options.tailoredExecution;
      if (record.options.threshold <= kMinProb) {
        countProb += 1;
      }
    }
    if (tailoredExecution) {
      reasons.add('${S.current.options}: ${S.current.battle_tailored_execution}');
    }

    if (countLargeRng > 3) {
      reasons.add('${S.current.battle_random}≥0.95: count $countLargeRng>3');
    }
    if (countProb > 3) {
      reasons.add('${S.current.battle_probability_threshold}≤80: count $countProb>3');
    }
    return reasons;
  }

  List<BattleRecordData> toUploadRecords() {
    final List<BattleRecordData> uploadRecords = [];
    for (final record in records) {
      final uploadRecord = record.toUploadRecord();
      if (uploadRecord != null) {
        uploadRecords.add(uploadRecord);
      }
    }
    return uploadRecords;
  }
}

class _BattleCardTempData {
  final BattleServantData actor;
  CommandCardData? card;
  BattleAttackRecord? attack;
  bool hasAttack = false;

  _BattleCardTempData(this.actor, this.card);
}

const _kOneRowRecordHeight = 32.0; // with svt icon

/// Only record user visible actions
/// make sealed when dart 2.19 enabled
abstract class BattleRecord {
  BattleRecord();

  BattleRecord copy();

  BattleRecordData? toUploadRecord() {
    return null;
  }

  double get estimatedHeight;
}

class BattleMessageRecord extends BattleRecord {
  final String message;
  final AlignmentGeometry? alignment;
  final TextStyle? style;
  final TextAlign? textAlign;
  final BattleServantData? target;
  BattleMessageRecord(this.message, {this.target, this.alignment, this.style, this.textAlign});

  @override
  BattleMessageRecord copy() {
    return BattleMessageRecord(message,
        target: target?.copy(), alignment: alignment, style: style?.copyWith(), textAlign: textAlign);
  }

  @override
  double get estimatedHeight => _kOneRowRecordHeight;
}

class BattleSkipWaveRecord extends BattleRecord {
  // skip [wave], then start [wave+1]
  final int wave;
  BattleSkipWaveRecord(this.wave);

  @override
  String toString() {
    return 'Skip Wave $wave';
  }

  @override
  BattleSkipWaveRecord copy() {
    return BattleSkipWaveRecord(wave);
  }

  @override
  double get estimatedHeight => 21.0;
}

class BattleProgressWaveRecord extends BattleRecord {
  // start [wave]
  final int wave;
  BattleProgressWaveRecord(this.wave);

  @override
  String toString() {
    return 'Start Wave $wave';
  }

  @override
  BattleProgressWaveRecord copy() {
    return BattleProgressWaveRecord(wave);
  }

  @override
  double get estimatedHeight => 36;
}

class BattleProgressTurnRecord extends BattleRecord {
  // start [wave]
  final int turn;
  BattleProgressTurnRecord(this.turn);

  @override
  String toString() {
    return 'Start Turn $turn';
  }

  @override
  BattleProgressWaveRecord copy() {
    return BattleProgressWaveRecord(turn);
  }

  @override
  double get estimatedHeight => 21;
}

class BattleSkillActivationRecord extends BattleRecord {
  final BattleRecordData recordData;

  BattleSkillActivationRecord({
    required final int playerTarget,
    required final int enemyTarget,
    required final int random,
    required final int threshold,
    required final bool tailoredExecution,
    required final int? svt,
    required final int skill,
  }) : recordData = BattleRecordData.skill(
          options: BattleActionOptions(
            playerTarget: playerTarget,
            enemyTarget: enemyTarget,
            random: random,
            threshold: threshold,
            tailoredExecution: tailoredExecution,
          ),
          svt: svt,
          skill: skill,
        );

  @override
  BattleRecord copy() {
    return BattleSkillActivationRecord(
      playerTarget: recordData.options.playerTarget,
      enemyTarget: recordData.options.enemyTarget,
      random: recordData.options.random,
      threshold: recordData.options.threshold,
      tailoredExecution: recordData.options.tailoredExecution,
      svt: recordData.svt,
      skill: recordData.skill!,
    );
  }

  @override
  BattleRecordData? toUploadRecord() {
    return recordData;
  }

  @override
  double get estimatedHeight => 0;
}

class BattleSkillParams {
  int? selectAddIndex;
  int? actSet;
  int? tdTypeChange;

  BattleSkillParams({
    this.selectAddIndex,
    this.actSet,
    this.tdTypeChange,
  });

  BattleSkillParams copy() {
    return BattleSkillParams(
      selectAddIndex: selectAddIndex,
      actSet: actSet,
      tdTypeChange: tdTypeChange,
    );
  }
}

class BattleSkillRecord extends BattleRecord {
  final String? prefix;
  final BattleServantData? activator;
  final BattleServantData? targetPlayerSvt;
  final BattleServantData? targetEnemySvt;
  final BattleSkillInfoData skill;
  final bool fromPlayer;
  final BattleSkillParams param;

  BattleSkillRecord({
    this.prefix,
    required BattleServantData? activator,
    required BattleServantData? targetPlayerSvt,
    required BattleServantData? targetEnemySvt,
    required BattleSkillInfoData skill,
    required this.fromPlayer,
    BattleSkillParams? param,
  })  : activator = activator?.copy(),
        targetPlayerSvt = targetPlayerSvt?.copy(),
        targetEnemySvt = targetEnemySvt?.copy(),
        skill = skill.copy(),
        param = param ?? BattleSkillParams();

  @override
  String toString() {
    return '${skill.type.name}: ${activator?.lBattleName} Skill: ${skill.lName}';
  }

  @override
  BattleSkillRecord copy() {
    return BattleSkillRecord(
      prefix: prefix,
      activator: activator,
      targetPlayerSvt: targetPlayerSvt,
      targetEnemySvt: targetEnemySvt,
      skill: skill,
      fromPlayer: fromPlayer,
      param: param.copy(),
    );
  }

  @override
  double get estimatedHeight => _kOneRowRecordHeight;
}

class BattleOrderChangeRecord extends BattleRecord {
  final BattleServantData onField;
  final BattleServantData backup;
  BattleOrderChangeRecord({
    required BattleServantData onField,
    required BattleServantData backup,
  })  : onField = onField.copy(),
        backup = backup.copy();

  @override
  String toString() {
    return 'Order Change: ${onField.lBattleName} ↔ ${backup.lBattleName}';
  }

  @override
  BattleOrderChangeRecord copy() {
    return BattleOrderChangeRecord(onField: onField, backup: backup);
  }

  @override
  double get estimatedHeight => _kOneRowRecordHeight;
}

class BattleAttacksInitiationRecord extends BattleRecord {
  final int playerTarget;
  final int enemyTarget;
  final int random;
  final int threshold;
  final bool tailoredExecution;
  final List<CombatAction> attacks;

  BattleAttacksInitiationRecord({
    required this.playerTarget,
    required this.enemyTarget,
    required this.random,
    required this.threshold,
    required this.tailoredExecution,
    required List<CombatAction> attacks,
  }) : attacks = attacks.map((e) => e.copy()).toList();

  @override
  BattleRecord copy() {
    return BattleAttacksInitiationRecord(
      playerTarget: playerTarget,
      enemyTarget: enemyTarget,
      random: random,
      threshold: threshold,
      tailoredExecution: tailoredExecution,
      attacks: attacks.map((e) => e.copy()).toList(),
    );
  }

  @override
  BattleRecordData? toUploadRecord() {
    return BattleRecordData.attack(
      options: BattleActionOptions(
        playerTarget: playerTarget,
        enemyTarget: enemyTarget,
        random: random,
        threshold: threshold,
        tailoredExecution: tailoredExecution,
      ),
      attacks: [
        for (final attack in attacks)
          BattleAttackRecordData(
            svt: attack.actor.fieldIndex,
            card: attack.cardData.cardIndex,
            isTD: attack.cardData.isTD,
            critical: attack.cardData.critical,
            cardType: attack.cardData.cardType,
          )
      ],
    );
  }

  @override
  double get estimatedHeight => _kOneRowRecordHeight;
}

class BattleAttackRecord extends BattleRecord {
  final BattleServantData attacker;
  CommandCardData? card;
  final List<AttackResultDetail> targets;
  final int damage;
  final int attackNp;
  final int defenseNp;
  final int star;

  BattleAttackRecord({
    required BattleServantData activator,
    required CommandCardData? card,
    required this.targets,
    required this.damage,
    required this.attackNp,
    required this.defenseNp,
    required this.star,
  })  : attacker = activator.copy(),
        card = card?.copy();
  @override
  String toString() {
    return '${attacker.lBattleName} Play ${card?.cardType.name.toTitle()} Card.'
        ' damage=$damage, NP=$attackNp, defNp=$defenseNp, star=$star';
  }

  @override
  BattleAttackRecord copy() {
    return BattleAttackRecord(
      activator: attacker,
      card: card,
      targets: targets.map((e) => e.copy()).toList(),
      damage: damage,
      attackNp: attackNp,
      defenseNp: defenseNp,
      star: star,
    );
  }

  @override
  double get estimatedHeight {
    if (targets.isEmpty) return 95.0;
    final maxFieldIndex = Maths.max(targets.map((e) => e.target.fieldIndex));
    final rows = max((maxFieldIndex + 1 / 3).ceil(), 1);
    return rows * 140;
  }
}

class AttackResultDetail {
  final BattleServantData target;
  final BattleServantData targetBefore;
  final DamageParameters damageParams;
  final AttackNpGainParameters attackNpParams;
  final DefendNpGainParameters defenseNpParams;
  final StarParameters starParams;
  final DamageResult result;
  final DamageResult? minResult;
  final DamageResult? maxResult;

  AttackResultDetail({
    required BattleServantData target,
    required BattleServantData targetBefore,
    required DamageParameters damageParams,
    required AttackNpGainParameters attackNpParams,
    required DefendNpGainParameters defenseNpParams,
    required StarParameters starParams,
    required DamageResult result,
    required DamageResult? minResult,
    required DamageResult? maxResult,
  })  : target = target.copy(),
        targetBefore = targetBefore.copy(),
        damageParams = damageParams.copy(),
        attackNpParams = attackNpParams.copy(),
        defenseNpParams = defenseNpParams.copy(),
        starParams = starParams.copy(),
        result = result.copy(),
        minResult = minResult?.copy(),
        maxResult = maxResult?.copy();

  AttackResultDetail copy() {
    return AttackResultDetail(
      target: target,
      targetBefore: targetBefore,
      damageParams: damageParams,
      attackNpParams: attackNpParams,
      defenseNpParams: defenseNpParams,
      starParams: starParams,
      result: result,
      minResult: minResult,
      maxResult: maxResult,
    );
  }
}

class BattleLossHpRecord extends BattleRecord {
  @override
  BattleRecord copy() => this;

  @override
  double get estimatedHeight => _kOneRowRecordHeight;
}

class BattleReduceHpRecord extends BattleRecord {
  @override
  BattleRecord copy() => this;

  @override
  double get estimatedHeight => _kOneRowRecordHeight;
}

class BattleInstantDeathRecord extends BattleRecord {
  final bool forceInstantDeath;
  final BattleServantData? activator;
  CommandCardData? card;
  final List<InstantDeathResultDetail> targets;

  BattleInstantDeathRecord({
    required this.forceInstantDeath,
    required BattleServantData? activator,
    CommandCardData? card,
    required this.targets,
  })  : activator = activator?.copy(),
        card = card?.copy();

  @override
  BattleInstantDeathRecord copy() {
    return BattleInstantDeathRecord(
      forceInstantDeath: forceInstantDeath,
      activator: activator?.copy(),
      card: card,
      targets: targets.map((e) => e.copy()).toList(),
    );
  }

  bool get hasSuccess {
    return targets.any((e) => e.params.success);
  }

  @override
  double get estimatedHeight {
    final maxFieldIndex = Maths.max(targets.map((e) => e.target.fieldIndex));
    final rows = max((maxFieldIndex + 1 / 3).ceil(), 1);
    return rows * 103;
  }
}

class InstantDeathResultDetail {
  final BattleServantData target;
  final InstantDeathParameters params;

  InstantDeathResultDetail({
    required BattleServantData target,
    required InstantDeathParameters params,
  })  : target = target.copy(),
        params = params.copy();

  InstantDeathResultDetail copy() {
    return InstantDeathResultDetail(target: target, params: params.copy());
  }
}
