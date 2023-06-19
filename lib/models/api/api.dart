import '../userdata/_helper.dart';

part '../../generated/models/api/api.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class D1Result<T> {
  bool success;
  String? error;
  List<T> results;

  D1Result({
    required this.success,
    this.error,
    this.results = const [],
  });

  factory D1Result.fromJson(Map<String, dynamic> json) => _$D1ResultFromJson(json, _fromJsonT<T>);

  Map<String, dynamic> toJson() => _$D1ResultToJson(this, _toJsonT);

  static T _fromJsonT<T>(Object? obj) {
    if (obj == null) {
      return null as T;
    } else if (obj is int || obj is double || obj is String) {
      return obj as T;
    } else if (T == UserBattleData) {
      return UserBattleData.fromJson(Map<String, dynamic>.from(obj as Map)) as T;
    }
    throw FormatException('unknown type: ${obj.runtimeType}');
  }

  static Object? _toJsonT<T>(T value) {
    if (value == null) {
      return null;
    } else if (value is int || value is double || value is String) {
      return value;
    }
    throw FormatException('unknown type: ${value.runtimeType} : $T');
  }
}

@JsonSerializable()
class UserBattleData {
  int id;
  int ver;
  String userId;
  int questId;
  int phase;
  String enemyHash;
  String record;

  UserBattleData({
    required this.id,
    required this.ver,
    required this.userId,
    required this.questId,
    required this.phase,
    required this.enemyHash,
    required this.record,
  });

  factory UserBattleData.fromJson(Map<String, dynamic> json) => _$UserBattleDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserBattleDataToJson(this);
}
