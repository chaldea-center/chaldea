import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/userdata/autologin.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import '../quiz/cat_mouse.dart';

int _getNowTimestamp() => DateTime.now().timestamp;

class FRequestBase {
  bool _disposed = false;

  NetworkManager network;
  RequestOptions? rawRequest;
  Response? rawResponse;
  String path;

  FRequestBase({required this.network, required this.path});

  final Map<String, int> paramInteger = {};
  final Map<String, String> paramString = {};

  int sendTime = 0;
  int receiveTime = 0;
  int serverTime = 0;
  int serverExecutionTime = 0;

  // int64/long, float, double should convert to string
  void addFieldInt32(String fieldName, int data, {bool replace = false}) {
    if (!replace) assert(!paramInteger.containsKey(fieldName));
    paramInteger[fieldName] = data;
  }

  void addFieldInt64(String fieldName, int data, {bool replace = false}) {
    if (!replace) assert(!paramString.containsKey(fieldName));
    paramString[fieldName] = data.toString();
  }

  void addFieldFloat(String fieldName, double data, {bool replace = false}) {
    if (!replace) assert(!paramString.containsKey(fieldName));
    paramString[fieldName] = data.toString();
  }

  void addFieldStr(String fieldName, String data, {bool replace = false}) {
    if (!replace) assert(!paramString.containsKey(fieldName));
    paramString[fieldName] = data;
  }

  void addBaseField() {
    network.setBaseField(this);
  }

  /// Update lastAccessTime
  void replaceBaseField() {
    network.setBaseField(this);
  }

  Future<void> addSignatureField() {
    return network.setSignatureField(this);
  }

  (WWWForm form, Map<String, String> authParams) getForm() {
    final form = WWWForm();
    final authParams = <String, String>{};
    for (final entry in paramString.entries) {
      form.addField(entry.key, entry.value);
      authParams[entry.key] = entry.value;
    }
    for (final entry in paramInteger.entries) {
      form.addField(entry.key, entry.value.toString());
      authParams[entry.key] = entry.value.toString();
    }
    return (form, authParams);
  }

  Future<FResponse> beginRequestAndCheckError({bool addBaseFields = true}) async {
    final resp = await beginRequest(addBaseFields: addBaseFields);
    return resp.throwError();
  }

  Future<FResponse> beginRequest({bool addBaseFields = true}) async {
    if (addBaseFields) {
      addBaseField();
    }
    return network.requestStart(this);
  }
}

class NetworkManager {
  final GameTop gameTop;
  final AutoLoginData user;
  final CatMouseGame catMouseGame;

  FRequestBase? _runningTask;

  NetworkManager({required this.gameTop, required this.user}) : catMouseGame = CatMouseGame(gameTop.region);

  // long
  int _nowTime = -1;
  String? sessionId; // Set-Cookie: ASP.NET_SessionId=.*; path=/; HttpOnly
  int getTime() {
    if (_nowTime < 0) {
      _nowTime = _getNowTimestamp();
    }
    return _nowTime;
  }

  void setBaseField(FRequestBase request) {
    final auth = user.auth;
    if (auth == null) throw Exception('No auth data');
    request.addFieldStr('userId', auth.userId);
    request.addFieldStr('authKey', auth.authKey);
    request.addFieldStr('appVer', gameTop.appVer);
    request.addFieldInt32('dataVer', gameTop.dataVer);
    request.addFieldInt64('dateVer', gameTop.dateVer);
    request.addFieldInt64('lastAccessTime', _getNowTimestamp());
    request.addFieldStr('verCode', gameTop.verCode);
    request.addFieldStr('idempotencyKey', const Uuid().v4());
  }

  Future<void> setSignatureField(FRequestBase request) async {
    final key = const Uuid().v4();
    final signature = await ChaldeaWorkerApi.signData("${user.auth!.userId}$key");
    if (signature == null || signature.isEmpty) throw const FormatException("Invalid signature");
    request.addFieldStr('idempotencyKey', key, replace: true);
    request.addFieldStr('idempotencyKeySignature', signature);
  }

  String getAuthCode(Map<String, String> authParams) {
    final auth = user.auth;
    if (auth == null) {
      throw Exception("No auth data");
    }

    final entries = authParams.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    String text = entries.map((e) => '${e.key}=${e.value}').join('&');
    text += ':${auth.secretKey}';
    return base64.encode(sha1.convert(utf8.encode(text)).bytes);
  }

  // sington
  Future<FResponse> requestStart(FRequestBase request) async {
    if (request._disposed) {
      throw Exception('Already disposed');
    }
    if (_runningTask != null) {
      throw Exception('Previous request is still running');
    }
    _runningTask = request;

    if (_nowTime > 0) {
      final dt = _getNowTimestamp() - _nowTime;
      if (dt < 5) {
        await Future.delayed(Duration(seconds: 6 - dt));
      }
    }

    const int kMaxTries = 3;
    int tryCount = 0;
    try {
      while (tryCount < kMaxTries) {
        try {
          final resp = await _requestStart(request);
          return resp;
        } on DioException catch (e, s) {
          logger.e('fgo request failed, retry after 5 seconds', e, s);
          await Future.delayed(const Duration(seconds: 5));
          tryCount++;
          _nowTime = _getNowTimestamp();
          continue;
        } catch (e) {
          _runningTask = null;
          rethrow;
        }
      }
    } finally {
      _runningTask = null;
      request._disposed = true;
    }
    throw Exception('Should not reach here');
  }

