import 'dart:collection';

import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/gamedata/individuality.dart';
import '../models/svt_entity.dart';

int capBuffValue(final BuffActionInfo buffAction, final int totalVal, final int? maxRate) {
  int adjustValue = buffAction.baseParam + totalVal;

  if (buffAction.limit == BuffLimit.normal || buffAction.limit == BuffLimit.lower) {
    if (adjustValue < 0) {
      adjustValue = 0;
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

int countAnyTraits(final Iterable<int> myTraits, final Iterable<int> requiredTraits) {
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

bool checkSignedIndividualitiesPartialMatch({
  required final Iterable<int> myTraits,
  required final Iterable<int> requiredTraits,
  final bool Function(Iterable<int>, Iterable<int>) positiveMatchFunc = partialMatch,
  final bool Function(Iterable<int>, Iterable<int>) negativeMatchFunc = partialMatch,
}) {
  final positiveTargets = requiredTraits.where((trait) => trait >= 0).toList();
  final negativeTargets = requiredTraits.where((trait) => trait < 0).toList();

  if (requiredTraits.isEmpty) return true;
  if (positiveMatchFunc(myTraits, positiveTargets)) return true;
  if (negativeTargets.isEmpty) return false;
  return !negativeMatchFunc(myTraits, negativeTargets);
}

bool checkSignedIndividualities2({
  required final Iterable<int> myTraits,
  required final Iterable<int> requiredTraits,
  final bool Function(Iterable<int>, Iterable<int>) positiveMatchFunc = partialMatch,
  final bool Function(Iterable<int>, Iterable<int>) negativeMatchFunc = partialMatch,
}) {
  return Individuality.checkSignedIndividualities2(
    self: myTraits.toList(),
    signedTarget: requiredTraits.toList(),
    matchedFunc: positiveMatchFunc == partialMatch ? Individuality.isPartialMatchArray : Individuality.isMatchArray,
    mismatchFunc: positiveMatchFunc == partialMatch ? Individuality.isPartialMatchArray : Individuality.isMatchArray,
  );
}

bool partialMatch(final Iterable<int> myTraits, final Iterable<int> unsignedRequiredTraits) {
  final Set<int> myTraitsSet = myTraits.toSet();
  for (final trait in unsignedRequiredTraits) {
    if (myTraitsSet.contains(trait.abs())) {
      return true;
    }
  }
  return false;
}

bool allMatch(final Iterable<int> myTraits, final Iterable<int> unsignedRequiredTraits) {
  final Set<int> myTraitsSet = myTraits.toSet();
  for (final trait in unsignedRequiredTraits) {
    if (!myTraitsSet.contains(trait.abs())) {
      return false;
    }
  }
  return true;
}

List<BuffData> collectBuffsPerAction(final Iterable<BuffData> buffs, final BuffAction buffAction) {
  return collectBuffsPerActions(buffs, [buffAction]);
}

List<BuffData> collectBuffsPerType(final Iterable<BuffData> buffs, final BuffType buffType) {
  return collectBuffsPerTypes(buffs, [buffType]);
}

List<BuffData> collectBuffsPerActions(final Iterable<BuffData> buffs, final Iterable<BuffAction> buffActions) {
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

List<BuffData> collectBuffsPerTypes(final Iterable<BuffData> buffs, final Iterable<BuffType> buffTypes) {
  return buffs.where((buff) => buffTypes.contains(buff.buff.type)).toList();
}

class CheckTraitParameters {
  Iterable<int> requiredTraits;
  BattleServantData? actor;
  int? requireAtLeast; // overshadows positive & negative match
  bool Function(Iterable<int>, Iterable<int>) positiveMatchFunction;
  bool Function(Iterable<int>, Iterable<int>) negativeMatchFunction;

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
    required final Iterable<int> requiredTraits,
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
    this.positiveMatchFunction = partialMatch,
    this.negativeMatchFunction = partialMatch,
  }) : requiredTraits = requiredTraits.toList();
}
