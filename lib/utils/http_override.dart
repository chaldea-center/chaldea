import 'dart:io';

class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    // client.findProxy = (uri) {
    //   return 'PROXY 127.0.0.1:8888;';
    // };
    return client;
  }
}
