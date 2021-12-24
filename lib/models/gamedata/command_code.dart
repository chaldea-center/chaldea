part of gamedata;

@JsonSerializable()
class CommandCode {
  int id;
  int collectionNo;
  String name;
  int rarity;
  ExtraCCAssets extraAssets;
  List<NiceSkill> skills;
  String illustrator;
  String comment;

  CommandCode({
    required this.id,
    required this.collectionNo,
    required this.name,
    required this.rarity,
    required this.extraAssets,
    required this.skills,
    required this.illustrator,
    required this.comment,
  });

  factory CommandCode.fromJson(Map<String, dynamic> json) =>
      _$CommandCodeFromJson(json);
}
