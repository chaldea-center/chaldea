import 'package:chaldea/app/battle/models/skill.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
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
}

class BattleLog {
  final BattleLogType type;
  final String log;

  BattleLog(this.type, this.log);
}

enum BattleLogType { debug, function, action }

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
}

class BattleProgressWaveRecord extends BattleRecord {
  // start [wave]
  final int wave;
  BattleProgressWaveRecord(this.wave, {super.message});
}

class BattleSkillRecord extends BattleRecord {
  final BattleServantData? activator;
  final List<BattleServantData> targets;
  final BattleSkillInfoData skill;

  BattleSkillRecord({
    required BattleServantData? activator,
    required List<BattleServantData> targets,
    required BattleSkillInfoData skill,
    super.message,
  })  : activator = activator?.copy(),
        targets = targets.map((e) => e.copy()).toList(),
        skill = skill.copy();
}

class BattleAttackRecord extends BattleRecord {
  final BattleServantData activator;
  final CommandCardData card;
  final List<AttackResultDetail> targets;
  final int damage;
  final int attackNp;
  final int defenseNp;
  final int star;

  BattleAttackRecord({
    required BattleServantData activator,
    required CommandCardData card,
    required this.targets,
    required this.damage,
    required this.attackNp,
    required this.defenseNp,
    required this.star,
    super.message,
  })  : activator = activator.copy(),
        card = card.copy();
}

class AttackResultDetail {
  final BattleServantData target;
  final List<int> damageList;
  final DamageParameters damageParams;
  final List<int> attackNpList;
  final AttackNpGainParameters attackNpParams;
  final List<int> defenseNpList;
  final DefendNpGainParameters defenseNpParams;
  final List<int> starList;
  final StarParameters starParams;

  AttackResultDetail({
    required BattleServantData target,
    required List<int> damageList,
    required DamageParameters damageParams,
    required List<int> attackNpList,
    required AttackNpGainParameters attackNpParams,
    required List<int> defenseNpList,
    required DefendNpGainParameters defenseNpParams,
    required List<int> starList,
    required StarParameters starParams,
  })  : target = target.copy(),
        damageList = damageList.toList(),
        damageParams = damageParams.copy(),
        attackNpList = attackNpList.toList(),
        attackNpParams = attackNpParams.copy(),
        defenseNpList = defenseNpList.toList(),
        defenseNpParams = defenseNpParams.copy(),
        starList = starList.toList(),
        starParams = starParams.copy();
}
