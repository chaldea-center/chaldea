import 'dart:io';
import 'dart:math';

import 'package:chaldea/components/components.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

const _hjs = 'https://hm.baidu.com/hm.js?';
const _hgif = 'https://hm.baidu.com/hm.gif?';

const _kBDID = '9de65dbb7a214ca258974c37c5e060d2';

@deprecated
Future<void> launchStaticUrl(String url) async {
  final plugin = FlutterWebviewPlugin();
  await plugin.launch(url, hidden: true);
  print('$url launched');
  await Future.delayed(Duration(seconds: 10));
  plugin.dispose();
}

String _constructUrl({String? server, String? platform}) {
  return '${server ?? kServerRoot}/bdtj/${platform ?? Platform.operatingSystem}/${AppInfo.version}';
  // return 'http://localhost:8083/bdtj/${Platform.operatingSystem}/${AppInfo.version}';
}

String? _getUserAgent() {
  if (Platform.isWindows) {
    return ' Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36 Edg/89.0.774.54';
  } else if (Platform.isMacOS) {
    return 'Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.146 Safari/537.36';
  }
}

Future<void> reportBdtj({String? bdId}) async {
  final excludeIds = [
    b64('YjhhMDY0OWQ3NTI5MmQwOQ=='), // android
    b64('RDE0QjBGNzItNUYzRS00ODcxLTlDRjUtNTRGMkQ1OTYyMUEw'), //ios
    b64('QzAyQ1cwTUNNTDdM'), //macos
    b64('MDAzNzgtNDAwMDAtMDAwMDEtQUE5Mjc='), // windows
  ];

  if (kDebugMode || excludeIds.contains(AppInfo.uniqueId)) {
    return;
  }

  try {
    // if (Platform.isIOS || Platform.isAndroid) {
    //   _launchStaticUrl(_constructUrl());
    //   return;
    // }
    String url = _constructUrl(server: 'http://chaldea.narumi.cc');
    bdId ??= _kBDID;
    final String hjs = _hjs + bdId;

    final size = MediaQuery.of(kAppKey.currentContext!).size;
    final random = Random(DateTime.now().microsecondsSinceEpoch);

    final cookieJar = PersistCookieJar();
    final cookies = await cookieJar.loadForRequest(Uri.parse(hjs));
    String? hca = cookies
        .firstWhereOrNull((c) => c.name.trim() == 'HMACCOUNT_BFESS')
        ?.value;

    bool fresh = hca == null;
    bool first = true;

    int sn = random.nextInt(7000) + 300;
    final genMap = () {
      final Map<String, dynamic> _param = {
        // 'hca':null,
        'cc': 1,
        'ck': 1,
        'cl': '24-bit',
        'ds': '${size.width}x${size.height}',
        'vl': 750,
        // 'ep': null,
        // 'et':xxx?3:0,
        'ja': 0,
        'ln': Intl.getCurrentLocale(),
        'lo': 0,
        'lt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'rnd':
            (random.nextInt(90000) + 10000) * 100000 + random.nextInt(100000),
        'si': bdId,
        'v': '1.2.80',
        'lv': fresh ? 1 : 2,
        'sn': sn += random.nextInt(100) + 20,
        'r': 0,
        'ww': size.width,
        // 'ct':null,
        'u': url,
        // 'tt':null,
      };
      if (!fresh && first) {
        _param['hca'] = hca;
      }
      if (!fresh && first) {
        _param['ep'] = '72000,${15000 + random.nextInt(6000)}';
      }
      _param['et'] = _param['ep'] == null ? 0 : 3;
      if (fresh || !first) {
        _param['ct'] = '!!';
      }
      if (!first) {
        _param['uu'] = 'Chaldea ${Platform.operatingSystem}';
      }
      logger.i(_param);
      return _param.map((key, value) => MapEntry(key, value.toString()));
    };
    final _dio = Dio(BaseOptions(headers: {'User-Agent': _getUserAgent()}));
    _dio.interceptors.add(CookieManager(cookieJar));
    await _dio.get(hjs);
    first = false;
    String gifUrl1 =
        Uri.parse(_hgif).replace(queryParameters: genMap()).toString();
    var gif1 = _dio.get(gifUrl1);
    await Future.delayed(Duration(milliseconds: 66));
    String gifUrl2 =
        Uri.parse(_hgif).replace(queryParameters: genMap()).toString();
    var gif2 = _dio.get(gifUrl2);
    await Future.wait([gif1, gif2]);
  } catch (e, s) {
    logger.e('bdtj failed', e, s);
  }
}
