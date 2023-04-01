import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import '../../../widgets/widgets.dart';

class CardDmgOption {
  EnemyData? enemyData;
  PlayerSvtData? playerSvtData;
  List<BuffPreset> buffs = [];
  Map<FuncType, int> superNPDmg = {};
}

class EnemyData {
  int svtId = 0;
  int limitCount = 0;
  List<int> individuality = [];
  SvtClass svtClass = SvtClass.ALL;
  Attribute attribute = Attribute.void_;
  int rarity = 0;
  int hp = 0;
}

class PlayerSvtData {
  Servant? svt;
  int limitCount = 4;
  List<int> skillLvs = [10, 10, 10];
  List<NiceSkill?> skills = [null, null, null];
  List<int> appendLvs = [0, 0, 0];
  List<NiceSkill> extraPassives = [];
  List<BaseSkill> additionalPassives = [];
  List<int> additionalPassiveLvs = [];
  int tdLv = 5;
  NiceTd? td;

  int lv = 1; // -1=mlb, 90, 100, 120
  int atkFou = 1000;
  int hpFou = 1000;

  CraftEssence? ce;
  bool ceLimitBreak = false;
  int ceLv = 0;

  SupportSvtType supportSvtType = SupportSvtType.none;

  List<int> cardStrengthens = [0, 0, 0, 0, 0];
  List<CommandCode?> commandCodes = [null, null, null, null, null];

  PlayerSvtData.base();

  PlayerSvtData(final int svtId) {
    svt = db.gameData.servantsById[svtId];
    skills = kActiveSkillNums.map((e) => svt!.groupedActiveSkills[e]?.first).toList();
    td = svt!.groupedNoblePhantasms[1]?.first;
  }

  @visibleForTesting
  void setSkillStrengthenLvs(final List<int> skillStrengthenLvs) {
    skills =
        kActiveSkillNums.map((e) => svt!.groupedActiveSkills[e]?.getOrNull(skillStrengthenLvs[e - 1] - 1)).toList();
  }

  void setNpStrengthenLv(final int npStrengthenLv) {
    td = svt!.groupedNoblePhantasms[1]?[npStrengthenLv - 1];
  }

  void addCustomPassive(BaseSkill skill, int lv) {
    if (skill.maxLv <= 0) return;
    additionalPassives.add(skill);
    additionalPassiveLvs.add(lv);
  }
}

class MysticCodeData {
  MysticCode? mysticCode = db.gameData.mysticCodes[210];
  int level = 10;
}

class BuffPreset {
  int addAtk = 0;
}

// Follower.Type
enum SupportSvtType {
  none,
  friend,
  notFriend,
  npc,
  npcNoTd,
}
