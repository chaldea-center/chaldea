import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../quest/quest_card.dart';

enum _EfficiencySort {
  item,
  bond,
}

class QuestEfficiencyTab extends StatefulWidget {
  final LPSolution? solution;

  const QuestEfficiencyTab({super.key, required this.solution});

  @override
  _QuestEfficiencyTabState createState() => _QuestEfficiencyTabState();
}

class _QuestEfficiencyTabState extends State<QuestEfficiencyTab> {
  late final _scrollController = ScrollController();

  Set<int> allItems = {};
  Set<int> filterItems = {};
  bool matchAll = true;
  _EfficiencySort sortType = _EfficiencySort.item;

  FreeLPParams get params => widget.solution?.params ?? db.curUser.freeLPParams;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  List<LPVariable> getSortedVars() {
    if (widget.solution == null) return [];
    final List<LPVariable> quests = List.of(widget.solution!.weightVars);
    switch (sortType) {
      case _EfficiencySort.item:
        quests.sort((a, b) => Maths.sum(b.detail.values).compareTo(Maths.sum(a.detail.values)));
        break;
      case _EfficiencySort.bond:
        quests.sort((a, b) {
          final aa = getBondEff(a), bb = getBondEff(b);
          if (aa != bb) return bb.compareTo(aa);
          return Maths.sum(b.detail.values).compareTo(Maths.sum(a.detail.values));
        });
        break;
    }
    return quests;
  }

  double getBondEff(LPVariable variable) {
    final data = db.gameData.dropData.domusAurea;
    final index = data.questIds.indexOf(variable.name);
    int? bond = data.bonds.getOrNull(index), ap = data.apCosts.getOrNull(index);
    if (bond != null && ap != null) {
      final bondPercent = params.bondBonusPercent, bondCount = params.bondBonusCount;
      bond = (bond * (1 + bondPercent * 0.05) + bondCount * 50).toInt();
      return bond / ap;
    }
    return double.negativeInfinity;
  }

  @override
  Widget build(BuildContext context) {
    final List<LPVariable> solutionVars = getSortedVars();

    allItems.clear();
    solutionVars.forEach((variable) {
      variable.detail.forEach((key, value) {
        if (value > 0 && key != Items.bondPointId && key != Items.expPointId) {
          allItems.add(key);
        }
      });
    });
    filterItems.removeWhere((element) => !allItems.contains(element));

    List<Widget> children = [];

    final allBonus = widget.solution?.params?.validBonuses ?? {};
    if (allBonus.isNotEmpty) {
      children.add(Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 3,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(S.current.event_bonus),
              const SizedBox(width: 4),
              for (final itemId in allBonus.keys) ...[
                Item.iconBuilder(context: context, item: db.gameData.items[itemId], width: 32),
                Text('+${allBonus[itemId]}%', style: Theme.of(context).textTheme.bodySmall)
              ],
            ],
          ),
        ),
      ));
    }

    for (final variable in solutionVars) {
      final int questId = variable.name;
      final Map<int, double> drops = variable.detail;
      final Quest? quest = db.gameData.getQuestPhase(questId) ?? db.gameData.quests[questId];
      if (filterItems.isEmpty ||
          (matchAll && filterItems.every((e) => variable.detail.containsKey(e))) ||
          (!matchAll && filterItems.any((e) => variable.detail.containsKey(e)))) {
        children.add(Container(
          decoration: BoxDecoration(border: Border(bottom: Divider.createBorderSide(context))),
          child: ValueStatefulBuilder<bool>(
            key: Key('eff_quest_$questId'),
            initValue: false,
            builder: (context, state) {
              double bondEff = getBondEff(variable);
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomTile(
                    title: Text(quest?.lDispName ?? 'Quest $questId'),
                    subtitle: buildRichText(drops.entries),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Maths.sum(drops.values).toStringAsFixed(3)),
                        Text(
                          bondEff == double.negativeInfinity ? '???' : bondEff.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.bodySmall,
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
                  if (state.value && quest != null) QuestCard(quest: quest),
                ],
              );
            },
          ),
        ));
      }
    }

    return Column(
      children: [
        ListTile(
          title: Text(S.current.quest),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.current.item_eff),
              Text(
                S.current.bond_eff,
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          ),
        ),
        kDefaultDivider,
        Expanded(child: ListView(controller: _scrollController, children: children)),
        kDefaultDivider,
        SafeArea(child: _buildButtonBar()),
      ],
    );
  }

  Widget buildRichText(Iterable<MapEntry<int, double>> entries) {
    List<InlineSpan> children = [];
    for (final entry in entries) {
      String v = entry.value.toStringAsFixed(3);
      while (v.contains('.') && v[v.length - 1] == '0') {
        v = v.substring(0, v.length - 1);
      }
      if (entry.key == Items.bondPointId) {
        children.add(TextSpan(text: S.current.bond));
      } else if (entry.key == Items.expPointId) {
        children.add(const TextSpan(text: 'EXP'));
      } else {
        children.add(CenterWidgetSpan(
          child: Opacity(
            opacity: 0.75,
            child: db.getIconImage(db.gameData.items[entry.key]?.borderedIcon, height: 18),
          ),
        ));
      }
      children.add(TextSpan(text: '×$v '));
    }
    return Text.rich(
      TextSpan(children: children),
    );
  }

  Widget _buildButtonBar() {
    double height = 36;
    List<int> items = allItems.toList()..sort2((e) => db.gameData.items[e]?.priority ?? e);
    List<Widget> children = [];
    items.forEach((itemId) {
      children.add(GestureDetector(
        onTap: () {
          setState(() {
            if (filterItems.contains(itemId)) {
              filterItems.remove(itemId);
            } else {
              filterItems.add(itemId);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              db.getIconImage(db.gameData.items[itemId]?.borderedIcon, height: height),
              if (filterItems.contains(itemId)) Icon(Icons.circle, size: height * 0.53, color: Colors.white),
              if (filterItems.contains(itemId))
                Icon(Icons.check_circle, size: height * 0.5, color: Theme.of(context).colorScheme.primary)
            ],
          ),
        ),
      ));
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('${S.current.event_bonus}(${S.current.bond})'),
            ),
            DropdownButton<int>(
              isDense: true,
              value: params.bondBonusPercent,
              items: [
                for (int index = 0; index <= 9; index++)
                  DropdownMenuItem(
                    value: index,
                    child: Text('+${index * 5}%', textScaleFactor: 0.9),
                  ),
              ],
              onChanged: (v) {
                setState(() {
                  if (v != null) params.bondBonusPercent = v;
                });
              },
            ),
            const SizedBox(width: 8),
            DropdownButton<int>(
              isDense: true,
              value: params.bondBonusCount,
              items: [
                for (int index = 0; index <= 2; index++)
                  DropdownMenuItem(
                    value: index,
                    child: Text('+${index * 50}', textScaleFactor: 0.9),
                  ),
              ],
              onChanged: (v) {
                setState(() {
                  if (v != null) params.bondBonusCount = v;
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
                EasyLoading.showToast(matchAll ? 'Contains All' : 'Contains Any');
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
