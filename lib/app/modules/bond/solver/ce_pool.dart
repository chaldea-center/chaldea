import 'package:chaldea/models/gamedata/individuality.dart' show Individuality;
import 'package:chaldea/models/models.dart';

/// Target scope of a bond effect extracted from a `servantFriendshipUp` function.
enum BondEffectScope { self, team }

/// One bond-relevant effect atom parsed from a CE's `servantFriendshipUp` function.
///
/// Semantics mirror `FormationBondTab.calcResults` exactly:
/// - Wearer-side conditions: [wearerActIndiv] (skill.actIndividuality) and
///   [wearerRequiredIndiv] (vals.Individuality) are checked independently with
///   SIGNED PARTIAL match against the wearer's traits.
/// - Target-side conditions: either [targetOrAll] (overWriteTvalsList — OR of AND
///   lists, SIGNED ALL match) or [targetPartial] (functvals — SIGNED PARTIAL match).
///   Both empty means unconditional.
/// - For [BondEffectScope.self] effects the target IS the wearer, so target
///   conditions apply to the wearer as well.
class CeBondEffect {
  final BondEffectScope scope;
  final int rate;
  final int value;

  /// wearer-side condition 1: skill.actIndividuality (partial match, AND with indiv)
  final List<int> wearerActIndiv;

  /// wearer-side condition 2: vals.Individuality (partial match), 0 = none
  final int wearerRequiredIndiv;

  /// target-side condition: overWriteTvalsList — OR of AND lists (all match)
  final List<List<int>> targetOrAll;

  /// target-side condition: functvals (partial match)
  final List<int> targetPartial;

  const CeBondEffect({
    required this.scope,
    required this.rate,
    required this.value,
    this.wearerActIndiv = const [],
    this.wearerRequiredIndiv = 0,
    this.targetOrAll = const [],
    this.targetPartial = const [],
  });

  bool get isFlat => wearerActIndiv.isEmpty && wearerRequiredIndiv == 0 && targetOrAll.isEmpty && targetPartial.isEmpty;

  bool get hasCondition => !isFlat;

  /// Whether the effect has receiver-side (target) conditions — the wearer-side
  /// conditions ([wearerActIndiv]/[wearerRequiredIndiv]) are a separate axis.
  bool get hasTargetCondition => targetOrAll.isNotEmpty || targetPartial.isNotEmpty;

  /// Whether the given [traits] satisfy the wearer-side conditions.
  bool wearerMatches(List<int> traits) {
    if (wearerActIndiv.isNotEmpty &&
        !Individuality.checkSignedIndivPartialMatch(self: traits, signedTarget: wearerActIndiv)) {
      return false;
    }
    if (wearerRequiredIndiv != 0 &&
        !Individuality.checkSignedIndivPartialMatch(self: traits, signedTarget: [wearerRequiredIndiv])) {
      return false;
    }
    return true;
  }

  /// Whether the given [traits] satisfy the target-side conditions.
  /// Unconditional effects always match.
  bool targetMatches(List<int> traits) {
    if (targetOrAll.isNotEmpty) {
      return targetOrAll.any((and) => Individuality.checkSignedIndivAllMatch(self: traits, signedTarget: and));
    }
    if (targetPartial.isNotEmpty) {
      return Individuality.checkSignedIndivPartialMatch(self: traits, signedTarget: targetPartial);
    }
    return true;
  }

  /// Whether a no-trait placeholder (support slot) satisfies every condition.
  /// The empty trait list matches nothing, so only unconditional effects qualify.
  bool get matchesNoTraitPlaceholder => isFlat;
}

/// A support-slot CE candidate: worn by a no-trait placeholder servant.
/// Only team-scope effects matter (the support slot itself yields no bond).
class SupportCeCandidate {
  final CraftEssence ce;

  /// whether the enrolled variant is the limit-broken one
  final bool limitBreak;

  /// flat team rate contribution (no target conditions)
  final int flatTeamRate;

  /// flat team value contribution (no target conditions)
  final int flatTeamValue;

  /// team effects with target conditions (applied per matching slot)
  final List<CeBondEffect> targetedEffects;

