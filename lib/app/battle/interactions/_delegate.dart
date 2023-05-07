import 'package:chaldea/models/models.dart';
import '../models/battle.dart';

class BattleDelegate {
  final BattleData battleData;

  BattleDelegate(this.battleData);

  Future<int?> Function(BattleServantData? actor)? actWeight;
  Future<int?> Function(BattleServantData? actor)? skillActSelect;
  Future<NiceTd?> Function(BattleServantData? actor, List<NiceTd> tds)? tdTypeChange;
  int? Function(BattleServantData? actor, int baseOC, int upOC)? decideOC;
}
