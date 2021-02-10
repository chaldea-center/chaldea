import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/drop_calculator/drop_calc_filter_dialog.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';

import 'quest_efficiency_tab.dart';
import 'quest_plan_tab.dart';

class DropCalculatorPage extends StatefulWidget {
  final Map<String, int> objectiveCounts;

  DropCalculatorPage({Key key, this.objectiveCounts}) : super(key: key);

  @override
  _DropCalculatorPageState createState() => _DropCalculatorPageState();
}

class _DropCalculatorPageState extends State<DropCalculatorPage>
    with SingleTickerProviderStateMixin {
  GLPKSolution solution;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).drop_calculator),
        leading: BackButton(),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            tooltip: S.of(context).help,
            onPressed: () {
              SimpleCancelOkDialog(
                title: Text(S.of(context).help),
                content: Text(S.of(context).drop_calc_help_text),
              ).show(context);
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: S.of(context).item),
            Tab(text: S.of(context).plan),
            Tab(text: S.of(context).efficiency)
          ],
          onTap: (_) {
            FocusScope.of(context).unfocus();
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: TabBarView(
          controller: _tabController,
          children: [
            KeepAliveBuilder(
                builder: (context) => DropCalcInputTab(
                    objectiveCounts: widget.objectiveCounts,
                    onSolved: onSolved)),
            KeepAliveBuilder(
                builder: (context) => QuestPlanTab(solution: solution)),
            KeepAliveBuilder(
                builder: (context) => QuestEfficiencyTab(solution: solution))
          ],
        ),
      ),
    );
  }

  void onSolved(GLPKSolution s) {
    if (s == null) {
      EasyLoading.showToast('no solution');
    } else {
      setState(() {
        solution = s;
      });
      // if change tab index immediately, the second tab won't re-render
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (solution.destination > 0 && solution.destination < 3) {
          _tabController.index = solution.destination;
        } else {
          _tabController.index = 1;
        }
      });
    }
  }
}

class DropCalcInputTab extends StatefulWidget {
  final Map<String, int> objectiveCounts;
  final void Function(GLPKSolution) onSolved;

  const DropCalcInputTab({Key key, this.objectiveCounts, this.onSolved})
      : super(key: key);

  @override
  _DropCalcInputTabState createState() => _DropCalcInputTabState();
}

class _DropCalcInputTabState extends State<DropCalcInputTab> {
  GLPKParams params;

  // category - itemKey
  Map<String, List<String>> pickerData = {};
  List<PickerItem<String>> pickerAdapter = [];
  final GLPKSolver solver = GLPKSolver();
  bool running = false;

