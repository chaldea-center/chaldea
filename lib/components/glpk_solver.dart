import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'datatypes/datatypes.dart';
import 'utils.dart' show showToast;

class GLPKSolver {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  StreamSubscription<WebViewStateChanged> _onWebViewStateChanged;
  StreamController<bool> onStateChanged = StreamController.broadcast();
  bool solverReady = false;

  GLPKSolver();

  void stateChanged(bool state) {
    print('state=$state');
    solverReady = state;
    onStateChanged.sink.add(solverReady);
  }

  /// must call [dispose]!!!
  void dispose() {
    onStateChanged.close();
    _onWebViewStateChanged.cancel();
    flutterWebViewPlugin.close();
    flutterWebViewPlugin.dispose();
  }

  Future<Null> initial({VoidCallback callback}) async {
    // only load once
    // use callback to setState, not Future.
    print('=========loading js libs=========');
    if (solverReady == true) {
      print('closing...');
      _onWebViewStateChanged?.cancel();
      await flutterWebViewPlugin.close();
    }
    stateChanged(false);
    try {
      print('launching...');
      _onWebViewStateChanged =
          flutterWebViewPlugin.onStateChanged.listen((state) async {
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
          stateChanged(true);
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
    // if use integer GLPK (simplex then intopt),
    // it may run out of time and memory, then crash.
    // so only use simplex here
    assert(data != null && params != null);
    print('=========solving========\nparams="${json.encode(params)}"');
    stateChanged(false);
    GLPKSolution solution;
    try {
      final params2 = params.copyWith();
      final filtratedData = preProcess(data: data, params: params2);
      if (params2.objRows.length == 0) {
        print('after pre processing, params has no valid rows.\n'
            'params=${json.encode(params2)}');
      } else {
        print('modified params: ${json.encode(params2)}');
        String resultString = await flutterWebViewPlugin.evalJavascript(
            '''solve_glpk( `${json.encode(filtratedData)}`,`${json.encode(params2)}`);''');
        if (resultString?.isNotEmpty != true) {
          throw 'evalJavascript return null!';
        }
        solution = GLPKSolution.fromJson(Map.from(json.decode(resultString)));
        solution.sortByValue();
        print('result: ${json.encode(solution)}');
        await flutterWebViewPlugin.evalJavascript(
            '''add_log(`${DateTime.now().toString()}: solve result: ${json.encode(solution)}`)''');
      }
    } catch (e, s) {
      showToast('ERROR: failt to execute GLPK solver:\n$e');
      FlutterError.dumpErrorToConsole(
          FlutterErrorDetails(exception: e, stack: s));
    }
    stateChanged(true);
    print('=========solving finished=========');
    return solution;
  }

  /// modify [params] and return [newData] as a new copy of filtrated [data]
  GLPKData preProcess({GLPKData data, GLPKParams params}) {
    print('pre processing...');
    List<String> _columns;

    // server, maxColNum
    if (params.maxColNum > 0) {
      _columns = data.colNames.sublist(0, params.maxColNum);
    } else {
      _columns = List.from(data.colNames);
    }

    // store filtrate results
    Set<String> removeCols = {};
    Set<String> retainCols = {};
    Set<String> removeRows = {}; // no quest's drop contains the item.

    Map<String, int> colIndexMap = {};
    for (var i = 0; i < data.colNames.length; i++) {
      colIndexMap[data.colNames[i]] = i;
    }

    // minCoeff
    for (int j = 0; j < _columns.length; j++) {
      if (data.coeff[j] < params.minCoeff) {
        removeCols.add(data.colNames[j]);
      }
    }

    // maxSortOrder
    int getSortValue(int rowIndex, String key) {
      num value = data.matrix[rowIndex][colIndexMap[key]];
      return value > 0 ? (value * 10).toInt() : 1000000;
    }

    for (int i = 0; i < params.objRows.length; i++) {
      if (params.objNums[i] > 0) {
        int rowIndex = data.rowNames.indexOf(params.objRows[i]);
        final filtratedCols = _columns
            .where((col) => data.matrix[rowIndex][colIndexMap[col]] > 0)
            .toList()
              ..sort((a, b) =>
                  getSortValue(rowIndex, a) - getSortValue(rowIndex, b));
        Set<String> cols = Set<String>.from(params.maxSortOrder > 0
                ? filtratedCols.sublist(
                    0, min(filtratedCols.length, params.maxSortOrder))
                : filtratedCols)
            .difference(removeCols);
        if (cols.isEmpty) {
          if (filtratedCols.isEmpty) {
            // no any column(quest) contain the row key(item drop)
            removeRows.add(params.objRows[i]);
          } else {
            // ensure at least one quest for every item
            cols.add(filtratedCols.first);
          }
        }
        retainCols.addAll(cols);
      }
    }
    // create new data instance
    for (var key in removeRows) {
      params.remove(key);
    }
    if (params.objRows.length == 0) {
      // no rows (glpk will raise error), need to check in caller
      print('no valid objRows');
      return data;
    }
    List<String> retainRowList = List.from(params.objRows),
        retainColList = retainCols.toList();
    final newData = GLPKData(
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
    print('processed data: ${newData.rowNames.length} rows,'
        ' ${newData.colNames.length} columns');
    return newData;
  }
}
