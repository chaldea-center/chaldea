import 'package:json_annotation/json_annotation.dart';

import 'package:chaldea/utils/utils.dart';
import '../../app/app.dart';
import '../db.dart';
import 'game_card.dart';
import 'mappings.dart';
import 'servant.dart';
import 'skill.dart';
import 'wiki_data.dart';

part '../../generated/models/gamedata/command_code.g.dart';

@JsonSerializable()
class CommandCode with GameCardMixin {
  @override
  int id;
  @override
  int collectionNo;
  @override
  String name;
  @override
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

  @override
  Transl<String, String> get lName => Transl.ccNames(name);

  @override
  String? get icon =>
      extraAssets.faces.cc?[id] ??
      extraAssets.faces.cc?.values.toList().getOrNull(0);

  String? get charaGraph => extraAssets.charaGraph.cc?[id];

  CommandCodeExtra get extra => db.gameData.wiki.commandCodes[collectionNo] ??=
      CommandCodeExtra(collectionNo: collectionNo);

  String get route => Routes.commandCodeI(id);

  @override
  void routeTo() => routeToId(Routes.commandCode);
}
