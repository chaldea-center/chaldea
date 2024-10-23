// ignore_for_file: non_constant_identifier_names

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/modules/quest/quest.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/game_card.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../app/app.dart';
import '../../app/modules/enemy/quest_enemy.dart';
import '../db.dart';
import '_helper.dart';
import 'common.dart';
import 'event.dart';
import 'item.dart';
import 'mappings.dart';
import 'mystic_code.dart';
import 'script.dart';
import 'servant.dart';
import 'skill.dart';
import 'war.dart';

part '../../generated/models/gamedata/quest.g.dart';

@JsonSerializable()
class BasicQuest {
  int id;
  String name;
  QuestType type;
  @QuestFlagConverter()
  List<QuestFlag> flags;
  QuestAfterClearType afterClear;
  ConsumeType consumeType;
  int consume;
  int spotId;
  int warId;
  String? warLongName;
  int priority;
  int noticeAt;
  int openedAt;
  int closedAt;

  BasicQuest({
    required this.id,
    required this.name,
    required this.type,
    this.flags = const [],
    this.afterClear = QuestAfterClearType.close,
    this.consumeType = ConsumeType.ap,
    this.consume = 0,
    this.spotId = 0,
    this.warId = 0,
    this.warLongName,
    required this.priority,
    required this.noticeAt,
    required this.openedAt,
    required this.closedAt,
  });

  factory BasicQuest.fromJson(Map<String, dynamic> json) => _$BasicQuestFromJson(json);

  Map<String, dynamic> toJson() => _$BasicQuestToJson(this);
}

@JsonSerializable()
class Quest with RouteInfo {
  int id;
  String name;
  QuestType type;
  @QuestFlagConverter()
  List<QuestFlag> flags;
  ConsumeType consumeType;
  int consume;
  List<ItemAmount> consumeItem;
  QuestAfterClearType afterClear;
  String recommendLv;
  int spotId;
  String? _spotName;
  int warId;
  String? _warLongName;
  int chapterId;
  int chapterSubId;
  String chapterSubStr;
  String? giftIcon;
  List<Gift> gifts;
  List<QuestPhasePresent> presents;
  List<QuestRelease> releaseConditions;
  List<QuestReleaseOverwrite> releaseOverwrites;
  List<int> phases;
  List<int> phasesWithEnemies;
  List<int> phasesNoBattle;
  List<QuestPhaseScript> phaseScripts;
  int priority; // large=top
  @protected
  int noticeAt;
  int openedAt;
  int closedAt;

  Quest({
    this.id = -1,
    this.name = '',
    this.type = QuestType.event,
    this.flags = const [],
    this.consumeType = ConsumeType.ap,
    int consume = 0,
    this.consumeItem = const [],
    this.afterClear = QuestAfterClearType.close,
    this.recommendLv = '',
    this.spotId = 0,
    String? spotName,
    this.warId = 0,
    String? warLongName,
    this.chapterId = 0,
    this.chapterSubId = 0,
    this.chapterSubStr = "",
    String? giftIcon,
    this.gifts = const [],
    this.presents = const [],
    this.releaseConditions = const [],
    this.releaseOverwrites = const [],
    this.phases = const [],
    this.phasesWithEnemies = const [],
    this.phasesNoBattle = const [],
    this.phaseScripts = const [],
    this.priority = 0,
    this.noticeAt = 0,
    this.openedAt = 0,
    this.closedAt = 0,
  })  : _spotName = spotName == '0' ? null : spotName,
        _warLongName = warLongName,
        giftIcon = _isSQGiftIcon(giftIcon, gifts) ? null : giftIcon,
        consume = consumeType.useApOrBp ? consume : 0;

  int? get recommendLvInt => int.tryParse(recommendLv);

  List<Gift> get giftsWithPhasePresents => [...gifts, ...presents.expand((e) => e.gifts)];

  String get spotName {
    _spotName ??= db.gameData.spots[spotId]?.name;
    return _spotName ?? "";
  }

  String get warLongName {
    _warLongName ??= db.gameData.wars[warId]?.longName;
    return _warLongName ?? "";
  }

  static bool _isSQGiftIcon(String? giftIcon, List<Gift> gifts) {
    return giftIcon != null &&
        giftIcon.endsWith('/Items/6.png') &&
        gifts.any((gift) => gift.type == GiftType.item && gift.objectId == Items.stoneId);
  }

  static int compare(Quest a, Quest b, {bool spotLayer = false}) {
    if (spotLayer && a.warId == b.warId && a.afterClear.isRepeat && b.afterClear.isRepeat) {
      final la = kLB7SpotLayers[a.spotId], lb = kLB7SpotLayers[b.spotId];
      if (la != null && lb != null && la != lb) return la - lb;
    }
    final v1 = ListX.compareByList(
        a, b, (v) => [v.warId < 1000 ? 0 : 1, v.warId < 1000 ? v.warId : (v.war?.event?.startedAt ?? v.openedAt)]);
    if (v1 != 0) return v1;
    if (a.priority == b.priority) return a.id - b.id;
    return b.priority - a.priority;
  }

  static int compareId(int a, int b, {bool spotLayer = false}) {
    final qa = db.gameData.quests[a], qb = db.gameData.quests[b];
    final wa = qa?.war, wb = qb?.war;
    if ((wa != null || wb != null) && wa?.id != wb?.id) {
      return (wb?.id ?? 99999) - (wa?.id ?? 99999);
    }
    if (qa == null && qb == null) return a - b;
    if (qa == null) return -1;
    if (qb == null) return 1;
    return compare(qa, qb, spotLayer: spotLayer);
  }

  static String getName(int questId) {
    return db.gameData.quests[questId]?.lDispName ?? 'Quest $questId';
  }

  factory Quest.fromJson(Map<String, dynamic> json) => _$QuestFromJson(json);

  int getPhaseKey(int phase) => id * 100 + phase;

  int? get jpOpenAt {
    final quest = db.gameData.quests[id.abs()];
    if (quest == null) return null;
    if (quest.closedAt > kNeverClosedTimestamp) {
      return DateTime.now().timestamp;
    }
    return quest.openedAt;
  }

  Transl<String, String> get lName {
    final names = Transl.questNames(name);
    if (names.maybeOf(null) == null && name.startsWith('強化クエスト')) {
      final match = RegExp(r'^強化クエスト (.*?)(\s+\d+)?$').firstMatch(name);
      if (match != null) {
        final name2 = <String?>[
          Transl.questNames('強化クエスト').l,
          Transl.svtNames(match.group(1)!).l,
          match.group(2)?.trim()
        ].whereType<String>().join(' ');
        return Transl.questNames(name2);
      }
    }
    return names;
  }

  String get lNameWithChapter {
    String questName = lName.l;
    String chapter = type == QuestType.main
        ? chapterSubStr.isEmpty && chapterSubId != 0
            ? S.current.quest_chapter_n(chapterSubId)
            : Transl.questNames(chapterSubStr).l
        : '';
    if (chapter.isNotEmpty) {
      questName = '$chapter $questName';
    }
    return questName;
  }

  NiceSpot? get spot => db.gameData.spots[spotId];
  NiceWar? get war => db.gameData.wars[warId];
  Event? get event {
    final _event = war?.eventReal;
    if (_event != null) return _event;
    for (final (eventId, questIds) in db.gameData.others.eventQuestGroups.items) {
      if (questIds.contains(id) && db.gameData.events.containsKey(eventId)) {
        final _event = db.gameData.events[eventId]!;
        if (_event.isAdvancedQuestEvent) {
          return db.gameData.events.values.firstWhereOrNull((e) => e.isAdvancedQuestEvent && e.startedAt == openedAt) ??
              _event;
        }
        return _event;
      }
    }
    return null;
  }

  int get eventIdPriorWarId => event?.id ?? warId;

  bool get is90PlusFree =>
      (isAnyFree || isRepeatRaid) &&
      ((recommendLv.startsWith('90') && recommendLv != '90') || recommendLv.startsWith('100'));

  bool shouldEnableMightyChain() {
    final war = this.war;
    final event = war?.eventReal;
    final checkTime = DateTime(2022, 7, 31).timestamp;
    if (war != null && !war.isMainStory && event != null && event.endedAt < checkTime && closedAt < checkTime) {
      return false;
    } else {
      return true;
    }
  }

  @override
  String get route => Routes.questI(id);

  @override
  void routeTo({Widget? child, bool popDetails = false, Region? region}) {
    super.routeTo(child: child ?? QuestDetailPage(quest: this, region: region), popDetails: popDetails);
  }

