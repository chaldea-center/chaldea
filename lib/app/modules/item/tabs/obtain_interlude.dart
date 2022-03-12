import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../../common/quest_card.dart';

class ItemObtainInterludeTab extends StatefulWidget {
  final int itemId;
  final bool favorite;

  const ItemObtainInterludeTab({
    Key? key,
    required this.itemId,
    this.favorite = true,
  }) : super(key: key);

  @override
  _ItemObtainInterludeTabState createState() => _ItemObtainInterludeTabState();
}

class _ItemObtainInterludeTabState extends State<ItemObtainInterludeTab> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final sortedServants = sortSvts(db2.gameData.servants.values.toList());
    for (final svt in sortedServants) {
      bool svtFavorite = db2.curUser.svtStatusOf(svt.collectionNo).favorite;
      if (widget.favorite && !svtFavorite) continue;
      for (final questId in svt.relateQuestIds) {
        final quest = db2.gameData.quests[questId];
        if (quest == null) continue;
        int itemCount = 0;
        for (final gift in quest.gifts) {
          if (gift.objectId == widget.itemId) {
            itemCount += gift.num;
          }
        }
        for (int phase in quest.phases) {
          itemCount += db2.gameData.fixedDrops[questId * 100 + phase]
                  ?.items[widget.itemId] ??
              0;
        }
        if (itemCount > 0) {
          children.add(_buildOneQuest(
            quest: quest,
            itemCount: '$itemCount',
            favorite: svtFavorite,
            svt: svt,
          ));
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

  Widget _buildOneQuest({
    required Quest quest,
    required String itemCount,
    required bool favorite,
    required Servant svt,
  }) {
    return SimpleAccordion(
      headerBuilder: (context, expanded) {
        return CustomTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          leading: svt.iconBuilder(context: context, width: 36),
          subtitle: Row(
            children: [
              Expanded(child: Text(quest.lName.l)),
              Text(itemCount,
                  style: TextStyle(color: favorite ? Colors.blue : null))
            ],
          ),
        );
      },
      contentBuilder: (context) => QuestCard(quest: quest),
    );
  }

  List<Servant> sortSvts(List<Servant> svts) {
    List<SvtCompare> sortKeys;
    List<bool> sortReversed;
    switch (db2.settings.display.itemDetailSvtSort) {
      case ItemDetailSvtSort.collectionNo:
        sortKeys = [SvtCompare.no];
        sortReversed = [true];
        break;
      case ItemDetailSvtSort.clsName:
        sortKeys = [SvtCompare.className, SvtCompare.rarity, SvtCompare.no];
        sortReversed = [false, true, true];
        break;
      case ItemDetailSvtSort.rarity:
        sortKeys = [SvtCompare.rarity, SvtCompare.className, SvtCompare.no];
        sortReversed = [true, false, true];
        break;
    }
    svts.sort((a, b) =>
        SvtFilterData.compare(a, b, keys: sortKeys, reversed: sortReversed));
    return svts;
  }
}
