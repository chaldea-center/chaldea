// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:csv/csv.dart';
import 'package:dio/dio.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'ffo_card.dart';

enum FfoPartWhere {
  head,
  body,
  bg,
  ;

  String get shownName {
    switch (this) {
      case FfoPartWhere.head:
        return S.current.ffo_head;
      case FfoPartWhere.body:
        return S.current.ffo_body;
      case FfoPartWhere.bg:
        return S.current.background;
    }
  }
}

class FfoDB {
  final Map<int, FfoSvtPart> parts = {};
  final Map<int, FfoSvt> servants = {};
  FfoDB._();
  static FfoDB i = FfoDB._();

  bool get isEmpty => parts.isEmpty || servants.isEmpty;

  void clear() {
    parts.clear();
    servants.clear();
  }

  Future<void> load(bool force) async {
    for (final data
        in jsonDecode(await _readFile('FFOSpriteParts.json', force))) {
      final svt = FfoSvt.fromJson(data);
      servants[svt.collectionNo] = svt;
    }

    final csvrows = const CsvToListConverter(eol: '\n').convert(
        (await _readFile('CSV/ServantDB-Parts.csv', force))
            .replaceAll('\r\n', '\n'));
    for (final row in csvrows) {
      if (row[0] == 'id') {
        assert(row.length == 10, row.toString());
        continue;
      }
      final item = FfoSvtPart.fromList(row);
      parts[item.collectionNo] = item;
    }
    print('loaded ffo csv: ${parts.length} parts, ${servants.length} svts');
  }

  Future<String> _readFile(String fn, bool force) async {
    String url = FFOUtil.imgUrl(fn)!;
    final file = FilePlus(joinPaths(db.paths.atlasAssetsDir, 'JP/FFO/$fn'));
    if (file.existsSync() && !force) {
      try {
        print('reading ${file.path}');
        return await file.readAsString();
      } catch (e, s) {
        logger.e('$fn corrupt', e, s);
      }
    }
    print('downloading: $url');
    final resp = await DioE()
        .get(url, options: Options(responseType: ResponseType.plain));
    await file.create(recursive: true);
    await file.writeAsString(resp.data as String);
    return resp.data;
  }
}

class FfoSvt {
  final int collectionNo;
  final String name;
  final int rarity;
  final int classType;
  final String? icon;
  final String? bg;
  final String? bodyBack;
  final String? headBack;
  final String? bodyBack2;
  final String? bodyMiddle;
  final String? headFront;
  final String? bodyFront;
  final String? bgFront;

  const FfoSvt({
    required this.collectionNo,
    required this.name,
    required this.rarity,
    required this.classType,
    this.icon,
    this.bg,
    this.bodyBack,
    this.headBack,
    this.bodyBack2,
    this.bodyMiddle,
    this.headFront,
    this.bodyFront,
    this.bgFront,
  });

  SvtClass? get svtClass => _kSvtClassMapping[classType];

  String get shownName {
    String? _name;
    if (collectionNo < 400) {
      _name = db.gameData.servantsNoDup[collectionNo]?.lName.l;
    }
    return _name ?? Transl.svtNames(name).l;
  }

  bool get hasHead => headBack != null || headFront != null;
  bool get hasBody =>
      bodyBack != null ||
      bodyBack2 != null ||
      bodyMiddle != null ||
      bodyFront != null;
  bool get hasLandscape => bg != null || bgFront != null;
  bool has(FfoPartWhere where) {
    switch (where) {
      case FfoPartWhere.head:
        return hasHead;
      case FfoPartWhere.body:
        return hasBody;
      case FfoPartWhere.bg:
        return hasLandscape;
    }
  }

  factory FfoSvt.fromJson(Map<String, dynamic> json) {
    return FfoSvt(
      collectionNo: json['collectionNo'] as int,
      name: json['name'] as String,
      rarity: json['rarity'] as int,
      classType: json['classType'] as int,
      icon: json['icon'] as String?,
      bg: json['bg'] as String?,
      bodyBack: json['body_back'] as String?,
      headBack: json['head_back'] as String?,
      bodyBack2: json['body_back2'] as String?,
      bodyMiddle: json['body_middle'] as String?,
      headFront: json['head_front'] as String?,
      bodyFront: json['body_front'] as String?,
      bgFront: json['bg_front'] as String?,
    );
  }
}