  Transl<String, String> get lSpot {
    final spot = this.spot;
    if (spot == null) return Transl.spotNames(spotName);
    String shownName = spotName;
    Set<String> allNames = {spotName};
    for (final add in spot.spotAdds) {
      final name2 = add.overwriteSpotName;
      if (name2 == null) continue;
      allNames.add(name2);
      if ((add.condType == CondType.questClear && id > add.condTargetId) ||
          (add.condType == CondType.questClearPhase && id >= add.condTargetId)) {
        shownName = add.targetText;
      }
    }
    return Transl.spotNames(shownName);
    // final extraNames = allNames.where((e) => e != shownName).toList();
    // if (extraNames.isEmpty) return Transl.spotNames(shownName);
    // final m = MappingBase<String>().convert<String>((v, region) {
    //   String _cvt(String s) => Transl.spotNames(s).of(region);
    //   if (region == Region.jp) return '$shownName (${extraNames.join(" / ")})';
    //   return '${_cvt(shownName)} (${extraNames.map((e) => _cvt(e)).join(" / ")})';
    // });
    // return Transl({m.jp!: m}, m.jp!, m.jp!);
  }

  String get dispName {
    if (isMainStoryFree) {
      final count = db.gameData.others.spotMultiFrees[warId]?[spotId] ?? 0;
      return count > 1 ? '$spotName($name)' : spotName;
    }
    return name;
  }

  String get lDispName {
    if (isMainStoryFree) {
      final count = db.gameData.others.spotMultiFrees[warId]?[spotId] ?? 0;
      return count > 1 ? '${lSpot.l}(${lName.l})' : lSpot.l;
    }
    return lName.l;
  }

  String get chapter {
    if (type == QuestType.main) {
      if (chapterSubStr.isEmpty && chapterSubId != 0) {
        return S.current.quest_chapter_n(chapterSubId);
      } else {
        return Transl.questNames(chapterSubStr).l.trim();
      }
    }
    return '';
  }

  bool get isMainStoryFree =>
      type == QuestType.free &&
      afterClear == QuestAfterClearType.repeatLast &&
      warId < 1000 &&
      // war 401 Marie quests
      !flags.contains(QuestFlag.forceToNoDrop) &&
      !flags.contains(QuestFlag.dropFirstTimeOnly);

  bool get isDomusQuest => isMainStoryFree || db.gameData.dropData.domusAurea.questIds.contains(id);

  // exclude challenge quest, raid
  bool get isAnyFree {
    if (afterClear != QuestAfterClearType.repeatLast) return false;
    if (const [
      QuestFlag.noBattle,
      QuestFlag.dropFirstTimeOnly,
      QuestFlag.forceToNoDrop,
      QuestFlag.notRetrievable,
    ].any((e) => flags.contains(e))) {
      return false;
    }
    if (isAnyRaid) return false;
    if (type == QuestType.free) return true;
    return true;
  }

  // may be event's main quest
  bool get isAnyRaid => flags.contains(QuestFlag.raid);

  bool get isRepeatRaid {
    return afterClear == QuestAfterClearType.repeatLast && flags.contains(QuestFlag.raid);
  }

  bool get isLaplaceSharable {
    return id > 0 && id != WarId.daily && phases.isNotEmpty && (isAnyFree || isRepeatRaid);
  }

  bool get isLaplaceNeedAi => ConstData.laplaceUploadAllowAiQuests.contains(id);

  bool get isNoBattle => flags.contains(QuestFlag.noBattle);

  List<String> get allScriptIds {
    return [for (final phase in phaseScripts) ...phase.scripts.map((e) => e.scriptId)];
  }

  Map<String, dynamic> toJson() => _$QuestToJson(this);
}

@JsonSerializable(converters: [SvtClassConverter()])
class QuestPhase extends Quest {
  int phase;
  List<SvtClass> className;
  List<NiceTrait> individuality;
  List<NiceTrait> phaseIndividuality;
  int qp;
  int exp;
  int bond;
  bool isNpcOnly;
  // int battleBgId;
  // v1 `1_{enemy_count_hash:>02}{npc_id_hash:>02}_{sha1_hash}`
  String? enemyHash;
  @JsonKey(name: 'availableEnemyHashes')
  List<String> enemyHashes;
  // null if no enemy data found
  bool? dropsFromAllHashes;
  BattleBg? battleBg;
  QuestPhaseExtraDetail? extraDetail;
  List<ScriptLink> scripts;
  List<QuestMessage> messages;
  List<QuestHint> hints;
  List<QuestPhaseRestriction> restrictions;
  List<SupportServant> supportServants;
  List<Stage> stages;
  List<EnemyDrop> drops;

  List<NiceTrait> get questIndividuality {
    if (phaseIndividuality.isNotEmpty) {
      final baseTraits = battleBg?.individuality.toList() ?? [];
      baseTraits.addAll(phaseIndividuality.where((trait) => !trait.negative));

      final traitIdsToRemove = phaseIndividuality.where((trait) => trait.negative).map((trait) => trait.id).toList();
      baseTraits.removeWhere((trait) => traitIdsToRemove.contains(trait.id));
      return baseTraits;
    }

    return individuality;
  }

  QuestPhase({
    super.id = -1,
    super.name,
    super.type = QuestType.event,
    super.flags,
    super.consumeType = ConsumeType.ap,
    super.consume = 0,
    super.consumeItem,
    super.afterClear = QuestAfterClearType.close,
    super.recommendLv,
    super.spotId,
    super.spotName,
    super.warId,
    super.warLongName,
    super.chapterId,
    super.chapterSubId,
    super.chapterSubStr,
    super.gifts,
    super.presents,
    super.giftIcon,
    super.releaseConditions,
    super.releaseOverwrites,
    super.phases,
    super.phasesWithEnemies,
    super.phasesNoBattle,
    super.phaseScripts,
    super.priority,
    super.noticeAt,
    super.openedAt,
    super.closedAt,
    this.phase = 1,
    this.className = const [],
    List<NiceTrait>? individuality,
    List<NiceTrait>? phaseIndividuality,
    this.qp = 0,
    this.exp = 0,
    this.bond = 0,
    this.isNpcOnly = false,
    // this.battleBgId = 0,
    this.enemyHash,
    this.enemyHashes = const [],
    this.dropsFromAllHashes,
    this.battleBg,
    this.extraDetail,
    this.scripts = const [],
    this.messages = const [],
    this.hints = const [],
    this.restrictions = const [],
    this.supportServants = const [],
    List<Stage>? stages,
    this.drops = const [],
  })  : individuality = individuality ?? [],
        phaseIndividuality = phaseIndividuality ?? [],
        stages = stages ?? [] {
    if (enemyHashes.length > 1) {
      for (final stage in this.stages) {
        for (final enemy in stage.enemies) {
          enemy.dropsFromAllHashes = dropsFromAllHashes;
        }
      }
    }
    // ort
    if (id == 3001325 && phase == 7) {
      if (Maths.min(drops.map((e) => e.dropCount ~/ e.runs), 0) == 8) {
        for (final drop in drops) {
          drop.dropCount = drop.dropCount ~/ 8;
        }
      }
    }
  }

  @override
  bool get isLaplaceSharable => super.isLaplaceSharable && enemyHash != null;

  int get key => getPhaseKey(phase);

  List<QuestEnemy> get allEnemies => [for (final stage in stages) ...stage.enemies];

  String? get enemyHashOrTotal {
    if (dropsFromAllHashes == true) return null;
    return enemyHash;
  }

  @override
  Transl<String, String> get lSpot {
    final spot = this.spot;
    if (spot == null) return Transl.spotNames(spotName);
    String shownName = spotName;
    for (final add in spot.spotAdds) {
      if (add.overrideType != SpotOverwriteType.name || add.targetText.isEmpty) {
        continue;
      }
      if (add.condType == CondType.questClear && id > add.condTargetId) {
        shownName = add.targetText;
      } else if (add.condType == CondType.questClearPhase) {
        if (id > add.condTargetId || (id == add.condTargetId && phase > add.condNum)) {
          shownName = add.targetText;
        }
      }
    }
    return Transl.spotNames(shownName);
  }

  factory QuestPhase.fromJson(Map<String, dynamic> json) => _$QuestPhaseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$QuestPhaseToJson(this);

  void removeEventQuestIndividuality() {
    individuality.removeWhere((e) => e.isEventField);
    battleBg?.individuality.removeWhere((e) => e.isEventField);
    phaseIndividuality.removeWhere((e) => e.isEventField);
  }
}

