/// run in terminal [flutter packages pub run build_runner watch/build]
library servant;

import 'package:chaldea/components/datatype/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'servant.g.dart';

@JsonSerializable()
class Servant {
  int no;
  String mcLink;
  String icon;
  ServantBaseInfo info;
  List<NobelPhantasm> nobelPhantasm;

  Servant({this.no, this.mcLink, this.info, this.nobelPhantasm});

  factory Servant.fromJson(Map<String, dynamic> data) =>
      _$ServantFromJson(data);

  Map<String, dynamic> toJson() => _$ServantToJson(this);
}

@JsonSerializable()
class ServantBaseInfo {
  String get;
  int rarity;
  int rarity2;
  String weight;
  String height;
  String gender;
  String illustrator;
  String className;
  String attribute;
  bool isHumanoid;
  bool isWeakToEA;
  String name;
  String illustName;
  List<String> nicknames;
  List<String> cv;
  List<String> alignments;
  List<String> traits;
  Map<String, String> ability;
  List<Map<String, String>> illust;
  Map<String, Map<String, dynamic>> cards;
  Map<String, int> npRate;
  int atkMin;
  int hpMin;
  int atkMax;
  int hpMax;
  int atk90;
  int hp90;
  int atk100;
  int hp100;
  int starRate;
  int deathRate;
  int criticalRate;

  factory ServantBaseInfo.fromJson(Map<String, dynamic> data) =>
      _$ServantBaseInfoFromJson(data);

  Map<String, dynamic> toJson() => _$ServantBaseInfoToJson(this);

  ServantBaseInfo(
      {this.get,
      this.rarity,
      this.rarity2,
      this.weight,
      this.height,
      this.gender,
      this.illustrator,
      this.className,
      this.attribute,
      this.isHumanoid,
      this.isWeakToEA,
      this.name,
      this.illustName,
      this.nicknames,
      this.cv,
      this.alignments,
      this.traits,
      this.ability,
      this.illust,
      this.cards,
      this.npRate,
      this.atkMin,
      this.hpMin,
      this.atkMax,
      this.hpMax,
      this.atk90,
      this.hp90,
      this.atk100,
      this.hp100,
      this.starRate,
      this.deathRate,
      this.criticalRate});
}

@JsonSerializable()
class NobelPhantasm {
  String state;
  String openTime;
  String openCondition;
  String opeQuest;
  String name;
  String nameJP;
  String upperName;
  String upperNameJP;
  String color;
  String category;
  String rank;
  String typeText;
  List<Map<String, dynamic>> effect;

  factory NobelPhantasm.fromJson(Map<String, dynamic> data) =>
      _$NobelPhantasmFromJson(data);

  Map<String, dynamic> toJson() => _$NobelPhantasmToJson(this);

  NobelPhantasm(
      {this.state,
      this.openTime,
      this.openCondition,
      this.opeQuest,
      this.name,
      this.nameJP,
      this.upperName,
      this.upperNameJP,
      this.color,
      this.category,
      this.rank,
      this.typeText,
      this.effect});
}
