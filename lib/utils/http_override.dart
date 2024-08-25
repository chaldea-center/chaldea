import 'dart:io';

import 'package:chaldea/models/db.dart';

class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final proxySettings = db.settings.proxy;
    if (proxySettings.enableHttpProxy &&
        proxySettings.proxyHost?.isNotEmpty == true &&
        proxySettings.proxyPort != null) {
      client.findProxy = (uri) {
        return 'PROXY ${proxySettings.proxyHost}:${proxySettings.proxyPort}';
      };
    }
    return client;
  }
}
