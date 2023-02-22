import 'package:chaldea/models/models.dart';

class BattleBuff {
  List<BuffData> passiveList = [];
  List<BuffData> activeList = [];
  List<BuffData> auraBuffList = [];
}

class BuffData {
  Buff? buff;
  // ignore: unused_field
  DataVals? _vals;
  //
  int count = -1;
  int turn = -1;
  int param = 0;
  bool isUse = false;
  bool passive = false;
  bool isAct = false;
  bool isDecide = false;
  List<int> vals = [];
  int buffRate = 1000;
  int paramAdd = 0;
  int paramMax = 0;
  int onfieldUniqueId = 0;
  int auraEffectId = -1;
  int actorId = 0;
  int ratioHpHigh = 0;
  int ratioHpLow = 0;
  int ratioRangeHigh = 0;
  int ratioRangeLow = 0;
  int userCommandCodeId = -1;
  bool isActiveCC = false;
  List<int> targetSkill = [];
  int state = 0;
}
