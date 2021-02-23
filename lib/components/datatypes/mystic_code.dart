//@dart=2.9
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
    this.name,
    this.nameJp,
    this.description,
    this.descriptionJp,
    this.icon1,
    this.icon2,
    this.image1,
    this.image2,
    this.obtains,
    this.expPoints,
    this.skills,
  });

  String get localizedName => localizeNoun(name, nameJp, null);

  factory MysticCode.fromJson(Map<String, dynamic> data) =>
      _$MysticCodeFromJson(data);

  Map<String, dynamic> toJson() => _$MysticCodeToJson(this);
}
