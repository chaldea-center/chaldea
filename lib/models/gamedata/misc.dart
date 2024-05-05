import '_helper.dart';

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

  MyRoomAddOverwriteType get type2 =>
      MyRoomAddOverwriteType.values.firstWhere((e) => e.value == type, orElse: () => MyRoomAddOverwriteType.unknown);

  factory MstMyRoomAdd.fromJson(Map<String, dynamic> json) => _$MstMyRoomAddFromJson(json);

  Map<String, dynamic> toJson() => _$MstMyRoomAddToJson(this);
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
}
