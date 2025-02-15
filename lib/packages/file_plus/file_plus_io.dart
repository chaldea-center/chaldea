import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../logger.dart';
import 'file_plus.dart';

class FilePlusNative implements FilePlus {
  final File _file;

  FilePlusNative(String fp) : _file = File(fp);

  @override
  Future<bool> exists() => _file.exists();

  @override
  bool existsSync() => _file.existsSync();

  @override
  String get path => _file.path;

  @override
  Future<Uint8List> readAsBytes() => _file.readAsBytes();

  @override
  Uint8List readAsBytesSync() => _file.readAsBytesSync();

  @override
  Future<List<String>> readAsLines({Encoding encoding = utf8}) => _file.readAsLines(encoding: encoding);

  @override
  List<String> readAsLinesSync({Encoding encoding = utf8}) => _file.readAsLinesSync(encoding: encoding);

  @override
  Future<String> readAsString({Encoding encoding = utf8}) => _file.readAsString(encoding: encoding);

  @override
  String readAsStringSync({Encoding encoding = utf8}) => _file.readAsStringSync(encoding: encoding);

  @override
  Future<FilePlus> writeAsBytes(List<int> bytes, {FileMode mode = FileMode.write, bool flush = false}) async {
    await create(recursive: true);
    await _file.writeAsBytes(bytes, mode: mode, flush: flush);
    return this;
  }

  @override
  void writeAsBytesSync(List<int> bytes, {FileMode mode = FileMode.write, bool flush = false}) {
    createSync(recursive: true);
    _file.writeAsBytesSync(bytes, mode: mode, flush: flush);
  }

  @override
  Future<FilePlus> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) async {
    await create(recursive: true);
    await _file.writeAsString(contents, mode: mode, encoding: encoding, flush: flush);
    return this;
  }

  @override
  void writeAsStringSync(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) {
    createSync(recursive: true);
    _file.writeAsStringSync(contents, mode: mode, encoding: encoding, flush: flush);
  }

  @override
  Future<void> create({bool recursive = false}) => _file.create(recursive: recursive);

  @override
  void createSync({bool recursive = false}) => _file.createSync(recursive: recursive);

  @override
  Future<void> delete() => _file.delete();

  @override
  Future<void> deleteSafe() async {
    try {
      if (await exists()) await delete();
    } on PathNotFoundException catch (e, s) {
      logger.e('delete failed: $path', e, s);
    }
  }
}
