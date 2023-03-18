import 'package:chaldea/models/models.dart';

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
  int ascensionPhase = 4;
  List<int> skillLvs = [10, 10, 10];
  List<int> skillId = [0, 0, 0];
  List<int> appendLvs = [0, 0, 0];
  int npLv = 5;
  int npId = 0;
  int lv = -1; // -1=mlb, 90, 100, 120
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
    skillId = svt!.groupedActiveSkills.map((e) => e.first.id).toList();
    npId = svt!.groupedNoblePhantasms.first.first.id;
  }

  void setSkillStrengthenLvs(final List<int> skillStrengthenLvs) {
    skillId = List.generate(
        skillStrengthenLvs.length, (index) => svt!.groupedActiveSkills[index][skillStrengthenLvs[index] - 1].id);
  }

  void setNpStrengthenLv(final int npStrengthenLv) {
    npId = svt!.groupedNoblePhantasms.first[npStrengthenLv - 1].id;
  }
}

class MysticCodeData {
  MysticCode mysticCode = db.gameData.mysticCodes[210]!;
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
