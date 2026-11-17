import '_helper.dart';
import 'common.dart';

part '../../generated/models/gamedata/misc.g.dart';

@JsonSerializable()
class MstMyRoomAdd {
  // [id] is not unique
  int id;
  int type;
  int priority;
  int overwriteId;
  int condType;
  int condValue; // 1,46, 113-commonRelease
  int condValue2;
  int startedAt;
  int endedAt;

  MstMyRoomAdd({
    required this.id,
    required this.type,
    required this.priority,
    required this.overwriteId,
    required this.condType,
    required this.condValue,
    required this.condValue2,
    required this.startedAt,
    required this.endedAt,
  });

  MyRoomAddOverwriteType get type2 => MyRoomAddOverwriteType.fromValue(type);

  factory MstMyRoomAdd.fromJson(Map<String, dynamic> json) => _$MstMyRoomAddFromJson(json);

  Map<String, dynamic> toJson() => _$MstMyRoomAddToJson(this);
}

@JsonSerializable()
class MstMyRoomAddBgDiff {
  int overwriteId;
  int type;
  int priority;
  int objectId;
  int condType;
  int condId;
  int condValue;

  MstMyRoomAddBgDiff({
    required this.overwriteId,
    required this.type,
    required this.priority,
    required this.objectId,
    required this.condType,
    required this.condId,
    required this.condValue,
  });

  MyRoomAddOverwriteType get type2 =>
      MyRoomAddOverwriteType.values.firstWhere((e) => e.value == type, orElse: () => MyRoomAddOverwriteType.unknown);

  factory MstMyRoomAddBgDiff.fromJson(Map<String, dynamic> json) => _$MstMyRoomAddBgDiffFromJson(json);

  Map<String, dynamic> toJson() => _$MstMyRoomAddBgDiffToJson(this);
}

enum MyRoomAddOverwriteType {
  unknown(0),
  bgImage(1),
  bgm(2),
  servantOverlayObject(6),
  bgImageMultiple(7),
  backObject(8);

  final int value;
  const MyRoomAddOverwriteType(this.value);

  static MyRoomAddOverwriteType fromValue(int value) =>
      values.firstWhere((e) => e.value == value, orElse: () => unknown);
}

@JsonSerializable()
class NiceOpeningMovie {
  int id;
  int priority;
  String name;
  String movie;
  int eventId;
  @JsonKey(unknownEnumValue: NiceOpeningMovieMaterialPosType.none)
  NiceOpeningMovieMaterialPosType materialPosType;
  int materialPosValue;
  List<CommonRelease> releaseConditions;
  List<CommonRelease> materialReleaseConditions;
  int playTime;
  @JsonKey(unknownEnumValue: NiceOpeningMovieFlag.none)
  List<NiceOpeningMovieFlag> flags;
  int startedAt;
  int endedAt;
  NiceOpeningMovieScript script;

  NiceOpeningMovie({
    required this.id,
    this.priority = 0,
    this.name = "",
    this.movie = "",
    this.eventId = 0,
    this.materialPosType = NiceOpeningMovieMaterialPosType.none,
    this.materialPosValue = 0,
    this.releaseConditions = const [],
    this.materialReleaseConditions = const [],
    this.playTime = 0,
    this.flags = const [],
    this.startedAt = 0,
    this.endedAt = 0,
    NiceOpeningMovieScript? script,
  }) : script = script ?? NiceOpeningMovieScript();

  factory NiceOpeningMovie.fromJson(Map<String, dynamic> json) => _$NiceOpeningMovieFromJson(json);

  Map<String, dynamic> toJson() => _$NiceOpeningMovieToJson(this);
}

@JsonSerializable()
class NiceOpeningMovieScript with DataScriptBase {
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  NiceOpeningMovieTiming? timing;

  int? get groupId => toInt('groupId');
  int? get warId => toInt('warId');
  bool? get isGrand => toBool('isGrand');
  int? get grandPVparentId => toInt('grandPVparentId');
  int? get playedFlagId => toInt('playedFlagId');
  String? get afterTransitionParam => getScript('afterTransitionParam');

  NiceOpeningMovieScript({this.timing});

  factory NiceOpeningMovieScript.fromJson(Map<String, dynamic> json) =>
      _$NiceOpeningMovieScriptFromJson(json)..setSource(json);

  Map<String, dynamic> toJson() => Map.from(source)..addAll(_$NiceOpeningMovieScriptToJson(this));
}

enum NiceOpeningMovieFlag {
  none, // added
  displaySeekBar,
}

enum NiceOpeningMovieMaterialPosType { none, mainRecordTop, storyBottom, questScript }

enum NiceOpeningMovieTiming {
  all,
  title,
  terminalNoticeAfter,
  blankEarthActionEnd,
  blankEarthSpotOpen,
  areaBoardTap,
  grandQuestClassSelectSetup,
  movieTiming20251220,
  titleLoginAfter,
}
