// ignore_for_file: unused_element, unused_import

import 'package:flutter/material.dart';

import 'package:csv/csv.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'models/models.dart';

void testFunction([BuildContext? context]) async {
  //
  Map<FuncTargetType, int> svtCount = {};
  Map<FuncTargetType, int> ceCount = {};
  Map<FuncTargetType, int> ccCount = {};
  Map<FuncTargetType, int> allCount = {};
  for (final svt in db.gameData.servants.values) {
    for (final skill in [
      ...svt.skills,
      ...svt.classPassive,
      ...svt.appendPassive.map((e) => e.skill),
      ...svt.noblePhantasms
    ]) {
      for (final func in NiceFunction.filterFuncs(
          funcs: skill.functions, includeTrigger: true)) {
        svtCount.addNum(func.funcTargetType, 1);
      }
    }
  }
  for (final ce in db.gameData.craftEssences.values) {
    for (var skill in ce.skills) {
      for (final func in NiceFunction.filterFuncs(
          funcs: skill.functions, includeTrigger: true)) {
        ceCount.addNum(func.funcTargetType, 1);
      }
    }
  }
  for (final cc in db.gameData.commandCodes.values) {
    for (var skill in cc.skills) {
      for (final func in NiceFunction.filterFuncs(
          funcs: skill.functions, includeTrigger: true)) {
        ccCount.addNum(func.funcTargetType, 1);
      }
    }
  }
  allCount
    ..addDict(svtCount)
    ..addDict(ceCount)
    ..addDict(ccCount);
  List<List> data = [
    ['type', 'all', 'svt', 'ce', 'cc']
  ];
  for (var key in allCount.keys) {
    data.add(
        [key.name, allCount[key], svtCount[key], ceCount[key], ccCount[key]]);
  }
  await FilePlus(joinPaths(db.paths.tempDir, 'funcTargetType.csv'))
      .writeAsString(const ListToCsvConverter().convert(data));
  print('ended');
}

void _funcBuffCsv() async {
  Map<FuncType, _Detail<FuncType>> funcs = {};
  Map<BuffType, _Detail<BuffType>> buffs = {};
  for (final x in db.gameData.others.svtFuncs) {
    funcs.putIfAbsent(x, () => _Detail(val: x)).svt = true;
  }
  for (final x in db.gameData.others.svtBuffs) {
    buffs.putIfAbsent(x, () => _Detail(val: x)).svt = true;
  }

  for (final x in db.gameData.others.ceFuncs) {
    funcs.putIfAbsent(x, () => _Detail(val: x)).ce = true;
  }
  for (final x in db.gameData.others.ceBuffs) {
    buffs.putIfAbsent(x, () => _Detail(val: x)).ce = true;
  }

  for (final x in db.gameData.others.ccFuncs) {
    funcs.putIfAbsent(x, () => _Detail(val: x)).cc = true;
  }
  for (final x in db.gameData.others.ccBuffs) {
    buffs.putIfAbsent(x, () => _Detail(val: x)).cc = true;
  }
  List<List<String>> data = [
    [
      'funcType',
      'buffType',
      'CN',
      'NA',
      'JP',
      'TW',
      'KR',
      'svt',
      'cc',
      'ce',
    ]
  ];
  for (final x in funcs.values) {
    data.add(x.toCSVList());
  }
  for (final x in buffs.values) {
    data.add(x.toCSVList());
  }
  await FilePlus(joinPaths(db.paths.tempDir, 'func.csv'))
      .writeAsString(const ListToCsvConverter().convert(data));
}

class _Detail<T extends Enum> {
  T val;
  bool svt;
  bool ce;
  bool cc;
  bool get enemy => !(svt || ce || ce);
  _Detail({
    required this.val,
    this.svt = false,
    this.ce = false,
    this.cc = false,
  });

  List<String> toCSVList() {
    return [
      val is FuncType ? val.name : "",
      val is BuffType ? val.name : "",
      '',
      '',
      '',
      '',
      '',
      svt ? "1" : "",
      ce ? "1" : "",
      cc ? "1" : "",
    ];
  }
}
