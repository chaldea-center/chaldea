import 'dart:math' as math;

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/constants.dart';

/// The source data marks this Heroic Spirit Portrait's +50 bond as `self`.
/// Its game effect is party-wide, so both the manual calculator and solver
/// apply the same narrow correction when resolving the target scope.
const int kHeroicSpiritPortraitDariusCeId = 9401060;
const int kBond15BonusRate = 250;

/// Automatic Grand selection is verified for the 48 Final Chapter recollection
/// battles. They allow Grand effects in every slot and one support in the team.
abstract final class BondGrandSearchRules {
  static int? autoGrandOwnedLimit(QuestPhase? quest) {
    if (quest == null || !quest.isUseGrandBoard || quest.phase != 1 || quest.id < 4000801 || quest.id > 4000848) {
      return null;
    }

    // Require explicit Grand eligibility in all six slots for automatic search.
    const allSlots = {1, 2, 3, 4, 5, 6};
    final scripted = quest.extraDetail?.isUseGrandBoardInitPos;
    if (scripted == null || scripted.length != allSlots.length || !scripted.toSet().containsAll(allSlots)) {
      return null;
    }
    for (final entry in quest.restrictions) {
      final restriction = entry.restriction;
      if (restriction.type != RestrictionType.activeGrandBoard) continue;
      if (restriction.rangeType != RestrictionRangeType.equal ||
          restriction.targetVals.length != allSlots.length ||
          !restriction.targetVals.toSet().containsAll(allSlots)) {
        return null;
      }
    }
    return 5;
  }

  static int? resolveAutoGrandLimit(QuestPhase? quest, int? requested) {
    final limit = autoGrandOwnedLimit(quest);
    return limit == null ? null : (requested ?? limit).clamp(0, limit);
  }
}

/// IDs in one family share owned-team capacity and free-choice exclusions.
/// Support capacity is independent. Keep concrete fixed IDs for presentation.
class BondCeIdentity {
  static final _traitBondIdentity = Expando<bool>();

  static const portraits = [9400970, 9400980, 9400990, 9401000, 9401010, 9401020, 9401030, 9401040, 9401050, 9401060];
  static const fsn = [9308100, 9308110, 9308120, 9308130, 9308140, 9308150, 9308160];
  static const families = <List<int>>[portraits, fsn];
  static const uniqueIds = {9403520, 9401970};
  static List<List<int>>? _lookupSource;
  static Map<int, List<int>> _familyLookup = {};
  static Map<int, List<int>> get _familyById {
    // Keep policy edits effective after hot reload without retaining old groups.
    if (!identical(_lookupSource, families)) {
      _lookupSource = families;
      _familyLookup = {
        for (final family in families)
          for (final id in family) id: family,
      };
    }
    return _familyLookup;
  }

  static int of(int id) => _familyById[id]?.first ?? id;

  /// Unrestricted generic CEs are reusable representatives. Inspect all skill
  /// variants so quest conditions and limit breaks do not change identity.
  static bool requiresUniqueOwnedIdentity(CraftEssence ce) =>
      uniqueIds.contains(ce.id) ||
      _familyById.containsKey(ce.id) ||
      (_traitBondIdentity[ce] ??= ce.skills.any(
        (skill) => skill.functions.any(
          (func) =>
              func.funcType == FuncType.servantFriendshipUp &&
              (func.functvals.isNotEmpty || func.getOverwriteTvalsList().isNotEmpty),
        ),
      ));

  static bool excluded(int id, Set<int> exclusions) {
    if (exclusions.contains(id)) return true;
    return _familyById[id]?.any(exclusions.contains) ?? false;
  }
}

/// Shared release and trait semantics for manual calculation and search.
class BondReleaseRules {
  static bool hasClosingDate(QuestPhase? quest) =>
      quest != null && quest.closedAt > 0 && quest.closedAt < kNeverClosedTimestamp;

