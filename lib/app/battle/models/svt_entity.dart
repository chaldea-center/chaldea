import 'dart:math';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_exception.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'ai.dart';

class BattleServantData {
  static const npPityThreshold = 9900;
  static List<BuffType> gutsTypes = [BuffType.guts, BuffType.gutsRatio];
  static List<BuffAction> doNotNPTypes = [
    BuffAction.donotNoble,
    BuffAction.donotNobleCondMismatch,
    BuffAction.donotActCommandtype,
  ];
  static List<BuffAction> buffEffectivenessTypes = [BuffAction.buffRate, BuffAction.funcHpReduce];

  final bool isPlayer;
  bool get isEnemy => !isPlayer;
  QuestEnemy? niceEnemy;
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
  int atk = 0;
  int hp = 0;
  int _maxHp = 0;
  set maxHp(final int maxHp) => _maxHp = maxHp;

  int np = 0; // player, np/100
  int npLineCount = 0; // enemy
  bool usedNpThisTurn = false;
  int accumulationDamage = 0;

  // BattleServantData.Status status
  // NiceTd? td;
  // int ascensionPhase = 0;
  List<BattleSkillInfoData> skillInfoList = []; // BattleSkillInfoData, only active skills for now
  BattleCEData? equip;
  BattleBuff battleBuff = BattleBuff();
  List<List<BattleSkillInfoData>> commandCodeSkills = [];

  List<int> shiftNpcIds = [];
  int shiftIndex = 0;
  List<int> changeNpcIds = [];
  int changeIndex = 0;

  bool attacked = false;
  BattleServantData? lastHitBy;
  CommandCardData? lastHitByCard;

  BattleServantData._({required this.isPlayer});

  @override
  String toString() {
    return 'BattleServantData(${fieldIndex + 1}-$lBattleName)';
  }

  factory BattleServantData.fromEnemy(final QuestEnemy enemy, final int uniqueId, {Servant? niceSvt}) {
    final svt = BattleServantData._(isPlayer: false);
    svt
      ..niceEnemy = enemy
      ..svtAi = SvtAiManager(enemy.ai)
      ..niceSvt = niceSvt
      ..uniqueId = uniqueId
      ..hp = enemy.hp
      .._maxHp = enemy.hp
      ..svtId = enemy.svt.id
      ..level = enemy.lv
      ..atk = enemy.atk
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
      ..atk = settings.fixedAtk ?? ((psvt.atkGrowth.getOrNull(settings.lv - 1) ?? 0) + settings.atkFou);
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

  int get attack => isPlayer ? atk + (equip?.atk ?? 0) : atk;

  int get rarity => isPlayer ? niceSvt!.rarity : niceEnemy!.svt.rarity;

  int get classId => isPlayer ? niceSvt!.classId : niceEnemy!.svt.classId;

  Attribute get attribute => isPlayer ? niceSvt!.attribute : niceEnemy!.svt.attribute;

  int get starGen => isPlayer ? niceSvt!.starGen : 0;

  int get defenceNpGain => isPlayer ? playerSvtData?.td?.npGain.defence[playerSvtData!.tdLv - 1] ?? 0 : 0;

  int get enemyTdRate => isEnemy ? niceEnemy!.serverMod.tdRate : 0;

  int get enemyTdAttackRate => isEnemy ? niceEnemy!.serverMod.tdAttackRate : 0;

  int get enemyStarRate => isEnemy ? niceEnemy!.serverMod.starRate : 0;

  bool get isBuggedOverkill => accumulationDamage > hp;

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

  Future<void> initScript(final BattleData battleData) async {
    svtAi = SvtAiManager(niceEnemy?.ai);
    if (battleData.options.simulateAi) {
      await svtAi.fetchAiData();
    }
    if (niceEnemy != null) {
      int dispBreakShift = niceEnemy!.enemyScript.dispBreakShift ?? 0;
      int shiftLength = niceEnemy!.enemyScript.shift?.length ?? 0;
      if (dispBreakShift > 0 && shiftLength > 0) {
        if (dispBreakShift > shiftLength) {
          dispBreakShift = shiftLength;
        }
        shiftIndex = dispBreakShift - 1;
        if (hasNextShift(battleData)) {
          await shift(battleData);
        }
      }
    }
  }

  Future<void> activateClassPassive(final BattleData battleData) async {
    final List<NiceSkill> passives = isPlayer
        ? [...niceSvt!.classPassive]
        : [...niceEnemy!.classPassive.classPassive, ...niceEnemy!.classPassive.addPassive];

    await battleData.withActivator(this, () async {
      for (final skill in passives) {
        final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtPassive);
        await skillInfo.activate(battleData);
      }

      if (isPlayer) {
        for (int index = 0; index < niceSvt!.appendPassive.length; index += 1) {
          final appendLv = playerSvtData!.appendLvs.length > index ? playerSvtData!.appendLvs[index] : 0;
          if (appendLv > 0) {
            final skillInfo = BattleSkillInfoData(niceSvt!.appendPassive[index].skill,
                type: SkillInfoType.svtPassive, skillLv: appendLv);
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
          if (skill.extraPassive.isEmpty ||
              skill.isExtraPassiveEnabledForEvent(battleData.niceQuest?.war?.eventId ?? 0)) {
            final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtPassive);
            await skillInfo.activate(battleData);
          }
        }
      });
    }
  }