  const SupportCeCandidate({
    required this.ce,
    required this.limitBreak,
    required this.flatTeamRate,
    required this.flatTeamValue,
    required this.targetedEffects,
  });
}

/// Effect-equivalence class of CEs wearable by owned servants.
///
/// Members are mutually interchangeable in the solver: identical effect signature
/// and cost. Each CE id appears in exactly ONE owned class (only its best
/// limit-break variant is enrolled), so class capacity = member count and no
/// cross-class CE-id conflicts can occur.
class BondCeClass {
  final List<CeBondEffect> effects;
  final int cost;

  /// per member (aligned with [members]): whether the best variant is the MLB one
  final List<bool> memberLimitBreaks;

  /// distinct member CE ids (each wearable at most once per team)
  final List<int> memberIds;
  final List<CraftEssence> members;

  const BondCeClass({
    required this.effects,
    required this.cost,
    required this.memberLimitBreaks,
    required this.memberIds,
    required this.members,
  });

  int get capacity => memberIds.length;

  /// whether every effect of this class is unconditional (flat)
  bool get isFlat => effects.every((e) => e.isFlat);

  int get flatTeamRate =>
      effects.where((e) => e.scope == BondEffectScope.team && e.isFlat).fold(0, (sum, e) => sum + e.rate);

  /// flat team value (AddCount) contribution of unconditional team effects
  int get flatTeamValue =>
      effects.where((e) => e.scope == BondEffectScope.team && e.isFlat).fold(0, (sum, e) => sum + e.value);

  int get flatSelfRate =>
      effects.where((e) => e.scope == BondEffectScope.self && e.isFlat).fold(0, (sum, e) => sum + e.rate);

  int get flatSelfValue =>
      effects.where((e) => e.scope == BondEffectScope.self && e.isFlat).fold(0, (sum, e) => sum + e.value);
}

/// Parsed CE pool for one solve. Bond-irrelevant CEs and quest-mismatched
/// EventId functions are filtered out during extraction.
class CeBondPool {
  final List<BondCeClass> ownedClasses = [];
  final List<SupportCeCandidate> supportCandidates = [];

  CeBondPool._();

  static bool _isCeReleased(int ceId, Region region) {
    if (region == Region.jp) return true;
    final released = db.gameData.mappingData.entityRelease.ofRegion(region);
    if (released != null && released.isNotEmpty) {
      return released.contains(ceId);
    }
    return true;
  }

  /// Parses all CEs and builds the effect pool for the given quest context.
  ///
  /// [eventId] is `quest.logicEventId ?? 0`; quest individuality checked when [quest]
  /// is provided (funcquestTvals).
  static CeBondPool build({
    QuestPhase? quest,
    required int eventId,
    required Region region,
    required Set<int> excludedCes,
    required bool excludeUnreleased,
  }) {
    final pool = CeBondPool._();
    final questIndivs = quest?.questIndividuality ?? const <int>[];

    for (final ce in db.gameData.craftEssencesById.values) {
      if (ce.collectionNo <= 0 || ce.isRegionSpecific) continue;
      if (excludedCes.contains(ce.id)) continue;
      if (excludeUnreleased && !_isCeReleased(ce.id, region)) continue;

      // owned classes: only the best limit-break variant of a CE is enrolled so
      // each CE id belongs to exactly one class (no copy-count tracking).
      ({List<CeBondEffect> effects, bool lb})? best;
      for (final lb in [false, true]) {
        final effects = extractBondEffects(
          ce.getActivatedSkills(lb).values.expand((e) => e),
          eventId: eventId,
          questIndivs: questIndivs,
          hasQuest: quest != null,
        );
        if (effects.isEmpty) continue;
        final candidate = (effects: effects, lb: lb);
        if (best == null || _compareOwnedVariant(candidate.effects, best.effects) > 0) best = candidate;
      }
      if (best != null) pool._addOwnedClass(ce, best.effects, best.lb);

      // support candidates: wearer is a no-trait placeholder.
      // Support CE costs nothing and never conflicts with owned capacities,
      // so take the best limit-break variant per CE.
      SupportCeCandidate? bestSupport;
      for (final lb in [false, true]) {
        final supportEffects = extractBondEffects(
          ce.getActivatedSkills(lb).values.expand((e) => e),
          eventId: eventId,
          questIndivs: questIndivs,
          hasQuest: quest != null,
          supportWearerTraits: const [],
        );
        if (!supportEffects.any((e) => e.scope == BondEffectScope.team)) continue;
        final flat = supportEffects
            .where((e) => e.scope == BondEffectScope.team && e.isFlat)
            .fold(0, (sum, e) => sum + e.rate);
        final flatValue = supportEffects
            .where((e) => e.scope == BondEffectScope.team && e.isFlat)
            .fold(0, (sum, e) => sum + e.value);
        final targeted = supportEffects.where((e) => e.scope == BondEffectScope.team && e.hasCondition).toList();
        final candidate = SupportCeCandidate(
          ce: ce,
          limitBreak: lb,
          flatTeamRate: flat,
          flatTeamValue: flatValue,
          targetedEffects: targeted,
        );
        if (bestSupport == null ||
            candidate.flatTeamRate > bestSupport.flatTeamRate ||
            (candidate.flatTeamRate == bestSupport.flatTeamRate &&
                candidate.flatTeamValue > bestSupport.flatTeamValue)) {
          bestSupport = candidate;
        }
      }
      if (bestSupport != null) pool.supportCandidates.add(bestSupport);
    }

    pool._dominancePrune();
    pool.supportCandidates.sort((a, b) => b.flatTeamRate.compareTo(a.flatTeamRate));
    return pool;
  }

