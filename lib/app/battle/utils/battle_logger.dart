class BattleLogger {
  final List<BattleLog> logs = [];

  void _log(final BattleLogType type, final String log){
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

enum BattleLogType {
  debug, function, action
}