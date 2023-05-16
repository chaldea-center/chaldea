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

class BattleServantData {
  static const npPityThreshold = 9900;
  static List<BuffType> gutsTypes = [BuffType.guts, BuffType.gutsRatio];
  static List<BuffAction> doNotNPTypes = [BuffAction.donotNoble, BuffAction.donotNobleCondMismatch];
  static List<BuffAction> buffEffectivenessTypes = [BuffAction.buffRate, BuffAction.funcHpReduce];

  QuestEnemy? niceEnemy;
  Servant? niceSvt;
  BasicServant? overrideSvt;
  PlayerSvtData? playerSvtData;

  bool isPlayer = false;
  bool get isEnemy => !isPlayer;

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

  int get limitCount => isPlayer ? playerSvtData!.limitCount : niceEnemy!.limit?.limitCount ?? 0;

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
  int maxHp = 0;
  int np = 0; // player, np/100
  int npLineCount = 0; // enemy
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

  bool get selectable => battleBuff.isSelectable;

  int get tdLv => (isPlayer ? playerSvtData!.tdLv : niceEnemy!.noblePhantasm.noblePhantasmLv).clamp(0, 5);

  int get attack => isPlayer ? atk + (equip?.atk ?? 0) : atk;

  int get rarity => isPlayer ? niceSvt!.rarity : niceEnemy!.svt.rarity;

  SvtClass get svtClass => isPlayer ? niceSvt!.className : niceEnemy!.svt.className;

  int get classId => isPlayer ? niceSvt!.classId : niceEnemy!.svt.classId;

  Attribute get attribute => isPlayer ? niceSvt!.attribute : niceEnemy!.svt.attribute;

  int get starGen => isPlayer ? niceSvt!.starGen : 0;

  int get defenceNpGain => isPlayer ? playerSvtData?.td?.npGain.defence[playerSvtData!.tdLv - 1] ?? 0 : 0;

  int get enemyTdRate => isEnemy ? niceEnemy!.serverMod.tdRate : 0;

  int get enemyTdAttackRate => isEnemy ? niceEnemy!.serverMod.tdAttackRate : 0;

  int get enemyStarRate => isEnemy ? niceEnemy!.serverMod.starRate : 0;

  bool get isBuggedOverkill => accumulationDamage > hp;

  int get deathRate => isEnemy ? niceEnemy!.deathRate : niceSvt!.instantDeathChance;

  static BattleServantData fromEnemy(final QuestEnemy enemy, final int uniqueId) {
    final svt = BattleServantData();
    svt
      ..niceEnemy = enemy
      ..isPlayer = false
      ..uniqueId = uniqueId
      ..hp = enemy.hp
      ..maxHp = enemy.hp
      ..svtId = enemy.svt.id
      ..level = enemy.lv
      ..atk = enemy.atk
      ..deckIndex = enemy.deckId
      ..shiftNpcIds = enemy.enemyScript.shift ?? []
      ..changeNpcIds = enemy.enemyScript.change ?? [];
    return svt;
  }

  static BattleServantData fromPlayerSvtData(final PlayerSvtData settings, final int uniqueId) {
    if (settings.svt == null) {
      throw BattleException('Invalid PlayerSvtData: null svt');
    }

    final svt = BattleServantData();
    svt
      ..playerSvtData = settings.copy()
      ..uniqueId = uniqueId
      ..niceSvt = settings.svt!
      ..isPlayer = true
      ..svtId = settings.svt?.id ?? 0
      ..level = settings.lv
      ..maxHp = settings.fixedHp ?? ((settings.svt!.hpGrowth.getOrNull(settings.lv - 1) ?? 0) + settings.hpFou)
      ..atk = settings.fixedAtk ?? ((settings.svt!.atkGrowth.getOrNull(settings.lv - 1) ?? 0) + settings.atkFou);
    svt.hp = svt.maxHp;
    if (settings.ce != null) {
      svt.equip = BattleCEData(settings.ce!, settings.ceLimitBreak, settings.ceLv);
      svt.hp += svt.equip!.hp;
      svt.maxHp += svt.equip!.hp;
    }

    final script = settings.svt!.script;
    for (final skillNum in kActiveSkillNums) {
      final List<BaseSkill> provisionedSkills = [];
      provisionedSkills.addAll(settings.svt!.groupedActiveSkills[skillNum] ?? []);
      List<BaseSkill?>? rankUps;
      if (script != null && script.skillRankUp != null) {
        rankUps = [
          for (final id in script.skillRankUp![settings.skills[skillNum - 1]?.id] ?? <int>[]) db.gameData.baseSkills[id]
        ];
        if (rankUps.isNotEmpty) {
          provisionedSkills.addAll(rankUps.whereType());
        }
      }

      final skillInfo = BattleSkillInfoData(provisionedSkills, settings.skills[skillNum - 1])
        ..skillLv = settings.skillLvs[skillNum - 1];

      if (rankUps != null) {
        skillInfo.rankUps = rankUps;
      }

      svt.skillInfoList.add(skillInfo);
    }

    for (final commandCode in settings.commandCodes) {
      if (commandCode != null) {
        svt.commandCodeSkills.add(commandCode.skills
            .map((skill) => BattleSkillInfoData([skill], skill, isCommandCode: true)..skillLv = 1)
            .toList());
      } else {
        svt.commandCodeSkills.add([]);
      }
    }
    return svt;
  }

