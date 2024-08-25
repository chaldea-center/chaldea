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

  @override
  Map<String, dynamic> toJson() => _$NiceScriptToJson(this);
}

@JsonSerializable()
class ScriptLink with RouteInfo {
  String scriptId;
  String? _script;
  String get script => _script ?? getScriptPath(scriptId);

  ScriptLink({
    required this.scriptId,
    String? script,
  }) : _script = parseUrl(scriptId, script);

  static String? parseUrl(String scriptId, String? script) {
    if (script == null) return null;
    if (!script.contains('/JP/Script/')) return script;
    if (getScriptPath(scriptId) != script) return script;
    return null;
  }

  static String getScriptPath(String scriptId) {
    String scriptPath;
    if (scriptId == 'WarEpilogue108') {
      scriptPath = "01/WarEpilogue108";
    } else if (scriptId.isNotEmpty && (scriptId.startsWith('0') || scriptId.startsWith('9'))) {
      if (scriptId.startsWith('94')) {
        scriptPath = "94/${scriptId.substring(0, 4)}/$scriptId";
      } else {
        scriptPath = "${scriptId.substring(0, 2)}/$scriptId";
      }
    } else {
      scriptPath = "Common/$scriptId";
    }
    return 'https://static.atlasacademy.io/JP/Script/$scriptPath.txt';
  }

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

  Map<String, dynamic> toJson() => _$ScriptLinkToJson(this);
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

  @override
  Map<String, dynamic> toJson() => _$ValentineScriptToJson(this);
}
