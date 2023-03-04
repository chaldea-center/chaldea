import 'dart:io';

class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    // // debug only
    // if (kDebugMode) {
    //   client.findProxy = (uri) {
    //     return 'PROXY 127.0.0.1:1087;';
    //   };
    // }
    return client;
  }
}
