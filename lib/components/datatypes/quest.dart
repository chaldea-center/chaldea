part of datatypes;

@JsonSerializable(checked: true)
class Quest {
  String chapter;
  String nameJp;
  String nameCn;
  int level;
  int bondPoint;
  int experience;
  int qp;
  List<Battle> battles;

  String get placeJp => getValueInList(battles, 0)?.placeJp;

  String get placeCn => getValueInList(battles, 0)?.placeCn;

  Quest(
      {this.chapter,
      this.nameJp,
      this.nameCn,
      this.level,
      this.bondPoint,
      this.experience,
      this.qp,
      this.battles});

  factory Quest.fromJson(Map<String, dynamic> data) => _$QuestFromJson(data);

  Map<String, dynamic> toJson() => _$QuestToJson(this);
}

@JsonSerializable(checked: true)
class Battle {
  int ap;
  String placeJp;
  String placeCn;

  /// wave_num*enemy_num
  List<List<Enemy>> enemies;

  Battle({this.ap, this.placeJp, this.placeCn, this.enemies});

  factory Battle.fromJson(Map<String, dynamic> data) => _$BattleFromJson(data);

  Map<String, dynamic> toJson() => _$BattleToJson(this);
}

@JsonSerializable(checked: true)
class Enemy {
  String name;
  String shownName;
  String className;
  int rank;

  Enemy({this.name, this.shownName, this.className, this.rank, this.hp});

  int hp;

  factory Enemy.fromJson(Map<String, dynamic> data) => _$EnemyFromJson(data);

  Map<String, dynamic> toJson() => _$EnemyToJson(this);
}
