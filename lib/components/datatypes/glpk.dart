part of datatypes;

@JsonSerializable()
class GLPKData {
  List<String> colNames; //quests, n
  List<String> rowNames; // items, m
  List<num> coeff; // n
  List<List<num>> matrix; //m*n
  int cnMaxColNum;

  GLPKData({
    this.colNames,
    this.rowNames,
    this.coeff,
    this.matrix,
    this.cnMaxColNum,
  });

  /// don't edit on origin data, copied data preferred.
  void removeColumn(String col) {
    int index = colNames.indexOf(col);
    colNames.removeAt(index);
    coeff.removeAt(index);
    matrix.forEach((row) => row.removeAt(index));
  }

  void removeRow(String row) {
    int index = rowNames.indexOf(row);
    rowNames.removeAt(index);
    matrix.removeAt(index);
  }

  factory GLPKData.fromJson(Map<String, dynamic> data) =>
      _$GLPKDataFromJson(data);

  Map<String, dynamic> toJson() => _$GLPKDataToJson(this);
}

/// for solve_glpk(data_str and params_str)
@JsonSerializable(checked: true)
class GLPKParams {
  @JsonKey(ignore: true)
  List<TextEditingController> controllers;
  int minCoeff;
  int maxSortOrder;
  bool coeffPrio;
  int maxColNum;
  List<String> objRows;
  List<int> objNums;

  GLPKParams({
    this.minCoeff,
    this.maxSortOrder,
    this.coeffPrio,
    this.maxColNum,
    this.objRows,
    this.objNums,
  }) {
    // controllers ??= null;
    minCoeff ??= 0;
    maxSortOrder ??= 0;
    coeffPrio ??= true;
    maxColNum ??= -1;
    objRows ??= [];
    objNums ??= [];
  }

  void enableControllers() {
    assert(objRows.length == objNums.length);
    controllers?.forEach((e) => e.dispose());
    controllers?.clear();
    if (controllers?.length != objNums.length) {
      controllers = objNums
          .map((e) => TextEditingController(text: e.toString()))
          .toList();
    }
  }

  void addOne(String row, [int n = 0]) {
    if (row != null) {
      objRows.add(row);
      objNums.add(n);
      controllers?.add(TextEditingController(text: n.toString()));
    }
  }

  void remove(String obj) {
    int removeIndex = objRows.indexOf(obj);
    if (removeIndex >= 0) {
      removeAt(removeIndex);
    }
  }

  void removeAt(int index) {
    objRows.removeAt(index);
    objNums.removeAt(index);
    controllers?.removeAt(index);
  }

  void removeAll() {
    objRows.clear();
    objNums.clear();
    controllers?.forEach((e) => e.dispose());
    controllers?.clear();
  }

  GLPKParams copyWith({
    List<String> objRows,
    List<int> objNums,
    int minCoeff,
    int maxSortOrder,
    bool coeffPrio,
    int maxColNum,
  }) {
    return GLPKParams(
      objRows: objRows ?? List.from(this.objRows),
      objNums: objNums ?? List.from(this.objNums),
      minCoeff: minCoeff ?? this.minCoeff,
      maxSortOrder: maxSortOrder ?? this.maxSortOrder,
      coeffPrio: coeffPrio ?? this.coeffPrio,
      maxColNum: maxColNum ?? this.maxColNum,
    );
  }

  factory GLPKParams.fromJson(Map<String, dynamic> data) =>
      _$GLPKParamsFromJson(data);

  Map<String, dynamic> toJson() => _$GLPKParamsToJson(this);
}

@JsonSerializable()
class GLPKSolution {
  int totalEff;
  int totalNum;
  List<GLPKVariable> variables;

  GLPKSolution({this.totalEff, this.totalNum, this.variables});

  void clear() {
    totalEff = null;
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
  int coeff;
  Map<String, int> detail;

  GLPKVariable({this.name, this.value, this.coeff, this.detail});

  factory GLPKVariable.fromJson(Map<String, dynamic> data) =>
      _$GLPKVariableFromJson(data);

  Map<String, dynamic> toJson() => _$GLPKVariableToJson(this);
}
