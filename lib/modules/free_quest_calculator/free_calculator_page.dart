import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/widgets/markdown_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';

import 'free_calc_filter_dialog.dart';
import 'quest_efficiency_tab.dart';
import 'quest_plan_tab.dart';
import 'quest_query_tab.dart';

class FreeQuestCalculatorPage extends StatefulWidget {
  final Map<String, int>? objectiveCounts;

  FreeQuestCalculatorPage({Key? key, this.objectiveCounts}) : super(key: key);

  @override
  _FreeQuestCalculatorPageState createState() =>
      _FreeQuestCalculatorPageState();
}

class _FreeQuestCalculatorPageState extends State<FreeQuestCalculatorPage>
    with SingleTickerProviderStateMixin {
  GLPKSolution? solution;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).free_quest_calculator),
        leading: BackButton(),
        actions: [
          MarkdownHelpPage.buildHelpBtn(context, 'free_quest_planning.md')
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: !Language.isCN,
          tabs: [
            Tab(text: LocalizedText.of(chs: '需求', jpn: 'アイテム', eng: 'Demands')),
            Tab(text: S.of(context).plan),
            Tab(text: S.of(context).efficiency),
            Tab(text: S.of(context).free_quest)
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
                builder: (context) => QuestEfficiencyTab(solution: solution)),
            KeepAliveBuilder(builder: (context) => FreeQuestQueryTab())
          ],
        ),
      ),
    );
  }

  void onSolved(GLPKSolution? s) {
    if (s == null) {
      EasyLoading.showToast('no solution');
    } else {
      setState(() {
        solution = s;
      });
      // if change tab index immediately, the second tab won't re-render
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        if (solution!.destination > 0 && solution!.destination < 3) {
          _tabController.index = solution!.destination;
        } else {
          _tabController.index = 1;
        }
      });
    }
  }
}

class DropCalcInputTab extends StatefulWidget {
  final Map<String, int>? objectiveCounts;
  final ValueChanged<GLPKSolution>? onSolved;

  const DropCalcInputTab({Key? key, this.objectiveCounts, this.onSolved})
      : super(key: key);

  @override
  _DropCalcInputTabState createState() => _DropCalcInputTabState();
}

class _DropCalcInputTabState extends State<DropCalcInputTab> {
  late ScrollController _scrollController;
  late GLPKParams params;

