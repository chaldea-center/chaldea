part of datatypes;

@JsonSerializable(checked: true)
class CommandCode {
  int no;
  int rarity;
  String name;
  String nameJp;
  String mcLink;
  String icon;
  String illust;
  List<String> illustrators;
  String skillIcon;
  String skill;
  String description;
  String descriptionJp;
  String obtain;
  List<String> characters;

  CommandCode({
    this.no,
    this.rarity,
    this.name,
    this.nameJp,
    this.mcLink,
    this.icon,
    this.illust,
    this.illustrators,
    this.skillIcon,
    this.skill,
    this.description,
    this.descriptionJp,
    this.obtain,
    this.characters,
  });

  static int compare(CommandCode a, CommandCode b,
      [List<CmdCodeCompare> keys, List<bool> reversed]) {
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

enum CmdCodeCompare { no, rarity }
