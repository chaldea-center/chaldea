import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/faker/runtime.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

typedef UserQuestStat = ({UserQuestEntity userQuest, Quest quest, int count});

class FgoAnnualReportData {
  final MasterDataManager mstData;
  final Region region;
  final UserGameEntity userGame;

  DateTime createdAt = DateTime.now();
  int curYear = DateTime.now().year;
  String? avatarUrl; // custom url or base64 string
  int totalLogin = 0;

  // svt stat
  static const List<SvtClass> kSvtClassGroup = [...SvtClassX.regular, SvtClass.EXTRA1, SvtClass.EXTRA2];
  List<int> regionReleasedPlayableSvtIds = [];
  Map<int, int> regionReleasedPlayableSvtCountByRarity = {};
  Map<int, UserServantCollectionEntity> ownedSvtCollections = {};
  Map<SvtClass, int> ownedSvtCollectionByClass = {};
  Map<int, int> ownedSvtCollectionByRarity = {};
  int curSsrTdLv = 0;

  // bond
  List<int> regionReleasedBondEquipIds = [];
  Map<int, UserServantCollectionEntity> bond10SvtCollections = {};
  Map<int, UserServantCollectionEntity> bond15SvtCollections = {};
  Map<int, List<UserServantEntity>> bondEquipHistoryByYear = {};

  // summon
  Map<int, MstGacha> mstGachas = {};
  Map<int, UserGachaEntity> userStoneGachas = {};
  List<UserGachaEntity> luckyBagGachas = [];
  bool hasUnknownGacha = false;
  int summonSsrCount = 0;
  int summonPullCount = 0;
  double summonSsrRate = 0; // 0~1, or NaN
  String summonComment = ""; // rand
  List<UserGachaEntity> mostPullGachas = [];
  List<UserGachaEntity> mostPullGachasThisYear = [];

  // quests
  List<UserQuestStat> mostClearFreeQuests = [];
  List<UserQuestStat> mostClearEventFreeQuests = [];
  List<UserQuestStat> mostClearRaidQuests = [];
  List<UserQuestStat> mostChallengeFailQuests = [];

  FgoAnnualReportData({
    required this.mstData,
    required this.region,
    required this.userGame,
    //
  });

