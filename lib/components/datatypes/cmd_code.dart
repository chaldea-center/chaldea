part of datatypes;

enum CmdCodeCompare { no, rarity }

@JsonSerializable(checked: true)
class CommandCode {
  int no;
  String mcLink;
  String name;
  String nameJp;
  List<String> nameOther;
  int rarity;
  String icon;
  String illustration;
  List<String> illustrators;
  String skillIcon;
  String skill;
  String? description;
  String? descriptionJp;
  String obtain;
  String category;
  String categoryText;
  List<String> characters;

  CommandCode({
    required this.no,
    required this.mcLink,
    required this.name,
    required this.nameJp,
    this.nameOther = const [],
    required this.rarity,
    required this.icon,
    required this.illustration,
    this.illustrators = const [],
    required this.skillIcon,
    required this.skill,
    this.description,
    this.descriptionJp,
    required this.obtain,
    required this.category,
    required this.categoryText,
    this.characters = const [],
  });

  String get localizedName => localizeNoun(name, nameJp, null);

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
