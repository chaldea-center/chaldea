import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';

class QuestListPage extends StatelessWidget {
  final String title;
  final List<Quest> quests;
  final bool showChapter;

  const QuestListPage({
    Key? key,
    required this.title,
    required this.quests,
    this.showChapter = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (final quest in quests) {
      String questTitle = showChapter ? quest.chapter : quest.localizedName;
      String? subtitle = showChapter
          ? quest.localizedName
          : (!Language.isJP && quest.placeJp != null ? quest.placeJp : null);
      children.add(SimpleAccordion(
        headerBuilder: (context, _) => ListTile(
          title: Text(questTitle),
          subtitle: subtitle == null ? null : Text(subtitle),
        ),
        contentBuilder: (context) => QuestCard(quest: quest),
      ));
    }
    if (children.isEmpty) {
      children.add(const ListTile(title: Center(child: Text('╮(￣▽￣)╭'))));
    }
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          title,
          minFontSize: 12,
          maxLines: 1,
          overflow: TextOverflow.fade,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: children,
      ),
    );
  }
}
