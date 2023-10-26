import 'package:chaldea/app/routes/routes.dart';
import '../db.dart';
import '_helper.dart';
import 'common.dart';
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

  factory MysticCode.fromJson(Map<String, dynamic> json) => _$MysticCodeFromJson(json);

  @override
  int get collectionNo => id;

  @override
  String? get icon => extraAssets.item.masterGender;

  @override
  String? get borderedIcon => icon;

  @override
  @Deprecated("Mystic Code doesn't have rarity")
  int get rarity => 5;

  @override
  Transl<String, String> get lName => Transl.mcNames(name);

  @override
  String get route => Routes.mysticCodeI(id);

  Map<String, dynamic> toJson() => _$MysticCodeToJson(this);
}

@JsonSerializable()
class MCAssets {
  String male;
  String female;

  MCAssets({
    required this.male,
    required this.female,
  });

  String get masterGender => db.curUser.isGirl ? female : male;

  factory MCAssets.fromJson(Map<String, dynamic> json) => _$MCAssetsFromJson(json);

  Map<String, dynamic> toJson() => _$MCAssetsToJson(this);
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

  factory ExtraMCAssets.fromJson(Map<String, dynamic> json) => _$ExtraMCAssetsFromJson(json);

  Map<String, dynamic> toJson() => _$ExtraMCAssetsToJson(this);
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

  factory MysticCodeCostume.fromJson(Map<String, dynamic> json) => _$MysticCodeCostumeFromJson(json);

  Map<String, dynamic> toJson() => _$MysticCodeCostumeToJson(this);
}
