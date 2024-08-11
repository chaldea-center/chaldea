import 'dart:typed_data';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image/image.dart' as img_lib;

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'converter.dart';

class MCQuestConvertPage extends StatefulWidget {
  final Quest quest;
  const MCQuestConvertPage({super.key, required this.quest});

  @override
  State<MCQuestConvertPage> createState() => _MCQuestConvertPageState();
}

class _MCQuestConvertPageState extends State<MCQuestConvertPage> {
  late final quest = widget.quest;
  List<QuestPhase?> questPhases = [];

  late final parser = _MCQuestConverter(widget.quest);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    EasyLoading.show();
    try {
      await parser.loadAndConvert();
      EasyLoading.dismiss();
    } catch (e, s) {
      EasyLoading.showError(e.toString());
      logger.e('convert mc quest failed', e, s);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("导出Mooncell关卡"),
        actions: [
          IconButton(
            onPressed: () {
              loadData();
            },
            icon: const Icon(Icons.refresh),
            tooltip: S.current.refresh,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              children: [
                if (parser.errors.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [Text(S.current.error), Text(parser.errors.join('\n'))],
                      ),
                    ),
                  ),
                colorPicker,
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(parser.result),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: OverflowBar(
              alignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: parser.result.isEmpty
                      ? null
                      : () {
                          copyToClipboard(parser.result, toast: true);
                        },
                  child: Text(S.current.copy),
                ),
                FilledButton(
                  onPressed: () => _jumpToMooncell(quest),
                  child: const Text("跳转到Mooncell"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget get colorPicker {
    return TileGroup(
      header: '标题背景',
      children: [
        ListTile(
          dense: true,
          title: const Text('默认'),
          trailing: Text(parser.getDefaultTitleBg() ?? '无'),
          tileColor: parser.kHtmlColors[parser.getDefaultTitleBg()],
        ),
        ListTile(
          dense: true,
          title: const Text('背景图'),
          trailing: parser.titleBanner == null ? const Text('未加载') : Image.memory(parser.titleBanner!),
        ),
        ListTile(
          dense: true,
          title: const Text('提取颜色'),
          subtitle: Text(parser.bannerColor == null ? '未加载' : parser.bannerColor!.toCSSHex()),
          tileColor: parser.bannerColor,
          trailing: parser.cropTitleBanner == null
              ? null
              : Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Image.memory(parser.cropTitleBanner!),
                ),
        ),
      ],
    );
  }
}

class MCQuestListConvertPage extends StatefulWidget {
  final String? title;
  final List<Quest> quests;
  final NiceWar? war;
  const MCQuestListConvertPage({super.key, this.title, required this.quests, this.war});

  @override
  State<MCQuestListConvertPage> createState() => _MCQuestListConvertPageState();
}

class _MCQuestListConvertPageState extends State<MCQuestListConvertPage> {
  List<_MCQuestConverter> converters = [];
  bool _useBgColor = true;
  late String? title = widget.title;

  @override
  void initState() {
    super.initState();
    if (title == S.current.free_quest) {
      title = '自由关卡';
    }

    converters = [for (final quest in widget.quests) _MCQuestConverter(quest)..useTitleBg = _useBgColor];
    loadData();
  }

  bool _running = false;
  Future<void> loadData() async {
    if (_running) return;
    _running = true;
    try {
      int finished = 0;
      EasyLoading.show(status: '$finished/${converters.length}...');
      List<Future> futures = converters.map((converter) async {
        converter.useTitleBg = _useBgColor;
        await converter.loadAndConvert(widget.quests);
        finished += 1;
        EasyLoading.show(status: '$finished/${converters.length}...');
      }).toList();
      await Future.wait(futures);
      await Future.delayed(const Duration(milliseconds: 50));
      EasyLoading.dismiss();
      int error = converters.where((e) => e.errors.isNotEmpty).length;
      if (error == 0) {
        EasyLoading.showSuccess('共${converters.length}个关卡');
      } else {
        EasyLoading.showInfo('共${converters.length}个关卡, $error个包含错误/警告');
      }
    } catch (e, s) {
      logger.e('convert quests failed', e, s);
      EasyLoading.showError(e.toString());
    } finally {
      _running = false;
    }
    if (mounted) setState(() {});
  }

  String getAllResults() {
    final buffer = StringBuffer();
    final war = widget.war;
    final event = war?.eventReal;
    if (war != null && event != null && title == '主线关卡') {
      final converter = McConverter();
      final eventName = Transl.eventNames(event.detail);
      final condWar = war.releaseCondWar;

      buffer.writeln("""{{关卡信息
|类型=${war.parentWars.contains(WarId.mainInterlude) ? "主线物语" : "活动"}
|章名称cn=${converter.getPageName(eventName.maybeOf(Region.cn)) ?? ""}
|开始时间cn=
|结束时间cn=
|地点cn=${war.lLongName.maybeOf(Region.cn) ?? ""}
|章名称jp=${converter.getPageName(event.detail)}
|开始时间jp=${converter.getJpTime(event.startedAt)}
|结束时间jp=${converter.getJpTime(event.endedAt)}
|地点jp=${war.longName}
|开放条件=${converter.getPageName(condWar?.extra.mcLink) ?? ""}
|地图=
}}
""");
    }
    if (title != null) {
      buffer.writeln('==$title==');
    }
    for (final converter in converters) {
      if (converter.result.isEmpty) {
        buffer.writeln('「${converter.quest.lName.l}」未解析\n');
      } else {
        buffer.writeln(converter.result);
      }
      if (converter.errors.isNotEmpty) {
        buffer.writeln(converter.errors.join('\n'));
        buffer.writeln();
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final result = getAllResults();
    return Scaffold(
      appBar: AppBar(
        title: const Text('导出至Mooncell'),
        actions: [
          IconButton(onPressed: loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              children: [
                SwitchListTile(
                  // dense: true,
                  value: _useBgColor,
                  title: const Text('添加标题背景颜色'),
                  onChanged: (v) {
                    setState(() {
                      _useBgColor = v;
                    });
                    loadData();
                  },
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(result),
                  ),
                )
              ],
            ),
          ),
          SafeArea(
            child: OverflowBar(
              alignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () {
                    copyToClipboard(result, toast: true);
                  },
                  child: Text('${S.current.copy}(${converters.length}个关卡)'),
                ),
                if (converters.isNotEmpty)
                  FilledButton(
                    onPressed: () => _jumpToMooncell(converters.first.quest, anchor: title),
                    child: const Text("跳转到Mooncell"),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _MCQuestConverter extends McConverter {
  // static
  static final Map<String, (Uint8List, Uint8List, Color)> _bannerCaches = {};
  // data
  final Quest quest;
  Map<int, QuestPhase> questPhases = {};
  Map<int, QuestPhase?> cnQuestPhases = {};
  Map? rawQuest;
  Uint8List? titleBanner;
  Uint8List? cropTitleBanner;
  Color? bannerColor;
  // options
  bool useTitleBg = true;
  String? titleBg;

  _MCQuestConverter(this.quest);

  final Map<String, Color> kHtmlColors = const {
    'Chocolate': Color.fromARGB(255, 123, 63, 0),
    'Maroon': Color.fromARGB(255, 128, 0, 0),
    'darkred': Color.fromARGB(255, 139, 0, 0),
  };

  String? getDefaultTitleBg() {
    if (quest.warId == WarId.rankup || quest.type == QuestType.friendship) {
      return 'Chocolate';
    } else if (quest.warId == WarId.advanced) {
      return 'darkred';
    } else if (quest.name.startsWith('【高難易度】')) {
      return 'Maroon';
    }
    return null;
  }

  Future<void> loadAndConvert([List<Quest>? questList]) async {
    result = '';
    errors.clear();
    checkLanguageError();
    questPhases.clear();
    cnQuestPhases.clear();
    final phases = (quest.isMainStoryFree && quest.phases.length == 3) ? [quest.phases.last] : quest.phases;
    List<Future> futures = [];
    futures.addAll(phases.map((phase) async {
      final questPhase = await AtlasApi.questPhase(quest.id, phase,
          expireAfter: quest.isMainStoryFree ? const Duration(minutes: 10) : null);
      if (questPhase == null) {
        errors.add('Phase $phase 获取数据失败');
      } else {
        questPhases[phase] = questPhase;
        if (db.gameData.mappingData.warRelease.cn?.contains(quest.warId) == true) {
          cnQuestPhases[phase] = await AtlasApi.questPhase(quest.id, phase, region: Region.cn);
        }
      }
    }).toList());
    futures.add(_loadRaw());

    await Future.wait(futures);
    result = convert(questList);
  }

  Future<void> _loadRaw() async {
    final rawQuest = await AtlasApi.cacheManager.getJson('${AtlasApi.atlasApiHost}/raw/JP/quest/${quest.id}');
    final int? bannerId = rawQuest['mstQuest']?['bannerId'];
    final int? bannerType = rawQuest['mstQuest']?['bannerType'];
    await pickBannerColor(bannerId ?? 0, bannerType ?? 0);
  }

  Future<void> pickBannerColor(int bannerId, int bannerType) async {
    String? url;
    if (bannerId == 0) {
      // index=quest.type
      const msQBoardL3Names = [
        "",
        "img_questboard_main_",
        "img_questboard_free_",
        "img_questboard_story03",
        "",
        "img_questboard_free_",
        "img_questboard_hero03"
      ];
      // https://explorer.atlasacademy.io/aa-fgo-public/JP/Banner/
      switch (quest.type) {
        case QuestType.main:
        case QuestType.free:
        case QuestType.event:
          final prefix = msQBoardL3Names.getOrNull(quest.type.value);
          if (prefix != null) {
            url = '${HostsX.atlasAssetHost}/JP/Banner/$prefix$bannerType.png';
          }
        default:
          break;
      }
    } else {
      url = '${HostsX.atlasAssetHost}/JP/EventUI/quest_board_$bannerId.png';
    }
    if (url == null) return;

    if (_bannerCaches.containsKey(url)) {
      final cache = _bannerCaches[url]!;
      titleBanner = cache.$1;
      cropTitleBanner = cache.$2;
      bannerColor = cache.$3;
      return;
    }
    final imgBytes = await CachedApi.cacheManager.get(url);
    if (imgBytes == null) return;
    titleBanner = Uint8List.fromList(imgBytes);
    final img = img_lib.decodePng(titleBanner!);
    if (img == null) return;
    final w = img.width, h = img.height;
    final cropped = img_lib.copyCrop(img,
        x: (0.35 * w).toInt(), y: (28 / 256 * h).toInt(), width: (0.4 * w).toInt(), height: (80 / 256 * h).toInt());
    final r = Maths.sum(cropped.map((e) => e.r.toInt())) ~/ cropped.length;
    final g = Maths.sum(cropped.map((e) => e.g.toInt())) ~/ cropped.length;
    final b = Maths.sum(cropped.map((e) => e.b.toInt())) ~/ cropped.length;
    bannerColor = Color.fromARGB(255, r, g, b);
    cropTitleBanner = img_lib.encodePng(cropped);
    _bannerCaches[url] = (titleBanner!, cropTitleBanner!, bannerColor!);
  }

  String convert([List<Quest>? questList]) {
    // errors.clear();
    String? nameCn = quest.lName.maybeOf(Region.cn);
    bool allNoBattle = questPhases.values.every((q) => q.isNoBattle);
    Set<String> recommendLvs = questPhases.values.map((e) => e.recommendLv).toSet();
    Set<int> bonds = questPhases.values.map((e) => e.bond).toSet();
    Set<int> exps = questPhases.values.map((e) => e.exp).toSet();
    Set<int> qps = questPhases.values.map((e) => e.qp).toSet();
    bool sameBond = allNoBattle;
    List<String> extraInfo = [];
    final svt = db.gameData.servantsById.values.firstWhereOrNull((e) => e.relateQuestIds.contains(quest.id));

    String effectiveTitleBg = "";
    if (useTitleBg) {
      effectiveTitleBg = titleBg ?? getDefaultTitleBg() ?? bannerColor?.toCSSHex() ?? "";
    }

    String chapter = "";
    if (quest.type == QuestType.main) {
      chapter = quest.chapterSubStr.isEmpty && quest.chapterSubId != 0
          ? S.current.quest_chapter_n(quest.chapterSubId)
          : Transl.questNames(quest.chapterSubStr).l;
      if (chapter.isEmpty) {
        chapter = nameCn ?? quest.name;
        final match = RegExp(r'^(第\S{1,2}[節节]) \S').firstMatch(chapter);
        if (match != null) {
          chapter = match.group(1)!;
        }
      }
    }

    if (chapter.isEmpty) {
      chapter = nameCn ?? quest.name;
    }

    final buffer = StringBuffer("""===$chapter===\n{{关卡配置\n""");
    buffer.write('|开放条件=');
    List<String> conds = [];

    String getQuestName(int questId) {
      final q = db.gameData.quests[questId];
      if (q == null) return questId.toString();
      if (q.warId != quest.warId) {
        if (q.id == q.war?.lastQuestId) {
          return q.war!.lShortName;
        } else {
          return "${q.war!.lShortName} ${q.lNameWithChapter}";
        }
      }
      return q.lNameWithChapter;
    }

    for (final cond in quest.releaseConditions) {
      if (cond.type == CondType.questClear) {
        conds.add("通关「${getQuestName(cond.targetId)}」");
      } else if (cond.type == CondType.questGroupClear) {
        final questIds = db.gameData.others.getQuestsOfGroup(QuestGroupType.questRelease, cond.targetId);
        conds.add("通关「${questIds.map((e) => getQuestName(e)).join('、')}」");
      } else if (cond.type == CondType.eventMissionAchieve || cond.type == CondType.eventMissionClear) {
        final mission = db.gameData.others.eventMissions[cond.targetId];
        conds.add("完成任务No.${mission?.dispNo ?? cond.targetId}");
      } else if (cond.type == CondType.eventTotalPoint) {
        final event = db.gameData.events[cond.targetId];
        if (event != null && event.pointGroups.length > 1) {
          conds.add("活动点数合计${cond.value}以上后");
        } else {
          conds.add("活动点数${cond.value}以上后");
        }
      } else if (cond.type == CondType.eventGroupPoint) {
        final pointName = db.gameData.others.eventPointGroups[cond.targetId]?.lName.l ?? "活动点数【${cond.targetId}】";
        conds.add("$pointName${cond.value}以上");
      }
    }

    if (questList != null && questList.isNotEmpty) {
      int getDay(int t) {
        final datetime = questList.first.openedAt.sec2date().toUtc().add(const Duration(hours: 9));
        return datetime.year * 10000 + datetime.month * 100 + datetime.day;
      }

      final firstDay = getDay(questList.first.openedAt);
      final days = getDay(quest.openedAt) - firstDay + 1;

      if (days > 1) {
        conds.add("第$days天${getJpTime(quest.openedAt).split(' ').last}");
      }
    }
    if (conds.isNotEmpty) {
      buffer.writeln('${conds.join('&')}后');
    } else {
      buffer.writeln();
    }
    // end release conds

    buffer.writeln("""
|名称jp=${quest.name}
|名称cn=${nameCn ?? ""}
|标题背景颜色=$effectiveTitleBg""");
    if (svt != null) {
      buffer.writeln('|图标=Servant ${svt.collectionNo.toString().padLeft(3, "0")}');
    }

    if (!allNoBattle) {
      if (bonds.length == 1 && exps.length == 1 && qps.length == 1) {
        sameBond = true;
        buffer.writeln("""|推荐等级=${recommendLvs.single}
|牵绊=${bonds.single}
|经验=${exps.single}
|QP=${qps.single}""");
      }
    }
    if (quest.flags.contains(QuestFlag.displayLoopmark)) {
      buffer.writeln("|可重复=${quest.phases.last}");
    }
    for (final phase in quest.phases) {
      buffer.write(cvtPhase(questPhases[phase], cnQuestPhases[phase], sameBond, extraInfo));
    }
    final gifts = quest.gifts.where((gift) => gift.type != GiftType.questRewardIcon).toList();
    // gifts.sort((a, b) => Item.compare2(a.objectId, b.objectId));
    buffer.write('|通关奖励=');
    for (final gift in gifts) {
      if (gift.type == GiftType.equip) {
        buffer.write('{{装备小图标|${db.gameData.mysticCodes[gift.objectId]?.lName.l}}}');
      } else {
        buffer.write(getWikiDaoju(gift.objectId));
      }
      buffer.write('×${gift.num} ');
    }
    if (quest.warId == WarId.rankup || quest.type == QuestType.friendship) {
      final svt = db.gameData.servantsById.values.firstWhereOrNull((svt) => svt.relateQuestIds.contains(quest.id));
      final td = svt?.noblePhantasms.lastWhereOrNull((e) => e.condQuestId == quest.id);
      final skill = svt?.skills.lastWhereOrNull((e) => e.condQuestId == quest.id);
      if (td != null) {
        buffer.write('{{强化|宝具|${td.lName.l}}} ');
      }
      if (skill != null) {
        final skills = svt?.skills
                .where((e) => e.id != skill.id && e.svt.num == skill.svt.num && e.svt.priority < skill.svt.priority)
                .toList() ??
            [];
        skills.sort2((e) => e.svt.priority);
        final skillBefore = skills.lastOrNull;
        buffer.write('{{强化|技能${skill.svt.num}|前=${skillBefore?.lName.l}|后=${skill.lName.l}}} ');
      }
    }
    buffer.writeln();

    if (quest.gifts.any((e) => e.giftAdds.isNotEmpty)) {
      extraInfo.add('部分通关奖励可能被替换');
    }
    if (quest.presents.isNotEmpty) {
      extraInfo.add('进度${quest.presents.map((e) => e.phase).join("&")}有单独的奖励！！！');
    }
    if (quest.flags.contains(QuestFlag.branch)) {
      extraInfo.add('分支关卡，需要合并到默认关卡中');
    }
    for (final questPhase in questPhases.values) {
      if (questPhase.enemyHashes.length > 1) {
        extraInfo.add('进度${questPhase.phase}: 存在多种敌方配置，可能随剧情选择变化或随机');
      }
    }

    extraInfo.addAll([
      if (quest.flags.contains(QuestFlag.noContinue)) '无法续关',
      if (quest.flags.contains(QuestFlag.dropFirstTimeOnly)) '只有首次通关时才能获得牵绊点、经验值、战利品、通关奖励',
    ]);
    if (extraInfo.isNotEmpty) {
      buffer.writeln('|备注=${extraInfo.join("\n\n")}');
    }
    buffer.writeln('}}');
    return buffer.toString().split('\n').map((e) => e.trimRight()).join('\n');
  }

  String cvtPhase(QuestPhase? quest, QuestPhase? cnQuest, bool sameBond, List<String> extraInfo) {
    if (quest == null) {
      return '';
    }
    final buffer = StringBuffer();
    final int phase = (quest.isMainStoryFree && quest.phases.length == 3) ? 1 : quest.phase;
    final String phaseZh = getZhNum(phase);
    // AP
    buffer.write('|${phaseZh}AP=');
    switch (quest.consumeType) {
      case ConsumeType.none:
        buffer.writeln('0');
      case ConsumeType.ap:
        buffer.writeln(quest.consume.toString());
      case ConsumeType.rp:
        buffer.writeln('{{color|LimeGreen|BP}}${quest.consume}');
      case ConsumeType.item:
        buffer.writeln(quest.consumeItem.map((item) => '${getWikiDaoju(item.itemId)}${item.amount}').join(' '));
      case ConsumeType.apAndItem:
        buffer.write('AP${quest.consume} ');
        buffer.writeln(quest.consumeItem.map((item) => '${getWikiDaoju(item.itemId)}${item.amount}').join(' '));
    }

    if (!sameBond && !quest.isNoBattle) {
      buffer.writeln("""|$phaseZh推荐等级=${quest.recommendLv}
|$phaseZh牵绊=${quest.bond}
|$phaseZh经验=${quest.exp}
|${phaseZh}QP=${quest.qp}""");
    }
    // spot
    String spotName = quest.spotName;
    final spot = quest.spot;
    if (const [WarId.daily, WarId.interlude, WarId.rankup, WarId.advanced, WarId.chaldeaGate].contains(quest.warId)) {
      spotName = 'カルデアゲート';
    } else if (spot != null && spot.map?.hasSize == false && !spot.blankEarth) {
      spotName = "";
    }
    buffer.writeln('|$phaseZh地点jp=$spotName');
    buffer.writeln('|$phaseZh地点cn=${Transl.spotNames(spotName).maybeOf(Region.cn) ?? ""}');
    // stage
    for (final stage in quest.stages) {
      final String stagePrefix = '$phaseZh${stage.wave}';
      final startEffect =
          const {1: 'BATTLE', 2: 'FATAL BATTLE', 3: 'GRAND BATTLE'}[stage.startEffectId] ?? 'Battle <!--特殊开场特效-->';
      buffer.writeln('|$stagePrefix=$startEffect');
      final enemyDeck = stage.enemies.where((e) => e.deck == DeckType.enemy).toList();
      final shiftDeck = stage.enemies.where((e) => e.deck == DeckType.shift).toList();
      final callDeck = stage.enemies.where((e) => e.deck == DeckType.call).toList();
      enemyDeck.sort2((e) => e.deckId);
      for (final enemy in enemyDeck) {
        buffer.write('|$stagePrefix敌人${enemy.deckId}=');
        buffer.writeln(buildEnemyWithShift(enemy, shiftDeck));
      }
      int callDeckIdStart = (Maths.max(enemyDeck.map((e) => e.deckId), 0) / 3).ceil() * 3;
      callDeck.sort2((e) => e.deckId);
      for (final enemy in callDeck) {
        buffer.write('|$stagePrefix敌人${callDeckIdStart + enemy.deckId}=');
        buffer.writeln(buildEnemyWithShift(enemy, shiftDeck));
      }

      if (enemyDeck.length != enemyDeck.map((e) => e.deckId).toSet().length) {
        extraInfo.add('进度$phase Wave${stage.wave} 同一位置存在多个敌人，可能整合自多个版本');
      }
    }
    // drops
    if (!quest.isNoBattle) {
      buffer.write('|$phaseZh战利品=');

      final dropBuffer = StringBuffer();

      if (quest.isAnyFree) {
        Map<int, Set<int>> possibleDrops = {};
        final drops = quest.drops.toList();
        drops.sort((a, b) => Item.compare2(a.objectId, b.objectId));
        for (final drop in drops) {
          if (drop.type == GiftType.item && drop.objectId == Items.qpId) {
            possibleDrops.putIfAbsent(drop.objectId, () => {}).add(drop.num);
          } else {
            possibleDrops.putIfAbsent(drop.objectId, () => {}).add(1);
          }
        }

        for (final (objectId, setNums) in possibleDrops.items) {
          for (final setNum in setNums) {
            dropBuffer.write(getWikiDaoju(objectId, setNum: setNum));
          }
          dropBuffer.write(' ');
        }
      } else if (quest.type == QuestType.warBoard) {
        final warBoards = quest.war?.event?.warBoards ?? [];
        final warBoardStage = warBoards
            .expand((e) => e.stages)
            .firstWhereOrNull((e) => e.questId == quest.id && e.questPhase == quest.phase);
        if (warBoardStage != null) {
          final allTreasures = warBoardStage.squares.expand((e) => e.treasures).toList();
          allTreasures.sort2((e) => -e.rarity.index);
          Map<WarBoardTreasureRarity, List<WarBoardTreasure>> treasureDict = {};
          for (final treasure in allTreasures) {
            treasureDict.putIfAbsent(treasure.rarity, () => []).add(treasure);
          }
          // common/rare/srare
          for (final (rarity, treasures) in treasureDict.items) {
            dropBuffer.write(const {
                  WarBoardTreasureRarity.common: '铜箱子',
                  WarBoardTreasureRarity.rare: '银箱子',
                  WarBoardTreasureRarity.srare: '金箱子',
                }[rarity] ??
                rarity.name);
            dropBuffer.write('：');
            for (final treasure in treasures) {
              for (final gift in treasure.gifts) {
                dropBuffer.write(getWikiDaoju(gift.objectId));
                dropBuffer.write('×${gift.num}');
                dropBuffer.write(' ');
              }
            }
          }
        }
      } else {
        Map<int, Map<int, int>> fixedDrops = {};
        for (final enemy in quest.allEnemies) {
          for (final drop in enemy.drops) {
            final fixedNum = drop.dropCount ~/ drop.runs;
            if (fixedNum > 0) {
              fixedDrops.putIfAbsent(drop.objectId, () => {}).addNum(drop.num, fixedNum);
            }
          }
        }
        final itemIds = fixedDrops.keys.toList();
        itemIds.sort((a, b) => Item.compare2(a, b));
        for (final objectId in itemIds) {
          final setNums = fixedDrops[objectId]!;
          for (final setNum in setNums.keys) {
            dropBuffer.write(getWikiDaoju(objectId, setNum: setNum));
            dropBuffer.write('×${setNums[setNum]}');
          }
          dropBuffer.write(' ');
        }
      }
      final runs = quest.drops.firstOrNull?.runs ?? 0;
      if (quest.drops.isNotEmpty && runs < 20) {
        dropBuffer.write(' <!-- 样本数($runs)较低，战利品信息可能不准确 -->');
      }
      buffer.writeln(dropBuffer.toString());
      // final dropText = dropBuffer.toString().trim();
      // if (dropText.isNotEmpty) {
      //   buffer.write('{{subst:关卡配置/战利品/subst|$dropText}}');
      // }
      // buffer.writeln();
    }
    // 杂项名称
    List<String> formationConds = [];
    if (quest.flags.contains(QuestFlag.supportSelectAfterScript)) {
      formationConds.add('该关卡的队伍编制将在战斗开始前进行');
    }
    for (final restriction in (cnQuest ?? quest).restrictions) {
      if (!const [
        '編成制限あり',
      ].contains(restriction.restriction.name)) {
        formationConds.add(restriction.restriction.name);
      }
    }
    if (formationConds.isNotEmpty) {
      buffer.writeln('|$phaseZh杂项名称={{color|Orange|编队条件}}');
      buffer.writeln('|$phaseZh杂项内容=${formationConds.join("\n")}');
    }
    // 战斗效果
    List<String> battleEffects = [];
    if (quest.stages.any((e) => e.enemyFieldPosCountReal != 3)) {
      if (quest.stages.map((e) => e.enemyFieldPosCountReal).toSet().length == 1) {
        battleEffects.add('场上最多出现${quest.stages.first.enemyFieldPosCountReal}个敌人');
      } else {
        for (final stage in quest.stages) {
          if (stage.enemyFieldPosCountReal != 3) {
            battleEffects.add('场上最多出现${stage.enemyFieldPosCountReal}个敌人(wave${stage.wave})');
          }
        }
      }
    }
    Set<String> disabledMasterEffects = {
      if (quest.flags.contains(QuestFlag.hideMaster)) ...['御主', '令咒'],
      if (quest.flags.contains(QuestFlag.disableCommandSpeel)) '令咒',
      if (quest.flags.contains(QuestFlag.disableMasterSkill)) '魔术礼装',
    };
    if (disabledMasterEffects.isNotEmpty) {
      battleEffects.add('无${disabledMasterEffects.join('、')}');
    }
    if (battleEffects.isNotEmpty) {
      buffer.writeln('|$phaseZh战斗效果=${battleEffects.join("\n")}');
    }
    // 助战
    if (quest.supportServants.isNotEmpty) {
      buffer.write('|$phaseZh助战=');
      for (final support in quest.supportServants) {
        // {{助战|从者名|显示名(省略时使用从者名)|等级|宝具等级|技能等级|装备礼装(省略时表示无礼装)|礼装等级(省略时为20级)}}
        buffer.write('{{助战');
        final svtName = getSvtWikiLink(support.svt);
        final dispName = support.lName.l;
        buffer.write('|$svtName|${dispName == svtName ? "" : dispName}');
        buffer.write('|${support.lv}');
        buffer.write('|${support.noblePhantasm.lv ?? "-"}');
        final tdStrengthStatus = support.noblePhantasm.noblePhantasm?.strengthStatus ?? 0;
        if (tdStrengthStatus == 99) {
          // only 1->99, cannot detect 1 inside 2->1->99
          buffer.write('▲');
        }
        String getSkillLv(NiceSkill? skill, int skillLv) {
          if (skill == null || skillLv <= 0) return '-';
          return skill.strengthStatus > 1 ? '$skillLv▲' : '$skillLv';
        }

        buffer.write('|');
        buffer.write([
          getSkillLv(support.skills2.skill1, support.skills2.skillLv1),
          getSkillLv(support.skills2.skill2, support.skills2.skillLv2),
          getSkillLv(support.skills2.skill3, support.skills2.skillLv3),
        ].join('/'));

        if (support.equips.isNotEmpty) {
          final ce = support.equips.first;
          if (ce.equip.collectionNo == 0) {
            // add at last
          } else {
            buffer.write('|${ce.equip.extra.mcLink ?? ce.equip.lName.l}');
            if (ce.lv != 20) {
              buffer.write('|${ce.lv}');
            }
          }
        }
        if (support.limit.limitCount > 10) {
          buffer.write('|灵衣=1');
        }
        buffer.write('}} ');
      }
      if (quest.supportServants.any((q) => q.equips.any((ce) => ce.equip.id > 0 && ce.equip.collectionNo == 0))) {
        buffer.write('{{助战|概念礼装=1}}');
      }
      buffer.writeln();
      if (quest.isNpcOnly) {
        buffer.writeln('|$phaseZh助战限定=限定');
      }
    }
    return buffer.toString();
  }

  String buildEnemyWithShift(QuestEnemy enemy, List<QuestEnemy> shiftEnemies) {
    String svtName = getSvtWikiLink(enemy.svt);
    String displayName = trimEnemyName(enemy);
    final buffer = StringBuffer();
    buffer.write('{{敌人${enemy.roleType.index + 1}|$svtName|${displayName == svtName ? "" : displayName}');
    buffer.write('|${getSvtClass(enemy.svt.classId)}|${enemy.lv}|${enemy.hp}');
    final shifts = enemy.enemyScript.shift ?? [];
    for (final npcId in shifts) {
      final shift = shiftEnemies.firstWhereOrNull((e) => e.npcId == npcId);
      if (shift == null) {
        errors.add('shiftId=$npcId not found');
        continue;
      }
      String shiftSvtName = shift.svt.lName.maybeOf(Region.cn) ?? shift.name;
      String shiftDisplayName = trimEnemyName(shift);
      buffer.write('|敌人${shift.roleType.index + 1}');
      buffer.write(
          '|${shiftSvtName == svtName ? "" : shiftSvtName}|${shiftDisplayName == displayName ? "" : shiftDisplayName}');
      buffer.write('|${getSvtClass(shift.svt.classId)}|${shift.lv}|${shift.hp}');
    }
    buffer.write('}}');
    return buffer.toString();
  }

  String getSvtWikiLink(BasicServant svt) {
    String? link;
    if (svt.collectionNo > 0) {
      link = db.gameData.servantsById[svt.id]?.extra.mcLink?.replaceAll('_', ' ');
    }
    link ??= svt.lName.maybeOf(Region.cn) ?? svt.name;
    return link;
  }

  String trimEnemyName(QuestEnemy enemy) {
    String name = enemy.lShownName;
    if (enemy.roleType == EnemyRoleType.servant) {
      if (name.startsWith('谜之') ||
          name.startsWith('謎の') ||
          name.contains('女主角') ||
          name.contains('ヒロイン') ||
          name.toLowerCase().startsWith('beast')) {
        return name;
      }
    }
    if (name.length > 1) {
      String last = name.substring(name.length - 1);
      last = McConverter.kNormAlphabet[last] ?? last;
      String last2 = name.substring(name.length - 2, name.length - 1);
      last2 = McConverter.kNormAlphabet[last2] ?? last2;
      if (last.compareTo('A') >= 0 &&
          last.compareTo('Z') <= 0 &&
          !(last2.compareTo('A') >= 0 && last2.compareTo('Z') <= 0)) {
        name = name.substring(0, name.length - 1);
      }
    }
    return name;
  }
}

void _jumpToMooncell(Quest quest, {String? anchor}) {
  String? mcLink;
  bool subpage = true;
  if (quest.type == QuestType.friendship || quest.warId == WarId.rankup) {
    mcLink =
        db.gameData.servantsNoDup.values.firstWhereOrNull((e) => e.relateQuestIds.contains(quest.id))?.extra.mcLink;
  } else if (quest.war?.isMainStory == true) {
    mcLink = quest.war?.extra.mcLink;
  } else if (quest.war?.eventReal != null) {
    mcLink = quest.war?.eventReal?.extra.mcLink;
  } else if (quest.warId == WarId.advanced) {
    mcLink = '迦勒底之门/进阶关卡';
    subpage = false;
  } else {
    final huntingId = quest.event?.extra.script.huntingId ?? 0;
    if (huntingId > 0) {
      mcLink = quest.event?.extra.mcLink;
      subpage = false;
    }
  }
  if (mcLink == null || mcLink.isEmpty) {
    EasyLoading.showInfo('未指定wiki页面，请手动打开');
    return;
  }
  if (subpage && !mcLink.endsWith('关卡配置')) mcLink += '/关卡配置';
  if (anchor != null) mcLink += '#$anchor';
  launch('https://fgo.wiki/w/$mcLink', external: true);
}
