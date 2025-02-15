import 'dart:convert';
import 'dart:io' show FileMode;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb, protected;

import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

import 'file_plus_io.dart';
import 'file_plus_web.dart';

abstract class FilePlus {
  factory FilePlus(String fp, {LazyBox<Uint8List>? box}) {
    if (kIsWeb) {
      return FilePlusWeb(fp, box: box);
    } else {
      return FilePlusNative(fp);
    }
  }

  static Future<void> initiate() async {
    if (kIsWeb) return FilePlusWeb.initWebFileSystem();
  }

  Future<bool> exists();

  bool existsSync();

  Future<Uint8List> readAsBytes();

  @protected
  Uint8List readAsBytesSync();

  Future<String> readAsString({Encoding encoding = utf8});

  @protected
  String readAsStringSync({Encoding encoding = utf8});

  Future<List<String>> readAsLines({Encoding encoding = utf8});

  @protected
  List<String> readAsLinesSync({Encoding encoding = utf8});

  Future<FilePlus> writeAsBytes(List<int> bytes, {FileMode mode = FileMode.write, bool flush = false});

  @protected
  void writeAsBytesSync(List<int> bytes, {FileMode mode = FileMode.write, bool flush = false});

  Future<FilePlus> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  });

  @protected
  void writeAsStringSync(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  });

  Future<void> create({bool recursive = false});

  void createSync({bool recursive = false});

  Future<void> delete();

  Future<void> deleteSafe();

  String get path;
}

// ignore: camel_case_types
class pathlib {
  const pathlib._();
  static const basename = p.basename;
  static const basenameWithoutExtension = p.basenameWithoutExtension;
  static const dirname = p.dirname;
  static const absolute = p.absolute;
  static const join = p.join;
  static const joinAll = p.joinAll;
}
