import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import '../db.dart';
import '_helper.dart';
import 'common.dart';
import 'event.dart';
import 'item.dart';
import 'mst_tables.dart';
import 'servant.dart';
import 'skill.dart';

export 'mst_tables.dart';

part '../../generated/models/gamedata/mst_data.g.dart';

@JsonSerializable(createToJson: false)
class FateTopLogin {
  @JsonKey(name: 'response')
  List<FateResponseDetail> responses;
  Map<String, dynamic> cache;
  String sign;

  FateTopLogin({this.responses = const [], Map<String, dynamic>? cache, String? sign})
    : cache = cache ?? {},
      sign = sign ?? '' {
    mstData.updateCache(this.cache);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic>? rawMap;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Region? region;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final mstData = MasterDataManager();

  DateTime? get serverTime => (cache['serverTime'] as int?)?.sec2date();

  FateResponseDetail getResponse(String nid) {
    final result = getResponseNull(nid);
    if (result != null) return result;
    final errors = responses.where((e) => !e.isSuccess()).map((e) => '[${e.nid}] ${e.resCode} ${e.fail}').toList();
    if (errors.isNotEmpty) {
      throw Exception('response nid="$nid" not found, error found:\n${errors.join("\n")}');
    }
    throw Exception('response nid="$nid" not found: ${responses.map((e) => "[${e.nid}] ${e.resCode}").join(" ")}');
  }

  FateResponseDetail? getResponseNull(String nid) {
    for (final resp in responses) {
      if (resp.nid == nid) return resp;
    }
    return null;
  }

  bool isSuccess(String nid) {
    return responses.any((e) => e.nid == nid && e.isSuccess());
  }

  factory FateTopLogin.fromJson(Map<String, dynamic> data) => _$FateTopLoginFromJson(data)..rawMap = Map.of(data);

  factory FateTopLogin.parseAny(dynamic data) => FateTopLogin.fromJson(parseToMap(data));

  static Map<String, dynamic> parseToMap(dynamic data) {
    if (data is Map) {
      return Map.from(data);
    }
    if (data is String) {
      return Map.from(jsonDecode(tryBase64Decode(data)));
    }
    if (data is List<int>) {
      List<int> bytes = data;
      if (ByteFormatDetector.isGzip(bytes)) {
        bytes = gzip.decode(bytes);
      } else if (ByteFormatDetector.isZlib(bytes)) {
        bytes = ZLibCodec(raw: false).decode(bytes);
      } else if (ByteFormatDetector.isJsonMap(bytes) || ByteFormatDetector.isJsonMapBase64(bytes)) {
        // do nothing
      } else {
        try {
          bytes = ZLibCodec(raw: true).decode(bytes);
        } catch (e, s) {
          logger.t('not deflate compressed: ${bytes.take(10).toList()}', e, s);
        }
      }
      return Map.from(jsonDecode(tryBase64Decode(utf8.decode(bytes))));
    }
    throw FormatException('Unsupported format: ${data.runtimeType}');
  }

  static String tryBase64Decode(String content) {
    content = content.trim();
    try {
      // eyJy
      if (content.startsWith('ey')) {
        content = utf8.decode(base64Decode(Uri.decodeFull(content).trim()));
      }
    } catch (e) {
      //
    }
    return content;
  }

  /// base64 maybe url-encoded
  static FateTopLogin fromBase64(String encoded) {
    encoded = tryBase64Decode(encoded);
    final json = Map<String, dynamic>.from(jsonDecode(encoded));
    Region? region;
    try {
      region = guessRegion(json);
    } catch (e) {
      print(e);
    }
    return FateTopLogin.fromJson(json)..region = region;
  }

  // may be deflate, gzip
  static FateTopLogin fromBytes(List<int> bytes) {
    String? contents;
    try {
      contents = utf8.decode(bytes);
    } catch (e) {} // ignore: empty_catches
    if (contents == null) {
      try {
        if (bytes.length > 2 && bytes[0] == 0x1f && bytes[1] == 0x8b) {
          contents = utf8.decode(gzip.decode(bytes));
        }
      } catch (e) {} // ignore: empty_catches
    }
    if (contents == null) {
      try {
        contents = utf8.decode(ZLibCodec(raw: true).decode(bytes));
      } catch (e) {} // ignore: empty_catches
    }
    if (contents == null) {
      if (kIsWeb) {
        throw const FormatException("Unknown byte format, web doesn't support gzip/deflate");
      } else {
        throw const FormatException("Unknown byte format, gzip or raw deflate or plain utf8");
      }
    }
    return fromBase64(contents);
  }

  static Region? guessRegion(Map? data) {
    if (data == null) return null;
    if ((data['cache']?['replaced'] as Map?)?.containsKey('globalUser') == true) {
      return Region.na;
    }
    final Map? userGame = data['cache']?['replaced']?['userGame']?[0];
    final String? friendCode = userGame?['friendCode']?.toString();
    if (userGame == null) return null;
    if (userGame['rkchannel']?.toString() == '1000') {
      return Region.tw;
    } else if (friendCode != null && friendCode.length >= 12) {
      return Region.cn;
    }
    return Region.jp;
  }
}

// ResponseData.cs
@JsonSerializable(createToJson: false)
class FateResponseDetail {
  String? resCode;
  Map? success;
  Map? fail;
  String? nid;
  // CN
  String? usk;
  List<String>? encryptApi;

  bool isSuccess() => resCode == '00' || resCode == '0';

  int? get code => resCode == null ? null : int.tryParse(resCode!);

  FateResponseDetail({this.resCode, this.success, this.fail, this.nid, this.usk, this.encryptApi});

