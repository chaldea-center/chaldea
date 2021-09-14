part of datatypes;

@JsonSerializable()
class PlanningData {
  @protected
  DropRateData dropRates;
  @protected
  DropRateData legacyDropRates;
  List<WeeklyMissionQuest> weeklyMissions;

  PlanningData({
    required this.dropRates,
    required this.legacyDropRates,
    required this.weeklyMissions,
  });

  DropRateData getDropRate([bool use6th = true]) =>
      use6th ? dropRates : legacyDropRates;

  factory PlanningData.fromJson(Map<String, dynamic> data) =>
      _$PlanningDataFromJson(data);

  Map<String, dynamic> toJson() => _$PlanningDataToJson(this);
}

@JsonSerializable()
class DropRateData {
  /// free quest counts of every progress/chapter
  /// From new to old, the first is jp
  Map<String, int> freeCounts;
  List<int> sampleNum; // n

  List<String> colNames; //quests, n
  List<String> rowNames; // items, m
  List<int> costs; // n

  /// drop rate per quest, m*n. 0 if not dropped
  @JsonKey(ignore: true)
  List<List<double>> matrix = [];

  /// only used when decoding from json
  @protected
  Map<int, Map<int, double>> sparseMatrix;

  int get jpMaxColNum => freeCounts.values.reduce((a, b) => max(a, b));

  DropRateData({
    this.freeCounts = const {},
    this.sampleNum = const [],
    this.colNames = const [],
    this.rowNames = const [],
    this.costs = const [],
    this.sparseMatrix = const {},
  }) : matrix = sparseToMatrix(sparseMatrix, rowNames.length, colNames.length);

  static List<List<double>> sparseToMatrix(
      Map<int, Map<int, double>> sparse, int rows, int cols) {
    List<List<double>> m =
        List.generate(rows, (index) => List.generate(cols, (index) => 0));
    sparse.forEach((i, row) {
      row.forEach((j, v) {
        // 80.0 =>80.0%
        m[i][j] = v / 100;
      });
    });
    return m;
  }

  DropRateData.from(DropRateData other)
      : freeCounts = Map.of(other.freeCounts),
        sampleNum = List.of(other.sampleNum),
        colNames = List.of(other.colNames),
        rowNames = List.of(other.rowNames),
        costs = List.of(other.costs),
        sparseMatrix = {},
        matrix = List.generate(
            other.matrix.length, (index) => List.of(other.matrix[index]));

  List<double> columnAt(int colIndex) {
    return List.generate(
        rowNames.length, (rowIndex) => matrix[rowIndex][colIndex]);
  }

  /// DON'T call the following methods on original data
  void removeRow(String name) {
    int index = rowNames.indexOf(name);
    if (index >= 0) removeRowAt(index);
  }

  void removeRowAt(int index) {
    assert(index >= 0 && index < rowNames.length);
    rowNames.removeAt(index);
    matrix.removeAt(index);
  }

  void removeCol(String name) {
    int index = colNames.indexOf(name);
    if (index >= 0) {
      removeColAt(index);
    } else {
      logger.w('GLPKData has no such column to remove: "$name"');
    }
  }

  void removeColAt(int index) {
    assert(index >= 0 && index < colNames.length);
    colNames.removeAt(index);
    costs.removeAt(index);
    sampleNum.removeAt(index);
    matrix.forEach((row) => row.removeAt(index));
  }

  factory DropRateData.fromJson(Map<String, dynamic> data) =>
      _$DropRateDataFromJson(data);

  Map<String, dynamic> toJson() => _$DropRateDataToJson(this);
}

@JsonSerializable(checked: true)
class WeeklyMissionQuest {
  String chapter;
  String place;
  String placeJp;
  int ap;
  Map<String, int> servantTraits;
  Map<String, int> enemyTraits;
  List<String> servants;
  List<String> battlefields;

  Map<String, int> get allTraits {
    Map<String, int> result = {};
    servantTraits.forEach((key, value) {
      result['从者_$key'] = value;
    });
    enemyTraits.forEach((key, value) {
      result['小怪_$key'] = value;
    });
    battlefields.forEach((key) {
      result['场地_$key'] = 1;
    });
    return result;
  }

  WeeklyMissionQuest({
    required this.chapter,
    required this.place,
    required this.placeJp,
    required this.ap,
    required this.enemyTraits,
    required this.servantTraits,
    required this.servants,
    required this.battlefields,
  });

  factory WeeklyMissionQuest.fromJson(Map<String, dynamic> data) =>
      _$WeeklyMissionQuestFromJson(data);

  Map<String, dynamic> toJson() => _$WeeklyMissionQuestToJson(this);
}

/// for solve_glpk(data_str and params_str)
@JsonSerializable(checked: true)
class GLPKParams {
  bool use6th;

  /// items(X)-counts(b) in AX>=b, only generated before transferred to js
  List<String> rows;

  Map<String, int> planItemCounts;
  Map<String, double> planItemWeights;

  List<int> get counts => rows.map((e) => getPlanItemCount(e)).toList();

