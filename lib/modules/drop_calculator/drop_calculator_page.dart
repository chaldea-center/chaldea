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
  GLPKParams params = GLPKParams();
  GLPKSolution result;
  bool solverReady; // launch only once
  Map<String, List<String>> pickerData = {};

  @override
  void initState() {
    super.initState();
    params.addOne(db.gameData.glpk.rowNames[0], 50);
    params.addOne(db.gameData.glpk.rowNames[1], 50);
    db.gameData.items.forEach((name, item) {
      if (item.category == 1) {
        if ([1, 2, 3].contains(item.rarity)) {
          pickerData
              .putIfAbsent(['铜', '银', '金'][item.rarity - 1] + '素材', () => [])
              .add(item.name);
        }
      } else if (item.category == 2) {
        pickerData.putIfAbsent('技能石', () => []).add(item.name);
      } else if (item.category == 3) {
        pickerData.putIfAbsent('棋子', () => []).add(item.name);
      }
    });
  }

  @override
  void dispose() {
    flutterWebViewPlugin.close();
    flutterWebViewPlugin.dispose();
    params.controllers.forEach((e) => e.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plans'),
        leading: BackButton(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
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
                    Picker(
                        adapter:
                            PickerDataAdapter<String>(pickerdata: [pickerData]),
                        height: 250,
                        itemExtent: 36,
                        changeToFirst: true,
                        onConfirm: (Picker picker, List value) {
                          print(picker.getSelectedValues());
                          setState(() {
                            params.objRows[i] = picker.getSelectedValues().last;
                          });
                        }).showModal(context);
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
    return List.generate(
      result?.solutionKeys?.length ?? 0,
      (i) => ListTile(
        title: Text(result.solutionKeys[i]),
        subtitle: Text('item*n, ...'),
        trailing: Text('${result.solutionValues[i]}*?AP'),
      ),
    );
  }

  Widget buildButtonBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: <Widget>[
            Text('最低AP'),
            DropdownButton(
                value: params.minCoeff ?? 0,
                items: List.generate(
                    20,
                    (i) =>
                        DropdownMenuItem(value: i, child: Text(i.toString()))),
                onChanged: (v) => params.minCoeff = v),
            Text('目标'),
            DropdownButton(
                value: params.coeffPrio ?? true,
                items: [
                  DropdownMenuItem(value: true, child: Text('AP')),
                  DropdownMenuItem(value: false, child: Text('次数'))
                ],
                onChanged: (v) => params.coeffPrio = v),
            Text('版本'),
            DropdownButton(
                value: params.useCn ?? false,
                items: [
                  DropdownMenuItem(value: true, child: Text('国服')),
                  DropdownMenuItem(value: false, child: Text('日服'))
                ],
                onChanged: (v) => params.useCn = v),
          ],
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.add_circle),
                onPressed: () {
                  setState(() {
                    params.addOne(db.gameData.glpk.rowNames.first);
                  });
                }),
            RaisedButton(
              onPressed: () {
                if (params.objRows.length > 0 && sum(params.objNums) > 0) {
                  calculate();
                } else {
                  showToast('invalid input');
                }
              },
              child: Text('Solve'),
            ),
          ],
        )
      ],
    );
  }

  Future<Null> _loadLib() async {
    // should only load once
    print('load js libs...');
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
    await flutterWebViewPlugin.evalJavascript('''
                function test(a){
                  document.getElementById('logs').innerHTML+='<p>'+a.toString()+'</p>';
                  return a.toString();
                }''');
    await flutterWebViewPlugin.evalJavascript(
        '''test('${DateTime.now().toString()}: Load libs finished.')''');
    solverReady = true;
    print(
        '================load libs finish: ${DateTime.now().difference(t0).inMilliseconds / 1000} sec.==============');
  }

  void calculate() async {
    try {
      if (solverReady != true) {
        await _loadLib();
      }
      print('solveing...\nparams="${params.toJson()}"');
      final r = await flutterWebViewPlugin.evalJavascript(
          '''solve_glpk( `${json.encode(db.gameData.glpk.toJson())}`,`${json.encode(params.toJson())}`);''');
      result = GLPKSolution.fromJson(Map.from(json.decode(r)));
      result.sortByValue();
      print('result: ${result.toJson()}');
      await flutterWebViewPlugin.evalJavascript(
          '''test('${DateTime.now().toString()}: solve result: ${result.toJson().toString()}')''');
    } catch (e) {
      showToast('calculator error:\n$e');
      result?.clear();
    } finally {
      setState(() {});
    }
  }
}
