import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chaldea/components/spec_delegate.dart' show DataChangeCallback;
import 'package:chaldea/components/constants.dart';
import 'datatypes/datatypes.dart';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

/// app config:
///  - app database
///  - user database
class Database {
  DataChangeCallback onDataChange;
  AppData appData;
  Plans userData;
  GameData gameData;
  static String _rootPath = '';

  String get rootPath => _rootPath;

  // initialization
  Future<Null> initial() async {
    _rootPath = (await getApplicationDocumentsDirectory()).path;
  }

  Future<Null> loadUserData() async {
    appData = AppData.fromJson(
        getJsonFromFile(appDataFilename, Map<String, dynamic>()));
    userData = Plans.fromJson(
        getJsonFromFile(userDataFilename, Map<String, dynamic>()));

    gameData=GameData.fromJson({
      'servants':jsonDecode(await rootBundle.loadString('res/data/svt_list.json')),
      'crafts':<String,String>{}
    });
  }

  Future<Null> saveAppData() async {
    try {
      final contents = json.encode(appData);
      getLocalFile(appDataFilename).writeAsStringSync(contents);
      print('Saved "$appDataFilename"\n');
    } catch (e) {
      print('Error saving "$appDataFilename"!');
      print(e);
    }
  }
  Future<Null> saveUserData() async {
    try {
      final contents = json.encode(userData);
      getLocalFile(userDataFilename).writeAsStringSync(contents);
      print('Saved "$userDataFilename"\n');
    } catch (e) {
      print('Error saving "$userDataFilename"!');
      print(e);
    }
  }

  File getLocalFile(String filename, {rel = ''}) {
    return File(join(_rootPath, rel, filename));
  }

  dynamic getJsonFromFile(String filename,dynamic k) {
    dynamic result;
    try {
      String contents = getLocalFile(filename).readAsStringSync();
      result = jsonDecode(contents);
      print('load json "$filename":\n${contents} ...');
    } catch (e) {
      result = k;
      print('error load "$filename", use defailt value. Error:\n$e');
    }
    return result;
  }

  Future<Null> loadZipAssets(String assetKey,
      {String dir = 'temp/', bool forceLoad = false}) async {
    String basePath = join(_rootPath, dir);
    if (forceLoad || !Directory(basePath).existsSync()) {
      //extract
      final data = await rootBundle.load(assetKey);
      extractZip(data.buffer.asUint8List().cast<int>(), basePath);
    }
  }

  Future<Null> extractZip(List<int> bytes, String path) async {
    Archive archive = ZipDecoder().decodeBytes(bytes);
    for (ArchiveFile file in archive) {
      String fullFilepath = join(path, file.name);
      if (file.isFile) {
        List<int> data = file.content;
        File(fullFilepath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(fullFilepath)..create(recursive: true);
      }
    }
    //
    print('------------------------------------------------------------');
    print('Zip file has been extracted, directory tree ($path)}):');
    for (final file in Directory(path).listSync()) {
      print(file.path);
    }
    print('end of tree.\n-----------------------------------------------');
  }

  /// static methods and internals
  static final _db = new Database._internal();

  factory Database() {
    return _db;
  }

  Database._internal();
}

Database db = new Database();
