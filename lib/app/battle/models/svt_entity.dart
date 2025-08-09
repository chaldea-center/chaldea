import 'dart:math';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_exception.dart';
import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/individuality.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'ai.dart';

class BattleServantData {
  static const npPityThreshold = 9900;
  static List<BuffAction> buffEffectivenessTypes = [BuffAction.buffRate, BuffAction.funcHpReduce];

  final bool isPlayer;
  bool get isEnemy => !isPlayer;
  final bool isGrandSvt;
  final bool isUseGrandBoard; // should not be used
  int? eventId;
  QuestEnemy? niceEnemy;
  QuestEnemy? baseEnemy;
  Servant? niceSvt;
  BasicServant? overrideSvt;
  PlayerSvtData? playerSvtData;
  SvtAiManager svtAi = SvtAiManager(null);

  // performance issue,
  String? _battleNameCache;
  int? _limitCountCache;
  String get lBattleName {
    if (isPlayer) {
      if (_battleNameCache != null && _limitCountCache == playerSvtData!.limitCount) {
        return _battleNameCache!;
      } else {
        _limitCountCache = playerSvtData!.limitCount;
        return _battleNameCache = niceSvt!.lBattleName(playerSvtData!.limitCount).l;
      }
    } else {
      return niceEnemy!.lShownName;
    }
  }

  int get limitCount => isPlayer ? playerSvtData!.limitCount : niceEnemy!.limit.useLimitCount;

  // int exceedCount = 0;
  // int transformSvtId = -1;
  // int transformIndex = -1;
  // int totalDamage = 0;
  // Servant? svtData;
  // int maxLevel = 0;
  // dynamic followerType; // none/friend/non_friend/npc/npc_no_td
  // int maxActNum = 0;
  // int lineMaxNp = 100;
  // int tmpNp = 0;
  // int equipAtk = 0;
  // int equipHp = 0;
  // int maxTpTurn = 0;
  // int nextTpTurn = 0;
  // int downStarRate = 0;
  // int downTdRate = 0;
  // int deathRate = 0;
  // int svtType = 0; //displayType, npcSvtType;
  // int criticalRate = 0;
  // int reducedHp = 0;
  // int restAttackCount = 0;
  // int overkillTargetId = 0;
  // int resultHp = 0;
  // List<int> userCommandCodeIds = [];
  // List<NiceTrait> svtIndividuality = [];
  // int tdId = 0;
  // int tdLv = 0;

  int fieldIndex = -1; // start from 0
  int deckIndex = -1;
  int uniqueId = 0;
  int svtId = -1;
  int level = 0;
  int baseAtk = 0;
  int hp = 0;
  int _maxHp = 0;
  int get maxHp {
    final addition = getMaxHpBuffValue(percent: false);
    final percentAddition = toModifier(getMaxHpBuffValue(percent: true) * _maxHp).toInt();

    return max(_maxHp + addition + percentAddition, 1);
  }

  // TODO: adjustable?
  int bond = 5;
  int startingPosition = 0;
  // initScript will set initial value
  Map<int, int> curBattlePoints = {};

  int determineBattlePointPhase(final int battlePointId) {
    final battlePoint = niceSvt?.battlePoints.firstWhereOrNull((battlePoint) => battlePoint.id == battlePointId);
    final curBattlePoint = curBattlePoints[battlePointId];
    if (battlePoint == null || curBattlePoint == null) {
      return 0;
    }

    int phase = 0;
    for (final battlePointPhase in battlePoint.phases) {
      if (battlePointPhase.value <= curBattlePoint) {
        phase = max(phase, battlePointPhase.phase);
      }
    }
    return phase;
  }

  int getMaxBattlePointPhase(int battlePointId) {
    return Maths.max(niceSvt?.battlePoints.expand((e) => e.phases).map((e) => e.phase) ?? <int>[], 0);
  }

  int np = 0; // player, np/100
  int npLineCount = 0; // enemy
  bool usedNpThisTurn = false;
  int reducedHp = 0; // used for bug overkill checks
  int get accumulationDamage => _accumulationDamage;
  // used for Angry Mango NP (damageNpCounter)
  // set with procAccumulationDamage(previousHp)
  // reset with resetAccumulationDamage (after use or after reflectionFunction buff is added)
  int _accumulationDamage = 0;

  // BattleServantData.Status status
  // NiceTd? td;
  // int ascensionPhase = 0;
  List<BattleSkillInfoData> skillInfoList = []; // BattleSkillInfoData, only active skills for now
  BattleCEData? equip1;
  BattleCEData? equip2;
  BattleCEData? equip3;
  BattleBuff battleBuff = BattleBuff();
  List<List<BattleSkillInfoData>> commandCodeSkills = [];

  List<int> shiftNpcIds = [];
  int shiftLowLimit = 0; // lowLimitShift in dw terms
  int shiftDeckIndex = -1;
  int get shiftCounts => shiftNpcIds.length - shiftLowLimit;
  List<int> changeNpcIds = [];
  int changeIndex = 0;

  bool attacked = false;
  // @Deprecated('actionHistory')
  BattleServantData? lastHitBy;
  // @Deprecated('actionHistory')
  CommandCardData? lastHitByCard;
  NiceFunction? lastHitByFunc;
  List<NiceFunction> receivedFunctionsList = [];
  List<int> triggeredSkillIds = [];
  List<BattleServantActionHistory> actionHistory = [];

  BattleServantData._({required this.isPlayer, required this.isGrandSvt, required this.isUseGrandBoard});

  @override
  String toString() {
    return 'BattleServantData(${fieldIndex + 1}-$lBattleName)';
  }

  factory BattleServantData.fromEnemy(final QuestEnemy enemy, final int uniqueId, int? eventId, {Servant? niceSvt}) {
    final svt = BattleServantData._(
      isPlayer: false,
      isGrandSvt: enemy.enemyScript.isGrandSvt == 1 && db.gameData.grandGraphDetails.containsKey(enemy.svt.classId),
      isUseGrandBoard: false,
    );
    svt
      ..eventId = eventId
      ..niceEnemy = enemy
      ..baseEnemy = enemy
      ..svtAi = SvtAiManager(enemy.ai)
      ..niceSvt = niceSvt
      ..uniqueId = uniqueId
      ..startingPosition = enemy.deckId
      ..hp = enemy.hp
      .._maxHp = enemy.hp
      ..baseAtk = enemy.atk
      ..svtId = enemy.svt.id
      ..level = enemy.lv
      ..deckIndex = enemy.deckId
      ..shiftNpcIds = enemy.enemyScript.shift ?? []
      ..changeNpcIds = enemy.enemyScript.change ?? [];

    svt.skillInfoList = [
      BattleSkillInfoData(
        enemy.skills.skill1,
        skillNum: 1,
        skillLv: enemy.skills.skillLv1,
        type: SkillInfoType.svtSelf,
      ),
      BattleSkillInfoData(
        enemy.skills.skill2,
        skillNum: 2,
        skillLv: enemy.skills.skillLv2,
        type: SkillInfoType.svtSelf,
      ),
      BattleSkillInfoData(
        enemy.skills.skill3,
        skillNum: 3,
        skillLv: enemy.skills.skillLv3,
        type: SkillInfoType.svtSelf,
      ),
    ];
    return svt;
  }

  factory BattleServantData.fromPlayerSvtData(
    final PlayerSvtData settings,
    final int uniqueId, {
    final int startingPosition = 0,
    required bool isUseGrandBoard,
  }) {
    final psvt = settings.svt;
    if (psvt == null) {
      throw BattleException('Invalid PlayerSvtData: null svt');
    }

    final growCurve = psvt.growCurveForLimit(settings.limitCount);
    final svt = BattleServantData._(
      isPlayer: true,
      isGrandSvt: settings.grandSvt && db.gameData.grandGraphDetails.containsKey(psvt.classId),
      isUseGrandBoard: isUseGrandBoard,
    );
    svt
      ..playerSvtData = settings.copy()
      ..uniqueId = uniqueId
      ..niceSvt = psvt
      ..svtId = psvt.id
      ..level = settings.lv
      ..startingPosition = startingPosition
      .._maxHp = settings.fixedHp ?? ((growCurve.hp.getOrNull(settings.lv - 1) ?? 0) + settings.hpFou)
      ..baseAtk = settings.fixedAtk ?? ((growCurve.atk.getOrNull(settings.lv - 1) ?? 0) + settings.atkFou);
    if (svt.isGrandSvt) {
      svt._maxHp += 1000;
      svt.baseAtk += 1000;
    }
    if (settings.equip1.ce != null) {
      svt.equip1 = BattleCEData(settings.equip1.ce!, settings.equip1.limitBreak, settings.equip1.lv);
      svt._maxHp += svt.equip1!.hp;
    }
    if (svt.isGrandSvt && isUseGrandBoard) {
      if (settings.equip2.ce != null) {
        svt.equip2 = BattleCEData(settings.equip2.ce!, settings.equip2.limitBreak, settings.equip2.lv);
        svt._maxHp += svt.equip2!.hp;
      }
      if (settings.equip3.ce != null) {
        svt.equip3 = BattleCEData(settings.equip3.ce!, settings.equip3.limitBreak, settings.equip3.lv);
        svt._maxHp += svt.equip3!.hp;
      }
    }
    svt.hp = svt._maxHp;

    final script = psvt.script;
    for (final skillNum in kActiveSkillNums) {
      final List<BaseSkill> provisionedSkills = [];
      provisionedSkills.addAll(psvt.groupedActiveSkills[skillNum] ?? []);
      List<BaseSkill?>? rankUps;
      if (script != null && script.skillRankUp != null) {
        rankUps = [
          for (final id in script.skillRankUp![settings.skills[skillNum - 1]?.id] ?? <int>[])
            db.gameData.baseSkills[id],
        ];
        if (rankUps.isNotEmpty) {
          provisionedSkills.addAll(rankUps.whereType());
        }
      }

      final baseSkill = settings.skills[skillNum - 1], skillLv = settings.skillLvs[skillNum - 1];

      final skillInfo = BattleSkillInfoData(
        baseSkill,
        provisionedSkills: provisionedSkills,
        skillNum: skillNum,
        skillLv: skillLv,
        type: SkillInfoType.svtSelf,
      );

      final startTurn = baseSkill?.script?.battleStartRemainingTurn?.getOrNull(skillLv - 1);
      if (startTurn != null && startTurn > 0) {
        skillInfo.chargeTurn = startTurn;
      }

      if (rankUps != null) {
        skillInfo.rankUps = rankUps;
      }

      svt.skillInfoList.add(skillInfo);
    }

    for (final commandCode in settings.commandCodes) {
      if (commandCode != null) {
        svt.commandCodeSkills.add(
          commandCode.skills
              .map((skill) => BattleSkillInfoData(skill, type: SkillInfoType.commandCode)..skillLv = 1)
              .toList(),
        );
      } else {
        svt.commandCodeSkills.add([]);
      }
    }
    return svt;
  }

  Future<void> loadEnemySvtData(final BattleData battleData) async {
    if (niceEnemy == null) return;
    final svtId = niceEnemy!.svt.id;
    if (niceSvt != null && niceSvt!.id == svtId) return;
    niceSvt = db.gameData.servantsById[svtId] ?? await showEasyLoading(() => AtlasApi.svt(svtId), mask: true);
    if (niceSvt == null) {
      battleData.battleLogger.error("failed to load servant data for enemy $svtId - ${niceEnemy?.lShownName}");
    }
  }

  bool get selectable => battleBuff.isSelectable;

  int get tdLv => (isPlayer ? playerSvtData!.tdLv : niceEnemy!.noblePhantasm.noblePhantasmLv).clamp(0, 5);

  int get atk {
    int totalAtk = baseAtk;
    if (isPlayer) {
      totalAtk += equip1?.atk ?? 0;
      if (isGrandSvt) {
        totalAtk += equip2?.atk ?? 0;
        totalAtk += equip3?.atk ?? 0;
      }
    }
    return totalAtk;
  }

  int get rarity => isPlayer
      ? niceSvt!.getAscended(limitCount, (attr) => attr.overwriteRarity) ?? niceSvt!.rarity
      : niceEnemy!.svt.rarity;

