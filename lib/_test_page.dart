// ignore_for_file: unused_element,unused_import
import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/datatypes/effect_type/effect_type.dart';
import 'package:chaldea/widgets/charts/line_chart.dart';
import 'package:path/path.dart' as p;

void testFunction([BuildContext? context]) async {
  // if (PlatformU.isMacOS) _reloadDebugDataset();
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
