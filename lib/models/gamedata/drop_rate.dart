import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part '../../generated/models/gamedata/drop_rate.g.dart';

@JsonSerializable()
class DropRateData {
  final DropRateSheet newData;
  final DropRateSheet legacyData;

  DropRateData({
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
  final List<int> questIds; // n
  final List<int> itemIds; // m
  final List<int> apCosts;
  final List<int> runs;

  /// drop rate, not ap rate
  @protected
  final Map<int, Map<int, double>> sparseMatrix;
  @JsonKey(ignore: true)
  List<List<double>> matrix; // m*n

  DropRateSheet({
    this.questIds = const [],
    this.itemIds = const [],
    this.apCosts = const [],
    this.runs = const [],
    this.sparseMatrix = const {},
  }) : matrix = List.generate(
            itemIds.length,
            (i) => List.generate(
                questIds.length, (j) => sparseMatrix[i]?[j] ?? 0));

  factory DropRateSheet.fromJson(Map<String, dynamic> json) =>
      _$DropRateSheetFromJson(json);
}
