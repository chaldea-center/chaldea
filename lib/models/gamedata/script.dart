import 'package:tuple/tuple.dart';

import '../db.dart';
import '_helper.dart';
import 'quest.dart';
import 'war.dart';

part '../../generated/models/gamedata/script.g.dart';

@JsonSerializable()
class NiceScript extends ScriptLink {
  int scriptSizeBytes;
  List<Quest> quests;

  NiceScript({
    required super.scriptId,
    required this.scriptSizeBytes,
    required super.script,
    required this.quests,
  });

  factory NiceScript.fromJson(Map<String, dynamic> json) =>
      _$NiceScriptFromJson(json);
}

@JsonSerializable()
class ScriptLink {
  String scriptId;
  String script;

  ScriptLink({
    required this.scriptId,
    required this.script,
  });

  factory ScriptLink.fromJson(Map<String, dynamic> json) =>
      _$ScriptLinkFromJson(json);

  static List<Tuple2<NiceWar, Quest?>> findQuests(String scriptId) {
    List<Tuple2<NiceWar, Quest?>> results = [];
    for (final war in db.gameData.wars.values) {
      if (war.startScript?.scriptId == scriptId) {
        results.add(Tuple2(war, null));
      }
      for (final quest in war.quests) {
        for (final phase in quest.phaseScripts) {
          if (phase.scripts.any((s) => s.scriptId == scriptId)) {
            results.add(Tuple2(war, quest));
          }
        }
      }
    }
    return results;
  }
}

@JsonSerializable()
class ValentineScript extends ScriptLink {
  String scriptName;

  ValentineScript({
    required super.scriptId,
    required super.script,
    required this.scriptName,
  });

  factory ValentineScript.fromJson(Map<String, dynamic> json) =>
      _$ValentineScriptFromJson(json);
}

@JsonSerializable()
class StageLink {
  int questId;
  int phase;
  int stage;

  StageLink({
    required this.questId,
    required this.phase,
    required this.stage,
  });

  factory StageLink.fromJson(Map<String, dynamic> json) =>
      _$StageLinkFromJson(json);
}
