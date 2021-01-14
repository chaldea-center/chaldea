import 'dart:math';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/shared/quest_card.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';

class DropCalculatorPage extends StatefulWidget {
  final Map<String, int> objectiveMap;

  DropCalculatorPage({Key key, this.objectiveMap}) : super(key: key);

  @override
  _DropCalculatorPageState createState() => _DropCalculatorPageState();
}

class _DropCalculatorPageState extends State<DropCalculatorPage>
    with SingleTickerProviderStateMixin {
  GLPKSolution solution;
  TabController _tabController;
  final _blankNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).drop_calculator),
        leading: BackButton(),
        actions: [],
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: 'Input'), Tab(text: 'Output')],
          onTap: (_) {
            FocusScope.of(context).unfocus();
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(_blankNode);
        },
        behavior: HitTestBehavior.translucent,
        child: TabBarView(
          controller: _tabController,
          children: [
            KeepAliveBuilder(
                builder: (context) => DropCalcInputTab(
                    objectiveMap: widget.objectiveMap, onSolved: onSolved)),
            KeepAliveBuilder(
                builder: (context) => DropCalcOutputTab(solution: solution))
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
        _tabController.index = 1;
      });
    }
  }
}

class DropCalcInputTab extends StatefulWidget {
  final Map<String, int> objectiveMap;

  final void Function(GLPKSolution) onSolved;

  const DropCalcInputTab({Key key, this.objectiveMap, this.onSolved})
      : super(key: key);

  @override
  _DropCalcInputTabState createState() => _DropCalcInputTabState();
}

class _DropCalcInputTabState extends State<DropCalcInputTab> {
  GLPKParams params;
  Map<String, List<String>> pickerData = {};
  final solver = GLPKSolver();