@JsonSerializable()
class BaseGift {
  int id;
  @JsonKey(unknownEnumValue: GiftType.unknown)
  GiftType type;
  int objectId;

  // int priority;
  int num;

  BaseGift({
    required this.id,
    GiftType? type,
    required this.objectId,
    // required this.priority,
    required this.num,
  }) : type = type ?? GiftType.item;

  factory BaseGift.fromJson(Map<String, dynamic> json) => _$BaseGiftFromJson(json);

  bool get isStatItem {
    if (const [
      GiftType.equip,
      GiftType.eventSvtJoin,
      GiftType.eventPointBuff,
      GiftType.eventCommandAssist,
      GiftType.eventHeelPortrait,
      GiftType.battleItem,
      GiftType.unknown,
    ].contains(type)) return false;
    return true;
  }

  Item? toItem() {
    if (const [GiftType.item, GiftType.battleItem].contains(type)) return db.gameData.items[objectId];
    return null;
  }

  Widget iconBuilder({
    required BuildContext context,
    String? icon,
    double? width,
    double? height,
    double? aspectRatio = 132 / 144,
    String? text,
    EdgeInsets? padding,
    VoidCallback? onTap,
    ImageWithTextOption? option,
    bool jumpToDetail = true,
    bool popDetail = false,
    String? name,
    bool showName = false,
    bool showOne = true,
  }) {
    switch (type) {
      case GiftType.servant:
      case GiftType.item:
      case GiftType.battleItem:
      case GiftType.commandCode:
      case GiftType.eventSvtJoin:
      case GiftType.eventSvtGet:
      case GiftType.costumeRelease:
      case GiftType.costumeGet:
        break;
      case GiftType.friendship:
        break;
      case GiftType.userExp:
        break;
      case GiftType.equip:
        icon ??= db.gameData.mysticCodes[objectId]?.icon;
        onTap ??= () {
          router.push(url: Routes.mysticCodeI(objectId));
        };
        break;
      case GiftType.questRewardIcon:
        icon ??= Atlas.assetItem(objectId);
        onTap = () {};
        jumpToDetail = false;
        break;
      case GiftType.eventBoardGameToken:
        if (objectId ~/ 1000 == 80285) {
          final tokenId = objectId % 1000;
          icon ??= AssetURL.i.eventUi("Prefabs/80285/940477${tokenId.toString().padLeft(2, '0')}.png");
        }
        showOne = false;
      case GiftType.eventCommandAssist:
        icon ??= Atlas.assetItem(objectId);
        showOne = false;
        break;
      case GiftType.eventHeelPortrait:
        icon ??= AssetURL.i.eventUi("Prefabs/80432/$objectId");
        showOne = false;
        break;
      case GiftType.eventPointBuff:
        icon ??= db.gameData.others.eventPointBuffs[objectId]?.icon;
        break;
      case GiftType.unknown:
        jumpToDetail = false;
        break;
    }
    return GameCardMixin.anyCardItemBuilder(
      context: context,
      id: objectId,
      icon: icon,
      width: width,
      height: height,
      aspectRatio: aspectRatio,
      text: text ?? ((num > 1 || (num == 1 && showOne)) ? num.format() : null),
      padding: padding,
      onTap: onTap,
      option: option,
      jumpToDetail: jumpToDetail,
      popDetail: popDetail,
      name: name,
      showName: showName,
    );
  }

  String get shownName {
    String? name;
    if (type == GiftType.equip) {
      name = db.gameData.mysticCodes[objectId]?.lName.l;
    } else if (type == GiftType.eventPointBuff) {
      name = db.gameData.others.eventPointBuffs[objectId]?.name ?? "PointBuff $objectId";
      // } else if (type == GiftType.eventBoardGameToken) {
      // } else if (type == GiftType.eventCommandAssist) {
    } else if (type == GiftType.eventHeelPortrait) {
      name = '${S.current.event_heel}(${db.gameData.entities[objectId]?.lName.l ?? objectId})';
    }
    name ??= GameCardMixin.anyCardItemName(objectId).l;
    return name;
  }

  void routeTo() {
    String? route;
    switch (type) {
      case GiftType.servant:
      case GiftType.item:
      case GiftType.battleItem:
      case GiftType.commandCode:
      case GiftType.eventSvtJoin:
      case GiftType.eventSvtGet:
      case GiftType.costumeRelease:
      case GiftType.costumeGet:
        break;
      case GiftType.friendship:
        break;
      case GiftType.userExp:
        break;
      case GiftType.equip:
        route = Routes.mysticCodeI(objectId);
        break;
      case GiftType.questRewardIcon:
        break;
      case GiftType.eventPointBuff:
        break;
      case GiftType.eventBoardGameToken:
        break;
      case GiftType.eventCommandAssist:
        break;
      case GiftType.eventHeelPortrait:
        // objectId=svtId
        break;
      case GiftType.unknown:
        break;
    }
    route ??= GameCardMixin.getRoute(objectId);
    if (route != null) {
      router.push(url: route);
    }
  }

  Map<String, dynamic> toJson() => _$BaseGiftToJson(this);
}

@JsonSerializable()
class GiftAdd {
  int priority;
  String replacementGiftIcon;
  @CondTypeConverter()
  CondType condType;
  int targetId;
  int targetNum;
  List<BaseGift> replacementGifts;

  GiftAdd({
    required this.priority,
    required this.replacementGiftIcon,
    required this.condType,
    required this.targetId,
    required this.targetNum,
    required this.replacementGifts,
  });

  factory GiftAdd.fromJson(Map<String, dynamic> json) => _$GiftAddFromJson(json);

  Map<String, dynamic> toJson() => _$GiftAddToJson(this);
}

@JsonSerializable()
class Gift extends BaseGift {
  List<GiftAdd> giftAdds;
  Gift({
    required super.id,
    GiftType? type,
    required super.objectId,
    // required this.priority,
    // ignore: avoid_types_as_parameter_names
    required super.num,
    this.giftAdds = const [],
  }) : super(type: type ?? GiftType.item);

  static final kGift448 = <Gift>[
    Gift(
      id: 448,
      type: GiftType.item,
      objectId: 16,
      num: 1,
    ),
    Gift(
      id: 448,
      type: GiftType.item,
      objectId: 103,
      num: 1,
    )
  ];

  factory Gift.fromJson(Map<String, dynamic> json) => _$GiftFromJson(json);

  static Map<int, List<Gift>> group(List<Gift> gifts) {
    Map<int, List<Gift>> groups = {};
    for (final gift in gifts) {
      groups.putIfAbsent(gift.id, () => []).add(gift);
    }
    return groups;
  }

  static List<Widget> listBuilder({
    required BuildContext context,
    required List<Gift> gifts,
    Widget Function(BaseGift gift)? itemBuilder,
    double size = 36.0,
  }) {
    List<Widget> children = [];
    itemBuilder ??= (gift) => gift.iconBuilder(context: context, width: size);
    Map<int, List<Gift>> groups = {};
    for (final gift in gifts) {
      groups.putIfAbsent(gift.id, () => []).add(gift);
    }
    bool multiGroup = groups.length > 1;
    for (final group in groups.values) {
      final giftAdds = group.first.giftAdds;
      if (giftAdds.isEmpty) {
        children.addAll(group.map(itemBuilder));
      } else {
        Widget text(String s) => Text(s, style: TextStyle(fontSize: size * 0.6));
        children.addAll([
          if (multiGroup) text('('),
          ...group.map(itemBuilder),
          // text('➟'),
          text('→'),
        ]);
        for (int index = 0; index < giftAdds.length; index++) {
          final giftAdd = giftAdds[index];
          children.add(db.getIconImage(giftAdd.replacementGiftIcon, width: size, height: size));
          children.addAll(giftAdd.replacementGifts.map(itemBuilder));
          children.add(InkWell(
            onTap: () {
              SimpleCancelOkDialog(
                title: Text(S.current.condition),
                content: CondTargetValueDescriptor(
                    condType: giftAdd.condType, target: giftAdd.targetId, value: giftAdd.targetNum),
                scrollable: true,
                hideCancel: true,
              ).showDialog(context);
            },
            child: Icon(Icons.info_outline, size: size * 0.5),
          ));
        }
        if (multiGroup) children.add(text(')'));
      }
    }
    return children;
  }