  int get originalClassId => isPlayer ? niceSvt!.classId : niceEnemy!.svt.classId;

  int get baseClassId {
    if (isGrandSvt) {
      return db.gameData.grandGraphDetails[originalClassId]?.grandClassId ?? originalClassId;
    } else {
      return originalClassId;
    }
  }

  int get logicalClassId {
    final overwriteBattleClassBuff = collectBuffsPerAction(
      battleBuff.validBuffsActiveFirst,
      BuffAction.overwriteBattleclass,
    ).lastWhereOrNull((buff) => buff.param != 0);
    if (overwriteBattleClassBuff != null) {
      return overwriteBattleClassBuff.param;
    }

    return baseClassId;
  }

  ServantSubAttribute get attribute {
    final overwriteSubattributeBuff = collectBuffsPerAction(
      battleBuff.validBuffsActiveFirst,
      BuffAction.overwriteSubattribute,
    ).firstOrNull;
    final overwriteSubattribute = ServantSubAttribute.values.firstWhereOrNull(
      (attr) => attr.value == overwriteSubattributeBuff?.vals.Value,
    );
    if (overwriteSubattribute != null && overwriteSubattribute != ServantSubAttribute.default_) {
      return overwriteSubattribute;
    }
    return isPlayer ? niceSvt!.getAttribute(limitCount) : niceEnemy!.svt.attribute;
  }

  int get starGen => isPlayer ? niceSvt!.starGen : 0;

  int get defenceNpGain => isPlayer ? playerSvtData?.td?.npGain.defence[playerSvtData!.tdLv - 1] ?? 0 : 0;

  int get enemyTdRate => isEnemy ? niceEnemy!.serverMod.tdRate : 0;

  int get enemyTdAttackRate => isEnemy ? niceEnemy!.serverMod.tdAttackRate : 0;

  int get enemyStarRate => isEnemy ? niceEnemy!.serverMod.starRate : 0;

  bool get isBuggedOverkill => reducedHp > hp;

  int get deathRate => isEnemy ? niceEnemy!.deathRate : niceSvt!.instantDeathChance;

  String get npValueText {
    if (isEnemy) {
      if (niceEnemy!.noblePhantasm.noblePhantasm?.functions.isNotEmpty == true && niceEnemy!.chargeTurn > 0) {
        return '$npLineCount/${niceEnemy!.chargeTurn}';
      } else {
        return '-';
      }
    } else {
      if (playerSvtData!.td != null) {
        return (np / 100).toString();
      } else {
        return '-';
      }
    }
  }

  Future<void> loadAi(final BattleData battleData) async {
    svtAi = SvtAiManager(niceEnemy?.ai);
    if (battleData.options.simulateAi) {
      await svtAi.fetchAiData();
    }
  }

  Future<void> initScript(final BattleData battleData) async {
    await loadAi(battleData);

    if (niceEnemy != null) {
      int shiftLength = niceEnemy!.enemyScript.shift?.length ?? 0;
      int shiftPosition = niceEnemy!.enemyScript.shiftPosition ?? -1;
      if (shiftPosition >= 0) {
        shiftDeckIndex = shiftPosition;
        shiftLowLimit = (shiftPosition + 1).clamp(0, shiftLength - 1);
      }
      int dispBreakShift = niceEnemy!.enemyScript.dispBreakShift ?? 0;
      if (dispBreakShift > 0) {
        shiftDeckIndex += dispBreakShift;
      }

      shiftDeckIndex = shiftDeckIndex.clamp(-1, shiftLength - 1);
      final shouldShift = dispBreakShift > 0 || shiftPosition >= 0;
      if (shouldShift) {
        shiftDeckIndex -= 1; // go to previous shift to shift to desired shift
        await shift(battleData);
      }
    }

    if (niceSvt != null && playerSvtData?.supportType != SupportSvtType.friend) {
      final questBlockList = battleData.niceQuest?.extraDetail?.IgnoreBattlePointUp;
      for (final battlePoint in niceSvt!.battlePoints) {
        if (questBlockList == null || !questBlockList.contains(battlePoint.id)) {
          curBattlePoints[battlePoint.id] = 0;
        }
      }
    }
  }

  Future<void> activateClassPassive(final BattleData battleData) async {
    final List<BaseSkill> passives = [];

    if (isPlayer) {
      final ascensionAdds = niceSvt!.getAscended(limitCount, (attr) => attr.overwriteClassPassive);
      if (ascensionAdds != null) {
        for (final skillId in ascensionAdds) {
          BaseSkill? skill = db.gameData.baseSkills[skillId];
          skill ??= await showEasyLoading(() => AtlasApi.skill(skillId), mask: true);
          if (skill == null) {
            battleData.battleLogger.debug('Buff ID [$skillId}]: ${S.current.skill} [$skillId] ${S.current.not_found}');
            continue;
          }

          passives.add(skill);
        }
      } else {
        passives.addAll(niceSvt!.classPassive);
      }
    } else {
      passives.addAll(niceEnemy!.classPassive.classPassive);
    }

    for (final skill in passives) {
      final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtClassPassive);
      await skillInfo.activate(battleData, activator: this);
    }
    if (isEnemy) {
      for (final (index, skill) in niceEnemy!.classPassive.addPassive.indexed) {
        final skillInfo = BattleSkillInfoData(
          skill,
          type: SkillInfoType.svtOtherPassive,
          skillLv: niceEnemy!.classPassive.addPassiveLvs.getOrNull(index) ?? skill.maxLv,
        );
        await skillInfo.activate(battleData, activator: this);
      }
    }

