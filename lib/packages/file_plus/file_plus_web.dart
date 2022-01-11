import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../logger.dart';
import 'file_plus.dart';

const fsName = 'webfs';

/// all async methods are not async actually
class FilePlusWeb implements FilePlus {
  static late Box _box;

  final String _path;

  FilePlusWeb(String fp) : _path = normalizePath(fp);

  static Future<void> initWebFileSystem() async {
    assert(kIsWeb, 'DO NOT init for non-web');
    try {
      FilePlusWeb._box = await Hive.openBox(fsName);
      logger.d('open $fsName box');
    } catch (e, s) {
      logger.e('initWebFileSystem failed', e, s);
      await Hive.deleteBoxFromDisk(fsName);
      FilePlusWeb._box = await Hive.openBox(fsName);
    }
  }

  static String normalizePath(String fp) {
    return fp.split(RegExp(r'[/\\]+')).join('/');
  }

  @override
  String get path => _path;

  @override
  Future<bool> exists() => Future.value(existsSync());

  @override
  bool existsSync() => _box.containsKey(_path);

  @override
  Future<Uint8List> readAsBytes() => Future.value(readAsBytesSync());

  @override
  Uint8List readAsBytesSync() => _box.get(_path);

  @override
  Future<List<String>> readAsLines({Encoding encoding = utf8}) =>
      Future.value(readAsLinesSync());

  @override
  List<String> readAsLinesSync({Encoding encoding = utf8}) =>
      readAsStringSync().split('\n');

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      Future.value(readAsStringSync());

  @override
  String readAsStringSync({Encoding encoding = utf8}) =>
      encoding.decode(readAsBytesSync());

  @override
  Future<FilePlus> writeAsBytes(List<int> bytes,
      {FileMode mode = FileMode.write, bool flush = false}) async {
    _box.put(_path, Uint8List.fromList(bytes));
    return this;
  }

  @override
  void writeAsBytesSync(List<int> bytes,
      {FileMode mode = FileMode.write, bool flush = false}) {
    writeAsBytes(bytes);
  }

  @override
  Future<FilePlus> writeAsString(String contents,
      {FileMode mode = FileMode.write,
      Encoding encoding = utf8,
      bool flush = false}) async {
    return writeAsBytes(encoding.encode(contents), mode: mode, flush: flush);
  }

  @override
  void writeAsStringSync(String contents,
      {FileMode mode = FileMode.write,
      Encoding encoding = utf8,
      bool flush = false}) {
    writeAsString(contents, mode: mode, encoding: encoding, flush: flush);
  }
}
