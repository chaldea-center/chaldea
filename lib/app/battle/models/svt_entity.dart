import 'dart:math';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/command_card.dart';
import 'package:chaldea/app/battle/models/craft_essence_entity.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
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
  BasicServant? overrideSvt;
  PlayerSvtData? playerSvtData;

  bool get isPlayer => niceSvt != null;

  bool get isEnemy => niceEnemy != null;

  String get lBattleName => isPlayer ? niceSvt!.lBattleName(ascensionPhase).l : niceEnemy!.lShownName;

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
  int npId = 1;
  int atk = 0;
  int hp = 0;
  int maxHp = 0;
  int np = 0;
  int npLineCount = 0;
  int accumulationDamage = 0;
  bool myTurn = false;

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

  int get npLv => isPlayer ? playerSvtData!.npLv : niceEnemy!.noblePhantasm.noblePhantasmLv;

  int get attack => isPlayer ? atk + (equip?.atk ?? 0) : atk;

  int get rarity => isPlayer ? niceSvt!.rarity : niceEnemy!.svt.rarity;

  SvtClass get svtClass => isPlayer ? niceSvt!.className : niceEnemy!.svt.className;

  Attribute get attribute => isPlayer ? niceSvt!.attribute : niceEnemy!.svt.attribute;

  int get starGen => isPlayer ? niceSvt!.starGen : 0;

  int get defenceNpGain => isPlayer
      ? niceSvt!.noblePhantasms.firstWhere((niceTd) => niceTd.id == npId).npGain.defence[playerSvtData!.npLv - 1]
      : 0;

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
    return svt;
  }

  static BattleServantData fromPlayerSvtData(final PlayerSvtData settings) {
    final svt = BattleServantData();
    svt
      ..playerSvtData = settings
      ..niceSvt = settings.svt!
      ..svtId = settings.svt?.id ?? 0
      ..level = settings.lv
      ..npId = settings.npId
      ..ascensionPhase = settings.ascensionPhase
      ..hp = settings.svt!.hpGrowth[settings.lv - 1] + settings.hpFou
      ..maxHp = settings.svt!.hpGrowth[settings.lv - 1] + settings.hpFou
      ..atk = settings.svt!.atkGrowth[settings.lv - 1] + settings.atkFou;

    if (settings.ce != null) {
      svt.equip = BattleCEData(settings.ce!, settings.ceLimitBreak, settings.ceLv);
      svt.hp += svt.equip!.hp;
      svt.maxHp += svt.equip!.hp;
    }

    final script = settings.svt!.script;
    for (int i = 0; i <= settings.skillId.length; i += 1) {
      if (settings.svt!.groupedActiveSkills.length > i) {
        final List<BaseSkill> provisionedSkills = [];
        provisionedSkills.addAll(settings.svt!.groupedActiveSkills[i]);
        List<int>? rankUps;
        if (script != null && script.skillRankUp != null) {
          rankUps = script.skillRankUp![settings.skillId[i]];
          if (rankUps != null && rankUps.isNotEmpty) {
            for (final skillId in rankUps) {
              final rankUpSkill = db.gameData.baseSkills[skillId];
              if (rankUpSkill != null) {
                provisionedSkills.add(rankUpSkill);
              }
            }
          }
        }

        final skillInfo = BattleSkillInfoData(provisionedSkills, settings.skillId[i])..skillLv = settings.skillLvs[i];

        if (rankUps != null) {
          skillInfo.rankUps = rankUps;
        }

        svt.skillInfoList.add(skillInfo);
      }
    }

    for (final commandCode in settings.commandCodes) {
      if (commandCode != null) {
        svt.commandCodeSkills.add(commandCode.skills
            .map((skill) => BattleSkillInfoData([skill], skill.id, isCommandCode: true)..skillLv = 1)
            .toList());
      } else {
        svt.commandCodeSkills.add([]);
      }
    }
    return svt;
  }

  Future<void> init(final BattleData battleData) async {
    final List<NiceSkill> passives = isPlayer
        ? [...niceSvt!.classPassive, ...niceSvt!.extraPassive]
        : [...niceEnemy!.classPassive.classPassive, ...niceEnemy!.classPassive.addPassive];

    battleData.setActivator(this);
    for (final skill in passives) {
      await BattleSkillInfoData.activateSkill(battleData, skill, 1, isPassive: true); // passives default to level 1
    }

    if (isPlayer) {
      for (int i = 0; i < niceSvt!.appendPassive.length; i += 1) {
        final appendLv = playerSvtData!.appendLvs.length > i ? playerSvtData!.appendLvs[i] : 0;
        if (appendLv > 0) {
          await BattleSkillInfoData.activateSkill(
            battleData,
            niceSvt!.appendPassive[i].skill,
            appendLv,
            isPassive: true,
          );
        }
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

    final changeCardType = getFirstBuffOnActions(battleData, [BuffAction.changeCommandCardType]);
    final List<CardType> cards = changeCardType == null
        ? niceSvt!.cards
        : List.generate(niceSvt!.cards.length,
            (index) => CardType.values.firstWhere((cardType) => cardType.id == changeCardType.param));

    final List<CommandCardData> builtCards = [];
    for (int i = 0; i < cards.length; i += 1) {
      final cardType = cards[i];
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
      niceSvt!.traitAdd.forEach((e) => allTraits.addAll(e.trait));
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

  bool checkTrait(final BattleData battleData, final NiceTrait requiredTrait, {final bool checkBuff = false}) {
    return checkTraits(battleData, [requiredTrait], checkBuff: checkBuff);
  }

  bool checkTraits(
    final BattleData battleData,
    final Iterable<NiceTrait> requiredTraits, {
    final bool checkBuff = false,
  }) {
    final List<NiceTrait> myTraits = getTraits(battleData);
    if (checkBuff) {
      battleBuff.allBuffs.forEach((buff) {
        myTraits.addAll(buff.traits);
      });
    }

    return containsAnyTraits(myTraits, requiredTraits);
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

  void heal(final BattleData battleData, final int heal) {
    if (hasDoNotBuffOnActionForUI(battleData, BuffAction.donotRecovery)) {
      return;
    }

    hp += heal;
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

  bool hasNextShift() {
    if (isPlayer) {
      return false;
    }

    return shiftNpcIds.isNotEmpty && shiftNpcIds.length > shiftIndex;
  }

  Future<void> shift(final BattleData battleData) async {
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

    await init(battleData);
    shiftIndex += 1;
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
    if (skillInfoList.length <= skillIndex || skillIndex < 0) {
      return false;
    }

    final skillInfo = skillInfoList[skillIndex];
    battleData.setActivator(this);
    final rankUp = countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.id)]);
    skillInfo.setRankUp(rankUp);

    final result = canAttack(battleData) &&
        !hasDoNotBuffOnActionForUI(battleData, BuffAction.donotSkill) &&
        skillInfo.skillId != 0 &&
        skillInfo.checkSkillScript(battleData);
    battleData.unsetActivator();
    return result;
  }

  Future<void> activateSkill(final BattleData battleData, final int skillIndex) async {
    final skillInfo = skillInfoList[skillIndex];
    battleData.setActivator(this);
    final rankUp = countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.id)]);
    skillInfo.setRankUp(rankUp);

    await skillInfo.activate(battleData);
    battleData.unsetActivator();
  }

  Future<void> activateCommandCode(final BattleData battleData, final int cardIndex) async {
    if (cardIndex < 0 || commandCodeSkills.length <= cardIndex) {
      return;
    }

    battleData.setActivator(this);
    for (final skill in commandCodeSkills[cardIndex]) {
      battleData.logger.action('$lBattleName - ${S.current.command_code}: ${skill.lName}');
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
    final result = canNP(battleData) && npId != 0 && checkNPScript(battleData);
    battleData.unsetActivator();
    return result;
  }

  bool canNP(final BattleData battleData) {
    if ((isPlayer && np < ConstData.constants.fullTdPoint) ||
        (isEnemy && (npLineCount < niceEnemy!.chargeTurn || niceEnemy!.chargeTurn == 0))) {
      return false;
    }
    battleData.setActivator(this);
    final result = canAttack(battleData) && !hasDoNotBuffOnActionsForUI(battleData, doNotNPTypes);
    battleData.unsetActivator();
    return result;
  }

  bool checkNPScript(final BattleData battleData) {
    battleData.setActivator(this);
    if (isPlayer) {
      return BattleSkillInfoData.skillScriptConditionCheck(battleData, getCurrentNP(battleData).script, npLv);
    }
    battleData.unsetActivator();
    return true;
  }

  List<NiceTd> getTdsById(final List<int> tdIds) {
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

  NiceTd getCurrentNP(final BattleData battleData) {
    final buffs = collectBuffsPerAction(battleBuff.allBuffs, BuffAction.tdTypeChange);
    battleData.setActivator(this);
    for (final buff in buffs) {
      if (buff.shouldApplyBuff(battleData, false)) {
        return buff.tdSelection!;
      }
    }
    battleData.unsetActivator();

    return isPlayer
        ? niceSvt!.groupedNoblePhantasms[0].firstWhere((niceTd) => niceTd.id == npId)
        : niceEnemy!.noblePhantasm.noblePhantasm!;
  }

  Future<void> activateNP(final BattleData battleData, final int extraOverchargeLvl) async {
    battleData.setActivator(this);
    battleData.logger.action('$lBattleName ${S.current.battle_np_card}');

    final upOverCharge = await getBuffValueOnAction(battleData, BuffAction.chagetd);
    int overchargeLvl = upOverCharge + (isPlayer ? np ~/ ConstData.constants.fullTdPoint + extraOverchargeLvl : 1);
    overchargeLvl = overchargeLvl.clamp(1, 5);

    np = 0;
    npLineCount = 0;

    final niceTD = getCurrentNP(battleData);
    await FunctionExecutor.executeFunctions(battleData, niceTD.functions, npLv, overchargeLvl: overchargeLvl);

    battleData.unsetActivator();
  }

  Future<int> getBuffValueOnAction(final BattleData battleData, final BuffAction buffAction) async {
    final actionDetails = ConstData.buffActions[buffAction];
    final isTarget = battleData.target == this;
    int totalVal = 0;
    int maxRate = Maths.min(actionDetails!.maxRate);

    for (final buff in collectBuffsPerAction(battleBuff.allBuffs, buffAction)) {
      if (await buff.shouldActivateBuff(battleData, isTarget)) {
        buff.setUsed();
        battleData.setCurrentBuff(buff);
        final totalEffectiveness = buffAction == BuffAction.turnendHpReduce
            ? await getBuffValueOnAction(battleData, BuffAction.funcHpReduce)
            : buffAction != BuffAction.buffRate
                ? await getBuffValueOnAction(battleData, BuffAction.buffRate)
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

  Future<void> activateBuffOnAction(final BattleData battleData, final BuffAction buffAction) async {
    await activateBuffOnActions(battleData, [buffAction]);
  }

  Future<void> activateBuffOnActions(final BattleData battleData, final Iterable<BuffAction> buffActions) async {
    await activateBuffs(battleData, collectBuffsPerActions(battleBuff.allBuffs, buffActions));
  }

  Future<void> activateBuffs(final BattleData battleData, final Iterable<BuffData> buffs) async {
    battleData.setActivator(this);

    for (final buff in buffs.toList()) {
      if (await buff.shouldActivateBuff(battleData, false)) {
        final skillId = buff.param;
        BaseSkill? skill = db.gameData.baseSkills[skillId];
        try {
          skill ??= await AtlasApi.skill(skillId);
        } catch (e) {
          logger.e('Exception while fetch AtlasApi for skill $skillId', e);
        }
        if (skill == null) {
          battleData.logger.debug('Buff ID [${buff.buff.id}]: ${S.current.skill} [$skillId] ${S.current.not_found}');
          continue;
        }

        battleData.logger.function('$lBattleName - ${buff.buff.lName.l} ${S.current.skill} [$skillId]');
        await BattleSkillInfoData.activateSkill(battleData, skill, buff.additionalParam);
        buff.setUsed();
      }
    }

    battleData.unsetActivator();

    battleData.checkBuffStatus();
  }

  void removeBuffWithTrait(final NiceTrait trait) {
    battleBuff.activeList.removeWhere((buff) => buff.checkTraits([trait]));
  }

  int countTrait(final BattleData battleData, final List<NiceTrait> traits) {
    return countAnyTraits(getTraits(battleData), traits);
  }

  int countBuffWithTrait(final List<NiceTrait> traits) {
    return getBuffsWithTraits(traits).length;
  }

  List<BuffData> getBuffsWithTraits(final List<NiceTrait> traits) {
    return battleBuff.allBuffs.where((buff) => containsAnyTraits(buff.traits, traits)).toList();
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
    for (final buff in collectBuffsPerType(battleBuff.allBuffs, BuffType.overwriteClassRelation)) {
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
    buffData.shouldDecreaseTurn = myTurn;
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

  Future<void> enterField(final BattleData battleData) async {
    await activateBuffOnAction(battleData, BuffAction.functionEntry);
  }

  Future<void> death(final BattleData battleData) async {
    battleData.setActivator(this);
    if (await hasBuffOnAction(battleData, BuffAction.functionDead)) {
      battleData.nonnullActors.forEach((svt) {
        svt.clearAccumulationDamage();
      });
    }
    battleData.unsetActivator();

    await activateBuffOnAction(battleData, BuffAction.functionDead);

    battleData.fieldBuffs
        .removeWhere((buff) => buff.vals.RemoveFieldBuffActorDeath == 1 && buff.actorUniqueId == uniqueId);
    battleData.logger.action('$lBattleName ${S.current.battle_death}');
  }

  Future<void> startOfMyTurn(final BattleData battleData) async {
    myTurn = true;
    for (final buff in battleBuff.allBuffs) {
      buff.shouldDecreaseTurn = true;
    }
    await activateBuffOnAction(battleData, BuffAction.functionSelfturnstart);
  }

  Future<void> endOfMyTurn(final BattleData battleData) async {
    battleData.setActivator(this);
    battleData.setTarget(this);
    if (isEnemy) {
      final npSealed = await hasBuffOnActions(battleData, doNotNPTypes);
      if (!npSealed) {
        npLineCount += 1;
        npLineCount = npLineCount.clamp(0, niceEnemy!.chargeTurn);
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


    String turnEndLog = '';
    int turnEndDamage = await getBuffValueOnAction(battleData, BuffAction.turnendHpReduce);
    if (turnEndDamage != 0) {
      final List<BuffData> preventDeaths = getBuffsOfType(BuffType.preventDeathByDamage);
      turnEndDamage = preventDeaths.any((buff) => buff.shouldApplyBuff(battleData, true))
          ? min(hp - 1, turnEndDamage)
          : turnEndDamage;

      receiveDamage(turnEndDamage);
      turnEndLog += ' - dot ${S.current.battle_damage}: $turnEndDamage';
    }

    if (hp <= 0 && hasNextShift()) {
      hp = 1;
    }

    final turnEndHeal = await getBuffValueOnAction(battleData, BuffAction.turnendHpRegain);
    if (turnEndHeal != 0) {
      final healGrantEff = toModifier(await getBuffValueOnAction(battleData, BuffAction.giveGainHp));
      final healReceiveEff = toModifier(await getBuffValueOnAction(battleData, BuffAction.gainHp));
      final finalHeal = (turnEndHeal * healReceiveEff * healGrantEff).toInt();
      heal(battleData, finalHeal);

      turnEndLog += ' - ${S.current.battle_heal} HP: $finalHeal';
    }

    final turnEndStar = await getBuffValueOnAction(battleData, BuffAction.turnendStar);
    if (turnEndStar != 0) {
      battleData.changeStar(turnEndStar);

      turnEndLog += ' - ${S.current.battle_critical_star}: $turnEndStar';
    }

    if (isPlayer) {
      final turnEndNP = await getBuffValueOnAction(battleData, BuffAction.turnendNp);
      if (turnEndNP != 0) {
        changeNP(turnEndNP);

        turnEndLog += ' - NP: ${(turnEndNP / 100).toStringAsFixed(2)}%';
      }
    } else {
      final turnEndNP = await getBuffValueOnAction(battleData, BuffAction.turnvalNp);
      if (turnEndNP != 0) {
        changeNP(turnEndNP);

        turnEndLog += ' - NP: ${(turnEndNP / 100).toStringAsFixed(2)}%';
      }
    }

    if (turnEndLog.isNotEmpty) {
      battleData.logger.debug('$lBattleName - ${S.current.battle_turn_end}$turnEndLog');
    }

    battleBuff.turnEndShort();

    battleData.unsetTarget();
    battleData.unsetActivator();

    final delayedFunctions = collectBuffsPerType(battleBuff.allBuffs, BuffType.delayFunction);
    await activateBuffOnAction(battleData, BuffAction.functionSelfturnend);
    await activateBuffs(battleData, delayedFunctions.where((buff) => buff.turn == 0));

    battleData.checkBuffStatus();

    myTurn = false;
  }

  Future<void> endOfYourTurn(final BattleData battleData) async {
    clearAccumulationDamage();
    attacked = false;

    battleData.setActivator(this);
    battleData.setTarget(this);

    battleBuff.turnEndLong();

    battleData.unsetTarget();
    battleData.unsetActivator();

    final delayedFunctions = collectBuffsPerType(battleBuff.allBuffs, BuffType.delayFunction);
    await activateBuffs(battleData, delayedFunctions.where((buff) => buff.turn == 0));

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

      battleData.logger.action('$lBattleName - ${gutsToApply.buff.lName.l} - '
          '${!isRatio ? value : '${(value / 10).toStringAsFixed(1)}%'}');

      killedByCard = null;
      killedBy = null;
      await activateBuffOnAction(battleData, BuffAction.functionGuts);
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
      ..npId = npId
      ..atk = atk
      ..hp = hp
      ..maxHp = maxHp
      ..np = np
      ..npLineCount = npLineCount
      ..accumulationDamage = accumulationDamage
      ..myTurn = myTurn
      ..ascensionPhase = ascensionPhase
      ..skillInfoList = skillInfoList.map((e) => e.copy()).toList() // copy
      ..equip = equip
      ..battleBuff = battleBuff.copy()
      ..commandCodeSkills = commandCodeSkills.map((skills) => skills.map((skill) => skill.copy()).toList()).toList()
      ..shiftNpcIds = shiftNpcIds
      ..shiftIndex = shiftIndex; //copy
  }
}
