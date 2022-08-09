import 'dart:convert';
import 'dart:math';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';

// id	name	priority	coin	bond favorite
// 	ascension	ascension_t	skill1	skill1_t	skill2	skill2_t	skill3	skill3_t
// 	append1	append_t	append2	append2_t	append3	append3_t	costumes	costumes_t
// grail	grail_t	fouHp	fouHp_t	fouAtk	fouAtk_t	bondLimit	bondLimit_t	npLv	npLv_t
class PlanDataSheetConverter {
  static const _id = 'id';
  static const _name = 'name';
  static const _priority = 'priority';
  static const _coin = 'coin';
  static const _bond = 'bond';
  static const _cmdCode = 'cmdCode';

  static const _favorite = 'favorite';
  static const _ascension = 'ascension';
  static const _skill1 = 'skill1';
  static const _skill2 = 'skill2';
  static const _skill3 = 'skill3';
  static const _append1 = 'append1';
  static const _append2 = 'append2';
  static const _append3 = 'append3';
  static const _costumes = 'costumes';
  static const _grail = 'grail';
  static const _fouHp = 'fouHp4';
  static const _fouAtk = 'fouAtk4';
  static const _fouHp3 = 'fouHp3';
  static const _fouAtk3 = 'fouAtk3';
  static const _bondLimit = 'bondLimit';
  static const _npLv = 'npLv';

  static const _planHeaders = <String>[
    _ascension,
    _skill1,
    _skill2,
    _skill3,
    _append1,
    _append2,
    _append3,
    _costumes,
    _grail,
    _fouHp,
    _fouAtk,
    _bondLimit,
    _npLv
  ];

  static final _headers = <String>[
    _id,
    _name,
    _favorite,
    _priority,
    _coin,
    _bond,
    for (final k in _planHeaders) ...[k, '${k}_t'],
    _cmdCode,
  ];

  static Map<String, String Function()> titles = {
    _id: () => 'ID',
    _name: () => 'Name',
    _priority: () => S.current.priority,
    _coin: () => S.current.servant_coin,
    _bond: () => S.current.bond,
    _cmdCode: () => S.current.command_code,
    _favorite: () => S.current.favorite,
    _ascension: () => S.current.ascension,
    _skill1: () => '${S.current.active_skill_short} 1',
    _skill2: () => '${S.current.active_skill_short} 2',
    _skill3: () => '${S.current.active_skill_short} 3',
    _append1: () => '${S.current.append_skill_short} 1',
    _append2: () => '${S.current.append_skill_short} 2',
    _append3: () => '${S.current.append_skill_short} 3',
    _costumes: () => S.current.costume,
    _grail: () => S.current.grail_up,
    _fouHp: () => '${S.current.foukun} HP',
    _fouAtk: () => '${S.current.foukun} ATK',
    _bondLimit: () => S.current.bond_limit,
    _npLv: () => S.current.np_short,
  };

  Map<String, String> _svtPlanToCsv(SvtPlan plan, bool isTarget) {
    Map<String, String> data = {};
    String suff = isTarget ? '_t' : '';
    void _write(String key, dynamic v) {
      assert(v is int || v is String);
      data[key + suff] = v.toString();
    }

    _write(_ascension, plan.ascension);
    _write(_skill1, plan.skills[0]);
    _write(_skill2, plan.skills[1]);
    _write(_skill3, plan.skills[2]);
    _write(_append1, plan.appendSkills[0]);
    _write(_append2, plan.appendSkills[1]);
    _write(_append3, plan.appendSkills[2]);
    _write(
        _costumes,
        jsonEncode(plan.costumes
            .map((key, value) => MapEntry(key.toString(), value))));
    _write(_grail, plan.grail);
    _write(_fouHp, plan.fouHp);
    _write(_fouAtk, plan.fouAtk);
    _write(_fouHp3, plan.fouHp3);
    _write(_fouAtk3, plan.fouAtk3);
    _write(_bondLimit, plan.bondLimit);
    _write(_npLv, plan.npLv);
    return data;
  }

