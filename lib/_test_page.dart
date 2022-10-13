// ignore_for_file: unused_element, unused_import

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:file_picker/file_picker.dart';

import 'package:chaldea/utils/utils.dart';
import 'models/models.dart';

void testFunction([BuildContext? context]) async {
  if (kReleaseMode) return;
}

void loadSvtIconRemap() async {
  Set<String> _openedFiles = {};
  final result = await FilePicker.platform.pickFiles(allowMultiple: true);
  _openedFiles.addAll(result?.paths.whereType<String>() ?? []);
  Map<int, List<int>> mapping = {};
  for (final fp in _openedFiles) {
    final html = File(fp).readAsStringSync();
    for (final reg in [
      RegExp(r'JP/Faces/f_(\d+).png'),
      RegExp(r'JP/Enemys/(\d+).png')
    ]) {
      for (final match in reg.allMatches(html)) {
        final iconId = int.parse(match.group(1)!);
        mapping.putIfAbsent(iconId ~/ 10, () => []).add(iconId);
      }
    }
  }
  final validIcons = {for (final a in mapping.values) ...a};
  final reg = RegExp(r'\d+');
  Map<int, int> remap = {};
  for (final svt in db.gameData.entities.values) {
    final iconId = int.parse(reg.firstMatch(svt.face)!.group(0)!);
    if (validIcons.contains(iconId)) continue;
    final icons = mapping[svt.id];
    if (icons == null) continue;
    print('No.${svt.id} ${svt.lName.l}: $iconId not in $icons');
    assert(icons.first.toString().startsWith(svt.id.toString()));
    remap[svt.id] = icons.first % 10;
  }
  print('finished');
  remap = sortDict(remap);
  final buffer = StringBuffer();
  for (final svtId in remap.keys) {
    buffer.writeln(
        '  $svtId: ${remap[svtId]}, // ${db.gameData.entities[svtId]!.name}');
  }
  print(buffer);
  Clipboard.setData(ClipboardData(text: buffer.toString()));
}
