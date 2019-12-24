part of datatypes;

@JsonSerializable()
class GLPKData {
  List<String> colNames;
  List<String> rowNames;
  List<num> coeff;
  List<List<num>> matrix;
  int cnMaxColNum;

  GLPKData({
    this.colNames,
    this.rowNames,
    this.coeff,
    this.matrix,
    this.cnMaxColNum,
  });

  factory GLPKData.fromJson(Map<String, dynamic> data) =>
      _$GLPKDataFromJson(data);

  Map<String, dynamic> toJson() => _$GLPKDataToJson(this);
}

/// for solve_glpk(data_str and params_str)
@JsonSerializable()
class GLPKParams {
  @JsonKey(ignore: true)
  List<TextEditingController> controllers;
  List<String> objRows;
  List<int> objNums;
  int minCoeff;
  int maxSortOrder;
  bool coeffPrio;
  int maxColNum;

  GLPKParams({
    this.objRows,
    this.objNums,
    this.minCoeff,
    this.maxSortOrder,
    this.coeffPrio,
    this.maxColNum,
  }) {
    objRows ??= [];
    objNums ??= [];
    minCoeff ??= 0;
    //  maxSortOrder ??= null; // js Infinity
    coeffPrio ??= true;
    maxColNum ??= -1;
    // controllers ??= null;
  }

  void enableControllers() {
    if (controllers?.length != objNums.length) {
      controllers = objNums
          .map((e) => TextEditingController(text: e.toString()))
          .toList();
    }
  }

  void addOne(String row, [int n = 0]) {
    objRows.add(row);
    objNums.add(n);
    controllers?.add(TextEditingController(text: n.toString()));
  }

  void removeAt(int index) {
    objRows.removeAt(index);
    objNums.removeAt(index);
    controllers?.removeAt(index);
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
