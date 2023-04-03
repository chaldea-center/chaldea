import 'package:chaldea/app/battle/models/skill.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/utils/utils.dart';
import '../models/battle.dart';
import '../models/command_card.dart';
import '../models/svt_entity.dart';

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
}

enum BattleLogType { debug, function, action, error }

class BattleRecordManager {
  List<BattleRecord> records = [];
  BattleRecordManager();

  BattleRecordManager copy() {
    return BattleRecordManager()..records = records.toList();
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
  }) {
    records.add(BattleSkillRecord(
      activator: activator,
      ally: battleData.targetedAlly,
      enemy: battleData.targetedEnemy,
      skill: skill,
    ));
  }

  BattleServantData? _attacker;
  CommandCardData? _card;
  void startPlayerCard(BattleServantData activator, CommandCardData card) {
    assert(_attacker == null && _card == null);
    _attacker = activator;
    _card = card;
  }

  void attack(BattleServantData activator, BattleAttackRecord record) {
    if (_attacker == activator && _card != null && record.card == null) {
      record.card = _card?.copy();
    }
    records.add(record);
  }

  void endPlayerCard(BattleServantData activator, CommandCardData card) {
    assert(_attacker == activator && _card == card);
    _attacker = null;
    _card = null;
  }
}

/// Only record user visible actions
/// make sealed when dart 2.19 enabled
abstract class BattleRecord {
  final String? message;
  BattleRecord({this.message});
}

class BattleSkipWaveRecord extends BattleRecord {
  // skip [wave], then start [wave+1]
  final int wave;
  BattleSkipWaveRecord(this.wave, {super.message});

  @override
  String toString() {
    return 'Skip Wave $wave';
  }
}

class BattleProgressWaveRecord extends BattleRecord {
  // start [wave]
  final int wave;
  BattleProgressWaveRecord(this.wave, {super.message});

  @override
  String toString() {
    return 'Start Wave $wave';
  }
}

class BattleProgressTurnRecord extends BattleRecord {
  // start [wave]
  final int turn;
  BattleProgressTurnRecord(this.turn, {super.message});

  @override
  String toString() {
    return 'Start Turn $turn';
  }
}

class BattleSkillRecord extends BattleRecord {
  final BattleServantData? activator;
  final BattleServantData? ally;
  final BattleServantData? enemy;
  final BattleSkillInfoData skill;

  BattleSkillRecord({
    required BattleServantData? activator,
    required BattleServantData? ally,
    required BattleServantData? enemy,
    required BattleSkillInfoData skill,
    super.message,
  })  : activator = activator?.copy(),
        ally = ally?.copy(),
        enemy = enemy?.copy(),
        skill = skill.copy();

  @override
  String toString() {
    return '${activator?.lBattleName} Skill: ${skill.lName}';
  }
}

class BattleAttackRecord extends BattleRecord {
  final BattleServantData activator;
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
    super.message,
  })  : activator = activator.copy(),
        card = card?.copy();
  @override
  String toString() {
    return '${activator.lBattleName} Play ${card?.cardType.name.toTitle()} Card.'
        ' damage=$damage, NP=$attackNp, defNp=$defenseNp, star=$star';
  }
}

class AttackResultDetail {
  final BattleServantData target;
  final DamageParameters damageParams;
  final AttackNpGainParameters attackNpParams;
  final DefendNpGainParameters defenseNpParams;
  final StarParameters starParams;
  final DamageResult result;

  AttackResultDetail({
    required BattleServantData target,
    required DamageParameters damageParams,
    required AttackNpGainParameters attackNpParams,
    required DefendNpGainParameters defenseNpParams,
    required StarParameters starParams,
    required DamageResult result,
  })  : target = target.copy(),
        damageParams = damageParams.copy(),
        attackNpParams = attackNpParams.copy(),
        defenseNpParams = defenseNpParams.copy(),
        starParams = starParams.copy(),
        result = result.copy();
}
