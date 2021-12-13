import 'dart:async';
import 'dart:convert';

import 'package:catcher/catcher.dart';
import 'package:chaldea/components/components.dart';
import 'package:flutter/services.dart';

import 'js_engine/js_engine.dart';

class GLPKSolver {
  final JsEngine engine = JsEngine();

  GLPKSolver();

  /// ensure libs loaded
  Future<void> ensureEngine() async {
    // only load once
    // use callback to setState, not Future.
    print('=========loading js libs=========');
    await engine.init(() async {
      print('loading glpk.min.js ...');
      await engine.eval(await rootBundle.loadString('res/js/glpk.min.js'),
          name: '<glpk.min.js>');
      print('loading solver.js ...');
      await engine.eval(await rootBundle.loadString('res/js/glpk_solver.js'),
          name: '<glpk_solver.js>');
      print('=========js libs loaded.=========');
    }).catchError((e, s) async {
      logger.e('initiate js libs error', e, s);
      Catcher.reportCheckedError(e, s);
      EasyLoading.showToast('initiation error\n$e');
    });
  }

  /// two part: glpk linear programming +(then) efficiency sort
  Future<GLPKSolution> calculate({required GLPKParams params}) async {
    // if use integer GLPK (simplex then intopt),
    // it may run out of time and memory, then crash.
    // so only use simplex here
    print('=========solving========\nparams=${json.encode(params)}');
    GLPKSolution solution = GLPKSolution(originalItems: List.of(params.rows));

    params = GLPKParams.from(params);
    final data = DropRateData.from(params.dropRatesData);
    data.rowNames.addAll([Items.bondPoint, Items.exp]);
    data.matrix.add(data.colNames
        .map((e) => db.gameData.getFreeQuest(e)?.bondPoint.toDouble() ?? 0.0)
        .toList());
    data.matrix.add(data.colNames
        .map((e) => db.gameData.getFreeQuest(e)?.experience.toDouble() ?? 0.0)
        .toList());
    _preProcess(data: data, params: params);
    if (params.rows.isEmpty) {
      logger.d('after pre processing, params has no valid rows.\n'
          'params=${json.encode(params)}');
      EasyLoading.showToast('Invalid inputs');
      return solution;
    }
    if (params.weights.reduce(max) <= 0) {
      logger.d('after pre processing, params has no positive weights.\n'
          'params=${json.encode(params)}');
      EasyLoading.showToast('At least one weight >0');
      return solution;
    }
    try {
      BasicGLPKParams glpkParams = BasicGLPKParams();
      glpkParams.colNames = data.colNames;
      glpkParams.rowNames = data.rowNames;
      glpkParams.AMat = data.matrix;
      glpkParams.bVec =
          data.rowNames.map((e) => params.getPlanItemCount(e, 0)).toList();
      glpkParams.cVec = params.costMinimize
          ? data.costs
          : List.filled(data.costs.length, 1, growable: true);
      glpkParams.integer = false;
      final _debugParams = GLPKParams.from(params)
        ..planItemCounts.clear()
        ..planItemWeights.clear();
      logger.i('glpk params: ${jsonEncode(_debugParams)}');
      await ensureEngine();
      final resultString = await engine.eval(
          '''glpk_solver(`${jsonEncode(glpkParams)}`)''',
          name: 'solver_caller');
      logger.i('result: $resultString');

      Map<String, num> result = Map.from(jsonDecode(resultString ?? '{}'));
      solution.params = params;
      solution.totalNum = 0;
      solution.totalCost = 0;
      result.forEach((questKey, countFloat) {
        int count = countFloat.ceil();
        int col = data.colNames.indexOf(questKey);
        assert(col >= 0);
        solution.totalNum = solution.totalNum! + count;
        solution.totalCost = solution.totalCost! + count * data.costs[col];
        Map<String, double> details = {};
        for (String itemKey in params.rows) {
          int row = data.rowNames.indexOf(itemKey);
          if (row < 0) {
            continue;
          }
          if (data.matrix[row][col] > 0) {
            details[itemKey] = data.matrix[row][col] * count;
          }
        }
        solution.countVars.add(GLPKVariable<int>(
          name: questKey,
          value: count,
          cost: data.costs[col],
          detail: details,
        ));
      });
      solution.sortCountVars();
      //
      _solveEfficiency(solution, params, data);
    } catch (e, s) {
      logger.e('Execute GLPK solver failed', e, s);
      EasyLoading.showToast('Execute GLPK solver failed:\n$e');
      if (kDebugMode) {
        rethrow;
      }
    }
    print('=========solving finished=========');
    return solution;
  }

  void _solveEfficiency(
      GLPKSolution solution, GLPKParams params, DropRateData data) {
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
          dropWeights[itemKey] = (params.useAP20 ? 20 / data.costs[col] : 1) *
              data.matrix[row][col] *
              objectiveWeights[itemKey]!;
          sortDict(dropWeights, reversed: true, inPlace: true);
        }
      }
      if (dropWeights.isNotEmpty) {
        solution.weightVars.add(GLPKVariable<double>(
            name: questKey, detail: dropWeights, value: 0, cost: 0));
      }
    }
    solution.sortWeightVars();
  }

  /// must call [dispose]!!!
  void dispose() {
    engine.dispose();
  }
}

/// [data] and [params] must be copied instances. Modify them **in-place** here
DropRateData _preProcess(
    {required DropRateData data, required GLPKParams params}) {
  print('pre processing GLPK data and params...');
  // inside pre processing, use [params.objective] not [items] and [counts]
  final objective = params.objectiveCounts;

  // now filtrate data's rows/cols
  Set<String> removeCols = {}; // not fit minCost
  // at least one quest for every item, higher priority than removeRows
  Set<String> retainCols = {};
  Set<String> removeRows = {}; // no quest's drop contains the item.

  // traverse originData rather new data
  // remove unused rows
  objective.removeWhere((key, value) {
    if (!data.rowNames.contains(key) || value <= 0) {
      removeRows.add(key);
      return true;
    } else {
      return false;
    }
  });
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
      if (v > 0) v = data.costs[j] / v;
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
      if (retainCol < 0) {
        removeRows.add(rowName);
      } else {
        retainCols.add(data.colNames[retainCol]);
      }
    } else {
      retainCols.add(data.colNames[minApRateCol]);
    }
  }

  // remove rows/cols above
  params.rows.removeWhere((rowName) =>
      removeRows.contains(rowName) || !objective.containsKey(rowName));
  removeRows.forEach((element) => data.removeRow(element));
  removeCols.forEach((element) {
    if (!retainCols.contains(element)) data.removeCol(element);
  });

  // no rows (glpk will raise error), need to check in caller
  if (objective.isEmpty) logger.d('no valid objRows');

  logger.v('processed data: ${data.rowNames.length} rows,'
      ' ${data.colNames.length} columns');
  // print(const JsonEncoder.withIndent('  ').convert(params));
  return data;
}