  @override
  void initState() {
    super.initState();
    // reset params
    db.userData.glpkParams ??= GLPKParams();
    params = db.userData.glpkParams..validate();
    final Map<String, int> objective =
        widget.objectiveCounts ?? params.objectiveCounts;
    params
      ..removeAll()
      ..enableControllers();
    if (objective.isEmpty) {
      // if enter from home page, default to add two items
      addAnItemNotInList();
      addAnItemNotInList();
    } else {
      // if enter from item list page
      print('objMap: $objective');
      objective.forEach((key, value) => params.addOne(key, value));
      params.sortByItem();
    }

    // picker
    db.gameData.items.keys.forEach((name) {
      final category = getItemCategory(name);
      if (category != null) {
        pickerData.putIfAbsent(getItemCategory(name), () => []).add(name);
      }
    });

    Widget makeText(String text) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Center(
          child: AutoSizeText(
            text,
            maxLines: 2,
            maxFontSize: 15,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    pickerData.forEach((category, items) {
      pickerAdapter.add(PickerItem(
        text: makeText(category),
        value: category,
        children: items
            .map((e) =>
                PickerItem(text: makeText(Item.localizedNameOf(e)), value: e))
            .toList(),
      ));
    });

    solver.ensureEngine();
  }

  @override
  void dispose() {
    solver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(S.of(context).item),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 65,
                child: Center(
                  child: Text(planOrEff
                      ? S.of(context).counts
                      : S.of(context).calc_weight),
                ),
              ),
              IconButton(icon: Icon(Icons.delete), onPressed: null)
            ],
          ),
        ),
        if (params.rows.isEmpty)
          ListTile(
              title: Center(child: Text(S.of(context).drop_calc_empty_hint))),
        Expanded(child: _buildInputRows()),
        _buildButtonBar(),
      ],
    );
  }

  Widget _buildInputRows() {
    return ListView.separated(
      itemBuilder: (context, index) {
        final item = params.rows[index];
        return CustomTile(
          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          // titlePadding: EdgeInsets.symmetric(vertical: 0),
          leading: GestureDetector(
            onTap: () {
              SplitRoute.push(
                context: context,
                builder: (context, _) => ItemDetailPage(item),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: db.getIconImage(item, height: 48),
            ),
          ),
          title: GestureDetector(
            onTap: () {
              final String category = getItemCategory(item);
              Picker(
                adapter: PickerDataAdapter<String>(data: pickerAdapter),
                selecteds: [
                  pickerData.keys.toList().indexOf(category),
                  pickerData[category].indexOf(item)
                ],
                height: 250,
                itemExtent: 48,
                changeToFirst: true,
                hideHeader: true,
                textScaleFactor: 0.7,
                cancelText: S.of(context).cancel,
                confirmText: S.of(context).confirm,
                onConfirm: (Picker picker, List<int> value) {
                  print('picker: ${picker.getSelectedValues()}');
                  setState(() {
                    String selected = picker.getSelectedValues().last;
                    if (params.rows.contains(selected)) {
                      EasyLoading.showToast(S
                          .of(context)
                          .item_already_exist_hint(
                              Item.localizedNameOf(selected)));
                    } else {
                      params.rows[index] = selected;
                    }
                  });
                },
              ).showDialog(context);
            },
            child: Text(Item.localizedNameOf(item)),
          ),
          subtitle: planOrEff
              ? Text(S.current
                  .words_separate(S.current.calc_weight, params.weights[index]))
              : Text(S.current
                  .words_separate(S.current.counts, params.counts[index])),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 65,
                child: TextField(
                  controller: planOrEff
                      ? params.countControllers[index]
                      : params.weightControllers[index],
                  keyboardType: TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  textAlign: TextAlign.center,
                  // textInputAction: TextInputAction.next,
                  decoration: InputDecoration(isDense: true),
                  // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (s) {
                    if (planOrEff) {
                      params.counts[index] = int.tryParse(s) ?? 0;
                    } else {
                      params.weights[index] = double.tryParse(s) ?? 1.0;
                    }
                  },
                ),
              ),
              IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                  focusNode: FocusNode(skipTraversal: true),
                  onPressed: () {
                    setState(() {
                      params.remove(item);
                    });
                  })
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => Divider(height: 1, thickness: 0.5),
      itemCount: params.rows.length,
    );
  }

  Widget _buildButtonBar() {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: <Widget>[
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: <Widget>[
                DropdownButton(
                    value: planOrEff,
                    items: [
                      DropdownMenuItem(
                          value: true, child: Text(S.of(context).plan)),
                      DropdownMenuItem(
                          value: false, child: Text(S.of(context).efficiency))
                    ],
                    onChanged: (v) =>
                        setState(() => planOrEff = v ?? planOrEff)),
              ],
            ),
            IconButton(
                icon: Icon(Icons.filter_alt),
                color: Theme.of(context).primaryColor,
                tooltip: S.of(context).filter,
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (context) =>
                          DropCalcFilterDialog(params: params));
                  setState(() {});
                }),
            //TODO: add extra event quests button and dialog page
            IconButton(
              icon: Icon(Icons.sort),
              tooltip: S.of(context).filter_sort,
              color: Theme.of(context).primaryColor,
              onPressed: () {
                setState(() {
                  params.sortByItem();
                });
              },
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    tooltip: 'Add row',
                    onPressed: () {
                      setState(() {
                        addAnItemNotInList();
                      });
                    }),
                ElevatedButton(
                  onPressed: running ? null : solve,
                  child: Text(S.of(context).drop_calc_solve),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  void addAnItemNotInList([int n = 50]) {
    final item = db.gameData.glpk.rowNames
        .firstWhere((e) => !params.rows.contains(e), orElse: () => null);
    params.addOne(item, n);
  }

  String getItemCategory(String itemKey) {
    final item = db.gameData.items[itemKey];
    if (item.category == 1) {
      if (item.rarity <= 3) {
        return [
          null,
          S.current.item_category_copper,
          S.current.item_category_silver,
          S.current.item_category_gold
        ][item.rarity];
      }
    } else if (item.category == 2) {
      return S.current.item_category_gems;
    } else if (item.category == 3) {
      return S.current.item_category_ascension;
    }
    return null;
  }

  bool planOrEff = true;

  void solve() async {
    FocusScope.of(context).unfocus();
    if (params.counts.reduce(max) > 0) {
      setState(() {
        running = true;
      });
      final solution =
          await solver.calculate(data: db.gameData.glpk, params: params);
      running = false;
      solution.destination = planOrEff ? 1 : 2;
      solution.params = params;
      if (widget.onSolved != null) {
        widget.onSolved(solution);
      }
    } else {
      EasyLoading.showToast(S.of(context).input_invalid_hint);
    }
  }
}
