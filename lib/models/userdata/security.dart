import 'package:hive/hive.dart';

import 'package:chaldea/utils/hive_extention.dart';

class ChaldeaSecurity {
  static const _storeKey = 'explorer.aa.io/auth';
  static const _chaldeaUser = 'chaldea_user';
  static const _chaldeaAuth = 'chaldea_auth';

  late final Box box;

  String? get username => box.get(_chaldeaUser);
  String? get userAuth => box.get(_chaldeaAuth);
  String? get atlasAuth => box.get(_storeKey);

  bool get isUserLoggedIn => username != null && userAuth != null;

  Future<void> init() async {
    box = await Hive.openBoxRetry('security');
  }

  void saveAtlasAuth(final String authCode) {
    box.put(_storeKey, authCode);
  }

  void saveUserInfo(final String name, final String? auth) {
    box.put(_chaldeaUser, name);
    if (auth != null) {
      box.put(_chaldeaAuth, auth);
    }
  }

  void deleteUserInfo() {
    box.delete(_chaldeaUser);
    box.delete(_chaldeaAuth);
  }
}
