import 'dart:collection';

import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

int capBuffValue(BuffActionDetail buffAction, int totalVal, int maxRate) {
  var adjustValue = buffAction.baseParam + totalVal;

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

bool containsAllTraits(Iterable<NiceTrait> myTraits, Iterable<NiceTrait> requiredTraits) {
  Iterable<int> myTraitIds = myTraits.map((e) => e.signedId);
  return requiredTraits.every((trait) => myTraitIds.contains(trait.signedId) || (trait.negative && !myTraitIds.contains(trait.id)));
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
    final actionDetails = db.gameData.constData.buffActions[buffAction];
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