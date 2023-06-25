import 'package:chaldea/packages/logger.dart';
import '../db.dart';
import '_helper.dart';

part '../../generated/models/gamedata/drop_rate.g.dart';

@JsonSerializable()
class DropData {
  int domusVer;
  DropRateSheet domusAurea;
  // key=questId*100+phase
  Map<int, QuestDropData> fixedDrops; // one-off quest
  @protected
  final Map<int, QuestDropData> freeDrops; // event free quest
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<int, QuestDropData> freeDrops2;

  DropData({
    this.domusVer = 0,
    DropRateSheet? domusAurea,
    this.fixedDrops = const {},
    this.freeDrops = const {},
  })  : domusAurea = domusAurea ?? DropRateSheet(),
        freeDrops2 = freeDrops.map((key, value) => MapEntry(key ~/ 100, value));

  factory DropData.fromJson(Map<String, dynamic> json) => _$DropDataFromJson(json);

  Map<String, dynamic> toJson() => _$DropDataToJson(this);
}

@JsonSerializable()
class DropRateSheet {
  final List<int> itemIds; // m
  final List<int> questIds; // n
  final List<int> apCosts;
  final List<int> runs;
  final List<int> bonds;
  final List<int> exps;

  /// drop rate, not ap rate
  @protected
  final Map<int, Map<int, double>> sparseMatrix;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<List<double>> matrix; // m*n

  DropRateSheet({
    this.itemIds = const [],
    this.questIds = const [],
    this.apCosts = const [],
    this.runs = const [],
    this.bonds = const [],
    this.exps = const [],
    this.sparseMatrix = const {},
  }) : matrix = List.generate(
            itemIds.length, (i) => List.generate(questIds.length, (j) => (sparseMatrix[i]?[j] ?? 0) / 100));

  DropRateSheet copy() {
    return DropRateSheet(
      questIds: List.of(questIds),
      itemIds: List.of(itemIds),
      apCosts: List.of(apCosts),
      runs: List.of(runs),
      bonds: List.of(bonds),
      exps: List.of(exps),
      sparseMatrix: sparseMatrix.map((key, value) => MapEntry(key, Map.of(value))),
    )..matrix = List.generate(matrix.length, (i) => List.generate(matrix[i].length, (j) => matrix[i][j]));
  }

  int getQuestRuns(int questId) {
    int questIndex = questIds.indexOf(questId);
    if (questIndex < 0) return 0;
    return runs[questIndex];
  }

  Map<int, double> getQuestDropRate(int questId) {
    int questIndex = questIds.indexOf(questId);
    if (questIndex < 0) return {};
    return {
      for (int itemIndex = 0; itemIndex < itemIds.length; itemIndex++)
        if (matrix[itemIndex][questIndex] > 0) itemIds[itemIndex]: matrix[itemIndex][questIndex]
    };
  }

  Map<int, double> getQuestApRate(int questId) {
    final ap = db.gameData.quests[questId]?.consume ?? apCosts[questIds.indexOf(questId)];
    return getQuestDropRate(questId).map((key, value) => MapEntry(key, ap / value));
  }

  /// DON'T call the following methods on original data
  void removeRow(int itemId) {
    int index = itemIds.indexOf(itemId);
    if (index >= 0) removeRowAt(index);
  }

  void removeRowAt(int index) {
    assert(index >= 0 && index < itemIds.length);
    itemIds.removeAt(index);
    matrix.removeAt(index);
  }

  void removeCol(int questId) {
    int index = questIds.indexOf(questId);
    if (index >= 0) {
      removeColAt(index);
    } else {
      logger.w('GLPKData has no such column to remove: "$questId"');
    }
  }

  void removeColAt(int index) {
    assert(index >= 0 && index < questIds.length);
    questIds.removeAt(index);
    apCosts.removeAt(index);
    runs.removeAt(index);
    bonds.removeAt(index);
    exps.removeAt(index);
    matrix.forEach((row) => row.removeAt(index));
  }

  factory DropRateSheet.fromJson(Map<String, dynamic> json) => _$DropRateSheetFromJson(json);

  Map<String, dynamic> toJson() => _$DropRateSheetToJson(this);
}

@JsonSerializable()
class QuestDropData {
  int runs;
  // itemId: dropCount=num*count
  Map<int, int> items;
  Map<int, int> groups; // default 1

  QuestDropData({
    this.runs = 0,
    this.items = const {},
    this.groups = const {},
  });

  double getBase(int itemId) => (items[itemId] ?? 0) / runs;

  double getGroup(int itemId) {
    if ((items[itemId] ?? 0) <= 0) return 0;
    return groups.containsKey(itemId) ? groups[itemId]! / runs : 1;
  }

  factory QuestDropData.fromJson(Map<String, dynamic> json) => _$QuestDropDataFromJson(json);

  Map<String, dynamic> toJson() => _$QuestDropDataToJson(this);
}
