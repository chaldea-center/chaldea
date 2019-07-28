import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chaldea/components/spec_delegate.dart'
    show DataChangeCallback;
import 'package:chaldea/components/constants.dart';
import 'datatypes/datatypes.dart';
import 'package:flutter/services.dart' show rootBundle;

/// app config:
///  - app database
///  - user database
class Database {
  DataChangeCallback onDataChange;
  AppData data;

  // GameData gameData;

  Future<Null> loadUserData({String filename = defaultAppDataFilename}) async {
    try {
      data = AppData.fromJson(await _getJsonFile(filename));
      print('load userdata "$filename": $data');
    } catch (e) {
      print("Error loading '$filename'");
      data = AppData();
    }
  }

  Future<Null> saveUserData({String filename = defaultAppDataFilename}) async {
    try {
      final contents = json.encode(data);
      (await _getLocalFile(filename))
          .writeAsStringSync(contents);
      print('Saved "$filename":\n$contents\n');
    } catch (e) {
      print('Error saving "$filename"!');
      print(e);
    }
  }

  /// static methods and internals
  static Future<File> _getLocalFile(String filename) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File(join(dir, filename));
  }

  static Future<Map> _getJsonFile(String filename) async {
    String contents = (await _getLocalFile(filename)).readAsStringSync();
    print('load json data:\n$contents');
    return jsonDecode(contents);
  }

  Future<String> loadAsset(String key) async {
    return await rootBundle.loadString(key);
  }

  static final _db = new Database._internal();

  factory Database() {
    return _db;
  }

  Database._internal();
}

Database db = new Database();
