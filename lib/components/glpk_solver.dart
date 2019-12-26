import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'datatypes/datatypes.dart';
import 'utils.dart' show showToast;

class GLPKSolver {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  StreamSubscription<WebViewStateChanged> onStateChange;
  bool solverReady;
  bool _solving;

  GLPKSolver() {
    onStateChange =
        flutterWebViewPlugin.onStateChanged.listen((state) async {});
  }

  /// must call [dispose]!!!
  void dispose() {
    onStateChange.cancel();
    flutterWebViewPlugin.close();
    flutterWebViewPlugin.dispose();
  }

  Future<Null> initial({VoidCallback callback}) async {
    // only load once
    // use callback to setState, not Future.
    print('=========loading js libs=========');
    try {
      if (solverReady == true) {
        print('closing...');
        onStateChange?.cancel();
        await flutterWebViewPlugin.close();
      }
      solverReady = false;
      print('launching...');
      onStateChange = flutterWebViewPlugin.onStateChanged.listen((state) async {
        print('state changed: ${state.type}');
        if (state.type == WebViewState.finishLoad && solverReady != true) {
          print('eval glpk...');
          await flutterWebViewPlugin.evalJavascript(
              await rootBundle.loadString('res/lib/glpk.min.js'));
          print('eval solver func...');
          await flutterWebViewPlugin
              .evalJavascript(await rootBundle.loadString('res/lib/solver.js'));
          print('eval log...');
          await flutterWebViewPlugin.evalJavascript(
              '''add_log(`${DateTime.now().toString()}: Load libs finished.`)''');
          await flutterWebViewPlugin.evalJavascript(
              '''add_log(`${DateTime.now().toString()}: Load libs finished.`)''');
          solverReady = true;
          print('=========js libs loaded.=========');
          if (callback != null) {
            callback();
          }
        }
      });
      await flutterWebViewPlugin.launch(
        Uri.dataFromString(
            '''<html><body><h3>Logs:</h3><div id="logs"></div></body></html>''',
            mimeType: 'text/html',
            parameters: {'charset': 'utf-8'}).toString(),
        hidden: true,
      );
    } catch (e, s) {
      print('initial js error:\n$e\n-----statck----\n$s');
      FlutterError.dumpErrorToConsole(
          FlutterErrorDetails(exception: e, stack: s));
      showToast('ERROR: fail to initial solver.\n$e');
    }
  }

  Future<GLPKSolution> calculate({GLPKData data, GLPKParams params}) async {
    assert(data != null && params != null);
    _solving = true;
    GLPKSolution solution;
    Timer(Duration(seconds: 30), () {
      //TODO: how to force stop?
      if (_solving == true) {
        print('solver didn\'t finish in 30s, stop it.');
        flutterWebViewPlugin.close();
        showToast('solver didn\'t finish in 30s, stop it.');
      } else {
        print('solver already finished in 30s?');
      }
    });
    try {
      if (solverReady != true) {
        await initial();
      }
      print('solveing...\nparams="${json.encode(params)}"');
      final data2 = preProcess(data: data, params: params);
      String resultString = await flutterWebViewPlugin.evalJavascript(
          '''solve_glpk( `${json.encode(data2)}`,`${json.encode(params)}`);''');
      if (resultString?.isNotEmpty == false) {
        throw 'evalJavascript return null!';
      }
      solution = GLPKSolution.fromJson(Map.from(json.decode(resultString)));
      solution.sortByValue();
      print('result: ${json.encode(solution)}');
      await flutterWebViewPlugin.evalJavascript(
          '''add_log(`${DateTime.now().toString()}: solve result: ${json.encode(solution)}`)''');
    } catch (e, s) {
      showToast('ERROR: failt to execute GLPK solver:\n$e');
      FlutterError.dumpErrorToConsole(
          FlutterErrorDetails(exception: e, stack: s));
    }
    _solving = false;
    return solution;
  }

  GLPKData preProcess({GLPKData data, GLPKParams params}) {
    print('pre processing...');
    if (params.maxSortOrder <= 0 || params.objRows.length <= 0) {
      return null;
    }
    List<String> _columns;
    // server, maxColNum
    if (params.maxColNum > 0) {
      _columns = data.colNames.sublist(0, params.maxColNum);
    } else {
      _columns = List.from(data.colNames);
    }

    // minCoeff & maxSortOrder
    Set<String> removeCols = {};
    Set<String> retainCols = {};
    for (int j = 0; j < _columns.length; j++) {
      if (data.coeff[j] < params.minCoeff) {
        removeCols.add(data.colNames[j]);
      }
    }
    Map<String, int> colIndexMap = {};
    for (var i = 0; i < data.colNames.length; i++) {
      colIndexMap[data.colNames[i]] = i;
    }
    int getSortValue(int rowIndex, String key) {
      num value = data.matrix[rowIndex][colIndexMap[key]];
      return value > 0 ? (value * 10).toInt() : 1000000;
    }

    for (int i = 0; i < params.objRows.length; i++) {
      if (params.objNums[i] > 0) {
        int rowIndex = data.rowNames.indexOf(params.objRows[i]);
        _columns.sort(
            (a, b) => getSortValue(rowIndex, a) - getSortValue(rowIndex, b));
        Set<String> cols =
            Set<String>.from(_columns.sublist(0, params.maxSortOrder))
                .difference(removeCols);
        if (cols.isEmpty) {
          // insure at least one quest for every item
          cols.add(_columns.first);
        }
        retainCols.addAll(cols);
      }
    }
    // create new data instance
    List<String> retainRowList = List.from(params.objRows),
        retainColList = retainCols.toList();
    return GLPKData(
      rowNames: retainRowList,
      colNames: retainColList,
      coeff: retainColList.map((col) => data.coeff[colIndexMap[col]]).toList(),
      matrix: retainRowList.map((row) {
        int rowIndex = data.rowNames.indexOf(row);
        return retainColList
            .map((col) => data.matrix[rowIndex][colIndexMap[col]])
            .toList();
      }).toList(),
      cnMaxColNum: retainColList.length,
    );
  }
}
