import 'dart:collection';

import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

import '../models/svt_entity.dart';

int capBuffValue(final BuffActionDetail buffAction, final int totalVal, final int maxRate) {
  int adjustValue = buffAction.baseParam + totalVal;

  if (buffAction.limit == BuffLimit.normal || buffAction.limit == BuffLimit.lower) {
    if (adjustValue < 0) {
      adjustValue = 0;
    }
  }

  adjustValue = adjustValue - buffAction.baseValue;

  if (buffAction.limit == BuffLimit.normal || buffAction.limit == BuffLimit.upper) {
    if (maxRate < adjustValue) {
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

bool containsAnyTraits(final Iterable<NiceTrait> myTraits, final Iterable<NiceTrait> requiredTraits) {
  if (requiredTraits.isEmpty) {
    return true;
  }

  final Iterable<int> myTraitIds = myTraits.map((e) => e.signedId);
  return requiredTraits
      .any((trait) => myTraitIds.contains(trait.signedId) || (trait.negative && !myTraitIds.contains(trait.id)));
}

bool containsAllTraits(final Iterable<NiceTrait> myTraits, final Iterable<NiceTrait> requiredTraits) {
  final Iterable<int> myTraitIds = myTraits.map((e) => e.signedId);
  return requiredTraits
      .every((trait) => myTraitIds.contains(trait.signedId) || (trait.negative && !myTraitIds.contains(trait.id)));
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
  int checkIndivType;

  bool checkActorTraits;
  bool checkActorBuffTraits;
  bool checkActiveBuffOnly;
  bool ignoreIrremovableBuff;
  bool checkActorNpTraits;
  bool checkCurrentBuffTraits;
  bool checkCurrentCardTraits;
  bool checkQuestTraits;

  bool tempAddSvtId;

  CheckTraitParameters({
    required final Iterable<NiceTrait> requiredTraits,
    this.actor,
    this.checkIndivType = 0,
    this.checkActorTraits = false,
    this.checkActorBuffTraits = false,
    this.checkActiveBuffOnly = false,
    this.ignoreIrremovableBuff = false,
    this.checkActorNpTraits = false,
    this.checkCurrentBuffTraits = false,
    this.checkCurrentCardTraits = false,
    this.checkQuestTraits = false,
    this.tempAddSvtId = false,
  }) : requiredTraits = requiredTraits.toList();
}
