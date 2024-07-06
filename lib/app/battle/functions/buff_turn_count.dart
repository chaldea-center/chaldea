import 'dart:math';

import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/models.dart';
import '../models/battle.dart';

// FuncType.shortenBuffturn:
// FuncType.extendBuffturn:
// FuncType.shortenBuffcount:
// FuncType.extendBuffcount:
class BuffTurnCount {
  const BuffTurnCount._();

  static void changeBuffValue(
    final BattleData battleData,
    final FuncType funcType,
    final DataVals dataVals,
    final List<BattleServantData> targets,
  ) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    int value = dataVals.Value ?? 0;
    final bool isTurn = funcType == FuncType.shortenBuffturn || funcType == FuncType.extendBuffturn;
    final bool isShorten = funcType == FuncType.shortenBuffturn || funcType == FuncType.shortenBuffcount;
    if (isShorten) {
      value *= -1;
    }
    if (isTurn) {
      value *= 2;
    }
    for (final target in targets) {
      final success = _changeBuffValue(battleData, target, value, dataVals, isTurn, true);
      battleData.setFuncResult(target.uniqueId, success);
    }
  }

  static bool _changeBuffValue(
    final BattleData battleData,
    final BattleServantData svt,
    final int changeValue,
    final DataVals dataVals,
    final bool isTurn,
    final bool isAny,
  ) {
    final List<int> targetIndivi = dataVals.TargetList ?? [];
    if (targetIndivi.isEmpty) return false;

    final List<NiceTrait> targetTraits = targetIndivi.map((targetIndiv) => NiceTrait(id: targetIndiv)).toList();
    bool changed = false;

    final matchFunc = isAny ? partialMatch : allMatch;

    for (final buff in svt.battleBuff.getActiveList()) {
      if (dataVals.IgnoreIndivUnreleaseable == 1 && buff.irremovable) {
        continue;
      }
      final traitCheck = checkTraitFunction(
        myTraits: buff.traits,
        requiredTraits: targetTraits,
        positiveMatchFunc: matchFunc,
        negativeMatchFunc: matchFunc,
      );
      if (traitCheck) {
        final minValue = dataVals.AllowRemoveBuff == 1 ? 0 : 1;
        if (isTurn && buff.logicTurn > 0) {
          buff.logicTurn = max(buff.logicTurn + changeValue, minValue);
          changed = true;
        } else if (!isTurn && buff.count > 0) {
          buff.count = max(buff.count + changeValue, minValue);
          changed = true;
        }
      }
    }

    return changed;
  }
}
