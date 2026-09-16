import 'dart:collection';

import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/gamedata/individuality.dart';

import '../models/svt_entity.dart';

int capBuffValue(BuffActionInfo buffAction, int totalVal, int? maxRate, [int? minRate]) {
  int adjustValue = buffAction.baseParam + totalVal;

  if (buffAction.limit == BuffLimit.normal || buffAction.limit == BuffLimit.lower) {
    final lowerLimit = minRate ?? 0;
    if (adjustValue < lowerLimit) {
      adjustValue = lowerLimit;
    }
  }

  adjustValue = adjustValue - buffAction.baseValue;

  if (buffAction.limit == BuffLimit.normal || buffAction.limit == BuffLimit.upper) {
    if (maxRate != null && maxRate < adjustValue) {
      adjustValue = maxRate;
    }
  }

  return adjustValue;
}

int countAnyTraits(Iterable<int> myTraits, Iterable<int> requiredTraits) {
  if (requiredTraits.isEmpty) {
    return 0;
  }

  return myTraits
      .where(
        (myTrait) => requiredTraits.any(
          (requiredTrait) => myTrait == requiredTrait || (requiredTrait < 0 && myTrait.abs() != requiredTrait.abs()),
        ),
      )
      .length;
}

@Deprecated('Use `Individuality.checkSignedIndividualitiesPartialMatch` instead')
bool checkSignedIndividualitiesPartialMatch({
  required Iterable<int> myTraits,
  required Iterable<int> requiredTraits,
  bool Function(Iterable<int>, Iterable<int>) positiveMatchFunc = partialMatch,
  bool Function(Iterable<int>, Iterable<int>) negativeMatchFunc = partialMatch,
}) {
  final positiveTargets = requiredTraits.where((trait) => trait >= 0).toList();
  final negativeTargets = requiredTraits.where((trait) => trait < 0).toList();

  if (requiredTraits.isEmpty) return true;
  if (positiveMatchFunc(myTraits, positiveTargets)) return true;
  if (negativeTargets.isEmpty) return false;
  return !negativeMatchFunc(myTraits, negativeTargets);
}

@Deprecated(
  'Use `Individuality.checkSignedIndividualities2/checkSignedIndivPartialMatch/checkSignedIndivAllMatch` instead',
)
bool checkSignedIndividualities2({
  required Iterable<int>? myTraits,
  required Iterable<int>? requiredTraits,
  bool Function(Iterable<int>, Iterable<int>) positiveMatchFunc = partialMatch,
  bool Function(Iterable<int>, Iterable<int>) negativeMatchFunc = partialMatch,
}) {
  return Individuality.checkSignedIndividualities2(
    self: myTraits?.toList(),
    signedTarget: requiredTraits?.toList(),
    matchedFunc: positiveMatchFunc == partialMatch ? Individuality.isPartialMatchArray : Individuality.isMatchArray,
    mismatchFunc: positiveMatchFunc == partialMatch ? Individuality.isPartialMatchArray : Individuality.isMatchArray,
  );
}

@Deprecated('Use `Individuality.isPartialMatchArray` instead')
bool partialMatch(Iterable<int> myTraits, Iterable<int> unsignedRequiredTraits) {
  final Set<int> myTraitsSet = myTraits.toSet();
  for (final trait in unsignedRequiredTraits) {
    if (myTraitsSet.contains(trait.abs())) {
      return true;
    }
  }
  return false;
}

@Deprecated('Use `Individuality.isMatchArray` instead')
bool allMatch(Iterable<int> myTraits, Iterable<int> unsignedRequiredTraits) {
  final Set<int> myTraitsSet = myTraits.toSet();
  for (final trait in unsignedRequiredTraits) {
    if (!myTraitsSet.contains(trait.abs())) {
      return false;
    }
  }
  return true;
}

List<BuffData> collectBuffsPerAction(Iterable<BuffData> buffs, BuffAction buffAction) {
  return collectBuffsPerActions(buffs, [buffAction]);
}

List<BuffData> collectBuffsPerType(Iterable<BuffData> buffs, BuffType buffType) {
  return collectBuffsPerTypes(buffs, [buffType]);
}

List<BuffData> collectBuffsPerActions(Iterable<BuffData> buffs, Iterable<BuffAction> buffActions) {
  final allBuffTypes = HashSet<BuffType>();
  for (final buffAction in buffActions) {
    final actionDetails = ConstData.buffActions[buffAction];
    if (actionDetails == null) {
      continue;
    }

    allBuffTypes.addAll(actionDetails.plusTypes);
    allBuffTypes.addAll(actionDetails.minusTypes);
  }

  return collectBuffsPerTypes(buffs, allBuffTypes);
}

List<BuffData> collectBuffsPerTypes(Iterable<BuffData> buffs, Iterable<BuffType> buffTypes) {
  return buffs.where((buff) => buffTypes.contains(buff.buff.type)).toList();
}

class CheckTraitParameters {
  Iterable<int> requiredTraits;
  BattleServantData? actor;
  int? requireAtLeast; // overshadows positive & negative match
  bool Function(List<int>?, List<int>?) positiveMatchFunction;
  bool Function(List<int>?, List<int>?) negativeMatchFunction;

  bool checkActorTraits;
  bool checkActorBuffTraits;
  bool checkActiveBuffOnly;
  bool ignoreIrremovableBuff;
  bool checkActorNpTraits;
  bool checkCurrentBuffTraits;
  bool checkCurrentCardTraits;
  bool checkCurrentFuncTraits;
  bool checkQuestTraits;

  CheckTraitParameters({
    required Iterable<int> requiredTraits,
    this.actor,
    this.requireAtLeast,
    this.checkActorTraits = false,
    this.checkActorBuffTraits = false,
    this.checkActiveBuffOnly = false,
    this.ignoreIrremovableBuff = false,
    this.checkActorNpTraits = false,
    this.checkCurrentBuffTraits = false,
    this.checkCurrentCardTraits = false,
    this.checkCurrentFuncTraits = false,
    this.checkQuestTraits = false,
    this.positiveMatchFunction = Individuality.isPartialMatchArray,
    this.negativeMatchFunction = Individuality.isPartialMatchArray,
  }) : requiredTraits = requiredTraits.toList();
}
