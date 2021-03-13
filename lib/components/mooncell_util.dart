import 'package:chaldea/components/components.dart';
import 'package:dio/dio.dart';

class MooncellUtil {
  MooncellUtil._();

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

  static Future<String?> resolveFileUrl(String filename) async {
    if (db.prefs.containsKey(filename)) {
      // print('prefs: $filename -> ${db.prefs.getString(filename)}');
      return db.prefs.getString(filename);
    }
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
      final String url =
          response.data['query']['pages'].values.first['imageinfo'][0]['url'];
      print('wiki image/file url $filename ->  $url');
      db.prefs.setString(filename, url);
      return url;
    } catch (e) {
      print(e);
    }
  }
}