  /// Orders two effect lists of the same CE by solver desirability:
  /// total rate, then total value (MLB variants are strictly better in data).
  static int _compareOwnedVariant(List<CeBondEffect> a, List<CeBondEffect> b) {
    int rateA = 0, rateB = 0, valueA = 0, valueB = 0;
    for (final e in a) {
      rateA += e.rate;
      valueA += e.value;
    }
    for (final e in b) {
      rateB += e.rate;
      valueB += e.value;
    }
    if (rateA != rateB) return rateA.compareTo(rateB);
    return valueA.compareTo(valueB);
  }

  /// Drops flat (unconditional) classes dominated by another flat class:
  /// rate >=, value >=, cost <=, capacity >= in all dimensions. Any solution
  /// using k copies of a dominated class can substitute k copies of the dominator.
  /// Conditional classes are kept (rare, hard to compare safely).
  void _dominancePrune() {
    final flatClasses = ownedClasses.where((c) => c.isFlat).toList();
    ownedClasses.removeWhere((b) {
      if (!b.isFlat) return false;
      for (final a in flatClasses) {
        if (identical(a, b)) continue;
        if (a.capacity < b.capacity || a.cost > b.cost) continue;
        if (a.flatSelfRate >= b.flatSelfRate &&
            a.flatSelfValue >= b.flatSelfValue &&
            a.flatTeamRate >= b.flatTeamRate &&
            a.flatTeamValue >= b.flatTeamValue) {
          // equal signature would have merged into one class, so a is strictly
          // better in at least one dimension — b is safely droppable
          return true;
        }
      }
      return false;
    });
  }

  void _addOwnedClass(CraftEssence ce, List<CeBondEffect> effects, bool lb) {
    final key = _classKey(effects, ce.cost);
    for (final cls in ownedClasses) {
      if (_classKey(cls.effects, cls.cost) == key) {
        // same signature but distinct CE id -> new member of the existing class
        if (!cls.memberIds.contains(ce.id)) {
          cls.memberIds.add(ce.id);
          cls.members.add(ce);
          cls.memberLimitBreaks.add(lb);
        }
        return;
      }
    }
    ownedClasses.add(
      BondCeClass(effects: effects, cost: ce.cost, memberLimitBreaks: [lb], memberIds: [ce.id], members: [ce]),
    );
  }

  static String _classKey(List<CeBondEffect> effects, int cost) {
    final parts = [
      for (final e in effects)
        '${e.scope.name}|${e.rate}|${e.value}|${_canonicalAnd(e.wearerActIndiv)}|${e.wearerRequiredIndiv}'
            '|${_canonicalOr(e.targetOrAll)}|${_canonicalAnd(e.targetPartial)}',
    ]..sort();
    return '$cost|${parts.join(';')}';
  }

