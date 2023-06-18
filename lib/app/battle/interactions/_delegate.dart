import 'package:chaldea/models/models.dart';
import 'package:tuple/tuple.dart';
import '../models/battle.dart';

class BattleDelegate {
  BattleDelegate();

  Future<int?> Function(BattleServantData? actor)? actWeight;
  Future<int?> Function(BattleServantData? actor)? skillActSelect;
  Future<NiceTd?> Function(BattleServantData? actor, List<NiceTd> tds)? tdTypeChange;
  Future<bool> Function(bool curResult)? tailoredExecutionCanActivate;
  Future<int> Function(int curRandom)? tailoredExecutionRandom;
  Future<Tuple2<BattleServantData, BattleServantData>?> Function(
    List<BattleServantData?>? onFieldSvts,
    List<BattleServantData?>? backupSvts,
  )? replaceMember;

  int? Function(BattleServantData? actor, int baseOC, int upOC)? decideOC;
  bool? Function(BattleServantData? actor, BaseSkill? skill)? whetherSkill;
  bool? Function(BattleServantData? actor)? whetherTd;

  int? Function(BattleServantData actor, BattleData battleData, NiceFunction? func, DataVals vals)? hpRatio;
  DamageNpSEDecision? Function(BattleServantData? actor, NiceFunction? func, DataVals vals)? damageNpSE;
}

class DamageNpSEDecision {
  bool? useCorrection;
  int? indivSumCount;

  DamageNpSEDecision({
    this.useCorrection,
    this.indivSumCount,
  });
}
