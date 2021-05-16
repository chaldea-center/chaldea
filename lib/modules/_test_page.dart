// ignore_for_file: unused_element,unused_import
import 'package:chaldea/components/components.dart';
import 'package:path/path.dart' as p;

void testFunction() async {
  if (Platform.isMacOS) _reloadDebugDataset();
  return;
}

String _makeLocalizedDart(String chs, String jpn, String eng) {
  return " LocalizedText(chs: '$chs', jpn: '$jpn', eng: '$eng'),";
}

Future _reloadDebugDataset() async {
  await db.extractZip(
    fp: r'/Users/narumi/Projects/chaldea-project/mcparser/output/dataset-text.zip',
    savePath: db.paths.gameDir,
  );
  db.loadGameData();
  EasyLoading.showSuccess('Reloaded');
}
