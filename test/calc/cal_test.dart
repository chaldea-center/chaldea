import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/tools/gamedata_loader.dart';
import '../test_init.dart';

void main() async {
  await initiateForTest();
  test('Load Game Data', () async {
    // test without ui, [silent] must set to silent
    final data = await GameDataLoader.instance.reload(offline: true, silent: true);
    print(data?.version.dateTime.toString());
    expect(data, isNotNull);
  });
}
