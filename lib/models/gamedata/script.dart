import 'package:json_annotation/json_annotation.dart';

import 'quest.dart';

part '../../generated/models/gamedata/script.g.dart';

@JsonSerializable()
class NiceScript {
  String scriptId;
  int scriptSizeBytes;
  String script;
  List<Quest> quests;

  NiceScript({
    required this.scriptId,
    required this.scriptSizeBytes,
    required this.script,
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
}

@JsonSerializable()
class ValentineScript implements ScriptLink {
  @override
  String scriptId;
  @override
  String script;
  String scriptName;

  ValentineScript({
    required this.scriptId,
    required this.script,
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
