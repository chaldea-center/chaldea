import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:archive/archive.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/utils/url.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import '../../packages/logger.dart';
import '../userdata/_helper.dart';
import '../userdata/battle.dart';
import '../userdata/userdata.dart';

part '../../generated/models/api/api.g.dart';

@JsonSerializable()
class WorkerResponse {
  int? status;
  dynamic error;

  String? message;
  dynamic body;

  WorkerResponse({
    this.status,
    this.error,
    this.message,
    this.body,
  });

  factory WorkerResponse.fromJson(Map<dynamic, dynamic> json) => _$WorkerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WorkerResponseToJson(this);

  bool get hasError => error != null;

  String get fullMessage {
    String msg = <String>[
      if (message != null) message!,
      if (error != null) error.toString(),
      if (message == null && body != null) body.toString(),
    ].join('\n');
    return msg.isEmpty ? 'No message' : msg;
  }

  Future<void> showDialog([BuildContext? context]) {
    return SimpleCancelOkDialog(
      title: Text(error != null ? S.current.error : S.current.success),
      content: Text(fullMessage),
      scrollable: true,
      hideCancel: true,
    ).showDialog(context);
  }

  Future<void> showToast() {
    final msg = fullMessage;
    if (hasError) {
      return EasyLoading.showError(msg);
    } else {
      return EasyLoading.showSuccess(message ?? S.current.success);
    }
  }
}

// users

abstract class ChaldeaUserRole {
  static const int member = 1;
  static const int team = 2;
  static const int admin = 16;
}

@JsonSerializable()
class ChaldeaUser {
  int id;
  String name;
  int role;
  String? secret; // only present in signup/login/change-password

  ChaldeaUser({
    required this.id,
    required this.name,
    this.role = ChaldeaUserRole.member,
    this.secret,
  });

  factory ChaldeaUser.fromJson(Map<String, dynamic> json) => _$ChaldeaUserFromJson(json);

  Map<String, dynamic> toJson() => _$ChaldeaUserToJson(this);

  bool get isAdmin => role == 16;
}

@JsonSerializable()
class UserBackupData {
  final int id;
  final int userId;
  final String? appVer; // length<=16
  final String? os; // length<=64
  final int createdAt;
  final String content; // base64

  @JsonKey(includeFromJson: false, includeToJson: false)
  final UserData? decoded;

  UserBackupData({
    required this.id,
    required this.userId,
    this.appVer,
    this.os,
    required this.createdAt,
    required this.content,
  }) : decoded = decode(content);

  static String encode(UserData userData) {
    return base64Encode(GZipEncoder().encode(utf8.encode(jsonEncode(userData)))!);
  }

  static UserData? decode(String content) {
    try {
      return UserData.fromJson(jsonDecode(utf8.decode(GZipDecoder().decodeBytes(base64Decode(content)))));
    } catch (e, s) {
      logger.e('decode user backup failed', e, s);
      return null;
    }
  }

  factory UserBackupData.fromJson(Map<String, dynamic> json) => _$UserBackupDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserBackupDataToJson(this);
}

@JsonSerializable()
class TeamVoteData {
  int up;
  int down;
  int mine;

  TeamVoteData({
    this.up = 0,
    this.down = 0,
    this.mine = 0,
  });

  TeamVoteData copy() {
    return TeamVoteData(up: up, down: down, mine: mine);
  }

  void updateMyVote(bool isUpVote) {
    if (isUpVote) {
      if (mine == 0) {
        up += 1;
        mine = 1;
      } else if (mine == 1) {
        up -= 1;
        mine = 0;
      } else if (mine == -1) {
        up += 1;
        down -= 1;
        mine = 1;
      }
    } else {
      if (mine == 0) {
        down += 1;
        mine = -1;
      } else if (mine == 1) {
        up -= 1;
        down += 1;
        mine = -1;
      } else if (mine == -1) {
        down -= 1;
        mine = 0;
      }
    }
  }

  factory TeamVoteData.fromJson(Map<String, dynamic> json) => _$TeamVoteDataFromJson(json);

  Map<String, dynamic> toJson() => _$TeamVoteDataToJson(this);
}

// teams
@JsonSerializable()
class UserBattleData {
  int id;
  int ver;
  String? appVer;
  int userId;
  int questId;
  int phase;
  String enemyHash;
  int createdAt;
  String content;
  // stats
  String? username;
  TeamVoteData votes;
  @JsonKey(includeFromJson: false, includeToJson: false)
  TeamVoteData? tempVotes;

  UserBattleData({
    required this.id,
    required this.ver,
    required this.appVer,
    required this.userId,
    required this.questId,
    required this.phase,
    required this.enemyHash,
    required this.createdAt,
    required this.content,
    this.username,
    TeamVoteData? votes,
  }) : votes = votes ?? TeamVoteData();

  factory UserBattleData.fromJson(Map<String, dynamic> json) => _$UserBattleDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserBattleDataToJson(this);

  BattleShareData? parse() {
    if (decoded != null) return decoded;
    try {
      if (ver == 1 || ver == 2) {
        return decoded = BattleShareData.parse(content);
      }
    } catch (e, s) {
      logger.e('parse gzip team data failed', e, s);
      return null;
    }
    print('parse failed');
    return null;
  }

  BattleQuestInfo get questInfo {
    return BattleQuestInfo(id: questId, phase: phase, enemyHash: enemyHash);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  BattleShareData? decoded;

  Uri toShortUri() {
    Uri shareUri = Uri.parse(ChaldeaUrl.deepLink('/laplace/share'));
    shareUri = shareUri.replace(queryParameters: {
      "id": id.toString(),
      // "questId": questId.toString(),
      // "phase": phase.toString(),
      // "enemyHash": enemyHash,
    });
    return shareUri;
  }

  Uri toUriV2() {
    final detail = parse();
    String? data = detail?.toDataV2();
    Uri shareUri = Uri.parse(ChaldeaUrl.deepLink('/laplace/share'));
    shareUri = shareUri.replace(queryParameters: {
      if (data != null) "data": data,
      "questId": (detail?.quest?.id ?? questId).toString(),
      "phase": (detail?.quest?.phase ?? phase).toString(),
      "enemyHash": detail?.quest?.enemyHash ?? enemyHash,
    });
    return shareUri;
  }
}

class PaginatedData<T> {
  final int offset;
  final int limit;
  final int? total;
  final List<T> data;

  PaginatedData({
    this.offset = 0,
    this.limit = 0,
    this.total,
    required this.data,
  });

  bool get hasNextPage {
    if (total != null) {
      return offset + data.length < total!;
    }
    if (limit > 0) {
      return data.length >= limit;
    }
    return data.isNotEmpty;
  }
}

@JsonSerializable()
class TeamQueryResult extends PaginatedData<UserBattleData> {
  TeamQueryResult({
    super.offset = 0,
    super.limit = 0,
    super.total,
    required super.data,
  });

  factory TeamQueryResult.fromJson(Map<String, dynamic> json) => _$TeamQueryResultFromJson(json);

  Map<String, dynamic> toJson() => _$TeamQueryResultToJson(this);
}
