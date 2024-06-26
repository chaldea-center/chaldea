import 'dart:math';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_exception.dart';
import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'ai.dart';

class BattleServantData {
  static const npPityThreshold = 9900;
  static List<BuffAction> buffEffectivenessTypes = [BuffAction.buffRate, BuffAction.funcHpReduce];

  final bool isPlayer;
  bool get isEnemy => !isPlayer;
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
  BattleCEData? equip;
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
  List<BattleServantActionHistory> actionHistory = [];

  BattleServantData._({required this.isPlayer});

  @override
  String toString() {
    return 'BattleServantData(${fieldIndex + 1}-$lBattleName)';
  }

  factory BattleServantData.fromEnemy(final QuestEnemy enemy, final int uniqueId, {Servant? niceSvt}) {
    final svt = BattleServantData._(isPlayer: false);
    svt
      ..niceEnemy = enemy
      ..baseEnemy = enemy
      ..svtAi = SvtAiManager(enemy.ai)
      ..niceSvt = niceSvt
      ..uniqueId = uniqueId
      ..hp = enemy.hp
      .._maxHp = enemy.hp
      ..svtId = enemy.svt.id
      ..level = enemy.lv
      ..baseAtk = enemy.atk
      ..deckIndex = enemy.deckId
      ..shiftNpcIds = enemy.enemyScript.shift ?? []
      ..changeNpcIds = enemy.enemyScript.change ?? [];

    svt.skillInfoList = [
      BattleSkillInfoData(enemy.skills.skill1,
          skillNum: 1, skillLv: enemy.skills.skillLv1, type: SkillInfoType.svtSelf),
      BattleSkillInfoData(enemy.skills.skill2,
          skillNum: 2, skillLv: enemy.skills.skillLv2, type: SkillInfoType.svtSelf),
      BattleSkillInfoData(enemy.skills.skill3,
          skillNum: 3, skillLv: enemy.skills.skillLv3, type: SkillInfoType.svtSelf),
    ];
    return svt;
  }

  factory BattleServantData.fromPlayerSvtData(final PlayerSvtData settings, final int uniqueId) {
    final psvt = settings.svt;
    if (psvt == null) {
      throw BattleException('Invalid PlayerSvtData: null svt');
    }

    final svt = BattleServantData._(isPlayer: true);
    svt
      ..playerSvtData = settings.copy()
      ..uniqueId = uniqueId
      ..niceSvt = psvt
      ..svtId = psvt.id
      ..level = settings.lv
      .._maxHp = settings.fixedHp ?? ((psvt.hpGrowth.getOrNull(settings.lv - 1) ?? 0) + settings.hpFou)
      ..baseAtk = settings.fixedAtk ?? ((psvt.atkGrowth.getOrNull(settings.lv - 1) ?? 0) + settings.atkFou);
    svt.hp = svt._maxHp;
    if (settings.ce != null) {
      svt.equip = BattleCEData(settings.ce!, settings.ceLimitBreak, settings.ceLv);
      svt.hp += svt.equip!.hp;
      svt._maxHp += svt.equip!.hp;
    }

    final script = psvt.script;
    for (final skillNum in kActiveSkillNums) {
      final List<BaseSkill> provisionedSkills = [];
      provisionedSkills.addAll(psvt.groupedActiveSkills[skillNum] ?? []);
      List<BaseSkill?>? rankUps;
      if (script != null && script.skillRankUp != null) {
        rankUps = [
          for (final id in script.skillRankUp![settings.skills[skillNum - 1]?.id] ?? <int>[]) db.gameData.baseSkills[id]
        ];
        if (rankUps.isNotEmpty) {
          provisionedSkills.addAll(rankUps.whereType());
        }
      }

      final baseSkill = settings.skills[skillNum - 1], skillLv = settings.skillLvs[skillNum - 1];

      final skillInfo = BattleSkillInfoData(baseSkill,
          provisionedSkills: provisionedSkills, skillNum: skillNum, skillLv: skillLv, type: SkillInfoType.svtSelf);

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
        svt.commandCodeSkills.add(commandCode.skills
            .map((skill) => BattleSkillInfoData(skill, type: SkillInfoType.commandCode)..skillLv = 1)
            .toList());
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
      battleData.battleLogger.error("failed to load servant data for enenemy $svtId - ${niceEnemy?.lShownName}");
    }
  }

  bool get selectable => battleBuff.isSelectable;

  int get tdLv => (isPlayer ? playerSvtData!.tdLv : niceEnemy!.noblePhantasm.noblePhantasmLv).clamp(0, 5);

  int get atk => isPlayer ? baseAtk + (equip?.atk ?? 0) : baseAtk;

  int get rarity => isPlayer ? niceSvt!.rarity : niceEnemy!.svt.rarity;

  int get classId => isPlayer ? niceSvt!.classId : niceEnemy!.svt.classId;

  ServantSubAttribute get attribute {
    final overwriteSubattributeBuff =
        collectBuffsPerType(battleBuff.validBuffsActiveFirst, BuffType.overwriteSubattribute).firstOrNull;
    final overwriteSubattribute =
        ServantSubAttribute.values.firstWhereOrNull((attr) => attr.value == overwriteSubattributeBuff?.vals.Value);
    if (overwriteSubattribute != null) {
      return overwriteSubattribute;
    }
    return isPlayer ? niceSvt!.attribute : niceEnemy!.svt.attribute;
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
  }

