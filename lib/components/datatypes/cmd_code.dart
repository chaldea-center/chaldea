part of datatypes;

enum CmdCodeCompare { no, rarity }

@JsonSerializable(checked: true)
class CommandCode {
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
  String skillIcon;
  String skill;
  String skillEn;
  String? description;
  String? descriptionJp;
  String? descriptionEn;
  String obtain;
  String category;
  String categoryText;
  List<String> characters;

  CommandCode({
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
    required this.skillIcon,
    required this.skill,
    required this.skillEn,
    required this.description,
    required this.descriptionJp,
    required this.descriptionEn,
    required this.obtain,
    required this.category,
    required this.categoryText,
    required this.characters,
  });

  String get localizedName => localizeNoun(name, nameJp, nameEn);

  String get lIllustrators =>
      localizeNoun(illustrators.join(' & '), illustratorsJp, illustratorsEn);

  String get lSkill => localizeNoun(skill, null, skillEn);

  String get lDescription =>
      localizeNoun(description, descriptionJp, descriptionEn);

  static int compare(CommandCode a, CommandCode b,
      {List<CmdCodeCompare>? keys, List<bool>? reversed}) {
    int res = 0;
    if (keys == null || keys.isEmpty) {
      keys = [CmdCodeCompare.no];
    }
    for (var i = 0; i < keys.length; i++) {
      int r;
      switch (keys[i]) {
        case CmdCodeCompare.no:
          r = a.no - b.no;
          break;
        case CmdCodeCompare.rarity:
          r = a.rarity - b.rarity;
          break;
      }
      res = res * 1000 + ((reversed?.elementAt(i) ?? false) ? -r : r);
    }
    return res;
  }

  factory CommandCode.fromJson(Map<String, dynamic> data) =>
      _$CommandCodeFromJson(data);

  Map<String, dynamic> toJson() => _$CommandCodeToJson(this);
}
