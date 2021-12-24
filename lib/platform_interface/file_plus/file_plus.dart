import 'dart:convert';
import 'dart:io' show FileMode;

import 'dart:typed_data';

import 'package:chaldea/platform_interface/file_plus/file_plus_io.dart';
import 'package:chaldea/platform_interface/file_plus/file_plus_web.dart';
import 'package:flutter/foundation.dart';

abstract class FilePlus {
  factory FilePlus(String fp) {
    if (kIsWeb) {
      return FilePlusWeb(fp);
    } else {
      return FilePlusNative(fp);
    }
  }

  static Future<void> initiate() async {
    if (kIsWeb) return initWebFileSystem();
  }

  Future<bool> exists();

  bool existsSync();

  Future<Uint8List> readAsBytes();

  Uint8List readAsBytesSync();

  Future<String> readAsString({Encoding encoding = utf8});

  String readAsStringSync({Encoding encoding = utf8});

  Future<List<String>> readAsLines({Encoding encoding = utf8});

  List<String> readAsLinesSync({Encoding encoding = utf8});

  Future<FilePlus> writeAsBytes(List<int> bytes,
      {FileMode mode = FileMode.write, bool flush = false});

  void writeAsBytesSync(List<int> bytes,
      {FileMode mode = FileMode.write, bool flush = false});

  Future<FilePlus> writeAsString(String contents,
      {FileMode mode = FileMode.write,
      Encoding encoding = utf8,
      bool flush = false});

  void writeAsStringSync(String contents,
      {FileMode mode = FileMode.write,
      Encoding encoding = utf8,
      bool flush = false});

  String get path;
}
