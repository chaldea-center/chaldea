//@dart=2.12
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';

class ItemObtainInterludeTab extends StatefulWidget {
  final String itemKey;
  final bool favorite;
  final int sortType;

  const ItemObtainInterludeTab(
      {Key? key,
      required this.itemKey,
      this.favorite = true,
      this.sortType = 0})
      : super(key: key);

  @override
  _ItemObtainInterludeTabState createState() => _ItemObtainInterludeTabState();
}

class _ItemObtainInterludeTabState extends State<ItemObtainInterludeTab> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final sortedServants = sortSvts(db.gameData.svtQuests.keys.toList());
    for (int svtNo in sortedServants) {
      bool svtFavorite = db.curUser.svtPlanOf(svtNo).favorite;
      if (!widget.favorite || svtFavorite) {
        final quests = db.gameData.svtQuests[svtNo];
        for (var quest in quests!) {
          int itemCount = 0;
          itemCount += quest.rewards[widget.itemKey] ?? 0;
          quest.battles.forEach((battle) {
            itemCount += battle.drops[widget.itemKey] ?? 0;
          });
          if (itemCount > 0) {
            children.add(_buildOneQuest(
              quest: quest,
              itemCount: itemCount,
              favorite: svtFavorite,
              svt: db.gameData.servants[svtNo]!,
            ));
          }
        }
      }
    }
    if (children.isEmpty) {
      children.add(ListTile(
        title: Text(S.of(context).no_servant_quest_hint),
        subtitle: widget.favorite
            ? Text(S.of(context).no_servant_quest_hint_subtitle)
            : null,
      ));
    }
    return ListView.separated(
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (context, _) => kDefaultDivider,
      itemCount: children.length,
    );
  }

  Widget _buildOneQuest(
      {required Quest quest,
      required int itemCount,
      required bool favorite,
      required Servant svt}) {
    return SimpleAccordion(
      headerBuilder: (context, expanded) {
        return CustomTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          leading: db.getIconImage(svt.icon, width: 40),
          subtitle: Row(
            children: [
              Expanded(child: Text(quest.localizedName)),
              Text(itemCount.toString(),
                  style: TextStyle(color: favorite ? Colors.blue : null))
            ],
          ),
        );
      },
      contentBuilder: (context) => QuestCard(quest: quest),
    );
  }

  List<int> sortSvts(List<int> svts) {
    List<SvtCompare> sortKeys;
    List<bool> sortReversed;
    if (widget.sortType == 0) {
      sortKeys = [SvtCompare.no];
      sortReversed = [true];
    } else if (widget.sortType == 1) {
      sortKeys = [SvtCompare.className, SvtCompare.rarity, SvtCompare.no];
      sortReversed = [false, true, true];
    } else {
      sortKeys = [SvtCompare.rarity, SvtCompare.className, SvtCompare.no];
      sortReversed = [true, false, true];
    }
    svts.sort((a, b) => Servant.compare(
        db.gameData.servants[a], db.gameData.servants[b],
        keys: sortKeys, reversed: sortReversed, user: db.curUser));
    return svts;
  }
}
