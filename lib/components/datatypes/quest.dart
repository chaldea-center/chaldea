part of datatypes;

@JsonSerializable(checked: true)
class Quest {
  String chapter;
  String name;
  String nameJp;

  /// one place one quest: use place as key
  /// one place two quests: place（name）
  /// daily quests: name
  String indexKey;
  int level;
  int bondPoint;
  int experience;
  int qp;
  bool isFree;
  bool hasChoice;
  List<Battle> battles;
  Map<String, int> rewards;
  String enhancement;
  String conditions;

  Quest({
    this.chapter,
    this.name,
    this.nameJp,
    this.indexKey,
    this.level,
    this.bondPoint,
    this.experience,
    this.qp,
    this.isFree,
    this.hasChoice,
    this.battles,
    this.rewards,
    this.enhancement,
    this.conditions,
  });

  String  localizedKey(String key){
    if (key == place) {
      return localizedPlace;
    } else {
      return '$localizedPlace ($localizedName)';
    }
  }

  String get localizedName => localizeNoun(name, nameJp, null);

  String get localizedPlace => localizeNoun(place, placeJp, null);

  String get placeJp => getListItem(battles, 0)?.placeJp;

  String get place => getListItem(battles, 0)?.place;

  factory Quest.fromJson(Map<String, dynamic> data) => _$QuestFromJson(data);

  Map<String, dynamic> toJson() => _$QuestToJson(this);
}

@JsonSerializable(checked: true)
class Battle {
  int ap;
  String place;
  String placeJp;
  List<List<Enemy>> enemies; // wave_num*enemy_num
  Map<String, int> drops;

  Battle({this.ap, this.place, this.placeJp, this.enemies, this.drops});

  factory Battle.fromJson(Map<String, dynamic> data) => _$BattleFromJson(data);

  Map<String, dynamic> toJson() => _$BattleToJson(this);
}

@JsonSerializable(checked: true)
class Enemy {
  List<String> name;
  List<String> shownName;
  List<String> className;
  List<int> rank;
  List<int> hp;

  Enemy({this.name, this.shownName, this.className, this.rank, this.hp});

  factory Enemy.fromJson(Map<String, dynamic> data) => _$EnemyFromJson(data);

  Map<String, dynamic> toJson() => _$EnemyToJson(this);
}
