import 'package:flutter/foundation.dart';

import 'package:json_annotation/json_annotation.dart';

import 'package:chaldea/packages/logger.dart';

part '../../generated/models/gamedata/drop_rate.g.dart';

@JsonSerializable()
class DropRateData {
  final int updatedAt;
  final DropRateSheet newData;
  final DropRateSheet legacyData;

  DropRateData({
    this.updatedAt = 0,
    DropRateSheet? newData,
    DropRateSheet? legacyData,
  })  : newData = newData ?? DropRateSheet(),
        legacyData = legacyData ?? DropRateSheet();

  factory DropRateData.fromJson(Map<String, dynamic> json) =>
      _$DropRateDataFromJson(json);

  DropRateSheet getSheet(bool use6th) {
    return use6th ? newData : legacyData;
  }
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
  @JsonKey(ignore: true)
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
            itemIds.length,
            (i) => List.generate(
                questIds.length, (j) => (sparseMatrix[i]?[j] ?? 0) / 100));

  factory DropRateSheet.fromJson(Map<String, dynamic> json) =>
      _$DropRateSheetFromJson(json);

  DropRateSheet copy() {
    return DropRateSheet(
      questIds: List.of(questIds),
      itemIds: List.of(itemIds),
      apCosts: List.of(apCosts),
      runs: List.of(runs),
      bonds: List.of(bonds),
      exps: List.of(exps),
      sparseMatrix:
          sparseMatrix.map((key, value) => MapEntry(key, Map.of(value))),
    )..matrix = List.generate(matrix.length,
        (i) => List.generate(matrix[i].length, (j) => matrix[i][j]));
  }

  Map<int, double> getQuestDropRate(int questId) {
    int questIndex = questIds.indexOf(questId);
    if (questIndex < 0) return {};
    return {
      for (int itemIndex = 0; itemIndex < itemIds.length; itemIndex++)
        if (matrix[itemIndex][questIndex] > 0)
          itemIds[itemIndex]: matrix[itemIndex][questIndex]
    };
  }

  Map<int, double> getQuestApRate(int questId) {
    int questIndex = questIds.indexOf(questId);
    return getQuestDropRate(questId)
        .map((key, value) => MapEntry(key, apCosts[questIndex] / value));
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
}