  factory FateResponseDetail.fromJson(Map<String, dynamic> data) => _$FateResponseDetailFromJson(data);
}

class MasterDataManager extends MasterDataManagerBase {
  bool get isLoggedIn => user != null && userSvt.isNotEmpty;

  bool isQuestClear(int questId) => (userQuest[questId]?.clearNum ?? 0) > 0;

  bool isQuestPhaseClear(int questId, int questPhase) {
    if (questPhase <= 0) return isQuestClear(questId);
    final _userQuest = userQuest[questId];
    if (_userQuest == null) return false;
    return _userQuest.questPhase >= questPhase;
  }

  List<int> getSvtAppendSkillLv(UserServantEntity userSvt) {
    final Map<int, int> lvs = Map.fromIterable(
      userSvtAppendPassiveSkill[userSvt.svtId]?.unlockNums ?? <int>[],
      value: (_) => 1,
    );
    final appendLv = userSvtAppendPassiveSkillLv[userSvt.id];
    if (appendLv != null) {
      lvs.addAll(Map.fromIterables(appendLv.appendPassiveSkillNums, appendLv.appendPassiveSkillLvs));
    }
    return List.generate(kAppendSkillNums.length, (index) => lvs[100 + index] ?? 0);
  }

  int getItemOrSvtNum(
    int itemId, {
    int defaultValue = 0,
    bool sumEquipLimitCount = true,
    List<int> eventIds = const [],
  }) {
    final user = this.user;
    if (itemId == Items.qpId) {
      return user?.qp ?? defaultValue;
    } else if (itemId == Items.stoneId) {
      // stone=free+charge
      return user?.stone ?? defaultValue;
    } else if (itemId == Items.manaPrismId) {
      return user?.mana ?? defaultValue;
    } else if (itemId == Items.rarePrismId) {
      return user?.rarePri ?? defaultValue;
    }
    int? count = userItem[itemId]?.num;
    if (count != null) return count;
    final item = db.gameData.items[itemId];
    if (item != null) {
      if (item.type == ItemType.eventPoint) {
        for (final eventId in [item.eventId, ...eventIds]) {
          if (eventId == 0) continue;
          for (final candidateEventId in eventIds) {
            final point = userEventPoint[UserEventPointEntity.createPK(candidateEventId, item.eventGroupId)];
            if (candidateEventId != 0 && point != null) return point.value;
          }
        }
        return userEventPoint[UserEventPointEntity.createPK(item.eventId, item.eventGroupId)]?.value ?? defaultValue;
      }
      if (item.type == ItemType.svtCoin) {
        return userSvtCoin[item.value]?.num ?? defaultValue;
      }
    }

    final svt = db.gameData.entities[itemId];
    if (svt != null) {
      switch (svt.type) {
        case SvtType.normal:
        case SvtType.heroine:
        case SvtType.combineMaterial:
        case SvtType.statusUp:
        case SvtType.svtMaterialTd:
          count = userSvt.where((e) => e.svtId == svt.id).length;
        case SvtType.servantEquip:
          final equips = userSvt.where((e) => e.svtId == svt.id);
          count = sumEquipLimitCount ? Maths.sum(equips.map((e) => e.limitCount + 1)) : equips.length;
        case SvtType.enemy:
        case SvtType.enemyCollection:
        case SvtType.enemyCollectionDetail:
        case SvtType.svtEquipMaterial:
        case SvtType.all:
        case SvtType.commandCode:
          break;
      }
    }
    return count ?? defaultValue;
  }

  ({int svtCount, int svtEquipCount, int ccCount, int unknownCount}) countSvtKeep() {
    int svtCount = 0, svtEquipCount = 0, unknownCount = 0;
    for (final svt in userSvt) {
      // may contains region specific CEs
      final ce = db.gameData.craftEssencesById[svt.svtId];
      if (ce != null) {
        if (!ce.flags.contains(SvtFlag.svtEquipFriendShip)) {
          svtEquipCount += 1;
        }
        continue;
      }
      final dbSvt = db.gameData.entities[svt.svtId];
      if (dbSvt == null) {
        unknownCount += 1;
      } else {
        svtCount += 1;
      }
    }
    return (
      svtCount: svtCount,
      svtEquipCount: svtEquipCount,
      ccCount: userCommandCode.length,
      unknownCount: unknownCount,
    );
  }

  Map<int, int> get randomMissionProgress {
    return {
      for (final v in userEventRandomMission)
        if (v.isInProgress) v.missionId: userEventMissionFix[v.missionId]?.num ?? 0,
    };
  }

  MissionProgressType getMissionProgress(int missionId) {
    return MissionProgressType.fromValue(userEventMission[missionId]?.missionProgressType ?? 0);
  }

  ({MissionProgressType progressType, List<({int? progress, int targetNum})> progresses}) resolveMissionProgress(
    EventMission mission,
  ) {
    final eventMissionFix = userEventMissionFix[mission.id];
    if (eventMissionFix != null) {
      // progressType=eventMissionFix.progressType;
      // progressNum = eventMissionFix.num;
    }
    List<({int? progress, int targetNum})> progresses = [];
    // DIDN'T consider condGroup
    for (final cond in mission.clearConds) {
      int? progressNum;
      if (cond.condType == CondType.missionConditionDetail) {
        progressNum = Maths.sum(cond.targetIds.map((e) => userEventMissionCondDetail[e]?.progressNum));
      } else if (cond.condType == CondType.eventMissionClear) {
        progressNum = cond.targetIds.where((missionId) => getMissionProgress(missionId).isClearOrAchieve).length;
      } else if (cond.condType == CondType.questClear) {
        progressNum = cond.targetIds.where(isQuestClear).length;
      }
      progresses.add((progress: progressNum, targetNum: cond.targetNum));
    }

    return (progressType: getMissionProgress(mission.id), progresses: progresses);
  }
}
