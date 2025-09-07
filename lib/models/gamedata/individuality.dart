import 'package:flutter/foundation.dart' show protected;

import 'package:chaldea/utils/extension.dart';
import 'common.dart';

abstract class Individuality {
  static bool containsAllAB(List<NiceTrait> selfs, List<int> targets, {bool signed = true}) {
    return selfs.map((e) => signed ? e.signedId : e.id).toSet().containSubset(targets.toSet());
  }

  static bool checkSignedIndividualities({required List<int>? self, required List<int>? signedTarget}) {
    bool result = true;
    if (signedTarget != null && self != null && signedTarget.isNotEmpty) {
      if (self.isNotEmpty) {
        final (:unsignedArray, :signedArray) = Individuality.divideUnsignedAndSignedArray(signedTarget);
        bool v11, v13;
        if (unsignedArray.isNotEmpty) {
          v11 = Individuality.isPartialMatchArray(self, unsignedArray);
        } else {
          v11 = true;
        }
        if (signedArray.isNotEmpty) {
          v13 = !Individuality.isPartialMatchArray(self, signedArray);
        } else {
          v13 = true;
        }
        return v13 && v11;
      } else {
        return false;
      }
    }
    return result;
  }

  static bool checkSignedIndividualities2({
    required List<int>? self,
    required List<int>? signedTarget,
    required bool Function(List<int>? selfs, List<int>? targets) matchedFunc,
    required bool Function(List<int>? selfs, List<int>? targets) mismatchFunc,
  }) {
    bool result = true;
    if (signedTarget != null && self != null && signedTarget.isNotEmpty) {
      if (self.isEmpty) return false;
      final (:unsignedArray, :signedArray) = Individuality.divideUnsignedAndSignedArray(signedTarget);

      bool v12;
      if (unsignedArray.isNotEmpty) {
        v12 = matchedFunc(self, unsignedArray);
      } else {
        v12 = true;
      }

      bool v13;
      if (signedArray.isEmpty) {
        v13 = true;
      } else {
        v13 = !mismatchFunc(self, signedArray);
      }
      return v13 && v12;
    }
    return result;
  }

  static bool checkSignedIndivPartialMatch({required List<int>? self, required List<int>? signedTarget}) {
    return checkSignedIndividualities2(
      self: self,
      signedTarget: signedTarget,
      matchedFunc: Individuality.isPartialMatchArray,
      mismatchFunc: Individuality.isPartialMatchArray,
    );
  }

  static bool checkSignedIndivAllMatch({required List<int>? self, required List<int>? signedTarget}) {
    return checkSignedIndividualities2(
      self: self,
      signedTarget: signedTarget,
      matchedFunc: Individuality.isMatchArray,
      mismatchFunc: Individuality.isMatchArray,
    );
  }

  static ({List<int> unsignedArray, List<int> signedArray}) divideUnsignedAndSignedArray(List<int> baseArray) {
    List<int> unsignedArray = [], signedArray = [];
    for (final x in baseArray) {
      if (x < 1) {
        signedArray.add(-x);
      } else {
        unsignedArray.add(x);
      }
    }
    return (unsignedArray: unsignedArray, signedArray: signedArray);
  }

  static bool checkIndividualities({required List<int>? self, required List<int>? target}) {
    if (target == null || target.isEmpty) return true;
    if (self == null) return true;
    if (self.isEmpty) return false;
    for (final x in self) {
      for (final y in target) {
        if (x == y) return true;
      }
    }
    return false;
  }

  static bool containsIndividualities({required List<int>? self, required List<int>? target}) {
    if (target == null || target.isEmpty) return true;
    if (self == null) return true;
    if (self.isEmpty) return false;
    // int count = 0;
    // for (final x in self) {
    //   if (target.contains(x)) {
    //     count++;
    //   }
    // }
    // return count >= target.length;
    return target.every(self.contains);
  }

  // named [CheckAllIndividualities] before
  static bool containsAllIndividualities({required List<int>? self, required List<int>? target}) {
    if (self == null) return false;
    if (target == null) return true;
    if (self.isEmpty) return false;
    if (target.isEmpty) return true;

    for (final y in target) {
      if (!self.contains(y)) {
        return false;
      }
    }
    return true;
  }

  static bool isPartialMatchArray(List<int>? selfs, List<int>? targets) {
    bool result = false;
    if (selfs != null && targets != null && selfs.isNotEmpty) {
      for (final selfNum in selfs) {
        for (final targetNum in targets) {
          if (selfNum == targetNum) return true;
        }
      }
    }
    return result;
  }

