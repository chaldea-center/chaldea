import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/faker/runtime.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/utils/utils.dart';

typedef UserQuestStat = ({UserQuestEntity userQuest, Quest quest, int count});

class FgoAnnualReportData {
  final MasterDataManager mstData;
  final Region region;
  final UserGameEntity userGame;

  List<Object> errors = [];

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
  List<int> get ownedSvtReleasedBondEquipIds {
    List<int> _mineReleasedBondEquipIds = [
      for (final equipId in regionReleasedBondEquipIds)
        if (ownedSvtCollections.containsKey(db.gameData.craftEssencesById[equipId]?.bondEquipOwner)) equipId,
    ];
    return _mineReleasedBondEquipIds;
  }

  // summon
  Map<int, MstGacha> mstGachas = {};
  Map<int, MstShop> mstShops = {};
  Map<int, UserGachaEntity> userStoneGachas = {};
  List<UserGachaEntity> luckyBagGachas = [];
  bool hasUnknownGacha = false;
  int summonSsrCount = 0;
  int summonPullCount = 0;
  double summonSsrRate = 0; // 0~100, or NaN
  GachaLuckyGrade get luckyGrade => GachaLuckyGrade.fromRate(summonSsrRate);
  String summonComment = ""; // rand
  List<UserGachaEntity> mostPullGachas = [];
  List<UserGachaEntity> mostPullGachasThisYear = [];

  // quests
  static const int kMaxQuestCount = 100;
  List<UserQuestStat> mostClearFreeQuests = [];
  List<UserQuestStat> mostClearEventFreeQuests = [];
  List<UserQuestStat> mostClearRaidQuests = [];
  List<UserQuestStat> mostChallengeFailQuests = [];

  // misc
  List<UserServantCollectionEntity> usedLanternSvt = [];
  int get usedLanternCount => Maths.sum(usedLanternSvt.map((e) => e.usedLanternCount));

  List<UserShopEntity> svtAnonymousShops = [];
  int get usedSvtAnonymousCount => Maths.sum(svtAnonymousShops.map((e) => e.num));

  int usedCrystalCountActive = 0;
  int usedCrystalCountPassive = 0;
  int get usedCrystalCount => usedCrystalCountActive + usedCrystalCountPassive;

