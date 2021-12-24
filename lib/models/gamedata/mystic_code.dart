part of gamedata;

@JsonSerializable()
class MCAssets {
  String male;
  String female;

  MCAssets({
    required this.male,
    required this.female,
  });

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
class MysticCode {
  int id;
  String name;
  String detail;
  ExtraMCAssets extraAssets;
  List<NiceSkill> skills;
  List<int> expRequired;

  MysticCode({
    required this.id,
    required this.name,
    required this.detail,
    required this.extraAssets,
    required this.skills,
    required this.expRequired,
  });

  factory MysticCode.fromJson(Map<String, dynamic> json) =>
      _$MysticCodeFromJson(json);
}
