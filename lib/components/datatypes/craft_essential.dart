part of datatypes;

@JsonSerializable()
class CraftEssential {
  int no;
  int rarity;
  String name;
  String nameJp;
  String mcLink;
  String icon;
  String illust;
  List<String> illustrator;
  int cost;
  int hpMin;
  int hpMax;
  int atkMin;
  int atkMax;
  String skillIcon;
  String skill;
  List<String> eventIcons;
  List<String> eventSkills;
  String description;
  String descriptionJp;
  int category;
  List<String> characters;
  int bond;
  int valentine;

  CraftEssential(
      {this.no,
      this.rarity,
      this.name,
      this.nameJp,
      this.mcLink,
      this.icon,
      this.illust,
      this.illustrator,
      this.cost,
      this.hpMin,
      this.hpMax,
      this.atkMin,
      this.atkMax,
      this.skillIcon,
      this.skill,
      this.eventIcons,
      this.eventSkills,
      this.description,
      this.descriptionJp,
      this.category,
      this.characters,
      this.bond,
      this.valentine});

  factory CraftEssential.fromJson(Map<String, dynamic> data) =>
      _$CraftEssentialFromJson(data);

  Map<String, dynamic> toJson() => _$CraftEssentialToJson(this);
}
