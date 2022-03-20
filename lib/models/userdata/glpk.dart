import 'package:chaldea/utils/utils.dart';

import '../db.dart';
import '../gamedata/drop_rate.dart';
import '_helper.dart';

part '../../generated/models/userdata/glpk.g.dart';

/// for solve_glpk(data_str and params_str)
@JsonSerializable(checked: true)
class FreeLPParams {
  bool use6th;

  /// items(X)-counts(b) in AX>=b, only generated before transferred to js
  List<int> rows;

  Map<int, int> planItemCounts;
  Map<int, double> planItemWeights;

  List<int> get counts => rows.map((e) => getPlanItemCount(e)).toList();

  List<double> get weights => rows.map((e) => getPlanItemWeight(e)).toList();

  Set<int> blacklist; // questIds

  /// generated from [rows] and [counts], only used when processing data
  /// before transferred to js
  //  Map<int, int> objective;

  /// limit minimum coefficient of quest
  int minCost;

  /// linear programming target
  /// true: minimum ap cost = sum(cost_i*x_i)
  /// false: minimum battle num = sum(x_i)
  /// transferred to js
  bool costMinimize;

  /// for free quests, [maxColNum] = [cnMaxColNum] or [jpMaxColNum]
  int maxColNum;

  /// for event quests, [extraCols]>[jpMaxColNum]
  /// not used
  List<int> extraCols;

  /// If true, use ILP(simplex+intopt), else use simplex only
  /// transferred to js
  bool integerResult;

  bool useAP20;

  /// convert two key-value list to map
  Map<int, int> get objectiveCounts =>
      Map.fromIterable(rows, value: (k) => getPlanItemCount(k));

  Map<int, double> get objectiveWeights =>
      Map.fromIterable(rows, value: (k) => getPlanItemWeight(k));

  int getPlanItemCount(int id, [int? _default]) =>
      planItemCounts[id] ??= _default ?? 50;

  double getPlanItemWeight(int id, [double? _default]) =>
      planItemWeights[id] ??= _default ?? 1.0;

  FreeLPParams({
    bool? use6th,
    List<int>? rows,
    Set<int>? blacklist,
    int? minCost = 0,
    bool? costMinimize = true,
    int? maxColNum = -1,
    List<int>? extraCols,
    bool? integerResult = false,
    bool? useAP20 = true,
    Map<int, int>? planItemCounts,
    Map<int, double>? planItemWeights,
  })  : use6th = use6th ?? true,
        rows = rows ?? [],
        blacklist = blacklist ?? {},
        minCost = minCost ?? 0,
        costMinimize = costMinimize ?? true,
        maxColNum = maxColNum ?? -1,
        extraCols = extraCols ?? [],
        integerResult = integerResult ?? false,
        useAP20 = useAP20 ?? true,
        planItemCounts = planItemCounts ?? {},
        planItemWeights = planItemWeights ?? {};

  FreeLPParams.from(FreeLPParams other)
      : use6th = other.use6th,
        rows = List.of(other.rows),
        blacklist = Set.of(other.blacklist),
        minCost = other.minCost,
        costMinimize = other.costMinimize,
        maxColNum = other.maxColNum,
        extraCols = List.of(other.extraCols),
        integerResult = other.integerResult,
        useAP20 = other.useAP20,
        planItemCounts = Map.of(other.planItemCounts),
        planItemWeights = Map.of(other.planItemWeights);

  DropRateSheet get sheet => db2.gameData.dropRate.getSheet(use6th);

  void validate() {
    rows.removeWhere((e) => !sheet.itemIds.contains(e));
  }

  void sortByItem() {
    // rows
    rows.sort2((id) => db2.gameData.items[id]?.priority ?? id);
  }

  void removeAt(int index) {
    if (index >= 0 && index < rows.length) {
      rows.removeAt(index);
    }
  }

  factory FreeLPParams.fromJson(Map<String, dynamic> data) =>
      _$FreeLPParamsFromJson(data);

  Map<String, dynamic> toJson() => _$FreeLPParamsToJson(this);
}

