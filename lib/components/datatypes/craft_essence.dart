part of datatypes;

enum CraftCompare { no, rarity, atk, hp }

@JsonSerializable(checked: true)
class CraftEssence with GameCardMixin {
  int gameId;
  @override
  int no;
  @override
  String mcLink;
  String name;
  String nameJp;
  String nameEn;
  List<String> nameOther;
  @override
  int rarity;
  @override
  String icon;
  String illustration;
  List<String> illustrators;

  /// TODO: make list
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
  List<NiceSkill> niceSkills;

  String? get skillJp => niceSkills.getOrNull(0)?.detail;

  String? get skillMaxJp => niceSkills.getOrNull(0)?.detail;

  @override
  String toString() => '$runtimeType($no, $mcLink)';

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
    this.bond = -1,
    this.valentine = -1,
    required this.niceSkills,
  });

  @override
  String get lName => localizeNoun(name, nameJp, nameEn);

  String get lIllustrators =>
      localizeNoun(illustrators.join(', '), illustratorsJp, illustratorsEn);

  String get lSkill => localizeNoun(skill, skillJp, skillEn);

  String get lSkillMax => localizeNoun(skillMax, skillMaxJp, skillMaxEn);

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
              ? () => SplitRoute.push(context, CraftDetailPage(ce: this),
                  popDetail: popDetail)
              : null),
    );
  }

  factory CraftEssence.fromJson(Map<String, dynamic> data) =>
      _$CraftEssenceFromJson(data);

  Map<String, dynamic> toJson() => _$CraftEssenceToJson(this);
}
