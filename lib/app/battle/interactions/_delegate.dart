import 'package:tuple/tuple.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import '../models/battle.dart';

class BattleDelegate {
  Future<int?> Function(BattleServantData? actor)? actWeight;
  Future<int?> Function(BattleServantData? actor)? skillActSelect;
  Future<CardType?> Function(BattleServantData? actor, List<CardType> tdTypes)? tdTypeChange;
  Future<BattleServantData?> Function(List<BattleServantData> targets)? ptRandom;
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
  final BattleReplayDelegateData _data;

  BattleReplayDelegate(BattleReplayDelegateData data) : _data = data.copy() {
    actWeight = (actor) async {
      if (_data.actWeightSelections.isEmpty) {
        return null;
      }
      return _data.actWeightSelections.removeAt(0);
    };

    skillActSelect = (actor) async {
      if (_data.skillActSelectSelections.isEmpty) {
        return null;
      }
      return _data.skillActSelectSelections.removeAt(0);
    };

    tdTypeChange = (actor, validTypes) async {
      if (_data.tdTypeChanges.isEmpty) {
        return null;
      }

      return _data.tdTypeChanges.removeAt(0);
    };

    ptRandom = (targets) async {
      if (_data.ptRandomIndexes.isEmpty) {
        return null;
      }

      final selectedIndex = _data.ptRandomIndexes.removeAt(0);
      if (selectedIndex == null || selectedIndex < 0 || selectedIndex >= targets.length) {
        return null;
      }
      return targets[selectedIndex];
    };

    canActivate = (result) async {
      if (_data.canActivateDecisions.isEmpty) {
        return result;
      }
      return _data.canActivateDecisions.removeAt(0);
    };

    damageRandom = (random) async {
      if (_data.damageSelections.isEmpty) {
        return random;
      }
      return _data.damageSelections.removeAt(0);
    };

    replaceMember = (onFieldSvts, backupSvts) async {
      if (_data.replaceMemberIndexes.isEmpty) {
        return null;
      }

      final selections = _data.replaceMemberIndexes.removeAt(0);
      final onFieldSvtIndex = selections.getOrNull(0) ?? -1;
      final backupSvtIndex = selections.getOrNull(1) ?? -1;

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
