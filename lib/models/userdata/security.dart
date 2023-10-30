import 'package:hive/hive.dart';

import 'package:chaldea/utils/hive_extention.dart';

class ChaldeaSecurity {
  late final Box box;

  Future<void> init() async {
    box = await Hive.openBoxRetry('security');
  }
}
