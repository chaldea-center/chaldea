import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  late SharedPreferences instance;

  SharedPrefItem<String> previousVersion = SharedPrefItem('previousVersion');
  SharedPrefItem<String> ignoreAppVersion = SharedPrefItem('ignoreAppVersion');
  SharedPrefItem<String> contactInfo = SharedPrefItem('contactInfo');
  SharedPrefItem<String> userName = SharedPrefItem('userName');
  SharedPrefItem<String> userPwd = SharedPrefItem('userPwd');

  Future<void> initiate() async {
    instance = await SharedPreferences.getInstance();
    SharedPrefItem._instance = instance;
  }

  SharedPrefItem<T> getItem<T>(String key) {
    return SharedPrefItem<T>(key);
  }
}

/// T can not be T?
class SharedPrefItem<T> {
  static late SharedPreferences _instance;

  final String key;
  final String _type;

  SharedPrefItem(this.key)
      : assert(!T.toString().endsWith('?')),
        _type = T.toString();

  T? get() {
    if (_isStringType) return _instance.getString(key) as T?;
    if (_isIntType) return _instance.getInt(key) as T?;
    if (_isDoubleType) return _instance.getDouble(key) as T?;
    if (_isBoolType) return _instance.getBool(key) as T?;
    if (_isStringListType) return _instance.getStringList(key) as T?;
    return _instance.get(key) as T?;
  }

  Future<bool> set(T v) {
    if (_isStringType)
      return _instance.setString(key, v as String);
    else if (_isIntType)
      return _instance.setInt(key, v as int);
    else if (_isDoubleType)
      return _instance.setDouble(key, v as double);
    else if (_isBoolType)
      return _instance.setBool(key, v as bool);
    else if (_isStringListType)
      return _instance.setStringList(key, v as List<String>);
    else
      throw ArgumentError.value(T, 'T', 'invalid type');
  }

  Future<bool> remove() {
    return _instance.remove(key);
  }

  bool get _isStringType => _type == 'String';

  bool get _isIntType => _type == 'int';

  bool get _isDoubleType => _type == 'double';

  bool get _isBoolType => _type == 'bool';

  bool get _isStringListType => _type == 'List<String>';
}
