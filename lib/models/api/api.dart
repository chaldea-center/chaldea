import 'package:flutter/widgets.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/utils/url.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import '../../packages/logger.dart';
import '../userdata/_helper.dart';
import '../userdata/battle.dart';

part '../../generated/models/api/api.g.dart';

@JsonSerializable()
class WorkerResponse {
  bool success;
  String? message;
  dynamic body;

  WorkerResponse({
    required this.success,
    this.message,
    this.body,
  });

  WorkerResponse.failed([this.message = "Error"])
      : success = false,
        body = null;

  factory WorkerResponse.fromJson(Map<dynamic, dynamic> json) => _$WorkerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WorkerResponseToJson(this);

  Future<void> showDialog([BuildContext? context]) {
    if (success) {
      return SimpleCancelOkDialog(
        title: Text(S.current.success),
        content: message == null ? null : Text(message!),
        scrollable: true,
        hideCancel: true,
      ).showDialog(context);
    } else {
      return SimpleCancelOkDialog(
        title: Text(S.current.error),
        content: Text(message ?? body?.toString() ?? "Error"),
        scrollable: true,
        hideCancel: true,
      ).showDialog(context);
    }
  }

  Future<void> showToast() {
    if (success) {
      return EasyLoading.showSuccess(message ?? S.current.success);
    } else {
      return EasyLoading.showError(message ?? body?.toString() ?? "Error");
    }
  }
}

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

  factory D1Result.fromJson(Map<dynamic, dynamic> json) => _$D1ResultFromJson(json, _fromJsonT<T>);

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

  BattleShareData? parse() {
    if (decoded != null) return decoded;
    try {
      if (ver == 1 || ver == 2) {
        return decoded = BattleShareData.parse(record);
      }
    } catch (e, s) {
      logger.e('parse gzip team data failed', e, s);
      return null;
    }
    print('parse failed');
    return null;
  }

  BattleQuestInfo get questInfo {
    return BattleQuestInfo(
      id: questId,
      phase: phase,
      hash: enemyHash,
    );
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  BattleShareData? decoded;

  Uri toShortUri() {
    Uri shareUri = Uri.parse(ChaldeaUrl.app('/laplace/share'));
    shareUri = shareUri.replace(queryParameters: {
      "id": id.toString(),
      "questId": questId.toString(),
      "phase": phase.toString(),
      "enemyHash": enemyHash,
    });
    return shareUri;
  }

  Uri toUriV2() {
    final detail = parse();
    String? data = detail?.toDataV2();
    Uri shareUri = Uri.parse(ChaldeaUrl.app('/laplace/share'));
    shareUri = shareUri.replace(queryParameters: {
      if (data != null) "data": data,
      "questId": (detail?.quest?.id ?? questId).toString(),
      "phase": (detail?.quest?.phase ?? phase).toString(),
      "enemyHash": detail?.quest?.hash ?? enemyHash,
    });
    return shareUri;
  }
}
