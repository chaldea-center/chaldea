import 'dart:collection';

import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

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
