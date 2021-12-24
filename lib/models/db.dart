class _Database {
  // singleton
  static final _instance = _Database._internal();

  factory _Database() => _instance;

  _Database._internal();
}

final db2 = _Database();
