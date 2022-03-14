import 'dart:convert';
import 'dart:typed_data';

import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:dio/dio.dart';

import '../../packages/app_info.dart';
import '../../packages/language.dart';

bool _defaultValidateStat(int? statusCode) {
  return statusCode != null;
}

class ChaldeaResponse {
  final Response? response;

  final dynamic error;

  ChaldeaResponse(this.response) : error = null;

  ChaldeaResponse.error(this.error) : response = null;

  int? get statusCode => response?.statusCode;

  Map? _cachedJson;

  Map? json() {
    print(response?.data);
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
}

class ChaldeaApi {
  const ChaldeaApi._();

  static Dio get dio {
    return Dio(BaseOptions(
      baseUrl: kServerRoot,
      // baseUrl: kDebugMode ? 'http://localhost:8183' : kServerRoot,
      headers: {
        'chaldea-version': AppInfo.versionString,
        'chaldea-build': AppInfo.buildNumber,
        'chaldea-lang': Language.current.code,
        'chaldea-os': PlatformU.operatingSystem,
      },
      validateStatus: _defaultValidateStat,
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
      if (senderName != null) 'from': senderName,
      for (final file in files.entries)
        file.key: MultipartFile.fromBytes(file.value, filename: file.key),
    });
    return wrap((dio) => dio.post('/feedback', data: formData));
  }
}
