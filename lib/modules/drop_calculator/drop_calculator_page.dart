import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';

class DropCalculatorPage extends StatefulWidget {
  final GLPKParams params;

  const DropCalculatorPage({Key key, this.params}) : super(key: key);

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
                params: widget.params,
                onSolved: (s) {
                  if (s == null) {
                    showToast('no solution');
                  } else {
                    setState(() {
                      solution = s;
                    });
                    _tabController.index = 1;
                  }
                },
              ),
            ),
            KeepAliveBuilder(builder: (context) => DropCalcOutputTab(solution)),
          ],
        ),
      ),
    );
  }
}

class DropCalcInputTab extends StatefulWidget {
  final GLPKParams params;
  final void Function(GLPKSolution) onSolved;

  const DropCalcInputTab({Key key, this.params, this.onSolved})
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
    db.gameData.items.keys.forEach((name) {
      final category = getItemCategory(name);
      if (category != null) {
        pickerData.putIfAbsent(getItemCategory(name), () => []).add(name);
      }
    });
    params = db.userData.glpkParams..removeAll();
    if (widget.params == null &&
        pickerData.values.isNotEmpty &&
        pickerData.values.first.length >= 2) {
      params.addOne(pickerData.values.first.elementAt(0), 50);
      params.addOne(pickerData.values.first.elementAt(1), 50);
    } else {
      params.objRows = widget.params.objRows;
      params.objNums = widget.params.objNums;
    }
    params.enableControllers();
    solver.initial();
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
        if (params.objRows.isEmpty)
          ListTile(title: Center(child: Text('No item data, click + to add.'))),
        Expanded(child: _buildInputRows()),
        _buildButtonBar(),
      ],
    );
  }

  Widget _buildInputRows() {
    return ListView.separated(
      itemBuilder: (context, index) => ListTile(
        leading: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Image(image: db.getIconImage(params.objRows[index])),
        ),
        title: Row(
          children: <Widget>[
            Expanded(
              child: FlatButton(
                  onPressed: () {
                    final String itemKey = params.objRows[index];
                    final String category = getItemCategory(itemKey);
                    Picker(
                      adapter:
                          PickerDataAdapter<String>(pickerdata: [pickerData]),
                      selecteds: [
                        pickerData.keys.toList().indexOf(category),
                        pickerData[category].indexOf(itemKey)
                      ],
                      height: 250,
                      itemExtent: 48,
                      changeToFirst: true,
                      onConfirm: (Picker picker, List value) {
                        print(picker.getSelectedValues());
                        setState(() {
                          params.objRows[index] =
                              picker.getSelectedValues().last;
                        });
                      },
                    ).showModal(context);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(params.objRows[index]),
                  )),
            ),
            Expanded(
              child: TextField(
                controller: params.controllers[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(isDense: true),
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                onChanged: (s) {
                  params.objNums[index] = int.tryParse(s) ?? 0;
                },
              ),
            ),
          ],
        ),
        trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              setState(() {
                params.removeAt(index);
              });
            }),
      ),
      separatorBuilder: (context, index) => Divider(height: 1, thickness: 0.5),
      itemCount: params.objRows.length,
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
                    value: params.minCoeff,
                    items: List.generate(
                        20,
                        (i) => DropdownMenuItem(
                            value: i, child: Text(i.toString()))),
                    onChanged: (v) => params.minCoeff = v),
              ],
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: <Widget>[
                Text('掉落前'),
                DropdownButton(
                    value: [0, 1, 2, 4, 6, 8].contains(params.maxSortOrder)
                        ? params.maxSortOrder
                        : 0,
                    items: List.generate(6, (i) {
                      int v = [0, 1, 2, 4, 6, 8][i];
                      return DropdownMenuItem(
                          value: v, child: Text(v <= 0 ? 'ALL' : v.toString()));
                    }),
                    onChanged: (v) => params.maxSortOrder = v),
              ],
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: <Widget>[
                Text('目标'),
                DropdownButton(
                    value: params.coeffPrio,
                    items: [
                      DropdownMenuItem(value: true, child: Text('AP')),
                      DropdownMenuItem(value: false, child: Text('次数'))
                    ],
                    onChanged: (v) => params.coeffPrio = v),
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
                        params.addOne(db.gameData.glpk.rowNames?.first, 50);
                      });
                    }),
                StreamBuilder(
                  initialData: false,
                  stream: solver.onStateChanged.stream,
                  builder: (context, snapshot) {
                    bool enabled = snapshot.data == true;
                    return RaisedButton(
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onPressed: enabled ? solve : null,
                      child: SizedBox(
                        width: 75,
                        child: Center(
                          child: Text(
                            enabled ? 'Sovle' : 'Running',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                    icon: Icon(
                      Icons.help,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          child: SimpleCancelOkDialog(
                            title: Text('Hints'),
                            content: Text('计算结果仅供参考==\n'
                                '>>>最低AP：\n过滤AP较低的free\n'
                                '>>>掉落前n：\n仅限于单素材掉落在前n的关卡的合集\n'
                                '以上筛选时将保证每个素材至少有一个关卡\n'
                                '>>>目标：\n最低总次数或最低总AP为优化目标\n'
                                '>>>版本：\n选择国服则国服未实装的素材将被踢出群\n'
                                ''),
                          ));
                    })
              ],
            )
          ],
        ),
      ],
    );
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
    if (sum(params.objNums) > 0) {
      FocusScope.of(context).unfocus();
      final solution =
          await solver.calculate(data: db.gameData.glpk, params: params);
      if (widget.onSolved != null) {
        widget.onSolved(solution);
      }
    } else {
      showToast('invalid inputs.');
    }
  }
}

class DropCalcOutputTab extends StatelessWidget {
  final GLPKSolution solution;

  DropCalcOutputTab(this.solution);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              border: Border(bottom: Divider.createBorderSide(context))),
          child: ListTile(
            title: Text('Total Num: ${solution?.totalNum}'),
            trailing: Text('Total AP: ${solution?.totalEff}'),
          ),
        ),
        Expanded(
            child: ListView(
          children: solution?.variables?.map((variable) {
                final quest = db.gameData.freeQuests[variable.name];
                String title = quest?.placeCn ?? variable.name;
                if (['后山', '群岛'].contains(title)) {
                  // 下总国后山&四章群岛 two quests
                  title = '$title-${quest.nameCn}';
                }
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
                              title: Text(title),
                              subtitle: Text(variable.detail.entries
                                  .map((e) => '${e.key}*${e.value}')
                                  .join(', ')),
                              trailing: Text(
                                  '${variable.value}*${variable.coeff} AP'),
                              onTap: quest == null
                                  ? null
                                  : () {
                                      state.value = !state.value;
                                      state.updateState();
                                    },
                            ),
                            if (state.value &&
                                (quest?.battles?.length ?? 0) > 0)
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
