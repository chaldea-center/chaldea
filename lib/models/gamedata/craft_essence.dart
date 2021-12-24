part of gamedata;

@JsonSerializable()
class CraftEssence {
  int id;
  int collectionNo;
  String name;
  SvtType type;
  SvtFlag flag;
  int rarity;
  int cost;
  int lvMax;
  ExtraAssets extraAssets;
  int atkBase;
  int atkMax;
  int hpBase;
  int hpMax;
  int growthCurve;
  List<int> atkGrowth;
  List<int> hpGrowth;
  List<int> expGrowth;
  List<int> expFeed;
  int? bondEquipOwner;
  int? valentineEquipOwner;
  List<ValentineScript> valentineScript;
  AscensionAdd ascensionAdd;
  List<NiceSkill> skills;
  NiceLore? profile;

  CraftEssence({
    required this.id,
    required this.collectionNo,
    required this.name,
    required this.type,
    required this.flag,
    required this.rarity,
    required this.cost,
    required this.lvMax,
    required this.extraAssets,
    required this.atkBase,
    required this.atkMax,
    required this.hpBase,
    required this.hpMax,
    required this.growthCurve,
    required this.atkGrowth,
    required this.hpGrowth,
    required this.expGrowth,
    required this.expFeed,
    this.bondEquipOwner,
    this.valentineEquipOwner,
    required this.valentineScript,
    required this.ascensionAdd,
    required this.skills,
    this.profile,
  });

  factory CraftEssence.fromJson(Map<String, dynamic> json) =>
      _$CraftEssenceFromJson(json);
}
