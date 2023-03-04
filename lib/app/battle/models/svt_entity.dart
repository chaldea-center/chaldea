import 'dart:math';

import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/command_card.dart';
import 'package:chaldea/app/battle/models/craft_essence_entity.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/basic.dart';
import 'buff.dart';
import 'card_dmg.dart';
import 'skill.dart';

class BattleServantData {
  static const npPityThreshold = 9900;
  static List<BuffType> gutsTypes = [BuffType.guts, BuffType.gutsRatio];
  static List<BuffAction> doNotNPTypes = [BuffAction.donotNoble, BuffAction.donotNobleCondMismatch];
  static List<BuffAction> buffEffectivenessTypes = [BuffAction.buffRate, BuffAction.funcHpReduce];

  QuestEnemy? niceEnemy;
  Servant? niceSvt;

  bool get isPlayer => niceSvt != null;

  bool get isEnemy => niceEnemy != null;

  String get name => isPlayer ? niceSvt!.battleName : niceEnemy!.lShownName;

  //
  int index = 0;
  int deckIndex = -1;
  int uniqueId = 0;
  int svtId = -1;
  int exceedCount = 0;
  int limitCount = 0;
  int transformSvtId = -1;
  int transformIndex = -1;
  int totalDamage = 0;
  Servant? svtData;
  int level = 0;
  int maxLevel = 0;
  int atk = 0;
  dynamic followerType; // none/friend/non_friend/npc/npc_no_td
  int hp = 0;
  int maxHp = 0;
  int maxActNum = 0;
  int np = 0;
  int npLineCount = 0;
  int lineMaxNp = 100;
  int tmpNp = 0;
  int equipAtk = 0;
  int equipHp = 0;
  int maxTpTurn = 0;
  int nextTpTurn = 0;
  int downStarRate = 0;
  int downTdRate = 0;
  int deathRate = 0;
  int svtType = 0; //displayType, npcSvtType;
  int criticalRate = 0;
  int reducedHp = 0;
  int restAttackCount = 0;
  int overkillTargetId = 0;
  int accumulationDamage = 0;
  int resultHp = 0;

  // BattleServantData.Status status
  List<int> userCommandCodeIds = [];
  List<int> svtIndividuality = [];
  List<BattleSkillInfoData> skillInfoList = []; // BattleSkillInfoData, only active skills for now
  int tdId = 0;
  int tdLv = 0;
  BattleCEData? equip;
  BattleBuff battleBuff = BattleBuff();
  int shiftIndex = 0;
  bool attacked = false;
  BattleServantData? killedBy;
  CommandCardData? killedByCard;
  List<List<BuffData>> commandCodeBuffs = [[], [], [], [], []];

  PlayerSvtData? playerSvtData;

  bool get selectable => battleBuff.isSelectable;

  int get attack => isPlayer ? atk + (equip?.atk ?? 0) : atk;

  SvtClass get svtClass => isPlayer ? niceSvt!.className : niceEnemy!.svt.className;

  Attribute get attribute => isPlayer ? niceSvt!.attribute : niceEnemy!.svt.attribute;

  int get starGen => isPlayer ? niceSvt!.starGen : 0;

  int get defenceNpGain =>
      isPlayer ? niceSvt!.noblePhantasms[playerSvtData!.npStrengthenLv - 1].npGain.defence[playerSvtData!.npLv - 1] : 0;

  int get enemyTdRate => isEnemy ? niceEnemy!.serverMod.tdRate : 0;

  int get enemyTdAttackRate => isEnemy ? niceEnemy!.serverMod.tdAttackRate : 0;

  int get enemyStarRate => isEnemy ? niceEnemy!.serverMod.starRate : 0;

  bool get isBuggedOverkill => accumulationDamage > hp;

