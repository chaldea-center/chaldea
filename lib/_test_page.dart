// ignore_for_file: unused_element, unused_import
import 'package:chaldea/app/app.dart';
import 'package:flutter/material.dart';

import 'models/models.dart';

void testFunction([BuildContext? context]) async {
  // if (PlatformU.isMacOS) _reloadDebugDataset();
  final detail = db2.itemCenter.calcOneSvt(
    db2.gameData.servants[2]!,
    SvtPlan(favorite: true, skills: [1, 1, 1]),
    SvtPlan(favorite: true, skills: [10, 10, 10]),
  );
  print(detail);
}
