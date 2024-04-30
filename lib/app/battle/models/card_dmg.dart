import 'package:chaldea/models/models.dart';
import 'user.dart';

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
  ServantSubAttribute attribute = ServantSubAttribute.void_;
  int rarity = 0;
  int hp = 0;
}

class BuffPreset {
  int addAtk = 0;
}