  static void checkAddGifts(Map<int, int> stat, List<Gift> gifts, [int setNum = 1]) {
    Map<int, int> repls = {};
    if (gifts.any((gift) => gift.giftAdds.isNotEmpty)) {
      final giftAdd = gifts.firstWhere((e) => e.giftAdds.isNotEmpty).giftAdds.first;
      final replGifts = giftAdd.replacementGifts;
      for (final gift in replGifts) {
        if (giftAdd.replacementGiftIcon.endsWith('Items/19.png') && gift.objectId == Items.crystalId) {
          repls.addNum(Items.grailToCrystalId, gift.num * setNum);
          repls.addNum(Items.grailId, -gift.num * setNum);
        } else if (gift.objectId == Items.rarePrismId) {
          repls.addNum(gift.objectId, gift.num * setNum);
        }
      }
    }
    for (final gift in gifts) {
      if (gift.isStatItem) stat.addNum(gift.objectId, gift.num * setNum);
    }
    stat.addDict(repls);
  }

  @override
  Map<String, dynamic> toJson() => _$GiftToJson(this);
}

@JsonSerializable()
class Stage with DataScriptBase {
  Map<String, dynamic> get originalScript => source;

  int wave;
  Bgm? bgm;
  int startEffectId;

  List<FieldAi> fieldAis;
  List<int> call;
  int? turn;
  StageLimitActType? limitAct;
  int? enemyFieldPosCount;
  int? enemyActCount;
  BattleBg? battleBg;
  List<int>? NoEntryIds;
  List<StageStartMovie> waveStartMovies;

  StageCutin? cutin;
  List<AiAllocationInfo>? aiAllocations;
  List<QuestEnemy> enemies;

  Stage({
    required this.wave,
    this.bgm,
    this.startEffectId = 1,
    List<FieldAi>? fieldAis,
    List<int>? call,
    this.turn,
    this.limitAct,
    this.enemyFieldPosCount,
    this.enemyActCount,
    this.battleBg,
    this.NoEntryIds,
    this.waveStartMovies = const [],
    Map<String, dynamic>? originalScript,
    this.cutin,
    this.aiAllocations,
    List<QuestEnemy>? enemies,
  })  : fieldAis = fieldAis ?? [],
        call = call ?? [],
        enemies = enemies ?? [] {
    setSource(originalScript);
  }

  factory Stage.fromJson(Map<String, dynamic> json) => _$StageFromJson(json);

  int get enemyFieldPosCountReal => enemyFieldPosCount ?? 3;

  int? get enemyMasterBattleId => toInt('enemyMasterBattleId');
  List<int>? get enemyMasterBattleIdByPlayerGender => toList('enemyMasterBattleIdByPlayerGender');
  // mstBattleMasterImage.id
  int? get battleMasterImageId => toInt('battleMasterImageId');

  Map<String, dynamic> toJson() => _$StageToJson(this)..['originalScript'] = originalScript;
}

@JsonSerializable()
class AiAllocationInfo {
  List<int> aiIds;
  @JsonKey(unknownEnumValue: AiAllocationApplySvtFlag.unknown)
  List<AiAllocationApplySvtFlag> applySvtType;
  NiceTrait? individuality;

  AiAllocationInfo({
    this.aiIds = const [],
    this.applySvtType = const [],
    this.individuality,
  });

  factory AiAllocationInfo.fromJson(Map<String, dynamic> json) => _$AiAllocationInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AiAllocationInfoToJson(this);
}

@JsonSerializable()
class StageCutin {
  int runs;
  List<StageCutInSkill> skills;
  List<EnemyDrop> drops;

  StageCutin({
    required this.runs,
    this.skills = const [],
    this.drops = const [],
  });

  factory StageCutin.fromJson(Map<String, dynamic> json) => _$StageCutinFromJson(json);

  Map<String, dynamic> toJson() => _$StageCutinToJson(this);
}

@JsonSerializable()
class StageCutInSkill {
  NiceSkill skill;
  int appearCount;

  StageCutInSkill({required this.skill, required this.appearCount});

  factory StageCutInSkill.fromJson(Map<String, dynamic> json) => _$StageCutInSkillFromJson(json);

  Map<String, dynamic> toJson() => _$StageCutInSkillToJson(this);
}

@JsonSerializable()
class StageStartMovie {
  String waveStartMovie;

  StageStartMovie({required this.waveStartMovie});

  factory StageStartMovie.fromJson(Map<String, dynamic> json) => _$StageStartMovieFromJson(json);

  Map<String, dynamic> toJson() => _$StageStartMovieToJson(this);
}

@JsonSerializable()
class QuestRelease {
  @CondTypeConverter()
  CondType type;
  int targetId;
  int value;
  String closedMessage;

  QuestRelease({
    required this.type,
    required this.targetId,
    this.value = 0,
    this.closedMessage = "",
  });

  factory QuestRelease.fromJson(Map<String, dynamic> json) => _$QuestReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$QuestReleaseToJson(this);
}

@JsonSerializable()
class QuestReleaseOverwrite {
  int priority;
  // int imagePriority;
  @CondTypeConverter()
  CondType condType;
  int condId;
  int condNum;
  String closedMessage;
  String overlayClosedMessage;
  int eventId;
  int startedAt;
  int endedAt;

  QuestReleaseOverwrite({
    this.priority = 0,
    this.condType = CondType.none,
    this.condId = 0,
    this.condNum = 0,
    this.closedMessage = "",
    this.overlayClosedMessage = "",
    this.eventId = 0,
    this.startedAt = 0,
    this.endedAt = 0,
  });

  factory QuestReleaseOverwrite.fromJson(Map<String, dynamic> json) => _$QuestReleaseOverwriteFromJson(json);

  Map<String, dynamic> toJson() => _$QuestReleaseOverwriteToJson(this);
}

@JsonSerializable()
class QuestPhaseScript {
  int phase;
  List<ScriptLink> scripts;

  QuestPhaseScript({
    required this.phase,
    required this.scripts,
  });

  factory QuestPhaseScript.fromJson(Map<String, dynamic> json) => _$QuestPhaseScriptFromJson(json);

  Map<String, dynamic> toJson() => _$QuestPhaseScriptToJson(this);
}

@JsonSerializable()
class QuestMessage {
  int idx;
  String message;
  @CondTypeConverter()
  CondType condType;
  int targetId;
  int targetNum;

  QuestMessage({
    required this.idx,
    required this.message,
    required this.condType,
    required this.targetId,
    required this.targetNum,
  });

  factory QuestMessage.fromJson(Map<String, dynamic> json) => _$QuestMessageFromJson(json);

  Map<String, dynamic> toJson() => _$QuestMessageToJson(this);
}

@JsonSerializable()
class QuestHint {
  String title;
  String message;
  int leftIndent;

  QuestHint({
    this.title = '',
    this.message = '',
    this.leftIndent = 0,
  });

  factory QuestHint.fromJson(Map<String, dynamic> json) => _$QuestHintFromJson(json);

  Map<String, dynamic> toJson() => _$QuestHintToJson(this);
}

@JsonSerializable()
class QuestPhasePresent {
  // int questId;
  int phase;
  List<Gift> gifts;
  String? giftIcon;
  // String presentMessage;
  @CondTypeConverter()
  CondType condType;
  int condId;
  int condNum;
  // Map<String, dynamic> originalScript;

  QuestPhasePresent({
    this.phase = 0,
    this.gifts = const [],
    this.giftIcon,
    this.condType = CondType.none,
    this.condId = 0,
    this.condNum = 0,
    // this.originalScript = const {},
  });

  factory QuestPhasePresent.fromJson(Map<String, dynamic> json) => _$QuestPhasePresentFromJson(json);

  Map<String, dynamic> toJson() => _$QuestPhasePresentToJson(this);
}

@JsonSerializable()
class NpcServant {
  int? npcId; // non-null
  String name;
  BasicServant svt;
  int lv;
  int atk;
  int hp;
  List<NiceTrait> traits;
  EnemySkill? skills;
  SupportServantTd? noblePhantasm;
  SupportServantLimit limit;
  @JsonKey(unknownEnumValue: NpcServantFollowerFlag.unknown)
  List<NpcServantFollowerFlag> flags;

  NpcServant({
    this.npcId,
    required this.name,
    required this.svt,
    required this.lv,
    required this.atk,
    required this.hp,
    this.traits = const [],
    this.skills,
    this.noblePhantasm,
    required this.limit,
    this.flags = const [],
  });

  factory NpcServant.fromJson(Map<String, dynamic> json) => _$NpcServantFromJson(json);

