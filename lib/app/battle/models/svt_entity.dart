import 'dart:math';

import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/command_card.dart';
import 'package:chaldea/app/battle/models/craft_essence_entity.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/app/modules/battle/simulation_preview.dart';
import 'package:chaldea/generated/l10n.dart';
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
  PlayerSvtData? playerSvtData;

  bool get isPlayer => niceSvt != null;

  bool get isEnemy => niceEnemy != null;

  String get lBattleName =>
      isPlayer ? Transl.svtNames(ServantSelector.getSvtBattleName(niceSvt!, ascensionPhase)).l : niceEnemy!.lShownName;

  int get limitCount => niceEnemy?.limit?.limitCount ?? 0;

  // int index = 0;
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
  // List<int> svtIndividuality = [];
  // int tdId = 0;
  // int tdLv = 0;

  int deckIndex = -1;
  int uniqueId = 0;
  int svtId = -1;
  int level = 0;
  int atk = 0;
  int hp = 0;
  int maxHp = 0;
  int np = 0;
  int npLineCount = 0;
  int accumulationDamage = 0;

  // BattleServantData.Status status
  int ascensionPhase = 0;
  List<BattleSkillInfoData> skillInfoList = []; // BattleSkillInfoData, only active skills for now
  BattleCEData? equip;
  BattleBuff battleBuff = BattleBuff();
  List<List<BattleSkillInfoData>> commandCodeSkills = [];

  List<int> shiftNpcIds = [];
  int shiftIndex = 0;

  bool attacked = false;
  BattleServantData? killedBy;
  CommandCardData? killedByCard;

  bool get selectable => battleBuff.isSelectable;

  int get attack => isPlayer ? atk + (equip?.atk ?? 0) : atk;

  int get rarity => isPlayer ? niceSvt!.rarity : niceEnemy!.svt.rarity;

  SvtClass get svtClass => isPlayer ? niceSvt!.className : niceEnemy!.svt.className;

  Attribute get attribute => isPlayer ? niceSvt!.attribute : niceEnemy!.svt.attribute;

  int get starGen => isPlayer ? niceSvt!.starGen : 0;

  int get defenceNpGain =>
      isPlayer ? niceSvt!.noblePhantasms[playerSvtData!.npStrengthenLv - 1].npGain.defence[playerSvtData!.npLv - 1] : 0;

  int get enemyTdRate => isEnemy ? niceEnemy!.serverMod.tdRate : 0;

  int get enemyTdAttackRate => isEnemy ? niceEnemy!.serverMod.tdAttackRate : 0;

  int get enemyStarRate => isEnemy ? niceEnemy!.serverMod.starRate : 0;

  bool get isBuggedOverkill => accumulationDamage > hp;

  int get deathRate => isEnemy ? niceEnemy!.deathRate : niceSvt!.instantDeathChance;

  static BattleServantData fromEnemy(final QuestEnemy enemy) {
    final svt = BattleServantData();
    svt
      ..niceEnemy = enemy
      ..hp = enemy.hp
      ..maxHp = enemy.hp
      ..svtId = enemy.svt.id
      ..level = enemy.lv
      ..atk = enemy.atk
      ..shiftNpcIds = enemy.enemyScript.shift ?? [];
    // TODO (battle): build enemy active skills & cards & NP
    return svt;
  }

  static BattleServantData fromPlayerSvtData(final PlayerSvtData settings) {
    final svt = BattleServantData();
    svt
      ..playerSvtData = settings
      ..niceSvt = settings.svt
      ..svtId = settings.svt?.id ?? 0
      ..ascensionPhase = settings.ascensionPhase
      ..hp = settings.svt!.hpGrowth[settings.lv - 1] + settings.hpFou
      ..maxHp = settings.svt!.hpGrowth[settings.lv - 1] + settings.hpFou
      ..atk = settings.svt!.atkGrowth[settings.lv - 1] + settings.atkFou;

    if (settings.ce != null) {
      svt.equip = BattleCEData(settings.ce!, settings.ceLimitBreak, settings.ceLv);
      svt.hp += svt.equip!.hp;
      svt.maxHp += svt.equip!.hp;
    }

    for (int i = 0; i <= settings.skillStrengthenLvs.length; i += 1) {
      if (settings.svt!.groupedActiveSkills.length > i) {
        svt.skillInfoList
            .add(BattleSkillInfoData(settings.svt!.groupedActiveSkills[i][settings.skillStrengthenLvs[i] - 1])
              ..skillLv = settings.skillLvs[i]
              ..strengthStatus = settings.skillStrengthenLvs[i]);
      }
    }

    for (final commandCode in settings.commandCodes) {
      if (commandCode != null) {
        svt.commandCodeSkills.add(
            commandCode.skills.map((skill) => BattleSkillInfoData(skill, isCommandCode: true)..skillLv = 1).toList());
      } else {
        svt.commandCodeSkills.add([]);
      }
    }
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

  String getSkillName(final int index) {
    if (skillInfoList.length <= index || index < 0) {
      return 'Invalid skill index: $index';
    }

    return skillInfoList[index].skill.lName.l;
  }

  List<CommandCardData> getCards(final BattleData battleData) {
    if (isEnemy) {
      return [];
    }

    final List<CommandCardData> builtCards = [];
    for (int i = 0; i < niceSvt!.cards.length; i += 1) {
      final cardType = niceSvt!.cards[i];
      final card = CommandCardData(cardType, niceSvt!.cardDetails[cardType]!)
        ..cardIndex = i
        ..isNP = false
        ..cardStrengthen = playerSvtData!.cardStrengthens[i]
        ..npGain = getNPGain(battleData, cardType)
        ..traits = ConstData.cardInfo[cardType]![1]!.individuality;
      builtCards.add(card);
    }
    return builtCards;
  }

  CommandCardData? getNPCard(final BattleData battleData) {
    if (isEnemy) {
      return null;
    }

    final currentNP = getCurrentNP(battleData);
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

  CommandCardData? getExtraCard(final BattleData battleData) {
    if (isEnemy) {
      return null;
    }

    return CommandCardData(CardType.extra, niceSvt!.cardDetails[CardType.extra]!)
      ..isNP = false
      ..npGain = getNPGain(battleData, CardType.extra)
      ..traits = ConstData.cardInfo[CardType.extra]![1]!.individuality;
  }

  int getNPGain(final BattleData battleData, final CardType cardType) {
    if (!isPlayer) {
      return 0;
    }
    switch (cardType) {
      case CardType.buster:
        return getCurrentNP(battleData).npGain.buster[playerSvtData!.npLv - 1];
      case CardType.arts:
        return getCurrentNP(battleData).npGain.arts[playerSvtData!.npLv - 1];
      case CardType.quick:
        return getCurrentNP(battleData).npGain.quick[playerSvtData!.npLv - 1];
      case CardType.extra:
        return getCurrentNP(battleData).npGain.extra[playerSvtData!.npLv - 1];
      default:
        return 0;
    }
  }

  List<NiceTrait> getTraits(final BattleData battleData) {
    final List<NiceTrait> allTraits = [];
    if (isEnemy) {
      allTraits.addAll(niceEnemy!.traits);
    } else {
      if (niceSvt!.ascensionAdd.individuality.all.containsKey(ascensionPhase)) {
        allTraits.addAll(niceSvt!.ascensionAdd.individuality.all[ascensionPhase]!);
      } else {
        allTraits.addAll(niceSvt!.traits);
      }
      niceSvt!.traitAdd.map((e) => allTraits.addAll(e.trait));
    }

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

  bool checkTrait(final BattleData battleData, final NiceTrait requiredTrait, {final bool checkBuff = false}) {
    return checkTraits(battleData, [requiredTrait], checkBuff: checkBuff);
  }

  bool checkTraits(
    final BattleData battleData,
    final Iterable<NiceTrait> requiredTraits, {
    final bool checkBuff = false,
  }) {
    return containsAnyTraits(getTraits(battleData), requiredTraits) ||
        (checkBuff && battleBuff.checkTraits(requiredTraits));
  }

  void changeNPLineCount(final int change) {
    if (!isEnemy) {
      return;
    }

    npLineCount += change;
    npLineCount = npLineCount.clamp(0, niceEnemy!.chargeTurn);
  }

  void changeNP(final int change) {
    if (!isPlayer) {
      return;
    }

    np += change;

    np = np.clamp(0, getNPCap(playerSvtData!.npLv));
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
    return activator != null && currentCard != null && killedBy == activator && killedByCard == currentCard;
  }

  void heal(final int heal) {
    hp += heal;
    hp = hp.clamp(0, maxHp);
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

    return shiftNpcIds.isNotEmpty && shiftNpcIds.length > shiftIndex;
  }

  void shift(final BattleData battleData) {
    if (!hasNextShift()) {
      return;
    }

    final nextShift =
        battleData.enemyDecks[DeckType.shift]!.firstWhere((questEnemy) => questEnemy.npcId == shiftNpcIds[shiftIndex]);
    niceEnemy = nextShift;

    atk = nextShift.atk;
    hp = nextShift.hp;
    maxHp = nextShift.hp;
    level = nextShift.lv;
    battleBuff.clearPassive(uniqueId);

    init(battleData);
  }

  bool isAlive(final BattleData battleData) {
    if (hp > 0) {
      return true;
    }

    if (hasNextShift()) {
      return true;
    }

    battleData.setActivator(this);
    final result = collectBuffsPerTypes(battleBuff.allBuffs, gutsTypes)
        .where((buff) => buff.shouldApplyBuff(battleData, false))
        .isNotEmpty;
    battleData.unsetActivator();
    return result;
  }

  bool canUseSkillIgnoreCoolDown(final BattleData battleData, final int skillIndex) {
    // TODO (battle): skill specific check
    return canAttack(battleData) && !hasBuffOnAction(battleData, BuffAction.donotSkill);
  }

  void activateSkill(final BattleData battleData, final int skillIndex) {
    battleData.setActivator(this);
    skillInfoList[skillIndex].activate(battleData);
    battleData.unsetActivator();
  }

  void activateCommandCode(final BattleData battleData, final int cardIndex) {
    if (cardIndex < 0 || commandCodeSkills.length <= cardIndex) {
      return;
    }

    battleData.setActivator(this);
    commandCodeSkills[cardIndex].forEach((skill) {
      battleData.logger.action('$lBattleName - ${S.current.command_code}: ${skill.skill.lName.l}');
      skill.activate(battleData);
    });
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
      // TODO (battle): check script
    } else {}
    return true;
  }

  NiceTd getCurrentNP(final BattleData battleData) {
    return isPlayer
        ? niceSvt!.groupedNoblePhantasms[0][playerSvtData!.npStrengthenLv - 1]
        : niceEnemy!.noblePhantasm.noblePhantasm!;
  }

  void activateNP(final BattleData battleData, final int extraOverchargeLvl) {
    battleData.setActivator(this);

    // TODO (battle): account for OC buff
    final overchargeLvl = isPlayer ? np ~/ ConstData.constants.fullTdPoint + extraOverchargeLvl : 1;

    final npLvl = isPlayer ? playerSvtData!.npLv : niceEnemy!.noblePhantasm.noblePhantasmLv;

    np = 0;
    npLineCount = 0;

    final niceTD = getCurrentNP(battleData);
    for (final function in niceTD.functions) {
      FunctionExecutor.executeFunction(battleData, function, npLvl, overchargeLvl: overchargeLvl);
    }
    battleData.unsetActivator();
  }

  int getBuffValueOnAction(final BattleData battleData, final BuffAction buffAction) {
    final actionDetails = ConstData.buffActions[buffAction];
    final isTarget = battleData.target == this;
    int totalVal = 0;
    int maxRate = Maths.min(actionDetails!.maxRate);

    for (final buff in collectBuffsPerAction(battleBuff.allBuffs, buffAction)) {
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

  bool hasBuffOnAction(final BattleData battleData, final BuffAction buffAction) {
    return hasBuffOnActions(battleData, [buffAction]);
  }

  bool hasBuffOnActions(final BattleData battleData, final List<BuffAction> buffActions) {
    final isTarget = battleData.target == this;

    for (final buff in collectBuffsPerActions(battleBuff.allBuffs, buffActions)) {
      if (buff.shouldApplyBuff(battleData, isTarget)) {
        buff.setUsed();
        return true;
      }
    }
    return false;
  }

  void activateBuffOnAction(final BattleData battleData, final BuffAction buffAction) {
    activateBuffOnActions(battleData, [buffAction]);
  }

  void activateBuffOnActions(final BattleData battleData, final Iterable<BuffAction> buffActions) {
    activateBuffs(battleData, collectBuffsPerActions(battleBuff.allBuffs, buffActions));
  }

  void activateBuffs(final BattleData battleData, final Iterable<BuffData> buffs) {
    battleData.setActivator(this);

    for (final buff in buffs.toList()) {
      if (buff.shouldApplyBuff(battleData, false)) {
        final skill = db.gameData.baseSkills[buff.param];
        if (skill == null) {
          battleData.logger
              .debug('Buff ID [${buff.buff.id}]: ${S.current.skill} [${buff.param}] ${S.current.not_found}');
          continue;
        }

        battleData.logger.function('$lBattleName - ${buff.buff.lName.l} ${S.current.skill} [${buff.param}]');
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

  void checkBuffStatus() {
    battleBuff.allBuffs.where((buff) => buff.isUsed).forEach((buff) {
      buff.useOnce();
    });

    battleBuff.passiveList.removeWhere((buff) => !buff.isActive);
    battleBuff.activeList.removeWhere((buff) => !buff.isActive);
    battleBuff.commandCodeList.removeWhere((buff) => !buff.isActive);
  }

  void enterField(final BattleData battleData) {
    activateBuffOnAction(battleData, BuffAction.functionEntry);
  }

  void death(final BattleData battleData) {
    activateBuffOnAction(battleData, BuffAction.functionDead);

    battleData.fieldBuffs
        .removeWhere((buff) => buff.vals.RemoveFieldBuffActorDeath == 1 && buff.actorUniqueId == uniqueId);
  }

  void startOfMyTurn(final BattleData battleData) {
    activateBuffOnAction(battleData, BuffAction.functionSelfturnstart);
  }

  void endOfMyTurn(final BattleData battleData) {
    if (isEnemy) {
      final npSealed = hasBuffOnActions(battleData, doNotNPTypes);
      if (!npSealed) {
        npLineCount += 1;
        npLineCount = npLineCount.clamp(0, niceEnemy!.chargeTurn);
      }
    } else {
      final skillSealed = hasBuffOnAction(battleData, BuffAction.donotSkill);
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
    battleData.setActivator(this);
    for (final buff in collectBuffsPerTypes(battleBuff.allBuffs, gutsTypes)) {
      if (buff.shouldApplyBuff(battleData, false)) {
        if (gutsToApply == null || (gutsToApply.irremovable && !buff.irremovable)) {
          gutsToApply = buff;
        }
      }
    }
    battleData.unsetActivator();

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
      ..playerSvtData = playerSvtData
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
      ..ascensionPhase = ascensionPhase
      ..skillInfoList = skillInfoList.map((e) => e.copy()).toList() // copy
      ..equip = equip
      ..battleBuff = battleBuff.copy()
      ..commandCodeSkills = commandCodeSkills.map((skills) => skills.map((skill) => skill.copy()).toList()).toList()
      ..shiftNpcIds = shiftNpcIds
      ..shiftIndex = shiftIndex; //copy
  }
}
