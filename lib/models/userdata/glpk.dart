import 'package:chaldea/utils/utils.dart';
import '../db.dart';
import '../gamedata/drop_rate.dart';
import '_helper.dart';

part '../../generated/models/userdata/glpk.g.dart';

/// for solve_glpk(data_str and params_str)
@JsonSerializable(checked: true)
class FreeLPParams {
  /// items(X)-counts(b) in AX>=b, only generated before transferred to js
  List<int> rows;

  Map<int, int> planItemCounts;
  Map<int, double> planItemWeights;

  List<int> get counts => rows.map((e) => getPlanItemCount(e)).toList();

  List<double> get weights => rows.map((e) => getPlanItemWeight(e)).toList();

  int progress;

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

  /// for event quests, [extraCols]>[jpMaxColNum]
  /// not used
  List<int> extraCols;

  /// If true, use ILP(simplex+intopt), else use simplex only
  /// transferred to js
  bool integerResult;

  bool useAP20;

  bool dailyCostHalf;

  /// bond efficiency, percent*5, count*50
  int bondBonusPercent;
  int bondBonusCount;

  /// convert two key-value list to map
  Map<int, int> get objectiveCounts => Map.fromIterable(rows, value: (k) => getPlanItemCount(k));

  Map<int, double> get objectiveWeights => Map.fromIterable(rows, value: (k) => getPlanItemWeight(k));

  int getPlanItemCount(int id, [int? _default]) => planItemCounts[id] ??= _default ?? 50;

  double getPlanItemWeight(int id, [double? _default]) => planItemWeights[id] ??= _default ?? 1.0;

  FreeLPParams({
    List<int>? rows,
    this.progress = -1,
    Set<int>? blacklist,
    this.minCost = 0,
    this.costMinimize = true,
    List<int>? extraCols,
    this.integerResult = false,
    this.useAP20 = true,
    this.dailyCostHalf = false,
    this.bondBonusPercent = 0,
    this.bondBonusCount = 0,
    Map<int, int>? planItemCounts,
    Map<int, double>? planItemWeights,
  })  : rows = rows ?? [],
        blacklist = blacklist ?? {},
        extraCols = extraCols ?? [],
        planItemCounts = planItemCounts ?? {},
        planItemWeights = planItemWeights ?? {};

  FreeLPParams.from(FreeLPParams other)
      : rows = List.of(other.rows),
        progress = other.progress,
        blacklist = Set.of(other.blacklist),
        minCost = other.minCost,
        costMinimize = other.costMinimize,
        extraCols = List.of(other.extraCols),
        integerResult = other.integerResult,
        useAP20 = other.useAP20,
        dailyCostHalf = other.dailyCostHalf,
        bondBonusPercent = other.bondBonusPercent,
        bondBonusCount = other.bondBonusCount,
        planItemCounts = Map.of(other.planItemCounts),
        planItemWeights = Map.of(other.planItemWeights);

  DropRateSheet get sheet => db.gameData.dropRate.getSheet();

  void validate() {
    rows.removeWhere((e) => !sheet.itemIds.contains(e));
    bondBonusPercent = bondBonusPercent.clamp(0, 9);
    bondBonusCount = bondBonusCount.clamp2(0, 2);
  }

  void sortByItem() {
    // rows
    rows.sort2((id) => db.gameData.items[id]?.priority ?? id);
  }

  void removeAt(int index) {
    if (index >= 0 && index < rows.length) {
      rows.removeAt(index);
    }
  }

  factory FreeLPParams.fromJson(Map<String, dynamic> data) => _$FreeLPParamsFromJson(data);

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

  @JsonKey(includeFromJson: false, includeToJson: false)
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
    weightVars.sort((a, b) => Maths.sum(b.detail.values).compareTo(Maths.sum(a.detail.values)));
  }

  List<int> getIgnoredKeys() {
    List<int> items = [];
    for (final v in countVars) {
      items.addAll(v.detail.keys);
    }
    return originalItems.where((e) => !items.contains(e)).toList();
  }

  factory LPSolution.fromJson(Map<String, dynamic> data) => _$LPSolutionFromJson(data);

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

  factory LPVariable.fromJson(Map<String, dynamic> data) => _$LPVariableFromJson<T>(data, _fromJsonT);

  Map<String, dynamic> toJson() => _$LPVariableToJson<T>(this, _toJsonT);
}

T _fromJsonT<T>(Object? data) => data as T;

Object? _toJsonT<T>(T value) => value;

/// min c'x
///   Ax>=b
@JsonSerializable()
class BasicLPParams {
  List<int> colNames; //n
  List<int> rowNames; //m
  List<List<num>> matA; // m*n
  List<num> bVec; //m
  List<num> cVec; //n
  bool integer;

  BasicLPParams({
    List<int>? colNames,
    List<int>? rowNames,
    List<List<num>>? matA,
    List<num>? bVec,
    List<num>? cVec,
    bool? integer,
  })  : colNames = colNames ?? [],
        rowNames = rowNames ?? [],
        matA = matA ?? [],
        bVec = bVec ?? [],
        cVec = cVec ?? [],
        integer = integer ?? false;

  List<num> getCol(int index) {
    return matA.map((e) => e[index]).toList();
  }

  void addRow(int rowName, List<num> rowOfA, num b) {
    rowNames.add(rowName);
    matA.add(rowOfA);
    bVec.add(b);
  }

  void removeCol(int index) {
    colNames.removeAt(index);
    cVec.removeAt(index);
    matA.forEach((row) {
      row.removeAt(index);
    });
  }

  void removeRow(int index) {
    rowNames.removeAt(index);
    matA.removeAt(index);
    bVec.removeAt(index);
  }

  void removeInvalidCells() {
    for (int row = rowNames.length - 1; row >= 0; row--) {
      if (bVec[row] <= 0 || matA[row].every((e) => e == 0)) {
        removeRow(row);
      }
    }
    for (int col = colNames.length - 1; col >= 0; col--) {
      if (matA.every((rowData) => rowData[col] == 0)) {
        removeCol(col);
      }
    }
  }

  factory BasicLPParams.fromJson(Map<String, dynamic> data) => _$BasicLPParamsFromJson(data);

  Map<String, dynamic> toJson() => _$BasicLPParamsToJson(this);
}
