import 'package:chaldea/components/components.dart';

class BugAnnouncePage extends StatelessWidget {
  final List<_BugDetail> bugs = [
    _BugDetail(
      title: '本页罗列当前版本已发现的BUG',
      content: '但无法短时间内解决，如有其他bug请反馈',
      titleEn: 'Bugs in Current Version',
      contentEn:
          'cannot be fixed currently. If there is other bugs, please send feedback.',
    ),
    _BugDetail(
      title: '滚动条错误',
      content: '主要存在于桌面端，当一个页面存在多个标签页(Tab)时，请勿拖动滚动条。使用滚轮或直接拖拽页面',
      titleEn: 'Scrollbar error',
      contentEn:
          'On desktop version, don\'t drag scrollbar if there are multiple tabs. Please use mouse or drag page body instead',
    ),
    _BugDetail(
      title: '输入框删除问题',
      content:
          '主要存在于Android，等待官方修复\nhttps://github.com/flutter/flutter/issues/80226',
      titleEn: 'Deletion in input field',
      contentEn:
          'On Android, deletion may cause error, wait for official fix\nhttps://github.com/flutter/flutter/issues/80226',
    ),
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
              subtitle: Text(bug.getContent()),
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

  _BugDetail({
    required this.title,
    required this.content,
    required this.titleEn,
    required this.contentEn,
  });

  String getTitle() {
    return Language.isCN ? title : titleEn ?? title;
  }

  String getContent() {
    return Language.isCN ? content : contentEn ?? content;
  }
}
