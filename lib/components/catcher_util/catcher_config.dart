import 'dart:io';

import 'package:catcher/catcher.dart';
import 'package:flutter/foundation.dart';

import '../config.dart';
import '../device_app_info.dart';
import '../logger.dart';
import 'catcher_email_handler.dart';

class CatcherUtils {
  static CatcherOptions getOptions() {
    final crashFile = File(db.paths.crashLog);
    return CatcherOptions(
      // when error occurs when building:
      // DialogReportMode will keep generating error and you can do nothing
      // PageReportMode will generate error repeatedly for about 3 times.
      SilentReportMode(),
      [
        FileHandler(crashFile),
        ConsoleHandler(),
        // ToastHandler(),
        kEmailAutoHandlerCross(attachments: [
          crashFile,
          File(db.paths.userDataPath),
          File(db.paths.appLog),
        ]),
      ],
      customParameters: _getCatcherCustomParameters(),
      handleSilentError: false,
      filterFunction: CatcherUtils.reportFilter,
      handlerTimeout: 10000,
    );
  }

  static bool reportFilter(Report report) {
    if (isKnownError(report)) return false;
    return true;
  }

  /// Ignore some known but cannot be fix immediately bugs
  /// Remove those when the bug is fixed
  static bool isKnownError(Report report) {
    /// Issue 1 - TextField changes too fast
    /// * see https://github.com/flutter/flutter/issues/80226
    if (report.error.toString().startsWith('RangeError: Value not in range')) {
      if (removeStackTraceLineNumber(report.stackTrace.toString()).contains(
          '''#0      _StringBase.substring (dart:core-patch/string_patch.dart)
#1      TextRange.textBefore (dart:ui/text.dart)
#2      RenderEditable.delete (package:flutter/src/rendering/editable.dart)
#3      _DeleteTextAction.invoke (package:flutter/src/widgets/default_text_editing_actions.dart)
#4      ActionDispatcher.invokeAction (package:flutter/src/widgets/actions.dart)
#5      ShortcutManager.handleKeypress (package:flutter/src/widgets/shortcuts.dart)
#6      _ShortcutsState._handleOnKey (package:flutter/src/widgets/shortcuts.dart)
#7      FocusManager._handleRawKeyEvent (package:flutter/src/widgets/focus_manager.dart)
#8      RawKeyboard._handleKeyEvent (package:flutter/src/services/raw_keyboard.dart)
''')) {
        logger.e('ignore the bug by TextField changing too fast');
        return true;
      }
    }
    return false;
  }

  /// In release mode, StackTrace won't offer offset
  /// This should only called for develop
  static String removeStackTraceLineNumber(String s) {
    if (kReleaseMode) return s;
    return s.replaceAll(RegExp(r'(:\d+)+(?=\)\n)'), '');
  }
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
