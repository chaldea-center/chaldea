import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:share_plus/share_plus.dart';

import 'package:chaldea/packages/file_plus/file_plus.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class ShareX {
  const ShareX._();

  // share_plus requires iPad users to provide the sharePositionOrigin parameter.
  // Without it, share_plus will not work on iPads and may cause a crash or letting the UI not responding.
  // To avoid that problem, provide the sharePositionOrigin.
  static Rect? getSharePosOrigin([BuildContext? context]) {
    if (context != null) {
      final box = context.findRenderObject();
      if (box is RenderBox) {
        print(box.localToGlobal(Offset.zero) & box.size);
      }
    }
    context ??= kAppKey.currentContext;
    if (context == null) return null;
    final size = MediaQuery.maybeOf(context)?.size;
    if (size == null) return null;
    if (size.width > size.height) {
      return Rect.fromLTWH(size.width * 0.7, size.height * 0.5, 10, 10);
    } else {
      return Rect.fromLTWH(size.width * 0.75, size.height * 0.5, 10, 10);
    }
  }

  static Future<void> share(
    String text, {
    String? subject,
    Rect? sharePositionOrigin,
    BuildContext? context,
  }) {
    if (sharePositionOrigin == null && PlatformU.isIOS) {
      sharePositionOrigin = getSharePosOrigin(context);
    }
    return Share.share(
      text,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  static Future<ShareResult> shareFile(
    String fp, {
    String? subject,
    String? text,
    Rect? sharePositionOrigin,
    BuildContext? context,
  }) async {
    if (sharePositionOrigin == null && PlatformU.isIOS) {
      sharePositionOrigin = getSharePosOrigin(context);
    }
    subject ??= pathlib.basename(fp);
    XFile file;
    if (kIsWeb) {
      try {
        file = XFile.fromData(await FilePlus(fp).readAsBytes());
      } catch (e) {
        EasyLoading.showError(e.toString());
        return ShareResult(
            'read file failed ($fp): $e', ShareResultStatus.unavailable);
      }
    } else {
      file = XFile(fp);
    }
    return Share.shareXFiles(
      [file],
      subject: subject,
      text: text,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  static Future<ShareResult> shareFiles(
    List<XFile> files, {
    String? subject,
    String? text,
    Rect? sharePositionOrigin,
    BuildContext? context,
  }) {
    if (sharePositionOrigin == null && PlatformU.isIOS) {
      sharePositionOrigin = getSharePosOrigin(context);
    }
    if (files.length == 1 && subject == null) {
      subject = files.first.name;
    }
    return Share.shareXFiles(
      files,
      subject: subject,
      text: text,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