  Future<FResponse> _requestStart(FRequestBase request) async {
    final (form, authParams) = request.getForm();
    final Map<String, dynamic> headers = {};
    headers[HttpHeaders.userAgentHeader] = user.userAgent ?? UA.fallback;
    if (sessionId != null) {
      headers['Cookie'] = sessionId!;
    }
    final authCode = getAuthCode(authParams);
    form.addField('authCode', authCode);
    headers[HttpHeaders.contentTypeHeader] = Headers.formUrlEncodedContentType;
    if (user.region.isJP) {
      headers['X-Unity-Version'] = '2020.3.34f1';
    }

    request.sendTime = _getNowTimestamp();
    Uri uri = Uri.parse(gameTop.host);
    uri = uri.replace(path: request.path, queryParameters: {
      ...uri.queryParameters,
      '_userId': user.auth!.userId,
    });
    final buffer = StringBuffer('============ start ${request.path} ============\n');
    buffer.writeln(uri);
    // buffer.writeln(headers);
    buffer.writeln(form.data);
    final Response rawResp = await Dio().post(
      uri.toString(),
      data: form.data,
      options: Options(
        headers: headers,
      ),
    );
    request.rawRequest = rawResp.requestOptions;
    request.rawResponse = rawResp;
    // buffer.writeln(rawResp.headers);
    final _jsonData = FateTopLogin.parseToMap(rawResp.data);
    // final _jsonData = jsonEncode();
    buffer.writeln(jsonEncode(_jsonData['response'] ?? []));
    if (request.path.contains('login/top')) {
      // buffer.writeln(_jsonData.substring2(0, 000));
    } else {
      // buffer.writeln(_jsonData);
    }
    buffer.write('============ end ============');
    // final s = buffer.toString();
    if (kDebugMode) {
      await FilePlus(joinPaths(db.paths.tempDir, 'faker',
              '${DateTime.now().toSafeFileName()}_${request.path.replaceAll('/', '_')}.json'))
          .writeAsString(jsonEncode(_jsonData));
    }
    logger.v(buffer.toString());
    final cookie = rawResp.headers['Set-Cookie']?.firstOrNull;
    if (cookie != null) {
      final match = RegExp(r'^(ASP.NET_SessionId=[^;]+);').firstMatch(cookie);
      if (match != null) {
        sessionId = match.group(1);
        print('Set cookie: $sessionId');
      }
    }
    final serverTimeStr = rawResp.headers['X-Server-Time']?.firstOrNull;
    if (serverTimeStr != null) {
      final serverTime = int.tryParse(serverTimeStr);
      if (serverTime != null) request.serverTime = serverTime;
    }

    _nowTime = _getNowTimestamp();

    request.receiveTime = _getNowTimestamp();

    final resp = FResponse(rawResp);
    for (final detail in resp.responses) {
      if (!detail.checkError()) {
        logger.e('error in response: [${detail.nid}] ${detail.resCode} ${detail.fail}');
        // throw Exception('${detail.resCode}: ${detail.fail}');
      }
    }
    return resp;
  }
}

class FResponse {
  Response rawResponse;
  late final Map<String, dynamic> raw;
  late final FateTopLogin? data;
  // add response here in case [data] parse failed
  List<FateResponseDetail> responses = [];

  FResponse.raw(this.rawResponse);

  factory FResponse(Response rawResponse) {
    final resp = FResponse.raw(rawResponse);
    resp.raw = FateTopLogin.parseToMap(rawResponse.data);
    resp.responses = (resp.raw['response'] as List).map((e) => FateResponseDetail.fromJson(e)).toList();
    try {
      resp.data = FateTopLogin.fromJson(jsonDecode(jsonEncode(resp.raw)));
    } catch (e, s) {
      logger.e('decode response cache failed', e, s);
    }
    return resp;
  }

  FateResponseDetail getResponse(String nid) {
    for (final resp in responses) {
      if (resp.nid == nid) return resp;
    }
    throw Exception('response nid="$nid" not found');
  }

  FResponse throwError() {
    for (final detail in responses) {
      if (!detail.checkError()) {
        throw Exception('[${detail.nid}] ${detail.resCode} ${detail.fail}');
      }
    }
    return this;
  }

  FateTopLogin? toplogin;
}

class FResponseData {
  String resCode;
  Map<String, dynamic> success;
  Map<String, dynamic> fail;
  String nid;

  FResponseData({
    required this.resCode,
    this.success = const {},
    this.fail = const {},
    required this.nid,
  });

  factory FResponseData.fromJson(Map<dynamic, dynamic> json) {
    return FResponseData(
      resCode: json['resCode'],
      success: Map.from(json['success'] ?? {}),
      fail: Map.from(json['fail'] ?? {}),
      nid: json['nid'],
    );
  }

  bool checkError() {
    return resCode == '00';
  }
}

//

class WWWForm {
  final List<MapEntry<String, String>> _list = [];
  // headers

  void addField(String key, String value) {
    _list.add(MapEntry(key, value));
  }

  String get data {
    return _list.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&');
  }
}

abstract class UA {
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
