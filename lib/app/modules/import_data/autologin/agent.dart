/// https://github.com/hexstr/FGODailyBonus

import 'dart:convert';
import 'dart:math';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:uuid/uuid.dart';

import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

// ignore: depend_on_referenced_packages

enum ParamType {
  userId('userId'),
  authKey('authKey'),
  appVer('appVer'),
  dateVer('dateVer'),
  lastAccessTime('lastAccessTime'),
  verCode('verCode'),
  idempotencyKey('idempotencyKey'),
  deviceinfo('deviceinfo'), // optional? login top only
  userState('userState'),
  assetbundleFolder('assetbundleFolder'),
  dataVer('dataVer'),
  isTerminalLogin('isTerminalLogin'),
  country('country'), // NA only
  //
  authCode('authCode'),
  ;

  const ParamType(this.str);
  final String str;
}

abstract class UA {
  static const fallback = android;

  static const android =
      'Dalvik/2.1.0 (Linux; U; Android 6.0.1; SM-G9500 Build/V417IR)';

  static bool validate(String ua) {
    if (ua.trim().isEmpty) return false;
    if (!RegExp(r'^[0-9a-zA-Z\./, ;:\-\(\)]+$').hasMatch(ua)) return false;
    if (ua.split('(').length != ua.split(')').length) return false;
    if (RegExp(r'\([^\)]+\(').hasMatch(ua) ||
        RegExp(r'\)[^\()]+\)').hasMatch(ua)) return false;
    return true;
  }

  static const deviceinfo =
      'samsung SM-G9500 / Android OS 6.0.1 / API-23 (V417IR/eng.duanlusheng.20221214.192029)';
}

class ServerResponse {
  final Response src;
  String text = '';
  Map? json;

  BiliTopLogin? toplogin;

  ServerResponse(this.src) {
    try {
      if (src.data is String) {
        text = src.data as String;
        json = jsonDecode(src.data);
      } else if (src.data is Map) {
        text = jsonEncode(src.data);
        json = Map.from(src.data);
      } else {
        text = src.data.toString();
      }
      if (success && json != null) {
        final r0 = json!['response'][0];
        if (r0['nid'] == 'login') {
          toplogin = BiliTopLogin.fromJson(Map.from(json!));
        }
      }
    } catch (e) {
      //
    }
  }

  bool get success {
    if (json == null) return false;
    try {
      return int.parse(json!['response'][0]['resCode']) == 0 &&
          Map.from(json!['response'][0]['success']).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  DateTime? get serverTime {
    if (json == null) return null;
    try {
      return DateTime.fromMillisecondsSinceEpoch(
          (json!['cache']['serverTime'] as int) * 1000);
    } catch (e) {
      return null;
    }
  }

  UserGame? get userGame => toplogin?.cache.replaced.userGame.getOrNull(0);
}

class LoginAgent {
  final UserAuth auth;
  final GameTop gameTop;
  AutoLoginData args;

  late Map<ParamType, String> _params;
  DateTime? _lastPostTime;

  LoginAgent({
    required this.auth,
    required this.gameTop,
    AutoLoginData? args,
  }) : args = args ?? AutoLoginData() {
    _params = defaultParams();
  }

  LoginAgent copyWith({
    UserAuth? auth,
    GameTop? gameTop,
    AutoLoginData? args,
  }) {
    return LoginAgent(
      auth: auth ?? this.auth,
      gameTop: gameTop ?? this.gameTop,
      args: args ?? this.args,
    ).._lastPostTime = _lastPostTime;
  }

  final dio = Dio()..interceptors.add(CookieManager(CookieJar()));

  Map<ParamType, String> defaultParams() {
    return {
      ParamType.appVer: gameTop.appVer,
      ParamType.authKey: auth.authKey,
      ParamType.dataVer: gameTop.dataVer.toString(),
      ParamType.dateVer: gameTop.dateVer.toString(),
      ParamType.idempotencyKey: const Uuid().v4(),
      ParamType.lastAccessTime: DateTime.now().timestamp.toString(),
      ParamType.userId: auth.userId.toString(),
      ParamType.verCode: gameTop.verCode,
    };
  }

  void addParam(ParamType param, String value) {
    assert(_params[param] == null, '$param already in list');
    assert(value.trim() == value, '"$value" is not trimmed');
    _params[param] = value;
  }

  static String escape(String s) {
    return Uri.encodeQueryComponent(s);
  }

  void reset() {
    _params = defaultParams();
  }

  String _buildForm() {
    final params = _params.entries.toList();
    params.sort2((e) => e.key.str);
    String temp = params.map((e) => '${e.key.str}=${e.value}').join('&');
    temp += ':${auth.secretKey}';
    params.add(MapEntry(ParamType.authCode,
        base64.encode(sha1.convert(utf8.encode(temp)).bytes)));
    params.sort2((e) => e.key.index);
    final content =
        params.map((e) => '${escape(e.key.str)}=${escape(e.value)}').join('&');
    // print('form content: $content');
    // print(content.replaceAll('&', '\n'));
    return content;
  }

  Future<Response> post(String url) async {
    // HttpOverrides.global = CustomHttpOverrides(); // disable cert failed check
    final ua = args.userAgent ?? UA.fallback;
    if (!UA.validate(ua)) {
      throw ArgumentError.value(ua, 'User-Agent', ' is invalid');
    }

    if (_lastPostTime != null &&
        DateTime.now().difference(_lastPostTime!).inSeconds < 3) {
      // 3-5 s
      await Future.delayed(
          Duration(seconds: 3, milliseconds: Random().nextInt(2000)));
    }
    _lastPostTime = DateTime.now();
    final data = _buildForm();
    final resp = await dio.post(
      url,
      data: data,
      options: Options(headers: {
        'Accept-Encoding': 'gzip, identity',
        'User-Agent': ua,
        'Content-Type': 'application/x-www-form-urlencoded',
        'Connection': 'Keep-Alive, TE',
        'TE': 'identity',
      }),
    );
    print(resp.requestOptions.uri.toString());
    print(resp.requestOptions.data.toString());
    print(resp.data.toString().substring2(0, 1000));
    return resp;
  }

  Future<Response> topLogin() async {
    reset();
    int lastAccessTime = int.parse(_params[ParamType.lastAccessTime]!);
    int userState =
        (-lastAccessTime >> 2) ^ int.parse(auth.userId) & gameTop.folderCrc;
    print('crc: ${gameTop.folderCrc}');
    addParam(ParamType.deviceinfo, args.deviceInfo ?? UA.deviceinfo);
    addParam(ParamType.assetbundleFolder, gameTop.assetbundleFolder);
    addParam(ParamType.isTerminalLogin, '1');
    addParam(ParamType.userState, userState.toString());
    if (gameTop.region == Region.na) {
      addParam(ParamType.country, args.country.countryId.toString());
    }
    final resp = await post('${gameTop.host}/login/top?_userId=${auth.userId}');
    reset();
    final sr = ServerResponse(resp);
    if (sr.userGame != null) {
      auth.friendCode = sr.userGame?.friendCode;
      auth.name = sr.userGame?.name;
    }
    return resp;
  }

  Future topHome() async {
    final resp = await post('${gameTop.host}/home/top?_userId=${auth.userId}');
    reset();
    return resp;
  }
}
