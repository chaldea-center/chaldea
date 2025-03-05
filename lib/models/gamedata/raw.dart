import 'dart:convert';

import '_helper.dart';

part '../../generated/models/gamedata/raw.g.dart';

@JsonSerializable(createToJson: false)
class MstEvent {
  int id;
  int type;
  String name;
  String shortName;
  // int noticeAt;
  int startedAt;
  int endedAt;
  int finishedAt;

  MstEvent({
    required this.id,
    required this.type,
    this.name = "",
    this.shortName = "",
    required this.startedAt,
    required this.endedAt,
    required this.finishedAt,
  });
  factory MstEvent.fromJson(Map<String, dynamic> json) => _$MstEventFromJson(json);
}

abstract class ExtraCharaImageBase<T> {
  int get svtId;
  List<T> get imageIds;
}

@JsonSerializable()
class ExtraCharaFigure implements ExtraCharaImageBase<int> {
  @override
  int svtId;
  List<int> charaFigureIds;

  @override
  List<int> get imageIds => charaFigureIds;

  ExtraCharaFigure({required this.svtId, List<int>? charaFigureIds}) : charaFigureIds = charaFigureIds ?? [];

  factory ExtraCharaFigure.fromJson(Map<dynamic, dynamic> json) => _$ExtraCharaFigureFromJson(json);
  Map<String, dynamic> toJson() => _$ExtraCharaFigureToJson(this);
}

@JsonSerializable()
class ExtraCharaImage implements ExtraCharaImageBase<String> {
  @override
  int svtId;
  @override
  List<String> imageIds;

  ExtraCharaImage({required this.svtId, List<dynamic>? imageIds})
    : imageIds = imageIds?.map((e) => e.toString()).toList() ?? [];

  factory ExtraCharaImage.fromJson(Map<dynamic, dynamic> json) => _$ExtraCharaImageFromJson(json);
  Map<String, dynamic> toJson() => _$ExtraCharaImageToJson(this);
}

@JsonSerializable()
class MstViewEnemy {
  int questId;
  int enemyId;
  String name;
  int classId;
  int svtId;
  int limitCount;
  int iconId;
  int displayType;
  List<int> missionIds;
  int impossibleKill;
  Map<String, dynamic> enemyScript;
  int npcSvtId;
  MstViewEnemy({
    required this.questId,
    required this.enemyId,
    required this.name,
    required this.classId,
    required this.svtId,
    required this.limitCount,
    required this.iconId,
    required this.displayType,
    this.missionIds = const [],
    this.impossibleKill = 0,
    dynamic enemyScript,
    required this.npcSvtId,
  }) : enemyScript = _parseScript(enemyScript);

  int? get entryByUserDeckFormationCondId => enemyScript['entryByUserDeckFormationCondId'];

  static Map<String, dynamic> _parseScript(dynamic src) {
    if (src is Map) return Map.from(src);
    if (src is String) {
      try {
        return Map.from(jsonDecode(src));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  factory MstViewEnemy.fromJson(Map<dynamic, dynamic> json) => _$MstViewEnemyFromJson(json);
  Map<String, dynamic> toJson() => _$MstViewEnemyToJson(this);
}

@JsonSerializable()
class UserDeckFormationCond {
  List<int> targetVals;
  List<int> targetVals2;
  int id;
  int type;
  int rangeType; // RestrictionRangeType

  UserDeckFormationCond({
    this.targetVals = const [],
    this.targetVals2 = const [],
    required this.id,
    this.type = 0,
    this.rangeType = 0,
  });

  factory UserDeckFormationCond.fromJson(Map<dynamic, dynamic> json) => _$UserDeckFormationCondFromJson(json);
  Map<String, dynamic> toJson() => _$UserDeckFormationCondToJson(this);
}

@JsonSerializable()
class MstQuestHint {
  int questId;
  int questPhase;
  String title;
  String message;
  int leftIndent;
  int openType;

  MstQuestHint({
    required this.questId,
    required this.questPhase,
    this.title = '',
    this.message = '',
    this.leftIndent = 0,
    this.openType = 0,
  });

  factory MstQuestHint.fromJson(Map<dynamic, dynamic> json) => _$MstQuestHintFromJson(json);
  Map<String, dynamic> toJson() => _$MstQuestHintToJson(this);
}

@JsonSerializable()
class MstSvtFilter {
  int id;
  String name;
  List<int> svtIds;
  int priority;
  int startedAt;
  int endedAt;

  MstSvtFilter({
    required this.id,
    this.name = "",
    this.svtIds = const [],
    this.priority = 0,
    this.startedAt = 0,
    this.endedAt = 0,
  });

  factory MstSvtFilter.fromJson(Map<dynamic, dynamic> json) => _$MstSvtFilterFromJson(json);
  Map<String, dynamic> toJson() => _$MstSvtFilterToJson(this);
}
// {
//     "eventId": 80273,
//     "svtId": 401400,
//     "priority": 0,
//     "fatigueTime": 18000,
//     "commonReleaseId": 0
// }

@JsonSerializable()
class MstEventSvtFatigue {
  int eventId;
  int svtId;
  int priority;
  int fatigueTime;
  int commonReleaseId;

  MstEventSvtFatigue({
    required this.eventId,
    this.svtId = 0,
    this.priority = 0,
    this.fatigueTime = 0,
    this.commonReleaseId = 0,
  });

  factory MstEventSvtFatigue.fromJson(Map<dynamic, dynamic> json) => _$MstEventSvtFatigueFromJson(json);
  Map<String, dynamic> toJson() => _$MstEventSvtFatigueToJson(this);
}

@JsonSerializable()
class MstStaffPhoto {
  int id;
  String staffName;
  String spriteName;
  int dispOrder;
  int condType;
  int condId;
  int condNum;
  Map<String, dynamic> extendData;

  MstStaffPhoto({
    required this.id,
    this.staffName = "",
    this.spriteName = "",
    this.dispOrder = 0,
    this.condType = 0,
    this.condId = 0,
    this.condNum = 0,
    this.extendData = const {},
  });

  factory MstStaffPhoto.fromJson(Map<dynamic, dynamic> json) => _$MstStaffPhotoFromJson(json);
  Map<String, dynamic> toJson() => _$MstStaffPhotoToJson(this);
}

@JsonSerializable()
class MstStaffPhotoCostume {
  int staffPhotoId;
  int idx;
  int dispOrder;
  String spriteName;
  int imageId;
  int faceId;
  String costumeName;
  int condType;
  int condId;
  int condNum;
  Map<String, dynamic> extendData;

  MstStaffPhotoCostume({
    this.staffPhotoId = 0,
    this.idx = 0,
    this.dispOrder = 0,
    this.spriteName = "",
    this.imageId = 0,
    this.faceId = 0,
    this.costumeName = "",
    this.condType = 0,
    this.condId = 0,
    this.condNum = 0,
    this.extendData = const {},
  });

  factory MstStaffPhotoCostume.fromJson(Map<dynamic, dynamic> json) => _$MstStaffPhotoCostumeFromJson(json);
  Map<String, dynamic> toJson() => _$MstStaffPhotoCostumeToJson(this);
}