  static BattleServantData fromEnemy(final QuestEnemy enemy) {
    final svt = BattleServantData();
    svt
      ..niceEnemy = enemy
      ..hp = enemy.hp
      ..maxHp = enemy.hp
      ..uniqueId = enemy.uniqueId
      ..svtId = enemy.svt.id
      ..limitCount = enemy.limit?.limitCount ?? 0
      ..level = enemy.lv
      ..atk = enemy.atk
      ..deathRate = enemy.deathRate
      ..downTdRate = enemy.serverMod.tdRate;
    // TODO (battle): build enemy active skills & cards & NP
    return svt;
  }

  static BattleServantData fromPlayerSvtData(final PlayerSvtData settings) {
    final svtData = db.gameData.servantsById[settings.svtId]!;

    final svt = BattleServantData();
    svt
      ..playerSvtData = settings
      ..niceSvt = svtData
      ..hp = svtData.hpGrowth[settings.lv - 1] + settings.hpFou
      ..maxHp = svtData.hpGrowth[settings.lv - 1] + settings.hpFou
      ..atk = svtData.atkGrowth[settings.lv - 1] + settings.atkFou;

    final ceData = db.gameData.craftEssencesById[settings.ceId];
    if (ceData != null) {
      svt.equip = BattleCEData(ceData, settings.ceLimitBreak, settings.ceLv);
      svt.hp += svt.equip!.hp;
      svt.maxHp += svt.equip!.hp;
    }

    for (int i = 0; i <= settings.skillStrengthenLvs.length; i += 1) {
      if (svtData.groupedActiveSkills.length > i) {
        svt.skillInfoList.add(BattleSkillInfoData(svtData.groupedActiveSkills[i][settings.skillStrengthenLvs[i] - 1])
          ..skillLv = settings.skillLvs[i]
          ..strengthStatus = settings.skillStrengthenLvs[i]);
      }
    }

    // TODO (battle): initialize commandCodes
    return svt;
  }

  void init(final BattleData battleData) {
    final List<NiceSkill> passives = isPlayer
        ? [...niceSvt!.classPassive, ...niceSvt!.extraPassive]
        : [...niceEnemy!.classPassive.classPassive, ...niceEnemy!.classPassive.addPassive];

    battleData.setActivator(this);
    for (final skill in passives) {
      BattleSkillInfoData.activateSkill(battleData, skill, 1, isPassive: true); // passives default to level 1
    }

    if (isPlayer) {
      for (int i = 0; i < niceSvt!.appendPassive.length; i += 1) {
        final appendLv = playerSvtData!.appendLvs.length > i ? playerSvtData!.appendLvs[i] : 0;
        if (appendLv > 0) {
          BattleSkillInfoData.activateSkill(battleData, niceSvt!.appendPassive[i].skill, appendLv);
        }
      }
    }

    equip?.activateCE(battleData);

    battleData.unsetActivator();
  }

  List<CommandCardData> getCards() {
    if (isEnemy) {
      return [];
    }

    final List<CommandCardData> builtCards = [];
    for (int i = 0; i < niceSvt!.cards.length; i += 1) {
      final cardType = niceSvt!.cards[i];
      final card = CommandCardData(cardType, niceSvt!.cardDetails[cardType]!)
        ..isNP = false
        ..cardStrengthen = playerSvtData!.cardStrengthens[i]
        ..npGain = getNPGain(cardType)
        ..traits = [mapCardTypeToTrait(cardType), NiceTrait(id: Trait.faceCard.id)]
        ..commandCodeBuffs = commandCodeBuffs[i];
      builtCards.add(card);
    }
    return builtCards;
  }

  CommandCardData? getNPCard() {
    if (isEnemy) {
      return null;
    }

    final currentNP = getCurrentNP();
    final cardDetail = CardDetail(
      attackIndividuality: currentNP.individuality,
      hitsDistribution: currentNP.npDistribution,
      attackType:
          currentNP.damageType == TdEffectFlag.attackEnemyAll ? CommandCardAttackType.all : CommandCardAttackType.one,
      attackNpRate: currentNP.npGain.np[playerSvtData!.npLv - 1],
    );

    return CommandCardData(currentNP.card, cardDetail)
      ..isNP = true
      ..npGain = currentNP.npGain.np[playerSvtData!.npLv - 1]
      ..traits = currentNP.individuality;
  }