  Map<String, dynamic> toJson() => _$NpcServantToJson(this);
}

@JsonSerializable()
class SupportServant {
  int id;
  int npcSvtFollowerId;
  int priority;
  String name;
  BasicServant svt;
  int lv;
  int atk;
  int hp;
  List<NiceTrait> traits;
  EnemySkill skills;
  List<SupportServantPassiveSkill> passiveSkills; // Only CN has it
  SupportServantTd noblePhantasm;
  @JsonKey(unknownEnumValue: NpcFollowerEntityFlag.none)
  List<NpcFollowerEntityFlag> followerFlags;
  List<SupportServantEquip> equips;
  SupportServantScript? script;
  List<SupportServantRelease> releaseConditions;
  SupportServantLimit limit;
  QuestEnemy? detail;
  // misc

  SupportServant({
    required this.id,
    this.npcSvtFollowerId = 0,
    required this.priority,
    required this.name,
    required this.svt,
    required this.lv,
    required this.atk,
    required this.hp,
    this.traits = const [],
    required this.skills,
    this.passiveSkills = const [],
    required this.noblePhantasm,
    this.followerFlags = const [],
    this.equips = const [],
    this.script,
    this.releaseConditions = const [],
    required this.limit,
    this.detail,
  });

  factory SupportServant.fromJson(Map<String, dynamic> json) => _$SupportServantFromJson(json);

  String get shownName {
    if (name.isEmpty || name == "NONE") {
      return svt.name;
    }
    return name;
  }

  Transl<String, String> get lName => Transl.svtNames(shownName);

  List<NiceTrait> get traits2 => detail?.traits ?? traits;
  EnemySkill get skills2 => detail?.skills ?? skills;
  NiceTd? get td2 => detail?.noblePhantasm.noblePhantasm ?? noblePhantasm.noblePhantasm;
  int? get td2Lv => detail?.noblePhantasm.noblePhantasmLv ?? noblePhantasm.lv;
  EnemyPassive get classPassive => detail?.classPassive ?? EnemyPassive();

  Map<String, dynamic> toJson() => _$SupportServantToJson(this);
}

@JsonSerializable()
class SupportServantRelease {
  @CondTypeConverter()
  CondType type;
  int targetId;
  int value;

  SupportServantRelease({
    this.type = CondType.none,
    required this.targetId,
    required this.value,
  });

  factory SupportServantRelease.fromJson(Map<String, dynamic> json) => _$SupportServantReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$SupportServantReleaseToJson(this);
}

@JsonSerializable()
class SupportServantPassiveSkill {
  int skillId;
  NiceSkill? skill;
  int? skillLv;

  SupportServantPassiveSkill({
    this.skillId = 0,
    this.skill,
    this.skillLv,
  });

  factory SupportServantPassiveSkill.fromJson(Map<String, dynamic> json) => _$SupportServantPassiveSkillFromJson(json);

  Map<String, dynamic> toJson() => _$SupportServantPassiveSkillToJson(this);
}

@JsonSerializable()
class SupportServantTd {
  int noblePhantasmId;
  NiceTd? noblePhantasm;
  int noblePhantasmLv;

  SupportServantTd({
    required this.noblePhantasmId,
    this.noblePhantasm,
    required this.noblePhantasmLv,
  });

  factory SupportServantTd.fromJson(Map<String, dynamic> json) => _$SupportServantTdFromJson(json);

  int? get lv => noblePhantasm == null ? null : noblePhantasmLv;

  Map<String, dynamic> toJson() => _$SupportServantTdToJson(this);
}

@JsonSerializable()
class SupportServantEquip {
  CraftEssence equip;
  int lv;
  int limitCount;

  SupportServantEquip({
    required this.equip,
    required this.lv,
    required this.limitCount,
  });

  factory SupportServantEquip.fromJson(Map<String, dynamic> json) => _$SupportServantEquipFromJson(json);

  Map<String, dynamic> toJson() => _$SupportServantEquipToJson(this);
}

@JsonSerializable()
class SupportServantScript {
  int? dispLimitCount;
  int? eventDeckIndex;

  SupportServantScript({
    this.dispLimitCount,
    this.eventDeckIndex,
  });

  factory SupportServantScript.fromJson(Map<String, dynamic> json) => _$SupportServantScriptFromJson(json);

  Map<String, dynamic> toJson() => _$SupportServantScriptToJson(this);
}

@JsonSerializable()
class SupportServantLimit {
  int limitCount;

  SupportServantLimit({
    required this.limitCount,
  });

  factory SupportServantLimit.fromJson(Map<String, dynamic> json) => _$SupportServantLimitFromJson(json);

  Map<String, dynamic> toJson() => _$SupportServantLimitToJson(this);
}

@JsonSerializable()
class EnemyDrop extends BaseGift {
  int dropCount;
  int runs;

  // double dropExpected;
  // double dropVariance;

  EnemyDrop({
    super.id = 0,
    super.type = GiftType.item,
    required super.objectId,
    // ignore: avoid_types_as_parameter_names
    super.num = 1,
    required this.dropCount,
    required this.runs,
    // required this.dropExpected,
    // required this.dropVariance,
  });

  factory EnemyDrop.fromJson(Map<String, dynamic> json) => _$EnemyDropFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EnemyDropToJson(this);
}

@JsonSerializable()
class EnemyLimit {
  int limitCount;
  int imageLimitCount;
  int dispLimitCount;
  int commandCardLimitCount;
  int iconLimitCount;
  int portraitLimitCount;
  int battleVoice;
  int exceedCount;

  EnemyLimit({
    this.limitCount = 0,
    this.imageLimitCount = 0,
    this.dispLimitCount = 0,
    this.commandCardLimitCount = 0,
    this.iconLimitCount = 0,
    this.portraitLimitCount = 0,
    this.battleVoice = 0,
    this.exceedCount = 0,
  });

  int get useLimitCount => limitCount == 0 && dispLimitCount != 0 ? dispLimitCount : limitCount;

  factory EnemyLimit.fromJson(Map<String, dynamic> json) => _$EnemyLimitFromJson(json);

  Map<String, dynamic> toJson() => _$EnemyLimitToJson(this);
}

@JsonSerializable()
class EnemyMisc {
  int displayType;
  int npcSvtType;
  List<int>? passiveSkill;
  int equipTargetId1;
  List<int>? equipTargetIds;
  int npcSvtClassId;
  int overwriteSvtId;

  // List<int> userCommandCodeIds;
  List<int>? commandCardParam;
  int status;
  // int? hpGaugeType;
  // int? imageSvtId;
  // int? condVal;

  EnemyMisc({
    this.displayType = 1,
    this.npcSvtType = 2,
    this.passiveSkill,
    this.equipTargetId1 = 0,
    this.equipTargetIds,
    this.npcSvtClassId = 0,
    this.overwriteSvtId = 0,
    this.commandCardParam,
    this.status = 0,
  });

  factory EnemyMisc.fromJson(Map<String, dynamic> json) => _$EnemyMiscFromJson(json);

  Map<String, dynamic> toJson() => _$EnemyMiscToJson(this);
}

@JsonSerializable()
class QuestEnemy with GameCardMixin {
  DeckType deck;
  int deckId;
  // int userSvtId;
  // int uniqueId;
  int npcId; // not unique even in same deck
  EnemyRoleType roleType;
  @override
  String name;
  BasicServant svt;
  List<EnemyDrop> drops;
  // only true/false when there are multiple versions
  @JsonKey(includeFromJson: false)
  bool? dropsFromAllHashes;
  int lv;
  int exp;
  int atk;
  int hp;
  int adjustAtk; // not used
  int adjustHp; // not used
  int deathRate;
  int criticalRate;
  int recover;
  int chargeTurn;
  List<NiceTrait> traits;

  EnemySkill skills;
  EnemyPassive classPassive;

  EnemyTd noblePhantasm;
  EnemyServerMod serverMod;

  EnemyAi? ai;
  EnemyScript enemyScript;
  Map<String, dynamic> get originalEnemyScript => enemyScript.source;
  EnemyInfoScript infoScript;
  Map<String, dynamic> get originalInfoScript => infoScript.source;

  EnemyLimit limit;
  EnemyMisc? misc;

  // not unique if summoned from call deck
  int get deckNpcId => npcId * 10 + deck.index;

  bool get isRareOrAddition => infoScript.isAddition || enemyScript.isRare;

