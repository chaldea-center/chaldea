import 'dart:math';

import 'package:flutter/widgets.dart';

import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import '../models/battle.dart';

class BattleCancelException implements Exception {
  final String msg;
  const BattleCancelException([this.msg = ""]);

  @override
  String toString() {
    return "BattleCancelException: $msg";
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
      ..records = records.toList();
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

  void skillActivation(final BattleData battleData, final int? servantIndex, final int skillIndex) {
    records.add(BattleSkillActivationRecord(
      allyTargetIndex: battleData.allyTargetIndex,
      enemyTargetIndex: battleData.enemyTargetIndex,
      fixedRandom: battleData.options.fixedRandom,
      probabilityThreshold: battleData.options.probabilityThreshold,
      isAfter7thAnni: battleData.options.isAfter7thAnni,
      tailoredExecution: battleData.options.tailoredExecution,
      servantIndex: servantIndex,
      skillIndex: skillIndex,
    ));
  }

  void skill({
    required BattleData battleData,
    required BattleServantData? activator,
    required BattleSkillInfoData skill,
    required bool fromPlayer,
    required bool uploadEligible,
    String? prefix,
  }) {
    if (!uploadEligible) {
      setIllegal('${S.current.skill} ${skill.type.name}: ${skill.proximateSkill?.lName.l}');
    }

    records.add(BattleSkillRecord(
      prefix: prefix,
      activator: activator,
      targetPlayerSvt: battleData.targetedAlly,
      targetEnemySvt: battleData.targetedEnemy,
      skill: skill,
      fromPlayer: fromPlayer,
    ));
  }

  void orderChange({required BattleServantData onField, required BattleServantData backup}) {
    records.add(BattleOrderChangeRecord(onField: onField, backup: backup));
  }

  final List<_BattleCardTempData> _cardHistory = [];

  void initiateAttacks(final BattleData battleData, final List<CombatAction> combatActions) {
    records.add(BattleAttacksInitiationRecord(
        allyTargetIndex: battleData.allyTargetIndex,
        enemyTargetIndex: battleData.enemyTargetIndex,
        fixedRandom: battleData.options.fixedRandom,
        probabilityThreshold: battleData.options.probabilityThreshold,
        isAfter7thAnni: battleData.options.isAfter7thAnni,
        tailoredExecution: battleData.options.tailoredExecution,
        actions: combatActions
            .map((combatAction) => BattleAttackRecordData(
                  servantIndex: combatAction.actor.fieldIndex,
                  cardIndex: combatAction.cardData.cardIndex,
                  isNp: combatAction.cardData.isNP,
                  isCritical: combatAction.cardData.isCritical,
                  cardType: combatAction.cardData.cardType,
                ))
            .toList()));
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
    if (options.simulateAi) {
      // TODO: allow Tsunguska
      setIllegal('${S.current.options}: ${S.current.simulate_simple_ai}');
    }
    if (options.team.allSvts.where((e) => e.supportType != SupportSvtType.none).length > 1) {
      setIllegal('${S.current.support_servant}: ＞1');
    }
    final maxCost = Maths.max(ConstData.userLevel.values.map((e) => e.maxCost), 115);
    if (options.team.totalCost > maxCost) {
      setIllegal('COST ${options.team.totalCost}>$maxCost');
    }

    for (final svtData in options.team.allSvts) {
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
    if (svtData.additionalPassives.isNotEmpty) {
      setIllegal('${S.current.extra_passive}(${S.current.general_custom})');
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
  }

  Set<String> checkExtraIllegalReason() {
    final reasons = <String>{};
    int countNormalAttack = 0, countLargeRng = 0, countProb = 0;
    for (final record in toUploadRecords()) {
      if (record.options.fixedRandom >= 950) {
        countLargeRng += 1;
      }
      if (record.options.probabilityThreshold <= 80) {
        countProb += 1;
      }
      final attacks = record.attackRecords ?? [];
      for (final attack in attacks) {
        if (!attack.isNp) {
          countNormalAttack += 1;
        }
      }
    }
    if (countNormalAttack > 6) {
      setIllegal('${S.current.normal_attack}: $countNormalAttack >6');
    }
    if (countLargeRng > 3) {
      setIllegal('${S.current.battle_random}≥0.95: count $countLargeRng>3');
    }
    if (countProb > 3) {
      setIllegal('${S.current.battle_probability_threshold}≤80: count $countProb>3');
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
    required final int allyTargetIndex,
    required final int enemyTargetIndex,
    required final int fixedRandom,
    required final int probabilityThreshold,
    required final bool isAfter7thAnni,
    required final bool tailoredExecution,
    required final int? servantIndex,
    required final int skillIndex,
  }) : recordData = BattleRecordData.skill(
          options: BattleActionOptions(
            allyTargetIndex: allyTargetIndex,
            enemyTargetIndex: enemyTargetIndex,
            fixedRandom: fixedRandom,
            probabilityThreshold: probabilityThreshold,
            isAfter7thAnni: isAfter7thAnni,
            tailoredExecution: tailoredExecution,
          ),
          servantIndex: servantIndex,
          skillIndex: skillIndex,
        );

  @override
  BattleRecord copy() {
    return BattleSkillActivationRecord(
      allyTargetIndex: recordData.options.allyTargetIndex,
      enemyTargetIndex: recordData.options.enemyTargetIndex,
      fixedRandom: recordData.options.fixedRandom,
      probabilityThreshold: recordData.options.probabilityThreshold,
      isAfter7thAnni: recordData.options.isAfter7thAnni,
      tailoredExecution: recordData.options.tailoredExecution,
      servantIndex: recordData.servantIndex,
      skillIndex: recordData.skillIndex!,
    );
  }

  @override
  BattleRecordData? toUploadRecord() {
    return recordData;
  }

  @override
  double get estimatedHeight => 0;
}

class BattleSkillRecord extends BattleRecord {
  final String? prefix;
  final BattleServantData? activator;
  final BattleServantData? targetPlayerSvt;
  final BattleServantData? targetEnemySvt;
  final BattleSkillInfoData skill;
  final bool fromPlayer;

  BattleSkillRecord({
    this.prefix,
    required BattleServantData? activator,
    required BattleServantData? targetPlayerSvt,
    required BattleServantData? targetEnemySvt,
    required BattleSkillInfoData skill,
    required this.fromPlayer,
  })  : activator = activator?.copy(),
        targetPlayerSvt = targetPlayerSvt?.copy(),
        targetEnemySvt = targetEnemySvt?.copy(),
        skill = skill.copy();

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
  final BattleRecordData recordData;
  BattleAttacksInitiationRecord({
    required final int allyTargetIndex,
    required final int enemyTargetIndex,
    required final int fixedRandom,
    required final int probabilityThreshold,
    required final bool isAfter7thAnni,
    required final bool tailoredExecution,
    required final List<BattleAttackRecordData> actions,
  }) : recordData = BattleRecordData.attack(
          options: BattleActionOptions(
            allyTargetIndex: allyTargetIndex,
            enemyTargetIndex: enemyTargetIndex,
            fixedRandom: fixedRandom,
            probabilityThreshold: probabilityThreshold,
            isAfter7thAnni: isAfter7thAnni,
            tailoredExecution: tailoredExecution,
          ),
          attackRecords: actions.toList(),
        );

  @override
  BattleRecord copy() {
    return BattleAttacksInitiationRecord(
      allyTargetIndex: recordData.options.allyTargetIndex,
      enemyTargetIndex: recordData.options.enemyTargetIndex,
      fixedRandom: recordData.options.fixedRandom,
      probabilityThreshold: recordData.options.probabilityThreshold,
      isAfter7thAnni: recordData.options.isAfter7thAnni,
      tailoredExecution: recordData.options.tailoredExecution,
      actions: recordData.attackRecords!.toList(),
    );
  }

  @override
  BattleRecordData? toUploadRecord() {
    return recordData;
  }

  @override
  double get estimatedHeight => 0;
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
  final DamageParameters damageParams;
  final AttackNpGainParameters attackNpParams;
  final DefendNpGainParameters defenseNpParams;
  final StarParameters starParams;
  final DamageResult result;
  final DamageResult? minResult;
  final DamageResult? maxResult;

  AttackResultDetail({
    required BattleServantData target,
    required DamageParameters damageParams,
    required AttackNpGainParameters attackNpParams,
    required DefendNpGainParameters defenseNpParams,
    required StarParameters starParams,
    required DamageResult result,
    required DamageResult? minResult,
    required DamageResult? maxResult,
  })  : target = target.copy(),
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
