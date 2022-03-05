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
  static late LazyBox<Uint8List> _defaultBox;

  final String _path;
  final LazyBox<Uint8List>? _box;

  LazyBox<Uint8List> get effectiveBox => _box ?? _defaultBox;

  FilePlusWeb(String fp, {LazyBox<Uint8List>? box})
      : _path = normalizePath(fp),
        _box = box;

  static Future<void> initWebFileSystem() async {
    assert(kIsWeb, 'DO NOT init for non-web');
    try {
      FilePlusWeb._defaultBox = await Hive.openLazyBox(fsName);
      logger.d('opened $fsName lazy box');
    } catch (e, s) {
      logger.e('initWebFileSystem failed', e, s);
      await Hive.deleteBoxFromDisk(fsName);
      FilePlusWeb._defaultBox = await Hive.openLazyBox(fsName);
    }
  }

  static Iterable<String> list() => _defaultBox.keys.whereType<String>();

  static String normalizePath(String fp) {
    return fp
        .split(RegExp(r'[/\\]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join('/');
  }

  @override
  String get path => _path;

  @override
  Future<bool> exists() => Future.value(existsSync());

  @override
  bool existsSync() => effectiveBox.containsKey(_path);

  /// raise error if not found
  @override
  Future<Uint8List> readAsBytes() async {
    final bytes = await effectiveBox.get(_path);
    if (bytes == null) {
      throw OSError('FileNotFound: $_path');
    }
    return Uint8List.fromList(bytes);
  }

  /// failed
  @override
  Uint8List readAsBytesSync() {
    throw UnimplementedError('Sync read is not available on web');
  }

  @override
  Future<List<String>> readAsLines({Encoding encoding = utf8}) =>
      readAsString(encoding: encoding).then((value) => value.split('\n'));

  /// failed
  @override
  List<String> readAsLinesSync({Encoding encoding = utf8}) =>
      readAsStringSync(encoding: encoding).split('\n');

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      readAsBytes().then((value) => encoding.decode(value));

  /// failed
  @override
  String readAsStringSync({Encoding encoding = utf8}) =>
      encoding.decode(readAsBytesSync());

  @override
  Future<FilePlus> writeAsBytes(List<int> bytes,
      {FileMode mode = FileMode.write, bool flush = false}) async {
    if (mode == FileMode.append) {
      final previous = await effectiveBox.get(_path);
      if (previous != null) {
        await effectiveBox.put(_path, previous..addAll(bytes));
        return this;
      }
    }
    await effectiveBox.put(_path, Uint8List.fromList(bytes));
    return this;
  }

  /// not sync
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

  /// not sync
  @override
  void writeAsStringSync(String contents,
      {FileMode mode = FileMode.write,
      Encoding encoding = utf8,
      bool flush = false}) {
    writeAsString(contents, mode: mode, encoding: encoding, flush: flush);
  }

  @override
  Future<void> create({bool recursive = false}) => Future.value();

  @override
  Future<void> delete() => effectiveBox.delete(_path);
}
