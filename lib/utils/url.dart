import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart' as launcher_string;

import 'package:chaldea/app/api/hosts.dart';
import 'package:chaldea/packages/platform/platform.dart';
import '../packages/language.dart';
import 'constants.dart';

class HttpUrlHelper {
  HttpUrlHelper._();
  static String projectDocUrl(String path, [bool? isZh]) {
    isZh ??= Language.isZH;
    return kProjectDocRoot +
        (isZh ? '/zh/' : '/') +
        (path.startsWith('/') ? path.substring(1) : path);
  }

  static String appUrl(String path, [bool? useCN]) {
    useCN ??= Hosts.cn;
    if (!path.startsWith('/')) path = '/$path';
    return (useCN ? Hosts.kAppHostCN : Hosts.kAppHostGlobal) + path;
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
