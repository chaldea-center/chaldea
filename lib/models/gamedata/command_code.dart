import 'package:chaldea/utils/utils.dart';
import '../../app/app.dart';
import '../db.dart';
import '../userdata/userdata.dart';
import '_helper.dart';
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
  String ruby;
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
    this.ruby = "",
    required this.rarity,
    required this.extraAssets,
    required this.skills,
    required this.illustrator,
    required this.comment,
  });

  @override
  Transl<String, String> get lName => Transl.ccNames(name);

  @override
  String? get icon => extraAssets.faces.cc?[id] ?? extraAssets.faces.cc?.values.toList().getOrNull(0);

  @override
  String? get borderedIcon => collectionNo > 0 && !db.gameData.isJustAddedCard(id) ? super.borderedIcon : icon;

  String? get charaGraph => extraAssets.charaGraph.cc?[id];

  CommandCodeExtra get extra =>
      db.gameData.wiki.commandCodes[collectionNo] ??= CommandCodeExtra(collectionNo: collectionNo);

  @override
  String get route => Routes.commandCodeI(id);

  CmdCodeStatus get status => db.curUser.ccStatusOf(collectionNo);

  factory CommandCode.fromJson(Map<String, dynamic> json) => _$CommandCodeFromJson(json);

  Map<String, dynamic> toJson() => _$CommandCodeToJson(this);
}

@JsonSerializable()
class BasicCommandCode with GameCardMixin {
  @override
  int id;
  @override
  int collectionNo;
  @override
  String name;
  @override
  int rarity;
  String face;

  BasicCommandCode({
    required this.id,
    required this.collectionNo,
    required this.name,
    required this.rarity,
    required this.face,
  });

  @override
  String get icon => face;

  @override
  Transl<String, String> get lName => Transl.ccNames(name);

  @override
  String get route => Routes.commandCodeI(id);

  factory BasicCommandCode.fromJson(Map<String, dynamic> json) => _$BasicCommandCodeFromJson(json);

  Map<String, dynamic> toJson() => _$BasicCommandCodeToJson(this);
}
