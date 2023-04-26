class BattleException implements Exception {
  final String message;

  BattleException(this.message);

  @override
  String toString() {
    return "BattleException: $message";
  }
}
