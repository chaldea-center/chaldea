import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';

enum _EfficiencySort {
  item,
  bond,
}

class QuestEfficiencyTab extends StatefulWidget {
  final GLPKSolution? solution;

  const QuestEfficiencyTab({Key? key, required this.solution})
      : super(key: key);

  @override
  _QuestEfficiencyTabState createState() => _QuestEfficiencyTabState();
}

class _QuestEfficiencyTabState extends State<QuestEfficiencyTab> {
  late ScrollController _scrollController;

  Set<String> allItems = {};
  Set<String> filterItems = {};
  bool matchAll = true;
  _EfficiencySort sortType = _EfficiencySort.item;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  List<GLPKVariable> getSortedVars() {
    if (widget.solution == null) return [];
    final List<GLPKVariable> quests = List.of(widget.solution!.weightVars);
    switch (sortType) {
      case _EfficiencySort.item:
        quests.sort((a, b) => sum(b.detail.values as Iterable<double>)
            .compareTo(sum(a.detail.values as Iterable<double>)));
        break;
      case _EfficiencySort.bond:
        quests.sort((a, b) {
          return getBondEff(b).compareTo(getBondEff(a));
        });
        break;
    }
    return quests;
  }

  double getBondEff(GLPKVariable variable) {
    final quest = db.gameData.getFreeQuest(variable.name);
    if (quest != null) {
      int? ap = quest.battles.getOrNull(0)?.ap;
      if (ap != null) {
        return quest.bondPoint / ap;
      }
    }
    return double.negativeInfinity;
  }

  @override
  Widget build(BuildContext context) {
    final List<GLPKVariable> solutionVars = getSortedVars();

    allItems.clear();
    solutionVars.forEach((variable) {
      variable.detail.forEach((key, value) {
        if (value > 0) {
          allItems.add(key);
        }
      });
    });
    filterItems.removeWhere((element) => !allItems.contains(element));

    List<Widget> children = [];
    solutionVars.forEach((variable) {
      final String questKey = variable.name;
      final Map<String, double> drops = variable.detail as Map<String, double>;
      final Quest? quest = db.gameData.getFreeQuest(questKey);
      if (filterItems.isEmpty ||
          (matchAll &&
              filterItems.every((e) => variable.detail.containsKey(e))) ||
          (!matchAll &&
              filterItems.any((e) => variable.detail.containsKey(e)))) {
        children.add(Container(
          decoration: BoxDecoration(
              border: Border(bottom: Divider.createBorderSide(context))),
          child: ValueStatefulBuilder<bool>(
            initValue: false,
            builder: (context, state) {
              double bondEff = getBondEff(variable);
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomTile(
                    title: Text(quest?.localizedKey ??
                        Quest.getDailyQuestName(questKey)),
                    subtitle: buildRichText(drops.entries),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(sum(drops.values).toStringAsFixed(3)),
                        Text(
                          bondEff == double.negativeInfinity
                              ? '???'
                              : bondEff.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    ),
                    onTap: quest == null
                        ? null
                        : () {
                            state.value = !state.value;
                            state.updateState();
                          },
                  ),
                  if (state.value && quest != null)
                    QuestCard(
                      quest: quest,
                      use6th: widget.solution?.params?.use6th,
                    ),
                ],
              );
            },
          ),
        ));
      }
    });
    children.add(ListTile(
      subtitle: Center(
        child: Text(Localized.freeDropRateChangedHint.localized),
      ),
    ));
    return Column(
      children: [
        ListTile(
          title: Text(S.of(context).quest),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.current.item_eff),
              Text(
                S.current.bond_eff,
                style: Theme.of(context).textTheme.caption,
              )
            ],
          ),
        ),
        kDefaultDivider,
        Expanded(
            child: ListView(controller: _scrollController, children: children)),
        kDefaultDivider,
        _buildButtonBar(),
      ],
    );
  }

  Widget buildRichText(Iterable<MapEntry<String, double>> entries) {
    List<InlineSpan> children = [];
    for (final entry in entries) {
      String v = entry.value.toStringAsFixed(3);
      while (v.contains('.') && v[v.length - 1] == '0') {
        v = v.substring(0, v.length - 1);
      }
      children.add(WidgetSpan(
        child: Opacity(
          opacity: 0.75,
          child: db.getIconImage(entry.key, height: 18),
        ),
      ));
      children.add(TextSpan(text: '*$v '));
    }
    final textTheme = Theme.of(context).textTheme;
    return RichText(
      text: TextSpan(
        children: children,
        style: textTheme.bodyText2?.copyWith(color: textTheme.caption?.color),
      ),
    );
  }

  Widget _buildButtonBar() {
    double height = Theme.of(context).iconTheme.size ?? 48;
    List<String> items = Item.sortListById(allItems.toList());
    List<Widget> children = [];
    items.forEach((itemKey) {
      children.add(GestureDetector(
        onTap: () {
          setState(() {
            if (filterItems.contains(itemKey)) {
              filterItems.remove(itemKey);
            } else {
              filterItems.add(itemKey);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              db.getIconImage(itemKey, height: height),
              if (filterItems.contains(itemKey))
                Icon(Icons.circle, size: height * 0.53, color: Colors.white),
              if (filterItems.contains(itemKey))
                Icon(Icons.check_circle,
                    size: height * 0.5,
                    color: Theme.of(context).colorScheme.primary)
            ],
          ),
        ),
      ));
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(S.current.filter_sort),
            ),
            RadioWithLabel<_EfficiencySort>(
              value: _EfficiencySort.item,
              groupValue: sortType,
              label: Text(S.current.item_eff),
              onChanged: (v) {
                setState(() {
                  sortType = v ?? sortType;
                });
              },
            ),
            RadioWithLabel<_EfficiencySort>(
              value: _EfficiencySort.bond,
              groupValue: sortType,
              label: Text(S.current.bond_eff),
              onChanged: (v) {
                setState(() {
                  sortType = v ?? sortType;
                });
              },
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(matchAll ? Icons.add_box : Icons.add_box_outlined),
              color: Theme.of(context).buttonTheme.colorScheme?.secondary,
              tooltip: matchAll ? 'Contains All' : 'Contains Any',
              onPressed: () {
                setState(() {
                  matchAll = !matchAll;
                });
              },
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                height: height,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: children,
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
