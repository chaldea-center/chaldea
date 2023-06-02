import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/utils/utils.dart';
import '../models/battle.dart';

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
  BattleRecordManager();

  BattleRecordManager copy() {
    return BattleRecordManager()..records = records.toList();
  }

  void message(String msg, [BattleServantData? target]) {
    records.add(BattleMessageRecord(msg, target));
  }

  void progressWave(int wave) {
    records.add(BattleProgressWaveRecord(wave));
  }

  void skipWave(int wave) {
    records.add(BattleSkipWaveRecord(wave));
  }

  void progressTurn(int turn) {
    records.add(BattleProgressTurnRecord(turn));
  }

  void skill({
    required BattleData battleData,
    required BattleServantData? activator,
    required BattleSkillInfoData skill,
    required SkillInfoType type,
    required bool fromPlayer,
  }) {
    records.add(BattleSkillRecord(
      activator: activator,
      targetPlayerSvt: battleData.targetedAlly,
      targetEnemySvt: battleData.targetedEnemy,
      skill: skill,
      type: type,
      fromPlayer: fromPlayer,
    ));
  }

  void orderChange({required BattleServantData onField, required BattleServantData backup}) {
    records.add(BattleOrderChangeRecord(onField: onField, backup: backup));
  }

  final List<_BattleCardTempData> _cardHistory = [];

  void startPlayerCard(BattleServantData activator, CommandCardData card) {
    _cardHistory.add(_BattleCardTempData(activator, card));
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
}

class _BattleCardTempData {
  final BattleServantData actor;
  CommandCardData? card;
  BattleAttackRecord? attack;
  bool hasAttack = false;

  _BattleCardTempData(this.actor, this.card);
}

/// Only record user visible actions
/// make sealed when dart 2.19 enabled
abstract class BattleRecord {
  BattleRecord();

  BattleRecord copy();
}

class BattleMessageRecord extends BattleRecord {
  final String message;
  final BattleServantData? target;
  BattleMessageRecord(this.message, this.target);

  @override
  BattleMessageRecord copy() {
    return BattleMessageRecord(message, target?.copy());
  }
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
}

class BattleSkillRecord extends BattleRecord {
  final BattleServantData? activator;
  final BattleServantData? targetPlayerSvt;
  final BattleServantData? targetEnemySvt;
  final BattleSkillInfoData skill;
  final SkillInfoType type;
  final bool fromPlayer;

  BattleSkillRecord({
    required BattleServantData? activator,
    required BattleServantData? targetPlayerSvt,
    required BattleServantData? targetEnemySvt,
    required BattleSkillInfoData skill,
    required this.type,
    required this.fromPlayer,
  })  : activator = activator?.copy(),
        targetPlayerSvt = targetPlayerSvt?.copy(),
        targetEnemySvt = targetEnemySvt?.copy(),
        skill = skill.copy();

  @override
  String toString() {
    return '${type.name}: ${activator?.lBattleName} Skill: ${skill.lName}';
  }

  @override
  BattleSkillRecord copy() {
    return BattleSkillRecord(
      activator: activator,
      targetPlayerSvt: targetPlayerSvt,
      targetEnemySvt: targetEnemySvt,
      skill: skill,
      type: type,
      fromPlayer: fromPlayer,
    );
  }
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
}

class BattleReduceHpRecord extends BattleRecord {
  @override
  BattleRecord copy() => this;
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