class FfoCanvasImages {
  ui.Image? bg_0;
  ui.Image? bodyBack_1;
  ui.Image? headBack_2;
  ui.Image? bodyBack2_3;
  ui.Image? bodyMiddle_4;
  ui.Image? headFront_5;
  ui.Image? bodyFront_6;
  ui.Image? bgFront_7;

  FfoCanvasImages({
    this.bg_0,
    this.bodyBack_1,
    this.headBack_2,
    this.bodyBack2_3,
    this.bodyMiddle_4,
    this.headFront_5,
    this.bodyFront_6,
    this.bgFront_7,
  });

  List<ui.Image?> toList() => [
        bg_0,
        bodyBack_1,
        headBack_2,
        bodyBack2_3,
        bodyMiddle_4,
        headFront_5,
        bodyFront_6,
        bgFront_7,
      ];

  bool get isEmpty => toList().every((e) => e == null);
}

class FfoSvtPart {
  final int id;
  final int collectionNo;
  final int direction;
  final double scale;
  final int headX;
  final int _headY;
  int get headY {
    // if (collectionNo == 402) {
    //   const y = 490;
    //   print('402 headY: $_headY -> $y');
    //   return y;
    // }
    return _headY;
  }

  final int bodyX;
  final int bodyY;
  final int headX2;
  final int headY2;

  FfoSvt? get svt => FfoDB.i.servants[collectionNo];

  static int _toInt(dynamic v) {
    if (v is String) return int.parse(v);
    if (v is num) return v.toInt();
    throw FormatException('${v.runtimeType} v=$v is not a int value');
  }

  static double _toDouble(dynamic v) {
    if (v is String) return double.parse(v);
    if (v is num) return v.toDouble();
    throw FormatException('${v.runtimeType} v=$v is not a double value');
  }

  FfoSvtPart.fromList(List row)
      : id = _toInt(row[0]),
        collectionNo = _toInt(row[1]),
        direction = _toInt(row[2]),
        scale = _toDouble(row[3]),
        headX = _toInt(row[4]),
        _headY = _toInt(row[5]),
        bodyX = _toInt(row[6]),
        bodyY = _toInt(row[7]),
        headX2 = _toInt(row[8]),
        headY2 = _toInt(row[9]);
}

class FFOParams {
  FfoSvtPart? headPart;
  FfoSvtPart? bodyPart;
  FfoSvtPart? bgPart;
  final bool clipOverflow; // not used
  bool cropNormalizedSize;

  FFOParams({
    this.headPart,
    this.bodyPart,
    this.bgPart,
    this.clipOverflow = false,
    this.cropNormalizedSize = false,
  });

  FFOParams.only({
    required FfoPartWhere where,
    required FfoSvtPart part,
    this.clipOverflow = false,
    this.cropNormalizedSize = false,
  })  : headPart = where == FfoPartWhere.head ? part : null,
        bodyPart = where == FfoPartWhere.body ? part : null,
        bgPart = where == FfoPartWhere.bg ? part : null;

  List<FfoSvtPart?> get parts => [headPart, bodyPart, bgPart];

  FfoSvtPart? of(FfoPartWhere where) {
    switch (where) {
      case FfoPartWhere.head:
        return headPart;
      case FfoPartWhere.body:
        return bodyPart;
      case FfoPartWhere.bg:
        return bgPart;
    }
  }

  void update(FfoPartWhere where, FfoSvtPart? part) {
    switch (where) {
      case FfoPartWhere.head:
        headPart = part;
        break;
      case FfoPartWhere.body:
        bodyPart = part;
        break;
      case FfoPartWhere.bg:
        bgPart = part;
        break;
    }
  }

  FFOParams copyWith() {
    return FFOParams(
      headPart: headPart,
      bodyPart: bodyPart,
      bgPart: bgPart,
      clipOverflow: clipOverflow,
      cropNormalizedSize: cropNormalizedSize,
    );
  }

  bool get isEmpty => parts.every((e) => e == null);

  Size get canvasSize =>
      cropNormalizedSize ? const Size(512, 720) : const Size(1024, 1024);
}

const _kSvtClassMapping = {
  0: SvtClass.shielder,
  1: SvtClass.saber,
  2: SvtClass.archer,
  3: SvtClass.lancer,
  4: SvtClass.rider,
  5: SvtClass.caster,
  6: SvtClass.assassin,
  7: SvtClass.berserker,
  8: SvtClass.ruler,
  9: SvtClass.avenger,
  10: SvtClass.moonCancer,
  11: SvtClass.alterEgo,
  12: SvtClass.foreigner,
};
