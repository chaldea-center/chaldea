// ignore_for_file: avoid_types_as_parameter_names

import '_helper.dart';
import 'quest.dart';

part '../../generated/models/gamedata/gift.g.dart';

@JsonSerializable()
class MstGiftBase {
  int type;
  int objectId;
  int num;

  MstGiftBase({
    this.type = 0,
    this.objectId = 0,
    this.num = 0,
  });

  Gift toGift() {
    return Gift(
      id: 0,
      type: GiftType.fromId(type),
      objectId: objectId,
      num: num,
    );
  }

  factory MstGiftBase.fromJson(Map<String, dynamic> json) => _$MstGiftBaseFromJson(json);

  Map<String, dynamic> toJson() => _$MstGiftBaseToJson(this);
}

// GachaInfos
@JsonSerializable()
class GachaInfos extends MstGiftBase {
  bool isNew;
  int userSvtId;
  //  int type;
  //  int objectId;
  //  int num;
  int limitCount;
  int sellQp;
  int sellMana;
  int svtCoinNum;

  GachaInfos({
    this.isNew = false,
    this.userSvtId = 0,
    super.type,
    super.objectId,
    super.num,
    this.limitCount = 0,
    this.sellQp = 0,
    this.sellMana = 0,
    this.svtCoinNum = 0,
  });

  factory GachaInfos.fromJson(Map<String, dynamic> json) => _$GachaInfosFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GachaInfosToJson(this);
}

// public class GachaInfos
// {
// 	public bool isNew;
// 	public long userSvtId;
// 	public int type;
// 	public int objectId;
// 	public int num;
// 	public int limitCount;
// 	public int sellQp;
// 	public int sellMana;
// 	public int svtCoinNum;

// 	public void .ctor() { }
// }
