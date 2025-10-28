import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:screenshot/screenshot.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/utils.dart';
import '../app/routes/delegate.dart';
import '../app/tools/app_update.dart';
import '../packages/app_info.dart';
import 'api/api.dart';
import 'api/recognizer.dart';
import 'gamedata/gamedata.dart';
import 'gamedata/mst_data.dart';
import 'userdata/local_settings.dart';
import 'userdata/version.dart';

class RuntimeData {
  AppVersion? upgradableVersion;
  AppUpdateDetail? releaseDetail;
  DataVersion? upgradableDataVersion;
  AppVersion? dataRequiredAppVer;

  RemoteConfig? remoteConfig;

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

  bool get enableDebugTools => _enableDebugTools || kDebugMode || AppInfo.isDebugOn;

  set enableDebugTools(bool v) => _enableDebugTools = v;

  bool showWindowManager = false;

  /// Controller of [Screenshot] widget which set root [MaterialApp] as child
  final screenshotController = ScreenshotController();

  /// store anything you like
  Map<dynamic, dynamic> tempDict = {};

  final AppClipBoard clipBoard = AppClipBoard();

  int lastUpload = 0;
  final int secondsBetweenUpload = 120;
  int get secondsRemainUtilNextUpload {
    final lapse = DateTime.now().timestamp - lastUpload;
    return lapse > secondsBetweenUpload ? 0 : secondsBetweenUpload - lapse;
  }

  // filters
  final svtFilters = _RouterValueMap<SvtFilterData>(
    (r) => r.index == 0 ? db.settings.filters.laplaceSvtFilterData : SvtFilterData(useGrid: true),
  );
  final ceFilters = _RouterValueMap<CraftFilterData>(
    (r) =>
        CraftFilterData(useGrid: true)
          ..obtain.options = CEObtain.values.toSet().difference({CEObtain.valentine, CEObtain.exp, CEObtain.campaign}),
  );

  // gamedata
  DailyBonusData? dailyBonusData;

  Future<DailyBonusData?> loadDailyBonusData({bool refresh = false}) async {
    final data = await EasyThrottle.throttleAsync(
      'load_daily_bonus',
      () => ChaldeaWorkerApi.dailyBonusData(expireAfter: refresh ? Duration.zero : null),
    );
    if (data != null) {
      dailyBonusData = data;
      data.userPresentBox.removeWhere(
        (e) => e.fromType == PresentFromType.seqLogin.value || e.fromType == PresentFromType.totalLogin.value,
      );
    }
    return data;
  }
}

class AppClipBoard {
  QuestEnemy? questEnemy;
  MasterDataManager? mstData; //  don't change in-place
  UserBattleData? teamData;
}

class _RouterValueMap<T> {
  final Map<int, T> _data = {};
  final T Function(AppRouterDelegate r) onAbsent;

  _RouterValueMap(this.onAbsent);

  T get current {
    return _data.putIfAbsent(router.hashCode, () => onAbsent(router));
  }

  T of(BuildContext context) {
    final r = AppRouter.of(context) ?? router;
    return _data.putIfAbsent(r.hashCode, () => onAbsent(r));
  }
}
