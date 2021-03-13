part of datatypes;

@JsonSerializable(checked: true)
class MysticCode {
  String name;
  String nameJp;
  String description;
  String descriptionJp;
  String icon1;
  String icon2;
  String image1;
  String image2;
  List<String> obtains;
  List<int> expPoints;

  /// skill only contains name/icon/cd/effects
  List<Skill> skills;

  MysticCode({
    required this.name,
    required this.nameJp,
    required this.description,
    required this.descriptionJp,
    required this.icon1,
    required this.icon2,
    required this.image1,
    required this.image2,
    required this.obtains,
    required this.expPoints,
    required this.skills,
  });

  String get localizedName => localizeNoun(name, nameJp, null);

  factory MysticCode.fromJson(Map<String, dynamic> data) =>
      _$MysticCodeFromJson(data);

  Map<String, dynamic> toJson() => _$MysticCodeToJson(this);
}