  QuestEnemy({
    this.deck = DeckType.enemy,
    required this.deckId,
    // this.userSvtId = -1,
    // this.uniqueId = -1,
    this.npcId = -1,
    this.roleType = EnemyRoleType.normal,
    this.name = "",
    required this.svt,
    this.drops = const [],
    required this.lv,
    this.exp = 0,
    required this.atk,
    required this.hp,
    this.adjustAtk = 0,
    this.adjustHp = 0,
    required this.deathRate,
    required this.criticalRate,
    this.recover = 0,
    this.chargeTurn = 0,
    List<NiceTrait>? traits,
    EnemySkill? skills,
    EnemyPassive? classPassive,
    EnemyTd? noblePhantasm,
    EnemyServerMod? serverMod,
    this.ai,
    EnemyScript? enemyScript,
    Map<String, dynamic>? originalEnemyScript,
    EnemyInfoScript? infoScript,
    Map<String, dynamic>? originalInfoScript,
    EnemyLimit? limit,
    this.misc,
  })  : traits = traits ?? [],
        skills = skills ?? EnemySkill(),
        classPassive = classPassive ?? EnemyPassive(),
        noblePhantasm = noblePhantasm ?? EnemyTd(),
        serverMod = serverMod ?? EnemyServerMod(),
        enemyScript = (enemyScript ?? EnemyScript())..setSource(originalEnemyScript),
        infoScript = (infoScript ?? EnemyInfoScript())..setSource(originalInfoScript),
        limit = limit ?? EnemyLimit();

  static QuestEnemy blankEnemy() {
    return QuestEnemy(
      deckId: 1,
      name: 'BlankEnemy',
      svt: BasicServant(
        id: 988888888,
        collectionNo: 0,
        name: 'BlankEnemy',
        type: SvtType.normal,
        flags: [],
        classId: SvtClass.ALL.value,
        attribute: ServantSubAttribute.none,
        rarity: 3,
        atkMax: 1000,
        hpMax: 10000,
        face: Atlas.common.unknownEnemyIcon,
      ),
      lv: 1,
      atk: 1000,
      hp: 10000000,
      deathRate: 0,
      criticalRate: 0,
      serverMod: EnemyServerMod(),
    );
  }

  String get lShownName {
    if (name.isEmpty || name == 'NONE') {
      return svt.lName.l;
    }
    String? _name = Transl.md.svtNames[name]?.l ?? Transl.md.entityNames[name]?.l;
    if (_name != null) return _name;
    return name.replaceFirstMapped(RegExp(r'^(.+?)(\s*)([A-Z\uff21-\uff3a])$'), (match) {
      String a = Transl.svtNames(match.group(1)!).l, b = match.group(2)!, c = match.group(3)!;
      if (Transl.isEN && b.isEmpty && c.isNotEmpty) b = ' ';
      return '$a$b$c';
    });
  }

  @override
  Transl<String, String> get lName => svt.lName;

  @override
  int get collectionNo => svt.collectionNo;

  @override
  String? get icon => svt.icon;

  @override
  String? get borderedIcon => icon;

  @override
  int get id => svt.id;

  @override
  int get rarity => svt.rarity;

  @override
  String get route => Routes.enemyI(id);

  @override
  void routeTo({Widget? child, bool popDetails = false, Quest? quest}) {
    super.routeTo(
      child: QuestEnemyDetail(enemy: this, quest: quest),
      popDetails: popDetails,
    );
  }

  factory QuestEnemy.fromJson(Map<String, dynamic> json) => _$QuestEnemyFromJson(json);

  Map<String, dynamic> toJson() => _$QuestEnemyToJson(this);
}

@JsonSerializable()
class EnemyServerMod {
  int tdRate;
  int tdAttackRate;
  int starRate;

  // lots of others

  EnemyServerMod({
    this.tdRate = 1000,
    this.tdAttackRate = 1000,
    this.starRate = 0,
  });

  factory EnemyServerMod.fromJson(Map<String, dynamic> json) => _$EnemyServerModFromJson(json);

  Map<String, dynamic> toJson() => _$EnemyServerModToJson(this);
}

// appear
// billBoardGroup
// boss
// call
// Cane
// change
// changeAttri
// deadChangePos
// death
// dispLimitCount
// forceDropItem
// hpBarType
// isHideShadow
// isSkillShiftInfo
// kill
// leader
// leave
// missionTargetSkillShift
// multiTargetCore
// multiTargetUnder
// multiTargetUp
// NoMotion
// NoSkipDead
// noVoice
// npc
// probability_type
// raid
// shift
// shiftClear
// shiftPosition
// skillShift
// speed1_dead
// startPos
// superBoss
// surt
// svt_change
// svtVoiceId
// transformAfterName
// treasureDeviceVoiceId
// treasureDeviceName
// treasureDeviceRuby
// voice
@JsonSerializable(includeIfNull: false)
class EnemyScript with DataScriptBase {
  // lots of fields are skipped
  SvtDeathType? deathType;
  int? hpBarType;
  bool? leader;
  List<int>? call; // npcId
  List<int>? shift; // npcId
  List<NiceTrait>? shiftClear;
  List<int>? get change => toList('change');

  EnemyScript({
    this.deathType,
    this.hpBarType,
    this.leader,
    this.call,
    this.shift,
    this.shiftClear,
  });

  // the enemy is one of possible versions or not appear
  bool get isRare => (toInt('probability_type') ?? 0) != 0;

  int? get dispBreakShift => toInt('dispBreakShift');
  int? get shiftPosition => toInt('shiftPosition'); // default value -1
  int? get entryByUserDeckFormationCondId => toInt('entryByUserDeckFormationCondId');

  factory EnemyScript.fromJson(Map<String, dynamic> json) => _$EnemyScriptFromJson(json);

  Map<String, dynamic> toJson() => Map.from(source)..addAll(_$EnemyScriptToJson(this));
}

@JsonSerializable(includeIfNull: false)
class EnemyInfoScript with DataScriptBase {
  bool get isAddition => toInt('isAddition') == 1;

  EnemyInfoScript();

  factory EnemyInfoScript.fromJson(Map<String, dynamic> json) => _$EnemyInfoScriptFromJson(json);

  Map<String, dynamic> toJson() => Map.from(source)..addAll(_$EnemyInfoScriptToJson(this));
}

@JsonSerializable()
class EnemySkill {
  int skillId1;
  int skillId2;
  int skillId3;
  NiceSkill? skill1;
  NiceSkill? skill2;
  NiceSkill? skill3;
  int skillLv1;
  int skillLv2;
  int skillLv3;

  EnemySkill({
    this.skillId1 = 0,
    this.skillId2 = 0,
    this.skillId3 = 0,
    this.skill1,
    this.skill2,
    this.skill3,
    this.skillLv1 = 0,
    this.skillLv2 = 0,
    this.skillLv3 = 0,
  });

  List<NiceSkill?> get skills => [skill1, skill2, skill3];

  List<int> get skillIds => [skillId1, skillId2, skillId3];

  List<int?> get skillLvs => [
        skill1 == null ? null : skillLv1,
        skill2 == null ? null : skillLv2,
        skill3 == null ? null : skillLv3,
      ];

  factory EnemySkill.fromJson(Map<String, dynamic> json) => _$EnemySkillFromJson(json);

  Map<String, dynamic> toJson() => _$EnemySkillToJson(this);
}

@JsonSerializable()
class EnemyTd {
  int noblePhantasmId;
  NiceTd? noblePhantasm;
  int noblePhantasmLv;
  int noblePhantasmLv1;
  int? noblePhantasmLv2;
  int? noblePhantasmLv3;

  EnemyTd({
    this.noblePhantasmId = 0,
    this.noblePhantasm,
    this.noblePhantasmLv = 1,
    this.noblePhantasmLv1 = 0,
    this.noblePhantasmLv2,
    this.noblePhantasmLv3,
  });

  factory EnemyTd.fromJson(Map<String, dynamic> json) => _$EnemyTdFromJson(json);

  Map<String, dynamic> toJson() => _$EnemyTdToJson(this);
}

@JsonSerializable()
class EnemyPassive {
  List<NiceSkill> classPassive;
  List<NiceSkill> addPassive;
  List<int> addPassiveLvs;
  List<int>? appendPassiveSkillIds;
  List<int>? appendPassiveSkillLvs;

