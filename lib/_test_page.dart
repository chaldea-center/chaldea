// ignore_for_file: unused_element,unused_import
import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/datatypes/effect_type/effect_type.dart';
import 'package:path/path.dart' as p;

void testFunction([BuildContext? context]) async {
  // if (PlatformU.isMacOS) _reloadDebugDataset();
  final summon = db.gameData.summons['复刻 Saber Wars2推荐召唤']!;
  print(summon.startTimeJp?.toDateTime());
  print(summon.startTimeCn?.toDateTime());
  return;
}

String _makeLocalizedDart(String chs, String jpn, String eng) {
  return " LocalizedText(chs: '$chs', jpn: '$jpn', eng: '$eng'),";
}

Future _reloadDebugDataset() async {
  await db.extractZip(
    fp: r'res/data/dataset.zip',
    savePath: db.paths.gameDir,
  );
  db.loadGameData();
  EasyLoading.showSuccess('Reloaded');
}
