part of datatypes;

@JsonSerializable()
class GLPKData {
  List<String> colNames; //quests, n
  List<String> rowNames; // items, m
  List<int> costs; // n
  /// AP rate, m*n. 0 if not dropped
  List<List<double>> matrix;

  /// free quest counts of every progress/chapter
  /// From new to old, the first is jp
  Map<String, int> freeCounts;

  ///
  List<WeeklyMissionQuest> weeklyMissionData;

  int get jpMaxColNum => freeCounts.values.first;

  GLPKData({
    required this.colNames,
    required this.rowNames,
    required this.costs,
    required this.matrix,
    required this.freeCounts,
    required this.weeklyMissionData,
  });

  GLPKData.from(GLPKData other)
      : colNames = List.from(other.colNames),
        rowNames = List.from(other.rowNames),
        costs = List.from(other.costs),
        matrix = List.generate(
            other.matrix.length, (index) => List.from(other.matrix[index])),
        freeCounts = other.freeCounts,
        weeklyMissionData = other.weeklyMissionData
            .map((e) => WeeklyMissionQuest.fromJson(jsonDecode(jsonEncode(e))))
            .toList();

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
    if (index >= 0)
      removeColAt(index);
    else
      logger.w('GLPKData has no such column to remove: "$name"');
  }

  void removeColAt(int index) {
    assert(index >= 0 && index < colNames.length);
    colNames.removeAt(index);
    costs.removeAt(index);
    matrix.forEach((row) => row.removeAt(index));
  }

  factory GLPKData.fromJson(Map<String, dynamic> data) =>
      _$GLPKDataFromJson(data);

  Map<String, dynamic> toJson() => _$GLPKDataToJson(this);
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
    Map<String, int> result = Map();
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
  /// if [countControllers] is null, disabled. Removed controllers are temporary
  /// stored in [_unusedControllers] and dispose them inside widget's dispose
  @JsonKey(ignore: true)
  List<TextEditingController>? countControllers;
  @JsonKey(ignore: true)
  List<TextEditingController>? weightControllers;
  @JsonKey(ignore: true)
  List<TextEditingController> _unusedControllers = [];

  /// items(X)-counts(b) in AX>=b, only generated before transferred to js
  List<String> rows;
  List<int> counts;
  List<double> weights;
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
  Map<String, int> get objectiveCounts => Map.fromIterables(rows, counts);

  Map<String, double> get objectiveWeights => Map.fromIterables(rows, weights);

  GLPKParams({
    List<String>? rows,
    List<int>? counts,
    List<double>? weights,
    Set<String>? blacklist,
    int? minCost = 0,
    bool? costMinimize = true,
    int? maxColNum = -1,
    List<String>? extraCols,
    bool? integerResult = false,
    bool? useAP20 = true,
  })  : rows = rows ?? [],
        counts = counts ?? [],
        weights = weights ?? [],
        blacklist = blacklist ?? Set(),
        minCost = minCost ?? 0,
        costMinimize = costMinimize ?? true,
        maxColNum = maxColNum ?? -1,
        extraCols = extraCols ?? [],
        integerResult = integerResult ?? false,
        useAP20 = useAP20 ?? true {
    // controllers ??= null;
    fillListValue(this.counts, this.rows.length, (_) => 0);
    fillListValue(this.weights, this.rows.length, (_) => 1.0);
  }

  GLPKParams.from(GLPKParams other)
      : rows = List.from(other.rows),
        counts = List.from(other.counts),
        weights = List.from(other.weights),
        blacklist = Set.from(other.blacklist),
        minCost = other.minCost,
        costMinimize = other.costMinimize,
        maxColNum = other.maxColNum,
        extraCols = List.from(other.extraCols),
        integerResult = other.integerResult,
        useAP20 = other.useAP20;

  void validate() {
    // Need to remove item, so from end to start
    counts.length = weights.length = rows.length;
    for (int i = rows.length - 1; i >= 0; i--) {
      if (!db.gameData.glpk.rowNames.contains(rows[i])) {
        removeAt(i);
      } else {
        if (weights[i] < 0) weights[i] = 1;
        if (counts[i] < 0) counts[i] = 0;
      }
    }
  }

  void sortByItem() {
    // rows,counts,weights,countControllers,weightControllers
    final _getSortVal = (String key) {
      return db.gameData.items[key]?.id ?? -1;
    };
    final int length = rows.length;
    List<int> indices = List.generate(length, (index) => index);
    indices.sort((a, b) => _getSortVal(rows[a]) - _getSortVal(rows[b]));
    rows = List.generate(length, (index) => rows[indices[index]]);
    counts = List.generate(length, (index) => counts[indices[index]]);
    weights = List.generate(length, (index) => weights[indices[index]]);
    if (countControllers != null) {
      countControllers =
          List.generate(length, (index) => countControllers![indices[index]]);
    }
    if (weightControllers != null) {
      weightControllers =
          List.generate(length, (index) => weightControllers![indices[index]]);
    }
  }

  void enableControllers() {
    if (countControllers?.length == rows.length &&
        countControllers?.length == weightControllers?.length) {
      return;
    }

    countControllers = [];
    for (int i = 0; i < rows.length; i++) {
      countControllers!.add(TextEditingController(text: counts[i].toString()));
    }
    weightControllers = [];
    for (int i = 0; i < weights.length; i++) {
      weightControllers!
          .add(TextEditingController(text: weights[i].toString()));
    }
  }

  void disableControllers() {
    _unusedControllers
      ..addAll(countControllers ?? [])
      ..addAll(weightControllers ?? []);
    countControllers = weightControllers = null;
  }

  void dispose() {
    countControllers?.forEach((e) => e.dispose());
    weightControllers?.forEach((e) => e.dispose());
    _unusedControllers.forEach((e) => e.dispose());
    countControllers = weightControllers = null;
    _unusedControllers.clear();
  }

  void disposeUnused() {
    _unusedControllers.forEach((e) => e.dispose());
    _unusedControllers.clear();
  }

  bool addOne(String item, [int count = 0, double weight = 1.0]) {
    final index = rows.indexOf(item);
    if (index < 0) {
      rows.add(item);
      counts.add(count);
      weights.add(weight);
      countControllers?.add(TextEditingController(text: count.toString()));
      weightControllers?.add(TextEditingController(text: weight.toString()));
      return true;
    }
    return false;
  }

  void remove(String item) {
    return removeAt(rows.indexOf(item));
  }

  void removeAt(int index) {
    if (index >= 0 && index < rows.length) {
      rows.removeAt(index);
      counts.removeAt(index);
      weights.removeAt(index);
      if (countControllers != null) {
        _unusedControllers.add(countControllers!.removeAt(index));
        _unusedControllers.add(weightControllers!.removeAt(index));
      }
    }
  }

  void removeAll() {
    rows.clear();
    counts.clear();
    weights.clear();
    if (countControllers != null) {
      _unusedControllers
        ..addAll(countControllers ?? [])
        ..addAll(weightControllers ?? []);
      countControllers!.clear();
      weightControllers!.clear();
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
    required T value,
    required this.cost,
    Map<String, T>? detail,
  })  : value = value,
        detail = detail ?? {};

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
