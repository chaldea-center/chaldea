import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/faker/runtime.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class FgoAnnualReportData2 {
  final MasterDataManager mstData;
  final Region region;
  final UserGameEntity userGame;

  int curYear = DateTime.now().year;
  String? avatarUrl; // custom url or base64 string
  int totalLogin = 0;

  // svt stat
  static const List<SvtClass> kSvtClassGroup = [...SvtClassX.regular, SvtClass.EXTRA1, SvtClass.EXTRA2];
  List<int> regionReleasedPlayableSvtIds = [];
  Map<int, UserServantCollectionEntity> ownedSvtCollections = {};
  Map<SvtClass, int> ownedSvtCollectionByClass = {};
  int curSsrTdLv = 0;

  // bond
  List<int> regionReleasedBondEquipIds = [];
  Map<int, UserServantCollectionEntity> bond10SvtCollections = {};
  Map<int, UserServantCollectionEntity> bond15SvtCollections = {};
  Map<int, List<UserServantCollectionEntity>> bondEquipHistoryByYear = {};

  // summon
  Map<int, MstGacha> mstGachas = {};
  Map<int, UserGachaEntity> userStoneGachas = {};
  List<UserGachaEntity> luckyBagGachas = [];
  int summonSsrCount = 0;
  int summonPullCount = 0;
  double summonSsrRate = 0; // 0~1, or NaN
  String summonComment = ""; // rand
  List<UserGachaEntity> mostPullGachas = [];
  List<UserGachaEntity> mostPullGachasThisYear = [];

  FgoAnnualReportData2({
    required this.mstData,
    required this.region,
    required this.userGame,
    //
  });

  static Future<FgoAnnualReportData2> parse({
    FakerRuntime? runtime,
    required MasterDataManager mstData,
    required Region region,
    int? year,
  }) async {
    final data = FgoAnnualReportData2(mstData: mstData, region: region, userGame: mstData.user!);
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
    for (final collection in mstData.userSvtCollection) {
      if (collection.isOwned && regionBondEquips.containsKey(collection.svtId)) {
        (data.bondEquipHistoryByYear[region.getDateTimeByOffset(collection.createdAt).year] ??= []).add(collection);
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
    return data;
  }
}

class FgoAnnualReportData {
  final UserInfo user;
  final ServantRef topBondServant;
  final ServantRef favoriteServant;
  final int bondCeTotal;
  final Map<int, int> bondCePerYear;
  final Map<String, int> summonedByClass;
  final Map<int, int> summonedByYear;
  final double ssrRate;
  final String luckComment;
  final List<GachaPoolStat> topPoolsThisYear;
  final List<GachaPoolStat> topPoolsAllTime;
  final List<QuestStat> topEventQuestsThisYear;
  final List<QuestStat> topEventQuestsAllTime;
  final List<QuestStat> topDailyQuestsThisYear;
  final List<QuestStat> topDailyQuestsAllTime;
  final String nextYearMessage;
  final String? backgroundImageUrl;

  const FgoAnnualReportData({
    required this.user,
    required this.topBondServant,
    required this.favoriteServant,
    required this.bondCeTotal,
    required this.bondCePerYear,
    required this.summonedByClass,
    required this.summonedByYear,
    required this.ssrRate,
    required this.luckComment,
    required this.topPoolsThisYear,
    required this.topPoolsAllTime,
    required this.topEventQuestsThisYear,
    required this.topEventQuestsAllTime,
    required this.topDailyQuestsThisYear,
    required this.topDailyQuestsAllTime,
    required this.nextYearMessage,
    this.backgroundImageUrl,
  });

  static FgoAnnualReportData fake() {
    final now = DateTime.now();
    return FgoAnnualReportData(
      user: UserInfo(
        id: '123456789',
        name: '迦勒底主任',
        avatarUrl: 'https://static.atlasacademy.io/JP/EnemyMasterFace/enemyMstFace7100300.png',
        registerDate: DateTime(now.year - 5, 3, 14),
        loginCount: 1826,
      ),
      topBondServant: ServantRef(
        name: '玛修·基列莱特',
        cls: 'Shielder',
        imageUrl: 'https://static.atlasacademy.io/JP/Faces/f_8001900.png',
        bondLevel: 15,
      ),
      favoriteServant: ServantRef(
        name: '阿尔托莉雅·潘德拉贡',
        cls: 'Saber',
        imageUrl: 'https://static.atlasacademy.io/JP/Faces/f_1001003.png',
        bondLevel: 12,
      ),
      bondCeTotal: 48,
      bondCePerYear: {now.year - 4: 6, now.year - 3: 9, now.year - 2: 12, now.year - 1: 11, now.year: 10},
      summonedByClass: {
        'Saber': 18,
        'Archer': 14,
        'Lancer': 20,
        'Rider': 12,
        'Caster': 22,
        'Assassin': 16,
        'Berserker': 25,
        'Ruler': 3,
        'Avenger': 2,
        'AlterEgo': 4,
        'MoonCancer': 1,
        'Foreigner': 2,
        'Pretender': 1,
        'Shielder': 1,
      },
      summonedByYear: {now.year - 4: 28, now.year - 3: 35, now.year - 2: 40, now.year - 1: 32, now.year: 30},
      ssrRate: 1.7,
      luckComment: '今年的手气中规中矩，偶有惊喜，稳扎稳打。',
      topPoolsThisYear: [
        GachaPoolStat(
          name: '周年庆限定卡池',
          count: 120,
          timeRangeText: '${now.year}-07',
          imageUrl: 'https://static.atlasacademy.io/JP/SummonBanners/img_summon_83316.png',
        ),
        GachaPoolStat(
          name: '情人节活动限定',
          count: 85,
          timeRangeText: '${now.year}-02',
          imageUrl: 'https://static.atlasacademy.io/JP/SummonBanners/img_summon_83316.png',
        ),
        GachaPoolStat(
          name: '新年限定卡池',
          count: 66,
          timeRangeText: '${now.year}-01',
          imageUrl: 'https://static.atlasacademy.io/JP/SummonBanners/img_summon_83316.png',
        ),
      ],
      topPoolsAllTime: [
        GachaPoolStat(
          name: '第二部开幕纪念',
          count: 180,
          timeRangeText: '${now.year - 3}-12',
          imageUrl: 'https://static.atlasacademy.io/JP/SummonBanners/img_summon_83316.png',
        ),
        GachaPoolStat(
          name: '国服周年庆',
          count: 160,
          timeRangeText: '${now.year - 1}-07',
          imageUrl: 'https://static.atlasacademy.io/JP/SummonBanners/img_summon_83316.png',
        ),
        GachaPoolStat(
          name: '泳装活动限定',
          count: 150,
          timeRangeText: '${now.year - 2}-08',
          imageUrl: 'https://static.atlasacademy.io/JP/SummonBanners/img_summon_83316.png',
        ),
      ],
      topEventQuestsThisYear: [
        QuestStat(name: '泳装活动自由本', count: 320),
        QuestStat(name: '秋日巡礼本', count: 210),
        QuestStat(name: '周年庆挑战本', count: 180),
      ],
      topEventQuestsAllTime: [
        QuestStat(name: '吉尔伽美什狩猎', count: 560),
        QuestStat(name: '万圣节刷南瓜', count: 480),
        QuestStat(name: '复刻泳装自由本', count: 430),
      ],
      topDailyQuestsThisYear: [
        QuestStat(name: '弓本种火超级', count: 260),
        QuestStat(name: '剑本种火超级', count: 240),
        QuestStat(name: 'QP门', count: 220),
      ],
      topDailyQuestsAllTime: [
        QuestStat(name: 'QP门', count: 1100),
        QuestStat(name: '狂本种火超级', count: 980),
        QuestStat(name: '术本种火超级', count: 930),
      ],
      nextYearMessage: '愿来年欧气满满，推图顺利，从者都来！',
      backgroundImageUrl: 'https://static.atlasacademy.io/JP/Back/back255400_1344_626.png',
    );
  }

  static Future<FgoAnnualReportData> parse({
    FakerRuntime? runtime,
    required MasterDataManager mstData,
    required Region region,
  }) async {
    return fake();
  }
}

class UserInfo {
  final String id;
  final String name;
  final String avatarUrl;
  final DateTime registerDate;
  final int loginCount;
  const UserInfo({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.registerDate,
    required this.loginCount,
  });
}

class ServantRef {
  final String name;
  final String cls;
  final String imageUrl;
  final int bondLevel;
  const ServantRef({required this.name, required this.cls, required this.imageUrl, required this.bondLevel});
}

class GachaPoolStat {
  final String name;
  final int count;
  final String timeRangeText;
  final String imageUrl;
  const GachaPoolStat({required this.name, required this.count, required this.timeRangeText, required this.imageUrl});
}

class QuestStat {
  final String name;
  final int count;
  const QuestStat({required this.name, required this.count});
}
