import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:dio/dio.dart';
import 'package:pool/pool.dart';

class MooncellUtil {
  MooncellUtil._();

  static Pool _pool = Pool(50);

  static String domain = 'https://fgo.wiki';

  static Dio get _dio => Dio(BaseOptions(baseUrl: domain));

  static Future<String> pageContent(String title) async {
    try {
      final response = await _dio.get(
        '/api.php',
        queryParameters: {
          "action": "query",
          "format": "json",
          "prop": "revisions",
          "continue": "",
          "titles": title,
          "utf8": 1,
          "rvprop": "content"
        },
        options: Options(responseType: ResponseType.json),
      );
      String content =
          response.data['query']['pages'].values.first['revisions'][0]['*'];
      return content;
    } catch (e, s) {
      EasyLoading.showError(e.toString());
      logger.e('failed to get wikitext', e, s);
    }
    return '';
  }

  static String fullLink(String title, {bool encode = false}) {
    String link = '$domain/w/$title';
    if (encode) link = Uri.encodeFull(link);
    return link;
  }

  static Map<String, Future<String?>> _resolveUrlTasks = {};

  /// If [savePath] is provided, the file will be downloaded
  static Future<String?> resolveFileUrl(String filename,
      [String? savePath]) async {
    if (db.prefs.containsRealUrl(filename)) {
      // print('prefs: $filename -> ${db.prefs.getString(filename)}');
      return db.prefs.getRealUrl(filename);
    }
    if (_resolveUrlTasks.containsKey(filename)) {
      return _resolveUrlTasks[filename]!;
    }
    final future = _pool.withResource<String?>(() async {
      final _dio = Dio();
      try {
        final response = await _dio.get(
          'https://fgo.wiki/api.php',
          queryParameters: {
            "action": "query",
            "format": "json",
            "prop": "imageinfo",
            "iiprop": "url",
            "titles": "File:$filename"
          },
          options: Options(responseType: ResponseType.json),
        );
        final String? url =
            response.data['query']['pages'].values.first['imageinfo'][0]['url'];
        if (url?.isNotEmpty == true) {
          await db.prefs.setRealUrl(filename, url!);
          if (savePath != null) {
            Response fileResponse = await _dio.get(url,
                options: Options(responseType: ResponseType.bytes));
            if (fileResponse.statusCode == 200) {
              File file = File(savePath);
              await file.writeAsBytes(fileResponse.data, flush: true);
              logger.i('downloaded $url to $savePath');
            } else {
              throw HttpException('HTTP ${fileResponse.statusCode}',
                  uri: Uri.tryParse(url));
            }
          }
        }
        print('mc file: $filename -> $url');
        return url;
      } catch (e) {
        logger.e('error download $filename', e);
      } finally {
        _resolveUrlTasks.remove(filename);
      }
    });
    _resolveUrlTasks[filename] = future;
    return future;
  }
}
