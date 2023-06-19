import 'package:tuple/tuple.dart';

import 'package:chaldea/models/models.dart';
import '../models/battle.dart';

class BattleDelegate {
  BattleDelegate();

  Future<int?> Function(BattleServantData? actor)? actWeight;
  Future<int?> Function(BattleServantData? actor)? skillActSelect;
  Future<NiceTd?> Function(BattleServantData? actor, List<NiceTd> tds)? tdTypeChange;
  Future<bool> Function(bool curResult)? canActivate;
  Future<int> Function(int curRandom)? damageRandom;
  Future<Tuple2<BattleServantData, BattleServantData>?> Function(
    List<BattleServantData?> onFieldSvts,
    List<BattleServantData?> backupSvts,
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

class BattleReplayDelegate extends BattleDelegate {
  final List<int> actWeightSelections = [];
  final List<int> skillActSelectSelections = [];
  final List<int> tdTypeChangeIndexes = [];
  final List<bool> canActivateDecisions = [];
  final List<int> damageSelections = [];
  final List<Tuple2<int, int>> replaceMemberIndexes = [];

  BattleReplayDelegate(final BattleReplayDelegateData replayData) {
    actWeightSelections.addAll(replayData.actWeightSelections);
    skillActSelectSelections.addAll(replayData.skillActSelectSelections);
    tdTypeChangeIndexes.addAll(replayData.tdTypeChangeIndexes);
    canActivateDecisions.addAll(replayData.canActivateDecisions);
    damageSelections.addAll(replayData.damageSelections);
    for (final tupleList in replayData.replaceMemberIndexes) {
      if (tupleList.length == 2) {
        replaceMemberIndexes.add(Tuple2(tupleList[0], tupleList[1]));
      }
    }

    actWeight = (actor) async {
      if (actWeightSelections.isEmpty) {
        return null;
      }
      return actWeightSelections.removeAt(0);
    };

    skillActSelect = (actor) async {
      if (skillActSelectSelections.isEmpty) {
        return null;
      }
      return skillActSelectSelections.removeAt(0);
    };

    tdTypeChange = (actor, tds) async {
      if (tdTypeChangeIndexes.isEmpty || tds.isEmpty) {
        return null;
      }

      final selectedIndex = tdTypeChangeIndexes.removeAt(0);
      if (selectedIndex < 0 || selectedIndex >= tds.length) {
        return null;
      }

      return tds[selectedIndex];
    };

    canActivate = (result) async {
      if (canActivateDecisions.isEmpty) {
        return result;
      }
      return canActivateDecisions.removeAt(0);
    };

    damageRandom = (random) async {
      if (damageSelections.isEmpty) {
        return random;
      }
      return damageSelections.removeAt(0);
    };

    replaceMember = (onFieldSvts, backupSvts) async {
      if (replaceMemberIndexes.isEmpty || onFieldSvts.isEmpty == true || backupSvts.isEmpty == true) {
        return null;
      }

      final selections = replaceMemberIndexes.removeAt(0);
      final onFieldSvtIndex = selections.item1;
      final backupSvtIndex = selections.item2;

      if (onFieldSvtIndex < 0 ||
          backupSvtIndex < 0 ||
          onFieldSvts.length <= onFieldSvtIndex ||
          backupSvts.length <= backupSvtIndex) {
        return null;
      }

      final onFieldSelection = onFieldSvts[onFieldSvtIndex];
      final backupSelection = backupSvts[backupSvtIndex];

      if (onFieldSelection == null || backupSelection == null) {
        return null;
      }

      return Tuple2(onFieldSelection, backupSelection);
    };
  }
}
