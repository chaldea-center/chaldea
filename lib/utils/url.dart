import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart' as launcher_string;

import 'package:chaldea/app/api/hosts.dart';
import 'package:chaldea/packages/platform/platform.dart';
import '../generated/l10n.dart';
import '../packages/language.dart';
import 'constants.dart';

class ChaldeaUrl {
  const ChaldeaUrl._();

  static String get docHome => doc('', dir: '');

  static String doc(String path, {bool? isZh, String dir = 'guide/'}) {
    isZh ??= Language.isZH;
    return kProjectDocRoot +
        (isZh ? '/zh/' : '/') +
        dir +
        (path.startsWith('/') ? path.substring(1) : path);
  }

  static String chaldeas(String path, {bool? isZh}) {
    return doc(path, isZh: isZh, dir: 'chaldeas/');
  }

  static String app(String path, [bool? useCN]) {
    useCN ??= Hosts.cn;
    if (!path.startsWith('/')) path = '/$path';
    return (useCN ? Hosts.kAppHostCN : Hosts.kAppHostGlobal) + path;
  }

  static IconButton docsHelpBtn(String path,
      {String? zhPath, String? tooltip}) {
    return IconButton(
      onPressed: () {
        launch(ChaldeaUrl.doc(zhPath != null && Language.isZH ? zhPath : path));
      },
      icon: const Icon(Icons.help_outline),
      tooltip: tooltip ?? S.current.help,
    );
  }
}

Future<bool> launch(String url, {bool? external}) {
  final mode = external ?? PlatformU.isAndroid
      ? launcher.LaunchMode.externalApplication
      : launcher.LaunchMode.platformDefault;
  return launcher.launchUrl(
    Uri.parse(url),
    mode: mode,
  );
}

Future<bool> canLaunch(String url) {
  return launcher.canLaunchUrl(Uri.parse(url));
}

Future<bool> openFile(String fp) {
  assert(PlatformU.isDesktop, 'Only Desktop is supported');
  final uri = Uri.file(fp);
  if (PlatformU.isWindows) {
    // on Windows, [launcher.launchUrl] will encode Chinese chars
    return launcher_string.launchUrlString('file:///${uri.toFilePath()}');
  } else if (PlatformU.isDesktop) {
    return launcher.launchUrl(uri);
  } else {
    return Future.value(false);
  }
}
