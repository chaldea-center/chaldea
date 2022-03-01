import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/version.dart';
import 'package:flutter/foundation.dart';
import 'package:screenshot/screenshot.dart';

import '../components/git_tool.dart';
import '../packages/app_info.dart';
import '../packages/platform/platform.dart';

class RuntimeData {
  AppVersion? upgradableVersion;
  DatasetVersion? latestDatasetVersion;
  double? criticalWidth;
  Set<String> itemRecognizeImageFiles = {};
  Set<String> activeSkillRecognizeImageFiles = {};
  Set<String> appendSkillRecognizeImageFiles = {};
  bool googlePlayAccess = false;

  // debug
  bool _enableDebugTools = false;

  bool get enableDebugTools =>
      _enableDebugTools || kDebugMode || AppInfo.isDebugDevice;

  set enableDebugTools(bool v) => _enableDebugTools = v;

  bool _showDebugFAB = true;

  bool get showDebugFAB => _showDebugFAB && enableDebugTools;

  set showDebugFAB(bool value) => _showDebugFAB = value;

  bool showWindowManager = false;

  /// Controller of [Screenshot] widget which set root [MaterialApp] as child
  final screenshotController = ScreenshotController();

  /// store anything you like
  Map<dynamic, dynamic> tempDict = {};

  /// for db2
  DataVersion? downloadedDataVersion;

  WebRenderMode? webRendererCanvasKit;
}
