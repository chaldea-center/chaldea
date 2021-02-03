//@dart=2.12
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';

class QuestEfficiencyTab extends StatefulWidget {
  final GLPKSolution? solution;

  const QuestEfficiencyTab({Key? key, required this.solution})
      : super(key: key);

  @override
  _QuestEfficiencyTabState createState() => _QuestEfficiencyTabState();
}

class _QuestEfficiencyTabState extends State<QuestEfficiencyTab> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    widget.solution?.weightVars?.forEach((variable) {
      final String questKey = variable.name;
      final Map<String, double> drops = variable.detail as Map<String, double>;
      final Quest? quest = db.gameData.freeQuests[questKey];
      if (filterItems.isNotEmpty &&
          sum<double>(filterItems.map((e) => drops[e])) <= 0) {
        // no filter item contained
        return;
      }
      children.add(Container(
        decoration: BoxDecoration(
            border: Border(bottom: Divider.createBorderSide(context))),
        child: ValueStatefulBuilder<bool>(
            value: false,
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomTile(
                    title: Text(questKey),
                    subtitle: Text(drops.entries.map((e) {
                      String v = e.value.toStringAsFixed(3);
                      while (v.contains('.') && v[v.length - 1] == '0') {
                        v = v.substring(0, v.length - 1);
                      }
                      return '${e.key}*$v';
                    }).join(', ')),
                    trailing: Text(sum(drops.values).toStringAsFixed(3)),
                    onTap: quest == null
                        ? null
                        : () {
                            state.value = !state.value;
                            state.updateState();
                          },
                  ),
                  if (state.value && quest != null) QuestCard(quest: quest),
                ],
              );
            }),
      ));
    });
    return Column(
      children: [
        ListTile(
          title: Text(S.of(context).quest),
          trailing: Text(S.of(context).efficiency),
        ),
        Expanded(child: ListView(children: children)),
        _buildButtonBar(),
      ],
    );
  }

  Set<String> filterItems = {};

  Widget _buildButtonBar() {
    Set<String> itemSet = {};
    double height = Theme.of(context).iconTheme.size ?? 36;
    widget.solution?.weightVars.forEach((variable) {
      variable.detail.forEach((key, value) {
        if (value > 0) {
          itemSet.add(key);
        }
      });
    });
    List<String> items = Item.sortListById(itemSet.toList());
    List<Widget> children = [];
    items.forEach((itemKey) {
      children.add(GestureDetector(
        onTap: () {
          setState(() {
            if (filterItems.contains(itemKey))
              filterItems.remove(itemKey);
            else
              filterItems.add(itemKey);
          });
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              db.getIconImage(itemKey, height: height),
              if (filterItems.contains(itemKey))
                Icon(Icons.circle, size: height * 0.53, color: Colors.white),
              if (filterItems.contains(itemKey))
                Icon(Icons.check_circle,
                    size: height * 0.5, color: Theme.of(context).primaryColor)
            ],
          ),
        ),
      ));
    });
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.filter_alt),
          color: Theme.of(context).primaryColor,
          tooltip: 'Clear Filter',
          onPressed: () {
            setState(() {
              filterItems.clear();
            });
          },
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            height: height,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: children,
            ),
          ),
        )
      ],
    );
  }
}
