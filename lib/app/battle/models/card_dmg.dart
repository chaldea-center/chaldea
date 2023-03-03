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
  int svtId;
  List<int> skillLvs = [10, 10, 10];
  List<int> skillStrengthenLvs = [1, 1, 1];
  List<int> appendLvs = [0, 0, 0];
  int npLv = 5;
  int npStrengthenLv = 1;
  int lv = -1; // -1=mlb, 90, 100, 120
  int atkFou = 1000;
  int hpFou = 1000;

  int? ceId;
  bool ceLimitBreak = false;
  int ceLv = 0;

  List<int> cardStrengthens = [0, 0, 0, 0, 0];
  List<int> commandCodeIds = [-1, -1, -1, -1, -1];

  PlayerSvtData(this.svtId);
}

class BuffPreset {
  int addAtk = 0;
}
