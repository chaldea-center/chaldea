part of datatypes;

@JsonSerializable(checked: true)
class MysticCode {
  String name;
  String nameJp;
  String? nameEn;
  String description;
  String descriptionJp;
  String? descriptionEn;
  String icon1;
  String icon2;
  String image1;
  String image2;
  List<String> obtains;
  List<String>? obtainsEn;
  List<int> expPoints;

  /// skill only contains name/icon/cd/effects
  List<Skill> skills;

  MysticCode({
    required this.name,
    required this.nameJp,
    required this.nameEn,
    required this.description,
    required this.descriptionJp,
    required this.descriptionEn,
    required this.icon1,
    required this.icon2,
    required this.image1,
    required this.image2,
    required this.obtains,
    required this.obtainsEn,
    required this.expPoints,
    required this.skills,
  });

  String get localizedName => localizeNoun(name, nameJp, nameEn);

  String get lDescription =>
      localizeNoun(description, descriptionJp, descriptionEn);

  List<String> get lObtains => localizeNoun(obtains, null, obtainsEn);

  factory MysticCode.fromJson(Map<String, dynamic> data) =>
      _$MysticCodeFromJson(data);

  Map<String, dynamic> toJson() => _$MysticCodeToJson(this);
}
