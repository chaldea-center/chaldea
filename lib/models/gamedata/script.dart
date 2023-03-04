import 'package:flutter/material.dart';

import 'package:tuple/tuple.dart';

import '../../app/app.dart';
import '../../app/modules/script/reader_entry.dart';
import '../db.dart';
import '_helper.dart';
import 'common.dart';
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

  factory NiceScript.fromJson(Map<String, dynamic> json) => _$NiceScriptFromJson(json);
}

@JsonSerializable()
class ScriptLink with RouteInfo {
  String scriptId;
  String script;

  ScriptLink({
    required this.scriptId,
    required this.script,
  });

  factory ScriptLink.fromJson(Map<String, dynamic> json) => _$ScriptLinkFromJson(json);

  String removePrefix(String? prefix) {
    if (prefix != null && scriptId.startsWith(prefix)) {
      return scriptId.substring(prefix.length);
    }
    return scriptId.length > 2 ? scriptId.substring(scriptId.length - 2) : scriptId;
  }

  String shortId() {
    if (int.tryParse(scriptId) != null && scriptId.length > 2) {
      return scriptId.substring(scriptId.length - 2);
    }
    return scriptId;
  }

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

  @override
  String get route => Routes.scriptI(scriptId);

  @override
  void routeTo({Region? region, Widget? child, bool popDetails = false}) {
    if (region != null) {
      child ??= ScriptIdLoadingPage(scriptId: scriptId, script: this, region: region);
    }
    super.routeTo(child: child, popDetails: popDetails);
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

  factory ValentineScript.fromJson(Map<String, dynamic> json) => _$ValentineScriptFromJson(json);
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

  factory StageLink.fromJson(Map<String, dynamic> json) => _$StageLinkFromJson(json);
}
