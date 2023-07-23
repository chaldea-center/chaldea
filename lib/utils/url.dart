import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart' as launcher_string;

import '../generated/l10n.dart';
import '../models/userdata/remote_config.dart';
import '../packages/language.dart';
import '../packages/platform/platform.dart';
import 'constants.dart';

class ChaldeaUrl {
  const ChaldeaUrl._();

  static String get docHome => doc('', dir: '');

  static String doc(String path, {bool? isZh, String dir = 'guide/'}) {
    isZh ??= Language.isZH;
    return kProjectDocRoot + (isZh ? '/zh/' : '/') + dir + (path.startsWith('/') ? path.substring(1) : path);
  }

  static String laplace(String path, {bool? isZh}) {
    return doc(path, isZh: isZh, dir: 'laplace/');
  }

  static String app(String path, [bool? useCN]) {
    if (useCN == null && kIsWeb) {
      final href = kPlatformMethods.href;
      if (href.startsWith(HostsX.app.cn) || href.startsWith(HostsX.app.kCN)) {
        useCN = true;
      }
    }
    useCN ??= HostsX.proxy || Language.isCHS;
    if (!path.startsWith('/')) path = '/$path';
    return HostsX.app.of(useCN) + path;
  }

  static IconButton docsHelpBtn(String path, {String? zhPath, String? tooltip, String dir = 'guide/'}) {
    return IconButton(
      onPressed: () {
        launch(ChaldeaUrl.doc(zhPath != null && Language.isZH ? zhPath : path, dir: dir));
      },
      icon: const Icon(Icons.help_outline),
      tooltip: tooltip ?? S.current.help,
    );
  }

  static IconButton laplaceHelpBtn(String path, {String? zhPath, String? tooltip}) {
    return docsHelpBtn(path, zhPath: zhPath, tooltip: tooltip, dir: 'laplace/');
  }
}

class UriX {
  const UriX._();

  static void _onError(String method, String uri, dynamic e, dynamic s) {
    // logger.d('$method failed: $uri', e, s);
  }

  static String? tryDecodeFull(String uri) {
    try {
      return Uri.decodeFull(uri);
    } catch (e, s) {
      _onError('Uri.decodeFull', uri, e, s);
      return null;
    }
  }

  static String? tryDecodeComponent(String encodedComponent) {
    try {
      return Uri.decodeComponent(encodedComponent);
    } catch (e, s) {
      _onError('Uri.decodeComponent', encodedComponent, e, s);
      return null;
    }
  }

  static String? tryDecodeQueryComponent(String encodedComponent) {
    try {
      return Uri.decodeQueryComponent(encodedComponent);
    } catch (e, s) {
      _onError('Uri.decodeQueryComponent', encodedComponent, e, s);
      return null;
    }
  }
}

Future<bool> launch(String url, {bool? external}) {
  final mode =
      external ?? PlatformU.isAndroid ? launcher.LaunchMode.externalApplication : launcher.LaunchMode.platformDefault;
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