  static Future<FgoAnnualReportData> parse({
    FakerRuntime? runtime,
    required MasterDataManager mstData,
    required Region region,
    int? year,
  }) async {
    final data = FgoAnnualReportData(mstData: mstData, region: region, userGame: mstData.user!);
    data.totalLogin = mstData.userLogin.first.totalLoginCount;
    if (year == null) {
      final now = DateTime.now();
      if (now.month == 1 && data.userGame.createdAt.sec2date().year > now.year) {
        year = now.year - 1;
      } else {
        year = now.year;
      }
    }
    data.curYear = year;

    // svt stat
    final _regionReleasedSvtIds = db.gameData.mappingData.entityRelease.ofRegion(region);
    for (final svt in db.gameData.servantsById.values) {
      if (svt.collectionNo > 0 && svt.isUserSvt && (region.isJP || _regionReleasedSvtIds?.contains(svt.id) == true)) {
        data.regionReleasedPlayableSvtIds.add(svt.id);
        data.regionReleasedPlayableSvtCountByRarity.addNum(svt.rarity, 1);
      }
    }
    data.ownedSvtCollections = {
      for (final collection in mstData.userSvtCollection)
        if (collection.isOwned && data.regionReleasedPlayableSvtIds.contains(collection.svtId))
          collection.svtId: collection,
    };
    for (final collection in data.ownedSvtCollections.values) {
      final svt = db.gameData.servantsById[collection.svtId];
      SvtClass svtClass = SvtClass.unknown;
      if (svt != null) {
        for (final cls in kSvtClassGroup) {
          if (SvtClassX.match(svt.className, cls)) {
            svtClass = cls;
            break;
          }
        }
        data.ownedSvtCollectionByRarity.addNum(svt.rarity, 1);
      }
      data.ownedSvtCollectionByClass.addNum(svtClass, 1);
    }
    for (final userSvt in mstData.userSvt.followedBy(mstData.userSvtStorage)) {
      final svt = db.gameData.servantsById[userSvt.svtId];
      if (svt != null && svt.collectionNo > 0 && svt.isUserSvt && svt.rarity == 5) {
        data.curSsrTdLv += userSvt.treasureDeviceLv1;
      }
    }

    // bond
    for (final collection in data.ownedSvtCollections.values) {
      final svt = db.gameData.servantsById[collection.svtId];
      if (!collection.isOwned || svt == null || svt.collectionNo == 0 || !svt.isUserSvt) continue;
      if (collection.friendshipRank >= 10) data.bond10SvtCollections[collection.svtId] = collection;
      if (collection.friendshipRank >= 15) data.bond15SvtCollections[collection.svtId] = collection;
    }
    final releasedSvtEquipIds = db.gameData.mappingData.entityRelease.ofRegion(region);
    final regionBondEquips = {
      for (final ce in db.gameData.craftEssencesById.values)
        if (ce.flags.contains(SvtFlag.svtEquipFriendShip) &&
            (region == Region.jp || releasedSvtEquipIds?.contains(ce.id) == true))
          ce.id: ce,
    };
    data.regionReleasedBondEquipIds = regionBondEquips.keys.toList();
    for (final userSvtEquip in mstData.userSvt.followedBy(mstData.userSvtStorage)) {
      if (regionBondEquips.containsKey(userSvtEquip.svtId)) {
        (data.bondEquipHistoryByYear[region.getDateTimeByOffset(userSvtEquip.createdAt).year] ??= []).add(userSvtEquip);
      }
    }

    // summon
    final _gachas = await AtlasApi.fullRawGachas(region);
    if (_gachas == null) {
      throw Exception('Download gacha data failed.\n下载卡池数据失败，请尝试科学上网');
    }
    data.mstGachas = {for (final gacha in _gachas) gacha.id: gacha};

    for (final userGacha in mstData.userGacha) {
      final gacha = data.mstGachas[userGacha.gachaId];
      if (gacha != null && gacha.isFpGacha) continue; // skip FP summon
      data.userStoneGachas[userGacha.gachaId] = userGacha;
      if (gacha != null && gacha.isLuckyBag) {
        data.luckyBagGachas.add(userGacha);
      }
      data.summonPullCount += userGacha.num;
    }

    final _userGachas = data.userStoneGachas.values.toList();
    _userGachas.sort2((e) => -e.num);
    data.mostPullGachas = _userGachas.take(3).toList();
    data.mostPullGachasThisYear = _userGachas
        .where((userGacha) {
          final gacha = data.mstGachas[userGacha.gachaId];
          if (gacha == null) return false;
          if (gacha.closedAt - gacha.openedAt >= 365 * kSecsPerDay) return false;
          final openedAt = region.getDateTimeByOffset(gacha.openedAt),
              closedAt = region.getDateTimeByOffset(gacha.closedAt);
          return openedAt.year == data.curYear || closedAt.year == data.curYear;
        })
        .take(3)
        .toList();

    for (final userSvt in data.ownedSvtCollections.values) {
      final svt = db.gameData.servantsById[userSvt.svtId];
      if (svt == null || svt.rarity != 5) continue;
      if (const [800100, 2801200].contains(userSvt.svtId)) continue; // Mash, Solomon
      if (const [
        SvtObtain.eventReward,
        // SvtObtain.friendPoint,
        SvtObtain.clearReward,
        SvtObtain.unavailable,
      ].any((e) => svt.obtains.contains(e))) {
        continue;
      }
      data.summonSsrCount += userSvt.totalGetNum;
    }
    data.summonSsrCount -= data.luckyBagGachas.length;
    data.summonPullCount -= data.luckyBagGachas.length;
    if (data.summonSsrCount > 0) {
      data.summonSsrRate = data.summonSsrCount / data.summonPullCount;
    }

    // lucky bag
    for (final userGacha in mstData.userGacha) {
      final gacha = data.mstGachas[userGacha.gachaId];
      if (gacha == null) {
        data.hasUnknownGacha = true;
      } else if (gacha.isLuckyBag) {
        data.luckyBagGachas.add(userGacha);
      }
    }

    // quests
    List<UserQuestStat> freeQuests = [];
    List<UserQuestStat> eventFreeQuests = [];
    List<UserQuestStat> raidQuests = [];
    List<UserQuestStat> challengeFailQuests = [];

    for (final userQuest in mstData.userQuest) {
      final quest = db.gameData.quests[userQuest.questId];
      if (quest == null) continue;
      void _add(List<UserQuestStat> quests, int count) {
        quests.add((userQuest: userQuest, quest: quest, count: count));
      }

      int successNum, failedNum;
      if (quest.warId == WarId.daily) {
        // assume all success. clearNum is not accurate because once reset
        successNum = userQuest.challengeNum;
        failedNum = 0;
      } else {
        successNum = userQuest.clearNum > 0 ? userQuest.clearNum + userQuest.questPhase - 1 : userQuest.questPhase;
        failedNum = userQuest.challengeNum - successNum;
      }

      if (quest.isRepeatRaid) {
        _add(raidQuests, successNum);
      } else if (quest.isAnyFree) {
        if (quest.closedAt > kNeverClosedTimestamp ||
            quest.isMainStoryFree ||
            quest.war?.parentWars.contains(WarId.grandBoardWar) == true) {
          _add(freeQuests, successNum);
        } else {
          _add(eventFreeQuests, successNum);
        }
      }

      if (failedNum > 0) {
        _add(challengeFailQuests, failedNum);
      }
    }

    freeQuests.sortByList((e) => [-e.count, -e.userQuest.updatedAt, -e.quest.id]);
    eventFreeQuests.sortByList((e) => [-e.count, -e.userQuest.updatedAt, -e.quest.id]);
    raidQuests.sortByList((e) => [-e.count, -e.userQuest.updatedAt, -e.quest.id]);
    challengeFailQuests.sortByList((e) => [-e.count, -e.userQuest.updatedAt, -e.quest.id]);

    data.mostClearFreeQuests = freeQuests.take(3).toList();
    data.mostClearEventFreeQuests = eventFreeQuests.take(3).toList();
    data.mostClearRaidQuests = raidQuests.take(3).toList();
    data.mostChallengeFailQuests = challengeFailQuests.take(3).toList();

    return data;
  }
}
