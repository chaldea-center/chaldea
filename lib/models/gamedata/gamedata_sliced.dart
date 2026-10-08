// Frame-sliced variant of `GameData.fromJson` (ANR remediation P1-4).
//
// INVARIANTS — keep in sync with the generated code:
// 1) The final `GameData(...)` call must mirror `_$GameDataFromJson`
//    (gamedata.g.dart): same argument names, same order.
//    test/gamedata_sliced_sync_test.dart parses both files and fails on drift.
// 2) Order is load-bearing: `_GameLoadingTempData` is a first-parse-wins cache
//    (`_GameLoadingTempData` in gamedata_loader.dart; Item.fromJson also
//    caches). The six master maps must be parsed before any entity that embeds
//    references to them.
// 3) Entity parsing is never duplicated here — every leaf below is the same
//    generated `X.fromJson` the non-sliced path calls.

import 'package:chaldea/models/gamedata/gamedata.dart';

/// Hands the event loop back every [budgetMs] of continuous work.
class _SliceYielder {
  _SliceYielder(this.budgetMs);

  final int budgetMs;
  final Stopwatch _sw = Stopwatch()..start();

  bool get exhausted => _sw.elapsedMilliseconds >= budgetMs;

  Future<void> yieldNow() async {
    _sw.reset();
    // Duration.zero schedules a timer event so the event loop (timers, frames)
    // gets a turn. `await null` would only drain microtasks and block the UI.
    await Future<void>.delayed(Duration.zero);
  }
}

Future<Map<int, V>?> _sliceMap<V>(Object? raw, V Function(Map<String, dynamic>) parse, _SliceYielder y) async {
  if (raw == null) return null;
  final out = <int, V>{};
  for (final e in (raw as Map).entries) {
    out[int.parse(e.key as String)] = parse(Map<String, dynamic>.from(e.value as Map));
    if (y.exhausted) await y.yieldNow();
  }
  return out;
}

Future<List<V>?> _sliceList<V>(Object? raw, V Function(Map<String, dynamic>) parse, _SliceYielder y) async {
  if (raw == null) return null;
  final out = <V>[];
  for (final e in raw as List<dynamic>) {
    out.add(parse(Map<String, dynamic>.from(e as Map)));
    if (y.exhausted) await y.yieldNow();
  }
  return out;
}

/// Same input/output contract as `GameData.fromJson`, but yields to the event
/// loop every [budgetMs] so startup objectification cannot freeze the UI.
Future<GameData> gameDataFromJsonSliced(Map<String, dynamic> json, {int budgetMs = 40}) async {
  final y = _SliceYielder(budgetMs);

  final version = json['version'] == null
      ? null
      : DataVersion.fromJson(Map<String, dynamic>.from(json['version'] as Map));
  // -- tmp-cache producers: keep these six first, in this exact order --------
  final items = await _sliceMap(json['items'], Item.fromJson, y);
  final bgms = await _sliceMap(json['bgms'], BgmEntity.fromJson, y);
  final entities = await _sliceMap(json['entities'], BasicServant.fromJson, y);
  final baseFunctions = await _sliceMap(json['baseFunctions'], BaseFunction.fromJson, y);
  final baseSkills = await _sliceMap(json['baseSkills'], BaseSkill.fromJson, y);
  final baseTds = await _sliceMap(json['baseTds'], BaseTd.fromJson, y);
  // -- consumers -------------------------------------------------------------
  final servants = await _sliceList(json['servants'], Servant.fromJson, y) ?? const <Servant>[];
  final craftEssences = await _sliceList(json['craftEssences'], CraftEssence.fromJson, y) ?? const <CraftEssence>[];
  final commandCodes = await _sliceList(json['commandCodes'], CommandCode.fromJson, y) ?? const <CommandCode>[];
  final mysticCodes = await _sliceMap(json['mysticCodes'], MysticCode.fromJson, y);
  final campaigns = await _sliceMap(json['campaigns'], Event.fromJson, y);
  final events = await _sliceMap(json['events'], Event.fromJson, y);
  final wars = await _sliceMap(json['wars'], NiceWar.fromJson, y);
  final classBoards = await _sliceMap(json['classBoards'], ClassBoard.fromJson, y);
  final grandGraphs = await _sliceMap(json['grandGraphs'], GrandGraph.fromJson, y);
  final questPhases = await _sliceMap(json['questPhases'], QuestPhase.fromJson, y);
  final exchangeTickets = await _sliceMap(json['exchangeTickets'], ExchangeTicket.fromJson, y);
  final enemyMasters = await _sliceMap(json['enemyMasters'], EnemyMaster.fromJson, y);
  final masterMissions = await _sliceMap(json['masterMissions'], MstMasterMission.fromJson, y);
  final extraMasterMission = await _sliceMap(json['extraMasterMission'], MasterMission.fromJson, y);
  final questGroups = await _sliceList(json['questGroups'], MstQuestGroup.fromJson, y);
  final questPhaseDetails = await _sliceList(json['questPhaseDetails'], BasicQuestPhaseDetail.fromJson, y);
  final gachas = await _sliceMap(json['gachas'], NiceGacha.fromJson, y);
  // single-unit fields: no per-entry chunking at this level
  final wiki = json['wiki'] == null ? null : WikiData.fromJson(Map<String, dynamic>.from(json['wiki'] as Map));
  final mappingData = json['mappingData'] == null
      ? null
      : MappingData.fromJson(Map<String, dynamic>.from(json['mappingData'] as Map));
  final constData = json['constData'] == null
      ? null
      : ConstGameData.fromJson(Map<String, dynamic>.from(json['constData'] as Map));
  final dropData = json['dropData'] == null
      ? null
      : DropData.fromJson(Map<String, dynamic>.from(json['dropData'] as Map));
  final addData = json['addData'] == null
      ? null
      : GameDataAdd.fromJson(Map<String, dynamic>.from(json['addData'] as Map));
  final spoilerRegion = json['spoilerRegion'] == null
      ? null
      : const RegionConverter().fromJson(json['spoilerRegion'] as String);
  final removeOldDataRegion = json['removeOldDataRegion'] == null
      ? null
      : const RegionConverter().fromJson(json['removeOldDataRegion'] as String);

  // Phase boundary: let the event loop turn before the (synchronous)
  // constructor tail, so the tail cannot merge with the last objectification
  // remainder into one long block.
  await y.yieldNow();
  // Assembly — argument-for-argument mirror of `_$GameDataFromJson`,
  // guarded by test/gamedata_sliced_sync_test.dart.
  return GameData(
    version: version,
    items: items,
    bgms: bgms,
    entities: entities,
    baseFunctions: baseFunctions,
    baseSkills: baseSkills,
    baseTds: baseTds,
    servants: servants,
    craftEssences: craftEssences,
    commandCodes: commandCodes,
    mysticCodes: mysticCodes,
    campaigns: campaigns,
    events: events,
    wars: wars,
    classBoards: classBoards,
    grandGraphs: grandGraphs,
    questPhases: questPhases,
    exchangeTickets: exchangeTickets,
    enemyMasters: enemyMasters,
    masterMissions: masterMissions,
    extraMasterMission: extraMasterMission,
    questGroups: questGroups,
    questPhaseDetails: questPhaseDetails,
    gachas: gachas,
    wiki: wiki,
    mappingData: mappingData,
    constData: constData,
    dropData: dropData,
    addData: addData,
    spoilerRegion: spoilerRegion,
    removeOldDataRegion: removeOldDataRegion,
  );
}
