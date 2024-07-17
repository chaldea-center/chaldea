import 'dart:collection';

import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
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

int countAnyTraits(final Iterable<NiceTrait> myTraits, final Iterable<NiceTrait> requiredTraits) {
  if (requiredTraits.isEmpty) {
    return 0;
  }

  return myTraits
      .where((myTrait) => requiredTraits.any((requiredTrait) =>
          myTrait.signedId == requiredTrait.signedId || (requiredTrait.negative && myTrait.id != requiredTrait.id)))
      .length;
}

bool checkTraitFunction({
  required final Iterable<NiceTrait> myTraits,
  required final Iterable<NiceTrait> requiredTraits,
  final bool Function(Iterable<NiceTrait>, Iterable<NiceTrait>) positiveMatchFunc = partialMatch,
  final bool Function(Iterable<NiceTrait>, Iterable<NiceTrait>) negativeMatchFunc = partialMatch,
}) {
  final positiveTargets = requiredTraits.where((trait) => trait.signedId > 0);
  final negativeTargets = requiredTraits.where((trait) => trait.signedId < 0);

  if (requiredTraits.isEmpty) return true;
  if (positiveMatchFunc(myTraits, positiveTargets)) return true;
  if (negativeTargets.isEmpty) return false;
  return !negativeMatchFunc(myTraits, negativeTargets);
}

bool partialMatch(final Iterable<NiceTrait> myTraits, final Iterable<NiceTrait> unsignedRequiredTraits) {
  final Set<int> myTraitsSet = myTraits.map((trait) => trait.id).toSet();
  for (final required in unsignedRequiredTraits) {
    if (myTraitsSet.contains(required.id)) {
      return true;
    }
  }
  return false;
}

bool allMatch(final Iterable<NiceTrait> myTraits, final Iterable<NiceTrait> unsignedRequiredTraits) {
  final Set<int> myTraitsSet = myTraits.map((trait) => trait.id).toSet();
  for (final required in unsignedRequiredTraits) {
    if (!myTraitsSet.contains(required.id)) {
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
  Iterable<NiceTrait> requiredTraits;
  BattleServantData? actor;
  int? requireAtLeast; // overshadows positive & negative match
  bool Function(Iterable<NiceTrait>, Iterable<NiceTrait>) positiveMatchFunction;
  bool Function(Iterable<NiceTrait>, Iterable<NiceTrait>) negativeMatchFunction;

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
    required final Iterable<NiceTrait> requiredTraits,
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
