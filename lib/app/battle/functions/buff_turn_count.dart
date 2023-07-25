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
    if (functionRate < battleData.options.probabilityThreshold) {
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
      battleData.withTargetSync(target, () {
        final success = _changeBuffValue(target, value, dataVals.TargetList ?? [], isTurn, true);
        battleData.curFuncResults[target.uniqueId] = success;
      });
    }
  }

  static bool _changeBuffValue(
      BattleServantData svt, int changeValue, List<int> targetIndivi, bool isTurn, bool isAny) {
    if (targetIndivi.isEmpty) return false;
    bool changed = false;
    for (final buff in svt.battleBuff.activeList) {
      if (changeValue > 0 || ((!isTurn || buff.logicTurn != 1) && (isTurn || buff.count != 1))) {
        int turn = buff.logicTurn;
        int count = buff.count;
        if (isAny && buff.buff.vals.any((trait) => targetIndivi.contains(trait.signedId))) {
          if (isTurn && turn > 0) {
            buff.logicTurn += changeValue;
          } else if (!isTurn && count > 0) {
            buff.count += changeValue;
          }
        } else if (!isAny && targetIndivi.every((id) => buff.buff.vals.any((trait) => trait.signedId == id))) {
          if (isTurn && turn > 0) {
            buff.logicTurn += changeValue;
          } else if (!isTurn && count > 0) {
            buff.count += changeValue;
          }
        }
        if (!changed) {
          changed = buff.logicTurn != turn || buff.count != count;
        }
        if (isTurn && buff.logicTurn != turn && buff.logicTurn <= 0) {
          buff.logicTurn = 1;
        } else if (!isTurn && buff.count != count && buff.count <= 0) {
          buff.count = 1;
        }
      }
    }
    return changed;
  }
}
