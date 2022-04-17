import 'package:dio/dio.dart';

import 'package:chaldea/packages/packages.dart';

class GitTool {
  GitTool();

  static Future<String> giteeWikiPage(String wikiTitle,
      {bool htmlFmt = false}) async {
    final url =
        'https://gitee.com/chaldea-center/chaldea/wikis/pages/wiki?wiki_title=$wikiTitle&version_id=master&extname=.md';
    String content = '';
    try {
      final data = (await Dio().get(url)).data;
      content =
          htmlFmt ? data['wiki']['content_html'] : data['wiki']['content'];
    } catch (e, s) {
      logger.e('get gitee wiki "$wikiTitle" failed', e, s);
    }
    return content;
  }
}
