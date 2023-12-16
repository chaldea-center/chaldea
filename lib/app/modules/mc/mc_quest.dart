import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'converter.dart';

class MCQuestEditPage extends StatefulWidget {
  final Quest quest;
  const MCQuestEditPage({super.key, required this.quest});

  @override
  State<MCQuestEditPage> createState() => _MCQuestEditPageState();
}

class _MCQuestEditPageState extends State<MCQuestEditPage> {
  late final quest = widget.quest;
  List<QuestPhase?> questPhases = [];

  late final _parser = _MCQuestConverter(widget.quest);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    EasyLoading.show();
    try {
      await _parser.loadData();
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
                  if (_parser.errors.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [Text(S.current.error), Text(_parser.errors.join('\n'))],
                        ),
                      ),
                    ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(_parser.result),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: _parser.result.isEmpty
                        ? null
                        : () {
                            copyToClipboard(_parser.result, toast: true);
                          },
                    child: Text(S.current.copy),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

class _MCQuestConverter extends McConverter {
  // data
  final Quest quest;
  Map<int, QuestPhase> questPhases = {};
  Map<int, QuestPhase?> cnQuestPhases = {};
  Map<String, dynamic>? rawQuest;
  // options
  String? titleBg;
  // result
  String result = '';

  _MCQuestConverter(this.quest);

  Future<void> loadData() async {
    errors.clear();
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
        cnQuestPhases[phase] = await AtlasApi.questPhase(quest.id, phase, region: Region.cn);
      }
    }));
    futures.add(AtlasApi.cacheManager.getJson('${AtlasApi.atlasApiHost}/raw/JP/quest/${quest.id}').then((value) {
      if (value == null) {
        errors.add('raw quest data 获取失败');
      } else {
        rawQuest = Map.from(value);
      }
    }));

    await Future.wait(futures);
    if (rawQuest == null) {}
    result = convert();
  }

  String convert() {
    errors.clear();
    String? nameCn = quest.lName.maybeOf(Region.cn);
    bool allNoBattle = questPhases.values.every((q) => q.isNoBattle);
    Set<String> recommendLvs = questPhases.values.map((e) => e.recommendLv).toSet();
    Set<int> bonds = questPhases.values.map((e) => e.bond).toSet();
    Set<int> exps = questPhases.values.map((e) => e.exp).toSet();
    Set<int> qps = questPhases.values.map((e) => e.qp).toSet();
    bool sameBond = allNoBattle;
    String? titleBg = this.titleBg;
    if (quest.warId == WarId.rankup || quest.type == QuestType.friendship) {
      titleBg = 'Chocolate';
    } else if (quest.name.startsWith('【高難易度】')) {
      titleBg = 'Maroon';
    }
    final buffer = StringBuffer("""===${nameCn ?? quest.name}===
{{关卡配置
|开放条件=
|名称jp=${quest.name}
|名称cn=${nameCn ?? ""}
|标题背景颜色=${titleBg ?? ""}
""");
    final svt = db.gameData.servantsById.values.firstWhereOrNull((e) => e.relateQuestIds.contains(quest.id));
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
      buffer.write(cvtPhase(questPhases[phase], cnQuestPhases[phase], sameBond));
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

    List<String> extraInfo = [];
    if (quest.gifts.any((e) => e.giftAdds.isNotEmpty)) {
      extraInfo.add('部分通关奖励可能被替换');
    }
    if (quest.flags.contains(QuestFlag.branch)) {
      extraInfo.add('分支关卡，需要合并到默认关卡中');
    }
    for (final questPhase in questPhases.values) {
      if (questPhase.enemyHashes.length > 1) {
        extraInfo.add('wave${questPhase.phase}: 存在多种敌方配置，可能随剧情选择变化或随机');
      }
    }

    extraInfo.addAll([
      if (quest.flags.contains(QuestFlag.noContinue)) '无法续关',
      if (quest.flags.contains(QuestFlag.dropFirstTimeOnly)) '只有首次通关时才能获得牵绊点、经验值、战利品、通关奖励',
    ]);
    if (extraInfo.isNotEmpty) {
      buffer.writeln('|备注=${extraInfo.join("\n")}');
    }
    buffer.writeln('}}');
    return buffer.toString().split('\n').map((e) => e.trimRight()).join('\n');
  }

  String cvtPhase(QuestPhase? quest, QuestPhase? cnQuest, bool sameBond) {
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
    if (const [WarId.rankup, WarId.interlude, WarId.advanced].contains(quest.warId)) {
      spotName = 'カルデアゲート';
    }
    buffer.writeln('|$phaseZh地点jp=$spotName');
    buffer.writeln('|$phaseZh地点cn=${Transl.spotNames(spotName).maybeOf(Region.cn) ?? ""}');
    // stage
    for (final stage in quest.stages) {
      final String stagePrefix = '$phaseZh${stage.wave}';
      final startEffect =
          const {1: 'BATTLE', 2: 'FATAL BATTLE', 3: 'GRAND BATTLE'}[stage.startEffectId] ?? 'Battle <!--特殊开场特效-->';
      buffer.writeln('|$stagePrefix=$startEffect');
      final enemies = stage.enemies.where((e) => e.deck == DeckType.enemy).toList();
      final shifts = stage.enemies.where((e) => e.deck == DeckType.shift).toList();
      enemies.sort2((e) => e.deckId);
      for (final enemy in enemies) {
        buffer.write('|$stagePrefix敌人${enemy.deckId}=');
        buffer.writeln(buildEnemyWithShift(enemy, shifts));
      }
    }
    // drops
    if (!quest.isNoBattle) {
      buffer.write('|$phaseZh战利品=');
      bool isFree = quest.isAnyFree;
      if (isFree) {
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
            buffer.write(getWikiDaoju(objectId, setNum: setNum));
            buffer.write(' ');
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
            buffer.write(getWikiDaoju(objectId, setNum: setNum));
            buffer.write('×${setNums[setNum]}');
          }
          buffer.write(' ');
        }
      }
      buffer.writeln();
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
        final svt = db.gameData.servantsById[support.svt.id];
        final svtName = svt?.extra.mcLink ?? support.svt.lName.l;
        final dispName = support.lName.l;
        buffer.write('|${svt?.extra.mcLink ?? support.svt.lName.l}|${dispName == svtName ? "" : dispName}');
        buffer.write('|${support.lv}');
        buffer.write('|${support.noblePhantasm.lv ?? "-"}');
        if ((support.noblePhantasm.noblePhantasm?.strengthStatus ?? 0) > 1) {
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
        buffer.write('}}');
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
    String svtName = enemy.svt.lName.maybeOf(Region.cn) ?? enemy.name;
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

  String trimEnemyName(QuestEnemy enemy) {
    String name = enemy.lShownName;
    if (enemy.roleType == EnemyRoleType.servant) return name;
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
