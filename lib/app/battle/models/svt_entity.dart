import 'package:chaldea/models/models.dart';
import 'buff.dart';
import 'skill.dart';

class BattleServantData {
  QuestEnemy? niceEnemy;
  Servant? niceSvt;
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
  List equipList = [];
  BuffData buffData = BuffData();

  static BattleServantData fromEnemy(QuestEnemy enemy) {
    final svt = BattleServantData();
    svt
      ..niceEnemy = enemy
      ..uniqueId = enemy.uniqueId
      ..svtId = enemy.svt.id
      ..limitCount = enemy.limit?.limitCount ?? 0
      ..level = enemy.lv
      ..atk = enemy.atk
      ..hp = enemy.hp
      ..deathRate = enemy.deathRate
      ..downTdRate = enemy.serverMod.tdRate;
    return svt;
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
      ..buffData = buffData; //copy
  }
}