  Future<void> init(final BattleData battleData) async {
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
          return;
        }
      }
    }

    await _init(battleData);
  }

  Future<void> _init(final BattleData battleData) async {
    final List<NiceSkill> passives = isPlayer
        ? [...niceSvt!.classPassive]
        : [...niceEnemy!.classPassive.classPassive, ...niceEnemy!.classPassive.addPassive];

    battleData.setActivator(this);
    for (final skill in passives) {
      await BattleSkillInfoData.activateSkill(battleData, skill, 1, isPassive: true); // passives default to level 1
    }

    if (isPlayer) {
      for (int index = 0; index < niceSvt!.appendPassive.length; index += 1) {
        final appendLv = playerSvtData!.appendLvs.length > index ? playerSvtData!.appendLvs[index] : 0;
        if (appendLv > 0) {
          await BattleSkillInfoData.activateSkill(
            battleData,
            niceSvt!.appendPassive[index].skill,
            appendLv,
            isPassive: true,
          );
        }
      }
      for (final skill in playerSvtData!.extraPassives) {
        if (playerSvtData!.disabledExtraSkills.contains(skill.id)) continue;
        if (skill.isExtraPassiveEnabledForEvent(battleData.niceQuest?.war?.eventId ?? 0)) {
          await BattleSkillInfoData.activateSkill(
            battleData,
            skill,
            1,
            isPassive: true,
          );
        }
      }
      for (int index = 0; index < playerSvtData!.additionalPassives.length; index++) {
        final skill = playerSvtData!.additionalPassives[index];
        final extraPassiveLv = playerSvtData!.additionalPassiveLvs[index];
        await BattleSkillInfoData.activateSkill(
          battleData,
          skill,
          extraPassiveLv,
          isPassive: true,
        );
      }
    }

    await equip?.activateCE(battleData);

    battleData.unsetActivator();
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
    final percentAddition = toModifier(getBuffValueOnActionForUI(battleData, BuffAction.maxhpRate) * maxHp).toInt();

    return maxHp + addition + percentAddition;
  }

  CommandCardData? getNPCard(final BattleData battleData) {
    if (isEnemy) {
      return null;
    }

    final currentNP = getCurrentNP(battleData);
    final cardDetail = CardDetail(
      attackIndividuality: currentNP?.individuality ?? [],
      hitsDistribution: currentNP?.npDistribution ?? [100],
      attackType:
          currentNP?.damageType == TdEffectFlag.attackEnemyAll ? CommandCardAttackType.all : CommandCardAttackType.one,
      attackNpRate: currentNP?.npGain.np[playerSvtData!.tdLv - 1] ?? 0,
    );

    return CommandCardData(currentNP?.card ?? CardType.none, cardDetail)
      ..isNP = true
      ..npGain = currentNP?.npGain.np[playerSvtData!.tdLv - 1] ?? 0
      ..traits = currentNP?.individuality ?? [];
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
          traits.addAll(add.trait);
        }
      }
    }
    return traits.toList();
  }

  List<NiceTrait> getTraits(final BattleData battleData) {
    final List<NiceTrait> allTraits = [];
    allTraits.addAll(getBasicSvtTraits(eventId: battleData.niceQuest?.war?.eventId));

    final List<int> removeTraitIds = [];
    battleData.setActivator(this);
    for (final buff in battleBuff.allBuffs) {
      if (buff.buff.type == BuffType.addIndividuality && buff.shouldApplyBuff(battleData, false)) {
        allTraits.add(NiceTrait(id: buff.param));
      } else if (buff.buff.type == BuffType.subIndividuality && buff.shouldApplyBuff(battleData, false)) {
        removeTraitIds.add(buff.param);
      }
    }
    battleData.unsetActivator();

    allTraits.removeWhere((trait) => removeTraitIds.contains(trait.id));

    return allTraits;
  }

  List<NiceTrait> getBuffTraits(
    final BattleData battleData, {
    final bool activeOnly = false,
    final bool ignoreIrremovable = false,
  }) {
    final List<NiceTrait> myTraits = [];
    final List<BuffData> buffs = activeOnly ? battleBuff.activeList : battleBuff.allBuffs;
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

    atk = nextShift.atk;
    hp = nextShift.hp;
    maxHp = nextShift.hp;
    level = nextShift.lv;
    battleBuff.clearPassive(uniqueId);

    await _init(battleData);
    shiftIndex += 1;
  }

  Future<void> skillShift(final BattleData battleData, QuestEnemy shiftSvt) async {
    niceEnemy = shiftSvt;

    atk = shiftSvt.atk;
    hp = shiftSvt.hp;
    maxHp = shiftSvt.hp;
    level = shiftSvt.lv;
    battleBuff.clearPassive(uniqueId);

    await _init(battleData);
    shiftIndex += 1;
  }

  bool isAlive(final BattleData battleData) {
    if (hp > 0) {
      return true;
    }

    if (hasNextShift(battleData)) {
      return true;
    }

    battleData.setActivator(this);
    final result = collectBuffsPerTypes(battleBuff.allBuffs, gutsTypes)
        .where((buff) => buff.shouldApplyBuff(battleData, false))
        .isNotEmpty;
    battleData.unsetActivator();
    return result;
  }

  bool isSkillSealed(final BattleData battleData, final int skillIndex) {
    if (skillInfoList.length <= skillIndex || skillIndex < 0) {
      return false;
    }

    final skillInfo = skillInfoList[skillIndex];
    battleData.setActivator(this);
    final rankUp = countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.id)]);
    skillInfo.setRankUp(rankUp);

    final result = !canAttack(battleData) || hasDoNotBuffOnActionForUI(battleData, BuffAction.donotSkill);
    battleData.unsetActivator();
    return result;
  }

  bool isCondFailed(final BattleData battleData, final int skillIndex) {
    if (skillInfoList.length <= skillIndex || skillIndex < 0) {
      return false;
    }

    final skillInfo = skillInfoList[skillIndex];
    battleData.setActivator(this);
    final rankUp = countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.id)]);
    skillInfo.setRankUp(rankUp);

    final result = skillInfo.proximateSkill == null || !skillInfo.checkSkillScript(battleData);
    battleData.unsetActivator();
    return result;
  }

  bool canUseSkillIgnoreCoolDown(final BattleData battleData, final int skillIndex) {
    if (skillInfoList.length <= skillIndex || skillIndex < 0) {
      return false;
    }

    final skillInfo = skillInfoList[skillIndex];
    battleData.setActivator(this);
    final rankUp = countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.id)]);
    skillInfo.setRankUp(rankUp);

    final result = !isSkillSealed(battleData, skillIndex) && !isCondFailed(battleData, skillIndex);
    battleData.unsetActivator();
    return result;
  }

  Future<bool> activateSkill(final BattleData battleData, final int skillIndex) async {
    final skillInfo = skillInfoList[skillIndex];
    battleData.setActivator(this);
    final rankUp = countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.id)]);
    skillInfo.setRankUp(rankUp);

    final activated = await skillInfo.activate(battleData);
    if (activated) {
      battleData.recorder.skill(
          battleData: battleData, activator: this, skill: skillInfo, type: SkillInfoType.svtSelf, fromPlayer: true);
    }
    battleData.unsetActivator();
    return activated;
  }

  Future<void> activateCommandCode(final BattleData battleData, final int cardIndex) async {
    if (cardIndex < 0 || commandCodeSkills.length <= cardIndex) {
      return;
    }

    battleData.setActivator(this);
    for (final skill in commandCodeSkills[cardIndex]) {
      battleData.battleLogger.action('$lBattleName - ${S.current.command_code}: ${skill.lName}');
      await skill.activate(battleData);
    }
    battleData.unsetActivator();
  }

  bool canOrderChange(final BattleData battleData) {
    battleData.setActivator(this);
    final result = !hasDoNotBuffOnActionForUI(battleData, BuffAction.donotReplace);
    battleData.unsetActivator();
    return result;
  }

  bool canAttack(final BattleData battleData) {
    if (hp <= 0) {
      return false;
    }

    battleData.setActivator(this);
    final result = !hasDoNotBuffOnActionForUI(battleData, BuffAction.donotAct);
    battleData.unsetActivator();
    return result;
  }

  bool canCommandCard(final BattleData battleData) {
    battleData.setActivator(this);
    final result = canAttack(battleData) && !hasDoNotBuffOnActionForUI(battleData, BuffAction.donotActCommandtype);
    battleData.unsetActivator();
    return result;
  }

  bool canSelectNP(final BattleData battleData) {
    battleData.setActivator(this);
    final currentNp = getCurrentNP(battleData);
    final result =
        canNP(battleData) && currentNp != null && currentNp.functions.isNotEmpty && checkNPScript(battleData);
    battleData.unsetActivator();
    return result;
  }

  bool canNP(final BattleData battleData) {
    if (!isNpFull(battleData)) {
      return false;
    }
    battleData.setActivator(this);
    final result = canAttack(battleData) && !hasDoNotBuffOnActionsForUI(battleData, doNotNPTypes);
    battleData.unsetActivator();
    return result;
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
    battleData.setActivator(this);
    if (isPlayer) {
      return BattleSkillInfoData.skillScriptConditionCheck(battleData, getCurrentNP(battleData)?.script, tdLv);
    }
    battleData.unsetActivator();
    return true;
  }

  List<NiceTd> getTdsById(final List<int> tdIds) {
    // TODO: enemy(svt?) doesn't contain type changed TDs and fetch remote TDs
    if (isEnemy) {
      return [niceEnemy!.noblePhantasm.noblePhantasm!];
    }

    final List<NiceTd> result = [];

    for (final td in niceSvt!.noblePhantasms) {
      if (tdIds.contains(td.id)) {
        result.add(td);
      }
    }

    return result;
  }

  NiceTd? getCurrentNP(final BattleData battleData) {
    final buffs = collectBuffsPerAction(battleBuff.allBuffs, BuffAction.tdTypeChange);
    battleData.setActivator(this);
    for (final buff in buffs.reversed) {
      if (buff.tdSelection != null && buff.shouldApplyBuff(battleData, false)) {
        return buff.tdSelection!;
      }
    }
    battleData.unsetActivator();

    return isPlayer ? playerSvtData!.td : niceEnemy!.noblePhantasm.noblePhantasm;
  }

  Future<void> activateNP(final BattleData battleData, final int extraOverchargeLvl) async {
    battleData.setActivator(this);
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

      np = 0;
      npLineCount = 0;
      await FunctionExecutor.executeFunctions(battleData, niceTD.functions, tdLv, overchargeLvl: overchargeLvl);
    }

    battleData.unsetActivator();
  }

  Future<int?> getConfirmationBuffValueOnAction(final BattleData battleData, final BuffAction buffAction) async {
    final actionDetails = ConstData.buffActions[buffAction];
    if (actionDetails == null) {
      return null;
    }
    final isTarget = battleData.target == this;

    for (final buff in collectBuffsPerAction(battleBuff.allBuffs, buffAction)) {
      if (await buff.shouldActivateBuff(battleData, isTarget)) {
        buff.setUsed();
        final value = buff.getValue(battleData, isTarget);
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

    final isTarget = battleData.target == this;
    int totalVal = 0;
    int maxRate = Maths.min(actionDetails.maxRate);

    for (final buff in collectBuffsPerAction(battleBuff.allBuffs, buffAction)) {
      if (await buff.shouldActivateBuff(battleData, isTarget)) {
        buff.setUsed();
        battleData.setCurrentBuff(buff);
        final totalEffectiveness = await getEffectivenessOnAction(battleData, buffAction);
        battleData.unsetCurrentBuff();

        final value = (toModifier(totalEffectiveness) * buff.getValue(battleData, isTarget)).toInt();
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

    final isTarget = battleData.target == this;
    int totalVal = 0;
    int maxRate = Maths.min(actionDetails.maxRate);

    for (final buff in collectBuffsPerAction(battleBuff.allBuffs, BuffAction.turnendHpReduce)) {
      if (await buff.shouldActivateBuff(battleData, isTarget)) {
        buff.setUsed();
        battleData.setCurrentBuff(buff);
        final totalEffectiveness = await getEffectivenessOnAction(battleData, BuffAction.turnendHpReduce);
        final toHeal = await hasBuffOnAction(battleData, BuffAction.turnendHpReduceToRegain);
        battleData.unsetCurrentBuff();

        final useValue = forHeal == toHeal;
        final value = useValue ? (toModifier(totalEffectiveness) * buff.getValue(battleData, isTarget)).toInt() : 0;

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
    final isTarget = battleData.target == this;

    for (final buff in collectBuffsPerActions(battleBuff.allBuffs, buffActions)) {
      if (buff.shouldApplyBuff(battleData, isTarget)) {
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
    final isTarget = battleData.target == this;
    int totalVal = 0;
    int maxRate = Maths.min(actionDetails!.maxRate);

    for (final buff in collectBuffsPerAction(battleBuff.allBuffs, buffAction)) {
      if (buff.shouldApplyBuff(battleData, isTarget)) {
        buff.setUsed();
        battleData.setCurrentBuff(buff);
        final totalEffectiveness = buffAction == BuffAction.turnendHpReduce
            ? getBuffValueOnActionForUI(battleData, BuffAction.funcHpReduce)
            : buffAction != BuffAction.buffRate
                ? getBuffValueOnActionForUI(battleData, BuffAction.buffRate)
                : 1000;
        battleData.unsetCurrentBuff();

        final value = (toModifier(totalEffectiveness) * buff.getValue(battleData, isTarget)).toInt();
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
    final isTarget = battleData.target == this;

    for (final buff in collectBuffsPerActions(battleBuff.allBuffs, buffActions)) {
      if (buff.shouldApplyBuff(battleData, isTarget)) {
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
    final isTarget = battleData.target == this;

    for (final buff in collectBuffsPerActions(battleBuff.allBuffs, buffActions)) {
      if (await buff.shouldActivateBuff(battleData, isTarget)) {
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
    return await activateBuffs(battleData, collectBuffsPerActions(battleBuff.allBuffs, buffActions));
  }

  Future<bool> activateBuffs(final BattleData battleData, final Iterable<BuffData> buffs) async {
    battleData.setActivator(this);

    bool activated = false;
    for (final buff in buffs.toList()) {
      if (await buff.shouldActivateBuff(battleData, false)) {
        final skillId = buff.param;
        BaseSkill? skill = db.gameData.baseSkills[skillId];
        skill ??= await showEasyLoading(() => AtlasApi.skill(skillId));
        if (skill == null) {
          battleData.battleLogger
              .debug('Buff ID [${buff.buff.id}]: ${S.current.skill} [$skillId] ${S.current.not_found}');
          continue;
        }

        battleData.battleLogger.function('$lBattleName - ${buff.buff.lName.l} ${S.current.skill} [$skillId]');
        await BattleSkillInfoData.activateSkill(battleData, skill, buff.additionalParam);
        buff.setUsed();
        activated = true;
      }
    }

    battleData.unsetActivator();

    battleData.checkBuffStatus();
    return activated;
  }

  void removeBuffWithTrait(final NiceTrait trait) {
    battleBuff.activeList.removeWhere((buff) => containsAnyTraits(buff.traits, [trait]));
  }

  int countTrait(final BattleData battleData, final List<NiceTrait> traits) {
    return countAnyTraits(getTraits(battleData), traits);
  }

  int countBuffWithTrait(final List<NiceTrait> traits, {final bool activeOnly = false}) {
    return getBuffsWithTraits(traits, activeOnly: activeOnly).length;
  }

  List<BuffData> getBuffsWithTraits(final List<NiceTrait> traits, {final bool activeOnly = false}) {
    final buffList = activeOnly ? battleBuff.activeList : battleBuff.allBuffs;
    return buffList.where((buff) => containsAnyTraits(buff.traits, traits)).toList();
  }

  List<BuffData> getBuffsOfType(final BuffType buffType) {
    return battleBuff.allBuffs.where((buff) => buff.buff.type == buffType).toList();
  }

  Future<int> getClassRelation(
    final BattleData battleData,
    final int baseRelation,
    final SvtClass opponentClass,
    final isTarget,
  ) async {
    int relation = baseRelation;
    final List<BuffData> buffs = collectBuffsPerType(battleBuff.allBuffs, BuffType.overwriteClassRelation);
    for (final buff in buffs.reversed) {
      if (await buff.shouldActivateBuff(battleData, isTarget)) {
        buff.setUsed();
        final relationOverwrite = buff.buff.script!.relationId!;
        final overwrite = isTarget
            ? relationOverwrite.defSide.containsKey(opponentClass)
                ? relationOverwrite.defSide[opponentClass]![svtClass]
                : null
            : relationOverwrite.atkSide.containsKey(svtClass)
                ? relationOverwrite.atkSide[svtClass]![opponentClass]
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
    return battleBuff.allBuffs.every((buff) => buff.canStack(buffGroup));
  }

  void addBuff(final BuffData buffData, {final bool isPassive = false, final bool isCommandCode = false}) {
    if (isCommandCode) {
      battleBuff.commandCodeList.add(buffData);
    } else if (isPassive) {
      battleBuff.passiveList.add(buffData);
    } else {
      battleBuff.activeList.add(buffData);
    }
  }

  void clearCommandCodeBuffs() {
    battleBuff.commandCodeList.clear();
  }

  void checkBuffStatus(final BattleData battleData) {
    battleBuff.allBuffs.forEach((buff) {
      if (buff.isUsed) {
        buff.useOnce();
      }

      if (buff.buff.script?.INDIVIDUALITIE != null) {
        buff.individualitiesActive = battleData.checkTraits(CheckTraitParameters(
          requiredTraits: [buff.buff.script!.INDIVIDUALITIE!],
          actor: this,
          checkActorTraits: true,
          checkActorBuffTraits: true,
          checkQuestTraits: true,
        ));
      }
    });

    battleBuff.passiveList.removeWhere((buff) => !buff.isActive);
    battleBuff.activeList.removeWhere((buff) => !buff.isActive);
    battleBuff.commandCodeList.removeWhere((buff) => !buff.isActive);
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

    battleData.setActivator(this);
    battleData.setTarget(this);
    if (isEnemy) {
      final npSealed = await hasBuffOnActions(battleData, doNotNPTypes);
      if (!npSealed && niceEnemy!.chargeTurn > 0) {
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

    int turnEndDamage = await getTurnEndHpReduceValue(battleData);
    if (turnEndDamage != 0) {
      final List<BuffData> preventDeaths = getBuffsOfType(BuffType.preventDeathByDamage);
      turnEndDamage = preventDeaths.any((buff) => buff.shouldApplyBuff(battleData, true))
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

    battleData.unsetTarget();
    battleData.unsetActivator();

    final delayedFunctions = collectBuffsPerType(battleBuff.allBuffs, BuffType.delayFunction);
    await activateBuffOnAction(battleData, BuffAction.functionSelfturnend);
    await activateBuffs(battleData, delayedFunctions.where((buff) => buff.logicTurn == 0));

    battleBuff.turnPassParamAdd();

    battleData.checkBuffStatus();
  }

  Future<void> endOfYourTurn(final BattleData battleData) async {
    clearAccumulationDamage();
    attacked = false;

    battleData.setActivator(this);
    battleData.setTarget(this);

    battleBuff.turnProgress();

    battleData.unsetTarget();
    battleData.unsetActivator();

    final delayedFunctions = collectBuffsPerType(battleBuff.allBuffs, BuffType.delayFunction);
    await activateBuffs(battleData, delayedFunctions.where((buff) => buff.logicTurn == 0));

    battleData.checkBuffStatus();
  }

  Future<bool> activateGuts(final BattleData battleData) async {
    BuffData? gutsToApply;
    battleData.setActivator(this);
    for (final buff in collectBuffsPerTypes(battleBuff.allBuffs, gutsTypes)) {
      if (await buff.shouldActivateBuff(battleData, false)) {
        if (gutsToApply == null || (gutsToApply.irremovable && !buff.irremovable)) {
          gutsToApply = buff;
        }
      }
    }
    battleData.unsetActivator();

    if (gutsToApply != null) {
      gutsToApply.setUsed();
      final value = gutsToApply.getValue(battleData, false);
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
    return BattleServantData()
      ..niceEnemy = niceEnemy
      ..niceSvt = niceSvt
      ..isPlayer = isPlayer
      ..playerSvtData = playerSvtData?.copy()
      ..fieldIndex = fieldIndex
      ..deckIndex = deckIndex
      ..uniqueId = uniqueId
      ..svtId = svtId
      ..level = level
      ..atk = atk
      ..hp = hp
      ..maxHp = maxHp
      ..np = np
      ..npLineCount = npLineCount
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
