import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:chaldea/components/components.dart';
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
        if (state.type == WebViewState.finishLoad && solverReady != true) {
          await flutterWebViewPlugin.evalJavascript(
              await rootBundle.loadString('res/js/glpk.min.js'));
          await flutterWebViewPlugin
              .evalJavascript(await rootBundle.loadString('res/js/solver.js'));
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
      logger.e('initiate js error', e, s);
      showToast('initiate js error\n$e');
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
      final params2 = GLPKParams.from(params);
      final data2 = GLPKData.from(data);
      preProcess(data: data2, params: params2);
      if (params2.rows.length == 0) {
        logger.d('after pre processing, params has no valid rows.\n'
            'params=${json.encode(params2)}');
        showToast('Invalid inputs');
      } else {
//        print('modified params: ${json.encode(params2)}');
        String resultString = await flutterWebViewPlugin.evalJavascript(
            '''solve_glpk( `${json.encode(data2)}`,`${json.encode(params2)}`);''');
        // TODO: why returned JSON stringify format uncertainly
        resultString =
            (resultString ?? '').replaceAll(RegExp(r'(^"+)|("+$)'), '');
        resultString = resultString.replaceAll('\\"', '"');
        logger.v('result: $resultString');
        final result = json.decode(resultString);
        if (result?.isNotEmpty != true) {
          throw 'evalJavascript return null!';
        }
        solution = GLPKSolution.fromJson(Map.from(result));
        solution.sortByValue();
        await flutterWebViewPlugin.evalJavascript(
            '''add_log(`${DateTime.now().toString()}: solve result: ${json.encode(solution)}`)''');
      }
    } catch (e, s) {
      logger.e('Execute GLPK solver failed', e, s);
      showToast('Execute GLPK solver failed:\n$e');
      rethrow;
    } finally {
      stateChanged(true);
    }
    print('=========solving finished=========');
    return solution;
  }

  /// [data] and [params] must be copied instances. Modify them **in-place**
  GLPKData preProcess({GLPKData data, GLPKParams params}) {
    print('pre processing GLPK data and params...');

    // inside pre processing, use [params.objective] not [items] and [counts]
    final objective = params.generateObjective();

    // traverse originData rather new data
    // remove unused rows
    objective.removeWhere(
        (key, value) => !data.rowNames.contains(key) || value <= 0);
    List.from(data.rowNames).forEach((row) {
      if (!objective.containsKey(row)) data.removeRow(row);
    });

    // remove unused quests
    // free quests' index for different server
    List<String> cols = data.colNames
        .sublist(0, params.maxColNum > 0 ? params.maxColNum : data.jpMaxColNum);
    params.extraCols.forEach((col) {
      if (data.colNames.contains(col)) cols.add(col);
    });
    List.from(data.colNames).forEach((col) {
      if (!cols.contains(col)) data.removeCol(col);
    });

    // now filtrate data's rows/cols
    Set<String> removeCols = {}; // not fit minCost
    Set<String> retainCols = {}; // at least one quest for every item
    Set<String> removeRows = {}; // no quest's drop contains the item.

    for (int i = 0; i < data.colNames.length; i++) {
      if (data.costs[i] < params.minCost) removeCols.add(data.colNames[i]);
    }

    for (String rowName in objective.keys) {
      int row = data.rowNames.indexOf(rowName);
      int minApRateCol = -1;
      double minAPRateVal = double.infinity;
      for (int j = 0; j < data.colNames.length; j++) {
        double v = data.matrix[row][j];
        if (!removeCols.contains(data.colNames[j]) &&
            v > 0 &&
            v < minAPRateVal) {
          minApRateCol = j;
          minAPRateVal = v;
        }
      }
      if (minApRateCol < 0) {
        // no column(cost>minCost) contains rowName
        int retainCol = data.matrix[row].indexOf(data.matrix[row].reduce(max));
        if (retainCol < 0)
          removeRows.add(rowName);
        else
          retainCols.add(data.colNames[retainCol]);
      } else {
        // retain column with max drop rate/min ap rate
        retainCols.add(data.colNames[minApRateCol]);
      }
    }

    // remove rows/cols above
    objective.removeWhere((key, value) => removeRows.contains(key));
    removeRows.forEach((element) => data.removeRow(element));
    removeCols.forEach((element) {
      if (!retainCols.contains(element)) data.removeCol(element);
    });

    params.rows = objective.keys.toList();
    params.counts = objective.values.toList();

    // no rows (glpk will raise error), need to check in caller
    if (objective.length == 0) logger.d('no valid objRows');

    logger.v('processed data: ${data.rowNames.length} rows,'
        ' ${data.colNames.length} columns');
    return data;
  }
}
