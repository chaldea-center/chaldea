import 'package:tuple/tuple.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../quest/quest_card.dart';

class ItemObtainFreeTab extends StatefulWidget {
  final int itemId;

  const ItemObtainFreeTab({super.key, required this.itemId});

  @override
  _ItemObtainFreeTabState createState() => _ItemObtainFreeTabState();
}

class _ItemObtainFreeTabState extends State<ItemObtainFreeTab> {
  bool get sortByAP => db.settings.display.itemQuestsSortByAp;

  set sortByAP(bool v) {
    db.settings.display.itemQuestsSortByAp = v;
    db.saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          elevation: 1,
          child: ListTile(
            title: Text(S.current.quest),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[buildSortRadio(true), buildSortRadio(false)],
            ),
          ),
        ),
        Expanded(child: InheritSelectionArea(child: ListView(children: buildMainFreeQuests()))),
      ],
    );
  }

  Widget buildSortRadio(bool value) {
    return RadioWithLabel<bool>(
      value: value,
      groupValue: sortByAP,
      label: Text(
        value ? S.current.ap_efficiency : S.current.drop_rate,
        style: value == sortByAP ? null : TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
      ),
      onChanged: (v) => setState(() => sortByAP = v ?? sortByAP),
    );
  }

  List<Widget> buildMainFreeQuests() {
    final dropRateData = db.gameData.dropData.domusAurea;
    int rowIndex = dropRateData.itemIds.indexOf(widget.itemId);
    if (rowIndex < 0) {
      return [ListTile(title: Text(S.current.item_no_free_quests))];
    }
    final dropMatrix = dropRateData.matrix[rowIndex];
    final List<Tuple3<double, double, Widget>> tmpData = [];
    for (var i = 0; i < dropRateData.questIds.length; i++) {
      if (dropMatrix[i] <= 0) continue;
      int questId = dropRateData.questIds[i];
      final apRate = dropRateData.apCosts[i] / dropMatrix[i], dropRate = dropMatrix[i];
      final dropRateString = (dropRate * 100).toStringAsFixed(2), apRateString = apRate.toStringAsFixed(2);
      final quest = db.gameData.quests[questId];
      final apUnit = quest?.consumeType.unit ?? 'AP';
      final child = SimpleAccordion(
        key: ValueKey('main_free_$questId'),
        headerBuilder: (context, _) {
          return ListTile(
            dense: true,
            title: Text(quest?.lDispName.setMaxLines(1) ?? 'Quest $questId'),
            subtitle: Text(
              'Cost ${quest?.consume ?? dropRateData.apCosts[i]}$apUnit.  ${sortByAP ? '${S.current.drop_rate} $dropRateString%.' : '${S.current.ap_efficiency} $apRateString $apUnit.'}',
            ),
            trailing: Text(sortByAP ? '$apRateString $apUnit' : '$dropRateString%'),
          );
        },
        contentBuilder: (context) {
          if (quest == null) return SFooter('Quest $questId not found');
          return QuestCard(quest: quest);
        },
        expandIconBuilder: (context, _) => const SizedBox.shrink(),
      );
      tmpData.add(Tuple3(apRate, dropRate, child));
    }
    tmpData.sort((a, b) => (sortByAP ? a.item1 - b.item1 : b.item2 - a.item2).sign.toInt());
    return [
      ...tmpData.map((e) => e.item3),
      const Divider(height: 16, thickness: 0.5, indent: 16, endIndent: 16),
      const SafeArea(child: SizedBox()),
    ];
  }
}