  CommandCardData? getExtraCard() {
    if (isEnemy) {
      return null;
    }

    return CommandCardData(CardType.extra, niceSvt!.cardDetails[CardType.extra]!)
      ..isNP = false
      ..npGain = getNPGain(CardType.extra)
      ..traits = [mapCardTypeToTrait(CardType.extra), NiceTrait(id: Trait.faceCard.id)];
  }

  static NiceTrait mapCardTypeToTrait(final CardType cardType) {
    switch (cardType) {
      case CardType.buster:
        return NiceTrait(id: Trait.cardBuster.id);
      case CardType.arts:
        return NiceTrait(id: Trait.cardArts.id);
      case CardType.quick:
        return NiceTrait(id: Trait.cardQuick.id);
      case CardType.extra:
        return NiceTrait(id: Trait.cardExtra.id);
      case CardType.weak:
        return NiceTrait(id: Trait.cardWeak.id);
      case CardType.strength:
        return NiceTrait(id: Trait.cardStrong.id);
      case CardType.none:
      case CardType.blank:
        throw 'Invalid Card Type: $cardType';
    }
  }

  int getNPGain(final CardType cardType) {
    if (!isPlayer) {
      return 0;
    }
    switch (cardType) {
      case CardType.buster:
        return getCurrentNP().npGain.buster[playerSvtData!.npLv - 1];
      case CardType.arts:
        return getCurrentNP().npGain.arts[playerSvtData!.npLv - 1];
      case CardType.quick:
        return getCurrentNP().npGain.quick[playerSvtData!.npLv - 1];
      case CardType.extra:
        return getCurrentNP().npGain.extra[playerSvtData!.npLv - 1];
      default:
        return 0;
    }
  }

  List<NiceTrait> getTraits() {
    // TODO (battle): account for add & remove traits
    final List<NiceTrait> results = [];
    final svtTraits = isPlayer ? niceSvt!.traits : niceEnemy!.traits;
    results.addAll(svtTraits);
    return results;
  }

  bool checkTrait(final NiceTrait requiredTrait) {
    return checkTraits([requiredTrait]);
  }

  bool checkTraits(final Iterable<NiceTrait> requiredTraits) {
    return containsAllTraits(getTraits(), requiredTraits) || battleBuff.checkTraits(requiredTraits);
  }

