import 'package:chaldea/components/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';

class DropCalculatorPage extends StatefulWidget {
  @override
  _DropCalculatorPageState createState() => _DropCalculatorPageState();
}

class _DropCalculatorPageState extends State<DropCalculatorPage> {
  final solver = GLPKSolver();
  GLPKParams params;
  GLPKSolution solution;
  Map<String, List<String>> pickerData = {};

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

  @override
  void initState() {
    super.initState();
    db.gameData.items.keys.forEach((name) {
      final category = getItemCategory(name);
      if (category != null) {
        pickerData.putIfAbsent(getItemCategory(name), () => []).add(name);
      }
    });
    params = db.userData.glpkParams;
    if (params.objNums.isEmpty) {
      params.addOne(pickerData.values.first[0], 50);
      params.addOne(pickerData.values.first[1], 50);
    }
    params.enableControllers();
    solver.initial().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    solver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).drop_calculator),
        leading: BackButton(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(kBlankNode);
        },
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  TileGroup(header: 'Inputs', children: buildItemRows()),
                  TileGroup(
                    header: 'Solution',
                    children: <Widget>[
                      ListTile(
                        title: Text('Total Num: ${solution?.totalNum}'),
                        trailing: Text('Total AP: ${solution?.totalEff}'),
                      ),
                      ...buildPlaceRows()
                    ],
                  )
                ],
              ),
            ),
            buildButtonBar(),
          ],
        ),
      ),
    );
  }

  List<Widget> buildItemRows() {
    return List.generate(
      params.objRows.length,
      (i) => ListTile(
        title: Row(
          children: <Widget>[
            Expanded(
              child: FlatButton(
                  onPressed: () {
                    final String itemKey = params.objRows[i];
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
                          params.objRows[i] = picker.getSelectedValues().last;
                        });
                      },
                    ).showModal(context);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(params.objRows[i]),
                  )),
            ),
            Expanded(
                child: TextField(
              controller: params.controllers[i],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              onChanged: (s) {
                params.objNums[i] = int.tryParse(s) ?? 0;
              },
            )),
          ],
        ),
        trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              setState(() {
                if (params.objNums.length > 1) {
                  params.removeAt(i);
                }
              });
            }),
      ),
    );
  }

  List<Widget> buildPlaceRows() {
    return List.generate(solution?.variables?.length ?? 0, (i) {
      final variable = solution.variables[i];
      return ListTile(
        title: Text(variable.name),
        subtitle: Text(variable.detail.entries
            .map((e) => '${e.key}*${e.value}')
            .join(', ')),
        trailing: Text('${variable.value}*${variable.coeff} AP'),
      );
    });
  }

  Widget buildButtonBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Divider(height: 1, thickness: 1),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: <Widget>[
            Text('最低AP'),
            DropdownButton(
                value: params.minCoeff,
                items: List.generate(
                    20,
                    (i) =>
                        DropdownMenuItem(value: i, child: Text(i.toString()))),
                onChanged: (v) => params.minCoeff = v),
            Text('目标'),
            DropdownButton(
                value: params.coeffPrio,
                items: [
                  DropdownMenuItem(value: true, child: Text('AP')),
                  DropdownMenuItem(value: false, child: Text('次数'))
                ],
                onChanged: (v) => params.coeffPrio = v),
            Text('版本'),
            DropdownButton(
                value: params.maxColNum > 0,
                items: [
                  DropdownMenuItem(value: true, child: Text('国服')),
                  DropdownMenuItem(value: false, child: Text('日服'))
                ],
                onChanged: (v) =>
                    params.maxColNum = v ? db.gameData.glpk.cnMaxColNum : -1),
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
                    params.addOne(db.gameData.glpk.rowNames.first, 50);
                  });
                }),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: solver.solverReady != true
                  ? null
                  : () async {
                      if (sum(params.objNums) > 0) {
                        solution = await solver.calculate(
                            data: db.gameData.glpk, params: params);
                        setState(() {});
                      } else {
                        showToast('invalid inputs.');
                      }
                    },
              child: Text('Solve', style: TextStyle(color: Colors.white)),
            ),
          ],
        )
      ],
    );
  }
}
