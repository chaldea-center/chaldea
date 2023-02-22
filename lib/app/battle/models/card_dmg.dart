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
  int skillLv1 = 10;
  int skillLv2 = 10;
  int skillLv3 = 10;
  int npLv = 5;
  int ocLv = 1;
  int lv = -1; // -1=mlb, 90, 100, 120
  int fou = 1000;
}

class BuffPreset {
  int addAtk = 0;
}