  void changeNP(final int change) {
    if (!isPlayer) {
      return;
    }

    np += change;

    np.clamp(0, getNPCap(playerSvtData!.npLv));
    if (change > 0 && np > npPityThreshold) {
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
    return activator != null && currentCard != null && killedBy == activator && killedByCard == currentCard;
  }

  void heal(final int heal) {
    hp += heal;
    hp.clamp(0, maxHp);
  }

  void receiveDamage(final int hitDamage) {
    hp -= hitDamage;
  }

  void addAccumulationDamage(final int damage) {
    attacked = true;
    accumulationDamage += damage;
  }

  void clearAccumulationDamage() {
    attacked = false;
    accumulationDamage = 0;
  }

  bool hasNextShift() {
    if (isPlayer) {
      return false;
    }

    return niceEnemy!.enemyScript.shift != null && niceEnemy!.enemyScript.shift!.length > shiftIndex;
  }

  void shift(final BattleData battleData) {
    // TODO (battle): enemy shift
  }

  bool isAlive() {
    if (hp > 0) {
      return true;
    }

    if (hasNextShift()) {
      return true;
    }

    // TODO (battle): check for conditional guts?
    return collectBuffsPerTypes(battleBuff.allBuffs, gutsTypes).isNotEmpty;
  }

  bool canActivateSkill(final BattleData battleData, final int skillIndex) {
    // TODO (battle): skill specific check
    return canAttack(battleData) &&
        !hasBuffOnAction(battleData, BuffAction.donotSkill) &&
        skillInfoList[skillIndex].chargeTurn == 0;
  }

  void activateSkill(final BattleData battleData, final int skillIndex) {
    battleData.setActivator(this);
    skillInfoList[skillIndex].activate(battleData);
    battleData.unsetActivator();
  }

  bool canAttack(final BattleData battleData) {
    if (hp <= 0) {
      return false;
    }

    return !hasBuffOnAction(battleData, BuffAction.donotAct);
  }

  bool canCommandCard(final BattleData battleData) {
    return canAttack(battleData) && !hasBuffOnAction(battleData, BuffAction.donotActCommandtype);
  }

  bool canNP(final BattleData battleData) {
    if ((isPlayer && np < ConstData.constants.fullTdPoint) ||
        (isEnemy && (npLineCount < niceEnemy!.chargeTurn || niceEnemy!.chargeTurn == 0))) {
      return false;
    }

    return canAttack(battleData) && !hasBuffOnActions(battleData, doNotNPTypes) && checkNPScript(battleData);
  }

  bool checkNPScript(final BattleData battleData) {
    if (isPlayer) {
      final currentNP = niceSvt!.noblePhantasms[playerSvtData!.npStrengthenLv - 1];
      // TODO (battle): check script
    } else {
      final currentNP = niceEnemy!.noblePhantasm;
    }
    return true;
  }

  NiceTd getCurrentNP() {
    return isPlayer
        ? niceSvt!.noblePhantasms[playerSvtData!.npStrengthenLv - 1]
        : niceEnemy!.noblePhantasm.noblePhantasm!;
  }

  void activateNP(final BattleData battleData, final int extraOverchargeLvl) {
    battleData.setActivator(this);

    // TODO (battle): account for OC buff
    final overchargeLvl = isPlayer ? (np / ConstData.constants.fullTdPoint).floor() + extraOverchargeLvl : 1;

    final npLvl = isPlayer ? playerSvtData!.npLv : niceEnemy!.noblePhantasm.noblePhantasmLv;

    np = 0;
    npLineCount = 0;

    for (final function in getCurrentNP().functions) {
      executeFunction(battleData, function, npLvl, overchargeLvl: overchargeLvl);
    }
    battleData.unsetActivator();
  }

  int getBuffValueOnAction(final BattleData battleData, final BuffAction buffAction,
      [final List<BuffData>? commandCodeBuffs]) {
    final actionDetails = ConstData.buffActions[buffAction];
    final isTarget = battleData.target == this;
    int totalVal = 0;
    int maxRate = Maths.min(actionDetails!.maxRate);

    final Iterable<BuffData> allBuffs = [...battleBuff.allBuffs, ...commandCodeBuffs ?? []];

    for (final buff in collectBuffsPerAction(allBuffs, buffAction)) {
      if (buff.shouldApplyBuff(battleData, isTarget)) {
        buff.setUsed();
        battleData.setCurrentBuff(buff);
        final totalEffectiveness = buffAction == BuffAction.turnendHpReduce
            ? getBuffValueOnAction(battleData, BuffAction.funcHpReduce)
            : buffAction != BuffAction.buffRate
                ? getBuffValueOnAction(battleData, BuffAction.buffRate)
                : 0;
        battleData.unsetCurrentBuff();

        final value = (toModifier(totalEffectiveness) * buff.param).toInt();
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

  bool hasBuffOnAction(final BattleData battleData, final BuffAction buffAction,
      [final List<BuffData>? commandCodeBuffs]) {
    return hasBuffOnActions(battleData, [buffAction], commandCodeBuffs);
  }

  bool hasBuffOnActions(final BattleData battleData, final List<BuffAction> buffActions,
      [final List<BuffData>? commandCodeBuffs]) {
    final isTarget = battleData.target == this;

    final Iterable<BuffData> allBuffs = [...battleBuff.allBuffs, ...commandCodeBuffs ?? []];
    for (final buff in collectBuffsPerActions(allBuffs, buffActions)) {
      if (buff.shouldApplyBuff(battleData, isTarget)) {
        buff.setUsed();
        return true;
      }
    }
    return false;
  }

  void activateBuffOnAction(final BattleData battleData, final BuffAction buffAction,
      [final List<BuffData>? commandCodeBuffs]) {
    activateBuffOnActions(battleData, [buffAction], commandCodeBuffs);
  }

  void activateBuffOnActions(final BattleData battleData, final Iterable<BuffAction> buffActions,
      [List<BuffData>? commandCodeBuffs]) {
    final Iterable<BuffData> allBuffs = [...battleBuff.allBuffs, ...commandCodeBuffs ?? []];
    return activateBuffs(battleData, collectBuffsPerActions(allBuffs, buffActions));
  }

  void activateBuffs(final BattleData battleData, final Iterable<BuffData> buffs) {
    battleData.setActivator(this);

    for (final buff in buffs) {
      if (buff.shouldApplyBuff(battleData, false)) {
        final skill = db.gameData.baseSkills[buff.param];
        if (skill == null) {
          print('Unknown skill ID [${buff.param}] referenced in buff [${buff.buff.id}].');
          continue;
        }

        BattleSkillInfoData.activateSkill(battleData, skill, buff.additionalParam);
        buff.setUsed();
      }
    }

    battleData.unsetActivator();

    battleData.checkBuffStatus();
  }

  void removeBuffWithTrait(final NiceTrait trait) {
    battleBuff.activeList.removeWhere((buff) => buff.checkTraits([trait]));
  }

  bool isBuffStackable(final int buffGroup) {
    for (final buff in battleBuff.allBuffs) {
      if (!buff.canStack(buffGroup)) {
        return false;
      }
    }

    return true;
  }

  void addBuff(final BuffData buffData, {final bool isPassive = false}) {
    if (isPassive) {
      battleBuff.passiveList.add(buffData);
    } else {
      battleBuff.activeList.add(buffData);
    }
  }

  void checkBuffStatus() {
    battleBuff.allBuffs.where((buff) => buff.isUsed).forEach((buff) {
      buff.useOnce();
    });

    battleBuff.allBuffs.removeWhere((buff) => !buff.isActive);
  }

  void enterField(final BattleData battleData) {
    activateBuffOnAction(battleData, BuffAction.functionEntry);
  }

  void death(final BattleData battleData) {
    activateBuffOnAction(battleData, BuffAction.functionDead);
  }

  void startOfMyTurn(final BattleData battleData) {
    activateBuffOnAction(battleData, BuffAction.functionSelfturnstart);
  }

  void endOfMyTurn(final BattleData battleData) {
    if (isEnemy) {
      final npSealed = hasBuffOnActions(battleData, doNotNPTypes);
      if (!npSealed) {
        npLineCount += 1;
        npLineCount.clamp(0, niceEnemy!.chargeTurn);
      }
    } else {
      final skillSealed = hasBuffOnAction(battleData, BuffAction.donotSkill);
      if (!skillSealed) {
        skillInfoList.forEach((skill) {
          skill.turnEnd();
        });
      }
    }

    battleData.setActivator(this);
    battleData.setTarget(this);
    final turnEndDamage = getBuffValueOnAction(battleData, BuffAction.turnendHpReduce);
    if (turnEndDamage != 0) receiveDamage(turnEndDamage);

    if (hp <= 0 && hasNextShift()) {
      hp = 1;
    }

    final turnEndHeal = getBuffValueOnAction(battleData, BuffAction.turnendHpRegain);
    if (turnEndHeal != 0) {
      final healGrantEff = toModifier(getBuffValueOnAction(battleData, BuffAction.giveGainHp));
      final healReceiveEff = toModifier(getBuffValueOnAction(battleData, BuffAction.gainHp));
      heal((turnEndHeal * healReceiveEff * healGrantEff).toInt());
    }

    final turnEndStar = getBuffValueOnAction(battleData, BuffAction.turnendStar);
    if (turnEndStar != 0) battleData.changeStar(turnEndStar);

    final turnEndNP = getBuffValueOnAction(battleData, BuffAction.turnendNp);
    if (turnEndNP != 0) changeNP(turnEndNP);

    battleBuff.turnEndShort();

    battleData.unsetTarget();
    battleData.unsetActivator();

    final delayedFunctions = collectBuffsPerType(battleBuff.allBuffs, BuffType.delayFunction);
    activateBuffs(battleData, delayedFunctions.where((buff) => buff.turn == 0));
    activateBuffOnAction(battleData, BuffAction.functionSelfturnend);

    battleData.checkBuffStatus();
  }

  void endOfYourTurn(final BattleData battleData) {
    clearAccumulationDamage();

    battleData.setActivator(this);
    battleData.setTarget(this);

    battleBuff.turnEndLong();

    battleData.unsetTarget();
    battleData.unsetActivator();

    final delayedFunctions = collectBuffsPerType(battleBuff.allBuffs, BuffType.delayFunction);
    activateBuffs(battleData, delayedFunctions.where((buff) => buff.turn == 0));

    battleData.checkBuffStatus();
  }

  bool activateGuts(final BattleData battleData) {
    BuffData? gutsToApply;
    for (final buff in collectBuffsPerTypes(battleBuff.allBuffs, gutsTypes)) {
      if (buff.shouldApplyBuff(battleData, false)) {
        if (gutsToApply == null || (gutsToApply.irremovable && !buff.irremovable)) {
          gutsToApply = buff;
        }
      }
    }

    if (gutsToApply != null) {
      gutsToApply.setUsed();
      final value = gutsToApply.param;
      if (gutsToApply.buff.type == BuffType.gutsRatio) {
        hp = (value * maxHp).floor();
      } else {
        hp = value;
      }
      killedByCard = null;
      killedBy = null;
      activateBuffOnAction(battleData, BuffAction.functionGuts);
      return true;
    }

    return false;
  }

  BattleServantData copy() {
    return BattleServantData()
      ..niceEnemy = niceEnemy
      ..niceSvt = niceSvt
      ..index = index
      ..deckIndex = deckIndex
      ..uniqueId = uniqueId
      ..svtId = svtId
      ..exceedCount = exceedCount
      ..limitCount = limitCount
      ..transformSvtId = transformSvtId
      ..transformIndex = transformIndex
      ..totalDamage = totalDamage
      ..svtData = svtData
      ..level = level
      ..maxLevel = maxLevel
      ..atk = atk
      ..followerType = followerType
      ..hp = hp
      ..maxHp = maxHp
      ..maxActNum = maxActNum
      ..np = np
      ..npLineCount = npLineCount
      ..lineMaxNp = lineMaxNp
      ..tmpNp = tmpNp
      ..equipAtk = equipAtk
      ..equipHp = equipHp
      ..maxTpTurn = maxTpTurn
      ..nextTpTurn = nextTpTurn
      ..downStarRate = downStarRate
      ..downTdRate = downTdRate
      ..deathRate = deathRate
      ..svtType = svtType
      ..criticalRate = criticalRate
      ..reducedHp = reducedHp
      ..restAttackCount = restAttackCount
      ..overkillTargetId = overkillTargetId
      ..accumulationDamage = accumulationDamage
      ..resultHp = resultHp
      ..userCommandCodeIds = userCommandCodeIds.toList()
      ..svtIndividuality = svtIndividuality.toList()
      ..skillInfoList = skillInfoList.toList() // copy
      ..tdId = tdId
      ..tdLv = tdLv
      ..equip = equip
      ..battleBuff = battleBuff // TODO (battle): add copy()
      ..shiftIndex = shiftIndex; //copy
  }
}
