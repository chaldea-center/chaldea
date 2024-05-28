import 'dart:convert';

import 'package:chaldea/models/gamedata/_helper.dart';
import 'package:chaldea/utils/extension.dart';
import '../../app/modules/import_data/autologin/agent.dart';
import '../gamedata/common.dart';
import '../gamedata/toplogin.dart';

part '../../generated/models/userdata/autologin.g.dart';

@JsonSerializable()
class UserAuth {
  final String? source; // bytes in base64
  final String? code;

  final String userId;
  final String authKey;
  final String secretKey;
  final String? saveDataVer;
  final String? userCreateServer;

  int get userIdInt => int.parse(userId);

  UserAuth({
    this.source,
    this.code,
    required this.userId,
    required this.authKey,
    required this.secretKey,
    this.saveDataVer,
    this.userCreateServer,
  });

  bool get isValid => isValidKeys(userId, authKey, secretKey);

  static String normTransferCode(String code) {
    code = code.trim();
    if (!code.startsWith('ZSv/')) {
      int start = code.indexOf('ZSv/');
      if (start >= 0 && start < 5) {
        code = code.substring(start);
      }
    }
    return code;
  }

  static bool isValidCode(String code) {
    code = normTransferCode(code);
    try {
      base64Decode(code);
    } catch (e) {
      return false;
    }
    return true;
  }

  static bool isValidKeys(String userId, String authKey, String secretKey) {
    if (int.tryParse(userId) == null || userId.length < 9) return false;
    if (authKey.length != 29) return false;
    if (secretKey.length != 29) return false;
    return true;
  }

  static bool checkGameServer(Region region, String server) {
    if (region == Region.jp) return server.contains('fate-go.jp');
    if (region == Region.na) return server.contains('fate-go.us');
    return false;
  }

  factory UserAuth.fromJson(Map<String, dynamic> json) => _$UserAuthFromJson(json);

  Map<String, dynamic> toJson() => _$UserAuthToJson(this);
}

@JsonSerializable()
class AutoLoginData {
  @RegionConverter()
  Region region;
  UserAuth? auth;
  String? userAgent;
  String? deviceInfo;
  NACountry country;
  bool useThisDevice;
  // result
  int? lastLogin;
  UserGameEntity? userGame;
  @JsonKey(includeFromJson: false, includeToJson: false)
  FateServerResponse? response;

  AutoLoginData({
    this.region = Region.jp,
    this.auth,
    this.userAgent,
    this.deviceInfo,
    this.country = NACountry.unitedStates,
    this.useThisDevice = false,
    this.lastLogin,
    this.userGame,
  });
  factory AutoLoginData.fromJson(Map<String, dynamic> json) => _$AutoLoginDataFromJson(json);

  Map<String, dynamic> toJson() => _$AutoLoginDataToJson(this);
}

enum NACountry {
  // none(0),
  unitedStates(840),
  canada(124),
  australia(36),
  unitedKingdom(826),
  germany(276),
  france(250),
  singapore(702),
  italy(380),
  spain(724),
  philippines(608),
  mexico(484),
  thailand(764),
  netherlands(528),
  brazil(76),
  finland(246),
  sweden(752),
  chile(152),
  newZealand(554),
  poland(616),
  switzerland(756),
  austria(40),
  ireland(372),
  belgium(56),
  norway(576),
  denmark(208),
  portugal(620),
  ;

  const NACountry(this.countryId);
  final int countryId;

  String get displayName => name.toTitle();
}
