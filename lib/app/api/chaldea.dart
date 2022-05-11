import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../models/db.dart';
import '../../packages/app_info.dart';
import '../../packages/language.dart';
import 'hosts.dart';

// ignore: unused_element
bool _defaultValidateStat(int? statusCode) {
  return statusCode != null && statusCode >= 200 && statusCode < 500;
}

class ChaldeaResponse {
  final Response? response;

  final dynamic error;

  ChaldeaResponse(this.response) : error = null;

  ChaldeaResponse.error(this.error) : response = null;

  int? get statusCode => response?.statusCode;

  Map? _cachedJson;

  Map? json() {
    if (_cachedJson != null) return _cachedJson;
    if (response?.data == null) return null;
    if (response!.data is Map) {
      return _cachedJson = response!.data;
    }
    try {
      var plain = response!.data is List<int>
          ? utf8.decode(response!.data)
          : response!.data;
      return _cachedJson = jsonDecode(plain);
    } catch (e) {
      return null;
    }
  }

  bool get success => error == null && json()?['success'] == true;

  String? get message => error?.toString() ?? json()?['message'];

  T? body<T>() {
    var _body = json()?['body'];
    if (_body is T) return _body;
    return null;
  }

  static Future<void> request({
    required Future<Response> Function(Dio dio) caller,
    void Function(ChaldeaResponse)? onSuccess,
    bool showSuccess = true,
  }) async {
    try {
      EasyLoading.show(maskType: EasyLoadingMaskType.clear);
      print('apiWorkerDio: ${db.apiWorkerDio.options.baseUrl}');
      var resp = ChaldeaResponse(await caller(db.apiWorkerDio));
      if (resp.success) {
        onSuccess?.call(resp);
        if (showSuccess) {
          SimpleCancelOkDialog(
            title: Text(S.current.success),
            content: resp.message == null ? null : Text(resp.message!),
          ).showDialog(null);
        }
      } else {
        SimpleCancelOkDialog(
          title: Text(S.current.failed),
          content: Text(resp.message ?? resp.body()),
        ).showDialog(null);
      }
    } catch (e) {
      SimpleCancelOkDialog(
        title: Text(S.current.failed),
        content: Text(escapeDioError(e)),
      ).showDialog(null);
    } finally {
      EasyLoading.dismiss();
    }
  }
}

class ChaldeaApi {
  const ChaldeaApi._();

  static Dio get dio {
    return Dio(BaseOptions(
      baseUrl: Hosts.apiHost,
      // baseUrl: kDebugMode ? 'http://localhost:8000/' : Apis.apiRoot,
      queryParameters: {
        'key': AppInfo.uuid,
        'ver': AppInfo.versionString,
        'build': AppInfo.buildNumber,
        'lang': Language.current.code,
        'os': PlatformU.operatingSystem,
      },
      // validateStatus: _defaultValidateStat,
    ));
  }

  static Future<ChaldeaResponse> wrap(
      Future<Response> Function(Dio dio) callback) async {
    return ChaldeaResponse(await callback(dio));
  }

  static Future<ChaldeaResponse> sendFeedback({
    String? subject,
    String? senderName,
    String? html,
    String? text,
    // <filename, bytes>
    Map<String, Uint8List> files = const {},
  }) {
    var formData = FormData.fromMap({
      if (html != null) 'html': html,
      if (text != null) 'text': text,
      if (subject != null) 'subject': subject,
      if (senderName != null) 'sender': senderName,
      'files': [
        for (final file in files.entries)
          MultipartFile.fromBytes(file.value, filename: file.key),
      ]
    });
    return wrap((dio) => dio.post('/feedback', data: formData));
  }
}