  static bool isMatchArray(List<int>? selfs, List<int>? targets) {
    bool result = false;
    if (selfs != null && targets != null) {
      if (targets.isEmpty) {
        result = true;
      } else {
        result = true;
        for (final targetNum in targets) {
          if (!selfs.contains(targetNum)) {
            result = false;
          }
        }
      }
    }
    return result;
  }

  @protected
  static bool isPreIndividualitiesCount({
    required List<int>? selfs,
    required List<int>? targets,
    required int countAbove,
    required int countBelow,
    required Ref<bool> ret,
    bool isSkipPreCheckSelfEmpty = false,
  }) {
    bool result = true;
    ret.value = true;
    if (targets != null) {
      if (countAbove > 0 || countBelow > 0) {
        result = true;
        if (selfs != null) {
          if (targets.isNotEmpty) {
            result = false;
            if (selfs.isEmpty && !isSkipPreCheckSelfEmpty) {
              result = true;
              ret.value = false;
            }
          }
        }
      }
    }
    return result;
  }

  // 计算selfs数组中每个元素在targets数组中出现的次数，返回一个与targets数组长度相同的数组，其中每个位置记录selfs中等于该位置targets元素的个数。
  static List<int> _getMatchedCountArray({required List<int> selfs, required List<int> targets}) {
    final result = List<int>.filled(targets.length, 0);
    for (final selfValue in selfs) {
      for (int i = 0; i < targets.length; i++) {
        if (selfValue == targets[i]) {
          result[i] = result[i] + 1;
        }
      }
    }
    return result;
  }

  static bool isPartialMatchArrayCount(List<int>? selfs, List<int>? targets, int countAbove, int countBelow) {
    bool result = true;
    if (targets != null) {
      if (countAbove > 0 || countBelow > 0) {
        result = true;
        if (selfs != null) {
          if (targets.isNotEmpty) {
            if (selfs.isNotEmpty) {
              final matchedCountArray = Individuality._getMatchedCountArray(selfs: selfs, targets: targets);
              return matchedCountArray.any((count) {
                if (countAbove < 1) {
                  if (countBelow < 1) return false;
                } else {
                  if (countBelow < 1) return countAbove <= count;
                  if (countAbove > count) return false;
                }
                return countBelow >= count;
              });
            } else {
              return false;
            }
          }
        }
      }
    }
    return result;
  }

  static bool isMatchArrayCount(List<int>? selfs, List<int>? targets, int countAbove, int countBelow) {
    if (countAbove <= 0 && countBelow <= 0) return true;
    if (targets == null || targets.isEmpty) return true;
    if (selfs == null || selfs.isEmpty) return false;

    final countArray = Individuality._getMatchedCountArray(selfs: selfs, targets: targets);

    for (final count in countArray) {
      if (countAbove > 0 && countBelow > 0) {
        if (count < countAbove || count > countBelow) {
          return false;
        }
      } else if (countAbove > 0) {
        if (count < countAbove) {
          return false;
        }
      } else if (countBelow > 0) {
        if (count > countBelow) {
          return false;
        }
      }
    }

    return true;
  }

  static bool checkSignedIndividualitiesCount({
    required List<int>? selfs,
    required List<int>? targets,
    required bool Function(List<int>? selfs, List<int>? targets, int countAbove, int countBelow) matchedFunc,
    required bool Function(List<int>? selfs, List<int>? targets, int countAbove, int countBelow) mismatchFunc,
    required int countAbove,
    required int countBelow,
  }) {
    bool result = true;
    if (targets != null && (countAbove > 0 || countBelow > 0)) {
      result = true;
      if (selfs != null) {
        if (targets.isNotEmpty) {
          if (selfs.isEmpty) return false;
          final (:unsignedArray, :signedArray) = Individuality.divideUnsignedAndSignedArray(targets);
          bool v16;
          if (unsignedArray.isNotEmpty) {
            v16 = matchedFunc(selfs, unsignedArray, countAbove, countBelow);
          } else {
            v16 = true;
          }

          bool v17;
          if (signedArray.isEmpty) {
            v17 = true;
            return v17 && v16;
          }
          v17 = mismatchFunc(selfs, signedArray, countAbove, countBelow);
          return v17 && v16;
        }
      }
    }
    return result;
  }

  static bool checkSignedIndividualitiesPartialCount({
    required List<int>? selfs,
    required List<int>? targets,
    required bool Function(List<int>? selfs, List<int>? targets, int countAbove, int countBelow) matchedFunc,
    required bool Function(List<int>? selfs, List<int>? targets, int countAbove, int countBelow) mismatchFunc,
    required int countAbove,
    required int countBelow,
  }) {
    bool result = true;
    if (targets != null && (countAbove > 0 || countBelow > 0)) {
      result = true;
      if (selfs != null) {
        if (targets.isNotEmpty) {
          final (:unsignedArray, :signedArray) = Individuality.divideUnsignedAndSignedArray(targets);
          if (unsignedArray.isNotEmpty) {
            return matchedFunc(selfs, unsignedArray, countAbove, countBelow);
          }
          if (signedArray.isEmpty) return false;
          return !mismatchFunc(selfs, signedArray, countAbove, countBelow);
        }
      }
    }
    return result;
  }