  Map<UserServantEntity, int> usedGrailUserSvts = {};
  int get usedGrailCount => Maths.sum(usedGrailUserSvts.values);

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
    Duration? expireAfter,
  }) async {
    final report = FgoAnnualReportData(mstData: mstData, region: region, userGame: mstData.user!);
    report.totalLogin = mstData.userLogin.first.totalLoginCount;
    if (year == null) {
      final now = DateTime.now();
      if (now.month == 1 && report.userGame.createdAt.sec2date().year > now.year) {
        year = now.year - 1;
      } else {
        year = now.year;
      }
    }
    report.curYear = year;

    // svt stat
    final _regionReleasedSvtIds = db.gameData.mappingData.entityRelease.ofRegion(region);
    for (final svt in db.gameData.servantsById.values) {
      if (svt.collectionNo > 0 && svt.isUserSvt && (region.isJP || _regionReleasedSvtIds?.contains(svt.id) == true)) {
        report.regionReleasedPlayableSvtIds.add(svt.id);
        report.regionReleasedPlayableSvtCountByRarity.addNum(svt.rarity, 1);
      }
    }
    report.ownedSvtCollections = {
      for (final collection in mstData.userSvtCollection)
        if (collection.isOwned && report.regionReleasedPlayableSvtIds.contains(collection.svtId))
          collection.svtId: collection,
    };
    for (final collection in report.ownedSvtCollections.values) {
      final svt = db.gameData.servantsById[collection.svtId];
      SvtClass svtClass = SvtClass.unknown;
      if (svt != null) {
        for (final cls in kSvtClassGroup) {
          if (SvtClassX.match(svt.className, cls)) {
            svtClass = cls;
            break;
          }
        }
        report.ownedSvtCollectionByRarity.addNum(svt.rarity, 1);
      }
      report.ownedSvtCollectionByClass.addNum(svtClass, 1);
    }
    for (final userSvt in mstData.userSvtAndStorage) {
      final grailCount = userSvt.getExceedCountByGrail();
      if (grailCount > 0) {
        report.usedGrailUserSvts[userSvt] = grailCount;
      }
      report.usedCrystalCountActive += userSvt.skillLvs.where((e) => e == 10).length;
      final svt = db.gameData.servantsById[userSvt.svtId];
      if (svt == null) continue;
      if (svt.collectionNo > 0 && svt.isUserSvt && svt.rarity == 5) {
        report.curSsrTdLv += userSvt.treasureDeviceLv1;
      }
    }
    for (final skill in mstData.userSvtAppendPassiveSkillLv) {
      report.usedCrystalCountPassive += skill.appendPassiveSkillLvs.where((e) => e == 10).length;
    }

    // bond
    for (final collection in report.ownedSvtCollections.values) {
      final svt = db.gameData.servantsById[collection.svtId];
      if (!collection.isOwned) continue;
      if (svt == null || svt.collectionNo == 0 || !svt.isUserSvt) continue;
      if (collection.usedLanternCount > 0) report.usedLanternSvt.add(collection);
      if (collection.friendshipRank >= 10) report.bond10SvtCollections[collection.svtId] = collection;
      if (collection.friendshipRank >= 15) report.bond15SvtCollections[collection.svtId] = collection;
    }
    final releasedSvtEquipIds = db.gameData.mappingData.entityRelease.ofRegion(region);
    final regionBondEquips = {
      for (final ce in db.gameData.craftEssencesById.values)
        if (ce.flags.contains(SvtFlag.svtEquipFriendShip) &&
            (region == Region.jp || releasedSvtEquipIds?.contains(ce.id) == true))
          ce.id: ce,
    };
    report.regionReleasedBondEquipIds = regionBondEquips.keys.toList();
    for (final userSvtEquip in mstData.userSvt.followedBy(mstData.userSvtStorage)) {
      if (regionBondEquips.containsKey(userSvtEquip.svtId)) {
        (report.bondEquipHistoryByYear[region.getDateTimeByOffset(userSvtEquip.createdAt).year] ??= []).add(
          userSvtEquip,
        );
      }
    }

    // summon
    final _rawGachas = await AtlasApi.rawGachas(region: region, expireAfter: expireAfter);
    final _extraGachas = await AtlasApi.rawGachasExtra(region: region, expireAfter: expireAfter);
    if (_rawGachas == null || _extraGachas == null) {
      report.errors.add(
        Language.isZH ? '卡池数据下载失败，卡池统计结果不准确' : 'Gacha data download failed, gacha statistics may be incorrect',
      );
    }

    report.mstGachas = {
      for (final gacha in [...?_rawGachas, ...?_extraGachas]) gacha.id: gacha,
    };

    final _shops = await AtlasApi.rawShops(region: region, expireAfter: expireAfter);
    if (_shops == null) {
      report.errors.add(
        Language.isZH
            ? '商店数据下载失败，无记名灵基统计可能不准确'
            : 'Shop data download failed, Unregistered Spirit Origin data may be incorrect',
      );
    } else {
      report.mstShops = {for (final shop in _shops) shop.id: shop};
    }

    for (final userGacha in mstData.userGacha) {
      final gacha = report.mstGachas[userGacha.gachaId];
      if (gacha != null && gacha.isFpGacha) continue; // skip FP summon
      if (userGacha.gachaId < 100) continue;
      if (gacha == null) report.hasUnknownGacha = true;
      report.userStoneGachas[userGacha.gachaId] = userGacha;
      if (gacha != null && gacha.isLuckyBag) {
        report.luckyBagGachas.add(userGacha);
      }
      report.summonPullCount += userGacha.num;
    }

    final _userGachas = report.userStoneGachas.values.toList();
    _userGachas.sort2((e) => -e.num);
    report.mostPullGachas = _userGachas.toList();
    report.mostPullGachasThisYear = _userGachas.where((userGacha) {
      final gacha = report.mstGachas[userGacha.gachaId];
      if (gacha == null) return false;
      if (gacha.closedAt - gacha.openedAt >= 365 * kSecsPerDay) return false;
      final openedAt = region.getDateTimeByOffset(gacha.openedAt),
          closedAt = region.getDateTimeByOffset(gacha.closedAt);
      return openedAt.year == report.curYear || closedAt.year == report.curYear;
    }).toList();

    for (final collection in report.ownedSvtCollections.values) {
      final svt = db.gameData.servantsById[collection.svtId];
      if (svt == null || svt.rarity != 5) continue;
      if (!collection.isOwned) continue;
      if (const [800100, 2801200].contains(collection.svtId)) continue; // Mash, Solomon
      if (const [
        SvtObtain.eventReward,
        // SvtObtain.friendPoint,
        SvtObtain.clearReward,
        SvtObtain.unavailable,
      ].any((e) => svt.obtains.contains(e))) {
        continue;
      }
      report.summonSsrCount += collection.totalGetNum;
    }
    report.summonSsrCount -= report.luckyBagGachas.length;
    report.summonPullCount -= report.luckyBagGachas.length;
    if (report.summonSsrCount > 0) {
      report.summonSsrRate = report.summonSsrCount / report.summonPullCount * 100;
    }

    // lucky bag
    report.luckyBagGachas.sortByList((userGacha) {
      final gacha = report.mstGachas[userGacha.gachaId];
      return <int>[gacha == null ? 0 : 1, -(gacha?.openedAt ?? userGacha.gachaId), -userGacha.gachaId];
    });

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

      final (:successNum, :failNum) = userQuest.getSuccessFailedNum(quest);

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

      if (failNum > 0) {
        _add(challengeFailQuests, failNum);
      }
    }

    freeQuests.sortByList((e) => [-e.count, -e.userQuest.updatedAt, -e.quest.id]);
    eventFreeQuests.sortByList((e) => [-e.count, -e.userQuest.updatedAt, -e.quest.id]);
    raidQuests.sortByList((e) => [-e.count, -e.userQuest.updatedAt, -e.quest.id]);
    challengeFailQuests.sortByList((e) => [-e.count, -e.userQuest.updatedAt, -e.quest.id]);

    report.mostClearFreeQuests = freeQuests.take(kMaxQuestCount).toList();
    report.mostClearEventFreeQuests = eventFreeQuests.take(kMaxQuestCount).toList();
    report.mostClearRaidQuests = raidQuests.take(kMaxQuestCount).toList();
    report.mostChallengeFailQuests = challengeFailQuests.take(kMaxQuestCount).toList();

    // misc
    for (final userShop in mstData.userShop) {
      final shop = report.mstShops[userShop.shopId];
      bool isAnonymousShop;
      if (shop != null) {
        isAnonymousShop = shop.shopType == ShopType.svtAnonymous.value;
      } else {
        isAnonymousShop = userShop.isSvtAnonymousShop(region: region);
      }
      if (isAnonymousShop) report.svtAnonymousShops.add(userShop);
    }

    return report;
  }
}

