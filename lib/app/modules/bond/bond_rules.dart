import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/constants.dart';

/// The source data marks this Heroic Spirit Portrait's +50 bond as `self`.
/// Its game effect is party-wide, so both the manual calculator and solver
/// apply the same narrow correction when resolving the target scope.
const int kHeroicSpiritPortraitDariusCeId = 9401060;

/// IDs in one family share owned-team capacity and free-choice exclusions.
/// Support capacity is independent. Keep concrete fixed IDs for presentation.
class BondCeIdentity {
  static const families = <List<int>>[
    [9308100, 9308110, 9308120, 9308130, 9308140, 9308150, 9308160],
  ];

  static int of(int id) {
    for (final family in families) {
      if (family.contains(id)) return family.first;
    }
    return id;
  }

  static bool excluded(int id, Set<int> exclusions) {
    if (exclusions.contains(id)) return true;
    for (final family in families) {
      if (family.contains(id)) return family.any(exclusions.contains);
    }
    return false;
  }
}

/// Shared release and trait semantics for manual calculation and search.
class BondReleaseRules {
  static bool hasClosingDate(QuestPhase? quest) =>
      quest != null && quest.closedAt > 0 && quest.closedAt < kNeverClosedTimestamp;

  static BondReleaseReference resolve(BondReleaseReference reference, QuestPhase? quest) =>
      reference == BondReleaseReference.questClosedAt && !hasClosingDate(quest) ? BondReleaseReference.jp : reference;

  static List<int> traits(Servant svt, int limit, int eventId, BondReleaseReference reference) {
    // Copy first: filtering must never mutate the shared game dataset.
    final traits = List<int>.of(svt.getAscended(limit, (a) => a.individuality2) ?? svt.traits);
    for (final add in svt.traitAdd) {
      if (add.eventId != 0 && add.eventId != eventId) continue;
      if (add.limitCount != -1 && svt.battleCharaToLimitCount(limit) != add.limitCount) continue;
      traits.addAll(add.trait);
    }
    final region = reference.region;
    if (!region.isJP &&
        traits.contains(Trait.hasCostume.value) &&
        !db.gameData.mappingData.isSvtTraitRelease(
          svtCollectionNo: svt.collectionNo,
          trait: Trait.hasCostume.value,
          region: region,
        )) {
      traits.removeWhere((trait) => trait == Trait.hasCostume.value);
    }
    return traits.toSet().toList()..sort();
  }
}
