part of datatypes;

@JsonSerializable()
class GLPKData {
  List<String> colNames; //quests, n
  List<String> rowNames; // items, m
  List<int> costs; // n
  List<List<double>> matrix;
  int cnMaxColNum;
  int jpMaxColNum;

  GLPKData({
    this.colNames,
    this.rowNames,
    this.costs,
    this.matrix,
    this.cnMaxColNum,
    this.jpMaxColNum,
  });

  GLPKData.from(GLPKData other)
      : colNames = List.from(other.colNames),
        rowNames = List.from(other.rowNames),
        costs = List.from(other.costs),
        matrix = List.generate(
            other.matrix.length, (index) => List.from(other.matrix[index])),
        cnMaxColNum = other.cnMaxColNum,
        jpMaxColNum = other.jpMaxColNum;

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

/// for solve_glpk(data_str and params_str)
@JsonSerializable(checked: true)
class GLPKParams {
  /// if [controllers] is null, disabled. Removed controllers are temporary
  /// stored in [_unusedControllers] and dispose them inside widget's dispose
  @JsonKey(ignore: true)
  List<TextEditingController> controllers;
  @JsonKey(ignore: true)
  List<TextEditingController> _unusedControllers = [];

  /// items(X)-counts(b) in AX>=b, only generated before transferred to js
  List<String> rows;
  List<int> counts;

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

  GLPKParams({
    this.rows,
    this.counts,
    this.minCost,
    this.costMinimize,
    this.maxColNum,
    this.extraCols,
    this.integerResult,
  }) {
    // controllers ??= null;
    rows ??= [];
    counts ??= [];
    assert(rows.length == counts.length);
    minCost ??= 0;
    costMinimize ??= true;
    maxColNum ??= -1;
    extraCols ??= [];
    integerResult ??= false;
  }

  GLPKParams.from(GLPKParams other)
      : rows = List.from(other.rows),
        counts = List.from(other.counts),
        minCost = other.minCost,
        costMinimize = other.costMinimize,
        maxColNum = other.maxColNum,
        extraCols = List.from(other.extraCols),
        integerResult = other.integerResult;

  Map<String, int> generateObjective() => Map.fromIterables(rows, counts);

  void sortByItem() {
    final _getSortVal = (String key) {
      return db.gameData.items[key]?.id ?? -1;
    };
    final countsMap = Map.fromIterables(rows, counts);
    final controllersMap =
        controllers == null ? null : Map.fromIterables(rows, controllers);
    rows.sort((a, b) => _getSortVal(a) - _getSortVal(b));
    counts = rows.map((e) => countsMap[e]).toList();
    if (controllers != null) {
      controllers = rows.map((e) => controllersMap[e]).toList();
    }
  }

  void enableControllers() {
    if (controllers == null) {
      controllers = [];
      for (int i = 0; i < rows.length; i++) {
        controllers.add(TextEditingController(text: counts[i].toString()));
      }
    }
  }

  void disableControllers() {
    if (controllers != null) {
      _unusedControllers.addAll(controllers);
      controllers = null;
    }
  }

  void dispose() {
    controllers?.forEach((element) => element.dispose());
    _unusedControllers.forEach((element) => element.dispose());
    controllers = _unusedControllers = null;
  }

  void addOne(String item, [int n = 0]) {
    final index = rows.indexOf(item);
    if (index < 0) {
      rows.add(item);
      counts.add(n);
      controllers?.add(TextEditingController(text: n.toString()));
    }
  }

  void remove(String item) {
    final index = rows.indexOf(item);
    if (index >= 0) {
      rows.removeAt(index);
      counts.removeAt(index);
      if (controllers != null) {
        _unusedControllers.add(controllers.removeAt(index));
      }
    }
  }

  void removeAll() {
    rows.clear();
    counts.clear();
    if (controllers != null) {
      _unusedControllers.addAll(controllers);
      controllers.clear();
    }
  }

  factory GLPKParams.fromJson(Map<String, dynamic> data) =>
      _$GLPKParamsFromJson(data);

  Map<String, dynamic> toJson() => _$GLPKParamsToJson(this);
}

@JsonSerializable()
class GLPKSolution {
  int totalCost;
  int totalNum;
  List<GLPKVariable> variables;

  GLPKSolution({this.totalCost, this.totalNum, this.variables});

  void clear() {
    totalCost = null;
    totalNum = null;
    variables.clear();
  }

  void sortByValue() {
    variables.sort((a, b) => b.value - a.value);
  }

  factory GLPKSolution.fromJson(Map<String, dynamic> data) =>
      _$GLPKSolutionFromJson(data);

  Map<String, dynamic> toJson() => _$GLPKSolutionToJson(this);
}

@JsonSerializable()
class GLPKVariable {
  String name;
  int value;
  int cost;

  /// total item-num statistics from [value] times of quest [name]
  Map<String, int> detail;

  GLPKVariable({this.name, this.value, this.cost, this.detail});

  factory GLPKVariable.fromJson(Map<String, dynamic> data) =>
      _$GLPKVariableFromJson(data);

  Map<String, dynamic> toJson() => _$GLPKVariableToJson(this);
}
