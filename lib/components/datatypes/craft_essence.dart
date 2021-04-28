part of datatypes;

enum CraftCompare { no, rarity, atk, hp }

@JsonSerializable(checked: true)
class CraftEssence {
  int gameId;
  int no;
  String mcLink;
  String name;
  String nameJp;
  String nameEn;
  List<String> nameOther;
  int rarity;
  String icon;
  String illustration;
  List<String> illustrators;
  String? illustratorsJp;
  String? illustratorsEn;
  int cost;
  int hpMin;
  int hpMax;
  int atkMin;
  int atkMax;
  String? skillIcon;
  String skill;
  String? skillMax;
  String? skillEn;
  String? skillMaxEn;
  List<String> eventIcons;
  List<String> eventSkills;
  String? description;
  String? descriptionJp;
  String? descriptionEn;
  String category;
  String categoryText;
  List<String> characters;
  int bond;
  int valentine;

  String toString() => mcLink;

  CraftEssence({
    required this.gameId,
    required this.no,
    required this.mcLink,
    required this.name,
    required this.nameJp,
    required this.nameEn,
    required this.nameOther,
    required this.rarity,
    required this.icon,
    required this.illustration,
    required this.illustrators,
    required this.illustratorsJp,
    required this.illustratorsEn,
    required this.cost,
    required this.hpMin,
    required this.hpMax,
    required this.atkMin,
    required this.atkMax,
    required this.skillIcon,
    required this.skill,
    required this.skillMax,
    required this.skillEn,
    required this.skillMaxEn,
    required this.eventIcons,
    required this.eventSkills,
    required this.description,
    required this.descriptionJp,
    required this.descriptionEn,
    required this.category,
    required this.categoryText,
    required this.characters,
    required this.bond,
    required this.valentine,
  });

  String get localizedName => localizeNoun(name, nameJp, nameEn);

  String get localizedIllustrators =>
      localizeNoun(illustrators.join(' & '), illustratorsJp, illustratorsEn);

  String get lSkill => localizeNoun(skill, null, skillEn);

  String get lSkillMax => localizeNoun(skillMax, null, skillMaxEn);

  String get lDescription =>
      localizeNoun(description, descriptionJp, descriptionEn);

  static int compare(CraftEssence a, CraftEssence b,
      {List<CraftCompare>? keys, List<bool>? reversed}) {
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

  factory CraftEssence.fromJson(Map<String, dynamic> data) =>
      _$CraftEssenceFromJson(data);

  Map<String, dynamic> toJson() => _$CraftEssenceToJson(this);
}
