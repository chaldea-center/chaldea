import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import '../../userdata/autologin.dart';
import '../shared/network.dart';

export '../shared/network.dart';

// for JP and NA

class FRequestJP extends FRequestBase {
  final NetworkManagerJP network;
  FRequestJP({required this.network, required super.path, super.key});

  final Map<String, int> paramInteger = {};
  final Map<String, String> paramString = {};

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

  @override
  Future<FResponse> beginRequestAndCheckError(String? nid, {bool addBaseFields = true}) async {
    final resp = await beginRequest(addBaseFields: addBaseFields);
    return resp.throwError(nid);
  }

  @override
  Future<FResponse> beginRequest({bool addBaseFields = true}) async {
    if (addBaseFields) {
      addBaseField();
    }
    return network.requestStart(this);
  }
}

class NetworkManagerJP extends NetworkManagerBase<FRequestJP, AutoLoginDataJP> {
  NetworkManagerJP({required super.gameTop, required super.user});

  // String? sessionId; // Set-Cookie: ASP.NET_SessionId=.*; path=/; HttpOnly

  @override
  FRequestJP createRequest({required String path, String? key}) {
    return FRequestJP(network: this, path: path, key: key);
  }

  void setBaseField(FRequestJP request) {
    final auth = user.auth;
    if (auth == null) throw Exception('No auth data');
    request.addFieldStr('userId', auth.userId);
    request.addFieldStr('authKey', auth.authKey);
    request.addFieldStr('appVer', gameTop.appVer);
    request.addFieldInt32('dataVer', gameTop.dataVer);
    request.addFieldInt64('dateVer', gameTop.dateVer);
    request.addFieldInt64('lastAccessTime', getNowTimestamp());
    request.addFieldStr('verCode', gameTop.verCode);
    request.addFieldStr('idempotencyKey', const Uuid().v4());
  }

  Future<void> setSignatureField(FRequestJP request) async {
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

  @override
  Future<Response> requestStartImpl(FRequestJP request) async {
    final (form, authParams) = request.getForm();
    final Map<String, dynamic> headers = {};
    headers[HttpHeaders.userAgentHeader] = user.userAgent.isEmpty ? FakerUA.fallback : user.userAgent;
    updateCookies(headers);
    final authCode = getAuthCode(authParams);
    form.addField('authCode', authCode);
    headers[HttpHeaders.contentTypeHeader] = Headers.formUrlEncodedContentType;
    if (user.region.isJP) {
      headers['X-Unity-Version'] = '2022.3.28f1'; // 2020.3.34f1
    }

    request.sendTime = getNowTimestamp();
    Uri uri = Uri.parse(gameTop.host);
    uri = uri.replace(path: request.path, queryParameters: {...uri.queryParameters, '_userId': user.auth!.userId});
    final buffer = StringBuffer('============ start ${request.path} ============\n');
    buffer.writeln(uri);
    // buffer.writeln(headers);
    buffer.writeln(form.data);
    request.params = form.map;
    final lastRequestOptions = user.lastRequestOptions = RequestOptionsSaveData(
      createdAt: getNowTimestamp(),
      path: request.path,
      key: request.key,
      url: uri.toString(),
      formData: form.data,
      headers: headers.deepCopy(),
    );
    notifyListeners();

    if (request.sendDelay > Duration.zero) {
      await Future.delayed(request.sendDelay);
      if (stopFlag) {
        stopFlag = false;
        throw SilentException('Manual Stop Flag, current request: ${request.key}');
      }
      notifyListeners();
    }
    final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));
    final Response rawResp = await dio.post(
      uri.toString(),
      data: form.data,
      options: Options(
        headers: headers,
        followRedirects: true,
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    if (rawResp.statusCode == HttpStatus.ok) {
      lastRequestOptions.success = true;
      notifyListeners();
    }
    request.rawRequest = rawResp.requestOptions;
    request.rawResponse = rawResp;
    // buffer.writeln(rawResp.headers);
    final _jsonData = FateTopLogin.parseToMap(rawResp.data);
    // final _jsonData = jsonEncode();
    buffer.writeln(jsonEncode(_jsonData['response'] ?? []).substring2(0, 2000));
    if (request.path.contains('login/top')) {
      // buffer.writeln(_jsonData.substring2(0, 000));
    } else {
      // buffer.writeln(_jsonData);
    }
    buffer.write('============ end ${request.path} ============');
    // final s = buffer.toString();
    logger.t(buffer.toString());
    final serverTimeStr = rawResp.headers['X-Server-Time']?.firstOrNull;
    if (serverTimeStr != null) {
      final serverTime = int.tryParse(serverTimeStr);
      if (serverTime != null) request.serverTime = serverTime;
    }
    return rawResp;
  }
}