enum GachaLuckyGrade {
  grandLucky,
  lucky,
  middle,
  notLucky,
  unlucky,
  veryUnlucky;

  // 0-100
  static GachaLuckyGrade fromRate(double percent) {
    if (percent >= 1.25) return grandLucky;
    if (percent >= 1.15) return lucky;
    if (percent >= 1.05) return middle;
    if (percent >= 1.0) return notLucky;
    if (percent >= 0.85) return unlucky;
    return veryUnlucky;
  }

  String get shownName => switch (this) {
    grandLucky => S.current.chaldea_report_luck_grand_lucky,
    lucky => S.current.chaldea_report_luck_lucky,
    middle => S.current.chaldea_report_luck_mid_lucky,
    notLucky => S.current.chaldea_report_luck_not_lucky,
    unlucky => S.current.chaldea_report_luck_unlucky,
    veryUnlucky => S.current.chaldea_report_luck_very_unlucky,
  };

  String get comment => switch (this) {
    grandLucky => S.current.chaldea_report_luck_grand_lucky_desc,
    lucky => S.current.chaldea_report_luck_lucky_desc,
    middle => S.current.chaldea_report_luck_mid_lucky_desc,
    notLucky => S.current.chaldea_report_luck_not_lucky_desc,
    unlucky => S.current.chaldea_report_luck_unlucky_desc,
    veryUnlucky => S.current.chaldea_report_luck_very_unlucky_desc,
  };
}
