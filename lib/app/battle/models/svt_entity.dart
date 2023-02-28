import 'dart:math';

import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/craft_essence_entity.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/models.dart';

import 'buff.dart';
import 'card_dmg.dart';
import 'skill.dart';

class BattleServantData {
  static const npPityThreshold = 9900;

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
  int npLineCount = 3;
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
  List<BattleSkillInfoData> skillInfoList = []; //BattleSkillInfoData
  int tdId = 0;
  int tdLv = 0;
  List<BattleCEData> equipList = [];
  BattleBuff battleBuff = BattleBuff();
  int shiftIndex = 0;

  PlayerSvtData? playerSvtData;

  bool get selectable => battleBuff.isSelectable;

  static BattleServantData fromEnemy(QuestEnemy enemy) {
    final svt = BattleServantData();
    svt
      ..niceEnemy = enemy
      ..hp = enemy.hp
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

  void init(BattleData battleData) {
    List<NiceSkill> passives = isPlayer
        ? [...niceSvt!.classPassive, ...niceSvt!.extraPassive, ...niceSvt!.appendPassive.map((e) => e.skill)]
        : [...niceEnemy!.classPassive.classPassive, ...niceEnemy!.classPassive.addPassive];

    battleData.activator = this;
    for (final skill in passives) {
      activateSkill(battleData, skill, 1, isPassive: true); // passives default to level 1
    }

    for (final craftEssence in equipList) {
      craftEssence.activateCE(battleData);
    }
    battleData.activator = null;
  }

  List<NiceTrait> getTraits() {
    // TODO (battle): account for add & remove traits
    return isPlayer ? niceSvt!.traits : niceEnemy!.traits;
  }

  void changeNP(int change) {
    if (!isPlayer) {
      return;
    }

    np += change;

    np.clamp(0, getNPCap(playerSvtData!.npLv));
    if (change > 0 && np > npPityThreshold) {
      np = max(np, db.gameData.constData.constants.fullTdPoint);
    }
  }

  static int getNPCap(int npLevel) {
    final capRate = npLevel == 1
        ? 1
        : npLevel < 5
            ? 2
            : 3;
    return db.gameData.constData.constants.fullTdPoint * capRate;
  }

  bool isAlive() {
    if (hp > 0) {
      return true;
    }

    if (isEnemy && niceEnemy!.enemyScript.shift != null) {
      List<int> shifts = niceEnemy!.enemyScript.shift!;
      if (shifts.length > shiftIndex) {
        return true;
      }
    }

    // TODO (battle): check for conditional guts?
    return battleBuff.collectBuffPerType({BuffType.guts, BuffType.gutsRatio}).isNotEmpty;
  }

  bool canAttack(BattleData battleData) {
    if (hp > 0) {
      return true;
    }

    final doNotActs = battleBuff.collectBuffPerAction(BuffAction.donotAct);
    return doNotActs.any((buff) => buff.shouldApplyBuff(battleData, this == battleData.target));
  }

  bool canCommandCard(BattleData battleData) {
    final doNotCommandCards = battleBuff.collectBuffPerAction(BuffAction.donotActCommandtype);

    return canAttack(battleData) &&
        doNotCommandCards.any((buff) => buff.shouldApplyBuff(battleData, this == battleData.target));
  }

  bool canNP(BattleData battleData) {
    if ((isPlayer && np < db.gameData.constData.constants.fullTdPoint) ||
        (isEnemy && (npLineCount < niceEnemy!.chargeTurn || niceEnemy!.chargeTurn == 0))) {
      return false;
    }

    final doNotActNps = [
      ...battleBuff.collectBuffPerAction(BuffAction.donotNoble),
      ...battleBuff.collectBuffPerAction(BuffAction.donotNobleCondMismatch)
    ];

    return canAttack(battleData) &&
        doNotActNps.any((buff) => buff.shouldApplyBuff(battleData, this == battleData.target)) &&
        checkNPScript(battleData);
  }

  bool checkNPScript(BattleData battleData) {
    if (isPlayer) {
      final currentNP = niceSvt!.noblePhantasms[playerSvtData!.npStrengthenLvl];
      // TODO (battle): check script
    } else {
      final currentNP = niceEnemy!.noblePhantasm;
    }
    return true;
  }

  void activateNP(BattleData battleData, int extraOverchargeLvl) {
    final currentNPFunctions = isPlayer
        ? niceSvt!.noblePhantasms[playerSvtData!.npStrengthenLvl].functions
        : niceEnemy!.noblePhantasm.noblePhantasm!.functions;

    // TODO (battle): account for OC buff
    final overchargeLvl =
        isPlayer ? (np / db.gameData.constData.constants.fullTdPoint).floor() + extraOverchargeLvl : 1;

    final npLvl = isPlayer ? playerSvtData!.npLv : niceEnemy!.noblePhantasm.noblePhantasmLv;

    np = 0;
    npLineCount = 0;

    for (final function in currentNPFunctions) {
      executeFunction(battleData, function, npLvl, overchargeLvl: overchargeLvl);
    }
  }

  int getBuffValueOnAction(BattleData battleData, BuffAction buffAction) {
    final isTarget = battleData.target == this;
    var totalVal = 0;
    var maxRate = 0;

    final actionDetails = db.gameData.constData.buffActions[buffAction];

    for (BuffData buff in battleBuff.collectBuffPerAction(buffAction)) {
      if (buff.shouldApplyBuff(battleData, isTarget)) {
        buff.setUsed();
        if (actionDetails!.plusTypes.contains(buff.buff!.type)) {
          totalVal += buff.param;
        } else {
          totalVal -= buff.param;
        }
        maxRate = max(maxRate, buff.buff!.maxRate);
      }
    }
    return capBuffValue(actionDetails!, totalVal, maxRate);
  }

  bool hasBuffOnAction(BattleData battleData, BuffAction buffAction) {
    final isTarget = battleData.target == this;
    for (BuffData buff in battleBuff.collectBuffPerAction(buffAction)) {
      if (buff.shouldApplyBuff(battleData, isTarget)) {
        buff.setUsed();
        return true;
      }
    }
    return false;
  }

  bool isBuffStackable(int buffGroup) {
    for (BuffData buff in battleBuff.allBuffs) {
      if (!buff.canStack(buffGroup)) {
        return false;
      }
    }

    return true;
  }

  void addBuff(BuffData buffData, {bool isPassive = false}) {
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
      ..equipList = equipList.toList()
      ..battleBuff = battleBuff // TODO (battle): add copy()
      ..shiftIndex = shiftIndex; //copy
  }
}
