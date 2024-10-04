import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/userdata/autologin.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/notification.dart';
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
      final errors = data.responses.where((e) => !e.isSuccess()).map((e) => "${e.resCode} ${e.fail}").join("\n");
      if (errors.isNotEmpty) {
        throw Exception('[$nid] failed:\n$errors');
      } else {
        throw Exception('Response [$nid] not found');
      }
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

  bool stopFlag = false;

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

  late final String fakerDir = joinPaths(db.paths.tempFakerDir, gameTop.region.upper);

  void updateCookies(Map<String, dynamic> headers) {
    if (cookies.isEmpty) return;
    const key = 'Cookie';
    String cookie = headers[key] ?? '';
    if (cookie.isNotEmpty && !cookie.endsWith(';')) cookie += ';';
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
    // In case memory used out
    history.add(record);
    if (history.length > 50) {
      history.removeRange(0, history.length - 50);
    }

    const int kMaxTries = 3;
    int tryCount = 0;
    try {
      while (tryCount < kMaxTries) {
        try {
          if (stopFlag) {
            stopFlag = false;
            throw SilentException('Manual Stop Flag, current request: ${request.key}');
          }
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
          if (db.settings.fakerSettings.dumpResponse) {
            String fn = '${DateTime.now().toSafeFileName()}_${request.key}';
            fn = fn.replaceAll(RegExp(r'[/:\s\\]+'), '_');
            await FilePlus(joinPaths(fakerDir, '$fn.json')).writeAsString(jsonEncode(_jsonData));
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
          for (final itemId in Items.loginSaveItems) {
            final count = resp.data.mstData.userItem[itemId]?.num;
            if (count != null) {
              user.userItems[itemId] = count;
            }
          }

          record.response = resp;
          setLocalNotification();
          return resp;
        } on DioException catch (e, s) {
          logger.e('fgo request failed, retry after 5 seconds', e, s);
          EasyLoading.show(status: 'Error: ${e.toString().substring2(0, 100)}');
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

  Future<void> setLocalNotification() async {
    if (!LocalNotificationUtil.supported) return;
    if (!db.settings.fakerSettings.apRecoveredNotification) return;
    if (!(await LocalNotificationUtil.checkPermission())) return;
    final userGame = mstData.user;
    if (userGame == null) return;
    for (final targetAp in user.recoveredAps) {
      final isFull = targetAp == 0;
      final int id = LocalNotificationUtil.generateUserApRecoverId(user.region.index, userGame.userId, targetAp);
      int recoverAt;
      if (isFull) {
        recoverAt = userGame.actRecoverAt;
      } else if (userGame.calCurAp() < targetAp && targetAp < userGame.actMax) {
        recoverAt = userGame.actRecoverAt - (userGame.actMax - targetAp) * 60 * 5;
      } else {
        await LocalNotificationUtil.plugin.cancel(id);
        continue;
      }
      final now = DateTime.now().timestamp;
      if (!isFull && recoverAt < now + 2) {
        // await LocalNotificationUtil.plugin.cancel(id);
        continue;
      }
      final recoverTime = recoverAt.sec2date();
      DateTime notifyTime = recoverTime.subtract(Duration(minutes: isFull ? 5 : 0));
      if (notifyTime.timestamp <= now + 1) {
        notifyTime = (now + 2).sec2date();
      }

      await LocalNotificationUtil.scheduleNotification(
        id: id,
        dateTime: notifyTime,
        title: isFull ? S.current.ap_fully_recovered : 'AP $targetAp!',
        body: [
          '[${user.serverName}] ${userGame.name}',
          recoverTime.toCustomString(year: false, millisecond: false),
        ].join('\n'),
      );
    }
  }
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
