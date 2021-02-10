//@dart=2.12
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:chaldea/components/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qjs/flutter_qjs.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

abstract class JsEngine<T> {
  final T engine;

  JsEngine(this.engine);

  /// init if needed
  Future<void> init();

  /// JSON.stringify returned object
  Future<String> eval(String command, {String name});

  void dispose();
}

/// using package `flutter_qjs`
class QjsEngine implements JsEngine<IsolateQjs> {
  final IsolateQjs engine = IsolateQjs();

  QjsEngine();

  Future<void> init() async => null;

  Future<String> eval(String command, {String? name}) async {
    return (await engine.evaluate(command, name: name)).toString();
  }

  void dispose() {
    engine.close();
  }
}

/// using package `flutter_webview_plugin`
class WebviewJsEngine implements JsEngine<FlutterWebviewPlugin> {
  final FlutterWebviewPlugin engine = FlutterWebviewPlugin();

  WebviewJsEngine();

  Future<bool> isopen() async {
    String s = await engine.evalJavascript('1+1');
    if (s != '2') {
      print('eval 1+1=$s, webview is closed');
      return false;
    }
    return true;
  }

  Future<void> init() async {
    if (await isopen()) return;
    await engine.launch(
      Uri.dataFromString('''<html><body></body></html>''',
          mimeType: 'text/html', parameters: {'charset': 'utf-8'}).toString(),
      hidden: true,
    );
    while (true) {
      if (await isopen()) break;
      await Future.delayed(Duration(seconds: 1));
    }
  }

  Future<String> eval(String command, {String? name}) async {
    return engine.evalJavascript(command);
  }

  void dispose() {
    engine.dispose();
    engine.close();
  }
}

class GLPKSolver {
  // final JsEngine js = WebviewJsEngine();
  final JsEngine js = QjsEngine();
  Completer? _initCompleter;

  GLPKSolver();

  /// ensure libs loaded
  Future<void> ensureEngine() async {
    if (_initCompleter != null) {
      return await _initCompleter!.future;
    }
    _initCompleter = Completer();
    // only load once
    // use callback to setState, not Future.
    await js.init();
    print('=========loading js libs=========');
    try {
      print('loading glpk.min.js ...');
      await js.eval(await rootBundle.loadString('res/js/glpk.min.js'),
          name: '<glpk.min.js>');
      print('loading solver.js ...');
      await js.eval(await rootBundle.loadString('res/js/solver.js'),
          name: '<solver.js>');
      print('=========js libs loaded.=========');
    } catch (e, s) {
      logger.e('initiate js libs error', e, s);
      EasyLoading.showToast('initiation error\n$e');
      _initCompleter!.completeError(e);
    }
    _initCompleter!.complete();
  }

  /// two part: glpk linear programming +(then) efficiency sort
  Future<GLPKSolution?> calculate(
      {required GLPKData data, required GLPKParams params}) async {
    // if use integer GLPK (simplex then intopt),
    // it may run out of time and memory, then crash.
    // so only use simplex here
    GLPKSolution solution = GLPKSolution();
    final params2 = GLPKParams.from(params);
    final data2 = GLPKData.from(data);
    _preProcess(data: data2, params: params2);

    try {
      await ensureEngine();
      print('=========solving========\nparams="${json.encode(params)}"');
      if (params2.rows.length == 0) {
        logger.d('after pre processing, params has no valid rows.\n'
            'params=${json.encode(params2)}');
        EasyLoading.showToast('Invalid inputs');
      } else if (params2.weights.reduce(max) <= 0) {
        logger.d('after pre processing, params has no positive weights.\n'
            'params=${json.encode(params2)}');
        EasyLoading.showToast('At least one weight >0');
      } else {
//        print('modified params: ${json.encode(params2)}');
        String resultString = await js.eval(
            '''solve_glpk( `${json.encode(data2)}`,`${json.encode(params2)}`);''');
        resultString = resultString.trim();
        logger.v('result: $resultString');
        if (resultString.isNotEmpty != true || resultString == 'null') {
          throw 'qjsEngine return nothing!';
        }
        var result;
        try {
          result = json.decode(resultString);
        } catch (e) {
          throw FormatException(
              'JsonDecodeError(error=$e)\njsonString:$result');
        }
        solution = GLPKSolution.fromJson(Map.from(result));
        solution.sortCountVars();
      }
    } catch (e, s) {
      logger.e('Execute GLPK solver failed', e, s);
      EasyLoading.showToast('Execute GLPK solver failed:\n$e');
      if (kDebugMode_) {
        rethrow;
      }
    }
    _solveEfficiency(solution, params2, data2);
    print('=========solving finished=========');
    return solution;
  }

