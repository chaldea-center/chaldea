//@dart=2.12
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';
import 'package:getwidget/getwidget.dart';

class ItemObtainInterludeTab extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    final sortedServants = sortSvts(db.gameData.svtQuests.keys.toList());
    for (int svtNo in sortedServants) {
      bool svtFavorite = db.curUser.svtPlanOf(svtNo).favorite;
      if (!favorite || svtFavorite) {
        final quests = db.gameData.svtQuests[svtNo];
        for (var quest in quests!) {
          int itemCount = 0;
          itemCount += quest.rewards[itemKey] ?? 0;
          quest.battles.forEach((battle) {
            itemCount += battle.drops[itemKey] ?? 0;
          });
          if (itemCount > 0) {
            children.add(GFAccordion(
              titlePadding: EdgeInsets.all(0),
              margin: EdgeInsets.symmetric(vertical: 0),
              titleChild: CustomTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                leading: db.getIconImage(db.gameData.servants[svtNo]!.icon,
                    width: 40),
                subtitle: Text(quest.localizedName),
                trailing: Text(
                  itemCount.toString(),
                  style: TextStyle(color: svtFavorite ? Colors.blue : null),
                ),
              ),
              contentChild: QuestCard(quest: quest),
            ));
          }
        }
      }
    }
    if (children.isEmpty) {
      children.add(ListTile(
        title: Text(S.of(context).no_servant_quest_hint),
        subtitle: favorite
            ? Text(S.of(context).no_servant_quest_hint_subtitle)
            : null,
      ));
    }
    return ListView(children: children);
  }

  List<int> sortSvts(List<int> svts) {
    List<SvtCompare> sortKeys;
    List<bool> sortReversed;
    if (sortType == 0) {
      sortKeys = [SvtCompare.no];
      sortReversed = [true];
    } else if (sortType == 1) {
      sortKeys = [SvtCompare.className, SvtCompare.rarity, SvtCompare.no];
      sortReversed = [false, true, true];
    } else {
      sortKeys = [SvtCompare.rarity, SvtCompare.className, SvtCompare.no];
      sortReversed = [true, false, true];
    }
    svts.sort((a, b) => Servant.compare(db.gameData.servants[a],
        db.gameData.servants[b], sortKeys, sortReversed));
    return svts;
  }
}
