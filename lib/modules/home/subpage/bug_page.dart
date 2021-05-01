import 'package:chaldea/components/components.dart';
import 'package:url_launcher/url_launcher.dart';

class BugAnnouncePage extends StatelessWidget {
  final List<_BugDetail> bugs = [
    _BugDetail(
      title: '本页罗列当前版本已发现的BUG',
      content: '但无法短时间内解决，如有其他bug请反馈',
      titleEn: 'Bugs in Current Version',
      contentEn:
          'cannot be fixed immediately. If there is any other bug, please send feedback.',
    ),
    _BugDetail(
      title: '翻译错误/不全',
      content: '欢迎纠错/提供翻译',
      titleEn: 'Translations',
      contentEn: 'Any suggestion is welcomed.\n',
    ),
    _BugDetail(
        title: '输入框删除问题',
        content: '主要存在于Android，等待官方修复',
        titleEn: 'Deletion in input field',
        contentEn:
            'On Android, deletion may cause error, wait for official fix',
        link: 'https://github.com/flutter/flutter/issues/80226'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('BUGS'),
      ),
      body: ListView.separated(
        itemBuilder: (ctx, index) {
          final bug = bugs[index];
          if (index == 0) {
            return ListTile(
              title: Text(bug.getTitle()),
              subtitle: Text(bug.getContent()),
            );
          }
          return SimpleAccordion(
            headerBuilder: (ctx, _) =>
                ListTile(title: Text('$index. ${bug.getTitle()}')),
            contentBuilder: (ctx) => ListTile(
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bug.getContent()),
                  if (bug.link != null)
                    TextButton(
                      onPressed: () {
                        launch(bug.link!);
                      },
                      child: Text(bug.link!),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    )
                ],
              ),
            ),
          );
        },
        separatorBuilder: (ctx, index) => kDefaultDivider,
        itemCount: bugs.length,
      ),
    );
  }
}

class _BugDetail {
  final String title;
  final String content;
  final String? titleEn;
  final String? contentEn;
  final String? link;

  _BugDetail({
    required this.title,
    required this.content,
    required this.titleEn,
    required this.contentEn,
    this.link,
  });

  String getTitle() {
    return Language.isCN ? title : titleEn ?? title;
  }

  String getContent() {
    return Language.isCN ? content : contentEn ?? content;
  }
}