  List<double> get weights => rows.map((e) => getPlanItemWeight(e)).toList();

  Set<String> blacklist;

  /// generated from [rows] and [counts], only used when processing data
  /// before transferred to js
//  Map<String, int> objective;

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
  List<String> extraCols;

  /// If true, use ILP(simplex+intopt), else use simplex only
  /// transferred to js
  bool integerResult;

  bool useAP20;

  /// convert two key-value list to map
  Map<String, int> get objectiveCounts =>
      Map.fromIterable(rows, value: (k) => getPlanItemCount(k));

  Map<String, double> get objectiveWeights =>
      Map.fromIterable(rows, value: (k) => getPlanItemWeight(k));

  int getPlanItemCount(String key) => planItemCounts[key] ??= 50;

  double getPlanItemWeight(String key) => planItemWeights[key] ??= 1.0;

  GLPKParams({
    bool? use6th,
    List<String>? rows,
    Set<String>? blacklist,
    int? minCost = 0,
    bool? costMinimize = true,
    int? maxColNum = -1,
    List<String>? extraCols,
    bool? integerResult = false,
    bool? useAP20 = true,
    Map<String, int>? planItemCounts,
    Map<String, double>? planItemWeights,
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

  GLPKParams.from(GLPKParams other)
      : use6th = other.use6th,
        rows = List.from(other.rows),
        blacklist = Set.from(other.blacklist),
        minCost = other.minCost,
        costMinimize = other.costMinimize,
        maxColNum = other.maxColNum,
        extraCols = List.from(other.extraCols),
        integerResult = other.integerResult,
        useAP20 = other.useAP20,
        planItemCounts = other.planItemCounts,
        planItemWeights = other.planItemWeights;

  DropRateData get dropRatesData =>
      db.gameData.planningData.getDropRate(use6th);

  void validate() {
    rows.removeWhere((e) => !dropRatesData.rowNames.contains(e));
  }

  void sortByItem() {
    // rows
    int _getSortVal(String key) {
      return db.gameData.items[key]?.id ?? -1;
    }

    rows.sort((a, b) => _getSortVal(a).compareTo(_getSortVal(b)));
  }

  void removeAt(int index) {
    if (index >= 0 && index < rows.length) {
      rows.removeAt(index);
    }
  }

  factory GLPKParams.fromJson(Map<String, dynamic> data) =>
      _$GLPKParamsFromJson(data);

  Map<String, dynamic> toJson() => _$GLPKParamsToJson(this);
}

@JsonSerializable()
class GLPKSolution {
  /// 0-glpk plan, 1-efficiency
  int destination = 0;
  int? totalCost;
  int? totalNum;

  //int
  List<GLPKVariable> countVars;

  //double
  List<GLPKVariable> weightVars;

  @JsonKey(ignore: true)
  GLPKParams? params;

  GLPKSolution({
    int? destination = 0,
    this.totalCost,
    this.totalNum,
    List<GLPKVariable>? countVars,
    List<GLPKVariable>? weightVars,
  })  : destination = destination ?? 0,
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
    weightVars.sort((a, b) => sum(b.detail.values as Iterable<double>)
        .compareTo(sum(a.detail.values as Iterable<double>)));
  }

  factory GLPKSolution.fromJson(Map<String, dynamic> data) =>
      _$GLPKSolutionFromJson(data);

  Map<String, dynamic> toJson() => _$GLPKSolutionToJson(this);
}

@JsonSerializable()
class GLPKVariable<T> {
  String name;
  @_Converter()
  T value;
  int cost;

  /// total item-num statistics from [value] times of quest [name]
  @_Converter()
  Map<String, T> detail;

  GLPKVariable({
    required this.name,
    required this.value,
    required this.cost,
    Map<String, T>? detail,
  }) : detail = detail ?? {};

  factory GLPKVariable.fromJson(Map<String, dynamic> data) =>
      _$GLPKVariableFromJson<T>(data);

  Map<String, dynamic> toJson() => _$GLPKVariableToJson<T>(this);
}

/// basic [String,int,double,null] converter for generic types
class _Converter<T> implements JsonConverter<T, Object> {
  const _Converter();

  @override
  T fromJson(Object json) {
    return json as T;
  }

  @override
  num toJson(T object) {
    return object as num;
  }
}

/// min c'x
///   Ax>=b
@JsonSerializable()
class BasicGLPKParams {
  List<String> colNames; //n
  List<String> rowNames; //m
  List<List<num>> AMat; // ignore: non_constant_identifier_names, // m*n
  List<num> bVec; //m
  List<num> cVec; //n
  bool integer;

  BasicGLPKParams({
    List<String>? colNames,
    List<String>? rowNames,
    List<List<num>>? AMat, // ignore: non_constant_identifier_names
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

  void addRow(String rowName, List<num> rowOfA, num b) {
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

  factory BasicGLPKParams.fromJson(Map<String, dynamic> data) =>
      _$BasicGLPKParamsFromJson(data);

  Map<String, dynamic> toJson() => _$BasicGLPKParamsToJson(this);
}
