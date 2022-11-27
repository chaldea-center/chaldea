import 'package:flutter/foundation.dart';

import 'package:screenshot/screenshot.dart';

import '../app/tools/app_update.dart';
import '../packages/app_info.dart';
import '../packages/platform/platform.dart';
import 'api/recognizer.dart';
import 'gamedata/gamedata.dart';
import 'userdata/version.dart';

class RuntimeData {
  AppVersion? upgradableVersion;
  AppUpdateDetail? releaseDetail;
  DataVersion? upgradableDataVersion;

  double? criticalWidth;
  bool showSkillOriginText = false;

  Set<Uint8List> recognizerItems = {};
  Set<Uint8List> recognizerActive = {};
  Set<Uint8List> recognizerAppend = {};

  ItemResult? recognizerItemResult;
  SkillResult? recognizerActiveResult;
  SkillResult? recognizerAppendResult;

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

  WebRenderMode? webRendererCanvasKit;

  bool svtPlanTabButtonBarUseActive = true;
}
