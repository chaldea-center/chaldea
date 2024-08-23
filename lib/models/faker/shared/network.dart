import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/userdata/autologin.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import '../quiz/cat_mouse.dart';

int getNowTimestamp() => DateTime.now().timestamp;

class FRequestRecord<TRequest extends FRequestBase> {
  TRequest? request;
  FResponse? response;
  DateTime? sendedAt;
  DateTime? receivedAt;
}

abstract class FRequestBase {
  bool disposed = false;

  RequestOptions? rawRequest;
  Response? rawResponse;
  String path;
  String key;

  FRequestBase({required this.path, String? key}) : key = key ?? path;

  int sendTime = 0;
  int receiveTime = 0;
  int serverTime = 0;
  int serverExecutionTime = 0;

  Future<FResponse> beginRequestAndCheckError(String? nid) async {
    final resp = await beginRequest();
    return resp.throwError(nid);
  }

  Future<FResponse> beginRequest();
}

class FResponse {
  final Response rawResponse;
  final FateTopLogin data;

  FResponse.raw(this.rawResponse, this.data);

  factory FResponse(Response rawResponse) {
    try {
      final jsonData = FateTopLogin.parseToMap(rawResponse.data);
      final resp = FResponse.raw(rawResponse, FateTopLogin.fromJson(jsonData));
      return resp;
    } catch (e, s) {
      logger.e('decode response cache failed', e, s);
      return FResponse.raw(rawResponse, FateTopLogin.fromJson({}));
    }
  }

  FResponse throwError(String? nid) {
    for (final detail in data.responses) {
      if (nid != null && nid == detail.nid && detail.isSuccess()) {
        return this;
      }
      if ((nid == null || nid == detail.nid) && !detail.isSuccess()) {
        throw Exception('[${detail.nid}] ${detail.resCode} ${detail.fail}');
      }
    }
    if (nid != null) {
      throw Exception('response of nid $nid not found');
    }
    return this;
  }
}

abstract class NetworkManagerBase<TRequest extends FRequestBase, TUser extends AutoLoginData> {
  final GameTop gameTop;
  final TUser user;
  final CatMouseGame catMouseGame;
  final mstData = MasterDataManager();

  List<FRequestRecord<TRequest>> history = [];

  FRequestBase? _runningTask;
  final Map<String, String> cookies = {};

  NetworkManagerBase({required this.gameTop, required this.user}) : catMouseGame = CatMouseGame(gameTop.region);

  // long
  int _nowTime = -1;
  int getTime() {
    if (_nowTime < 0) {
      _nowTime = getNowTimestamp();
    }
    return _nowTime;
  }

  void clearTask() {
    _runningTask = null;
  }

  void updateCookies(Map<String, dynamic> headers) {
    if (cookies.isEmpty) return;
    const key = 'Cookie';
    String cookie = headers[key] ?? '';
    if (!cookie.endsWith(';')) cookie += ';';
    cookie += [for (final (k, v) in cookies.items) '$k=$v'].join(';');
    headers[key] = cookie;
  }

  Future<FResponse> requestStart(TRequest request) async {
    if (request.disposed) {
      throw Exception('Already disposed');
    }
    if (_runningTask != null) {
      throw Exception('Previous request is still running');
    }
    _runningTask = request;

    if (_nowTime > 0) {
      final dt = getNowTimestamp() - _nowTime;
      if (dt < 2) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    final record = FRequestRecord<TRequest>()
      ..request = request
      ..sendedAt = DateTime.now();
    history.add(record);

    const int kMaxTries = 3;
    int tryCount = 0;
    try {
      while (tryCount < kMaxTries) {
        try {
          final rawResp = await requestStartImpl(request);
          request.rawRequest = rawResp.requestOptions;
          request.rawResponse = rawResp;
          // cookie
          final setCookies = rawResp.headers['Set-Cookie'] ?? [];
          for (final cookie in setCookies) {
            final m = RegExp('^([^=]+)=([^;]+)').firstMatch(cookie);
            if (m == null) {
              logger.w('Set-Cookie not parsed: $cookie');
            } else {
              final key = m.group(1)!, value = m.group(2)!;
              cookies[key] = value;
              print('Set-Cookie: $key=$value');
            }
          }

          // data
          final _jsonData = FateTopLogin.parseToMap(rawResp.data);
          if (AppInfo.isDebugDevice) {
            String fn = '${DateTime.now().toSafeFileName()}_${request.key}';
            fn = fn.replaceAll(RegExp(r'[/:\s\\]+'), '_');
            await FilePlus(joinPaths(db.paths.tempDir, 'faker', '$fn.json')).writeAsString(jsonEncode(_jsonData));
          }
          _nowTime = getNowTimestamp();
          request.receiveTime = getNowTimestamp();

          final resp = FResponse(rawResp);

          for (final detail in resp.data.responses) {
            if (!detail.isSuccess()) {
              logger.e('error in response: [${detail.nid}] ${detail.resCode} ${detail.fail}');
              // throw Exception('${detail.resCode}: ${detail.fail}');
            } else {
              logger.t('${detail.nid} ${detail.resCode}');
            }
          }
          mstData.updateCache(resp.data.cache);
          final newUserGame = resp.data.mstData.user;
          if (newUserGame != null) {
            user.userGame = UserGameEntity.fromJson(newUserGame.toJson());
          }

          record.response = resp;
          return resp;
        } on DioException catch (e, s) {
          logger.e('fgo request failed, retry after 5 seconds', e, s);
          await Future.delayed(const Duration(seconds: 5));
          tryCount++;
          _nowTime = getNowTimestamp();
          continue;
        } catch (e) {
          _runningTask = null;
          rethrow;
        }
      }
    } finally {
      _runningTask = null;
      request.disposed = true;
      record.receivedAt = DateTime.now();
    }
    throw Exception('[${request.path}] after $kMaxTries retries, still failed');
  }

  Future<Response> requestStartImpl(TRequest request);
}

class WWWForm {
  final List<MapEntry<String, String>> _list = [];
  // headers

  void addField(String key, String value) {
    _list.add(MapEntry(key, value));
  }

  void addFromMap(Map<String, Object> src) {
    for (final (k, v) in src.items) {
      addField(k, v.toString());
    }
  }

  String get data {
    return _list.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
  }
}

abstract class FakerUA {
  static const fallback = android;

  static const android = 'Dalvik/2.1.0 (Linux; U; Android 8.1; SM-G9500 Build/V417IR)';

  static bool validate(String ua) {
    if (ua.trim().isEmpty) return false;
    if (!RegExp(r'^[0-9a-zA-Z\./, ;:\-\(\)]+$').hasMatch(ua)) return false;
    if (ua.split('(').length != ua.split(')').length) return false;
    if (RegExp(r'\([^\)]+\(').hasMatch(ua) || RegExp(r'\)[^\()]+\)').hasMatch(ua)) return false;
    return true;
  }

  static const deviceinfo = 'samsung SM-G9500 / Android OS 8.1 / API-27 (V417IR/eng.duanlusheng.20221214.192029)';
}