  static BondReleaseReference resolve(BondReleaseReference reference, QuestPhase? quest) =>
      reference == BondReleaseReference.questClosedAt && !hasClosingDate(quest) ? BondReleaseReference.jp : reference;

  static Set<int>? releasedCostumeIds(Region? region) {
    if (region == null || region.isJP) return null;
    final released = db.gameData.mappingData.costumeRelease.ofRegion(region);
    return released == null || released.isEmpty ? null : released.toSet();
  }

  static int? playableLimit(Servant svt, int limit) {
    final costume = limit >= 10 ? svt.getCostume(limit) : null;
    if (costume == null) return limit;
    return costume.costumeCollectionNo > 0 ? costume.battleCharaId : null;
  }

  static List<int> ascensionLimits(Servant svt, Set<int>? releasedCostumes) {
    final candidates = <int>{
      0,
      1,
      2,
      3,
      4,
      for (final costume in svt.costume.values)
        if (costume.costumeCollectionNo > 0 &&
            (releasedCostumes == null || releasedCostumes.contains(costume.battleCharaId)))
          costume.battleCharaId,
    };
    if (releasedCostumes == null) {
      final extraLimits = svt.ascensionAdd.individuality2.all.keys.followedBy(svt.ascensionAdd.overwriteCost.all.keys);
      candidates.addAll(extraLimits.map((limit) => playableLimit(svt, limit)).nonNulls);
    }
    return candidates.toList()..sort();
  }

  static List<int> unreleasedCostumeLimits(Servant svt, Set<int>? releasedCostumes, {int? fixedLimit}) {
    if (releasedCostumes == null) return const [];
    return [
      for (final costume in svt.costume.values)
        if (costume.costumeCollectionNo > 0 &&
            costume.battleCharaId != fixedLimit &&
            !releasedCostumes.contains(costume.battleCharaId))
          costume.battleCharaId,
    ]..sort();
  }

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

extension FormationBondCampaigns on FormationBondOption {
  Iterable<({Event event, int rate})> campaignBonusesFor(int servantId) sync* {
    for (final eventEntry in campaigns.entries) {
      final event = db.gameData.events[eventEntry.key];
      if (event == null) continue;
      for (final campaign in event.campaigns) {
        if (eventEntry.value[campaign.idx] != true || campaign.target != CombineAdjustTarget.questFriendship) {
          continue;
        }
        // Quest-wide campaigns specify the applicable quests and omit servant IDs.
        if (campaign.targetIds.isNotEmpty && !campaign.targetIds.contains(servantId)) continue;
        final rate = switch (campaign.calcType) {
          EventCombineCalc.addition => math.max(0, campaign.value),
          EventCombineCalc.multiplication => math.max(0, campaign.value - 1000),
          EventCombineCalc.fixedValue || EventCombineCalc.none => 0,
        };
        if (rate != 0) yield (event: event, rate: rate);
      }
    }
  }
}

/// Resolves a servant's active event passive skills that grant bond bonuses.
extension ServantBondEffects on Servant {
  List<NiceSkill> resolveBondEventSkills(QuestPhase quest, {int? logicEventId}) {
    final grouped = <int, Map<int, NiceSkill>>{};
    for (final skill in extraPassive) {
      if (skill.id == 970663) continue; // Bond 15 passive is handled separately.
      for (final passive in skill.extraPassive) {
        if (passive.startedAt > quest.closedAt || passive.endedAt < quest.openedAt) continue;
        final eventIds = passive.getValidEventIds();
        if (eventIds.isNotEmpty && !eventIds.contains(logicEventId ?? quest.logicEventId ?? 0)) continue;
        grouped.putIfAbsent(passive.num, () => {})[passive.priority] = skill;
      }
    }
    return [for (final priorities in grouped.values) priorities[priorities.keys.reduce((a, b) => a > b ? a : b)]!];
  }
}
