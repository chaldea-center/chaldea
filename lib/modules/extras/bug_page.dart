import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/home/subpage/feedback_page.dart';
import 'package:url_launcher/url_launcher.dart';

class BugAnnouncePage extends StatelessWidget {
  final _BugDetail header = _BugDetail(
    title: '本页罗列可能出现的BUG',
    content: '欢迎积极反馈 φ(≧ω≦*)♪',
    titleEn: 'Potential Bugs',
    contentEn: 'Any suggestion is welcomed φ(≧ω≦*)♪',
  );

  final List<_BugDetail> bugs = [
    _BugDetail(
      title: '翻译错误/不全',
      content: '欢迎纠错/提供翻译',
      titleEn: 'Translations',
      contentEn: 'Any suggestion(mistake/missing/adding) is welcomed.',
    ),
    _BugDetail(
      title: '游戏文本/数据有误',
      content:
          '请先在[Mooncell](https://fgo.wiki)及英文wiki[Fandom](https://fategrandorder.fandom.com/wiki/)上确认是否正确，'
          '若wiki上有误，请积极投入编辑大军。若wiki正确但APP内解析出错，请反馈。',
      titleEn: 'Wrong text/data',
      contentEn:
          'If possible, please check the correctness on [Mooncell](https://fgo.wiki) and [Fandom](https://fategrandorder.fandom.com/wiki/)\n'
          'If only wrong in app, please send feedback to let me know.',
    ),
    // _BugDetail(
    //     title: '输入框操作过快问题',
    //     content: '主要存在于从者等列表页的搜索框，等待官方修复',
    //     titleEn: 'Input/delete too fast in input field',
    //     contentEn:
    //         'Mostly happens on search box in servant/craft list page, wait for official fix.',
    //     link: 'https://github.com/flutter/flutter/issues/80226'),
    _BugDetail(
        title: '技能/素材识别功能',
        content: '新功能，需要多测试，有任何问题欢迎反馈\n',
        titleEn: 'Skill/Item recognition',
        contentEn: 'New feature, any advice/feedback is welcomed.\n'),
    _BugDetail(
        title: '滚动条不能拖动',
        content: '主要发生在桌面端，同一个页面(包含子标签页)含有多个滚动组件时可能发生，请反馈修复！\n',
        titleEn: 'Cannot drag scrollbar',
        contentEn:
            'Mostly on desktop when two or more scrollbars in one page(including sub-tabs). Please let me know to fix it.\n'),
    _BugDetail(
        title: '重复从者(2号机)',
        content: '当存在2号机时，部分页面可能出错，请反馈。\n\n临时解决方案：删除2号机。',
        titleEn: 'Duplicated servants',
        contentEn:
            'Some pages may went wrong because of duplicated servants.\n\n'
            'Temp fix: remove duplicated servants.\n\n'
            'Please send feedback to let me fix it.'),
  ];

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(Card(
      child: ListTile(
        title: Center(child: Text(header.getTitle())),
        subtitle: Center(child: Text(header.getContent())),
      ),
    ));
    for (int index = 0; index < bugs.length; index++) {
      final bug = bugs[index];
      children.add(SimpleAccordion(
        headerBuilder: (ctx, _) =>
            ListTile(title: Text('$index. ${bug.getTitle()}')),
        contentBuilder: (ctx) => ListTile(
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyMarkdownWidget(
                data: bug.getContent(),
                scrollable: false,
              ),
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
      ));
    }
    children.add(Align(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: ElevatedButton(
          onPressed: () {
            SplitRoute.push(
              context: context,
              builder: (ctx, _) => FeedbackPage(),
            );
          },
          child: Text(S.current.about_feedback),
          style: ElevatedButton.styleFrom(),
        ),
      ),
    ));
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('BUGS'),
      ),
      body: ListView.separated(
        itemBuilder: (ctx, index) => children[index],
        separatorBuilder: (ctx, index) => kDefaultDivider,
        itemCount: children.length,
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

  const _BugDetail({
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
