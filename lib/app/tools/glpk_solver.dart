import 'dart:async';
import 'dart:convert';

import 'package:catcher/catcher.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/js_engine/js_engine.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

abstract class BaseLPSolver {
  final JsEngine engine = JsEngine();

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

  Future<Map<int, num>> callSolver(BasicLPParams params) async {
    await ensureEngine();
    params.removeInvalidCells();
    final resultString = await engine.eval(
        '''glpk_solver(`${jsonEncode(params)}`)''',
        name: 'solver_caller');
    logger.i('result: $resultString');
    return Map<String, num>.from(jsonDecode(resultString!))
        .map((key, value) => MapEntry(int.parse(key), value));
  }
}

class FreeLPSolver {
  final JsEngine engine = JsEngine();

  FreeLPSolver();

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
  Future<LPSolution> calculate({required FreeLPParams params}) async {
    // if use integer GLPK (simplex then intopt),
    // it may run out of time and memory, then crash.
    // so only use simplex here
    print('=========solving========\nparams=${json.encode(params)}');
    LPSolution solution = LPSolution(originalItems: List.of(params.rows));

    params = FreeLPParams.from(params);
    final data = params.sheet.copy();
    data.itemIds.addAll([Items.bondPointId, Items.expPointId]);
    data.matrix.add(data.questIds
        .map((e) => db2.gameData.getQuestPhase(e)?.bond.toDouble() ?? 0.0)
        .toList());
    data.matrix.add(data.questIds
        .map((e) => db2.gameData.getQuestPhase(e)?.exp.toDouble() ?? 0.0)
        .toList());
    _preProcess(data: data, params: params);
    if (params.rows.isEmpty) {
      logger.d('after pre processing, params has no valid rows.\n'
          'params=${json.encode(params)}');
      EasyLoading.showToast('Invalid inputs');
      return solution;
    }
    if (Maths.max(params.weights, 0.0) <= 0) {
      logger.d('after pre processing, params has no positive weights.\n'
          'params=${json.encode(params)}');
      EasyLoading.showToast('At least one weight > 0');
      return solution;
    }
    try {
      BasicLPParams glpkParams = BasicLPParams();
      glpkParams.colNames = data.questIds;
      glpkParams.rowNames = data.itemIds;
      glpkParams.matA = data.matrix;
      glpkParams.bVec =
          data.itemIds.map((e) => params.getPlanItemCount(e, 0)).toList();
      glpkParams.cVec = params.costMinimize
          ? data.apCosts
          : List.filled(data.apCosts.length, 1, growable: true);
      glpkParams.integer = false;
      final _debugParams = FreeLPParams.from(params)
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
        final questId = int.parse(questKey);
        int count = countFloat.ceil();
        int col = data.questIds.indexOf(questId);
        assert(col >= 0);
        solution.totalNum = solution.totalNum! + count;
        solution.totalCost = solution.totalCost! + count * data.apCosts[col];
        Map<int, double> details = {};
        for (int itemId in params.rows) {
          int row = data.itemIds.indexOf(itemId);
          if (row < 0) {
            continue;
          }
          if (data.matrix[row][col] > 0) {
            details[itemId] = data.matrix[row][col] * count;
          }
        }
        solution.countVars.add(LPVariable<int>(
          name: questId,
          value: count,
          cost: data.apCosts[col],
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
      LPSolution solution, FreeLPParams params, DropRateSheet data) {
    Map<int, double> objectiveWeights = params.objectiveWeights;
    objectiveWeights.removeWhere((key, value) => value <= 0);

    for (int col = 0; col < data.questIds.length; col++) {
      if (col >= data.questIds.length) continue;
      int questId = data.questIds[col];
      Map<int, double> dropWeights = {};
      for (int row = 0; row < data.itemIds.length; row++) {
        int itemId = data.itemIds[row];
        if (objectiveWeights.keys.contains(itemId) &&
            data.matrix[row][col] > 0) {
          dropWeights[itemId] = (params.useAP20 ? 20 / data.apCosts[col] : 1) *
              data.matrix[row][col] *
              objectiveWeights[itemId]!;
          sortDict(dropWeights, reversed: true, inPlace: true);
        }
      }
      if (dropWeights.isNotEmpty) {
        solution.weightVars.add(LPVariable<double>(
            name: questId, detail: dropWeights, value: 0, cost: 0));
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
DropRateSheet _preProcess(
    {required DropRateSheet data, required FreeLPParams params}) {
  print('pre processing GLPK data and params...');
  // inside pre processing, use [params.objective] not [items] and [counts]
  final objective = params.objectiveCounts;

  // free quests for different server
  List<int> cols = data.questIds.sublist(
      0,
      params.maxColNum > 0
          ? params.maxColNum.clamp(0, data.questIds.length)
          : null);
  // only append extra columns having drop data in gpk matrix
  params.extraCols.forEach((col) {
    if (data.questIds.contains(col)) cols.add(col);
  });

  // remove quests in blacklist
  params.blacklist.forEach((col) {
    data.removeCol(col);
  });

  // remove unused quests
  // create a new list since iterator will change the original values
  for (final col in List.of(data.questIds)) {
    if (!cols.contains(col)) {
      data.removeCol(col);
    }
  }

  // now filtrate data's rows/cols
  Set<int> removeCols = {}; // not fit minCost
  // at least one quest for every item, higher priority than removeRows
  Set<int> retainCols = {};
  Set<int> removeRows = {}; // no quest's drop contains the item.

  // traverse originData rather new data
  // remove unused rows
  objective.removeWhere((key, value) {
    int row = data.itemIds.indexOf(key);
    if (row < 0 || value <= 0 || data.matrix[row].every((e) => e <= 0)) {
      removeRows.add(key);
      return true;
    }
    return false;
  });
  List.of(data.itemIds).forEach((row) {
    if (!objective.containsKey(row)) data.removeRow(row);
  });

  // remove cols don't contain any objective rows
  for (int col = 0; col < data.questIds.length; col++) {
    double apRateSum = Maths.sum(objective.keys.map((rowName) {
      return data.matrix[data.itemIds.indexOf(rowName)][col];
    }));
    if (apRateSum == 0) {
      // this col don't contain any objective rows
      removeCols.add(data.questIds[col]);
    }
  }

  // remove quests: ap<minCost
  for (int i = 0; i < data.questIds.length; i++) {
    if (data.apCosts[i] < params.minCost) removeCols.add(data.questIds[i]);
  }

  for (int itemId in objective.keys) {
    int row = data.itemIds.indexOf(itemId);
    int minApRateCol = -1;
    double minAPRateVal = double.infinity;
    for (int j = 0; j < data.questIds.length; j++) {
      double v = data.matrix[row][j];
      if (v > 0) v = data.apCosts[j] / v;
      if (!removeCols.contains(data.questIds[j]) && v > 0) {
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
      int retainCol = data.matrix[row].indexOf(Maths.max(data.matrix[row]));
      if (retainCol < 0) {
        removeRows.add(itemId);
      } else {
        retainCols.add(data.questIds[retainCol]);
      }
    } else {
      retainCols.add(data.questIds[minApRateCol]);
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

  logger.v('processed data: ${data.itemIds.length} rows,'
      ' ${data.questIds.length} columns');
  // print(const JsonEncoder.withIndent('  ').convert(params));
  return data;
}