    if (isPlayer) {
      for (int index = 0; index < niceSvt!.appendPassive.length; index += 1) {
        final appendLv = playerSvtData!.appendLvs.length > index ? playerSvtData!.appendLvs[index] : 0;
        if (appendLv > 0) {
          final skillInfo = BattleSkillInfoData(
            niceSvt!.appendPassive[index].skill,
            type: SkillInfoType.svtOtherPassive,
            skillLv: appendLv,
          );
          await skillInfo.activate(battleData, activator: this);
        }
      }
    }
  }

  Future<void> activateClassBoard(BattleData battleData) async {
    if (!isPlayer) return;
    final classBoardData = playerSvtData!.classBoardData;
    final baseBoard = ClassBoard.getClassBoard(niceSvt!.classId);
    if (baseBoard != null) {
      final skill = baseBoard.toSkill(classBoardData.classBoardSquares);
      if (skill != null) {
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.classBoardSkill);
        await skillInfo.activate(battleData, activator: this);
      }
    }

    final grandBoard = ClassBoard.getGrandClassBoard(niceSvt!.classId);
    if (battleData.isUseGrandBoard && grandBoard != null && isGrandSvt) {
      final skill = grandBoard.toSkill(classBoardData.grandClassBoardSquares);
      if (skill != null) {
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.classBoardSkill);
        await skillInfo.activate(battleData, activator: this);
      }
    }
  }

  Future<void> activateEquip(final BattleData battleData) async {
    await equip1?.activateCE(battleData, this);

    if (battleData.isUseGrandBoard && isPlayer && isGrandSvt) {
      if (playerSvtData!.classBoardData.grandBondEquipSkillChange && equip2 != null) {
        final skillId = ConstData.constants.grandFriendshipEquipSkillId;
        final changeSkill = db.gameData.baseSkills[skillId] ?? await AtlasApi.skill(skillId);
        final skillInfo = BattleSkillInfoData(changeSkill, type: SkillInfoType.svtEquip);
        await skillInfo.activate(battleData, activator: this);
      } else {
        await equip2?.activateCE(battleData, this);
      }

      await equip3?.activateCE(battleData, this);
    }
  }

  Future<void> activateExtraPassive(final BattleData battleData) async {
    if (isPlayer) {
      // TODO: skill num check
      for (final skill in playerSvtData!.extraPassives) {
        if (playerSvtData!.disabledExtraSkills.contains(skill.id)) continue;
        if (skill.shouldActiveSvtEventSkill(
          eventId: battleData.niceQuest?.war?.eventId ?? 0,
          svtId: svtId,
          includeZero: true,
        )) {
          final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtOtherPassive);
          await skillInfo.activate(battleData, activator: this);
        }
      }
      for (final skillId in playerSvtData!.allowedExtraSkills) {
        final skill = db.gameData.baseSkills[skillId] ?? await AtlasApi.skill(skillId);
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtOtherPassive);
        await skillInfo.activate(battleData, activator: this);
      }
    }
  }

  Future<void> activateAdditionalPassive(final BattleData battleData) async {
    if (isPlayer) {
      for (int index = 0; index < playerSvtData!.customPassives.length; index++) {
        final skill = playerSvtData!.customPassives[index];
        final skillLv = playerSvtData!.customPassiveLvs[index];
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtOtherPassive, skillLv: skillLv);
        await skillInfo.activate(battleData, activator: this);
      }
    }
  }

  void postAddStateProcessing(final Buff buff, final DataVals dataVals) {
    if (buff.type == BuffType.addMaxhp && hp > 0) {
      gainHp(dataVals.Value!);
    } else if (buff.type == BuffType.subMaxhp && hp > 0) {
      lossHp(dataVals.Value!);
    } else if (buff.type == BuffType.upMaxhp && hp > 0) {
      gainHp(toModifier(_maxHp * dataVals.Value!).toInt());
    } else if (buff.type == BuffType.downMaxhp && hp > 0) {
      lossHp(toModifier(_maxHp * dataVals.Value!).toInt());
    } else if (buff.type == BuffType.reflectionFunction) {
      resetAccumulationDamage();
    }
  }

  String getSkillName(final int index) {
    if (skillInfoList.length <= index || index < 0) {
      return 'Invalid skill index: $index';
    }

    return skillInfoList[index].lName;
  }

  List<CommandCardData> getCards() {
    if (isEnemy) {
      return [];
    }

    // get regular cards for servants
    final cardDetails = niceSvt!.cardDetails;
    List<CardType> cards = niceSvt!.cards.where((card) => cardDetails.containsKey(card)).toList();

    // check for changeCardBuff
    final changeCardBuff = collectBuffsPerAction(battleBuff.validBuffs, BuffAction.changeCommandCardType).firstOrNull;
    final changeCardType = changeCardBuff == null ? null : CardType.fromId(changeCardBuff.param);

    // fill in for enemy units
    if (cards.isEmpty) {
      for (final card in [CardType.weak, CardType.strength]) {
        if (cardDetails.containsKey(card)) {
          cards.addAll(List.filled(3, card));
        }
      }
    }

    final List<CommandCardData> builtCards = [];
    for (int index = 0; index < cards.length; index += 1) {
      final isCardInDeck = niceSvt!.cards.getOrNull(index) == cards[index];

      final cardType = checkOverwriteSvtCardType(changeCardType ?? cards[index]);
      final detail = niceSvt!.cardDetails[cardType];
      if (detail == null) continue;

      final card = CommandCardData(
        svtId: svtId,
        svtLimit: limitCount,
        uniqueId: uniqueId,
        cardType: cardType,
        cardDetail: detail,
        cardIndex: index,
        isTD: false,
        npGain: getNPGain(cardType),
        traits: ConstData.cardInfo[cardType]!.values.first.individuality.toList(),
        commandCode: isCardInDeck ? playerSvtData!.commandCodes.getOrNull(index) : null,
        cardStrengthen: isCardInDeck ? playerSvtData!.cardStrengthens.getOrNull(index) ?? 0 : 0,
        critical: cardType.isStrength(),
      );

      builtCards.add(card);
    }
    return builtCards;
  }

  CommandCardData? getNPCard() {
    if (isEnemy) {
      final _td = niceEnemy!.noblePhantasm.noblePhantasm;
      if (_td == null) return null;
      return CommandCardData(
        svtId: svtId,
        svtLimit: limitCount,
        uniqueId: uniqueId,
        cardType: _td.card,
        cardDetail: CardDetail(
          attackIndividuality: _td.individuality.toList(),
          hitsDistribution: _td.damage,
          attackType: _td.damageType == TdEffectFlag.attackEnemyAll
              ? CommandCardAttackType.all
              : CommandCardAttackType.one,
        ),
        cardIndex: -1,
        td: _td,
        isTD: true,
        npGain: 0,
        traits: _td.individuality.toList(),
      );
    }

    final currentNP = getCurrentNP();
    final cardDetail = CardDetail(
      attackIndividuality: currentNP?.individuality ?? [],
      hitsDistribution: currentNP?.svt.damage ?? [100],
      attackType: currentNP?.damageType == TdEffectFlag.attackEnemyAll
          ? CommandCardAttackType.all
          : CommandCardAttackType.one,
    );

    return CommandCardData(
      svtId: svtId,
      svtLimit: limitCount,
      uniqueId: uniqueId,
      cardType: currentNP?.svt.card ?? CardType.none,
      cardDetail: cardDetail,
      cardIndex: -1,
      isTD: true,
      td: currentNP,
      npGain: currentNP?.npGain.np[playerSvtData!.tdLv - 1] ?? 0,
      traits: currentNP?.individuality ?? [],
    );
  }

  Future<CommandCardData?> getCounterCard(final BattleData battleData) async {
    // buff.vals.UseTreasureDevice: =0 means skill?
    final buff = battleBuff.validBuffs.lastWhereOrNull((buff) => buff.vals.CounterId != null);
    if (buff == null) return null;
    if (buff.vals.UseTreasureDevice == 1) {
      final tdId = buff.vals.CounterId ?? 0;
      final tdLv = buff.vals.CounterLv ?? 1;
      NiceTd? td = niceSvt?.noblePhantasms.firstWhereOrNull((e) => e.id == tdId);
      td ??= await showEasyLoading(() => AtlasApi.td(tdId), mask: true);
      if (td == null) {
        battleData.battleLogger.error('CounterId=$tdId not found');
        return null;
      }

      if (isEnemy) {
        return null;
      }

      final cardDetail = CardDetail(
        attackIndividuality: td.individuality,
        hitsDistribution: td.svt.damage,
        attackType: td.damageType == TdEffectFlag.attackEnemyAll
            ? CommandCardAttackType.all
            : CommandCardAttackType.one,
      );

      return CommandCardData(
        svtId: svtId,
        svtLimit: limitCount,
        uniqueId: uniqueId,
        cardType: td.svt.card,
        cardDetail: cardDetail,
        cardIndex: -1,
        isTD: true,
        td: td,
        counterBuff: buff,
        npGain: td.npGain.np[tdLv - 1],
        traits: td.individuality,
      );
    } else if (buff.vals.UseAttack == 1) {
      final cardId = buff.vals.CounterId ?? 0;
      final cardType = CardType.fromId(cardId);
      final cardDetail = niceSvt?.cardDetails[cardType];
      if (cardType == null || cardDetail == null) return null;
      return CommandCardData(
        svtId: svtId,
        svtLimit: limitCount,
        uniqueId: uniqueId,
        cardType: cardType,
        cardDetail: cardDetail,
        cardIndex: -1,
        isTD: false,
        counterBuff: buff,
        npGain: getNPGain(cardType),
        traits: ConstData.cardInfo[cardType]?.values.first.individuality.toList() ?? [],
      );
    } else {
      return null;
    }
  }

  CommandCardData? getExtraCard() {
    if (isEnemy) {
      return null;
    }

    final cardType = checkOverwriteSvtCardType(CardType.extra);
    final detail = niceSvt!.cardDetails[cardType];
    if (detail == null) return null;

    return CommandCardData(
      svtId: svtId,
      svtLimit: limitCount,
      uniqueId: uniqueId,
      cardType: cardType,
      cardDetail: detail,
      cardIndex: -1,
      isTD: false,
      npGain: getNPGain(cardType),
      traits: ConstData.cardInfo[cardType]!.values.first.individuality.toList(),
    );
  }

  CardType checkOverwriteSvtCardType(final CardType baseCardType) {
    final overwriteSvtCardTypeBuff = collectBuffsPerAction(
      battleBuff.validBuffs,
      BuffAction.overwriteSvtCardType,
    ).lastOrNull;
    if (overwriteSvtCardTypeBuff == null) {
      return baseCardType;
    }

    final selfTraits = getTraits(addTraits: ConstData.cardInfo[baseCardType]!.values.first.individuality.toList());
    if (overwriteSvtCardTypeBuff.shouldActivateBuffNoProbabilityCheck(selfTraits) &&
        kCardTypeMapping.containsKey(overwriteSvtCardTypeBuff.param)) {
      return kCardTypeMapping[overwriteSvtCardTypeBuff.param]!;
    } else {
      return baseCardType;
    }
  }

  int getNPGain(final CardType cardType) {
    if (!isPlayer) {
      return 0;
    }
    final currentNp = getCurrentNP();
    if (currentNp == null) {
      return 0;
    }

    if (cardType.isArts()) {
      return currentNp.npGain.arts[playerSvtData!.tdLv - 1];
    } else if (cardType.isBuster()) {
      return currentNp.npGain.buster[playerSvtData!.tdLv - 1];
    } else if (cardType.isQuick()) {
      return currentNp.npGain.quick[playerSvtData!.tdLv - 1];
    } else if (cardType.isExtra()) {
      return currentNp.npGain.extra[playerSvtData!.tdLv - 1];
    }

    return 0;
  }

  List<NiceTrait> getBasicSvtTraits() {
    Set<NiceTrait> traits = {};

    if (niceEnemy != null) {
      traits.addAll(niceEnemy!.traits);
    } else if (niceSvt != null) {
      final traitsAdd = niceSvt!.ascensionAdd.individuality.all[limitCount];
      if (traitsAdd != null && traitsAdd.isNotEmpty) {
        traits.addAll(traitsAdd);
      } else {
        traits.addAll(niceSvt!.traits);
      }
      // idx=1,2, or eventId01
      for (final add in niceSvt!.traitAdd) {
        if (add.eventId == 0 || add.eventId == eventId) {
          if (add.limitCount < 0 ||
              add.limitCount == limitCount ||
              add.limitCount == niceSvt?.profile.costume[limitCount]?.id) {
            // check startedAt/endedAt too?
            traits.addAll(add.trait);
          }
        }
      }
    }
    if (niceSvt != null) {
      final attriAdd = niceSvt!.ascensionAdd.attribute.all[limitCount];
      if (attriAdd != null && attriAdd != ServantSubAttribute.default_) {
        traits.removeWhere((e) => e.id == niceSvt!.attribute.trait?.value);
        if (attriAdd.trait != null) {
          traits.add(NiceTrait(id: attriAdd.trait!.value));
        }
      }
    }
    if (playerSvtData?.supportType.isSupport == true) {
      traits.add(NiceTrait(id: ConstData.constants.individualityIsSupport));
    }
    if (isPlayer && isGrandSvt) {
      traits.addAll(db.gameData.grandGraphDetails[originalClassId]?.adjustIndividuality ?? []);
    }
    return traits.toList();
  }

  static List<NiceTrait> fetchSelfTraits(
    final BuffAction buffAction,
    final BuffData buff,
    final BattleServantData self, {
    final CommandCardData? cardData,
    final bool isAttack = true,
    final DataVals? dataVals,
    final List<NiceTrait>? addTraits,
  }) {
    switch (buffAction) {
      case BuffAction.avoidanceIndividuality:
      case BuffAction.specialInvincible:
      case BuffAction.invincible:
      case BuffAction.avoidance:
      case BuffAction.avoidanceAttackDeathDamage:
      case BuffAction.avoidInstantdeath:
      case BuffAction.commandDef:
      case BuffAction.defencePierce:
      case BuffAction.defence:
      case BuffAction.damageDef:
      case BuffAction.criticalDamageDef:
      case BuffAction.npdamageDef:
      case BuffAction.specialdefence:
      case BuffAction.receiveDamagePierce:
      case BuffAction.receiveDamage:
      case BuffAction.specialReceiveDamage:
      case BuffAction.commandNpDef:
      case BuffAction.commandStarDef:
      case BuffAction.criticalStarDamageTaken:
      case BuffAction.avoidState:
      case BuffAction.resistanceState:
      case BuffAction.toleranceSubstate:
      case BuffAction.resistInstantdeath:
      case BuffAction.nonresistInstantdeath:
      case BuffAction.resistanceDelayNpturn:
      case BuffAction.chagetd:
      case BuffAction.guts:
      case BuffAction.functionGuts:
      case BuffAction.overwriteDamageDef:
        final activeOnly = buff.buff.script.IndvAddBuffPassive != 1;
        return self.getTraits(addTraits: self.getBuffTraits(activeOnly: activeOnly));
      case BuffAction.functionCommandcodeattackBefore:
      case BuffAction.functionCommandcodeattackBeforeMainOnly:
      case BuffAction.functionCommandattackBefore:
      case BuffAction.functionCommandattackBeforeMainOnly:
      case BuffAction.functionAttackBefore:
      case BuffAction.functionAttackBeforeMainOnly:
      case BuffAction.functionCommandcodeattackAfter:
      case BuffAction.functionCommandcodeattackAfterMainOnly:
      case BuffAction.functionCommandattackAfter:
      case BuffAction.functionCommandattackAfterMainOnly:
      case BuffAction.functionAttackAfter:
      case BuffAction.functionAttackAfterMainOnly:
      case BuffAction.functionDeadattack:
      case BuffAction.functionConfirmCommand:
      case BuffAction.functionComboStart:
      case BuffAction.functionComboEnd:
      case BuffAction.pierceDefence:
      case BuffAction.pierceSubdamage:
      case BuffAction.pierceInvincible:
      case BuffAction.breakAvoidance:
      case BuffAction.commandAtk:
      case BuffAction.atk:
      case BuffAction.criticalDamage:
      case BuffAction.npdamage:
      case BuffAction.damageSpecial:
      case BuffAction.givenDamage:
      case BuffAction.damage:
      case BuffAction.damageIndividuality:
      case BuffAction.damageIndividualityActiveonly:
      case BuffAction.damageEventPoint:
      case BuffAction.commandNpAtk:
      case BuffAction.commandStarAtk:
      case BuffAction.grantInstantdeath:
      case BuffAction.multiattack:
        final activeOnly = buff.buff.script.IndvAddBuffPassive != 1;
        return self.getTraits(
          addTraits: [
            ...cardData?.traits ?? [],
            ...self.getBuffTraits(activeOnly: activeOnly),
          ],
        );
      case BuffAction.donotActCommandtype:
      case BuffAction.donotNobleCondMismatch:
        return self.getTraits(addTraits: cardData?.traits);
      case BuffAction.dropNp:
      case BuffAction.criticalPoint:
        return isAttack ? self.getTraits(addTraits: cardData?.traits) : self.getTraits();
      case BuffAction.grantState:
      case BuffAction.grantSubstate:
      case BuffAction.avoidFunctionExecuteSelf:
      case BuffAction.overwriteBuffUseRate:
      case BuffAction.changeBuffUseRate:
        return self.getTraits(addTraits: addTraits);
      case BuffAction.functionDamage:
      case BuffAction.functionReflection:
      case BuffAction.functionDead:
      case BuffAction.functionEntry:
      case BuffAction.functionWavestart:
      case BuffAction.functionSelfturnstart:
      case BuffAction.functionSelfturnend:
      case BuffAction.donotAct:
      case BuffAction.donotNoble:
      case BuffAction.donotSkill:
      case BuffAction.donotRecovery:
      case BuffAction.donotReplace:
      case BuffAction.giveGainHp:
      case BuffAction.gainHp:
      case BuffAction.masterSkillValueUp:
      case BuffAction.turnvalNp:
      case BuffAction.turnendHpRegain:
      case BuffAction.turnendStar:
      case BuffAction.turnendNp:
      case BuffAction.gutsHp:
      case BuffAction.functionFieldIndividualityChanged:
      case BuffAction.shortenSkillAfterUseSkill:
      case BuffAction.functionSkillBefore:
      case BuffAction.functionSkillAfter:
      case BuffAction.functionTreasureDeviceBefore:
      case BuffAction.functionTreasureDeviceAfter:
      case BuffAction.functionSkillTargetedBefore:
      case BuffAction.functionedFunction:
        return self.getTraits();
      default:
        return self.getTraits(addTraits: self.getBuffTraits(activeOnly: false));
    }
  }

  static List<NiceTrait>? fetchOpponentTraits(
    final BuffAction buffAction,
    final BuffData buff,
    final BattleServantData? opponent, {
    final BattleServantData? self,
    final CommandCardData? cardData,
    final bool isAttack = true,
    final DataVals? dataVals,
    final List<NiceTrait>? addTraits,
  }) {
    List<NiceTrait>? results;
    switch (buffAction) {
      case BuffAction.functionCommandcodeattackBefore:
      case BuffAction.functionCommandcodeattackBeforeMainOnly:
      case BuffAction.functionCommandattackBefore:
      case BuffAction.functionCommandattackBeforeMainOnly:
      case BuffAction.functionAttackBefore:
      case BuffAction.functionAttackBeforeMainOnly:
      case BuffAction.functionCommandcodeattackAfter:
      case BuffAction.functionCommandcodeattackAfterMainOnly:
      case BuffAction.functionCommandattackAfter:
      case BuffAction.functionCommandattackAfterMainOnly:
      case BuffAction.functionAttackAfter:
      case BuffAction.functionAttackAfterMainOnly:
      case BuffAction.functionDeadattack:
      case BuffAction.functionComboStart:
      case BuffAction.functionComboEnd:
      case BuffAction.commandAtk:
      case BuffAction.atk:
      case BuffAction.criticalDamage:
      case BuffAction.npdamage:
      case BuffAction.damageSpecial:
      case BuffAction.givenDamage:
      case BuffAction.damage:
      case BuffAction.commandNpAtk:
      case BuffAction.commandStarAtk:
      case BuffAction.pierceDefence:
      case BuffAction.pierceSubdamage:
      case BuffAction.pierceInvincible:
      case BuffAction.breakAvoidance:
      case BuffAction.avoidInstantdeath:
      case BuffAction.giveGainHp:
      case BuffAction.resistInstantdeath:
      case BuffAction.nonresistInstantdeath:
      case BuffAction.resistanceDelayNpturn:
      case BuffAction.grantInstantdeath:
      case BuffAction.grantState:
      case BuffAction.grantSubstate:
      case BuffAction.multiattack:
      case BuffAction.functionGuts:
        final activeOnly = buff.buff.script.IndvAddBuffPassive != 1;
        results = opponent?.getTraits(addTraits: opponent.getBuffTraits(activeOnly: activeOnly));
      case BuffAction.damageIndividuality:
        results = opponent?.getBuffTraits(activeOnly: false);
      case BuffAction.damageIndividualityActiveonly:
        results = opponent?.getBuffTraits(
          activeOnly: true,
          ignoreIndivUnreleaseable: buff.vals.IgnoreIndivUnreleaseable == 1,
        );
      case BuffAction.damageEventPoint:
        results = opponent?.getBuffTraits(activeOnly: true);
      case BuffAction.avoidState:
      case BuffAction.resistanceState:
      case BuffAction.toleranceSubstate:
      case BuffAction.guts:
        results = opponent?.getTraits(addTraits: addTraits) ?? addTraits;
      case BuffAction.functionDamage:
      case BuffAction.avoidanceIndividuality:
      case BuffAction.specialInvincible:
      case BuffAction.invincible:
      case BuffAction.avoidance:
      case BuffAction.avoidanceAttackDeathDamage:
      case BuffAction.commandDef:
      case BuffAction.defencePierce:
      case BuffAction.defence:
      case BuffAction.damageDef:
      case BuffAction.criticalDamageDef:
      case BuffAction.npdamageDef:
      case BuffAction.specialdefence:
      case BuffAction.receiveDamagePierce:
      case BuffAction.receiveDamage:
      case BuffAction.specialReceiveDamage:
      case BuffAction.commandNpDef:
      case BuffAction.commandStarDef:
      case BuffAction.criticalStarDamageTaken:
      case BuffAction.overwriteDamageDef:
        final activeOnly = buff.buff.script.IndvAddBuffPassive != 1;
        results =
            opponent?.getTraits(
              addTraits: [
                ...cardData?.traits ?? [],
                ...opponent.getBuffTraits(activeOnly: activeOnly),
              ],
            ) ??
            cardData?.traits;
      case BuffAction.dropNp:
      case BuffAction.criticalPoint:
        results = isAttack ? opponent?.getTraits(addTraits: cardData?.traits) : opponent?.getTraits();
      case BuffAction.functionReflection:
      case BuffAction.functionDead:
      case BuffAction.functionEntry:
      case BuffAction.functionWavestart:
      case BuffAction.functionSelfturnstart:
      case BuffAction.functionSelfturnend:
      case BuffAction.avoidFunctionExecuteSelf:
      case BuffAction.donotAct:
      case BuffAction.donotActCommandtype:
      case BuffAction.donotNoble:
      case BuffAction.donotNobleCondMismatch:
      case BuffAction.donotSkill:
      case BuffAction.donotReplace:
      case BuffAction.donotRecovery:
      case BuffAction.gainHp:
      case BuffAction.masterSkillValueUp:
      case BuffAction.chagetd:
      case BuffAction.turnvalNp:
      case BuffAction.turnendHpRegain:
      case BuffAction.turnendStar:
      case BuffAction.turnendNp:
      case BuffAction.gutsHp:
      case BuffAction.functionFieldIndividualityChanged:
      case BuffAction.functionConfirmCommand:
      case BuffAction.shortenSkillAfterUseSkill:
      case BuffAction.functionSkillBefore:
      case BuffAction.functionSkillAfter:
      case BuffAction.functionTreasureDeviceBefore:
      case BuffAction.functionTreasureDeviceAfter:
      case BuffAction.functionSkillTargetedBefore:
      case BuffAction.functionedFunction:
        results = [];
      default:
        results = opponent?.getTraits(addTraits: opponent.getBuffTraits(activeOnly: false)) ?? [];
    }

    if (self != null && self.lastHitBy != null && opponent != null && self.lastHitBy!.uniqueId == opponent.uniqueId) {
      results = [...?results, NiceTrait(id: ConstData.constants.lastAttackToSelfIndividuality)];
    }
    return results;
  }

  List<NiceTrait> getTraits({final List<NiceTrait>? addTraits}) {
    final List<NiceTrait> allTraits = [];
    allTraits.addAll(getBasicSvtTraits());

    if (addTraits != null) {
      allTraits.addAll(addTraits);
    }

    final List<int> removeTraitIds = [];
    for (final buff in battleBuff.validBuffs) {
      // indiv buffs do not require checks
      if (buff.buff.type == BuffType.addIndividuality) {
        allTraits.add(NiceTrait(id: buff.param));
      } else if (buff.buff.type == BuffType.subIndividuality) {
        removeTraitIds.add(buff.param);
      }
    }

    if (logicalClassId != baseClassId) {
      final isServant = allTraits.map((trait) => trait.id).contains(Trait.servant.value);
      final baseClassInfo = ConstData.classInfo[baseClassId];
      if (baseClassInfo != null) {
        final removeClassTraitIds = [
          baseClassInfo.individuality,
          if (isServant) ...baseClassInfo.relationSvtIndividuality,
        ];
        allTraits.removeWhere((trait) => removeClassTraitIds.contains(trait.id));
      }

      final logicalClassInfo = ConstData.classInfo[logicalClassId];
      if (logicalClassInfo != null) {
        final addClassTraitIds = [
          logicalClassInfo.individuality,
          if (isServant) ...logicalClassInfo.relationSvtIndividuality,
        ];
        allTraits.addAll(addClassTraitIds.map((id) => NiceTrait(id: id)));
      }
    }

    allTraits.removeWhere((trait) => removeTraitIds.contains(trait.id));

    return allTraits;
  }

  int countTrait(final List<NiceTrait> traits) {
    return countAnyTraits(getTraits(), traits);
  }

  List<NiceTrait> getBuffTraits({
    final bool activeOnly = false,
    final bool ignoreIndivUnreleaseable = false,
    final bool includeIgnoreIndiv = false,
  }) {
    final List<BuffData> buffs = getBuffsWithTraits(
      [], // get all
      activeOnly: activeOnly,
      ignoreIndivUnreleaseable: ignoreIndivUnreleaseable,
      includeIgnoreIndiv: includeIgnoreIndiv,
    );
    return [for (final buff in buffs) ...buff.getTraits()];
  }

  int countBuffWithTrait(
    final List<NiceTrait> traits, {
    final bool activeOnly = false,
    final bool ignoreIndivUnreleaseable = false,
    final bool includeIgnoreIndiv = false,
  }) {
    return getBuffsWithTraits(
      traits,
      activeOnly: activeOnly,
      ignoreIndivUnreleaseable: ignoreIndivUnreleaseable,
      includeIgnoreIndiv: includeIgnoreIndiv,
    ).length;
  }

  List<BuffData> getBuffsWithTraits(
    final List<NiceTrait> traits, {
    final bool activeOnly = false,
    final bool ignoreIndivUnreleaseable = false,
    final bool includeIgnoreIndiv = false,
  }) {
    final buffList = activeOnly ? battleBuff.getActiveList() : battleBuff.validBuffs;
    return buffList.where((buff) {
      if (buff.vals.IgnoreIndividuality == 1 && !includeIgnoreIndiv) return false;
      if (ignoreIndivUnreleaseable && buff.irremovable) return false;
      return checkSignedIndividualities2(
        myTraits: buff.getTraits(),
        requiredTraits: traits,
        positiveMatchFunc: partialMatch,
        negativeMatchFunc: partialMatch,
      );
    }).toList();
  }

  void changeNPLineCount(final int change) {
    if (!isEnemy) {
      return;
    }

    npLineCount += change;
    npLineCount = npLineCount.clamp(0, niceEnemy!.chargeTurn);
  }

  void changeNP(final int change, {Ref<bool>? maxLimited}) {
    if (!isPlayer || playerSvtData?.td == null) {
      return;
    }

    np += change;

    final maxNp = getNPCap(playerSvtData!.tdLv);
    maxLimited?.value = np > maxNp;
    np = np.clamp(0, maxNp);
    if (change > 0 && np >= npPityThreshold) {
      np = max(np, ConstData.constants.fullTdPoint);
    }
  }

  static int getNPCap(final int npLevel) {
    final capRate = npLevel == 1
        ? 1
        : npLevel < 5
        ? 2
        : 3;
    return ConstData.constants.fullTdPoint * capRate;
  }

  bool isKilledBy(final BattleServantData? activator, final CommandCardData? currentCard) {
    return activator != null && currentCard != null && lastHitBy == activator && lastHitByCard == currentCard;
  }

  void heal(final int heal) {
    if (hasBuffNoProbabilityCheck(BuffAction.donotRecovery)) {
      return;
    }

    gainHp(heal);
  }

  void setHp(final int newHp) {
    hp = maxHp < newHp ? maxHp : newHp;
  }

  void gainHp(final int gain) {
    final newHp = hp + gain;
    hp = maxHp < newHp ? maxHp : newHp;
  }

  void lossHp(final int loss, {final bool lethal = false}) {
    hp -= loss;
    if (hp <= 0 && !lethal) {
      hp = 1;
    }
  }

  void receiveDamage(final int hitDamage) {
    hp -= hitDamage;
  }

  // since Laplace allows minus HP, need to change it to lower limit for accumulation damage calculation
  int _getHpForAccumulationDamage(final int hp) {
    final minHp = shiftDeckIndex < shiftNpcIds.length - 1 ? 1 : 0;
    return max(hp, minHp);
  }

  void resetAccumulationDamage() {
    _accumulationDamage = 0;
  }

  // solely used for DamageReflection calculations
  void procAccumulationDamage(final int previousHp) {
    _accumulationDamage += _getHpForAccumulationDamage(previousHp) - _getHpForAccumulationDamage(hp);
    _accumulationDamage = _accumulationDamage.clamp(0, maxHp);
  }

  void resetLastHits() {
    lastHitBy = null;
    lastHitByCard = null;
    lastHitByFunc = null;
  }

  void addReducedHp(final int damage) {
    reducedHp += damage;
  }

  void clearReducedHp() {
    reducedHp = 0;
  }

  bool hasNextShift(final BattleData battleData) {
    return getEnemyShift(battleData, shiftDeckIndex + 1) != null;
  }

  QuestEnemy? getEnemyShift(final BattleData battleData, final int shiftTo) {
    if (isEnemy) {
      if (shiftTo == -1) {
        return baseEnemy;
      } else if (shiftNpcIds.isNotEmpty && shiftNpcIds.length > shiftTo && shiftTo >= 0) {
        return battleData.enemyDecks[DeckType.shift]?.firstWhereOrNull(
          (questEnemy) => questEnemy.npcId == shiftNpcIds[shiftTo],
        );
      }
    }
    return null;
  }

  Future<void> shift(final BattleData battleData) async {
    shiftDeckIndex += 1;
    final nextShift = getEnemyShift(battleData, shiftDeckIndex);
    if (nextShift == null) {
      return;
    }

    niceEnemy = nextShift;
    await loadAi(battleData);

    baseAtk = nextShift.atk;
    _maxHp = nextShift.hp;
    hp = maxHp;
    level = nextShift.lv;
    battleBuff.clearPassive(uniqueId);
  }

  Future<void> skillShift(final BattleData battleData, QuestEnemy shiftSvt) async {
    shiftDeckIndex += 1;
    niceEnemy = shiftSvt;
    await loadAi(battleData);

    baseAtk = shiftSvt.atk;
    _maxHp = shiftSvt.hp;
    hp = maxHp;
    level = shiftSvt.lv;
    battleBuff.clearPassive(uniqueId);
  }

  Future<void> changeServant(final BattleData battleData, QuestEnemy changeSvt) async {
    changeIndex = changeIndex;
    niceEnemy = changeSvt;
    baseAtk = changeSvt.atk;
    _maxHp = changeSvt.hp;
    // hp = maxHp;
    level = changeSvt.lv;
    battleBuff.clearPassive(uniqueId);
    await loadAi(battleData);
    await battleData.initActorSkills([this]);
  }

  Future<void> transformAlly(final BattleData battleData, final Servant targetSvt, final DataVals dataVals) async {
    final targetSvtId = dataVals.Value!;
    niceSvt = targetSvt;
    final limitCount = dataVals.SetLimitCount;
    if (limitCount != null) {
      playerSvtData!.limitCount = limitCount;
    }

    // build new skills
    final List<BattleSkillInfoData> newSkillInfos = [];
    for (final skillNum in kActiveSkillNums) {
      final newSkills = (targetSvt.groupedActiveSkills[skillNum] ?? []).toList();
      final hideActives = ConstData.getSvtLimitHides(
        targetSvtId,
        limitCount,
      ).expand((e) => e.activeSkills[skillNum] ?? []).toList();
      newSkills.removeWhere((niceSkill) => hideActives.contains(niceSkill.id));

      final oldInfoData = skillInfoList.firstWhereOrNull((infoData) => infoData.skillNum == skillNum);
      BaseSkill? baseSkill = newSkills.firstWhereOrNull((skill) => skill.id == oldInfoData?.skill?.id);
      baseSkill ??= newSkills.lastWhereOrNull(
        (skill) => skill.strengthStatus == oldInfoData?.skill?.svt.strengthStatus,
      );
      baseSkill ??= newSkills.fold(
        null,
        (prev, next) => prev == null || prev.svt.priority <= prev.svt.priority ? next : prev,
      );

      final newInfoData = BattleSkillInfoData(
        baseSkill,
        provisionedSkills: newSkills,
        skillNum: skillNum,
        type: SkillInfoType.svtSelf,
        skillLv: playerSvtData!.skillLvs.length >= skillNum ? playerSvtData!.skillLvs[skillNum - 1] : 1,
      );
      if (oldInfoData != null) {
        newInfoData.chargeTurn = oldInfoData.chargeTurn;
      }
      newSkillInfos.add(newInfoData);
    }

    skillInfoList = newSkillInfos;

    // build new Td
    final curTd = playerSvtData!.td;
    final newTds = (targetSvt.groupedNoblePhantasms[curTd?.svt.num ?? 1] ?? []).toList();
    final hideTds = ConstData.getSvtLimitHides(targetSvtId, limitCount).expand((e) => e.tds).toList();
    newTds.removeWhere((niceTd) => hideTds.contains(niceTd.id));
    NiceTd? newTd = newTds.firstWhereOrNull((td) => td.id == curTd?.id);
    newTd ??= newTds.lastWhereOrNull((td) => td.strengthStatus == curTd?.strengthStatus);
    newTd ??= newTds.fold(null, (prev, next) => prev == null || prev.priority <= next.priority ? next : prev);

    playerSvtData!.td = newTd;

    if (svtId == 600700) {
      return;
    }

    baseAtk = (targetSvt.atkGrowth.getOrNull(playerSvtData!.lv - 1) ?? 0) + playerSvtData!.atkFou;
    _maxHp =
        (targetSvt.hpGrowth.getOrNull(playerSvtData!.lv - 1) ?? 0) +
        playerSvtData!.hpFou +
        (equip1?.hp ?? 0) +
        (equip2?.hp ?? 0) +
        (equip3?.hp ?? 0);
    hp = hp > maxHp ? maxHp : hp;

    for (final actor in battleData.nonnullAllActors) {
      actor.battleBuff.clearClassPassive(uniqueId);
    }
    final List<NiceSkill> passives = [...targetSvt.classPassive];

    for (final skill in passives) {
      final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtClassPassive);
      await skillInfo.activate(battleData, activator: this);
    }
  }

  Future<void> transformEnemy(final BattleData battleData, final QuestEnemy targetEnemy) async {
    niceEnemy = targetEnemy;
    skillInfoList = [
      BattleSkillInfoData(
        targetEnemy.skills.skill1,
        skillNum: 1,
        skillLv: targetEnemy.skills.skillLv1,
        type: SkillInfoType.svtSelf,
      ),
      BattleSkillInfoData(
        targetEnemy.skills.skill2,
        skillNum: 2,
        skillLv: targetEnemy.skills.skillLv2,
        type: SkillInfoType.svtSelf,
      ),
      BattleSkillInfoData(
        targetEnemy.skills.skill3,
        skillNum: 3,
        skillLv: targetEnemy.skills.skillLv3,
        type: SkillInfoType.svtSelf,
      ),
    ];

    if (svtId == 600700) {
      return;
    }
    baseAtk = targetEnemy.atk;
    _maxHp = targetEnemy.hp;
    hp = hp > maxHp ? maxHp : hp;

    for (final actor in battleData.nonnullAllActors) {
      actor.battleBuff.clearClassPassive(uniqueId);
    }
    final List<NiceSkill> passives = targetEnemy.classPassive.classPassive;

    for (final skill in passives) {
      final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtClassPassive);
      await skillInfo.activate(battleData, activator: this);
    }
  }

  bool isAlive(final BattleData battleData, {final NiceFunction? function}) {
    if (hp > 0) {
      return true;
    }

    if (hasNextShift(battleData)) {
      return true;
    }

    // no code on this
    return hasBuffNoProbabilityCheck(BuffAction.guts, addTraits: function?.getFuncIndividuality());
  }

  bool isNPSealed() {
    return hasBuffNoProbabilityCheck(BuffAction.donotNoble) ||
        hasBuffNoProbabilityCheck(BuffAction.donotNobleCondMismatch, card: getNPCard());
  }

  bool isSkillSealed(final int skillIndex) {
    if (skillInfoList.length <= skillIndex || skillIndex < 0) {
      return false;
    }

    return hasBuffNoProbabilityCheck(BuffAction.donotSkill);
  }

  bool isDonotSkillSelect(int idx) {
    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, BuffAction.donotSkillSelect)) {
      if (buff.shouldActivateBuffNoProbabilityCheck(getTraits()) && buff.vals.Value == idx) {
        return true;
      }
    }
    return false;
  }

  bool isSkillCondFailed(final BattleData battleData, final int skillIndex) {
    if (skillInfoList.length <= skillIndex || skillIndex < 0) {
      return false;
    }

    final skillInfo = skillInfoList[skillIndex];
    return !canAttack() ||
        skillInfo.skill == null ||
        !BattleSkillInfoData.checkSkillScript(battleData, this, skillInfo.skillScript, skillInfo.skillLv);
  }

  bool canUseSkillIgnoreCoolDown(final BattleData battleData, final int skillIndex) {
    if (skillInfoList.length <= skillIndex || skillIndex < 0) {
      return false;
    }

    return !isSkillSealed(skillIndex) && !isSkillCondFailed(battleData, skillIndex);
  }

  bool canOrderChange() {
    return !hasBuffNoProbabilityCheck(BuffAction.donotReplace);
  }

  bool canAttack() {
    return hp > 0 && !hasBuffNoProbabilityCheck(BuffAction.donotAct);
  }

  bool canCommandCard(final CommandCardData card) {
    if (!canAttack()) return false;

    return !hasBuffNoProbabilityCheck(BuffAction.donotActCommandtype, card: card);
  }

  bool canSelectNP(final BattleData battleData) {
    if (!canNP()) return false;

    final currentNp = getCurrentNP();
    return currentNp != null && currentNp.functions.isNotEmpty && checkNPScript(battleData);
  }

  bool canNP() {
    final npCard = getNPCard();
    return npCard != null && isNpFull() && canAttack() && canCommandCard(npCard) && !isNPSealed();
  }

  bool checkNPScript(final BattleData battleData) {
    bool checkNpScript = true;
    if (isPlayer) {
      checkNpScript = BattleSkillInfoData.checkSkillScript(battleData, this, getCurrentNP()?.script, tdLv);
    }
    return checkNpScript;
  }

  bool isNpFull() {
    if (isPlayer && np < ConstData.constants.fullTdPoint) {
      return false;
    }
    if (isEnemy && (npLineCount < niceEnemy!.chargeTurn || niceEnemy!.chargeTurn == 0)) {
      return false;
    }
    return true;
  }

  Future<bool> activateSkill(final BattleData battleData, final int skillIndex) async {
    BattleSkillInfoData? skillInfo = skillInfoList.getOrNull(skillIndex);
    if (skillInfo == null || skillInfo.chargeTurn > 0) return false;

    // in case transform svt changed self or skill
    final _actor = copy(), _skill = skillInfo.copy();
    final param = BattleSkillParams();
    final activated = await skillInfo.activate(battleData, activator: this, param: param);
    if (activated) {
      battleData.recorder.skill(
        battleData: battleData,
        activator: _actor,
        skill: _skill,
        fromPlayer: true,
        uploadEligible: true,
        param: param,
      );

      skillInfo = skillInfoList.getOrNull(skillIndex);
      if (skillInfo != null) {
        int shortenSkillAfterUseSkill = 0;
        for (final buff in collectBuffsPerAction(battleBuff.validBuffs, BuffAction.shortenSkillAfterUseSkill)) {
          final curSkillUseCount = buff.shortenMaxCountEachSkill?.getOrNull(skillIndex);
          if (curSkillUseCount == null || curSkillUseCount > 0) {
            buff.shortenMaxCountEachSkill?[skillIndex] -= 1;
            shortenSkillAfterUseSkill += buff.param;
            buff.setUsed(this, battleData);
          }
        }
        skillInfo.shortenSkill(shortenSkillAfterUseSkill);
      }
    }
    return activated;
  }

  Future<void> activateCommandCode(final BattleData battleData, final int cardIndex) async {
    final skillInfos = commandCodeSkills.getOrNull(cardIndex);
    if (skillInfos == null) return;

    for (final skill in skillInfos) {
      if (skill.chargeTurn > 0) continue;
      battleData.battleLogger.action('$lBattleName - ${S.current.command_code}: ${skill.lName}');
      await skill.activate(battleData, activator: this);
    }
  }

  NiceTd? getBaseTD() {
    return isPlayer ? playerSvtData!.td : niceEnemy!.noblePhantasm.noblePhantasm;
  }

  NiceTd? getCurrentNP() {
    final buffs = collectBuffsPerAction(battleBuff.validBuffs, BuffAction.tdTypeChange);
    NiceTd? selected;
    for (final buff in buffs.reversed) {
      if (buff.tdTypeChange != null) {
        selected = buff.tdTypeChange!;
        break;
      }
    }

    if (selected != null) {
      return selected;
    }

    NiceTd? td = getBaseTD();
    final tdChangeByBattlePoint = td?.script?.tdChangeByBattlePoint?.firstOrNull;
    if (tdChangeByBattlePoint != null &&
        tdChangeByBattlePoint.phase <= determineBattlePointPhase(tdChangeByBattlePoint.battlePointId)) {
      return niceSvt?.noblePhantasms.firstWhereOrNull((niceTd) => niceTd.id == tdChangeByBattlePoint.noblePhantasmId) ??
          td;
    }

    return td;
  }

  Future<void> activateNP(final BattleData battleData, CommandCardData card, final int extraOverchargeLvl) async {
    battleData.battleLogger.action('$lBattleName ${S.current.battle_np_card}');

    final niceTD = getCurrentNP();
    if (niceTD != null) {
      final baseOverCharge = isPlayer ? np ~/ ConstData.constants.fullTdPoint : 1;
      int upOverCharge = await getBuffValue(battleData, BuffAction.chagetd);
      if (isPlayer) {
        upOverCharge += extraOverchargeLvl;
      }
      int? overchargeLvl;
      if (battleData.delegate?.decideOC != null) {
        overchargeLvl = battleData.delegate!.decideOC!(this, baseOverCharge, upOverCharge);
      }
      overchargeLvl ??= baseOverCharge + upOverCharge;
      overchargeLvl = overchargeLvl.clamp(1, 5);
      battleData.recorder.setOverCharge(this, card, overchargeLvl);

      await activateBuff(battleData, BuffAction.functionTreasureDeviceBefore, overchargeState: overchargeLvl - 1);

      np = 0;
      npLineCount = 0;
      usedNpThisTurn = true;
      final functions = await updateNpFunctions(battleData, niceTD);
      await FunctionExecutor.executeFunctions(
        battleData,
        functions,
        tdLv,
        script: niceTD.script,
        activator: this,
        targetedAlly: battleData.getTargetedAlly(this),
        targetedEnemy: battleData.getTargetedEnemy(this),
        card: card,
        overchargeLvl: overchargeLvl,
      );

      await activateBuff(battleData, BuffAction.functionTreasureDeviceAfter, overchargeState: overchargeLvl - 1);

      for (final svt in battleData.nonnullActors) {
        await svt.activateBuff(
          battleData,
          BuffAction.functionedFunction,
          receivedFunctionsList: svt.receivedFunctionsList,
        );
      }
    }
  }

  Future<List<NiceFunction>> updateNpFunctions(final BattleData battleData, final NiceTd niceTd) async {
    final List<NiceFunction> updatedFunctions = niceTd.functions.toList();

    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, BuffAction.functionNpattack)) {
      if (buff.param < 0 || buff.param >= updatedFunctions.length) {
        // replace index not valid for current function list
        continue;
      }

      final skillId = buff.vals.SkillID;
      final skillLv = buff.vals.SkillLV;
      if (skillId != null &&
          skillLv != null &&
          await buff.shouldActivateBuff(battleData, getTraits(addTraits: niceTd.individuality))) {
        BaseSkill? skill = db.gameData.baseSkills[skillId];
        skill ??= await showEasyLoading(() => AtlasApi.skill(skillId), mask: true);
        final replacementFunction = skill?.functions.firstOrNull;
        final selectedDataVal = replacementFunction?.svals.getOrNull(skillLv - 1);
        if (skill == null || replacementFunction == null || selectedDataVal == null) {
          battleData.battleLogger.debug(
            'Buff ID [${buff.buff.id}]: ${S.current.skill} [$skillId] ${S.current.battle_invalid}',
          );
          continue;
        }

        final List<DataVals> updatedSvalsList = List.generate(5, (_) => selectedDataVal);
        final updatedReplacementFunction = NiceFunction.fromJson(replacementFunction.toJson());
        updatedReplacementFunction.svals = updatedSvalsList;
        updatedReplacementFunction.svals2 = updatedSvalsList;
        updatedReplacementFunction.svals3 = updatedSvalsList;
        updatedReplacementFunction.svals4 = updatedSvalsList;
        updatedReplacementFunction.svals5 = updatedSvalsList;

        updatedFunctions[buff.param] = updatedReplacementFunction;
        buff.setUsed(this, battleData);
      }
    }

    return updatedFunctions;
  }

  // difference is this is not async
  // not checking anything for maxHpBuffs for now
  int getMaxHpBuffValue({final bool percent = false}) {
    final BuffAction buffAction = percent ? BuffAction.maxhpRate : BuffAction.maxhpValue;
    final actionDetails = ConstData.buffActions[buffAction];
    if (actionDetails == null) {
      return 0;
    }

    int totalVal = 0;
    int? maxRate;

    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, buffAction)) {
      if (buff.shouldActivateBuffNoProbabilityCheck(getTraits())) {
        buff.setUsed(this);
        final value = buff.getValue(this);
        if (actionDetails.plusTypes.contains(buff.buff.type)) {
          totalVal += value;
        } else {
          totalVal -= value;
        }
        maxRate = maxRate == null ? buff.buff.maxRate : max(maxRate, buff.buff.maxRate);
      }
    }
    return capBuffValue(actionDetails, totalVal, maxRate);
  }

  // difference is this immediately returns the first buff value instead of summing over all buffs
  Future<int?> getMultiAttackBuffValue(
    final BattleData battleData,
    final CommandCardData card,
    final BattleServantData opponent,
  ) async {
    final actionDetails = ConstData.buffActions[BuffAction.multiattack];
    if (actionDetails == null) {
      return null;
    }

    for (final buff in collectBuffsPerAction(battleBuff.validBuffsActiveFirst, BuffAction.multiattack)) {
      if (await buff.shouldActivateBuff(
        battleData,
        getTraits(addTraits: card.traits),
        opponentTraits: opponent.getTraits(),
      )) {
        buff.setUsed(this, battleData);
        final value = buff.getValue(this, opponent, battleData);
        if (actionDetails.plusTypes.contains(buff.buff.type)) {
          return value;
        } else {
          return -value;
        }
      }
    }
    return null;
  }

  Future<int> getBuffValue(
    BattleData battleData,
    BuffAction buffAction, {
    BattleServantData? opponent,
    List<NiceTrait>? opponentTraitsOverride,
    CommandCardData? card,
    bool isAttack = true,
    List<NiceTrait>? addTraits,
    bool skipDamage = false, // special logic for defender in damage calculation
  }) async {
    final actionDetails = ConstData.buffActions[buffAction];
    // not actionable if no actionDetails present
    if (actionDetails == null) return 0;

    int totalVal = 0;
    int? maxRate;

    final List<BuffData> allBuffs = collectBuffsPerAction(battleBuff.validBuffs, buffAction);
    for (final buff in allBuffs) {
      final List<NiceTrait> selfTraits = fetchSelfTraits(
        buffAction,
        buff,
        this,
        cardData: card,
        isAttack: isAttack,
        addTraits: addTraits,
      );
      final List<NiceTrait>? opponentTraits =
          opponentTraitsOverride ??
          fetchOpponentTraits(
            buffAction,
            buff,
            opponent,
            self: this,
            cardData: card,
            isAttack: !isAttack,
            addTraits: addTraits,
          );
      if (await buff.shouldActivateBuff(battleData, selfTraits, opponentTraits: opponentTraits)) {
        // here is a special logic we found that says plusTypes for defender buffs are ignored when damage is skipped.
        // It behaves like how pierceDefence acts on defence related buffs, but we did not find actual code for it.
        // This fix is still necessary so that defenceDown buffs get used correctly
        // ref: https://discord.com/channels/839788731108032532/1078568994170228736/1274409425586753647
        if (skipDamage && actionDetails.plusTypes.contains(buff.buff.type)) {
          continue;
        }

        buff.setUsed(this, battleData);

        int value = buff.getValue(this, opponent, battleData);
        final plusAction = actionDetails.plusAction;
        if (value > 0 && plusAction != BuffAction.none) {
          final effectiveness = await getBuffValueFixedTraits(
            battleData,
            plusAction,
            selfTraits: buff.getTraits(),
            opponent: opponent,
          );
          value = (value * toModifier(effectiveness)).toInt();
        }

        final buffRate = await getBuffRateValue(battleData, buff.getTraits(), opponent: opponent);
        value = (value * (toModifier(buffRate))).toInt();

        if (actionDetails.plusTypes.contains(buff.buff.type)) {
          totalVal += value;
        } else {
          totalVal -= value;
        }
        maxRate = maxRate == null ? buff.buff.maxRate : max(maxRate, buff.buff.maxRate);
      }
    }
    return capBuffValue(actionDetails, totalVal, maxRate);
  }

  // for actions that doesn't follow standard procedure & plusActions
  Future<int> getBuffValueFixedTraits(
    final BattleData battleData,
    final BuffAction buffAction, {
    required final List<NiceTrait> selfTraits,
    final List<NiceTrait>? opponentTraits,
    final BattleServantData? opponent,
  }) async {
    final actionDetails = ConstData.buffActions[buffAction];
    // not actionable if no actionDetails present
    if (actionDetails == null) return 0;

    int totalVal = 0;
    int? maxRate;

    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, buffAction)) {
      if (await buff.shouldActivateBuff(battleData, selfTraits, opponentTraits: opponentTraits)) {
        buff.setUsed(this, battleData);

        int value = buff.getValue(this, opponent, battleData);
        final plusAction = actionDetails.plusAction;
        if (value > 0 && plusAction != BuffAction.none) {
          final effectiveness = await getBuffValueFixedTraits(
            battleData,
            plusAction,
            selfTraits: buff.getTraits(),
            opponent: opponent,
          );
          value = (value * toModifier(effectiveness)).toInt();
        }

        final buffRate = await getBuffRateValue(battleData, buff.getTraits(), opponent: opponent);
        value = (value * (toModifier(buffRate))).toInt();

        if (actionDetails.plusTypes.contains(buff.buff.type)) {
          totalVal += value;
        } else {
          totalVal -= value;
        }
        maxRate = maxRate == null ? buff.buff.maxRate : max(maxRate, buff.buff.maxRate);
      }
    }
    return capBuffValue(actionDetails, totalVal, maxRate);
  }

  // separate method for buffRate to avoid stackOverflow
  Future<int> getBuffRateValue(
    final BattleData battleData,
    final List<NiceTrait> buffTraits, {
    final BattleServantData? opponent,
  }) async {
    final actionDetails = ConstData.buffActions[BuffAction.buffRate];
    // not actionable if no actionDetails present
    if (actionDetails == null) {
      return 0;
    }

    int totalVal = 0;
    int? maxRate;

    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, BuffAction.buffRate)) {
      if (await buff.shouldActivateBuff(battleData, buffTraits)) {
        buff.setUsed(this, battleData);

        int value = buff.getValue(this, opponent, battleData);

        if (actionDetails.plusTypes.contains(buff.buff.type)) {
          totalVal += value;
        } else {
          totalVal -= value;
        }
        maxRate = maxRate == null ? buff.buff.maxRate : max(maxRate, buff.buff.maxRate);
      }
    }
    return capBuffValue(actionDetails, totalVal, maxRate);
  }

  // this is too complicated since it also touches preventDeathByDamage & turnendHpReduceToRegain & there are two
  // types of plus actions (kinda) funcHpReduce & funcHpReduceValue
  Future<int> getBuffValueForTurnEndHpReduce(final BattleData battleData, {final bool isValueForHeal = false}) async {
    final actionDetails = ConstData.buffActions[BuffAction.turnendHpReduce];
    if (actionDetails == null) {
      return 0;
    }

    int nonPreventableValue = 0;
    int preventableValue = 0;
    int? maxRate;
    final List<BuffData> preventDeaths = collectBuffsPerAction(battleBuff.validBuffs, BuffAction.preventDeathByDamage);
    final List<BuffData> activatedPreventDeaths = [];

    final List<BuffData> turnEndHpReduceToRegainBuffs = collectBuffsPerAction(
      battleBuff.validBuffs,
      BuffAction.turnendHpReduceToRegain,
    );

    for (final turnEndHpReduce in collectBuffsPerAction(battleBuff.validBuffs, BuffAction.turnendHpReduce)) {
      // making assumption that turnendHpReduce should always apply, not checking indivs

      // check turnendHpReduceToRegain
      final shouldConvertToHeal = turnEndHpReduceToRegainBuffs.any((turnEndHpReduceToRegain) {
        final shouldActivate = turnEndHpReduceToRegain.shouldActivateBuffNoProbabilityCheck(
          turnEndHpReduce.getTraits(),
        );
        if (shouldActivate) {
          turnEndHpReduceToRegain.setUsed(this, battleData);
        }
        return shouldActivate;
      });

      if (isValueForHeal != shouldConvertToHeal) {
        continue;
      }

      turnEndHpReduce.setUsed(this, battleData);
      final funcHpReduce = await getBuffValueFixedTraits(
        battleData,
        BuffAction.funcHpReduce,
        selfTraits: turnEndHpReduce.getTraits(),
      );
      final funcHpReduceValue = await getBuffValueFixedTraits(
        battleData,
        BuffAction.funcHpReduceValue,
        selfTraits: turnEndHpReduce.getTraits(),
      );

      int value = (toModifier(funcHpReduce) * turnEndHpReduce.getValue(this)).toInt();
      value = max(value + funcHpReduceValue, 0);

      final buffRate = await getBuffRateValue(battleData, turnEndHpReduce.getTraits());
      value = (value * (toModifier(buffRate))).toInt();

      final shouldPreventDeath = preventDeaths.any((preventDeath) {
        final shouldActivate = preventDeath.shouldActivateBuffNoProbabilityCheck(
          [],
          opponentTraits: turnEndHpReduce.getTraits(),
        );
        if (shouldActivate) {
          activatedPreventDeaths.add(preventDeath);
        }
        return shouldActivate;
      });

      // turnendHpReduce has no minus type
      if (shouldPreventDeath) {
        preventableValue += value;
      } else {
        nonPreventableValue += value;
      }

      maxRate = maxRate == null ? turnEndHpReduce.buff.maxRate : max(maxRate, turnEndHpReduce.buff.maxRate);
    }

    int finalValue = preventableValue + nonPreventableValue;
    if (!isValueForHeal && hp <= finalValue && hp > nonPreventableValue && preventableValue > 0) {
      finalValue = hp - 1;
      for (final buff in activatedPreventDeaths) {
        buff.setUsed(this, battleData);
      }
    }

    return capBuffValue(actionDetails, finalValue, maxRate);
  }

  // For doNot type buffActions. Since during rendering can't wait for user input,
  // so assuming these buffs do not check for probability.
  // E.g. a stun buff having 60% chance doesn't make sense
  bool hasBuffNoProbabilityCheck(
    final BuffAction buffAction, {
    final BattleServantData? opponent,
    final CommandCardData? card,
    final List<NiceTrait>? addTraits,
  }) {
    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, buffAction)) {
      final List<NiceTrait> selfTraits = fetchSelfTraits(buffAction, buff, this, cardData: card, addTraits: addTraits);
      final List<NiceTrait>? opponentTraits = fetchOpponentTraits(
        buffAction,
        buff,
        opponent,
        self: this,
        cardData: card,
        addTraits: addTraits,
      );
      if (buff.shouldActivateBuffNoProbabilityCheck(selfTraits, opponentTraits: opponentTraits)) {
        buff.setUsed(this);
        return true;
      }
    }
    return false;
  }

  Future<bool> hasBuff(
    final BattleData battleData,
    final BuffAction buffAction, {
    final BattleServantData? opponent,
    final CommandCardData? card,
    final List<NiceTrait>? addTraits,
  }) async {
    return await getBuff(battleData, buffAction, opponent: opponent, card: card, addTraits: addTraits, useBuff: true) !=
        null;
  }

  Future<BuffData?> getBuff(
    final BattleData battleData,
    final BuffAction buffAction, {
    final BattleServantData? opponent,
    final CommandCardData? card,
    final List<NiceTrait>? addTraits,
    final bool useBuff = true,
  }) async {
    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, buffAction)) {
      final List<NiceTrait> selfTraits = fetchSelfTraits(buffAction, buff, this, cardData: card, addTraits: addTraits);
      final List<NiceTrait>? opponentTraits = fetchOpponentTraits(
        buffAction,
        buff,
        opponent,
        self: this,
        cardData: card,
        addTraits: addTraits,
      );

      if (await buff.shouldActivateBuff(battleData, selfTraits, opponentTraits: opponentTraits)) {
        if (useBuff) {
          buff.setUsed(this, battleData);
        }
        return buff;
      }
    }
    return null;
  }

  // Upon reading code, buff actions might always be active first
  // Future<bool> activateBuffOnActionActiveFirst(final BattleData battleData, final BuffAction buffAction) async {
  //   return await activateBuffsV2(battleData, collectBuffsPerAction(battleBuff.validBuffsActiveFirst, buffAction));
  // }

  Future<bool> activateBuff(
    final BattleData battleData,
    final BuffAction buffAction, {
    final BattleServantData? opponent,
    final CommandCardData? card,
    final int? overchargeState,
    final BattleSkillInfoData? skillInfo,
    final List<NiceFunction>? receivedFunctionsList,
  }) async {
    return await activateBuffs(
      battleData,
      [buffAction],
      opponent: opponent,
      card: card,
      overchargeState: overchargeState,
      skillInfo: skillInfo,
      receivedFunctionsList: receivedFunctionsList,
    );
  }

  Future<int> applyChangeBuffUseRate(
    BattleData battleData,
    BuffData buffToApply,
    List<NiceTrait>? opponentTraits,
  ) async {
    final overwriteBuffRates = collectBuffsPerAction(battleBuff.validBuffs, BuffAction.overwriteBuffUseRate);
    int baseRate = buffToApply.buffRate;
    for (final overwriteBuffRate in overwriteBuffRates) {
      final shouldApply = await buffToApply.shouldActivateBuff(
        battleData,
        fetchSelfTraits(BuffAction.overwriteBuffUseRate, overwriteBuffRate, this, addTraits: buffToApply.getTraits()),
        opponentTraits: opponentTraits,
      );
      if (shouldApply) {
        overwriteBuffRate.setUsed(this);
        baseRate = overwriteBuffRate.getValue(this);
        break;
      }
    }

    final changeBuffRate = await getBuffValue(
      battleData,
      BuffAction.changeBuffUseRate,
      opponentTraitsOverride: opponentTraits,
      addTraits: buffToApply.getTraits(),
    );
    return baseRate + changeBuffRate;
  }

  Future<bool> activateBuffs(
    final BattleData battleData,
    final Iterable<BuffAction> buffActions, {
    final BattleServantData? opponent,
    final CommandCardData? card,
    final int? overchargeState,
    final BattleSkillInfoData? skillInfo,
    final List<NiceFunction>? receivedFunctionsList,
  }) async {
    bool activated = false;
    for (final buffAction in buffActions) {
      for (final buff in collectBuffsPerAction(battleBuff.validBuffsActiveFirst, buffAction)) {
        final List<NiceTrait> selfTraits = fetchSelfTraits(buffAction, buff, this, cardData: card);
        List<NiceTrait>? opponentTraits = fetchOpponentTraits(buffAction, buff, opponent, cardData: card);

        final shouldActivate = await buff.shouldActivateBuff(
          battleData,
          selfTraits,
          opponentTraits: opponentTraits,
          skillInfoType: skillInfo?.type,
          receivedFunctionsList: receivedFunctionsList,
          triggeredSkillIds: triggeredSkillIds,
        );

        if (!shouldActivate) continue;

        BaseSkill? skill;
        if (buff.buff.type == BuffType.classboardCommandSpellAfterFunction) {
          final spellId = buff.param;
          final targetCommandSpell = db.gameData.classBoards.values
              .expand((e) => e.squares)
              .map((e) => e.targetCommandSpell)
              .firstWhereOrNull((e) => e?.id == spellId);
          if (targetCommandSpell != null) {
            skill = targetCommandSpell.toSkill();
          }
          if (skill == null) {
            battleData.battleLogger.debug(
              'Buff ID [${buff.buff.id}]: ${S.current.command_spell}(classboard) [$spellId] ${S.current.not_found}',
            );
            continue;
          }
          battleData.battleLogger.function(
            '$lBattleName - ${buff.buff.lName.l} ${S.current.command_spell}(classboard) [$spellId]',
          );
        } else {
          final skillId = buff.param;
          skill = db.gameData.baseSkills[skillId];
          skill ??= await showEasyLoading(() => AtlasApi.skill(skillId), mask: true);
          if (skill == null) {
            battleData.battleLogger.debug(
              'Buff ID [${buff.buff.id}]: ${S.current.skill} [$skillId] ${S.current.not_found}',
            );
            continue;
          }
          battleData.battleLogger.function('$lBattleName - ${buff.buff.lName.l} ${S.current.skill} [$skillId]');
          triggeredSkillIds.add(skillId);
        }
        await FunctionExecutor.executeFunctions(
          battleData,
          skill.functions,
          buff.additionalParam.clamp(1, skill.maxLv),
          script: skill.script,
          activator: this,
          overchargeState: overchargeState,
          ignoreBattlePoints: skillInfo?.skillScript?.IgnoreBattlePointUp,
          targetedAlly: battleData.getTargetedAlly(this),
          targetedEnemy: opponent,
          skillType: skill.type,
          skillInfoType: null,
        );
        buff.setUsed(this, battleData);
        activated = true;
      }

      battleData.checkActorStatus();
    }
    return activated;
  }

  // could have removed this method if not for the fact that BuffType.delayFunction
  // does not have a corresponding BuffAction
  Future<bool> activateDelayFunction(final BattleData battleData, final Iterable<BuffData> buffs) async {
    bool activated = false;
    final List<NiceTrait> selfTraits = getTraits();
    for (final buff in buffs.toList()) {
      if (await buff.shouldActivateBuff(battleData, selfTraits)) {
        final skillId = buff.param;
        BaseSkill? skill = db.gameData.baseSkills[skillId];
        skill ??= await showEasyLoading(() => AtlasApi.skill(skillId), mask: true);
        if (skill == null) {
          battleData.battleLogger.debug(
            'Buff ID [${buff.buff.id}]: ${S.current.skill} [$skillId] ${S.current.not_found}',
          );
          continue;
        }
        battleData.battleLogger.function('$lBattleName - ${buff.buff.lName.l} ${S.current.skill} [$skillId]');
        await FunctionExecutor.executeFunctions(
          battleData,
          skill.functions,
          buff.additionalParam.clamp(1, skill.maxLv),
          script: skill.script,
          activator: this,
          targetedAlly: battleData.getTargetedAlly(this),
          targetedEnemy: battleData.getTargetedEnemy(this),
          skillType: skill.type,
        );
        buff.setUsed(this, battleData);
        activated = true;
      }
    }

    battleData.checkActorStatus();
    return activated;
  }

  Future<int> getClassRelation(
    final BattleData battleData,
    final int curRelation,
    final BattleServantData opponent,
    final CommandCardData? card,
    final bool isDef,
  ) async {
    int relation = curRelation;

    final List<BuffData> buffs = collectBuffsPerAction(battleBuff.validBuffs, BuffAction.overwriteClassRelation);
    for (final buff in buffs.reversed) {
      // did not find corresponding buff
      final shouldActivate = await buff.shouldActivateBuff(
        battleData,
        getTraits(addTraits: card?.traits),
        opponentTraits: opponent.getTraits(),
      );

      if (shouldActivate) {
        buff.setUsed(this, battleData);
        final relationOverwrite = buff.buff.script.relationId!;
        // relation overwrite don't include grand class, but still take effect
        final int oppCurClassId = opponent.logicalClassId;
        final int oppBaseClassId = opponent.isGrandSvt && oppCurClassId == opponent.baseClassId
            ? opponent.originalClassId
            : oppCurClassId;
        final int selfCurClassId = logicalClassId;
        final int selfBaseClassId = isGrandSvt && selfCurClassId == baseClassId ? originalClassId : selfCurClassId;

        RelationOverwriteDetail? overwrite;
        if (isDef) {
          final details = relationOverwrite.defSide[oppCurClassId] ?? relationOverwrite.defSide[oppBaseClassId];
          if (details != null) {
            overwrite = details[selfCurClassId] ?? details[selfBaseClassId];
          }
        } else {
          final details = relationOverwrite.atkSide[selfCurClassId] ?? relationOverwrite.atkSide[selfBaseClassId];
          if (details != null) {
            overwrite = details[oppCurClassId] ?? details[oppBaseClassId];
          }
        }

        if (overwrite != null) {
          final overwriteValue = overwrite.damageRate;
          switch (overwrite.type) {
            case ClassRelationOverwriteType.overwriteForce:
              relation = overwriteValue;
              break;
            case ClassRelationOverwriteType.overwriteMoreThanTarget:
              relation = min(overwriteValue, relation);
              break;
            case ClassRelationOverwriteType.overwriteLessThanTarget:
              relation = max(overwriteValue, relation);
              break;
          }
        }
      }
    }
    return relation;
  }

  bool isBuffStackable(final int buffGroup) {
    return battleBuff.validBuffs.every((buff) => buff.canStack(buffGroup));
  }

  void addBuff(final BuffData buffData, {final bool isPassive = false, final bool isCommandCode = false}) {
    if (isCommandCode) {
      battleBuff.commandCodeList.add(buffData);
    } else {
      battleBuff.addBuff(buffData, isPassive: isPassive);
    }
  }

  void clearCommandCodeBuffs() {
    battleBuff.commandCodeList.clear();
  }

  void updateActState(final BattleData battleData) {
    // always update indiv related buff first
    battleBuff
        .getAllBuffs()
        .where((buff) => BuffType.addIndividuality == buff.buff.type || BuffType.subIndividuality == buff.buff.type)
        .forEach((buff) => buff.updateActState(battleData, this));

    battleBuff
        .getAllBuffs()
        .where((buff) => BuffType.addIndividuality != buff.buff.type && BuffType.subIndividuality != buff.buff.type)
        .forEach((buff) => buff.updateActState(battleData, this));

    final rankUp = battleBuff.validBuffs.where((buff) => buff.buff.type == BuffType.skillRankUp).length;
    for (final skill in skillInfoList) {
      skill.setRankUp(rankUp);
    }
  }

  void useBuffOnce() {
    battleBuff.getAllBuffs().forEach((buff) {
      if (buff.isUsed) {
        buff.useOnce();
      }
    });
    battleBuff.checkUsedBuff();
    battleBuff.commandCodeList.removeWhere((buff) => buff.checkBuffClear());
  }

  Future<void> enterField(final BattleData battleData) async {
    await activateBuff(battleData, BuffAction.functionEntry);
  }

  Future<void> death(final BattleData battleData) async {
    // TODO: collect buffs and activate each,
    // DataVals.OpponentOnly? revengeOpp : revenge
    if (await activateBuff(battleData, BuffAction.functionDead)) {
      for (final svt in battleData.nonnullActors) {
        svt.clearReducedHp();
      }
    }

    battleData.fieldBuffs.removeWhere(
      (buff) => buff.vals.RemoveFieldBuffActorDeath == 1 && buff.activatorUniqueId == uniqueId,
    );
    battleData.battleLogger.action('$lBattleName ${S.current.battle_death}');
    if (isPlayer) {
      battleData.refillCardDeck();

      for (final svt in battleData.nonnullPlayers) {
        svt.battleBuff.removeBuffOfType(BuffType.fixCommandcard);
      }
    }
  }

  Future<void> startOfMyTurn(final BattleData battleData) async {
    await activateBuff(battleData, BuffAction.functionSelfturnstart);
  }

  Future<void> endOfMyTurn(final BattleData battleData) async {
    String turnEndLog = '';

    if (isEnemy) {
      if (!usedNpThisTurn && !isNPSealed() && niceEnemy!.chargeTurn > 0) {
        final turnEndNP = await getBuffValue(battleData, BuffAction.turnvalNp);
        changeNPLineCount(1 + turnEndNP);

        if (turnEndNP != 0) {
          turnEndLog += ' - NP: $turnEndNP';
        }
      }
    } else {
      final skillSealed = hasBuffNoProbabilityCheck(BuffAction.donotSkill);
      if (!skillSealed) {
        for (final skill in skillInfoList) {
          skill.turnEnd();
        }
      }

      for (final skills in commandCodeSkills) {
        for (final skill in skills) {
          skill.turnEnd();
        }
      }
    }
    usedNpThisTurn = false;

    // processing turnEndHeal
    final currentHp = hp;
    final turnEndHeal =
        await getBuffValue(battleData, BuffAction.turnendHpRegain) +
        await getBuffValueForTurnEndHpReduce(battleData, isValueForHeal: true);
    if (turnEndHeal != 0) {
      final healReceiveEff = await getBuffValue(battleData, BuffAction.gainHp);
      final finalHeal = (turnEndHeal * toModifier(healReceiveEff)).toInt();
      heal(finalHeal);
      procAccumulationDamage(currentHp);

      turnEndLog += ' - ${S.current.battle_heal} HP: $finalHeal';
    }

    // processing turnEndDamage
    int turnEndDamage = await getBuffValueForTurnEndHpReduce(battleData);
    if (turnEndDamage != 0) {
      if (turnEndDamage > currentHp && battleData.isWaveCleared) {
        turnEndDamage = currentHp - 1;
      }
      lossHp(turnEndDamage, lethal: true);
      actionHistory.add(
        BattleServantActionHistory(
          actType: BattleServantActionHistoryType.reduceHp,
          targetUniqueId: -1,
          isOpponent: false,
        ),
      );
      turnEndLog += ' - dot ${S.current.battle_damage}: $turnEndDamage';
    }

    if (hp <= 0) {
      if (hasNextShift(battleData)) {
        hp = 1;
      } else {
        resetLastHits();
      }
    }

    // processing turnEndStar
    final turnEndStar = await getBuffValue(battleData, BuffAction.turnendStar);
    if (turnEndStar != 0) {
      battleData.changeStar(turnEndStar);

      turnEndLog += ' - ${S.current.critical_star}: $turnEndStar';
    }

    // processing turnEndNp
    if (isPlayer) {
      final turnEndNP = await getBuffValue(battleData, BuffAction.turnendNp);
      if (turnEndNP != 0) {
        changeNP(turnEndNP);

        turnEndLog += ' - NP: ${(turnEndNP / 100).toStringAsFixed(2)}%';
      }
    }

    if (turnEndLog.isNotEmpty) {
      battleData.battleLogger.debug('$lBattleName - ${S.current.battle_turn_end}$turnEndLog');
    }

    battleBuff.turnProgress();

    final delayedFunctions = collectBuffsPerType(battleBuff.validBuffs, BuffType.delayFunction);
    await activateBuff(battleData, BuffAction.functionSelfturnend);
    await activateDelayFunction(battleData, delayedFunctions.where((buff) => buff.logicTurn == 0));

    battleBuff.selfTurnPass();

    battleData.checkActorStatus();
  }

  Future<void> endOfYourTurn(final BattleData battleData) async {
    clearReducedHp();
    attacked = false;

    battleBuff.turnProgress();

    final delayedFunctions = collectBuffsPerType(battleBuff.validBuffs, BuffType.delayFunction);
    await activateDelayFunction(battleData, delayedFunctions.where((buff) => buff.logicTurn == 0));
    await activateBuff(battleData, BuffAction.functionReflection);
    resetAccumulationDamage();

    battleData.checkActorStatus();
  }

  Future<bool> activateGuts(final BattleData battleData) async {
    BuffData? gutsToApply;
    final BuffAction gutsActionToCheck = hasNextShift(battleData) ? BuffAction.shiftGuts : BuffAction.guts;
    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, gutsActionToCheck)) {
      // no code found on whether ckSelf actually checks anything
      final oppoTraits = fetchOpponentTraits(
        BuffAction.guts,
        buff,
        lastHitBy,
        addTraits: lastHitByFunc?.getFuncIndividuality(),
      );
      if (await buff.shouldActivateBuff(battleData, [], opponentTraits: oppoTraits)) {
        if (gutsToApply == null || (gutsToApply.irremovable && !buff.irremovable)) {
          gutsToApply = buff;
        }
      }
    }

    if (gutsToApply != null) {
      await activateBuff(battleData, BuffAction.functionGutsBefore, opponent: lastHitBy);
      gutsToApply.setUsed(this, battleData);
      final value = gutsToApply.getValue(this);
      final isRatio = gutsToApply.buff.type == BuffType.gutsRatio || gutsToApply.buff.type == BuffType.shiftGutsRatio;
      final baseGutsHp = isRatio ? (toModifier(value) * maxHp).floor() : value;
      final gutsHpModifier = toModifier(await getBuffValue(battleData, BuffAction.gutsHp));
      hp = (baseGutsHp * gutsHpModifier).toInt();
      hp = hp.clamp(1, maxHp);
      clearReducedHp();
      procAccumulationDamage(1); // guts always proc with previousHp = 1

      battleData.battleLogger.action(
        '$lBattleName - ${gutsToApply.buff.lName.l} - '
        '${!isRatio ? value : '${(value / 10).toStringAsFixed(1)}%'}',
      );

      // no corresponding code, but there is one instance that has ckOpsIndiv in an Event quest.
      // Therefore, I think here Ops refer to the svt which kills the current svt
      if (await activateBuff(battleData, BuffAction.functionGuts, opponent: lastHitBy)) {
        for (final svt in battleData.nonnullActors) {
          svt.clearReducedHp();
        }
      }
      return true;
    }

    resetLastHits();

    return false;
  }

  int getRevengeTargetUniqueId() {
    for (final action in actionHistory.reversed) {
      if (action.isDamage && action.targetUniqueId != uniqueId) {
        return action.targetUniqueId;
      }
    }
    return -1;
  }

  int getRevengeTargetUniqueIdFromOpponent() {
    for (final action in actionHistory.reversed) {
      if (action.isDamage && action.isOpponent && action.targetUniqueId != uniqueId) {
        return action.targetUniqueId;
      }
    }
    return -1;
  }

  BattleServantData copy() {
    return BattleServantData._(isPlayer: isPlayer, isGrandSvt: isGrandSvt, isUseGrandBoard: isUseGrandBoard)
      ..eventId = eventId
      ..niceEnemy = niceEnemy
      ..baseEnemy = baseEnemy
      ..niceSvt = niceSvt
      ..svtAi = svtAi
      ..playerSvtData = playerSvtData?.copy()
      ..fieldIndex = fieldIndex
      ..deckIndex = deckIndex
      ..uniqueId = uniqueId
      ..svtId = svtId
      ..level = level
      ..bond = bond
      ..startingPosition = startingPosition
      ..curBattlePoints = curBattlePoints.deepCopy()
      ..baseAtk = baseAtk
      ..hp = hp
      .._maxHp = _maxHp
      ..np = np
      ..npLineCount = npLineCount
      ..usedNpThisTurn = usedNpThisTurn
      ..reducedHp = reducedHp
      .._accumulationDamage = _accumulationDamage
      ..skillInfoList = skillInfoList
          .map((e) => e.copy())
          .toList() // copy
      ..equip1 = equip1?.copy()
      ..equip2 = equip2?.copy()
      ..equip3 = equip3?.copy()
      ..battleBuff = battleBuff.copy()
      ..commandCodeSkills = commandCodeSkills.map((skills) => skills.map((skill) => skill.copy()).toList()).toList()
      ..shiftNpcIds = shiftNpcIds.toList()
      ..shiftLowLimit = shiftLowLimit
      ..shiftDeckIndex = shiftDeckIndex
      ..changeNpcIds = changeNpcIds.toList()
      ..changeIndex = changeIndex
      ..actionHistory = actionHistory.toList(); //copy
  }
}

class BattleServantActionHistory {
  final BattleServantActionHistoryType actType;
  final int targetUniqueId;
  // final int waveCount;
  final bool isOpponent;

  BattleServantActionHistory({
    required this.actType,
    required this.targetUniqueId,
    // required this.waveCount,
    required this.isOpponent,
  });

  bool get isDamage => actType.isDamage;

  void copy() {}
}

enum BattleServantActionHistoryType {
  none,
  damageCommand,
  damageTd,
  hploss,
  instantDeath,
  reduceHp,
  damageReflection,
  damageValue;

  bool get isDamage => this != none;
}
