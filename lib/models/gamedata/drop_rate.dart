import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part '../../generated/models/gamedata/drop_rate.g.dart';

@JsonSerializable()
class DropRateData {
  final DropRateSheet newData;
  final DropRateSheet legacyData;

  DropRateData({
    this.newData = const DropRateSheet(),
    this.legacyData = const DropRateSheet(),
  });

  factory DropRateData.fromJson(Map<String, dynamic> json) =>
      _$DropRateDataFromJson(json);
}

@JsonSerializable()
class DropRateSheet {
  final List<int> questIds;
  final List<int> itemIds;
  final List<int> apCosts;
  final List<int> runs;

  /// drop rate, not ap rate
  @protected
  final Map<int, Map<int, double>> sparseMatrix;

  const DropRateSheet({
    this.questIds = const [],
    this.itemIds = const [],
    this.apCosts = const [],
    this.runs = const [],
    this.sparseMatrix = const {},
  });

  factory DropRateSheet.fromJson(Map<String, dynamic> json) =>
      _$DropRateSheetFromJson(json);
}
