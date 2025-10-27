import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/packages/logger.dart';
import 'network.dart';

class FakerAgentData {
  // battle
  BattleEntity? curBattle;
  BattleEntity? lastBattle;
  BattleResultData? lastBattleResultData;
  FResponse? lastResp;

  // raid
  Map<int, Map<int, EventRaidInfoRecord>> raidRecords = {};

  EventRaidInfoRecord getRaidRecord(int eventId, int day) =>
      raidRecords.putIfAbsent(eventId, () => {}).putIfAbsent(day, () => EventRaidInfoRecord());

  // login result
  final loginResultData = LoginResultData();

  void updateLoginResult(FateTopLogin resp) {
    for (final response in resp.responses) {
      if (!response.isSuccess()) continue;
      final success = response.success ?? {};
      if (LoginResultData.fieldMap.values.any(success.containsKey)) {
        try {
          loginResultData.mergeLoginBonus(LoginResultData.fromJson(success));
        } catch (e) {
          logger.e('LoginResultData parse failed in nid [${response.nid}]');
        }
      }
    }
  }
}

class EventRaidInfoRecord {
  EventRaidEntity? eventRaid;
  List<({int timestamp, BattleRaidInfo raidInfo, int? battleId})> history = [];
}
