import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';

class FreeQuestQueryTab extends StatefulWidget {
  const FreeQuestQueryTab({Key? key}) : super(key: key);

  @override
  _FreeQuestQueryTabState createState() => _FreeQuestQueryTabState();
}

class _FreeQuestQueryTabState extends State<FreeQuestQueryTab> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == '/')
          return SplitRoute(
              builder: (context, _) => _ChapterList(), detail: null);
      },
    );
  }
}

class _ChapterList extends StatelessWidget {
  const _ChapterList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, List<Quest>> chapters = {};
    db.gameData.freeQuests.values.forEach((quest) {
      chapters.putIfAbsent(quest.chapter, () => []).add(quest);
    });
    List<String> chapterNames = chapters.keys.toList();
    chapterNames.sort((a, b) {
      final recordA = db.gameData.events.mainRecords[a];
      final recordB = db.gameData.events.mainRecords[b];
      if (recordA == null && recordB == null) {
        return 0;
      } else if (recordA != null && recordB != null) {
        return recordA.startTimeJp?.compareTo(recordB.startTimeJp ?? '') ?? 0;
      } else if (recordA == null) {
        return -1;
      } else if (recordB == null) {
        return 1;
      }
      return 0;
    });
    List<Widget> children = [];
    chapterNames.forEach((chapter) {
      final quests = chapters[chapter]!;
      children.add(ListTile(
        title: AutoSizeText(
          Localized.chapter.of(chapter),
          maxFontSize: 14,
        ),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          Navigator.of(context).push(SplitRoute(
            builder: (context, _) =>
                _ChapterFreeQuests(chapter: chapter, quests: quests),
            detail: null,
          ));
        },
      ));
    });
    return ListView.separated(
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (context, index) => kDefaultDivider,
      itemCount: children.length,
    );
  }
}

class _ChapterFreeQuests extends StatelessWidget {
  final String chapter;
  final List<Quest> quests;

  const _ChapterFreeQuests(
      {Key? key, required this.chapter, required this.quests})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Card(
            margin: EdgeInsets.all(8),
            child: Row(
              children: [
                const SizedBox(width: 4),
                BackButton(color: Theme.of(context).hintColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 8, 6),
                    child: Text(
                      Localized.chapter.of(chapter),
                      style: Theme.of(context).textTheme.bodyText1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final quest in quests)
            SimpleAccordion(
              headerBuilder: (context, _) => ListTile(
                title: Text(quest.localizedKey),
                subtitle: !Language.isJP && quest.placeJp != null
                    ? Text(quest.placeJp!)
                    : null,
              ),
              contentBuilder: (context) => QuestCard(quest: quest),
            ),
        ],
      ),
    );
  }
}
