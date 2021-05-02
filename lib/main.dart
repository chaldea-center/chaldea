import 'package:catcher/catcher.dart';
import 'package:chaldea/components/catcher_universal.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/chaldea.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // make sure flutter packages like path_provider is working now
  WidgetsFlutterBinding.ensureInitialized();
  await db.initial();

  final File crashFile = File(db.paths.crashLog);
  rollLogFiles(crashFile.path, 3, 10 * 1024 * 1024);
  if (!crashFile.existsSync()) {
    crashFile.writeAsString('chaldea.crash.log\n');
  }
  final catcherOptions = CatcherOptions(
    // when error occurs when building:
    // DialogReportMode will keep generating error and you can do nothing
    // PageReportMode will generate error repeatedly for about 3 times.
    SilentReportFilterMode(),
    [
      FileHandler(crashFile),
      ConsoleHandler(),
      ToastHandler2(),
      kEmailAutoHandlerCross(attachments: [
        crashFile,
        File(db.paths.userDataPath),
        File(db.paths.appLog),
      ]),
    ],
    customParameters: _getCatcherCustomParameters(),
    localizationOptions: _getCatcherLocalizationOptions(),
    handleSilentError: false,
  );
  if (kDebugMode)
    runApp(Chaldea());
  else
    Catcher(
      rootWidget: Chaldea(),
      debugConfig: catcherOptions,
      profileConfig: catcherOptions,
      releaseConfig: catcherOptions,
      enableLogger: kDebugMode,
      navigatorKey: kAppKey,
      ensureInitialized: true,
    );
}

Map<String, dynamic> _getCatcherCustomParameters() {
  Map<String, dynamic> customParameters = {};
  if (Platform.isWindows) {
    customParameters.addAll(<String, dynamic>{
      'system': 'windows ' + Platform.operatingSystemVersion,
      'version': AppInfo.version,
      'appName': AppInfo.appName,
      'buildNumber': AppInfo.buildNumber,
      'packageName': AppInfo.packageName
    });
  }
  return customParameters;
}

List<LocalizationOptions> _getCatcherLocalizationOptions() {
  String dirEn = Platform.isIOS
      ? '"File" App/On My iPhone/Chaldea/data'
      : db.paths.gameDir;
  String dirCn =
      Platform.isIOS ? '"文件"应用/我的iPhone/Chaldea/data' : db.paths.gameDir;

  final zh = LocalizationOptions(
    "zh",
    notificationReportModeTitle: "发生应用错误",
    notificationReportModeContent: "单击此处将错误报告发送给支持团队。",
    dialogReportModeTitle: "紧急",
    dialogReportModeDescription:
        "应用程序中发生意外错误。 错误报告已准备好发送给支持团队。 请单击“接受”以发送错误报告，或单击“取消”以关闭报告。\n"
        "请尝试删除$dirCn文件夹后重启应用以查看问题是否解决",
    dialogReportModeAccept: "接受",
    dialogReportModeCancel: "取消",
    pageReportModeTitle: "紧急",
    pageReportModeDescription:
        "应用程序中发生意外错误。 错误报告已准备好发送给支持团队。 请单击“接受”以发送错误报告，或单击“取消”以关闭报告。\n"
        "请尝试删除$dirCn文件夹后重启应用以查看问题是否解决",
    pageReportModeAccept: "接受",
    pageReportModeCancel: "取消",
    toastHandlerDescription: "发生了错误:",
  );

  final en = LocalizationOptions(
    'en',
    dialogReportModeDescription:
        "Unexpected error occurred in application. Error report is ready to send to support team. "
        "Please click Accept to send error report or Cancel to dismiss report.\n"
        'Possible solution: delete "$dirEn" folder then restart app',
    pageReportModeDescription:
        "Unexpected error occurred in application. Error report is ready to send to support team. "
        "Please click Accept to send error report or Cancel to dismiss report.\n"
        'Possible solution: delete "$dirEn" folder then restart app',
  );
  return [zh, en];
}
