import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../quest/quest_card.dart';

class ItemObtainInterludeTab extends StatefulWidget {
  final int itemId;

  const ItemObtainInterludeTab({super.key, required this.itemId});

  @override
  _ItemObtainInterludeTabState createState() => _ItemObtainInterludeTabState();
}

class _ItemObtainInterludeTabState extends State<ItemObtainInterludeTab> {
  bool _favorite = true;
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      RadioGroup<bool>(
        groupValue: _favorite,
        onChanged: (v) {
          if (v != null) {
            _favorite = v;
          }
          setState(() {});
        },
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: [
            for (final fav in [true, false])
              RadioWithLabel<bool>(value: fav, label: Text(fav ? S.current.favorite : S.current.general_all)),
          ],
        ),
      ),
    ];
    final sortedServants = sortSvts(db.gameData.servantsNoDup.values.toList());
    for (final svt in sortedServants) {
      bool svtFavorite = svt.status.favorite;
      if (_favorite && !svtFavorite) continue;
      for (final questId in svt.relateQuestIds) {
        final quest = db.gameData.quests[questId];
        if (quest == null) continue;
        int itemCount = 0;
        for (final gift in quest.giftsWithPhasePresents) {
          if (gift.objectId == widget.itemId) {
            itemCount += gift.num;
          }
        }
        for (int phase in quest.phases) {
          itemCount += db.gameData.dropData.fixedDrops[questId * 100 + phase]?.items[widget.itemId] ?? 0;
        }
        if (itemCount > 0) {
          children.add(_buildOneQuest(quest: quest, itemCount: itemCount.format(), favorite: svtFavorite, svt: svt));
        }
      }
    }
    if (children.isEmpty) {
      children.add(
        ListTile(
          title: Text(S.current.no_servant_quest_hint),
          subtitle: _favorite ? Text(S.current.no_servant_quest_hint_subtitle) : null,
        ),
      );
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
          contentPadding: const EdgeInsetsDirectional.fromSTEB(10, 5, 0, 5),
          leading: svt.iconBuilder(context: context, width: 36),
          subtitle: Row(
            children: [
              Expanded(child: Text(quest.lName.l)),
              Text(itemCount, style: TextStyle(color: favorite ? Colors.blue : null)),
            ],
          ),
        );
      },
      contentBuilder: (context) => QuestCard(quest: quest),
    );
  }

  List<Servant> sortSvts(List<Servant> svts) {
    List<SvtCompare> sortKeys = switch (db.settings.display.itemDetailSvtSort) {
      ItemDetailSvtSort.collectionNo => [SvtCompare.collectionNo],
      ItemDetailSvtSort.clsName => SvtCompare.kClassFirstKeys,
      ItemDetailSvtSort.rarity => SvtCompare.kRarityFirstKeys,
    };
    svts.sort((a, b) => SvtFilterData.compare(a, b, keys: sortKeys));
    return svts;
  }
}