  EnemyPassive({
    List<NiceSkill>? classPassive,
    List<NiceSkill>? addPassive,
    List<int>? addPassiveLvs,
    this.appendPassiveSkillIds,
    this.appendPassiveSkillLvs,
  })  : classPassive = classPassive ?? [],
        addPassive = addPassive ?? [],
        addPassiveLvs = List.generate(addPassive?.length ?? 0,
            (index) => addPassiveLvs?.getOrNull(index) ?? addPassive?.getOrNull(index)?.maxLv ?? 1);

  factory EnemyPassive.fromJson(Map<String, dynamic> json) => _$EnemyPassiveFromJson(json);

  bool get isNotEmpty => classPassive.isNotEmpty || addPassive.isNotEmpty || appendPassiveSkillIds?.isNotEmpty == true;

  bool containSkill(int skillId) {
    return classPassive.any((e) => e.id == skillId) ||
        addPassive.any((e) => e.id == skillId) ||
        appendPassiveSkillIds?.contains(skillId) == true;
  }

  Map<String, dynamic> toJson() => _$EnemyPassiveToJson(this);
}

// class EnemyLimit{}

@JsonSerializable()
class EnemyAi {
  int aiId;
  int actPriority;
  int maxActNum;
  int? minActNum;

  EnemyAi({
    required this.aiId,
    required this.actPriority,
    required this.maxActNum,
    this.minActNum,
  });

  factory EnemyAi.fromJson(Map<String, dynamic> json) => _$EnemyAiFromJson(json);

  Map<String, dynamic> toJson() => _$EnemyAiToJson(this);
}

@JsonSerializable()
class FieldAi {
  int? raid;
  int? day;
  int id;

  FieldAi({
    this.raid,
    this.day,
    required this.id,
  });

  factory FieldAi.fromJson(Map<String, dynamic> json) => _$FieldAiFromJson(json);

  Map<String, dynamic> toJson() => _$FieldAiToJson(this);
}

@JsonSerializable()
class QuestPhaseAiNpc {
  NpcServant npc;
  QuestEnemy? detail;
  List<int> aiIds;

  QuestPhaseAiNpc({
    required this.npc,
    this.detail,
    this.aiIds = const [],
  });

  factory QuestPhaseAiNpc.fromJson(Map<String, dynamic> json) => _$QuestPhaseAiNpcFromJson(json);

  Map<String, dynamic> toJson() => _$QuestPhaseAiNpcToJson(this);
}

@JsonSerializable()
class QuestPhaseExtraDetail {
  List<int>? questSelect;
  int? singleForceSvtId;
  String? hintTitle;
  String? hintMessage;
  QuestPhaseAiNpc? aiNpc;
  List<QuestPhaseAiNpc>? aiMultiNpc;
  OverwriteEquipSkills? overwriteEquipSkills;
  OverwriteEquipSkills? addEquipSkills;
  int? waveSetup;
  int? interruptibleQuest;
  int? masterImageId;
  List<int>? IgnoreBattlePointUp;
  // int? repeatReward;
  // List<int>? consumeItemBattleWin;
  int? useEventDeckNo;
  int? masterSkillDelay;
  String? masterSkillDelayInfo;

  QuestPhaseExtraDetail({
    this.questSelect,
    this.singleForceSvtId,
    this.hintTitle,
    this.hintMessage,
    this.aiNpc,
    this.aiMultiNpc,
    this.overwriteEquipSkills,
    this.addEquipSkills,
    this.waveSetup,
    this.masterImageId,
    this.IgnoreBattlePointUp,
    this.useEventDeckNo,
    this.masterSkillDelay,
    this.masterSkillDelayInfo,
  });

  factory QuestPhaseExtraDetail.fromJson(Map<String, dynamic> json) => _$QuestPhaseExtraDetailFromJson(json);

  Map<String, dynamic> toJson() => _$QuestPhaseExtraDetailToJson(this);

  OverwriteEquipSkills? getMergedOverwriteEquipSkills() {
    if (overwriteEquipSkills?.skills.isNotEmpty == true || addEquipSkills?.skills.isNotEmpty == true) {
      return OverwriteEquipSkills(iconId: overwriteEquipSkills?.iconId ?? addEquipSkills?.iconId, skills: [
        ...?overwriteEquipSkills?.skills,
        ...?addEquipSkills?.skills,
      ]);
    }
    return null;
  }
}

@JsonSerializable()
class OverwriteEquipSkills {
  int? iconId;
  // int? cutInView;
  // int? notDispEquipSkillIconSplit;
  List<OverwriteEquipSkill> skills;

  OverwriteEquipSkills({
    this.iconId,
    this.skills = const [],
  });

  String get icon {
    final iconId = this.iconId ?? 0;
    String url = "https://static.atlasacademy.io/file/aa-fgo-extract-jp/Battle/Common/";
    if ((iconId) > 2) {
      url += 'BattleAssetUIAtlas/';
    } else {
      url += 'BattleUIAtlas/';
    }
    url += "btn_master_skill${iconId == 0 ? "" : iconId}.png";
    return url;
  }

  List<int> get skillIds => skills.map((e) => e.id).toList();

  int get skillLv => skills.firstOrNull?.lv ?? 1;

  Future<MysticCode> toMysticCode() async {
    final icon = this.icon;
    List<NiceSkill> niceSkills = [];
    for (final skillId in skillIds) {
      final skill = await AtlasApi.skill(skillId);
      if (skill != null) {
        niceSkills.add(skill);
      }
    }
    return MysticCode(
      id: 0,
      name: "OverwriteEquip",
      detail: "",
      extraAssets: ExtraMCAssets(
        item: MCAssets(male: icon, female: icon),
        masterFace: MCAssets(male: icon, female: icon),
        masterFigure: MCAssets(male: icon, female: icon),
      ),
      skills: niceSkills,
      expRequired: [0],
    );
  }

  factory OverwriteEquipSkills.fromJson(Map<String, dynamic> json) => _$OverwriteEquipSkillsFromJson(json);

  Map<String, dynamic> toJson() => _$OverwriteEquipSkillsToJson(this);
}

@JsonSerializable()
class OverwriteEquipSkill {
  int id;
  int lv;
  int condId; // common release id

  OverwriteEquipSkill({
    required this.id,
    this.lv = 0,
    this.condId = 0,
  });

  factory OverwriteEquipSkill.fromJson(Map<String, dynamic> json) => _$OverwriteEquipSkillFromJson(json);

  Map<String, dynamic> toJson() => _$OverwriteEquipSkillToJson(this);
}

@JsonSerializable()
class Restriction {
  int id;
  String name;
  RestrictionType type;
  RestrictionRangeType rangeType;
  List<int> targetVals;
  List<int> targetVals2;

  Restriction({
    required this.id,
    this.name = '',
    this.type = RestrictionType.none,
    this.rangeType = RestrictionRangeType.none,
    this.targetVals = const [],
    this.targetVals2 = const [],
  });

  factory Restriction.fromJson(Map<String, dynamic> json) => _$RestrictionFromJson(json);

  Map<String, dynamic> toJson() => _$RestrictionToJson(this);
}

@JsonSerializable()
class QuestPhaseRestriction {
  Restriction restriction;
  FrequencyType frequencyType;
  String dialogMessage;
  String noticeMessage;
  String title;

  QuestPhaseRestriction({
    required this.restriction,
    this.frequencyType = FrequencyType.none,
    this.dialogMessage = '',
    this.noticeMessage = '',
    this.title = '',
  });

  factory QuestPhaseRestriction.fromJson(Map<String, dynamic> json) => _$QuestPhaseRestrictionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestPhaseRestrictionToJson(this);
}

@JsonSerializable()
class QuestGroup {
  final int questId;
  final int type;
  final int groupId;

  QuestGroupType get type2 => kQuestGroupTypeMapping[type] ?? QuestGroupType.none;

  QuestGroup({
    required this.questId,
    required this.type,
    required this.groupId,
  });

  factory QuestGroup.fromJson(Map<String, dynamic> json) => _$QuestGroupFromJson(json);

  Map<String, dynamic> toJson() => _$QuestGroupToJson(this);
}

@JsonSerializable()
class BattleBg {
  final int id;
  final BattleFieldEnvironmentGrantType type;
  final int priority;
  final List<NiceTrait> individuality;
  final int imageId;

  BattleBg({
    required this.id,
    this.type = BattleFieldEnvironmentGrantType.none,
    this.priority = 0,
    this.individuality = const [],
    this.imageId = 0,
  });

  factory BattleBg.fromJson(Map<String, dynamic> json) => _$BattleBgFromJson(json);

  Map<String, dynamic> toJson() => _$BattleBgToJson(this);
}

