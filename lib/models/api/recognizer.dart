import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../packages/logger.dart';
import '../userdata/_helper.dart';
import '../userdata/userdata.dart';

part '../../generated/models/api/recognizer.g.dart';

@JsonSerializable()
class ItemResult {
  String key;
  int startAt;
  int endedAt;
  List<ItemDetail> details;

  ItemResult({
    required this.key,
    required this.startAt,
    required this.endedAt,
    required this.details,
  });

  factory ItemResult.fromJson(Map<String, dynamic> json) =>
      _$ItemResultFromJson(json);

  Map<String, dynamic> toJson() => _$ItemResultToJson(this);
}

@JsonSerializable()
class ItemDetail {
  int itemId;
  int count;
  final String thumb;
  final String numberThumb;
  final int imageId;
  final double score;

  @JsonKey(ignore: true)
  bool checked = true;
  @JsonKey(ignore: true)
  Uint8List? imgThumb;
  @JsonKey(ignore: true)
  Uint8List? imgNum;

  bool get valid => itemId > 0 && count > 0;

  ItemDetail({
    required this.itemId,
    required this.count,
    required this.thumb,
    required this.numberThumb,
    required this.imageId,
    required this.score,
  }) {
    try {
      imgThumb = base64Decode(thumb);
      imgNum = base64Decode(numberThumb);
    } catch (e, s) {
      logger.e('decode base64 failed: $itemId, $count', e, s);
    }
  }

  factory ItemDetail.fromJson(Map<String, dynamic> json) =>
      _$ItemDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ItemDetailToJson(this);
}

@JsonSerializable()
class SkillResult {
  String key;
  int startAt;
  int endedAt;
  List<SkillDetail> details;

  int get lapse => endedAt - startAt;

  SkillResult({
    required this.key,
    required this.startAt,
    required this.endedAt,
    required this.details,
  });

  factory SkillResult.fromJson(Map<String, dynamic> json) =>
      _$SkillResultFromJson(json);

  Map<String, dynamic> toJson() => _$SkillResultToJson(this);
}

@JsonSerializable()
class SkillDetail {
  int svtId;
  int ascension;
  int skill1;
  int skill2;
  int skill3;
  final String thumb;
  final int imageId;
  final double score;

  @JsonKey(ignore: true)
  bool checked = true;
  @JsonKey(ignore: true)
  Uint8List? imgThumb;
  List<int> get skills => [skill1, skill2, skill3];

  void setSkill(int index, int v) {
    if (v < 0 || v > 10) {
      assert(() {
        throw ArgumentError.value(v, 'v');
      }());
      return;
    }
    if (index == 0) {
      skill1 = v;
    } else if (index == 1) {
      skill2 = v;
    } else if (index == 2) {
      skill3 = v;
    } else {
      throw ArgumentError.value(index, 'index');
    }
  }

  bool get valid =>
      svtId > 0 &&
      _inRange(ascension, 0, 4) &&
      _inRange(skill1, 0, 10) &&
      _inRange(skill2, 0, 10) &&
      _inRange(skill3, 0, 10);

  bool _inRange(int v, int lower, int upper) {
    return v >= lower && v <= upper;
  }

  SkillDetail({
    required this.svtId,
    this.ascension = 0,
    required this.skill1,
    required this.skill2,
    required this.skill3,
    required this.thumb,
    required this.imageId,
    required this.score,
  }) {
    try {
      imgThumb = base64Decode(thumb);
    } catch (e, s) {
      logger.e('decode base64 failed: $svtId', e, s);
    }
    int _valid(int v, int lower, int upper) =>
        v >= lower && v <= upper ? v : -1;
    ascension = _valid(ascension, -1, 4);
    skill1 = _valid(skill1, -1, 10);
    skill2 = _valid(skill2, -1, 10);
    skill3 = _valid(skill3, -1, 10);
  }

  factory SkillDetail.fromJson(Map<String, dynamic> json) =>
      _$SkillDetailFromJson(json);

  Map<String, dynamic> toJson() => _$SkillDetailToJson(this);
}

// user data backup

@JsonSerializable()
class UserDataBackup {
  final DateTime timestamp;
  UserData? content;

  UserDataBackup({
    required int timestamp,
    required String content,
  })  : timestamp = DateTime.fromMillisecondsSinceEpoch(timestamp),
        content = null {
    try {
      this.content = UserData.fromJson(jsonDecode(
          utf8.decode(GZipDecoder().decodeBytes(base64Decode(content)))));
    } catch (e, s) {
      logger.e('decode server backup failed', e, s);
    }
  }

  factory UserDataBackup.fromJson(Map<String, dynamic> json) =>
      _$UserDataBackupFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataBackupToJson(this);
}
