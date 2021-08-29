part of datatypes;

@JsonSerializable(checked: true)
class EnemyDetail {
  String category;
  String? icon;
  String id;
  String name;
  List<String> classIcons;
  String attribute;
  List<String> traits;
  int? actions;
  List<int> charges;
  String? deathRate;
  String noblePhantasm;
  String skill;
  List<int> hitsCommon;
  List<int> hitsCritical;
  List<int> hitsNp;
  String firstStage;

  EnemyDetail({
    required this.category,
    required this.icon,
    required this.id,
    required this.name,
    required this.classIcons,
    required this.attribute,
    required this.traits,
    required this.actions,
    required this.charges,
    required this.deathRate,
    required this.noblePhantasm,
    required this.skill,
    required this.hitsCommon,
    required this.hitsCritical,
    required this.hitsNp,
    required this.firstStage,
  });

  factory EnemyDetail.fromJson(Map<String, dynamic> data) =>
      _$EnemyDetailFromJson(data);

  Map<String, dynamic> toJson() => _$EnemyDetailToJson(this);
}