  // category - itemKey
  Map<String, List<String>> pickerData = {};
  List<PickerItem<String>> pickerAdapter = [];
  final GLPKSolver solver = GLPKSolver();
  bool running = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // ensure every time [params] is a new instance
    params = GLPKParams.from(db.userData.glpkParams);
    params.enableControllers();
    if (widget.objectiveCounts != null) {
      params.removeAll();
      widget.objectiveCounts!
          .forEach((key, count) => params.addOne(key, count, 1.0));
    } else {
      if (params.rows.isEmpty) {
        addAnItemNotInList();
        addAnItemNotInList();
      }
    }
    params.sortByItem();
    // update userdata at last
    db.userData.glpkParams = params;
    solver.ensureEngine();
  }

  void setPickerData() {
    // picker
    db.gameData.items.keys.forEach((name) {
      final category = getItemCategory(name);
      if (category != null) {
        pickerData.putIfAbsent(category, () => []).add(name);
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
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyText1?.color),
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
  }

  @override
  void dispose() {
    solver.dispose();
    params.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (pickerData.isEmpty) setPickerData();
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(S.of(context).item),
          contentPadding: EdgeInsets.only(left: 18, right: 8),
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
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    SimpleCancelOkDialog(
                      title: Text('Clear ALL'),
                      onTapOk: () {
                        setState(() {
                          params.removeAll();
                        });
                      },
                    ).showDialog(context);
                  })
            ],
          ),
        ),
        kDefaultDivider,
        if (params.rows.isEmpty)
          ListTile(
              title: Center(child: Text(S.of(context).drop_calc_empty_hint))),
        Expanded(child: _buildInputRows()),
        kDefaultDivider,
        _buildButtonBar(),
      ],
    );
  }

  Widget _buildInputRows() {
    return ListView.separated(
      controller: _scrollController,
      itemBuilder: (context, index) {
        final item = params.rows[index];
        Widget leading = GestureDetector(
          onTap: () {
            SplitRoute.push(
              context: context,
              builder: (context, _) => ItemDetailPage(itemKey: item),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: db.getIconImage(item, height: 48),
          ),
        );
        Widget title = TextButton(
          style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size(48, 28),
              padding:
                  EdgeInsets.symmetric(horizontal: AppInfo.isMobile ? 8 : 16)),
          child: Text(Item.localizedNameOf(item)),
          onPressed: () {
            final String? category = getItemCategory(item);
            if (category == null) return;
            Picker(
              adapter: PickerDataAdapter<String>(data: pickerAdapter),
              selecteds: [
                pickerData.keys.toList().indexOf(category),
                pickerData[category]!.indexOf(item)
              ],
              height: min(150, MediaQuery.of(context).size.height - 200),
              itemExtent: 48,
              changeToFirst: true,
              hideHeader: true,
              textScaleFactor: 0.7,
              backgroundColor: null,
              cancelText: S.of(context).cancel,
              confirmText: S.of(context).confirm,
              onConfirm: (Picker picker, List<int> value) {
                print('picker: ${picker.getSelectedValues()}');
                setState(() {
                  String selected = picker.getSelectedValues().last;
                  if (params.rows.contains(selected)) {
                    EasyLoading.showToast(S.of(context).item_already_exist_hint(
                        Item.localizedNameOf(selected)));
                  } else {
                    params.rows[index] = selected;
                  }
                });
              },
            ).showDialog(context);
          },
        );
        Widget subtitle = Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            planOrEff
                ? S.current.words_separate(
                    S.current.calc_weight, params.weights[index])
                : S.current
                    .words_separate(S.current.counts, params.counts[index]),
          ),
        );
        return CustomTile(
          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          titlePadding: EdgeInsets.only(right: 6),
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 65,
                child: TextField(
                  controller: planOrEff
                      ? params.countControllers![index]
                      : params.weightControllers![index],
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
      separatorBuilder: (context, index) => kDefaultDivider,
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
                DropdownButton<bool>(
                  value: planOrEff,
                  isDense: true,
                  items: [
                    DropdownMenuItem(
                        value: true, child: Text(S.of(context).plan)),
                    DropdownMenuItem(
                        value: false, child: Text(S.of(context).efficiency))
                  ],
                  onChanged: (v) => setState(() => planOrEff = v ?? planOrEff),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.settings),
              color: params.minCost > 0 ||
                      params.maxColNum > 0 ||
                      params.blacklist.isNotEmpty
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
              tooltip: S.of(context).settings_tab_name,
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) => FreeCalcFilterDialog(params: params));
                setState(() {});
              },
            ),
            //TODO: add extra event quests button and dialog page
            IconButton(
              icon: Icon(Icons.sort),
              tooltip: S.of(context).filter_sort,
              color: Theme.of(context).colorScheme.primary,
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
                      color: Theme.of(context).colorScheme.primary,
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
        .firstWhereOrNull((e) => !params.rows.contains(e));
    if (item != null) params.addOne(item, n);
  }

  String? getItemCategory(String itemKey) {
    final item = db.gameData.items[itemKey];
    if (item == null) return null;
    if (item.category == ItemCategory.item) {
      if (item.rarity <= 3) {
        return <String?>[
          null,
          S.current.item_category_copper,
          S.current.item_category_silver,
          S.current.item_category_gold
        ][item.rarity];
      }
    } else if (item.category == ItemCategory.gem) {
      return S.current.item_category_gems;
    } else if (item.category == ItemCategory.ascension) {
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
        widget.onSolved!(solution);
      }
    } else {
      EasyLoading.showToast(S.of(context).input_invalid_hint);
    }
  }
}
