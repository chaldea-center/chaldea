// ignore_for_file: unused_element,unused_import
import 'dart:typed_data';

import 'package:chaldea/components/components.dart';
import 'package:path/path.dart' as p;

import 'components/img_util.dart';

void testFunction() async {
  // if (Platform.isMacOS) _reloadDebugDataset();
  Uint8List? img =
      await db.runtimeData.screenshotController!.capture(pixelRatio: 2);
  File(join(db.paths.tempDir, 'test1.png')).writeAsBytesSync(img!);
  img = compressToJpg(src: img);
  File(join(db.paths.tempDir, 'test2.jpg')).writeAsBytesSync(img);
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
