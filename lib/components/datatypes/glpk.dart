part of datatypes;

@JsonSerializable()
class GLPKData {
  List<String> colNames;
  List<String> rowNames;
  List<num> coeff;
  List<List<num>> matrix;
  List<int> ia;
  List<int> ja;
  List<num> ar;

  GLPKData({
    this.colNames,
    this.rowNames,
    this.coeff,
    this.matrix,
    this.ia,
    this.ja,
    this.ar,
  });

  factory GLPKData.fromJson(Map<String, dynamic> data) =>
      _$GLPKDataFromJson(data);

  Map<String, dynamic> toJson() => _$GLPKDataToJson(this);
}

/// for data_str and params_str
@JsonSerializable()
class GLPKParams {
  List<String> objRows;
  List<int> objNums;
  int minCoeff;
  int maxSortOrder;
  bool coeffPrio;
  bool useCn;
  @JsonKey(ignore: true)
  List<TextEditingController> controllers;

  GLPKParams({
    this.objRows,
    this.objNums,
    this.minCoeff,
    this.maxSortOrder,
    this.coeffPrio,
    this.useCn,
  }) {
    objRows ??= [];
    objNums ??= [];
    controllers =
        objNums.map((e) => TextEditingController(text: e.toString())).toList();
    // minCoeff ??= 0;
    //  maxSortOrder??=null;// Infinity
    // coeffPrio ??= true;
    // useCn ??= false;
  }

  void addOne(String row, [int n = 0]) {
    objRows.add(row);
    objNums.add(n);
    controllers.add(TextEditingController(text: n.toString()));
  }

  void removeAt(int index) {
    objRows.removeAt(index);
    objNums.removeAt(index);
    controllers.removeAt(index);
  }

  factory GLPKParams.fromJson(Map<String, dynamic> data) =>
      _$GLPKParamsFromJson(data);

  Map<String, dynamic> toJson() => _$GLPKParamsToJson(this);
}

/// TODO: for one X_i: place key, value(num), cost(ap), items map<item key, num>
@JsonSerializable()
class GLPKSolution {
  int totalEff;
  int totalNum;
  List<String> solutionKeys; // quest_name
  List<int> solutionValues;

  factory GLPKSolution.fromJson(Map<String, dynamic> data) =>
      _$GLPKSolutionFromJson(data);

  GLPKSolution({
    this.totalEff,
    this.totalNum,
    this.solutionKeys,
    this.solutionValues,
  });

  void clear() {
    totalEff = null;
    totalNum = null;
    solutionKeys.clear();
    solutionValues.clear();
  }

  void sortByValue() {
    Map<String, int> dict = {};
    for (var i = 0; i < solutionKeys.length; i++) {
      dict[solutionKeys[i]] = solutionValues[i];
    }
    solutionKeys.sort((a, b) {
      return -(dict[a] - dict[b]);
    });
    solutionValues = solutionKeys.map((e) => dict[e]).toList();
  }

  Map<String, dynamic> toJson() => _$GLPKSolutionToJson(this);
}