  Future<void> activateAdditionalPassive(final BattleData battleData) async {
    if (isPlayer) {
      await battleData.withActivator(this, () async {
        for (int index = 0; index < playerSvtData!.additionalPassives.length; index++) {
          final skill = playerSvtData!.additionalPassives[index];
          final extraPassiveLv = playerSvtData!.additionalPassiveLvs[index];
          final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtPassive, skillLv: extraPassiveLv);
          await skillInfo.activate(battleData);
        }
      });
    }
  }

  String getSkillName(final int index) {
    if (skillInfoList.length <= index || index < 0) {
      return 'Invalid skill index: $index';
    }

    return skillInfoList[index].lName;
  }

  List<CommandCardData> getCards(final BattleData battleData) {
    if (isEnemy) {
      return [];
    }

    final cardDetails = niceSvt!.cardDetails;
    final changeCardType = getFirstBuffOnActions(battleData, [BuffAction.changeCommandCardType]);
    List<CardType> cards = niceSvt!.cards.where((card) => cardDetails.containsKey(card)).toList();
    if (changeCardType != null) {
      cards = List.generate(niceSvt!.cards.length,
          (index) => CardType.values.firstWhere((cardType) => cardType.id == changeCardType.param));
    }
    if (cards.isEmpty) {
      for (final card in [CardType.weak, CardType.strength]) {
        if (cardDetails.containsKey(card)) {
          cards.addAll(List.filled(3, card));
        }
      }
    }

    final List<CommandCardData> builtCards = [];
    for (int i = 0; i < cards.length; i += 1) {
      final cardType = cards[i];
      final detail = niceSvt!.cardDetails[cardType];
      if (detail == null) continue;
      final isCardInDeck = niceSvt!.cards.getOrNull(i) == cardType;
      final card = CommandCardData(cardType, detail)
        ..cardIndex = i
        ..isNP = false
        ..npGain = getNPGain(battleData, cardType)
        ..traits = ConstData.cardInfo[cardType]![1]!.individuality.toList();
      if (isCardInDeck) {
        // enemy weak+strength 6 cards
        card
          ..cardStrengthen = playerSvtData!.cardStrengthens.getOrNull(i) ?? 0
          ..commandCode = playerSvtData!.commandCodes.getOrNull(i);
      }
      if (cardType == CardType.weak) {
        card.isCritical = false;
      } else if (cardType == CardType.strength) {
        card.isCritical = true;
      }

      builtCards.add(card);
    }
    return builtCards;
  }

  int getMaxHp(final BattleData battleData) {
    final addition = getBuffValueOnActionForUI(battleData, BuffAction.maxhpValue);
    final percentAddition = toModifier(getBuffValueOnActionForUI(battleData, BuffAction.maxhpRate) * _maxHp).toInt();

    return _maxHp + addition + percentAddition;
  }

  CommandCardData? getNPCard(final BattleData battleData) {
    if (isEnemy) {
      final _td = niceEnemy!.noblePhantasm.noblePhantasm;
      if (_td == null) return null;
      return CommandCardData(
          _td.card,
          CardDetail(
            attackIndividuality: _td.individuality.toList(),
            hitsDistribution: _td.damage,
            attackType:
                _td.damageType == TdEffectFlag.attackEnemyAll ? CommandCardAttackType.all : CommandCardAttackType.one,
          ))
        ..td = _td
        ..isNP = true
        ..npGain = 0
        ..traits = _td.individuality.toList();
    }

    final currentNP = getCurrentNP(battleData);
    final cardDetail = CardDetail(
      attackIndividuality: currentNP?.individuality ?? [],
      hitsDistribution: currentNP?.svt.damage ?? [100],
      attackType:
          currentNP?.damageType == TdEffectFlag.attackEnemyAll ? CommandCardAttackType.all : CommandCardAttackType.one,
      attackNpRate: currentNP?.npGain.np[playerSvtData!.tdLv - 1] ?? 0,
    );

    return CommandCardData(currentNP?.svt.card ?? CardType.none, cardDetail)
      ..isNP = true
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
    td ??= await showEasyLoading(() => AtlasApi.td(tdId));
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

    return CommandCardData(td.svt.card, cardDetail)
      ..isNP = true
      ..td = td
      ..counterBuff = buff
      ..npGain = td.npGain.np[tdLv - 1]
      ..traits = td.individuality;
  }

  CommandCardData? getExtraCard(final BattleData battleData) {
    if (isEnemy) {
      return null;
    }
    final detail = niceSvt!.cardDetails[CardType.extra];
    if (detail == null) return null;

    return CommandCardData(CardType.extra, detail)
      ..isNP = false
      ..npGain = getNPGain(battleData, CardType.extra)
      ..traits = ConstData.cardInfo[CardType.extra]![1]!.individuality.toList();
  }

  int getNPGain(final BattleData battleData, final CardType cardType) {
    if (!isPlayer) {
      return 0;
    }
    final currentNp = getCurrentNP(battleData);
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
        if (add.idx < 10 || (add.idx > 100 && (add.idx ~/ 100) == eventId)) {
          if (add.limitCount < 0 ||
              add.limitCount == limitCount ||
              add.limitCount == niceSvt?.profile.costume[limitCount]?.battleCharaId) {
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
    buffs.forEach((buff) {
      if (!ignoreIrremovable || !buff.irremovable) {
        myTraits.addAll(buff.traits);
      }
    });

    return myTraits;
  }

  void changeNPLineCount(final int change) {
    if (!isEnemy) {
      return;
    }

    npLineCount += change;
    npLineCount = npLineCount.clamp(0, niceEnemy!.chargeTurn);
  }

  void changeNP(final int change) {
    if (!isPlayer || playerSvtData?.td == null) {
      return;
    }

    np += change;

    np = np.clamp(0, getNPCap(playerSvtData!.tdLv));
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

    gainHp(battleData, heal);
  }

  void gainHp(final BattleData battleData, final int gain) {
    hp += gain;
    hp = hp.clamp(0, getMaxHp(battleData));
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

  void addAccumulationDamage(final int damage) {
    accumulationDamage += damage;
  }

  void clearAccumulationDamage() {
    accumulationDamage = 0;
  }

  bool hasNextShift(final BattleData battleData) {
    return getEnemyShift(battleData) != null;
  }

  QuestEnemy? getEnemyShift(final BattleData battleData) {
    if (isEnemy && shiftNpcIds.isNotEmpty && shiftNpcIds.length > shiftIndex) {
      return battleData.enemyDecks[DeckType.shift]
          ?.firstWhereOrNull((questEnemy) => questEnemy.npcId == shiftNpcIds[shiftIndex]);
    }
    return null;
  }

  Future<void> shift(final BattleData battleData) async {
    final nextShift = getEnemyShift(battleData);
    if (nextShift == null) {
      return;
    }

    niceEnemy = nextShift;
    await initScript(battleData);

    atk = nextShift.atk;
    hp = nextShift.hp;
    _maxHp = nextShift.hp;
    level = nextShift.lv;
    battleBuff.clearPassive(uniqueId);
    shiftIndex += 1;
  }

  Future<void> skillShift(final BattleData battleData, QuestEnemy shiftSvt) async {
    niceEnemy = shiftSvt;
    await initScript(battleData);

    atk = shiftSvt.atk;
    hp = shiftSvt.hp;
    _maxHp = shiftSvt.hp;
    level = shiftSvt.lv;
    battleBuff.clearPassive(uniqueId);
    shiftIndex += 1;
  }

  bool isAlive(final BattleData battleData) {
    if (hp > 0) {
      return true;
    }

    if (hasNextShift(battleData)) {
      return true;
    }

    return battleData.withActivatorSync(this, () {
      return collectBuffsPerTypes(battleBuff.validBuffs, gutsTypes)
          .where((buff) => buff.shouldApplyBuff(battleData, this))
          .isNotEmpty;
    });
  }

  bool isSkillSealed(final BattleData battleData, final int skillIndex) {
    if (skillInfoList.length <= skillIndex || skillIndex < 0) {
      return false;
    }

    final skillInfo = skillInfoList[skillIndex];
    return battleData.withActivatorSync(this, () {
      final rankUp = countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.id)]);
      skillInfo.setRankUp(rankUp);

      return hasDoNotBuffOnActionForUI(battleData, BuffAction.donotSkill);
    });
  }

  bool isCondFailed(final BattleData battleData, final int skillIndex) {
    if (skillInfoList.length <= skillIndex || skillIndex < 0) {
      return false;
    }

    final skillInfo = skillInfoList[skillIndex];
    return battleData.withActivatorSync(this, () {
      final rankUp = countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.id)]);
      skillInfo.setRankUp(rankUp);
      return !canAttack(battleData) || skillInfo.proximateSkill == null || !skillInfo.checkSkillScript(battleData);
    });
  }

  bool canUseSkillIgnoreCoolDown(final BattleData battleData, final int skillIndex) {
    if (skillInfoList.length <= skillIndex || skillIndex < 0) {
      return false;
    }

    final skillInfo = skillInfoList[skillIndex];
    return battleData.withActivatorSync(this, () {
      final rankUp = countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.id)]);
      skillInfo.setRankUp(rankUp);

      return !isSkillSealed(battleData, skillIndex) && !isCondFailed(battleData, skillIndex);
    });
  }

  Future<bool> activateSkill(final BattleData battleData, final int skillIndex) async {
    final skillInfo = skillInfoList.getOrNull(skillIndex);
    if (skillInfo == null || skillInfo.chargeTurn > 0) return false;

    return await battleData.withActivator(this, () async {
      final rankUp = countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.id)]);
      skillInfo.setRankUp(rankUp);

      final activated = await skillInfo.activate(battleData);
      if (activated) {
        battleData.recorder.skill(
          battleData: battleData,
          activator: this,
          skill: skillInfo,
          fromPlayer: true,
          uploadEligible: true,
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

  bool canOrderChange(final BattleData battleData) {
    return battleData.withActivatorSync(this, () {
      return !hasDoNotBuffOnActionForUI(battleData, BuffAction.donotReplace);
    });
  }

  bool canAttack(final BattleData battleData) {
    if (hp <= 0) {
      return false;
    }

    return battleData.withActivatorSync(this, () {
      return !hasDoNotBuffOnActionForUI(battleData, BuffAction.donotAct);
    });
  }

  bool canCommandCard(final BattleData battleData, final CommandCardData card) {
    return battleData.withActivatorSync(this, () {
      return battleData.withCardSync(card, () {
        return canAttack(battleData) && !hasDoNotBuffOnActionForUI(battleData, BuffAction.donotActCommandtype);
      });
    });
  }

  bool canSelectNP(final BattleData battleData) {
    return battleData.withActivatorSync(this, () {
      final currentNp = getCurrentNP(battleData);
      return canNP(battleData) && currentNp != null && currentNp.functions.isNotEmpty && checkNPScript(battleData);
    });
  }

  bool canNP(final BattleData battleData) {
    if (!isNpFull(battleData)) {
      return false;
    }
    return battleData.withActivatorSync(this, () {
      return battleData.withCardSync(getNPCard(battleData), () {
        return canAttack(battleData) && !hasDoNotBuffOnActionsForUI(battleData, doNotNPTypes);
      });
    });
  }

  bool isNpFull(BattleData battleData) {
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
        checkNpScript =
            BattleSkillInfoData.skillScriptConditionCheck(battleData, getCurrentNP(battleData)?.script, tdLv);
      }
      return checkNpScript;
    });
  }

  List<NiceTd> getTdsById(final List<int> tdIds) {
    // TODO: enemy(svt?) doesn't contain type changed TDs and fetch remote TDs
    if (isEnemy) {
      final td = niceEnemy!.noblePhantasm.noblePhantasm;
      return [if (td != null) td];
    }

    final List<NiceTd> result = [];

    for (final td in niceSvt!.noblePhantasms) {
      if (tdIds.contains(td.id)) {
        result.add(td);
      }
    }

    return result;
  }

  NiceTd? getBaseTD() {
    return isPlayer ? playerSvtData!.td : niceEnemy!.noblePhantasm.noblePhantasm;
  }

  NiceTd? getCurrentNP(final BattleData battleData) {
    final buffs = collectBuffsPerAction(battleBuff.validBuffs, BuffAction.tdTypeChange);
    NiceTd? selected;
    for (final buff in buffs.reversed) {
      if (!buff.shouldApplyBuff(battleData, this)) continue;
      if (buff.tdSelection != null) {
        selected = buff.tdSelection!;
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

      final niceTD = getCurrentNP(battleData);
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

        buff.setUsed();
      }
    }

    return updatedFunctions;
  }

  Future<int?> getConfirmationBuffValueOnAction(final BattleData battleData, final BuffAction buffAction) async {
    final actionDetails = ConstData.buffActions[buffAction];
    if (actionDetails == null) {
      return null;
    }

    final opponent = battleData.getOpponent(this);
    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, buffAction)) {
      if (await buff.shouldActivateBuff(battleData, this, opponent)) {
        buff.setUsed();
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
    int maxRate = Maths.min(actionDetails.maxRate);

    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, buffAction)) {
      if (await buff.shouldActivateBuff(battleData, this, opponent)) {
        buff.setUsed();
        final totalEffectiveness = await battleData.withBuff(buff, () async {
          return await getEffectivenessOnAction(battleData, buffAction);
        });

        final value = (toModifier(totalEffectiveness) * buff.getValue(battleData, this, opponent)).toInt();
        if (actionDetails.plusTypes.contains(buff.buff.type)) {
          totalVal += value;
        } else {
          totalVal -= value;
        }
        maxRate = max(maxRate, buff.buff.maxRate);
      }
    }
    return capBuffValue(actionDetails, totalVal, maxRate);
  }

  Future<int> getTurnEndHpReduceValue(final BattleData battleData, {final bool forHeal = false}) async {
    final actionDetails = ConstData.buffActions[BuffAction.turnendHpReduce];
    if (actionDetails == null) {
      return 0;
    }

    final opponent = battleData.getOpponent(this);
    int totalVal = 0;
    int maxRate = Maths.min(actionDetails.maxRate);

    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, BuffAction.turnendHpReduce)) {
      if (await buff.shouldActivateBuff(battleData, this, opponent)) {
        buff.setUsed();
        final totalEffectiveness = await battleData.withBuff(buff, () async {
          return await getEffectivenessOnAction(battleData, BuffAction.turnendHpReduce);
        });
        final toHeal = await battleData.withBuff(buff, () async {
          return await hasBuffOnAction(battleData, BuffAction.turnendHpReduceToRegain);
        });

        final useValue = forHeal == toHeal;
        final value =
            useValue ? (toModifier(totalEffectiveness) * buff.getValue(battleData, this, opponent)).toInt() : 0;

        if (actionDetails.plusTypes.contains(buff.buff.type)) {
          totalVal += value;
        } else {
          totalVal -= value;
        }
        maxRate = max(maxRate, buff.buff.maxRate);
      }
    }
    return capBuffValue(actionDetails, totalVal, maxRate);
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
        buff.setUsed();
        return buff;
      }
    }
    return null;
  }

  /// The following three methods are created to avoid calling async functions when building UI.
  /// These methods should only check buffs that only make sense in terms of turns and not times,
  /// like maxHp, stun, etc., hence no need to check and should not check probability of activation
  ///
  /// An alternative way of implementing tailored execution without these three methods would be to
  /// create dedicated fields to mark these UI related properties and update those at the end of any
  /// action (checkBuffStatus maybe?). However, that would result in a lot of extra properties to
  /// maintain.
  int getBuffValueOnActionForUI(final BattleData battleData, final BuffAction buffAction) {
    final actionDetails = ConstData.buffActions[buffAction];
    final opponent = battleData.getOpponent(this);
    int totalVal = 0;
    int maxRate = Maths.min(actionDetails!.maxRate);

    for (final buff in collectBuffsPerAction(battleBuff.validBuffs, buffAction)) {
      if (buff.shouldApplyBuff(battleData, this, opponent)) {
        buff.setUsed();

        /// should never be called since this is only used for getting maxHp related, so buffAction would never be these
        // battleData.setCurrentBuff(buff);
        // final totalEffectiveness = buffAction == BuffAction.turnendHpReduce
        //     ? getBuffValueOnActionForUI(battleData, BuffAction.funcHpReduce)
        //     : buffAction != BuffAction.buffRate
        //         ? getBuffValueOnActionForUI(battleData, BuffAction.buffRate)
        //         : 1000;
        // battleData.unsetCurrentBuff();
        //
        // final value = (toModifier(totalEffectiveness) * buff.getValue(battleData, isTarget)).toInt();

        final value = buff.getValue(battleData, this, opponent);
        if (actionDetails.plusTypes.contains(buff.buff.type)) {
          totalVal += value;
        } else {
          totalVal -= value;
        }
        maxRate = max(maxRate, buff.buff.maxRate);
      }
    }
    return capBuffValue(actionDetails, totalVal, maxRate);
  }

  bool hasDoNotBuffOnActionForUI(final BattleData battleData, final BuffAction buffAction) {
    return hasDoNotBuffOnActionsForUI(battleData, [buffAction]);
  }

  bool hasDoNotBuffOnActionsForUI(final BattleData battleData, final List<BuffAction> buffActions) {
    for (final buff in collectBuffsPerActions(battleBuff.validBuffs, buffActions)) {
      if (buff.shouldApplyBuff(battleData, this, battleData.getOpponent(this))) {
        buff.setUsed();
        return true;
      }
    }
    return false;
  }

  Future<bool> hasBuffOnAction(final BattleData battleData, final BuffAction buffAction) async {
    return await hasBuffOnActions(battleData, [buffAction]);
  }

  Future<bool> hasBuffOnActions(final BattleData battleData, final List<BuffAction> buffActions) async {
    for (final buff in collectBuffsPerActions(battleBuff.validBuffs, buffActions)) {
      if (await buff.shouldActivateBuff(battleData, this, battleData.getOpponent(this))) {
        buff.setUsed();
        return true;
      }
    }
    return false;
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
        if (await buff.shouldActivateBuff(battleData, this)) {
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
          buff.setUsed();
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

  int countBuffWithTrait(final List<NiceTrait> traits, {final bool activeOnly = false}) {
    return getBuffsWithTraits(traits, activeOnly: activeOnly).length;
  }

  List<BuffData> getBuffsWithTraits(final List<NiceTrait> traits, {final bool activeOnly = false}) {
    final buffList = activeOnly ? battleBuff.getActiveList() : battleBuff.validBuffs;
    return buffList.where((buff) => checkTraitFunction(buff.traits, traits, partialMatch, partialMatch)).toList();
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
        buff.setUsed();
        final relationOverwrite = buff.buff.script!.relationId!;
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
    battleBuff.getAllBuffs().forEach((buff) {
      buff.updateActState(battleData, this);
    });
  }

  void useBuffOnce(final BattleData battleData) {
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
    if (await activateBuffOnAction(battleData, BuffAction.functionDead)) {
      battleData.nonnullActors.forEach((svt) {
        svt.clearAccumulationDamage();
      });
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
          final npSealed = await hasBuffOnActions(battleData, doNotNPTypes);
          if (!usedNpThisTurn && !npSealed && niceEnemy!.chargeTurn > 0) {
            final turnEndNP = await getBuffValueOnAction(battleData, BuffAction.turnvalNp);
            changeNPLineCount(1 + turnEndNP);

            if (turnEndNP != 0) {
              turnEndLog += ' - NP: $turnEndNP';
            }
          }
        } else {
          final skillSealed = await hasBuffOnAction(battleData, BuffAction.donotSkill);
          if (!skillSealed) {
            skillInfoList.forEach((skill) {
              skill.turnEnd();
            });
          }

          commandCodeSkills.forEach((skills) {
            skills.forEach((skill) {
              skill.turnEnd();
            });
          });
        }
        usedNpThisTurn = false;

        int turnEndDamage = await getTurnEndHpReduceValue(battleData);
        if (turnEndDamage != 0) {
          final List<BuffData> preventDeaths = getBuffsOfType(BuffType.preventDeathByDamage);
          turnEndDamage = preventDeaths.any((buff) => buff.shouldApplyBuff(battleData, this, this))
              ? min(hp - 1, turnEndDamage)
              : turnEndDamage;

          receiveDamage(turnEndDamage);
          turnEndLog += ' - dot ${S.current.battle_damage}: $turnEndDamage';
        }

        if (hp <= 0 && hasNextShift(battleData)) {
          hp = 1;
        }

        final turnEndHeal = await getBuffValueOnAction(battleData, BuffAction.turnendHpRegain) +
            await getTurnEndHpReduceValue(battleData, forHeal: true);
        if (turnEndHeal != 0) {
          final healGrantEff = toModifier(await getBuffValueOnAction(battleData, BuffAction.giveGainHp));
          final healReceiveEff = toModifier(await getBuffValueOnAction(battleData, BuffAction.gainHp));
          final finalHeal = (turnEndHeal * healReceiveEff * healGrantEff).toInt();
          await heal(battleData, finalHeal);

          turnEndLog += ' - ${S.current.battle_heal} HP: $finalHeal';
        }

        final turnEndStar = await getBuffValueOnAction(battleData, BuffAction.turnendStar);
        if (turnEndStar != 0) {
          battleData.changeStar(turnEndStar);

          turnEndLog += ' - ${S.current.critical_star}: $turnEndStar';
        }

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
    await activateBuffOnAction(battleData, BuffAction.functionSelfturnend);
    await activateBuffs(battleData, delayedFunctions.where((buff) => buff.logicTurn == 0));

    battleBuff.turnPassParamAdd();

    battleData.checkActorStatus();
  }

  Future<void> endOfYourTurn(final BattleData battleData) async {
    clearAccumulationDamage();
    attacked = false;

    await battleData.withActivator(this, () async {
      await battleData.withTarget(this, () async {
        battleBuff.turnProgress();
      });
    });

    final delayedFunctions = collectBuffsPerType(battleBuff.validBuffs, BuffType.delayFunction);
    await activateBuffs(battleData, delayedFunctions.where((buff) => buff.logicTurn == 0));

    battleData.checkActorStatus();
  }

  Future<bool> activateGuts(final BattleData battleData) async {
    BuffData? gutsToApply = await battleData.withActivator(this, () async {
      BuffData? gutsToApply;
      for (final buff in collectBuffsPerTypes(battleBuff.validBuffs, gutsTypes)) {
        if (await buff.shouldActivateBuff(battleData, this)) {
          if (gutsToApply == null || (gutsToApply.irremovable && !buff.irremovable)) {
            gutsToApply = buff;
          }
        }
      }
      return gutsToApply;
    });

    if (gutsToApply != null) {
      gutsToApply.setUsed();
      final value = gutsToApply.getValue(battleData, this);
      final isRatio = gutsToApply.buff.type == BuffType.gutsRatio;
      if (isRatio) {
        hp = (toModifier(value) * getMaxHp(battleData)).floor();
      } else {
        hp = value;
      }
      hp = hp.clamp(0, getMaxHp(battleData));

      battleData.battleLogger.action('$lBattleName - ${gutsToApply.buff.lName.l} - '
          '${!isRatio ? value : '${(value / 10).toStringAsFixed(1)}%'}');

      lastHitByCard = null;
      lastHitBy = null;

      if (await activateBuffOnAction(battleData, BuffAction.functionGuts)) {
        battleData.nonnullActors.forEach((svt) {
          svt.clearAccumulationDamage();
        });
      }
      return true;
    }

    return false;
  }

  BattleServantData copy() {
    return BattleServantData._(isPlayer: isPlayer)
      ..niceEnemy = niceEnemy
      ..niceSvt = niceSvt
      ..svtAi = svtAi
      ..playerSvtData = playerSvtData?.copy()
      ..fieldIndex = fieldIndex
      ..deckIndex = deckIndex
      ..uniqueId = uniqueId
      ..svtId = svtId
      ..level = level
      ..atk = atk
      ..hp = hp
      .._maxHp = _maxHp
      ..np = np
      ..npLineCount = npLineCount
      ..usedNpThisTurn = usedNpThisTurn
      ..accumulationDamage = accumulationDamage
      ..skillInfoList = skillInfoList.map((e) => e.copy()).toList() // copy
      ..equip = equip
      ..battleBuff = battleBuff.copy()
      ..commandCodeSkills = commandCodeSkills.map((skills) => skills.map((skill) => skill.copy()).toList()).toList()
      ..shiftNpcIds = shiftNpcIds.toList()
      ..shiftIndex = shiftIndex
      ..changeNpcIds = changeNpcIds.toList()
      ..changeIndex = changeIndex; //copy
  }
}
