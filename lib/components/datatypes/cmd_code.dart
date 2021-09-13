part of datatypes;

enum CmdCodeCompare { no, rarity }

@JsonSerializable(checked: true)
class CommandCode with GameCardMixin {
  int gameId;
  @override
  int no;
  @override
  String mcLink;
  String name;
  String nameJp;
  String nameEn;
  List<String> nameOther;
  int rarity;
  @override
  String icon;
  String illustration;
  List<String> illustrators;
  String? illustratorsJp;
  String? illustratorsEn;
  String skillIcon;
  String skill;
  String? skillEn;

  String? get skillJp => niceSkills.getOrNull(0)?.detail;
  String? description;
  String? descriptionJp;
  String? descriptionEn;
  String obtain;
  String category;
  String categoryText;
  List<String> characters;
  List<NiceSkill> niceSkills;

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
    required this.niceSkills,
  });

  @override
  String get lName => localizeNoun(name, nameJp, nameEn);

  String get lIllustrators =>
      localizeNoun(illustrators.join(' & '), illustratorsJp, illustratorsEn);

  String get lSkill => localizeNoun(skill, skillJp, skillEn);

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

  @override
  Widget iconBuilder({
    required BuildContext context,
    double? width,
    double? height,
    double? aspectRatio = 132 / 144,
    String? text,
    EdgeInsets? padding,
    EdgeInsets? textPadding,
    VoidCallback? onTap,
    bool jumpToDetail = true,
    bool popDetail = false,
  }) {
    return super.iconBuilder(
      context: context,
      width: width,
      height: height,
      aspectRatio: aspectRatio,
      text: text,
      padding: padding,
      textPadding: textPadding,
      onTap: onTap ??
          (jumpToDetail
              ? () => SplitRoute.push(context, CmdCodeDetailPage(code: this),
                  popDetail: popDetail)
              : null),
    );
  }

  factory CommandCode.fromJson(Map<String, dynamic> data) =>
      _$CommandCodeFromJson(data);

  Map<String, dynamic> toJson() => _$CommandCodeToJson(this);
}