  Future<void> activateClassPassive(final BattleData battleData) async {
    final List<NiceSkill> passives = isPlayer ? [...niceSvt!.classPassive] : [...niceEnemy!.classPassive.classPassive];

    await battleData.withActivator(this, () async {
      for (final skill in passives) {
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtClassPassive);
        await skillInfo.activate(battleData);
      }
      if (isEnemy) {
        for (final (index, skill) in niceEnemy!.classPassive.addPassive.indexed) {
          final skillInfo = BattleSkillInfoData(skill,
              type: SkillInfoType.svtOtherPassive,
              skillLv: niceEnemy!.classPassive.addPassiveLvs.getOrNull(index) ?? skill.maxLv);
          await skillInfo.activate(battleData);
        }
      }

      if (isPlayer) {
        for (int index = 0; index < niceSvt!.appendPassive.length; index += 1) {
          final appendLv = playerSvtData!.appendLvs.length > index ? playerSvtData!.appendLvs[index] : 0;
          if (appendLv > 0) {
            final skillInfo = BattleSkillInfoData(niceSvt!.appendPassive[index].skill,
                type: SkillInfoType.svtOtherPassive, skillLv: appendLv);
            await skillInfo.activate(battleData);
          }
        }
      }
    });
  }

  Future<void> activateEquip(final BattleData battleData) async {
    await battleData.withActivator(this, () async {
      await equip?.activateCE(battleData);
    });
  }

  Future<void> activateExtraPassive(final BattleData battleData) async {
    if (isPlayer) {
      await battleData.withActivator(this, () async {
        for (final skill in playerSvtData!.extraPassives) {
          if (playerSvtData!.disabledExtraSkills.contains(skill.id)) continue;
          if (skill.shouldActiveSvtEventSkill(
              eventId: battleData.niceQuest?.war?.eventId ?? 0, svtId: svtId, includeZero: true)) {
            final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtOtherPassive);
            await skillInfo.activate(battleData);
          }
        }
      });
    }
  }

  Future<void> activateAdditionalPassive(final BattleData battleData) async {
    if (isPlayer) {
      await battleData.withActivator(this, () async {
        for (int index = 0; index < playerSvtData!.customPassives.length; index++) {
          final skill = playerSvtData!.customPassives[index];
          final skillLv = playerSvtData!.customPassiveLvs[index];
          final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtOtherPassive, skillLv: skillLv);
          await skillInfo.activate(battleData);
        }
      });
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
    final changeCardType = changeCardBuff == null
        ? null
        : CardType.values.firstWhere((cardType) => cardType.value == changeCardBuff.param);

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

      final cardType = changeCardType ?? cards[index];
      final detail = niceSvt!.cardDetails[cardType];
      if (detail == null) continue;
      final card = CommandCardData(this, cardType, detail, index)
        ..isTD = false
        ..npGain = getNPGain(cardType)
        ..traits = ConstData.cardInfo[cardType]![1]!.individuality.toList();

      if (isCardInDeck) {
        // enemy weak+strength 6 cards
        card
          ..cardStrengthen = playerSvtData!.cardStrengthens.getOrNull(index) ?? 0
          ..commandCode = playerSvtData!.commandCodes.getOrNull(index);
      }
      if (cardType == CardType.weak) {
        card.critical = false;
      } else if (cardType == CardType.strength) {
        card.critical = true;
      }

      builtCards.add(card);
    }
    return builtCards;
  }

  CommandCardData? getNPCard() {
    if (isEnemy) {
      final _td = niceEnemy!.noblePhantasm.noblePhantasm;
      if (_td == null) return null;
      return CommandCardData(
        this,
        _td.card,
        CardDetail(
          attackIndividuality: _td.individuality.toList(),
          hitsDistribution: _td.damage,
          attackType:
              _td.damageType == TdEffectFlag.attackEnemyAll ? CommandCardAttackType.all : CommandCardAttackType.one,
        ),
        -1,
      )
        ..td = _td
        ..isTD = true
        ..npGain = 0
        ..traits = _td.individuality.toList();
    }

    final currentNP = getCurrentNP();
    final cardDetail = CardDetail(
      attackIndividuality: currentNP?.individuality ?? [],
      hitsDistribution: currentNP?.svt.damage ?? [100],
      attackType:
          currentNP?.damageType == TdEffectFlag.attackEnemyAll ? CommandCardAttackType.all : CommandCardAttackType.one,
      attackNpRate: currentNP?.npGain.np[playerSvtData!.tdLv - 1] ?? 0,
    );

    return CommandCardData(this, currentNP?.svt.card ?? CardType.none, cardDetail, -1)
      ..isTD = true
      ..td = currentNP
      ..npGain = currentNP?.npGain.np[playerSvtData!.tdLv - 1] ?? 0
      ..traits = currentNP?.individuality ?? [];
  }

  Future<CommandCardData?> getCounterNPCard(final BattleData battleData) async {
    // buff.vals.UseTreasureDevice: =0 means skill?
    final buff = battleBuff.validBuffs.lastWhereOrNull((buff) => buff.vals.CounterId != null);
    if (buff == null) return null;

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
      attackType: td.damageType == TdEffectFlag.attackEnemyAll ? CommandCardAttackType.all : CommandCardAttackType.one,
      attackNpRate: td.npGain.np[tdLv - 1],
    );

    return CommandCardData(this, td.svt.card, cardDetail, -1)
      ..isTD = true
      ..td = td
      ..counterBuff = buff
      ..npGain = td.npGain.np[tdLv - 1]
      ..traits = td.individuality;
  }

  CommandCardData? getExtraCard() {
    if (isEnemy) {
      return null;
    }
    final detail = niceSvt!.cardDetails[CardType.extra];
    if (detail == null) return null;

    return CommandCardData(this, CardType.extra, detail, -1)
      ..isTD = false
      ..npGain = getNPGain(CardType.extra)
      ..traits = ConstData.cardInfo[CardType.extra]![1]!.individuality.toList();
  }

  int getNPGain(final CardType cardType) {
    if (!isPlayer) {
      return 0;
    }
    final currentNp = getCurrentNP();
    if (currentNp == null) {
      return 0;
    }

    switch (cardType) {
      case CardType.buster:
        return currentNp.npGain.buster[playerSvtData!.tdLv - 1];
      case CardType.arts:
        return currentNp.npGain.arts[playerSvtData!.tdLv - 1];
      case CardType.quick:
        return currentNp.npGain.quick[playerSvtData!.tdLv - 1];
      case CardType.extra:
        return currentNp.npGain.extra[playerSvtData!.tdLv - 1];
      default:
        return 0;
    }
  }

  List<NiceTrait> getBasicSvtTraits({int? eventId}) {
    Set<NiceTrait> traits = {};

    if (niceEnemy != null) {
      traits.addAll(niceEnemy!.traits);
    } else if (niceSvt != null) {
      if (niceSvt!.ascensionAdd.individuality.all.containsKey(limitCount)) {
        traits.addAll(niceSvt!.ascensionAdd.individuality.all[limitCount]!);
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
    return traits.toList();
  }

  List<NiceTrait> getTraits(final BattleData battleData) {
    final List<NiceTrait> allTraits = [];
    allTraits.addAll(getBasicSvtTraits(eventId: battleData.niceQuest?.war?.eventId));

    final List<int> removeTraitIds = [];
    for (final buff in battleBuff.validBuffs) {
      if (buff.buff.type == BuffType.addIndividuality && buff.shouldApplyBuff(battleData, this)) {
        allTraits.add(NiceTrait(id: buff.param));
      } else if (buff.buff.type == BuffType.subIndividuality && buff.shouldApplyBuff(battleData, this)) {
        removeTraitIds.add(buff.param);
      }
    }

    allTraits.removeWhere((trait) => removeTraitIds.contains(trait.id));

    return allTraits;
  }

  List<NiceTrait> getBuffTraits(
    final BattleData battleData, {
    final bool activeOnly = false,
    final bool ignoreIrremovable = false,
  }) {
    final List<NiceTrait> myTraits = [];
    final List<BuffData> buffs = activeOnly ? battleBuff.getActiveList() : battleBuff.validBuffs;
    for (final buff in buffs) {
      if (!ignoreIrremovable || !buff.irremovable) {
        myTraits.addAll(buff.traits);
      }
    }

    return myTraits;
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

  Future<void> heal(final BattleData battleData, final int heal) async {
    if (await hasBuffOnAction(battleData, BuffAction.donotRecovery)) {
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

  void lossHp(
    final int loss, {
    final bool lethal = false,
  }) {
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
        return battleData.enemyDecks[DeckType.shift]
            ?.firstWhereOrNull((questEnemy) => questEnemy.npcId == shiftNpcIds[shiftTo]);
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
    await battleData.withTarget(this, () async {
      changeIndex = changeIndex;
      niceEnemy = changeSvt;
      baseAtk = changeSvt.atk;
      _maxHp = changeSvt.hp;
      // hp = maxHp;
      level = changeSvt.lv;
      battleBuff.clearPassive(uniqueId);
      await loadAi(battleData);
      await battleData.initActorSkills([this]);
    });
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
      final hideActives =
          ConstData.getSvtLimitHides(targetSvtId, limitCount).expand((e) => e.activeSkills[skillNum] ?? []).toList();
      newSkills.removeWhere((niceSkill) => hideActives.contains(niceSkill.id));

      final oldInfoData = skillInfoList.firstWhereOrNull((infoData) => infoData.skillNum == skillNum);
      BaseSkill? baseSkill = newSkills.firstWhereOrNull((skill) => skill.id == oldInfoData?.skill?.id);
      baseSkill ??=
          newSkills.lastWhereOrNull((skill) => skill.strengthStatus == oldInfoData?.skill?.svt.strengthStatus);
      baseSkill ??=
          newSkills.fold(null, (prev, next) => prev == null || prev.svt.priority <= prev.svt.priority ? next : prev);

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
    _maxHp = (targetSvt.hpGrowth.getOrNull(playerSvtData!.lv - 1) ?? 0) + playerSvtData!.hpFou + (equip?.hp ?? 0);
    hp = hp > maxHp ? maxHp : hp;

    battleBuff.clearClassPassive();
    final List<NiceSkill> passives = [...targetSvt.classPassive];

    await battleData.withActivator(this, () async {
      for (final skill in passives) {
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtClassPassive);
        await skillInfo.activate(battleData);
      }
    });
  }

  Future<void> transformEnemy(final BattleData battleData, final QuestEnemy targetEnemy) async {
    niceEnemy = targetEnemy;
    skillInfoList = [
      BattleSkillInfoData(targetEnemy.skills.skill1,
          skillNum: 1, skillLv: targetEnemy.skills.skillLv1, type: SkillInfoType.svtSelf),
      BattleSkillInfoData(targetEnemy.skills.skill2,
          skillNum: 2, skillLv: targetEnemy.skills.skillLv2, type: SkillInfoType.svtSelf),
      BattleSkillInfoData(targetEnemy.skills.skill3,
          skillNum: 3, skillLv: targetEnemy.skills.skillLv3, type: SkillInfoType.svtSelf),
    ];

    if (svtId == 600700) {
      return;
    }
    baseAtk = targetEnemy.atk;
    _maxHp = targetEnemy.hp;
    hp = hp > maxHp ? maxHp : hp;

    battleBuff.clearClassPassive();
    final List<NiceSkill> passives = targetEnemy.classPassive.classPassive;

    await battleData.withActivator(this, () async {
      for (final skill in passives) {
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtClassPassive);
        await skillInfo.activate(battleData);
      }
    });
  }

  bool isAlive(final BattleData battleData) {
    if (hp > 0) {
      return true;
    }

    if (hasNextShift(battleData)) {
      return true;
    }

    return battleData.withActivatorSync(this, () {
      return collectBuffsPerAction(battleBuff.validBuffs, BuffAction.guts)
          .where((buff) => buff.shouldApplyBuff(battleData, this))
          .isNotEmpty;
    });
  }

  bool isNPSealed() {
    return collectBuffsPerActions(battleBuff.validBuffs, [BuffAction.donotNoble, BuffAction.donotNobleCondMismatch])
        .isNotEmpty;
  }

  bool isSkillSealed(final int skillIndex) {
    if (skillInfoList.length <= skillIndex || skillIndex < 0) {
      return false;
    }

    final skillInfo = skillInfoList[skillIndex];
    final rankUp = countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.value)]);
    skillInfo.setRankUp(rankUp);
    return collectBuffsPerAction(battleBuff.validBuffs, BuffAction.donotSkill).isNotEmpty;
  }

  bool isDonotSkillSelect(int idx) {
    return collectBuffsPerType(battleBuff.validBuffs, BuffType.donotSkillSelect).any((buff) => buff.vals.Value == idx);
  }

  bool isSkillCondFailed(final BattleData battleData, final int skillIndex) {
    if (skillInfoList.length <= skillIndex || skillIndex < 0) {
      return false;
    }

    final skillInfo = skillInfoList[skillIndex];
    return battleData.withActivatorSync(this, () {
      final rankUp = countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.value)]);
      skillInfo.setRankUp(rankUp);
      return !canAttack() || skillInfo.skill == null || !skillInfo.checkSkillScript(battleData);
    });
  }

  bool canUseSkillIgnoreCoolDown(final BattleData battleData, final int skillIndex) {
    if (skillInfoList.length <= skillIndex || skillIndex < 0) {
      return false;
    }

    final skillInfo = skillInfoList[skillIndex];
    return battleData.withActivatorSync(this, () {
      final rankUp = countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.value)]);
      skillInfo.setRankUp(rankUp);

      return !isSkillSealed(skillIndex) && !isSkillCondFailed(battleData, skillIndex);
    });
  }

  Future<bool> activateSkill(final BattleData battleData, final int skillIndex) async {
    final skillInfo = skillInfoList.getOrNull(skillIndex);
    if (skillInfo == null || skillInfo.chargeTurn > 0) return false;

    return await battleData.withActivator(this, () async {
      final rankUp = countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.value)]);
      skillInfo.setRankUp(rankUp);

      // in case transform svt changed self or skill
      final _actor = copy(), _skill = skillInfo.copy();
      final param = BattleSkillParams();
      final activated = await skillInfo.activate(battleData, param: param);
      if (activated) {
        battleData.recorder.skill(
          battleData: battleData,
          activator: _actor,
          skill: _skill,
          fromPlayer: true,
          uploadEligible: true,
          param: param,
        );
      }
      return activated;
    });
  }

  Future<void> activateCommandCode(final BattleData battleData, final int cardIndex) async {
    final skillInfos = commandCodeSkills.getOrNull(cardIndex);
    if (skillInfos == null) return;

    await battleData.withActivator(this, () async {
      for (final skill in skillInfos) {
        if (skill.chargeTurn > 0) continue;
        battleData.battleLogger.action('$lBattleName - ${S.current.command_code}: ${skill.lName}');
        await skill.activate(battleData);
      }
    });
  }

  bool canOrderChange() {
    return collectBuffsPerAction(battleBuff.validBuffs, BuffAction.donotReplace).isEmpty;
  }

  bool canAttack() {
    return hp > 0 && collectBuffsPerAction(battleBuff.validBuffs, BuffAction.donotAct).isEmpty;
  }

  bool canCommandCard(final CommandCardData card) {
    if (!canAttack()) return false;

    return collectBuffsPerAction(battleBuff.validBuffs, BuffAction.donotActCommandtype)
        .where((buff) => buff.shouldActivateDonotActCommandtype(card))
        .isEmpty;
  }

  bool canSelectNP(final BattleData battleData) {
    return battleData.withActivatorSync(this, () {
      final currentNp = getCurrentNP();
      return canNP() && currentNp != null && currentNp.functions.isNotEmpty && checkNPScript(battleData);
    });
  }

  bool canNP() {
    final npCard = getNPCard();
    return npCard != null && isNpFull() && canAttack() && canCommandCard(npCard) && !isNPSealed();
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

  bool checkNPScript(final BattleData battleData) {
    return battleData.withActivatorSync(this, () {
      bool checkNpScript = true;
      if (isPlayer) {
        checkNpScript = BattleSkillInfoData.skillScriptConditionCheck(battleData, getCurrentNP()?.script, tdLv);
      }
      return checkNpScript;
    });
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

    return getBaseTD();
  }

  Future<void> activateNP(final BattleData battleData, CommandCardData card, final int extraOverchargeLvl) async {
    await battleData.withActivator(this, () async {
      battleData.battleLogger.action('$lBattleName ${S.current.battle_np_card}');

      final niceTD = getCurrentNP();
      if (niceTD != null) {
        final baseOverCharge = isPlayer ? np ~/ ConstData.constants.fullTdPoint : 1;
        int upOverCharge = await getBuffValueOnAction(battleData, BuffAction.chagetd);
        if (isPlayer) {
          upOverCharge += extraOverchargeLvl;
        }
        int? overchargeLvl;
        if (battleData.delegate?.decideOC != null) {
          overchargeLvl = battleData.delegate!.decideOC!(battleData.activator, baseOverCharge, upOverCharge);
        }
        overchargeLvl ??= baseOverCharge + upOverCharge;
        overchargeLvl = overchargeLvl.clamp(1, 5);
        battleData.recorder.setOverCharge(this, card, overchargeLvl);

        np = 0;
        npLineCount = 0;
        usedNpThisTurn = true;
        final functions = await updateNpFunctions(battleData, niceTD.functions);
        await FunctionExecutor.executeFunctions(battleData, functions, tdLv,
            script: niceTD.script, overchargeLvl: overchargeLvl);
      }
    });
  }

  Future<List<NiceFunction>> updateNpFunctions(final BattleData battleData, final List<NiceFunction> functions) async {
    final List<NiceFunction> updatedFunctions = functions.toList();

    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, BuffAction.functionNpattack)) {
      if (buff.param < 0 || buff.param >= updatedFunctions.length) {
        // replace index not valid for current function list
        continue;
      }

      final skillId = buff.vals.SkillID;
      final skillLv = buff.vals.SkillLV;
      if (skillId != null && skillLv != null && await buff.shouldActivateBuff(battleData, this)) {
        BaseSkill? skill = db.gameData.baseSkills[skillId];
        skill ??= await showEasyLoading(() => AtlasApi.skill(skillId), mask: true);
        final replacementFunction = skill?.functions.firstOrNull;
        final selectedDataVal = replacementFunction?.svals.getOrNull(skillLv - 1);
        if (skill == null || replacementFunction == null || selectedDataVal == null) {
          battleData.battleLogger
              .debug('Buff ID [${buff.buff.id}]: ${S.current.skill} [$skillId] ${S.current.battle_invalid}');
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

        buff.setUsed(this);
      }
    }

    return updatedFunctions;
  }

  Future<int?> getMultiAttackBuffValue(final BattleData battleData) async {
    final actionDetails = ConstData.buffActions[BuffAction.multiattack];
    if (actionDetails == null) {
      return null;
    }

    final opponent = battleData.getOpponent(this);
    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, BuffAction.multiattack)) {
      if (await buff.shouldActivateBuff(battleData, this, opponent)) {
        buff.setUsed(this);
        final value = buff.getValue(battleData, this, opponent);
        if (actionDetails.plusTypes.contains(buff.buff.type)) {
          return value;
        } else {
          return -value;
        }
      }
    }
    return null;
  }

  Future<int> getBuffValueOnAction(final BattleData battleData, final BuffAction buffAction) async {
    final actionDetails = ConstData.buffActions[buffAction];
    if (actionDetails == null) {
      return 0;
    }

    final opponent = battleData.getOpponent(this);
    int totalVal = 0;
    int? maxRate;

    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, buffAction)) {
      if (await buff.shouldActivateBuff(battleData, this, opponent)) {
        buff.setUsed(this);
        final totalEffectiveness = await battleData.withBuff(buff, () async {
          return await getEffectivenessOnAction(battleData, buffAction);
        });

        final value = (toModifier(totalEffectiveness) * buff.getValue(battleData, this, opponent)).toInt();
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

  Future<int> getBuffValueForToleranceSubstate(
    final BattleData battleData,
    final Iterable<NiceTrait> affectTraits,
    final BattleServantData? activator, //  tolerance substate so opponent is activator of function
  ) async {
    final actionDetails = ConstData.buffActions[BuffAction.toleranceSubstate];
    if (actionDetails == null) {
      return 0;
    }

    int totalVal = 0;
    int? maxRate;

    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, BuffAction.toleranceSubstate)) {
      if (await buff.shouldActivateToleranceSubstate(battleData, this, affectTraits)) {
        buff.setUsed(this);
        // should not have effectiveness on this
        // final totalEffectiveness = await battleData.withBuff(buff, () async {
        //   return await getEffectivenessOnAction(battleData, buffAction);
        // });

        final value = buff.getValue(battleData, this, activator);
        if (actionDetails.plusTypes.contains(buff.buff.type)) {
          totalVal += value;
        } else if (actionDetails.minusTypes.contains(buff.buff.type)) {
          totalVal -= value;
        }
        maxRate = maxRate == null ? buff.buff.maxRate : max(maxRate, buff.buff.maxRate);
      }
    }
    return capBuffValue(actionDetails, totalVal, maxRate);
  }

  int getBuffValueForFuncHpReduce(final BattleData battleData, final BuffData turnEndHpReduce) {
    final actionDetails = ConstData.buffActions[BuffAction.funcHpReduce];
    if (actionDetails == null) {
      return 0;
    }

    int totalVal = 0;
    int? maxRate;

    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, BuffAction.funcHpReduce)) {
      if (buff.shouldActivateFuncHpReduce(turnEndHpReduce)) {
        buff.setUsed(this);
        final value = buff.getValue(battleData, this);
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

  int getBuffValueForFuncHpReduceValue(final BattleData battleData, final BuffData turnEndHpReduce) {
    final actionDetails = ConstData.buffActions[BuffAction.funcHpReduceValue];
    if (actionDetails == null) {
      return 0;
    }

    int totalVal = 0;
    int? maxRate;

    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, BuffAction.funcHpReduceValue)) {
      if (buff.shouldActivateFuncHpReduceValue(turnEndHpReduce)) {
        buff.setUsed(this);
        final value = buff.getValue(battleData, this);
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

  int getBuffValueForTurnEndHpReduce(final BattleData battleData, {final bool isValueForHeal = false}) {
    final actionDetails = ConstData.buffActions[BuffAction.turnendHpReduce];
    if (actionDetails == null) {
      return 0;
    }

    int nonPreventableValue = 0;
    int preventableValue = 0;
    int? maxRate;
    final List<BuffData> preventDeaths = collectBuffsPerAction(battleBuff.validBuffs, BuffAction.preventDeathByDamage);
    final List<BuffData> activatedPreventDeaths = [];

    final List<BuffData> turnEndHpReduceToRegainBuffs =
        collectBuffsPerAction(battleBuff.validBuffs, BuffAction.turnendHpReduceToRegain);

    for (final turnEndHpReduce in collectBuffsPerAction(battleBuff.validBuffs, BuffAction.turnendHpReduce)) {
      // making assumption that turnendHpReduce should always apply, not checking indivs

      // check turnendHpReduceToRegain
      final shouldConvertToHeal = turnEndHpReduceToRegainBuffs.any((turnEndHpReduceToRegain) {
        final shouldActivate = turnEndHpReduceToRegain.shouldActivateTurnendHpReduceToRegain(turnEndHpReduce);
        if (shouldActivate) {
          turnEndHpReduceToRegain.setUsed(this);
        }
        return shouldActivate;
      });

      if (isValueForHeal != shouldConvertToHeal) {
        continue;
      }

      turnEndHpReduce.setUsed(this);
      final funcHpReduce = getBuffValueForFuncHpReduce(battleData, turnEndHpReduce);
      final funcHpReduceValue = getBuffValueForFuncHpReduceValue(battleData, turnEndHpReduce);

      final baseValue = (toModifier(funcHpReduce) * turnEndHpReduce.getValue(battleData, this)).toInt();
      final finalValue = max(baseValue + funcHpReduceValue, 0);

      // this is for scenario where funcHpReduceValue is applied before funcHpReduce kicks in
      // final baseValue = max(turnEndHpReduce.getValue(battleData, this) + funcHpReduceValue, 0);
      // final finalValue = (toModifier(funcHpReduce) * baseValue).toInt();

      final shouldPreventDeath = preventDeaths.any((preventDeath) {
        final shouldActivate = preventDeath.shouldActivatePreventDeath(turnEndHpReduce);
        if (shouldActivate) {
          activatedPreventDeaths.add(preventDeath);
        }
        return shouldActivate;
      });

      // turnendHpReduce has no minus type
      if (shouldPreventDeath) {
        preventableValue += finalValue;
      } else {
        nonPreventableValue += finalValue;
      }

      maxRate = maxRate == null ? turnEndHpReduce.buff.maxRate : max(maxRate, turnEndHpReduce.buff.maxRate);
    }

    int finalValue = preventableValue + nonPreventableValue;
    if (!isValueForHeal && hp <= finalValue && hp > nonPreventableValue && preventableValue > 0) {
      finalValue = hp - 1;
      for (final buff in activatedPreventDeaths) {
        buff.setUsed(this);
      }
    }

    return capBuffValue(actionDetails, finalValue, maxRate);
  }

  Future<int> getEffectivenessOnAction(final BattleData battleData, final BuffAction buffAction) async {
    return buffAction == BuffAction.turnendHpReduce
        ? await getBuffValueOnAction(battleData, BuffAction.funcHpReduce)
        : buffAction != BuffAction.buffRate
            ? await getBuffValueOnAction(battleData, BuffAction.buffRate)
            : 1000;
  }

  BuffData? getFirstBuffOnActions(final BattleData battleData, final List<BuffAction> buffActions) {
    for (final buff in collectBuffsPerActions(battleBuff.validBuffs, buffActions)) {
      if (buff.shouldApplyBuff(battleData, this, battleData.getOpponent(this))) {
        buff.setUsed(this);
        return buff;
      }
    }
    return null;
  }

  int getMaxHpBuffValue({final bool percent = false}) {
    final BuffAction buffAction = percent ? BuffAction.maxhpRate : BuffAction.maxhpValue;
    final actionDetails = ConstData.buffActions[buffAction];
    if (actionDetails == null) {
      return 0;
    }

    int totalVal = 0;
    int? maxRate;

    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, buffAction)) {
      buff.setUsed(this);
      final value = buff.param;
      if (actionDetails.plusTypes.contains(buff.buff.type)) {
        totalVal += value;
      } else {
        totalVal -= value;
      }
      maxRate = maxRate == null ? buff.buff.maxRate : max(maxRate, buff.buff.maxRate);
    }
    return capBuffValue(actionDetails, totalVal, maxRate);
  }

  Future<bool> hasBuffOnAction(final BattleData battleData, final BuffAction buffAction) async {
    return await hasBuffOnActions(battleData, [buffAction]);
  }

  Future<bool> hasBuffOnActions(final BattleData battleData, final List<BuffAction> buffActions) async {
    for (final buff in collectBuffsPerActions(battleBuff.validBuffs, buffActions)) {
      if (await buff.shouldActivateBuff(battleData, this, battleData.getOpponent(this))) {
        buff.setUsed(this);
        return true;
      }
    }
    return false;
  }

  Future<bool> activateBuffOnActionActiveFirst(final BattleData battleData, final BuffAction buffAction) async {
    return await activateBuffs(battleData, collectBuffsPerAction(battleBuff.validBuffsActiveFirst, buffAction));
  }

  Future<bool> activateBuffOnAction(final BattleData battleData, final BuffAction buffAction) async {
    return await activateBuffOnActions(battleData, [buffAction]);
  }

  Future<bool> activateBuffOnActions(final BattleData battleData, final Iterable<BuffAction> buffActions) async {
    final List<BuffData> orderedBuffs = [
      for (final buffAction in buffActions) ...collectBuffsPerAction(battleBuff.validBuffs, buffAction)
    ];
    return await activateBuffs(battleData, orderedBuffs);
  }

  // trigger skill
  Future<bool> activateBuffs(final BattleData battleData, final Iterable<BuffData> buffs) async {
    return await battleData.withActivator(this, () async {
      bool activated = false;
      for (final buff in buffs.toList()) {
        if (await buff.shouldActivateBuff(battleData, this, battleData.target)) {
          final skillId = buff.param;
          BaseSkill? skill = db.gameData.baseSkills[skillId];
          skill ??= await showEasyLoading(() => AtlasApi.skill(skillId), mask: true);
          if (skill == null) {
            battleData.battleLogger
                .debug('Buff ID [${buff.buff.id}]: ${S.current.skill} [$skillId] ${S.current.not_found}');
            continue;
          }
          battleData.battleLogger.function('$lBattleName - ${buff.buff.lName.l} ${S.current.skill} [$skillId]');
          await FunctionExecutor.executeFunctions(
            battleData,
            skill.functions,
            buff.additionalParam.clamp(1, skill.maxLv),
            script: skill.script,
            isPassive: false,
          );
          buff.setUsed(this);
          activated = true;
        }
      }

      battleData.checkActorStatus();
      return activated;
    });
  }

  int countTrait(final BattleData battleData, final List<NiceTrait> traits) {
    return countAnyTraits(getTraits(battleData), traits);
  }

  int countBuffWithTrait(
    final List<NiceTrait> traits, {
    final bool activeOnly = false,
    final bool ignoreIndivUnreleaseable = false,
    final bool includeIgnoreIndiv = false,
  }) {
    return getBuffsWithTraits(traits,
            activeOnly: activeOnly,
            ignoreIndivUnreleaseable: ignoreIndivUnreleaseable,
            includeIgnoreIndiv: includeIgnoreIndiv)
        .length;
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
      return checkTraitFunction(
        myTraits: buff.traits,
        requiredTraits: traits,
        positiveMatchFunc: partialMatch,
        negativeMatchFunc: partialMatch,
      );
    }).toList();
  }

  List<BuffData> getBuffsOfType(final BuffType buffType) {
    return battleBuff.validBuffs.where((buff) => buff.buff.type == buffType).toList();
  }

  Future<int> getClassRelation(
      final BattleData battleData, final int baseRelation, final BattleServantData other, final bool isTarget) async {
    int relation = baseRelation;
    final List<BuffData> buffs = collectBuffsPerType(battleBuff.validBuffs, BuffType.overwriteClassRelation);
    for (final buff in buffs.reversed) {
      if (await buff.shouldActivateBuff(battleData, this, other)) {
        buff.setUsed(this);
        final relationOverwrite = buff.buff.script.relationId!;
        final overwrite = isTarget
            ? relationOverwrite.defSide2.containsKey(other.classId)
                ? relationOverwrite.defSide2[other.classId]![classId]
                : null
            : relationOverwrite.atkSide2.containsKey(classId)
                ? relationOverwrite.atkSide2[classId]![other.classId]
                : null;
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
    // reversed due to passive of YouZhu (skill seal is added before the add indiv that enables the skill seal)
    battleBuff.getAllBuffs().reversed.forEach((buff) {
      buff.updateActState(battleData, this);
    });
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
    await activateBuffOnAction(battleData, BuffAction.functionEntry);
  }

  Future<void> death(final BattleData battleData) async {
    // TODO: collect buffs and activate each,
    // DataVals.OpponentOnly? revengeOpp : revenge
    if (await activateBuffOnAction(battleData, BuffAction.functionDead)) {
      for (final svt in battleData.nonnullActors) {
        svt.clearReducedHp();
      }
    }

    battleData.fieldBuffs
        .removeWhere((buff) => buff.vals.RemoveFieldBuffActorDeath == 1 && buff.actorUniqueId == uniqueId);
    battleData.battleLogger.action('$lBattleName ${S.current.battle_death}');
  }

  Future<void> startOfMyTurn(final BattleData battleData) async {
    await activateBuffOnAction(battleData, BuffAction.functionSelfturnstart);
  }

  Future<void> endOfMyTurn(final BattleData battleData) async {
    String turnEndLog = '';

    await battleData.withActivator(this, () async {
      await battleData.withTarget(this, () async {
        if (isEnemy) {
          if (!usedNpThisTurn && !isNPSealed() && niceEnemy!.chargeTurn > 0) {
            final turnEndNP = await getBuffValueOnAction(battleData, BuffAction.turnvalNp);
            changeNPLineCount(1 + turnEndNP);

            if (turnEndNP != 0) {
              turnEndLog += ' - NP: $turnEndNP';
            }
          }
        } else {
          final skillSealed = await hasBuffOnAction(battleData, BuffAction.donotSkill);
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
        final turnEndHeal = await getBuffValueOnAction(battleData, BuffAction.turnendHpRegain) +
            getBuffValueForTurnEndHpReduce(battleData, isValueForHeal: true);
        if (turnEndHeal != 0) {
          final healGrantEff = toModifier(await getBuffValueOnAction(battleData, BuffAction.giveGainHp));
          final healReceiveEff = toModifier(await getBuffValueOnAction(battleData, BuffAction.gainHp));
          final finalHeal = (turnEndHeal * healReceiveEff * healGrantEff).toInt();
          await heal(battleData, finalHeal);
          procAccumulationDamage(currentHp);

          turnEndLog += ' - ${S.current.battle_heal} HP: $finalHeal';
        }

        // processing turnEndDamage
        int turnEndDamage = getBuffValueForTurnEndHpReduce(battleData);
        if (turnEndDamage != 0) {
          if (turnEndDamage > currentHp && battleData.isWaveCleared) {
            turnEndDamage = currentHp - 1;
          }
          lossHp(turnEndDamage, lethal: true);
          actionHistory.add(BattleServantActionHistory(
            actType: BattleServantActionHistoryType.reduceHp,
            targetUniqueId: -1,
            isOpponent: false,
          ));
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
        final turnEndStar = await getBuffValueOnAction(battleData, BuffAction.turnendStar);
        if (turnEndStar != 0) {
          battleData.changeStar(turnEndStar);

          turnEndLog += ' - ${S.current.critical_star}: $turnEndStar';
        }

        // processing turnEndNp
        if (isPlayer) {
          final turnEndNP = await getBuffValueOnAction(battleData, BuffAction.turnendNp);
          if (turnEndNP != 0) {
            changeNP(turnEndNP);

            turnEndLog += ' - NP: ${(turnEndNP / 100).toStringAsFixed(2)}%';
          }
        }

        if (turnEndLog.isNotEmpty) {
          battleData.battleLogger.debug('$lBattleName - ${S.current.battle_turn_end}$turnEndLog');
        }

        battleBuff.turnProgress();
      });
    });
    final delayedFunctions = collectBuffsPerType(battleBuff.validBuffs, BuffType.delayFunction);
    await activateBuffOnActionActiveFirst(battleData, BuffAction.functionSelfturnend);
    await activateBuffs(battleData, delayedFunctions.where((buff) => buff.logicTurn == 0));

    battleBuff.turnPassParamAdd();

    battleData.checkActorStatus();
  }

  Future<void> endOfYourTurn(final BattleData battleData) async {
    clearReducedHp();
    attacked = false;

    await battleData.withActivator(this, () async {
      await battleData.withTarget(this, () async {
        battleBuff.turnProgress();
      });
    });

    final delayedFunctions = collectBuffsPerType(battleBuff.validBuffs, BuffType.delayFunction);
    await activateBuffs(battleData, delayedFunctions.where((buff) => buff.logicTurn == 0));
    await activateBuffOnAction(battleData, BuffAction.functionReflection);
    resetAccumulationDamage();

    battleData.checkActorStatus();
  }

  Future<bool> activateGuts(final BattleData battleData) async {
    BuffData? gutsToApply = await battleData.withActivator(this, () async {
      BuffData? gutsToApply;
      final BuffAction gutsActionToCheck = hasNextShift(battleData) ? BuffAction.shiftGuts : BuffAction.guts;
      for (final buff in collectBuffsPerAction(battleBuff.validBuffs, gutsActionToCheck)) {
        if (await buff.shouldActivateGuts(battleData, this)) {
          if (gutsToApply == null || (gutsToApply.irremovable && !buff.irremovable)) {
            gutsToApply = buff;
          }
        }
      }
      return gutsToApply;
    });

    if (gutsToApply != null) {
      gutsToApply.setUsed(this);
      final value = gutsToApply.getValue(battleData, this);
      final isRatio = gutsToApply.buff.type == BuffType.gutsRatio || gutsToApply.buff.type == BuffType.shiftGutsRatio;
      final baseGutsHp = isRatio ? (toModifier(value) * maxHp).floor() : value;
      final gutsHpModifier = toModifier(await getBuffValueOnAction(battleData, BuffAction.gutsHp));
      hp = (baseGutsHp * gutsHpModifier).toInt();
      hp = hp.clamp(1, maxHp);
      clearReducedHp();
      procAccumulationDamage(1); // guts always proc with previousHp = 1

      battleData.battleLogger.action('$lBattleName - ${gutsToApply.buff.lName.l} - '
          '${!isRatio ? value : '${(value / 10).toStringAsFixed(1)}%'}');

      resetLastHits();

      if (await activateBuffOnAction(battleData, BuffAction.functionGuts)) {
        for (final svt in battleData.nonnullActors) {
          svt.clearReducedHp();
        }
      }
      return true;
    }

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
    return BattleServantData._(isPlayer: isPlayer)
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
      ..baseAtk = baseAtk
      ..hp = hp
      .._maxHp = _maxHp
      ..np = np
      ..npLineCount = npLineCount
      ..usedNpThisTurn = usedNpThisTurn
      ..reducedHp = reducedHp
      .._accumulationDamage = _accumulationDamage
      ..skillInfoList = skillInfoList.map((e) => e.copy()).toList() // copy
      ..equip = equip
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
