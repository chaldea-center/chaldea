import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  late SharedPreferences instance;

  static const String previousVersion = 'previousVersion';
  static const String ignoreAppVersion = 'ignoreAppVersion';
  static const String contactInfo = 'contactInfo';

  Future<void> initiate() async {
    instance = await SharedPreferences.getInstance();
  }

  /// url
  String _addUrlPrefix(String key) => 'url_$key';

  String? getRealUrl(String key) {
    return instance.getString(_addUrlPrefix(key));
  }

  void setRealUrl(String key, String value) {
    instance.setString(_addUrlPrefix(key), value);
  }

  bool containsRealUrl(String key) {
    return instance.containsKey(_addUrlPrefix(key));
  }
}
