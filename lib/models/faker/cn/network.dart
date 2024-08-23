import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import '../../userdata/autologin.dart';
import '../shared/network.dart';

export '../shared/network.dart';

class FRequestCN extends FRequestBase {
  final NetworkManagerCN network;
  // path includes query
  FRequestCN({required this.network, required super.path, required String super.key});

  Map<String, String> formData = {};
  WWWForm form = WWWForm();

  void addField(String key, Object value) {
    form.addField(key, value.toString());
  }

  @override
  Future<FResponse> beginRequestAndCheckError(String? nid) async {
    final resp = await beginRequest();
    return resp.throwError(nid);
  }

  @override
  Future<FResponse> beginRequest() async {
    return network.requestStart(this);
  }
}

class NetworkManagerCN extends NetworkManagerBase<FRequestCN, AutoLoginDataCN> {
  NetworkManagerCN({required super.gameTop, required super.user});

  @override
  Future<Response> requestStartImpl(FRequestCN request) async {
    assert(request.path.startsWith('https://'));
    final form = request.form;
    final Map<String, dynamic> headers = {};
    final String unityVersion = gameTop.unityVer ?? '2022.3.28f1';

    headers[HttpHeaders.contentTypeHeader] = Headers.formUrlEncodedContentType;
    // bili-sdk(etc): Mozilla/5.0 BSGameSDK
    headers[HttpHeaders.userAgentHeader] = user.userAgent.isEmpty
        ? (user.isAndroidDevice
            ? "UnityPlayer/$unityVersion (UnityWebRequest/1.0, libcurl/8.4.0-DEV)"
            : "fatego/20 CFNetwork/1327.0.4 Darwin/21.2.0")
        : user.userAgent;
    updateCookies(headers);
    headers['X-Unity-Version'] = unityVersion;

    request.sendTime = getNowTimestamp();
    Uri uri = Uri.parse(request.path);
    final buffer = StringBuffer('============ start ${request.key} ============\n');
    buffer.writeln(uri);
    // buffer.writeln(headers);
    buffer.writeln(form.data);
    print(buffer.toString());
    final Response rawResp = await Dio().post(
      uri.toString(),
      data: form.data,
      options: Options(
        headers: headers,
      ),
    );
    request.rawRequest = rawResp.requestOptions;
    request.rawResponse = rawResp;
    buffer.clear();
    // buffer.writeln(rawResp.headers);
    final _jsonData = FateTopLogin.parseToMap(rawResp.data);
    // final _jsonData = jsonEncode();
    buffer.writeln(jsonEncode(_jsonData['response'] ?? []).substring2(0, 2000));
    if (request.path.contains('toplogin')) {
      // buffer.writeln(_jsonData.substring2(0, 000));
    } else {
      // buffer.writeln(_jsonData);
    }
    buffer.write('============ end ${request.key} ============');
    // final s = buffer.toString();
    logger.t(buffer.toString());

    return rawResp;
  }
}
