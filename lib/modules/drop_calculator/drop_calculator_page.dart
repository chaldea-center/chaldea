import 'package:chaldea/components/components.dart';
import 'package:flutter/cupertino.dart';
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
          FocusScope.of(context).requestFocus(kBlankNode);
        },
        behavior: HitTestBehavior.translucent,
        child: TabBarView(
          controller: _tabController,
          children: [
            DropCalcInputTab(
              params: widget.params,
              onSolved: (s) {
                setState(() {
                  solution = s;
                });
                _tabController.index = 1;
              },
            ),
            buildOutputTab()
          ],
        ),
      ),
    );
  }

  Widget buildOutputTab() {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text('Total Num: ${solution?.totalNum}'),
          trailing: Text('Total AP: ${solution?.totalEff}'),
        ),
        Divider(height: 1, thickness: 1),
        Expanded(
          child: ListView.separated(
              itemBuilder: (context, index) {
                final variable = solution.variables[index];
                return ListTile(
                  title: Text(variable.name),
                  subtitle: Text(variable.detail.entries
                      .map((e) => '${e.key}*${e.value}')
                      .join(', ')),
                  trailing: Text('${variable.value}*${variable.coeff} AP'),
                );
              },
              separatorBuilder: (context, index) =>
                  Divider(height: 1, thickness: 1),
              itemCount: solution?.variables?.length ?? 0),
        )
      ],
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

class _DropCalcInputTabState extends State<DropCalcInputTab>
    with AutomaticKeepAliveClientMixin {
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
    if (widget.params == null) {
      params.addOne(pickerData.values?.first?.elementAt(0), 50);
      params.addOne(pickerData.values?.first?.elementAt(1), 50);
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
    super.build(context);
    return Column(
      children: <Widget>[
        if (params.objRows.isEmpty)
          ListTile(title: Center(child: Text('No item data, click + to add.'))),
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) => ListTile(
              title: Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                        onPressed: () {
                          final String itemKey = params.objRows[index];
                          final String category = getItemCategory(itemKey);
                          Picker(
                            adapter: PickerDataAdapter<String>(
                                pickerdata: [pickerData]),
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
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
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
            separatorBuilder: (context, index) =>
                Divider(height: 1, thickness: 0.5),
            itemCount: params.objRows.length,
          ),
        ),
        _buildButtonBar(),
      ],
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
                    value: params.maxSortOrder,
                    items: List.generate(5, (i) {
                      int v = i * 2 + 2;
                      return DropdownMenuItem(
                          value: v, child: Text(v.toString()));
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
                        child: Text(
                          enabled ? ' Solve ' : 'Running',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
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

  void solve() {
    if (sum(params.objNums) > 0) {
      FocusScope.of(context).unfocus();
      showDialog(
        context: context,
        child: SimpleCancelOkDialog(
          title: Text('Confirm'),
          content: Text(
              'If there are too many item rows, it may run out of memory and crash!!!'),
          onTapOk: () async {
            final solution =
                await solver.calculate(data: db.gameData.glpk, params: params);
            if (widget.onSolved != null) {
              widget.onSolved(solution);
            }
          },
        ),
      );
    } else {
      showToast('invalid inputs.');
    }
  }

  @override
  bool get wantKeepAlive => true;
}
