part of datatypes;

@JsonSerializable(checked: true)
class Quest {
  String chapter;
  String name;
  String? nameJp;
  String? nameEn;

  /// one place one quest: use place as key
  /// one place two quests: place（name）
  /// daily quests: name
  String? indexKey;
  int level;
  int bondPoint;
  int experience;
  int qp;
  bool isFree;
  bool hasChoice;
  List<Battle> battles;
  Map<String, int> rewards;
  String? enhancement;
  String? conditions;

  Quest({
    required this.chapter,
    required this.name,
    required this.nameEn,
    required this.nameJp,
    required this.indexKey,
    required this.level,
    required this.bondPoint,
    required this.experience,
    required this.qp,
    required this.isFree,
    required this.hasChoice,
    required this.battles,
    required this.rewards,
    required this.enhancement,
    required this.conditions,
  });

  /// [key] is [indexKey] which is used as map key
  String get localizedKey {
    if (indexKey == place) {
      return localizedPlace;
    } else if (chapter.contains('每日任务')) {
      return localizedName;
    } else {
      return '$localizedPlace ($localizedName)';
    }
  }

  String get localizedName => localizeNoun(name, nameJp, nameEn);

  String get localizedPlace => localizeNoun(place, placeJp, placeEn);

  String? get place => battles.getOrNull(0)?.place;

  String? get placeJp => battles.getOrNull(0)?.placeJp;

  String? get placeEn => battles.getOrNull(0)?.placeEn;

  static String shortChapterOf(String chapter) {
    if (Language.isEN) {
      return Localized.chapter.of(chapter).split(':').first;
    }
    if (chapter.contains('每日任务')) {
      return '每日任务';
    } else if (chapter.contains('特异点')) {
      // 第一部
      return chapter.split(' ').last;
    } else if (chapter.toLowerCase().contains('lostbelt')) {
      return chapter.split(' ')[2];
    } else {
      return chapter.split(' ')[0];
    }
  }

  factory Quest.fromJson(Map<String, dynamic> data) => _$QuestFromJson(data);

  Map<String, dynamic> toJson() => _$QuestToJson(this);
}

@JsonSerializable(checked: true)
class Battle {
  int ap;
  String? place;
  String? placeJp;
  String? placeEn;
  List<List<Enemy>> enemies; // wave_num*enemy_num
  Map<String, int> drops;

  Battle({
    required this.ap,
    required this.place,
    required this.placeJp,
    required this.placeEn,
    required this.enemies,
    required this.drops,
  });

  factory Battle.fromJson(Map<String, dynamic> data) => _$BattleFromJson(data);

  Map<String, dynamic> toJson() => _$BattleToJson(this);
}

@JsonSerializable(checked: true)
class Enemy {
  List<String> name;
  List<String?> shownName;
  List<String> className;
  List<int> rank;
  List<int> hp;

  Enemy({
    required this.name,
    required this.shownName,
    required this.className,
    required this.rank,
    required this.hp,
  });

  factory Enemy.fromJson(Map<String, dynamic> data) => _$EnemyFromJson(data);

  Map<String, dynamic> toJson() => _$EnemyToJson(this);
}