@JsonSerializable()
class BasicQuestPhaseDetail {
  final int questId;
  final int phase;
  final List<int> classIds;
  // final List<int> individuality;
  final int qp;
  final int exp;
  final int bond;
  final int giftId;
  final List<Gift> gifts;
  final int? spotId;
  @protected
  final int? consumeType;
  final int? actConsume;
  final String? recommendLv;

  ConsumeType? get consumeType2 {
    if (consumeType == null) return null;
    return ConsumeType.values.firstWhereOrNull((e) => e.value == consumeType);
  }

  BasicQuestPhaseDetail({
    required this.questId,
    required this.phase,
    this.classIds = const [],
    this.qp = 0,
    this.exp = 0,
    this.bond = 0,
    this.giftId = 0,
    List<Gift>? gifts,
    this.spotId,
    this.consumeType,
    this.actConsume,
    this.recommendLv,
  }) : gifts = gifts ?? (giftId == 448 ? Gift.kGift448 : []);

  factory BasicQuestPhaseDetail.fromJson(Map<String, dynamic> json) => _$BasicQuestPhaseDetailFromJson(json);

  Map<String, dynamic> toJson() => _$BasicQuestPhaseDetailToJson(this);
}

///

class QuestFlagConverter extends JsonConverter<QuestFlag, String> {
  const QuestFlagConverter();
  @override
  QuestFlag fromJson(String value) => decodeEnum(_$QuestFlagEnumMap, value, QuestFlag.none);
  @override
  String toJson(QuestFlag obj) => _$QuestFlagEnumMap[obj] ?? obj.name;
}

enum QuestType {
  main(1),
  free(2),
  friendship(3),
  event(5),
  heroballad(6),
  warBoard(7),
  autoExecute(8),
  ;

  final int value;
  const QuestType(this.value);
  String get shownName {
    switch (this) {
      case QuestType.main:
        return S.current.main_quest;
      case QuestType.free:
        return S.current.free_quest;
      case QuestType.friendship:
        return S.current.interlude;
      case QuestType.event:
        return S.current.event;
      case QuestType.warBoard:
        return S.current.war_board;
      case QuestType.heroballad:
      case autoExecute:
        return name;
    }
  }
}

final kQuestTypeIds = {for (final t in QuestType.values) t.value: t};

enum ConsumeType {
  none(0),
  ap(1),
  rp(2),
  item(3),
  apAndItem(4);

  const ConsumeType(this.value);
  final int value;

  bool get useAp => this == ap || this == apAndItem;
  bool get useApOrBp => this == ap || this == apAndItem || this == rp;
  bool get useItem => this == item || this == apAndItem;
  String get unit => useAp ? 'AP' : (this == rp ? 'BP' : '');
}

enum QuestAfterClearType {
  close,
  repeatFirst,
  repeatLast,
  resetInterval,
  closeDisp,
  ;

  bool get isRepeat => this == repeatLast || this == repeatFirst;
}

@JsonEnum(alwaysCreate: true)
enum QuestFlag {
  none,
  noBattle,
  raid,
  raidConnection,
  noContinue,
  noDisplayRemain,
  raidLastDay,
  closedHideCostItem,
  closedHideCostNum,
  closedHideProgress,
  closedHideRecommendLv,
  closedHideTrendClass,
  closedHideReward,
  noDisplayConsume,
  superBoss,
  noDisplayMissionNotify,
  hideProgress,
  dropFirstTimeOnly,
  chapterSubIdJapaneseNumeralsCalligraphy,
  supportOnlyForceBattle,
  eventDeckNoSupport,
  fatigueBattle,
  supportSelectAfterScript,
  branch,
  userEventDeck,
  noDisplayRaidRemain,
  questMaxDamageRecord,
  enableFollowQuest,
  supportSvtMultipleSet,
  supportOnlyBattle,
  actConsumeBattleWin,
  vote,
  hideMaster,
  disableMasterSkill,
  disableCommandSpeel,
  supportSvtEditablePosition,
  branchScenario,
  questKnockdownRecord,
  notRetrievable,
  displayLoopmark,
  boostItemConsumeBattleWin,
  playScenarioWithMapscreen,
  battleRetreatQuestClear,
  battleResultLoseQuestClear,
  branchHaving,
  noDisplayNextIcon,
  windowOnly,
  changeMasters,
  notDisplayResultGetPoint,
  forceToNoDrop,
  displayConsumeIcon,
  harvest,
  reconstruction,
  enemyImmediateAppear,
  noSupportList,
  live,
  forceDisplayEnemyInfo,
  alloutBattle,
  recollection,
  notSingleSupportOnly,
  disableChapterSub,
}

enum GiftType {
  unknown(0),
  servant(1),
  item(2),
  friendship(3),
  userExp(4),
  equip(5),
  eventSvtJoin(6),
  eventSvtGet(7),
  questRewardIcon(8),
  costumeRelease(9),
  costumeGet(10),
  commandCode(11),
  eventPointBuff(12), // 94030203, pointBuff.id
  eventBoardGameToken(13), // 80285047=eventId*1000+tokenId in mstEventBoardGameToken
  eventCommandAssist(14), // 80505
  eventHeelPortrait(15), // =svtId
  battleItem(16),
  ;

  const GiftType(this.value);
  final int value;

  static GiftType fromId(int id) {
    return GiftType.values.firstWhere((e) => e.value == id, orElse: () => GiftType.unknown);
  }
}

enum EnemyRoleType {
  normal,
  danger,
  servant,
}

enum SvtDeathType {
  normal,
  escape,
  stand,
  effect,
  wait,
  energy,
  crystal,
  explosion,
}

enum DeckType {
  enemy,
  call,
  shift,
  change,
  transform,
  skillShift,
  missionTargetSkillShift,
  aiNpc,
  svtFollower,
  ;

  bool get isInShiftDeck => this == shift || this == change || this == skillShift || this == missionTargetSkillShift;
}

enum RestrictionType {
  none, // custom
  individuality,
  rarity,
  totalCost,
  lv,
  supportOnly,
  uniqueSvtOnly,
  fixedSupportPosition,
  fixedMySvtIndividualityPositionMain,
  fixedMySvtIndividualitySingle,
  svtNum,
  mySvtNum,
  mySvtOrNpc,
  alloutBattleUniqueSvt,
  fixedSvtIndividualityPositionMain,
  uniqueIndividuality,
  mySvtOrSupport,
  dataLostBattleUniqueSvt,
}

enum RestrictionRangeType {
  none,
  equal,
  notEqual,
  above,
  below,
  between,
}

enum FrequencyType {
  none,
  once,
  onceUntilReboot,
  everyTime,
  valentine,
  everyTimeAfter,
  everyTimeBefore,
  onceUntilRemind,
}

enum StageLimitActType {
  win,
  lose,
}

enum NpcServantFollowerFlag {
  unknown,
  npc,
  hideSupport,
  notUsedTreasureDevice,
  noDisplayBonusIcon,
  applySvtChange,
  hideEquip,
  noDisplayBonusIconEquip,
  hideTreasureDeviceLv,
  hideTreasureDeviceDetail,
  hideRarity,
  notClassBoard,
}

enum NpcFollowerEntityFlag {
  none,
  recommendedIcon,
  isMySvtOrNpc,
  fixedNpc,
}

enum QuestGroupType {
  none(0),
  eventQuest(1), // groupId=eventId
  questRelease(2), // CondType.questGroupClear
  eventPointQuest(3),
  eventPointGroupQuest(4),
  eventRaceQuest(5),
  eventRaceGroupQuest(6),
  missionGroupQuest(7),
  eventTower(8), // groupId=tower id
  eventTowerFloor(9), // groupId=tower floor
  highlightQuest(10),
  eventDailyPoint(11),
  eventActivityPointGauge(12),
  interlude(13),
  eventBattleLine(14),
  battleGroup(15),
  shareQuestInfo(16),
  alloutBattleQuest(17),
  eventFortification(18),
  ;

  const QuestGroupType(this.value);
  final int value;
}

final kQuestGroupTypeMapping = {for (final v in QuestGroupType.values) v.value: v};

enum BattleFieldEnvironmentGrantType {
  none(0),
  stage(1),
  @JsonValue('function')
  function_(2);

  const BattleFieldEnvironmentGrantType(this.value);
  final int value;
}

enum AiAllocationApplySvtFlag {
  all(0),
  own(1),
  friend(2),
  npc(4),
  unknown(-1);

  const AiAllocationApplySvtFlag(this.value);
  final int value;
}