  void _solveEfficiency(
      GLPKSolution solution, GLPKParams params, GLPKData data) {
    Map<String, double> objectiveWeights = params.objectiveWeights;
    objectiveWeights.removeWhere((key, value) => value <= 0);

    for (int col = 0; col < data.colNames.length; col++) {
      if (col >= data.jpMaxColNum) continue;
      String questKey = data.colNames[col];
      Map<String, double> dropWeights = {};
      for (int row = 0; row < data.rowNames.length; row++) {
        String itemKey = data.rowNames[row];
        if (objectiveWeights.keys.contains(itemKey) &&
            data.matrix[row][col] > 0) {
          dropWeights[itemKey] =
              (params.useAP20 ?? true ? 20 : data.costs[col]) /
                  data.matrix[row][col] *
                  objectiveWeights[itemKey]!;
          sortDict(dropWeights, reversed: true, inPlace: true);
        }
      }
      if (dropWeights.isNotEmpty) {
        solution.weightVars
            .add(GLPKVariable(name: questKey, detail: dropWeights));
      }
    }
    solution.sortWeightVars();
  }

  /// must call [dispose]!!!
  void dispose() {
    js.dispose();
  }
}

/// [data] and [params] must be copied instances. Modify them **in-place** here
GLPKData _preProcess({required GLPKData data, required GLPKParams params}) {
  print('pre processing GLPK data and params...');
  // inside pre processing, use [params.objective] not [items] and [counts]
  final objective = params.objectiveCounts;

  // traverse originData rather new data
  // remove unused rows
  objective
      .removeWhere((key, value) => !data.rowNames.contains(key) || value <= 0);
  List.from(data.rowNames).forEach((row) {
    if (!objective.containsKey(row)) data.removeRow(row);
  });

  // free quests for different server
  List<String> cols = data.colNames
      .sublist(0, params.maxColNum > 0 ? params.maxColNum : data.jpMaxColNum);
  // only append extra columns having drop data in gpk matrix
  params.extraCols.forEach((col) {
    if (data.colNames.contains(col)) cols.add(col);
  });

  // remove quests in blacklist
  params.blacklist.forEach((col) {
    data.removeCol(col);
  });

  // remove unused quests
  // create a new list since iterator will change the original values
  List.from(data.colNames).forEach((col) {
    if (!cols.contains(col)) data.removeCol(col);
  });

  // now filtrate data's rows/cols
  Set<String> removeCols = {}; // not fit minCost
  // at least one quest for every item, higher priority than removeRows
  Set<String> retainCols = {};
  Set<String> removeRows = {}; // no quest's drop contains the item.

  // remove cols don't contain any objective rows
  for (int col = 0; col < data.colNames.length; col++) {
    double apRateSum = sum(objective.keys.map((rowName) {
      return data.matrix[data.rowNames.indexOf(rowName)][col];
    }));
    if (apRateSum == 0) {
      // this col don't contain any objective rows
      removeCols.add(data.colNames[col]);
    }
  }

  // remove quests: ap<minCost
  for (int i = 0; i < data.colNames.length; i++) {
    if (data.costs[i] < params.minCost) removeCols.add(data.colNames[i]);
  }

  for (String rowName in objective.keys) {
    int row = data.rowNames.indexOf(rowName);
    int minApRateCol = -1;
    double minAPRateVal = double.infinity;
    for (int j = 0; j < data.colNames.length; j++) {
      double v = data.matrix[row][j];
      if (!removeCols.contains(data.colNames[j]) && v > 0) {
        if (v < minAPRateVal) {
          // record min col
          minApRateCol = j;
          minAPRateVal = v;
        }
      }
    }
    if (minApRateCol < 0) {
      // no column(cost>minCost) contains rowName
      // then retain the column with max drop rate/min ap rate
      int retainCol = data.matrix[row].indexOf(data.matrix[row].reduce(max));
      if (retainCol < 0)
        removeRows.add(rowName);
      else
        retainCols.add(data.colNames[retainCol]);
    } else {
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
