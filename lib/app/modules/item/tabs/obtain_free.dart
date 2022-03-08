import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../../common/quest_card.dart';

class ItemObtainFreeTab extends StatefulWidget {
  final int itemId;

  const ItemObtainFreeTab({Key? key, required this.itemId}) : super(key: key);

  @override
  _ItemObtainFreeTabState createState() => _ItemObtainFreeTabState();
}

class _ItemObtainFreeTabState extends State<ItemObtainFreeTab> {
  bool get sortByAP => db2.settings.display.itemQuestsSortByAp;

  set sortByAP(bool v) {
    db2.settings.display.itemQuestsSortByAp = v;
    db2.saveSettings();
  }

  bool use6th = db2.curUser.use6thDropRate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          elevation: 1,
          child: ListTile(
            title: Wrap(
              spacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(S.current.quest),
                FilterOption(
                  selected: use6th,
                  value: '6th',
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text('6th'),
                  ),
                  onChanged: (v) => setState(() {
                    use6th = v;
                  }),
                  shrinkWrap: true,
                )
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildSortRadio(true),
                buildSortRadio(false),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(children: [
            ...buildQuests(),
            const Divider(
                height: 16, thickness: 0.5, indent: 16, endIndent: 16),
            const ListTile(
              subtitle: Center(
                child:
                    Text('Drop rate has been adjusted after 6th anniversary'),
              ),
            )
          ]),
        )
      ],
    );
  }

  Widget buildSortRadio(bool value) {
    return RadioWithLabel<bool>(
      value: value,
      groupValue: sortByAP,
      label: Text(
        value ? S.current.ap_efficiency : S.current.drop_rate,
        style: value == sortByAP
            ? null
            : TextStyle(color: Theme.of(context).textTheme.caption?.color),
      ),
      onChanged: (v) => setState(() => sortByAP = v ?? sortByAP),
    );
  }

  List<Widget> buildQuests() {
    final dropRateData = db2.gameData.dropRate.getSheet(use6th);
    int rowIndex = dropRateData.itemIds.indexOf(widget.itemId);
    if (rowIndex < 0) {
      return [ListTile(title: Text(S.current.item_no_free_quests))];
    }
    final dropMatrix = dropRateData.matrix[rowIndex];
    List<List> tmp = [];
    for (var i = 0; i < dropRateData.questIds.length; i++) {
      if (dropMatrix[i] <= 0) continue;
      int questId = dropRateData.questIds[i];
      final apRate = dropRateData.apCosts[i] / dropMatrix[i],
          dropRate = dropMatrix[i];
      final dropRateString = (dropRate * 100).toStringAsFixed(2),
          apRateString = apRate.toStringAsFixed(2);
      final quest = db2.gameData.quests[questId];

      final child = ValueStatefulBuilder<bool>(
          key: quest == null ? null : Key('quest_${quest.id}'),
          initValue: false,
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CustomTile(
                  title: Text(quest?.dispName ?? 'Quest $questId'),
                  subtitle: Text('cost ${dropRateData.apCosts[i]}AP.  ' +
                      (sortByAP
                          ? '${S.current.drop_rate} $dropRateString%.'
                          : '${S.current.ap_efficiency} $apRateString AP.')),
                  trailing:
                      Text(sortByAP ? '$apRateString AP' : '$dropRateString%'),
                  onTap: quest == null
                      ? null
                      : () => state.setState(() {
                            state.value = !state.value;
                          }),
                ),
                if (state.value && quest != null)
                  QuestCard(quest: quest, use6th: use6th),
              ],
            );
          });
      tmp.add([apRate, dropRate, child]);
    }

    tmp.sort((a, b) {
      return ((sortByAP ? a[0] - b[0] : b[1] - a[1]) as double).sign.toInt();
    });
    return tmp.map((e) => e.last as Widget).toList();
  }
}
