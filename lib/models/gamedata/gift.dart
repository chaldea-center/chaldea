// ignore_for_file: avoid_types_as_parameter_names

import '_helper.dart';
import 'quest.dart';

part '../../generated/models/gamedata/gift.g.dart';

@JsonSerializable()
class MstGiftBase {
  int type;
  int objectId;
  int num;

  MstGiftBase({this.type = 0, this.objectId = 0, this.num = 0});

  Gift toGift() {
    return Gift(id: 0, type: GiftType.fromId(type), objectId: objectId, num: num);
  }

  factory MstGiftBase.fromJson(Map<String, dynamic> json) => _$MstGiftBaseFromJson(json);

  Map<String, dynamic> toJson() => _$MstGiftBaseToJson(this);
}
