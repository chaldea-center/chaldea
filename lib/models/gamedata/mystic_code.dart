import 'package:chaldea/app/routes/routes.dart';
import 'package:json_annotation/json_annotation.dart';

import '../db.dart';
import 'game_card.dart';
import 'mappings.dart';
import 'skill.dart';

part '../../generated/models/gamedata/mystic_code.g.dart';

@JsonSerializable()
class MysticCode with GameCardMixin {
  @override
  int id;
  @override
  String name;
  String detail;
  ExtraMCAssets extraAssets;
  List<NiceSkill> skills;
  List<int> expRequired;
  List<MysticCodeCostume> costumes;

  MysticCode({
    required this.id,
    required this.name,
    required this.detail,
    required this.extraAssets,
    required this.skills,
    required this.expRequired,
    this.costumes = const [],
  });

  factory MysticCode.fromJson(Map<String, dynamic> json) =>
      _$MysticCodeFromJson(json);

  @override
  int get collectionNo => throw UnimplementedError();

  @override
  String? get icon => extraAssets.item.masterGender;

  @override
  String? get borderedIcon => icon;

  @override
  int get rarity => throw UnimplementedError();

  @override
  Transl<String, String> get lName => Transl.mcNames(name);

  String get route => Routes.mysticCodeI(id);

  @override
  void routeTo() => routeToId(Routes.mysticCode);
}

@JsonSerializable()
class MCAssets {
  String male;
  String female;

  MCAssets({
    required this.male,
    required this.female,
  });

  String get masterGender => db2.curUser.isGirl ? female : male;

  factory MCAssets.fromJson(Map<String, dynamic> json) =>
      _$MCAssetsFromJson(json);
}

@JsonSerializable()
class ExtraMCAssets {
  MCAssets item;
  MCAssets masterFace;
  MCAssets masterFigure;

  ExtraMCAssets({
    required this.item,
    required this.masterFace,
    required this.masterFigure,
  });

  factory ExtraMCAssets.fromJson(Map<String, dynamic> json) =>
      _$ExtraMCAssetsFromJson(json);
}

@JsonSerializable()
class MysticCodeCostume {
  int id;
  List<CommonRelease> releaseConditions;
  ExtraMCAssets extraAssets;

  MysticCodeCostume({
    required this.id,
    this.releaseConditions = const [],
    required this.extraAssets,
  });

  factory MysticCodeCostume.fromJson(Map<String, dynamic> json) =>
      _$MysticCodeCostumeFromJson(json);
}
