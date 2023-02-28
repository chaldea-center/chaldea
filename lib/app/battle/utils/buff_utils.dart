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

bool checkTrait(Iterable<NiceTrait> myTraits, Iterable<NiceTrait> requiredTraits) {
  Iterable<int> traitIds = myTraits.map((e) => e.id);

  for (NiceTrait trait in requiredTraits) {
    final containsTrait = traitIds.contains(trait.id);
    if ((trait.negative && containsTrait) || (!trait.negative && !containsTrait)) {
      return false;
    }
  }
  return true;
}
