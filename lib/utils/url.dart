import 'constants.dart';

class HttpUrlHelper {
  HttpUrlHelper._();
  static String projectDocUrl(String path, bool isZh) {
    return kProjectDocRoot +
        (isZh ? '/zh/' : '/') +
        (path.startsWith('/') ? path.substring(1) : path);
  }
}