  @protected
  static bool isPreIndividualitiesCheck({
    required List<int>? selfs,
    required List<int>? targets,
    required Ref<bool> result,
    bool isSkipPreCheckSelfsEmpty = false,
  }) {
    result.value = true;
    bool v8 = selfs == null || targets == null || targets.isEmpty;
    if (!v8 && !isSkipPreCheckSelfsEmpty) {
      if (selfs.isNotEmpty) {
        v8 = false;
      } else {
        v8 = true;
        result.value = false;
      }
    }
    return v8;
  }

  static bool checkSignedIndividualitiesPartialMatch({
    required List<int>? selfs,
    required List<int>? signedTargets,
    required bool Function(List<int> selfs, List<int> targets) matchedFunc,
    required bool Function(List<int> selfs, List<int> targets) mismatchFunc,
    bool isSkipPreCheckSelfsEmpty = false,
  }) {
    bool v12 = selfs == null || (signedTargets == null || signedTargets.isEmpty);
    if (v12 || isSkipPreCheckSelfsEmpty) {
      if (v12) return true;
    } else if (selfs.isEmpty) {
      return false;
    }
    final (:unsignedArray, :signedArray) = Individuality.divideUnsignedAndSignedArray(signedTargets);
    if (unsignedArray.isNotEmpty) {
      if (matchedFunc(selfs, unsignedArray)) {
        return true;
      }
    }
    if (signedArray.isEmpty) return false;
    return !mismatchFunc(selfs, signedArray);
  }

  static bool checkSignedMultiIndividuality({
    required List<int>? selfArray,
    required List<List<int>>? signedTargetsArray,
  }) {
    if (signedTargetsArray == null || signedTargetsArray.isEmpty) return true;
    return signedTargetsArray.any((signedTargets) {
      return Individuality.checkSignedIndividualities2(
        self: selfArray,
        signedTarget: signedTargets,
        matchedFunc: Individuality.isMatchArray,
        mismatchFunc: Individuality.isMatchArray,
      );
    });
  }

  static int getMatchedTotalCount({required List<int> selfs, required List<int> targets}) {
    List<int> matchedCountArray = Individuality._getMatchedCountArray(selfs: selfs, targets: targets);

    int total = 0;
    for (final count in matchedCountArray) {
      total += count;
    }

    return total;
  }

  static int getMatchedTotalCountMultiIndividuality(
    List<int> selfIndividualityArray,
    List<List<int>> targetMultiIndividualityArray,
  ) {
    if (targetMultiIndividualityArray.isEmpty) return 0;
    int count = 0;
    for (final v8 in targetMultiIndividualityArray) {
      bool _matched = Individuality.isMatchArray(selfIndividualityArray, v8);
      if (_matched) count++;
    }
    return count;
  }

  /// added for ParamAddSelfIndividualityAndCheck / ParamAddOpIndividualityAndCheck etc.
  /// Can reference BattleBuffData__GetParamAddCountSignedIndividualityAndCheck
  static int getSignedMatchedTotalCountMultiIndividuality(
    List<int> selfIndividualityArray,
    List<List<int>> targetMultiIndividualityArray,
  ) {
    if (targetMultiIndividualityArray.isEmpty) return 0;
    int count = 0;
    for (final signedTargets in targetMultiIndividualityArray) {
      bool _matched = Individuality.checkSignedIndividualities2(
        self: selfIndividualityArray,
        signedTarget: signedTargets,
        matchedFunc: Individuality.isMatchArray,
        mismatchFunc: Individuality.isPartialMatchArray,
      );
      if (_matched) count++;
    }
    return count;
  }

  @protected
  static bool isMatchAboveBelow(int count, int above, int below) {
    if (above < 1) {
      if (below < 1) return false;
    } else {
      if (below < 1) return count >= above;
      if (count < above) return false;
    }
    return count <= below;
  }

  static bool isMatchAboveBelowEqual(int count, int above, int below, int equal) {
    if (above < 1) {
      if (below < 1) return count == equal;
    } else {
      if (below < 1) {
        if (count >= above) return true;
        return count == equal;
      }
      if (count < above) return count == equal;
    }
    if (count <= below) return true;
    return count == equal;
  }

  static bool isServantClassIndividuality(int v) {
    return v - 100 < 100;
  }
}