  static String _canonicalAnd(List<int> traits) => (traits.toList()..sort()).join(',');

  static String _canonicalOr(List<List<int>> orTraits) {
    final list = [for (final and in orTraits) (and.toList()..sort()).join(',')]..sort();
    return list.join('|');
  }

  /// Extracts bond effect atoms from the given activated skills.
  ///
  /// Shared by the CE pool and the servant pool (event extraPassive skills) so both
  /// mirror `FormationBondTab.calcResults` exactly.
  ///
  /// [supportWearerTraits] switches vals selection to followerVals (support wearer,
  /// skipping ApplySupportSvt == 0) and checks wearer-side conditions against the
  /// given traits — pass an empty list for the no-trait friend placeholder.
  static List<CeBondEffect> extractBondEffects(
    Iterable<NiceSkill> skills, {
    required int eventId,
    required List<int> questIndivs,
    required bool hasQuest,
    List<int>? supportWearerTraits,
  }) {
    final effects = <CeBondEffect>[];
    for (final skill in skills) {
      // wearer-side condition 1: skill.actIndividuality (partial match against wearer)
      final actIndiv = skill.actIndividuality;

      for (final func in skill.functions) {
        if (func.funcType != FuncType.servantFriendshipUp) continue;
        // quest-side condition
        if (hasQuest && func.funcquestTvals.isNotEmpty) {
          if (!Individuality.checkSignedIndivPartialMatch(self: questIndivs, signedTarget: func.funcquestTvals)) {
            continue;
          }
        }

        DataVals? vals;
        if (supportWearerTraits != null) {
          vals = func.followerVals?.firstOrNull ?? func.svals.firstOrNull;
        } else {
          vals = func.svals.firstOrNull;
        }
        if (vals == null) continue;
        if (supportWearerTraits != null) {
          // ApplySupportSvt==0 means the function does not activate on a support wearer
          if (vals.ApplySupportSvt == 0) continue;
          // support wearer conditions are checked NOW against the (possibly empty) traits
          if (actIndiv.isNotEmpty &&
              !Individuality.checkSignedIndivPartialMatch(self: supportWearerTraits, signedTarget: actIndiv)) {
            continue;
          }
        }

        // event-limited functions must match the quest's logic event
        if (vals.EventId != null && vals.EventId != 0 && vals.EventId != eventId) continue;

        final rate = vals.RateCount ?? 0;
        final value = vals.AddCount ?? 0;
        if (rate <= 0 && value <= 0) continue;

        // wearer-side condition 2: vals.Individuality (single trait, partial match)
        final requiredIndiv = vals.Individuality ?? 0;
        if (supportWearerTraits != null && requiredIndiv != 0) {
          if (!Individuality.checkSignedIndivPartialMatch(self: supportWearerTraits, signedTarget: [requiredIndiv])) {
            continue;
          }
        }

        // target-side conditions: overwriteTvalsList (OR of AND, all match) wins
        // over functvals (partial match) — mirrors calcResults target filtering
        final overwriteTvals = func.getOverwriteTvalsList();
        final List<List<int>> targetOrAll;
        final List<int> targetPartial;
        if (overwriteTvals.isNotEmpty) {
          targetOrAll = overwriteTvals;
          targetPartial = const [];
        } else if (func.functvals.isNotEmpty) {
          targetOrAll = const [];
          targetPartial = func.functvals;
        } else {
          targetOrAll = const [];
          targetPartial = const [];
        }

        final scope = func.funcTargetType == FuncTargetType.ptFull ? BondEffectScope.team : BondEffectScope.self;

        effects.add(
          CeBondEffect(
            scope: scope,
            rate: rate,
            value: value,
            wearerActIndiv: actIndiv,
            wearerRequiredIndiv: requiredIndiv,
            targetOrAll: targetOrAll,
            targetPartial: targetPartial,
          ),
        );
      }
    }
    return effects;
  }
}