  @override
  void initState() {
    super.initState();
    // init picker data
    db.gameData.items.keys.forEach((name) {
      final category = getItemCategory(name);
      if (category != null) {
        pickerData.putIfAbsent(getItemCategory(name), () => []).add(name);
      }
    });

    // reset params
    params = db.userData.glpkParams
      ..removeAll()
      ..enableControllers();
    if (widget.objectiveMap == null) {
      // if enter from home page, default to add two items
      addAnItemNotInList();
      addAnItemNotInList();
    } else {
      // if enter from item list page
      print('objMap: ${widget.objectiveMap}');
      widget.objectiveMap.forEach((key, value) => params.addOne(key, value));
      params.sortByItem();
    }
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
        if (params.rows.isEmpty)
          ListTile(title: Center(child: Text('No item data, click + to add.'))),
        Expanded(child: _buildInputRows()),
        _buildButtonBar(),
      ],
    );
  }

  Widget _buildInputRows() {
    return ListView.separated(
      itemBuilder: (context, index) {
        final item = params.rows[index];
        return ListTile(
          leading: GestureDetector(
            onTap: () {
              SplitRoute.push(
                context: context,
                builder: (context, _) => ItemDetailPage(item),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Image(image: db.getIconImage(item)),
            ),
          ),
          title: Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: MaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    focusNode: FocusNode(skipTraversal: true),
                    onPressed: () {
                      final String category = getItemCategory(item);
                      Picker(
                        adapter:
                            PickerDataAdapter<String>(pickerdata: [pickerData]),
                        selecteds: [
                          pickerData.keys.toList().indexOf(category),
                          pickerData[category].indexOf(item)
                        ],
                        height: 250,
                        itemExtent: 48,
                        changeToFirst: true,
                        onConfirm: (Picker picker, List value) {
                          print('picker: ${picker.getSelectedValues()}');
                          setState(() {
                            String selected = picker.getSelectedValues().last;
                            if (params.rows.contains(selected)) {
                              EasyLoading.showToast(
                                  '$selected already in list');
                            } else {
                              params.rows[index] = selected;
                            }
                          });
                        },
                      ).showModal(context);
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(item),
                    )),
              ),
              SizedBox(
                width: 65,
                child: TextField(
                  controller: params.controllers[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(isDense: true),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (s) {
                    params.counts[index] = int.tryParse(s) ?? 0;
                  },
                ),
              ),
            ],
          ),
          trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.redAccent),
              focusNode: FocusNode(skipTraversal: true),
              onPressed: () {
                setState(() {
                  params.remove(item);
                });
              }),
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
        Divider(height: 1, thickness: 1),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: <Widget>[
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: <Widget>[
                Text('最低AP'),
                DropdownButton(
                    value: params.minCost,
                    items: List.generate(
                        20,
                        (i) => DropdownMenuItem(
                            value: i, child: Text(i.toString()))),
                    onChanged: (v) => params.minCost = v),
              ],
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: <Widget>[
                Text('优化'),
                DropdownButton(
                    value: params.costMinimize,
                    items: [
                      DropdownMenuItem(value: true, child: Text('AP')),
                      DropdownMenuItem(value: false, child: Text('次数'))
                    ],
                    onChanged: (v) => params.costMinimize = v),
              ],
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: <Widget>[
                Text('版本'),
                DropdownButton(
                    value: params.maxColNum > 0,
                    items: [
                      DropdownMenuItem(value: true, child: Text('国服')),
                      DropdownMenuItem(value: false, child: Text('日服'))
                    ],
                    onChanged: (v) => params.maxColNum =
                        v ? db.gameData.glpk.cnMaxColNum : -1),
              ],
            ),
            //TODO: add extra event quests button and dialog page
            IconButton(
              icon: Icon(Icons.sort),
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
                    onPressed: () {
                      setState(() {
                        addAnItemNotInList();
                      });
                    }),
                RaisedButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: solve,
                  child: SizedBox(
                    width: 75,
                    child: Center(
                      child: Text(
                        'Solve',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.help, color: Colors.blueAccent),
                    onPressed: () {
                      SimpleCancelOkDialog(
                        title: Text('Hints'),
                        content: Text('计算结果仅供参考==\n'
                            '>>>最低AP：\n过滤AP较低的free\n'
                            '筛选时将保证每个素材至少有一个关卡\n'
                            '>>>目标：\n最低总次数或最低总AP为优化目标\n'
                            '>>>版本：\n选择国服则国服未实装的素材将被踢出群\n'
                            ''),
                      ).show(context);
                    })
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
        return ['', '铜', '银', '金'][item.rarity] + '素材';
      }
    } else if (item.category == 2) {
      return '技能石';
    } else if (item.category == 3) {
      return '棋子';
    }
    return null;
  }

  void solve() async {
    FocusScope.of(context).unfocus();
    if (params.counts.reduce(max) > 0) {
      final solution =
          await solver.calculate(data: db.gameData.glpk, params: params);
      if (widget.onSolved != null) {
        widget.onSolved(solution);
      }
    } else {
      EasyLoading.showToast('invalid inputs.');
    }
  }
}

class DropCalcOutputTab extends StatefulWidget {
  final GLPKSolution solution;

  const DropCalcOutputTab({Key key, this.solution}) : super(key: key);

  @override
  _DropCalcOutputTabState createState() => _DropCalcOutputTabState();
}

class _DropCalcOutputTabState extends State<DropCalcOutputTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              border: Border(bottom: Divider.createBorderSide(context))),
          child: ListTile(
            title: Text('Total Num: ${widget.solution?.totalNum}'),
            trailing: Text('Total AP: ${widget.solution?.totalCost}'),
          ),
        ),
        Expanded(
            child: ListView(
          children: widget.solution?.variables?.map((variable) {
                final quest = db.gameData.freeQuests[variable.name];
                return Container(
                  decoration: BoxDecoration(
                      border:
                          Border(bottom: Divider.createBorderSide(context))),
                  child: ValueStatefulBuilder<bool>(
                      value: false,
                      builder: (context, state) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CustomTile(
                              title: Text(variable.name),
                              subtitle: Text(variable.detail.entries
                                  .map((e) => '${e.key}*${e.value}')
                                  .join(', ')),
                              trailing:
                                  Text('${variable.value}*${variable.cost} AP'),
                              onTap: quest == null
                                  ? null
                                  : () {
                                      state.value = !state.value;
                                      state.updateState();
                                    },
                            ),
                            if (state.value && quest != null)
                              QuestCard(quest: quest),
                          ],
                        );
                      }),
                );
              })?.toList() ??
              [],
        ))
      ],
    );
  }
}
