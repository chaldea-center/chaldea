import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';
import 'package:chaldea/modules/shared/quest_card.dart';

class ItemObtainFreeTab extends StatefulWidget {
  final String itemKey;

  const ItemObtainFreeTab({Key? key, required this.itemKey}) : super(key: key);

  @override
  _ItemObtainFreeTabState createState() => _ItemObtainFreeTabState();
}

class _ItemObtainFreeTabState extends State<ItemObtainFreeTab> {
  bool get sortByAP => db.appSetting.itemQuestsSortByAp;

  set sortByAP(bool v) => db.appSetting.itemQuestsSortByAp = v;
  bool use6th = db.curUser.use6thDropRate;

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
            ListTile(
              subtitle: Center(
                child: Text(Localized.freeDropRateChangedHint.localized),
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
    final dropRateData = db.gameData.planningData.getDropRate(use6th);
    int rowIndex = dropRateData.rowNames.indexOf(widget.itemKey);
    if (rowIndex < 0) {
      return [ListTile(title: Text(S.of(context).item_no_free_quests))];
    }
    final dropMatrix = dropRateData.matrix[rowIndex];
    List<List> tmp = [];
    for (var i = 0; i < dropRateData.colNames.length; i++) {
      if (dropMatrix[i] <= 0) continue;
      String questName = dropRateData.colNames[i];
      final apRate = dropRateData.costs[i] / dropMatrix[i],
          dropRate = dropMatrix[i];
      final dropRateString = (dropRate * 100).toStringAsFixed(2),
          apRateString = apRate.toStringAsFixed(2);
      final quest = db.gameData.getFreeQuest(questName);

      final child = ValueStatefulBuilder<bool>(
          initValue: false,
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CustomTile(
                  title: Text(quest?.localizedKey ??
                      Quest.getDailyQuestName(questName)),
                  subtitle: Text('cost ${dropRateData.costs[i]}AP.  ' +
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
                  QuestCard(quest: quest, use6th: use6th)
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
