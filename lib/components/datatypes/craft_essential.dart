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
  String skillMax;
  List<String> eventIcons;
  List<String> eventSkills;
  String description;
  String descriptionJp;
  int category;
  List<String> characters;
  int bond;
  int valentine;

  CraftEssential({
    this.no,
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
    this.skillMax,
    this.eventIcons,
    this.eventSkills,
    this.description,
    this.descriptionJp,
    this.category,
    this.characters,
    this.bond,
    this.valentine,
  });

  static int compare(CraftEssential a, CraftEssential b,
      [List<CraftCompare> keys, List<bool> reversed]) {
    int res = 0;
    if (keys == null || keys.isEmpty) {
      keys = [CraftCompare.no];
    }
    for (var i = 0; i < keys.length; i++) {
      int r;
      switch (keys[i]) {
        case CraftCompare.no:
          r = a.no - b.no;
          break;
        case CraftCompare.rarity:
          r = a.rarity - b.rarity;
          break;
        case CraftCompare.atk:
          r = a.atkMax - b.atkMax;
          break;
        case CraftCompare.hp:
          r = a.hpMax - b.hpMax;
          break;
      }
      res = res * 1000 + ((reversed?.elementAt(i) ?? false) ? -r : r);
    }
    return res;
  }

  factory CraftEssential.fromJson(Map<String, dynamic> data) =>
      _$CraftEssentialFromJson(data);

  Map<String, dynamic> toJson() => _$CraftEssentialToJson(this);
}

enum CraftCompare { no, rarity, atk, hp }