  SvtPlan _svtPlanFromCsv(Map<String, String?> row, bool isTarget) {
    String suff = isTarget ? '_t' : '';
    int? _toInt(String key) {
      final v = row[key + suff];
      if (v == null) return null;
      return int.tryParse(v);
    }

    Map<int, int> costumes = (jsonDecode(row[_costumes + suff] ?? '{}') as Map)
        .map((key, value) => MapEntry(int.parse(key), value));

    return SvtPlan(
      favorite: row[_favorite] == "1",
      ascension: _toInt(_ascension) ?? 0,
      skills: [
        _toInt(_skill1) ?? 0,
        _toInt(_skill2) ?? 0,
        _toInt(_skill3) ?? 0,
      ],
      appendSkills: [
        _toInt(_append1) ?? 0,
        _toInt(_append2) ?? 0,
        _toInt(_append3) ?? 0,
      ],
      costumes: costumes,
      grail: _toInt(_grail) ?? 0,
      fouHp: _toInt(_fouHp) ?? 0,
      fouAtk: _toInt(_fouAtk) ?? 0,
      fouHp3: _toInt(_fouHp3) ?? 0,
      fouAtk3: _toInt(_fouAtk3) ?? 0,
      bondLimit: _toInt(_bondLimit) ?? 0,
      npLv: _toInt(_npLv),
    );
  }

  List<String> svtToCsv(int id, String name, SvtStatus status, SvtPlan plan) {
    Map<String, dynamic> data = {
      _id: id,
      _name: name,
      _favorite: status.cur.favorite ? 1 : 0,
      _priority: status.priority,
      _bond: status.bond,
      ..._svtPlanToCsv(status.cur, false),
      ..._svtPlanToCsv(plan, true),
      _cmdCode: jsonEncode(status.equipCmdCodes),
    };
    return _headers.map((e) => data[e]?.toString() ?? "").toList();
  }

  MapEntry<SvtStatus, SvtPlan> csvToSvt(List<String> row, List<String> header) {
    Map<String, String> rowData = {
      for (int index = 0; index < min(row.length, header.length); index++)
        header[index]: row[index]
    };

    int? _toInt(String? key) {
      final v = rowData[key];
      if (v == null) return null;
      return int.tryParse(v);
    }

    String? _cmd = rowData[_cmdCode];
    final List equipCmdCodes =
        _cmd == null || _cmd.trim().isEmpty ? [] : jsonDecode(_cmd);

    final plan = _svtPlanFromCsv(rowData, true);
    final status = SvtStatus(
      cur: _svtPlanFromCsv(rowData, false),
      priority: _toInt(_priority) ?? 1,
      bond: _toInt(_bond) ?? 0,
      equipCmdCodes: List.from(equipCmdCodes),
    );
    return MapEntry(status, plan);
  }

  List<List<String>> generateCSV(bool includeAll, bool includeFavorite) {
    List<List<String>> data = [];
    data.add(_headers);
    List<String> notes = [];
    for (String key in _headers) {
      bool isTarget = key.endsWith('_t');
      if (isTarget) key = key.substring(0, key.length - 2);
      String note = titles[key]?.call() ?? "";
      if (isTarget) {
        note += '(${S.current.plan_list_set_all_target})';
      }
      notes.add(note);
    }
    data.add(notes);
    List<int> collections = [];
    if (includeAll) {
      collections = db.gameData.servantsWithDup.keys.toList();
    } else if (includeFavorite) {
      collections = db.gameData.servantsWithDup.keys
          .where((key) => db.curUser.svtStatusOf(key).favorite)
          .toList();
    }
    collections.sort();
    for (final key in collections) {
      data.add(svtToCsv(key, db.gameData.servantsWithDup[key]?.lName.l ?? "",
          db.curUser.svtStatusOf(key), db.curUser.svtPlanOf(key)));
    }
    return data;
  }

  void parseFromCSV(Map<int, SvtStatus> statuses, Map<int, SvtPlan> plans,
      List<List<String>> rawData) {
    if (rawData.isEmpty) throw ArgumentError('empty CSV');
    final header = rawData[0];
    for (final row in rawData.skip(1)) {
      if (row.isEmpty) continue;
      final key = int.tryParse(row.first);
      if (key == null) continue;
      final parsed = csvToSvt(row, header);
      statuses[key] = parsed.key;
      plans[key] = parsed.value;
    }
  }
}