@JsonSerializable()
class LPSolution {
  /// 0-glpk plan, 1-efficiency
  int destination = 0;
  List<int> originalItems;
  int? totalCost;
  int? totalNum;

  //int
  List<LPVariable> countVars;

  //double
  List<LPVariable> weightVars;

  @JsonKey(ignore: true)
  FreeLPParams? params;

  LPSolution({
    int? destination = 0,
    List<int>? originalItems,
    this.totalCost,
    this.totalNum,
    List<LPVariable>? countVars,
    List<LPVariable>? weightVars,
  })  : destination = destination ?? 0,
        originalItems = originalItems ?? [],
        countVars = countVars ?? [],
        weightVars = weightVars ?? [];

  void clear() {
    totalCost = null;
    totalNum = null;
    countVars.clear();
  }

  void sortCountVars() {
    countVars.sort((a, b) => b.value - a.value);
  }

  void sortWeightVars() {
    weightVars.sort((a, b) =>
        Maths.sum(b.detail.values).compareTo(Maths.sum(a.detail.values)));
  }

  List<int> getIgnoredKeys() {
    List<int> items = [];
    for (final v in countVars) {
      items.addAll(v.detail.keys);
    }
    return originalItems.where((e) => !items.contains(e)).toList();
  }

  factory LPSolution.fromJson(Map<String, dynamic> data) =>
      _$LPSolutionFromJson(data);

  Map<String, dynamic> toJson() => _$LPSolutionToJson(this);
}

@JsonSerializable()
class LPVariable<T> {
  int name;
  T value;
  int cost;

  /// total item-num statistics from [value] times of quest [name]
  // @_Converter()
  Map<int, double> detail;

  LPVariable({
    required this.name,
    required this.value,
    required this.cost,
    Map<int, double>? detail,
  }) : detail = detail ?? {};

  factory LPVariable.fromJson(Map<String, dynamic> data) =>
      _$LPVariableFromJson<T>(data, _fromJsonT);

  Map<String, dynamic> toJson() => _$LPVariableToJson<T>(this, _toJsonT);
}

T _fromJsonT<T>(Object? data) => data as T;

Object? _toJsonT<T>(T value) => value.toString();

/// min c'x
///   Ax>=b
@JsonSerializable()
class BasicLPParams {
  List<int> colNames; //n
  List<int> rowNames; //m
  List<List<num>> AMat; // m*n
  List<num> bVec; //m
  List<num> cVec; //n
  bool integer;

  BasicLPParams({
    List<int>? colNames,
    List<int>? rowNames,
    List<List<num>>? AMat,
    List<num>? bVec,
    List<num>? cVec,
    bool? integer,
  })  : colNames = colNames ?? [],
        rowNames = rowNames ?? [],
        AMat = AMat ?? [],
        bVec = bVec ?? [],
        cVec = cVec ?? [],
        integer = integer ?? false;

  List<num> getCol(int index) {
    return AMat.map((e) => e[index]).toList();
  }

  void addRow(int rowName, List<num> rowOfA, num b) {
    rowNames.add(rowName);
    AMat.add(rowOfA);
    bVec.add(b);
  }

  void removeCol(int index) {
    colNames.removeAt(index);
    cVec.removeAt(index);
    AMat.forEach((row) {
      row.removeAt(index);
    });
  }

  void removeRow(int index) {
    rowNames.removeAt(index);
    AMat.removeAt(index);
    bVec.removeAt(index);
  }

  void removeInvalidCells() {
    for (int row = rowNames.length - 1; row >= 0; row--) {
      if (bVec[row] <= 0 || AMat[row].every((e) => e == 0)) {
        removeRow(row);
      }
    }
    for (int col = colNames.length - 1; col >= 0; col--) {
      if (AMat.every((rowData) => rowData[col] == 0)) {
        removeCol(col);
      }
    }
  }

  factory BasicLPParams.fromJson(Map<String, dynamic> data) =>
      _$BasicLPParamsFromJson(data);

  Map<String, dynamic> toJson() => _$BasicLPParamsToJson(this);
}
