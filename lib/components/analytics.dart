import 'package:chaldea/components/components.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl_standalone.dart';

class Analyzer {
  const Analyzer._();

  static bool skipReport() {
    if (kDebugMode || AppInfo.isDebugDevice) {
      return true;
    }
    return false;
  }

  static Future<void> sendStat() async {
    if (!db.hasNetwork) return;

    String size = '';
    if (kAppKey.currentContext != null) {
      final mq = MediaQuery.of(kAppKey.currentContext!);
      // use logical pixel, don't multiple devicePixelRatio
      int w = (mq.size.width).round();
      int h = (mq.size.height).round();
      size = '${w}x$h';
    }
    String zone = 'unknown';
    try {
      final Response cipRes = await Dio().get('http://cip.cc',
          options: Options(
            contentType: 'text/plain',
            headers: {'User-Agent': 'curl/7.71.1'},
          ));
      zone = cipRes.data.toString().trim().split('\n')[1].split(':')[1].trim();
    } catch (e, s) {
      logger.e('fetch cip failed', e, s);
    }
    // await Dio(BaseOptions(baseUrl: 'http://localhost:8083'))
    //     .get('/analytics', queryParameters: {
    await db.serverDio.get('/analytics', queryParameters: {
      'uuid': AppInfo.uuid,
      'os': PlatformU.operatingSystem,
      'os_ver': PlatformU.isAndroid
          ? AppInfo.androidSdk ?? PlatformU.operatingSystemVersion
          : PlatformU.operatingSystemVersion,
      'app': AppInfo.packageName,
      'app_ver': AppInfo.version,
      'build': AppInfo.originBuild,
      'dataset': db.gameData.version,
      'lang': Language.current.code,
      'locale': await findSystemLocale(),
      'data_ver': db.gameData.version,
      'abi': AppInfo.abi.toStandardString(),
      'mac': AppInfo.macAppType.index,
      'time': DateTime.now().toString().split('.').first,
      'size': size,
      'zone': zone,
    }).catchError((e, s) async {
      logger.e('report analytics failed', e, s);
    });
  }
}
