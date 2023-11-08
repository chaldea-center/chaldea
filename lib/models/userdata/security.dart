import 'package:hive/hive.dart';

import 'package:chaldea/packages/logger.dart';

class ChaldeaSecurity {
  static const _boxName = 'security';
  static const _chaldeaUser = 'chaldea_user';
  static const _chaldeaAuth = 'chaldea_auth';

  Box? _box;

  String? get username => _box?.get(_chaldeaUser);
  String? get userAuth => _box?.get(_chaldeaAuth);

  bool get isUserLoggedIn => username != null && userAuth != null;

  Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);
    } catch (e, s) {
      logger.e('open Hive box $_boxName failed', e, s);
    }
  }

  void saveUserInfo(final String name, final String? auth) {
    _box?.put(_chaldeaUser, name);
    if (auth != null) {
      _box?.put(_chaldeaAuth, auth);
    }
  }

  void deleteUserInfo() {
    _box?.delete(_chaldeaUser);
    _box?.delete(_chaldeaAuth);
  }
}
