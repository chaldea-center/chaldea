import 'dart:convert';

import 'package:chaldea/components/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class DropCalculatorPage extends StatefulWidget {
  @override
  _DropCalculatorPageState createState() => _DropCalculatorPageState();
}

class _DropCalculatorPageState extends State<DropCalculatorPage> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  GLPKParams params;
  GLPKSolution result;
  bool solverReady; // launch only once
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
    _loadLib();
  }

  @override
  void dispose() {
    flutterWebViewPlugin.close();
    flutterWebViewPlugin.dispose();
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
                        title: Text('Total Num: ${result?.totalNum}'),
                        trailing: Text('Total AP: ${result?.totalEff}'),
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
    return List.generate(result?.variables?.length ?? 0, (i) {
      final variable = result.variables[i];
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
              onPressed: solverReady != true
                  ? null
                  : () {
                      if (params.objRows.length > 0 &&
                          sum(params.objNums) > 0) {
                        calculate();
                      } else {
                        showToast('invalid input');
                      }
                    },
              child: Text('Solve', style: TextStyle(color: Colors.white)),
            ),
          ],
        )
      ],
    );
  }

  Future<Null> _loadLib() async {
    // should only load once
    print('load js libs...');
    await flutterWebViewPlugin.close();
    solverReady = false;
    final t0 = DateTime.now();
    await flutterWebViewPlugin.launch(
      Uri.dataFromString(
          '<html><body><h3>Logs:</h3><div id="logs"></div></body></html>',
          mimeType: 'text/html',
          parameters: {'charset': 'utf-8'}).toString(),
      hidden: true,
    );
    await flutterWebViewPlugin
        .evalJavascript(await rootBundle.loadString('res/lib/glpk.min.js'));
    await flutterWebViewPlugin
        .evalJavascript(await rootBundle.loadString('res/lib/solver.js'));
    await flutterWebViewPlugin.evalJavascript(
        '''add_log(`${DateTime.now().toString()}: Load libs finished.`)''');
    solverReady = true;
    print('=========load libs finish:'
        ' ${DateTime.now().difference(t0).inMilliseconds / 1000} sec.=========');
    setState(() {});
  }

  void calculate() async {
    try {
      if (solverReady != true) {
        await _loadLib();
      }
      print('solveing...\nparams="${json.encode(params)}"');
      final r = await flutterWebViewPlugin.evalJavascript(
          '''solve_glpk( `${json.encode(db.gameData.glpk)}`,`${json.encode(params)}`);''');
      result = GLPKSolution.fromJson(Map.from(json.decode(r)));
      result.sortByValue();
      print('result: ${json.encode(result)}');
      await flutterWebViewPlugin.evalJavascript(
          '''add_log(`${DateTime.now().toString()}: solve result: ${json.encode(result)}`)''');
    } catch (e, s) {
      showToast('calculator error:\n$e');
      result?.clear();
      FlutterError.dumpErrorToConsole(
          FlutterErrorDetails(exception: e, stack: s));
    } finally {
      setState(() {});
    }
  }
}
