import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show compute, kIsWeb, listEquals, debugPrint, kDebugMode;

import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/models/gamedata/individuality.dart' show Individuality;
import 'package:chaldea/models/models.dart';

import '../bond_rules.dart';
import 'bond_effect.dart';
import 'ce_assignment.dart';
import 'ce_identity.dart';
import 'ce_source.dart';
import 'combination_count.dart';
import 'search.dart';
import 'work.dart';

part 'candidate_equipment.dart';
part 'ce_first.dart';
part 'ce_stream.dart';
part 'grand_formation.dart';

/// A concrete CE choice in a solved formation.
class BondSolvedCe {
  final int id;
  final bool limitBreak;
  const BondSolvedCe(this.id, this.limitBreak);
}

class BondCeRecipientBonus {
  final int wearerPosition;
  final BondSolvedCe ce;
  final int rate;
  final int value;
  final List<List<int>> targetTraitGroups;

  const BondCeRecipientBonus({
    required this.wearerPosition,
    required this.ce,
    required this.rate,
    required this.value,
    required this.targetTraitGroups,
  });
}

class BondRecipientDetails {
  final List<BondCeRecipientBonus> craftEssences;
  final List<({NiceSkill skill, int rate, int value})> eventSkills;
  final List<({Event event, int rate})> campaigns;
  final List<BondSolvedSlot> bond15Sources;
  final int frontlineRate;
  final int supportFrontlineRate;
  final int customRate;
  final int customValue;
  final bool atBondLimit;

  const BondRecipientDetails({
    required this.craftEssences,
    required this.eventSkills,
    required this.campaigns,
    required this.bond15Sources,
    required this.frontlineRate,
    required this.supportFrontlineRate,
    required this.customRate,
    required this.customValue,
    required this.atBondLimit,
  });

  int get uncappedRate =>
      customRate +
      bond15Sources.length * kBond15BonusRate +
      craftEssences.fold<int>(0, (total, bonus) => total + bonus.rate) +
      eventSkills.fold<int>(0, (total, bonus) => total + bonus.rate) +
      campaigns.fold<int>(0, (total, bonus) => total + bonus.rate);
}

class BondSolvedSlot {
  final int position;
  final int? servantId;
  final int? limitCount;
  final BondSolvedCe? equip1;
  final BondSolvedCe? equip3;
  final bool isSupport;
  final bool fixedServant;
  final bool enableGrand;
  final int bond;
  final int cost;
  final List<int> servantCandidates;
  final List<int> equip1Candidates;
  final List<int> equip3Candidates;
  final Map<int, int> servantVariants;
  final Map<int, bool> equip1Variants;
  final Map<int, bool> equip3Variants;
  final bool fixedEquip1;
  final bool fixedEquip3;

  const BondSolvedSlot({
    required this.position,
    required this.servantId,
    required this.limitCount,
    required this.equip1,
    required this.equip3,
    required this.isSupport,
    required this.fixedServant,
    this.enableGrand = false,
    required this.bond,
    required this.cost,
    required this.servantCandidates,
    required this.equip1Candidates,
    required this.equip3Candidates,
    this.servantVariants = const {},
    this.equip1Variants = const {},
    this.equip3Variants = const {},
    this.fixedEquip1 = false,
    this.fixedEquip3 = false,
  });

  BondSolvedSlot copyWith({
    int? limitCount,
    int? cost,
    int? bond,
    (BondSolvedCe?, Map<int, bool>)? ce1,
    (BondSolvedCe?, Map<int, bool>)? ce3,
    Map<int, int>? servantVariants,
  }) => BondSolvedSlot(
    position: position,
    servantId: servantId,
    limitCount: limitCount ?? this.limitCount,
    equip1: ce1 == null ? equip1 : ce1.$1,
    equip3: ce3 == null ? equip3 : ce3.$1,
    isSupport: isSupport,
    fixedServant: fixedServant,
    enableGrand: enableGrand,
    bond: bond ?? this.bond,
    cost: cost ?? this.cost,
    servantCandidates: servantVariants?.keys.toList() ?? servantCandidates,
    servantVariants: servantVariants ?? this.servantVariants,
    equip1Candidates: ce1 == null ? equip1Candidates : ce1.$2.keys.toList(),
    equip3Candidates: ce3 == null ? equip3Candidates : ce3.$2.keys.toList(),
    equip1Variants: ce1 == null ? equip1Variants : ce1.$2,
    equip3Variants: ce3 == null ? equip3Variants : ce3.$2,
    fixedEquip1: fixedEquip1,
    fixedEquip3: fixedEquip3,
  );
}

class BondSolvedTeam {
  static final _previews = Expando<BondSolvedTeam>();
  static final _ascensionDetails = Expando<Map<int, BondAscensionRequirement>>();

  /// The concrete team shown by progressive results, with preferred equivalent forms.
  BondSolvedTeam get previewTeam => _previews[this] ?? this;
  BondAscensionRequirement? cachedAscensionRequirement(int position) => _ascensionDetails[this]?[position];
  final int totalBond;
  final int totalCost;
  final List<BondSolvedSlot> slots;
  const BondSolvedTeam(this.totalBond, this.totalCost, this.slots);

  /// Lists concrete CE instances whose trait-targeted effects apply to [target].
  List<BondCeRecipientBonus> traitCeBonusesFor(BondSolvedSlot target, QuestPhase quest, FormationBondOption option) =>
      _ceBonusesFor(target, quest, option, traitOnly: true);

  List<BondCeRecipientBonus> _ceBonusesFor(
    BondSolvedSlot target,
    QuestPhase quest,
    FormationBondOption option, {
    bool traitOnly = false,
  }) {
    final reference = BondReleaseRules.resolve(option.releaseReference, quest);
    final targetSvt = target.servantId == null ? null : db.gameData.servantsById[target.servantId];
    if (targetSvt == null) return const [];
    final eventId = quest.logicEventId ?? 0;
    final targetTraits = BondReleaseRules.traits(targetSvt, target.limitCount ?? 4, eventId, reference);
    final bonuses = <BondCeRecipientBonus>[];
    for (final wearer in slots) {
      final wearerSvt = wearer.servantId == null ? null : db.gameData.servantsById[wearer.servantId];
      final wearerTraits = wearer.isSupport || wearerSvt == null
          ? const <int>[]
          : BondReleaseRules.traits(wearerSvt, wearer.limitCount ?? 4, eventId, reference);
      for (final equipped in [wearer.equip1, wearer.equip3]) {
        if (equipped == null) continue;
        final ce = db.gameData.craftEssencesById[equipped.id];
        if (ce == null) continue;
        final effects = CeBondEffect.extractAll(
          ce,
          equipped.limitBreak,
          quest,
          support: wearer.isSupport,
          logicEventId: eventId,
        );
        var rate = 0, value = 0;
        final targetTraitGroups = <List<int>>[];
        for (final effect in effects) {
          if ((traitOnly && !effect.hasCondition) || !effect.wearerMatches(wearerTraits)) continue;
          if (effect.scope == BondEffectScope.self && wearer.position != target.position) continue;
          if (!effect.targetMatches(targetTraits)) continue;
          rate += effect.rate;
          value += effect.value;
          if (effect.targetOrAll.isNotEmpty) {
            for (final group in effect.targetOrAll) {
              if (!Individuality.checkSignedIndivAllMatch(self: targetTraits, signedTarget: group)) continue;
              if (!targetTraitGroups.any((existing) => existing.join(',') == group.join(','))) {
                targetTraitGroups.add(group);
              }
              break;
            }
          } else if (effect.targetPartial.isNotEmpty) {
            final matchedTraits = effect.targetPartial
                .where((trait) => trait > 0 && targetTraits.contains(trait))
                .toList();
            if (matchedTraits.isNotEmpty &&
                !targetTraitGroups.any((group) => group.join(',') == matchedTraits.join(','))) {
              targetTraitGroups.add(matchedTraits);
            }
          }
        }
        if (rate != 0 || value != 0) {
          bonuses.add(
            BondCeRecipientBonus(
              wearerPosition: wearer.position,
              ce: equipped,
              rate: rate,
              value: value,
              targetTraitGroups: targetTraitGroups,
            ),
          );
        }
      }
    }
    return bonuses;
  }

  /// Copies the source team and clears free-slot bond flags in the supplied option.
  /// Missing solved reward CEs clear the copied slots so previews cannot display
  /// stored equip3 values that did not participate in the solution.
  BattleTeamSetup applyTo(BattleTeamSetup source, FormationBondOption option) {
    final applied = source.copy();
    for (var p = option.maxServants.clamp(1, 6); p < applied.svts.length; p++) {
      applied.svts[p] = PlayerSvtData.base();
    }
    for (final slot in slots) {
      final deck = applied.svts[slot.position];
      if (slot.isSupport) {
        deck.svt = null;
        _setEquip(deck.equip1, slot.equip1);
        _setEquip(deck.equip3, slot.equip3);
        continue;
      }
      if (slot.servantId == null) {
        applied.svts[slot.position] = PlayerSvtData.base();
        continue;
      }
      if (!slot.fixedServant) {
        option.svtBonus[slot.position]
          ..isBond15 = false
          ..isBondReachLimit = false;
        final svt = db.gameData.servantsById[slot.servantId];
        if (svt == null) throw StateError('missing servant ${slot.servantId}');
        applied.svts[slot.position] = PlayerSvtData.svt(svt)
          ..limitCount = slot.limitCount ?? 4
          ..grandSvt = slot.enableGrand;
      }
      final target = applied.svts[slot.position];
      target.limitCount = slot.limitCount ?? target.limitCount;
      _setEquip(target.equip1, slot.equip1);
      _setEquip(target.equip3, slot.equip3);
    }
    return applied;
  }

  static void _setEquip(SvtEquipData equip, BondSolvedCe? chosen) {
    if (equip.ce?.id == chosen?.id && equip.limitBreak == (chosen?.limitBreak ?? false)) return;
    final ce = chosen == null ? null : db.gameData.craftEssencesById[chosen.id];
    if (chosen != null && ce == null) throw StateError('missing craft essence ${chosen.id}');
    equip
      ..ce = ce
      ..limitBreak = chosen?.limitBreak ?? false
      ..lv = ce?.lvMax ?? 0;
  }

  String get _signature => [
    for (final slot in slots)
      '${slot.position}:${slot.servantId}:${slot.limitCount}:'
          '${slot.equip1?.id}:${slot.equip1?.limitBreak}:'
          '${slot.equip3?.id}:${slot.equip3?.limitBreak}',
  ].join('|');

  /// Expand exact effect-class witnesses into a bounded set of concrete teams.
  /// Every substitute belongs to the same class (or has the same exact slot
  /// score in the CE-first path), so the score and COST remain unchanged.

  static Iterable<void> _concreteRepresentativeSteps(
    BondSolvedTeam best,
    List<BondSolvedTeam> groups, {
    int maxTeams = 20,
    BondSolvedTeam Function(BondSolvedTeam)? normalize,
    required void Function(List<BondSolvedTeam>) onComplete,
  }) sync* {
    final teams = <BondSolvedTeam>[];
    final seen = <String>{};
    void add(BondSolvedTeam team) {
      if (normalize != null) team = normalize(team);
      if (team.totalBond == best.totalBond && seen.add(team._signature)) teams.add(team);
    }

    add(best);
    for (final group in groups) {
      yield null;
      if (teams.length == maxTeams) break;
      add(group);
    }
    final seeds = List<BondSolvedTeam>.of(teams);
    final choices = <Iterator<BondSolvedTeam>>[];
    for (final seed in seeds) {
      yield null;
      for (var p = 0; p < seed.slots.length; p++) {
        for (var kind = 0; kind < 3; kind++) {
          choices.add(_substituteOneMember(seed, p, kind).iterator);
        }
      }
    }
    while (teams.length < maxTeams) {
      var advanced = false;
      for (final choice in choices) {
        yield null;
        if (!choice.moveNext()) continue;
        advanced = true;
        add(choice.current);
        if (teams.length == maxTeams) break;
      }
      if (!advanced) break;
    }
    onComplete(List.unmodifiable(teams));
  }

  /// Expand a bounded set of feasible seeds by score tier. Lower scores are used
  /// only after the available higher-score concrete variants have been added.

  static Iterable<void> _rankedCandidateSteps(
    List<BondSolvedTeam> seeds, {
    required int maxTeams,
    BondSolvedTeam Function(BondSolvedTeam)? normalize,
    required void Function(List<BondSolvedTeam>) onComplete,
  }) sync* {
    if (seeds.isEmpty || maxTeams < 1) {
      onComplete(const []);
      return;
    }
    final byScore = <int, List<BondSolvedTeam>>{};
    for (final seed in seeds) {
      byScore.putIfAbsent(seed.totalBond, () => []).add(seed);
    }
    final scores = byScore.keys.toList()..sort((a, b) => b.compareTo(a));
    final result = <BondSolvedTeam>[];
    for (final score in scores) {
      final group = byScore[score]!..sort((a, b) => b.totalCost.compareTo(a.totalCost));
      late List<BondSolvedTeam> representatives;
      yield* _concreteRepresentativeSteps(
        group.first,
        group,
        maxTeams: maxTeams - result.length,
        normalize: normalize,
        onComplete: (value) => representatives = value.toList(),
      );
      representatives.sort((a, b) => b.totalCost.compareTo(a.totalCost));
      result.addAll(representatives);
      if (result.length >= maxTeams) break;
    }
    onComplete(List.unmodifiable(result));
  }

  static Iterable<BondSolvedTeam> _substituteOneMember(BondSolvedTeam team, int index, int kind) sync* {
    final original = team.slots[index];
    BondSolvedTeam? replaced(int? servantId, int? limit, BondSolvedCe? ce1, BondSolvedCe? ce3) {
      final slot = BondSolvedSlot(
        position: original.position,
        servantId: servantId,
        limitCount: limit,
        equip1: ce1,
        equip3: ce3,
        isSupport: original.isSupport,
        fixedServant: original.fixedServant,
        enableGrand: original.enableGrand,
        bond: original.bond,
        cost: original.cost,
        servantCandidates: original.servantCandidates,
        equip1Candidates: original.equip1Candidates,
        equip3Candidates: original.equip3Candidates,
        servantVariants: original.servantVariants,
        equip1Variants: original.equip1Variants,
        equip3Variants: original.equip3Variants,
        fixedEquip1: original.fixedEquip1,
        fixedEquip3: original.fixedEquip3,
      );
      final slots = List<BondSolvedSlot>.of(team.slots)..[index] = slot;
      final ownedServants = <int>{};
      final ownedCes = <int>{};
      for (final member in slots) {
        if (member.isSupport) {
          final supportCes = <int>{};
          for (final ce in [member.equip1, member.equip3]) {
            if (ce != null &&
                BondCeIdentity.requiresUniqueOwnedIdentity(db.gameData.craftEssencesById[ce.id]!) &&
                !supportCes.add(BondCeIdentity.of(ce.id))) {
              return null;
            }
          }
          continue;
        }
        if (member.servantId != null && !ownedServants.add(member.servantId!)) return null;
        for (final ce in [member.equip1, member.equip3]) {
          if (ce != null &&
              BondCeIdentity.requiresUniqueOwnedIdentity(db.gameData.craftEssencesById[ce.id]!) &&
              !ownedCes.add(BondCeIdentity.of(ce.id))) {
            return null;
          }
        }
      }
      return BondSolvedTeam(team.totalBond, team.totalCost, slots);
    }

    if (kind == 0 && !original.fixedServant && !original.isSupport && original.servantId != null) {
      for (final entry in original.servantVariants.entries) {
        if (entry.key == original.servantId) continue;
        final team = replaced(entry.key, entry.value, original.equip1, original.equip3);
        if (team != null) yield team;
      }
    } else if (kind == 1 && !original.fixedEquip1 && original.equip1 != null) {
      for (final entry in original.equip1Variants.entries) {
        if (entry.key == original.equip1!.id) continue;
        final team = replaced(
          original.servantId,
          original.limitCount,
          BondSolvedCe(entry.key, entry.value),
          original.equip3,
        );
        if (team != null) yield team;
      }
    } else if (kind == 2 && !original.fixedEquip3 && original.equip3 != null) {
      for (final entry in original.equip3Variants.entries) {
        if (entry.key == original.equip3!.id) continue;
        final team = replaced(
          original.servantId,
          original.limitCount,
          original.equip1,
          BondSolvedCe(entry.key, entry.value),
        );
        if (team != null) yield team;
      }
    }
  }
}

typedef BondCandidateCes = ({List<int> traitRestricted, List<int> limited, List<int> repeatable});

class BondSolverResult {
  final BondSolvedTeam? best;
  final List<BondSolvedTeam> ties;
  final List<BondSolvedTeam> candidates;
  final List<int> tieGroupCounts;
  final bool provenOptimal;
  final bool allTiesCollected;
  final int visitedNodes;
  final int elapsedMilliseconds;
  final int maxCost;
  final int fixedCost;
  final int servantClassCount;
  final int ownedCeClassCount;
  final int placementInvariantCeClassCount;
  final int receiverProfileCount;
  final int itemCount;

  /// Servants the search may put in a free slot, counted before the
  /// equivalence merge. Null when no free-servant pool was built.
  final List<int>? candidateSvtIds;

  /// Filtered owned-slot CEs before effect classes are merged or pruned.
  /// Null when no free CE pool was built.
  final BondCandidateCes? candidateCes;

  /// Number of feasible CE combinations prepared by the CE-first search.
  /// Null before CE preparation finishes and for general branch-and-bound.
  final int? possibleCombinations;
  final bool isCeFirst;

  const BondSolverResult({
    required this.best,
    required this.ties,
    this.candidates = const [],
    required this.tieGroupCounts,
    required this.provenOptimal,
    required this.allTiesCollected,
    required this.visitedNodes,
    required this.elapsedMilliseconds,
    required this.maxCost,
    required this.fixedCost,
    required this.servantClassCount,
    required this.ownedCeClassCount,
    required this.placementInvariantCeClassCount,
    required this.receiverProfileCount,
    required this.itemCount,
    this.candidateSvtIds,
    this.candidateCes,
    this.possibleCombinations,
    this.isCeFirst = false,
  });
}

class BondAscensionRequirement {
  final List<int> all;
  final List<int> allowed;
  final List<int> unreleasedCostumes;
  const BondAscensionRequirement(this.all, this.allowed, {this.unreleasedCostumes = const []});
  bool get restricted => allowed.length < all.length;
}

class BondFormationException implements Exception {
  final List<({int position, int equip, int ceId})> conflicts;
  const BondFormationException(this.conflicts);

  @override
  String toString() =>
      'Invalid formation: duplicate CE identity/group at '
      '${conflicts.map((slot) => '${slot.position + 1}/equip${slot.equip} (${slot.ceId})').join(', ')}';
}

class BondServantRestrictionError extends StateError {
  final int position;
  final int servantId;
  BondServantRestrictionError(this.position, this.servantId)
    : super('fixed servant $servantId at position ${position + 1} does not meet quest restrictions');
}

class BondGrandLimitError extends StateError {
  BondGrandLimitError(int count, int limit) : super('fixed owned Grand count $count exceeds $limit');
}

class BondStoryCostumeError extends StateError {
  final int position;
  final int servantId;
  final int limitCount;

  BondStoryCostumeError(this.position, this.servantId, this.limitCount)
    : super('fixed servant $servantId at position ${position + 1} uses a story-only costume');
}

/// Converts game data into effect-equivalent search choices, then invokes the
/// exact search core. The quest and formation are read only during preparation;
/// [solveAsync] moves the prepared search problem to a background isolate.
class FormationBondSolver {
  FormationBondSolver._(
    this.option,
    this.quest,
    this.formation,
    this.pruneDominatedCes, {
    this.forceStreamingCeFirst = false,
  });

  final bool forceStreamingCeFirst;

  final FormationBondOption option;
  final QuestPhase quest;
  final BattleTeamSetup formation;
  final bool pruneDominatedCes;
  BondReleaseReference get _releaseReference => BondReleaseRules.resolve(option.releaseReference, quest);
  late final Set<int>? _releasedCostumes = BondReleaseRules.releasedCostumeIds(_releaseReference.region);
  final _svtLimitCache = <int, List<int>>{};
  int get _candidateLimit => option.maxCandidateTeams.clamp(1, 200).toInt();

  static void validateFormation({
    required FormationBondOption option,
    required BattleTeamSetup formation,
    required QuestPhase quest,
  }) => FormationBondSolver._(option, quest, formation, false)._validateFormation();

  void _validateFormation() {
    final limit = _grandRules?.ownedLimit(option.maxGrandServants);
    if (limit != null && _fixedOwnedGrands > limit) throw BondGrandLimitError(_fixedOwnedGrands, limit);
    validateFixedCes(formation: formation, quest: quest, maxServants: option.maxServants);
    for (final (position, deck) in formation.svts.take(option.maxServants.clamp(1, 6)).indexed) {
      final svt = deck.svt;
      if (deck.supportType.isSupport || svt == null) continue;
      final limits = _fixedSvtLimits(deck);
      if (limits.isEmpty) throw BondStoryCostumeError(position, svt.id, deck.limitCount);
      if (!limits.any((limit) => _matchesQuestRestrictions(_traits(svt, limit)))) {
        throw BondServantRestrictionError(position, svt.id);
      }
    }
  }

  /// Runs before candidate preparation; a support has its own identity pool.
  static void validateFixedCes({
    required BattleTeamSetup formation,
    required QuestPhase quest,
    required int maxServants,
  }) {
    final pools = <int, Map<int, List<({int position, int equip, int ceId})>>>{};
    for (final (p, deck) in formation.svts.take(maxServants.clamp(1, 6)).indexed) {
      final pool = pools.putIfAbsent(deck.supportType.isSupport ? p : -1, () => {});
      final grand = quest.isUseGrandBoard && deck.grandSvt && (deck.svt != null || deck.supportType.isSupport);
      for (final (equip, data) in [(1, deck.equip1), if (grand) (3, deck.equip3)]) {
        final ce = data.ce;
        if (ce == null || !BondCeIdentity.requiresUniqueOwnedIdentity(ce)) continue;
        pool.putIfAbsent(BondCeIdentity.of(ce.id), () => []).add((position: p, equip: equip, ceId: ce.id));
      }
    }
    for (final pool in pools.values) {
      for (final conflicts in pool.values) {
        if (conflicts.length > 1) throw BondFormationException(List.unmodifiable(conflicts));
      }
    }
  }

  final List<_SvtVariant> _svtVariants = [];
  final List<_CeVariant> _ceVariants = [];
  // A team with no free slot never loads a pool; that must stay distinguishable
  // from a pool that was loaded and came out empty.
  bool _loadedFreeSvts = false;
  BondCandidateCes? _candidateCes;
  final List<CeBondEffect> _allEffects = [];
  final List<List<int>> _profiles = [];
  final Map<String, int> _profileBySignature = {};
  final Map<String, int> _profileByRawTraits = {};
  final List<_SvtClass> _svtClasses = [];
  final List<_CeClass> _ownedCeClasses = [];
  final List<_CeClass> _supportCeClasses = [];
  final Map<int, List<CeBondEffect>> _eventCache = {};
  final Map<String, _CeVariant> _ceCache = {};

  late final BondGrandRules? _grandRules = BondGrandRules.forQuest(quest);
  late final int _fixedOwnedGrands = formation.svts
      .take(option.maxServants.clamp(1, 6))
      .where((slot) => !slot.supportType.isSupport && slot.svt != null && slot.grandSvt)
      .length;
  late final int _remainingGrands = (_grandRules?.ownedLimit(option.maxGrandServants) ?? 0) - _fixedOwnedGrands;
  Set<int> _grandEligibleIds = const {};
  List<List<int>> _grandLayouts = const [];
  _GrandFormationSearch? _preparedGrand;

  late final int _eventId = quest.logicEventId ?? 0;
  late final List<int> _questTraits = quest.questIndividuality;
  late final List<Restriction> _questIndivRestrictions = [
    for (final entry in quest.restrictions)
      if (entry.restriction.type == RestrictionType.individuality) entry.restriction,
  ];
  final Map<String, BondSolvedTeam> _normalizedTeams = {};
  BondSolverResult? _convertedResult;
  _CeFirstProblem? _preparedCeFirst;
  BondSearchProblem? _preparedProblem;
  List<BondSearchItem> _preparedItems = [];
  late int _maxCost;
  late int _fixedCost;
  late int _itemCount;

  /// Tests one servant at a time under the exact solver scoring scope.
  static BondAscensionRequirement ascensionRequirement({
    required BondSolvedTeam team,
    required BondSolvedSlot target,
    required FormationBondOption option,
    required QuestPhase quest,
    required BattleTeamSetup formation,
  }) {
    final evaluator = FormationBondSolver._(option, quest, formation, false);
    late BondAscensionRequirement requirement;
    for (final _ in evaluator._ascensionRequirementSteps(team, target, onComplete: (value) => requirement = value)) {}
    return requirement;
  }

  static BondRecipientDetails? recipientDetails({
    required BondSolvedTeam team,
    required BondSolvedSlot target,
    required FormationBondOption option,
    required QuestPhase quest,
    required BattleTeamSetup formation,
  }) {
    final servant = db.gameData.servantsById[target.servantId];
    if (target.isSupport || servant == null) return null;
    final evaluator = FormationBondSolver._(option, quest, formation, false);
    final traits = evaluator._traits(servant, target.limitCount ?? 4);
    final eventSkills = <({NiceSkill skill, int rate, int value})>[];
    for (final skill in evaluator._activeEventSkills(servant)) {
      var rate = 0, value = 0;
      for (final effect in evaluator._eventSkillEffects(skill)) {
        if (!effect.wearerMatches(traits) || !effect.targetMatches(traits)) continue;
        rate += effect.rate;
        value += effect.value;
      }
      if (rate != 0 || value != 0) eventSkills.add((skill: skill, rate: rate, value: value));
    }
    final custom = option.svtBonus[target.position];
    return BondRecipientDetails(
      craftEssences: team._ceBonusesFor(target, quest, option),
      eventSkills: eventSkills,
      campaigns: option.campaignBonusesFor(servant.id).toList(),
      bond15Sources: team.slots.where(evaluator._grantsBond15).toList(),
      frontlineRate: evaluator._frontlineRate(target),
      supportFrontlineRate: evaluator._supportFrontlineRate(team),
      customRate: custom.addRate,
      customValue: custom.addValue,
      atBondLimit: target.fixedServant && custom.isBondReachLimit,
    );
  }

  Iterable<void> _ascensionRequirementSteps(
    BondSolvedTeam team,
    BondSolvedSlot target, {
    required void Function(BondAscensionRequirement) onComplete,
  }) sync* {
    final svt = db.gameData.servantsById[target.servantId];
    if (svt == null || target.isSupport) {
      onComplete(const BondAscensionRequirement([], []));
      return;
    }
    final formSvt = _formServant(target, svt);
    final limits = _svtLimits(formSvt);
    final current = BondReleaseRules.playableLimit(formSvt, target.limitCount ?? 4);
    // An unreleased form can still be part of the result when manually fixed.
    final all = current == null || limits.contains(current) ? limits : ([...limits, current]..sort());
    final allowed = <int>[];
    for (final limit in all) {
      yield null;
      if (_equivalentAscension(team, target, svt, limit) != null) {
        allowed.add(limit);
      }
    }
    final unreleased = BondReleaseRules.unreleasedCostumeLimits(formSvt, _releasedCostumes, fixedLimit: current);
    onComplete(BondAscensionRequirement(all, allowed, unreleasedCostumes: unreleased));
  }

  BondSolvedTeam? _equivalentAscension(BondSolvedTeam team, BondSolvedSlot target, Servant svt, int limit) {
    if (!_matchesQuestRestrictions(_traits(svt, limit))) return null;
    final changed = BondSolvedTeam(team.totalBond, team.totalCost, [
      for (final slot in team.slots) slot.position == target.position ? slot.copyWith(limitCount: limit) : slot,
    ]);
    final (bonds, cost) = _scoreConcrete(changed);
    return cost == team.totalCost && listEquals(bonds, team.slots.map((slot) => slot.bond).toList()) ? changed : null;
  }

  List<int> _preferredAscensions(BondSolvedSlot target, Servant svt) {
    final formSvt = _formServant(target, svt);
    final limits = _svtLimits(formSvt);
    final input = target.fixedServant
        ? BondReleaseRules.playableLimit(formSvt, formation.svts[target.position].limitCount)
        : null;
    return [
      if (input != null && limits.contains(input)) input,
      for (final limit in limits.reversed)
        if (limit < 10 && limit != input) limit,
      for (final limit in limits)
        if (limit >= 10 && limit != input) limit,
    ];
  }

  Iterable<void> _preparePreviewSteps(BondSolvedTeam team) sync* {
    if (BondSolvedTeam._previews[team] != null) return;
    var preview = team;
    // Each replacement must preserve the score with all earlier choices in place.
    for (final target in team.slots) {
      if (target.isSupport || (target.fixedServant && !option.searchFixedAscensions)) continue;
      final svt = db.gameData.servantsById[target.servantId];
      if (svt == null) continue;
      for (final limit in _preferredAscensions(target, svt)) {
        if (limit == target.limitCount) break;
        yield null;
        final changed = _equivalentAscension(preview, target, svt, limit);
        if (changed == null) continue;
        preview = changed;
        break;
      }
    }
    BondSolvedTeam._previews[team] = preview;
  }

  Iterable<void> _prepareResultDetailsSteps(BondSolverResult result) sync* {
    final teams = <BondSolvedTeam>{if (result.best != null) result.best!, ...result.ties, ...result.candidates};
    for (final team in teams) {
      if (BondSolvedTeam._ascensionDetails[team.previewTeam] != null) continue;
      yield* _preparePreviewSteps(team);
      final preview = team.previewTeam;
      final cached = <int, BondAscensionRequirement>{};
      for (final target in preview.slots) {
        yield* _ascensionRequirementSteps(preview, target, onComplete: (value) => cached[target.position] = value);
      }
      BondSolvedTeam._ascensionDetails[preview] = cached;
    }
  }

  (List<int>, int) _scoreConcrete(BondSolvedTeam team) {
    final traits = [
      for (final slot in team.slots)
        slot.isSupport || slot.servantId == null
            ? <int>[]
            : _traits(db.gameData.servantsById[slot.servantId]!, slot.limitCount ?? 4),
    ];
    final rates = List<int>.filled(team.slots.length, 0);
    final values = List<int>.filled(team.slots.length, 0);
    var cost = 0;
    for (final (p, slot) in team.slots.indexed) {
      if (!slot.isSupport && slot.servantId != null) {
        final svt = db.gameData.servantsById[slot.servantId]!;
        cost += _svtCost(svt, slot.limitCount ?? 4);
        if (slot.equip1 != null) cost += db.gameData.craftEssencesById[slot.equip1!.id]!.cost;
        rates[p] += _campaignRate(svt.id) + option.svtBonus[slot.position].addRate;
        values[p] += option.svtBonus[slot.position].addValue;
        if (_grantsBond15(slot)) {
          for (var r = 0; r < rates.length; r++) {
            rates[r] += kBond15BonusRate;
          }
        }
      }
      final effects = <CeBondEffect>[
        if (!slot.isSupport && slot.servantId != null) ..._eventEffects(db.gameData.servantsById[slot.servantId]!),
        for (final (ce, fixed) in [(slot.equip1, slot.fixedEquip1), (slot.equip3, slot.fixedEquip3)])
          if (ce != null) ..._concreteCeEffects(ce, support: slot.isSupport, fixed: fixed),
      ];
      for (final effect in effects) {
        if (!effect.wearerMatches(traits[p])) continue;
        for (var r = 0; r < rates.length; r++) {
          if (effect.scope == BondEffectScope.self && r != p) continue;
          if (!effect.targetMatches(traits[r])) continue;
          rates[r] += effect.rate;
          values[r] += effect.value;
        }
      }
    }
    final supportFrontlineRate = _supportFrontlineRate(team);
    final bonds = List<int>.filled(team.slots.length, 0);
    for (final (p, slot) in team.slots.indexed) {
      if (slot.isSupport ||
          slot.servantId == null ||
          (slot.fixedServant && option.svtBonus[slot.position].isBondReachLimit)) {
        continue;
      }
      final front = _frontlineRate(slot) + supportFrontlineRate;
      final first = (quest.bond * (1 + front / 1000)).floor();
      final rate = math.min(rates[p], ConstData.constants.maxFriendShipUpRatio);
      bonds[p] = (first * (1 + rate / 1000)).floor() + values[p];
    }
    return (bonds, cost);
  }

  Iterable<CeBondEffect> _concreteCeEffects(BondSolvedCe ce, {required bool support, required bool fixed}) {
    final variant = _ceVariant(db.gameData.craftEssencesById[ce.id]!, ce.limitBreak);
    if (!support) return variant.ownEffects;
    return fixed ? variant.supportEffects : variant.supportEffects.where(_isFreeCeEffect);
  }

  bool _grantsBond15(BondSolvedSlot slot) =>
      !slot.isSupport && slot.servantId != null && slot.fixedServant && option.svtBonus[slot.position].isBond15;

  int _frontlineRate(BondSolvedSlot slot) => option.frontlineBonus && slot.position < 3 ? 200 : 0;

  int _supportFrontlineRate(BondSolvedTeam team) =>
      option.frontlineBonus ? 40 * team.slots.where((slot) => slot.isSupport && slot.position < 3).length : 0;

  /// Concrete representatives are stable; rearrangements preserve the source multiset.
  BondSolvedTeam _normalizeTeam(BondSolvedTeam team) {
    final key =
        '${team._signature}|${team.totalBond}|${team.totalCost}|${[for (final slot in team.slots) '${slot.bond}:${slot.fixedServant}:${slot.fixedEquip1}:${slot.fixedEquip3}:'
              '${slot.servantVariants}:${slot.equip1Variants}:${slot.equip3Variants}'].join('|')}';
    final cached = _normalizedTeams[key];
    if (cached != null) return cached;
    final normalized = _normalizeTeamUncached(team);
    if (_normalizedTeams.length >= _candidateLimit * 4) _normalizedTeams.remove(_normalizedTeams.keys.first);
    _normalizedTeams[key] = normalized;
    return normalized;
  }

  BondSolvedTeam _normalizeTeamUncached(BondSolvedTeam team) {
    final slots = List<BondSolvedSlot>.of(team.slots);
    final used = <int>{};
    final dimensions = <(int, bool, Map<int, bool>)>[];
    for (final (p, slot) in slots.indexed) {
      for (final third in [false, true]) {
        final ce = third ? slot.equip3 : slot.equip1;
        if (ce == null) continue;
        final fixed = third ? slot.fixedEquip3 : slot.fixedEquip1;
        final candidates = third ? slot.equip3Variants : slot.equip1Variants;
        if (slot.isSupport) {
          if (!fixed && candidates.isNotEmpty) {
            final other = third ? slots[p].equip1 : slots[p].equip3;
            final available =
                candidates.keys
                    .where(
                      (id) =>
                          other == null ||
                          !BondCeIdentity.requiresUniqueOwnedIdentity(db.gameData.craftEssencesById[id]!) ||
                          BondCeIdentity.of(id) != BondCeIdentity.of(other.id),
                    )
                    .toList()
                  ..sort();
            final id = available.first;
            final chosen = BondSolvedCe(id, candidates[id]!);
            final effects = _ceVariant(db.gameData.craftEssencesById[id]!, chosen.limitBreak).supportEffects;
            final variants = effects.every((e) => e.isFlat) ? {id: chosen.limitBreak} : candidates;
            slots[p] = third ? slots[p].copyWith(ce3: (chosen, variants)) : slots[p].copyWith(ce1: (chosen, variants));
          }
        } else if (fixed) {
          if (BondCeIdentity.requiresUniqueOwnedIdentity(db.gameData.craftEssencesById[ce.id]!)) {
            used.add(BondCeIdentity.of(ce.id));
          }
        } else {
          dimensions.add((p, third, candidates.isEmpty ? {ce.id: ce.limitBreak} : candidates));
        }
      }
    }
    bool assign(int index) {
      if (index == dimensions.length) return true;
      final (p, third, candidates) = dimensions[index];
      for (final id in candidates.keys.toList()..sort()) {
        final identity = BondCeIdentity.of(id);
        final restricted = BondCeIdentity.requiresUniqueOwnedIdentity(db.gameData.craftEssencesById[id]!);
        if (restricted && !used.add(identity)) continue;
        final ce = BondSolvedCe(id, candidates[id]!);
        if (assign(index + 1)) {
          final effects = _ceVariant(db.gameData.craftEssencesById[id]!, ce.limitBreak).ownEffects;
          final variants = effects.every((e) => e.isFlat) ? {id: ce.limitBreak} : candidates;
          slots[p] = third ? slots[p].copyWith(ce3: (ce, variants)) : slots[p].copyWith(ce1: (ce, variants));
          return true;
        }
        if (restricted) used.remove(identity);
      }
      return false;
    }

    if (!assign(0)) throw StateError('solved CE identities cannot be instantiated');
    _orderFreeEquip1(slots);
    return BondSolvedTeam(team.totalBond, team.totalCost, slots);
  }

  void _orderFreeEquip1(List<BondSolvedSlot> slots) {
    final positions = [
      for (final (p, slot) in slots.indexed)
        if (!slot.isSupport && slot.servantId != null && !slot.fixedEquip1) p,
    ];
    final ordered = positions.map((p) => slots[p]).toList()..sort((a, b) => _compareCe(a.equip1, b.equip1));
    for (final (i, p) in positions.indexed) {
      final ce = ordered[i].equip1;
      final oldCost = slots[p].equip1 == null ? 0 : db.gameData.craftEssencesById[slots[p].equip1!.id]!.cost;
      final newCost = ce == null ? 0 : db.gameData.craftEssencesById[ce.id]!.cost;
      slots[p] = slots[p].copyWith(cost: slots[p].cost - oldCost + newCost, ce1: (ce, ordered[i].equip1Variants));
    }
  }

  int _compareCe(BondSolvedCe? a, BondSolvedCe? b) {
    if (a == null || b == null) return a == null ? (b == null ? 0 : 1) : -1;
    List<CeBondEffect> effects(BondSolvedCe ce) =>
        _ceVariant(db.gameData.craftEssencesById[ce.id]!, ce.limitBreak).ownEffects;
    final ea = effects(a), eb = effects(b);
    final trait = (eb.any((e) => e.hasCondition) ? 1 : 0).compareTo(ea.any((e) => e.hasCondition) ? 1 : 0);
    if (trait != 0) return trait;
    final rate = eb.fold<int>(0, (sum, e) => sum + e.rate).compareTo(ea.fold<int>(0, (sum, e) => sum + e.rate));
    return rate != 0 ? rate : b.id.compareTo(a.id);
  }

  static BondSolverResult solve({
    required FormationBondOption option,
    required QuestPhase quest,
    required BattleTeamSetup formation,
    int? maxNodes,
    int maxTies = 20,
    bool pruneDominatedCes = true,
    bool useCeFirst = true,
    bool useStreamingCeFirst = false,
  }) {
    final stopwatch = Stopwatch()..start();
    return FormationBondSolver._(
      option,
      quest,
      formation.copy(),
      pruneDominatedCes,
      forceStreamingCeFirst: useStreamingCeFirst,
    )._solve(maxNodes: maxNodes, maxTies: maxTies, useCeFirst: useCeFirst, stopwatch: stopwatch);
  }

  static Future<BondSolverResult> solveAsync({
    required FormationBondOption option,
    required QuestPhase quest,
    required BattleTeamSetup formation,
    int? maxNodes,
    int maxTies = 20,
    bool pruneDominatedCes = true,
    bool useCeFirst = true,
    bool useStreamingCeFirst = false,
  }) async {
    final stopwatch = Stopwatch()..start();
    final solver = FormationBondSolver._(
      option,
      quest,
      formation.copy(),
      pruneDominatedCes,
      forceStreamingCeFirst: useStreamingCeFirst,
    );
    for (final _ in solver._prepareSearchSteps(useCeFirst: useCeFirst)) {}
    final grand = solver._preparedGrand;
    if (grand != null) {
      final search = await compute(
        _GrandSearchInput.run,
        _GrandSearchInput(grand, maxNodes, maxTies, solver._candidateLimit),
      );
      return solver._concreteResult(search, stopwatch, maxTies: maxTies);
    }
    final ceFirst = solver._preparedCeFirst;
    if (ceFirst != null) {
      final search = await compute(
        FormationBondSolver._runCeFirstSearch,
        _CeFirstSearchInput(ceFirst, maxNodes, maxTies, solver._candidateLimit),
      );
      return solver._concreteResult(search, stopwatch, maxTies: maxTies);
    }
    final search = await compute(
      FormationBondSolver._runPreparedBondSearch,
      _SearchInput(solver._preparedProblem!, maxNodes, maxTies, solver._candidateLimit),
    );
    return solver._result(search, stopwatch, maxTies: maxTies);
  }

  /// Emits feasible improvements before the optimality proof finishes. The
  /// worker isolate is stopped when the stream subscription is cancelled.
  static Stream<BondSolverResult> solveProgressively({
    required FormationBondOption option,
    required QuestPhase quest,
    required BattleTeamSetup formation,
    bool pruneDominatedCes = true,
    void Function()? onSearchStarted,
    bool useWorkerIsolate = !kIsWeb,
    bool useCeFirst = true,
    bool useStreamingCeFirst = false,
    Duration candidatePreviewInterval = const Duration(seconds: 2),
  }) {
    if (candidatePreviewInterval <= Duration.zero) throw ArgumentError.value(candidatePreviewInterval);
    late StreamController<BondSolverResult> controller;
    Isolate? worker;
    ReceivePort? messages;
    bool cancelled = false, finished = false, processing = false;
    List<Object?>? pending;
    List<Object?>? firstWitness;
    List<Object?>? latest;
    Timer? previewTimer;
    var previewRequested = false;
    var previewLimit = 1;
    List<BondSolvedTeam> visibleCandidates = const [];
    bool receivedWitness = false, publishedWitness = false, publishedProof = false;
    Future<void>? processingFuture;
    final stopwatch = Stopwatch()..start();
    final solver = FormationBondSolver._(
      option,
      quest,
      formation.copy(),
      pruneDominatedCes,
      forceStreamingCeFirst: useStreamingCeFirst,
    );
    final scheduler = BondWorkScheduler(isCancelled: () => cancelled);
    final candidateEquipment = _CandidateEquipment(solver);

    void logPhase(String phase, int started) {
      if (kDebugMode) {
        debugPrint(
          '[BondSolver] $phase: ${stopwatch.elapsedMilliseconds - started}ms '
          'longestStep=${scheduler.longestStepMicroseconds}us yields=${scheduler.yields}',
        );
      }
    }

    Future<void> process() async {
      if (processing) return processingFuture;
      processing = true;
      try {
        while ((firstWitness != null || pending != null) && !cancelled) {
          final next = firstWitness ?? pending!;
          firstWitness = null;
          if (identical(pending, next)) pending = null;
          final proof = next[1] is _ConcreteBondSearchResult
              ? (next[1]! as _ConcreteBondSearchResult).provenOptimal
              : (next[1]! as BondSearchResult).provenOptimal;
          final preview = previewRequested && !proof && publishedWitness;
          previewRequested = false;
          final expand = publishedProof || preview;
          final limit = publishedProof ? solver._candidateLimit : previewLimit;
          final started = stopwatch.elapsedMilliseconds;
          await scheduler.run(
            next[0] == 'concrete'
                ? solver._concreteResultSteps(
                    next[1]! as _ConcreteBondSearchResult,
                    stopwatch,
                    expandCandidates: expand,
                    maxCandidates: limit,
                    maxNewCandidates: preview ? 10 : null,
                    retainedCandidates: visibleCandidates,
                    candidateEquipment: candidateEquipment,
                  )
                : solver._resultSteps(
                    next[1]! as BondSearchResult,
                    stopwatch,
                    expandCandidates: expand,
                    maxCandidates: limit,
                    maxNewCandidates: preview ? 10 : null,
                    retainedCandidates: visibleCandidates,
                    candidateEquipment: candidateEquipment,
                  ),
          );
          logPhase('snapshot conversion', started);
          final detailStarted = stopwatch.elapsedMilliseconds;
          await scheduler.run(solver._prepareResultDetailsSteps(solver._convertedResult!));
          logPhase('ascension details', detailStarted);
          if (!cancelled) {
            final result = solver._convertedResult!;
            visibleCandidates = result.candidates;
            if (!publishedWitness && result.best != null) {
              publishedWitness = true;
              previewTimer = Timer.periodic(candidatePreviewInterval, (_) {
                if (cancelled || finished || publishedProof || latest == null) return;
                previewLimit = math.min(solver._candidateLimit, visibleCandidates.length + 10);
                previewRequested = true;
                pending ??= latest;
                if (!processing) processingFuture = process();
              });
              if (kDebugMode) {
                debugPrint(
                  '[BondSolver] first team published: ${stopwatch.elapsedMilliseconds}ms '
                  'best=${result.best!.totalBond} candidates=${result.candidates.length} details=complete',
                );
              }
            }
            controller.add(result);
            if (preview && kDebugMode) {
              debugPrint(
                '[BondSolver] candidate preview published: '
                '${stopwatch.elapsedMilliseconds}ms candidates=${result.candidates.length}',
              );
            }
            if (result.provenOptimal && !publishedProof) {
              publishedProof = true;
              previewTimer?.cancel();
              // Publish the proof without waiting for further expansion; keep
              // already visible teams even when this is the final snapshot.
              if (result.best != null) pending ??= next;
              if (kDebugMode) {
                debugPrint('[BondSolver] maximum proof published: ${stopwatch.elapsedMilliseconds}ms');
              }
            }
          }
        }
      } on BondWorkCancelled {
        // Cancellation deliberately discards pending UI snapshots.
      } catch (e, stack) {
        if (!cancelled) controller.addError(e, stack);
        finished = true;
      } finally {
        processing = false;
        if (finished && !cancelled) {
          previewTimer?.cancel();
          messages?.close();
          worker?.kill(priority: Isolate.immediate);
          await controller.close();
        }
      }
    }

    void enqueue(String kind, Object result) {
      if (cancelled) return;
      final hasWitness = result is _ConcreteBondSearchResult
          ? result.best != null
          : (result as BondSearchResult).best != null;
      final next = <Object?>[kind, result];
      latest = next;
      if (!receivedWitness && hasWitness) {
        receivedWitness = true;
        firstWitness = next;
        if (kDebugMode) {
          final foundAt = result is _ConcreteBondSearchResult
              ? result.firstFeasibleMilliseconds
              : (result as BondSearchResult).firstFeasibleMilliseconds;
          debugPrint(
            '[BondSolver] first feasible witness: search=${foundAt}ms '
            'received=${stopwatch.elapsedMilliseconds}ms method=$kind',
          );
        }
      }
      pending = next;
      if (!processing) processingFuture = process();
    }

    Future<void> start() async {
      try {
        final started = stopwatch.elapsedMilliseconds;
        await scheduler.run(solver._prepareSearchSteps(useCeFirst: useCeFirst));
        logPhase('search preparation', started);
        final problem = solver._preparedProblem;
        final grand = solver._preparedGrand;
        final ceFirst = solver._preparedCeFirst;
        if (cancelled) return;
        onSearchStarted?.call();
        if (cancelled) return;
        if (!useWorkerIsolate) {
          if (grand != null) {
            await scheduler.run(
              grand.solveSteps(
                maxCandidates: solver._candidateLimit,
                onProgress: (value) => enqueue('concrete', value),
                onComplete: (value) => enqueue('concrete', value),
              ),
            );
          } else if (ceFirst != null) {
            final search = _CeFirstSearch(ceFirst, maxCandidates: solver._candidateLimit);
            await scheduler.run(
              search.solveSteps(
                onProgress: (value) => enqueue('concrete', value),
                onComplete: (value) => enqueue('concrete', value),
              ),
            );
          } else {
            await scheduler.run(
              BondSearch.solveSteps(
                problem!,
                maxCandidates: solver._candidateLimit,
                onProgress: (value) => enqueue('general', value),
                onComplete: (value) => enqueue('general', value),
              ),
            );
          }
          finished = true;
          if (processing) {
            await processingFuture;
          } else {
            processingFuture = process();
            await processingFuture;
          }
          return;
        }
        messages = ReceivePort();
        worker = await Isolate.spawn(
          FormationBondSolver._runProgressiveBondSearch,
          _ProgressInput(messages!.sendPort, problem, ceFirst, grand, solver._candidateLimit),
        );
        if (cancelled) {
          worker?.kill(priority: Isolate.immediate);
          messages?.close();
          return;
        }
        messages!.listen((dynamic message) {
          final parts = message as List<Object?>;
          switch (parts[0]) {
            case 'concrete':
              enqueue('concrete', parts[1]!);
            case 'general':
              enqueue('general', parts[1]!);
            case 'error':
              controller.addError(StateError(parts[1] as String));
              finished = true;
              if (!processing) processingFuture = process();
            case 'done':
              finished = true;
              if (!processing) processingFuture = process();
          }
        });
      } on BondWorkCancelled {
        // The stream was cancelled during a preparation slice.
      } catch (e, stack) {
        previewTimer?.cancel();
        if (!cancelled) {
          controller.addError(e, stack);
          await controller.close();
        }
        worker?.kill(priority: Isolate.immediate);
        messages?.close();
      }
    }

    controller = StreamController<BondSolverResult>(
      onListen: start,
      onCancel: () {
        cancelled = true;
        previewTimer?.cancel();
        pending = null;
        firstWitness = null;
        latest = null;
        visibleCandidates = const [];
        messages?.close();
        worker?.kill(priority: Isolate.immediate);
      },
    );
    return controller.stream;
  }

  BondSolverResult _solve({
    int? maxNodes,
    required int maxTies,
    required bool useCeFirst,
    required Stopwatch stopwatch,
  }) {
    for (final _ in _prepareSearchSteps(useCeFirst: useCeFirst)) {}
    final grand = _preparedGrand;
    if (grand != null) {
      return _concreteResult(
        grand.solve(maxNodes: maxNodes, maxTies: maxTies, maxCandidates: _candidateLimit),
        stopwatch,
        maxTies: maxTies,
      );
    }
    final ceFirst = _preparedCeFirst;
    if (ceFirst != null) {
      return _concreteResult(
        _CeFirstSearch(ceFirst, maxTies: maxTies, maxCandidates: _candidateLimit).solve(maxEvaluations: maxNodes),
        stopwatch,
        maxTies: maxTies,
      );
    }
    final search = BondSearch.solve(
      _preparedProblem!,
      maxNodes: maxNodes,
      maxTies: maxTies,
      maxCandidates: _candidateLimit,
    );
    return _result(search, stopwatch, maxTies: maxTies);
  }

  Iterable<void> _prepareSearchSteps({required bool useCeFirst}) sync* {
    final clock = kDebugMode ? (Stopwatch()..start()) : null;
    yield* _prepareCandidatesSteps();
    if (kDebugMode) debugPrint('[BondSolver] common preparation: ${clock!.elapsedMilliseconds}ms');
    clock?.reset();
    if (useCeFirst) yield* _prepareCeFirstSteps();
    if (_grandLayouts.isNotEmpty) {
      final ceFirst = _preparedCeFirst;
      if (ceFirst != null) {
        _preparedGrand = _GrandFormationSearch.ceFirst(ceFirst, _grandLayouts, _grandEligibleIds);
      } else {
        yield* _prepareGeneralGrandSteps();
      }
      // Each position's Grand item domain is shared across all layouts that use it.
      final grandClasses = _svtClasses.where((cls) => cls.limits.keys.any(_grandEligibleIds.contains)).length;
      final rewardChoices = _ownedCeClasses.length;
      for (final p in _grandLayouts.expand((layout) => layout).toSet()) {
        final normalChoices = formation.svts[p].equip1.ce == null ? rewardChoices + 1 : 1;
        _itemCount += grandClasses * normalChoices * rewardChoices;
      }
      return;
    }
    if (kDebugMode) debugPrint('[BondSolver] CE-first routing: ${clock!.elapsedMilliseconds}ms');
    clock?.reset();
    if (_preparedCeFirst == null) yield* _prepareProblemSteps();
    if (kDebugMode) {
      debugPrint(
        '[BondSolver] general item preparation: ${clock!.elapsedMilliseconds}ms '
        'built=${_preparedProblem != null} items=$_itemCount',
      );
    }
  }

  Iterable<void> _prepareCandidatesSteps() sync* {
    if (option.svtBonus.length < 6) throw StateError('formation bond bonuses must contain six positions');
    _validateFormation();
    final decks = formation.svts.take(option.maxServants.clamp(1, 6)).toList();
    final maxCost = _maxCost = option.maxCost ?? ConstData.userLevel[ConstData.maxUserLevel]?.maxCost ?? -1;
    if (maxCost < 0) throw StateError('master-level cost table is unavailable');
    final needsFreeServant = decks.any((d) => !d.supportType.isSupport && d.svt == null);
    // A Grand support's free reward slot still needs a pool with equip1 fixed.
    final needsFreeCe =
        (_remainingGrands > 0 && needsFreeServant) ||
        decks.any(
          (d) =>
              d.equip1.ce == null ||
              (quest.isUseGrandBoard &&
                  d.grandSvt &&
                  (d.supportType.isSupport || d.svt != null) &&
                  d.equip3.ce == null),
        );
    final released = needsFreeServant || needsFreeCe ? _releasedIds() : null;

    if (needsFreeServant) yield* _loadFreeServantsSteps(released);
    if (_remainingGrands > 0 && needsFreeServant) {
      _grandEligibleIds = {
        for (final variant in _svtVariants)
          if (variant.svt.status.favorite && variant.svt.status.grandSvt) variant.svt.id,
      };
      _grandLayouts = _GrandFormationSearch.layouts(
        rules: _grandRules!,
        decks: decks,
        bonuses: option.svtBonus,
        frontline: option.frontlineBonus,
        limit: math.min(_remainingGrands, _grandEligibleIds.length),
      );
    }
    if (needsFreeCe) yield* _loadFreeCesSteps(released);
    yield* _loadFixedEffectsSteps(decks);
    yield* _buildProfilesSteps(decks);
    yield* _buildSvtClassesSteps();
    yield* _buildCeClassesSteps();
    yield* _pruneOwnedCeClassesSteps(decks);

    _fixedCost = 0;
    _itemCount = 0;
    for (final (p, deck) in decks.indexed) {
      yield null;
      final support = deck.supportType.isSupport;
      final fixed = !support && deck.svt != null;
      final grand = quest.isUseGrandBoard && deck.grandSvt && (fixed || support);
      final int count;
      if (support) {
        count = _supportItems(deck, grand).length;
      } else {
        final servants = fixed ? _fixedSvtClasses(deck).length : _svtClasses.length;
        final ce1 = deck.equip1.ce == null ? _ownedCeClasses.length + 1 : 1;
        final ce3 = grand && deck.equip3.ce == null ? _ownedCeClasses.length + 1 : 1;
        // Preserve the diagnostic item count without allocating the owned
        // servant/CE product when the separable search can bypass it.
        count = servants * ce1 * ce3 + (!fixed && deck.equip1.ce == null ? 1 : 0);
        if (fixed && !option.searchFixedAscensions) _fixedCost += _svtCost(deck.svt!, _fixedSvtLimits(deck).single);
        _fixedCost += deck.equip1.ce?.cost ?? 0;
      }
      if (count == 0) throw StateError('no candidate at position ${p + 1}');
      _itemCount += count;
    }
  }

  Iterable<void> _prepareProblemSteps() sync* {
    final decks = formation.svts.take(option.maxServants.clamp(1, 6)).toList();
    final positions = <BondSearchPosition>[];
    final supportFrontCount = option.frontlineBonus ? decks.take(3).where((d) => d.supportType.isSupport).length : 0;
    var symmetryGroup = 0;
    final freeGroupByProfile = <String, int>{};
    for (final (p, deck) in decks.indexed) {
      final isSupport = deck.supportType.isSupport;
      final fixedSvt = !isSupport && deck.svt != null;
      final grand = quest.isUseGrandBoard && deck.grandSvt && (fixedSvt || isSupport);
      final front = option.frontlineBonus && !isSupport ? (p < 3 ? 200 : 0) + 40 * supportFrontCount : 0;
      List<BondSearchItem> items;
      if (isSupport) {
        items = _supportItems(deck, grand);
      } else {
        yield* _ownItemsSteps(p, deck, grand);
        items = _preparedItems;
      }
      yield null;
      if (items.isEmpty) throw StateError('no candidate at position ${p + 1}');

      int? group;
      if (!fixedSvt && !isSupport && deck.equip1.ce == null) {
        final bonus = option.svtBonus[p];
        final key = '$front|${bonus.addRate}|${bonus.addValue}';
        group = freeGroupByProfile.putIfAbsent(key, () => symmetryGroup++);
      }
      positions.add(BondSearchPosition(frontlineRate: front, items: items, symmetryGroup: group));
    }

    assert(_itemCount == positions.fold<int>(0, (sum, position) => sum + position.items.length));
    _preparedProblem = BondSearchProblem(
      baseBond: quest.bond,
      rateCap: ConstData.constants.maxFriendShipUpRatio,
      maxCost: _maxCost,
      receiverProfileCount: _profiles.length,
      positions: positions,
      servantClassCapacities: [for (final cls in _svtClasses) cls.limits.length],
      ownedCeClassCapacities: [for (final cls in _ownedCeClasses) cls.capacity(decks.length * 2)],
      ownedCeIdentities: {
        for (final family in BondCeIdentity.families)
          for (final id in family) id: family.first,
      },
    );
  }

  Iterable<void> _prepareGeneralGrandSteps() sync* {
    yield* _prepareProblemSteps();
    final template = _preparedProblem!;
    final grands = <int, BondSearchPosition>{};
    for (final p in _grandLayouts.expand((layout) => layout).toSet()) {
      yield* _ownItemsSteps(p, formation.svts[p], true, autoGrand: true);
      final base = template.positions[p];
      if (_preparedItems.isEmpty) continue;
      grands[p] = BondSearchPosition(
        frontlineRate: base.frontlineRate,
        items: _preparedItems,
        symmetryGroup: base.symmetryGroup == null ? null : base.symmetryGroup! + template.positions.length,
      );
    }
    final problems = <BondSearchProblem>[];
    for (final layout in _grandLayouts) {
      yield null;
      if (!layout.every(grands.containsKey)) continue;
      problems.add(
        BondSearchProblem(
          baseBond: template.baseBond,
          rateCap: template.rateCap,
          maxCost: template.maxCost,
          receiverProfileCount: template.receiverProfileCount,
          positions: [
            for (final (p, position) in template.positions.indexed) layout.contains(p) ? grands[p]! : position,
          ],
          servantClassCapacities: template.servantClassCapacities,
          ownedCeClassCapacities: template.ownedCeClassCapacities,
          ownedCeIdentities: template.ownedCeIdentities,
        ),
      );
    }
    _preparedGrand = _GrandFormationSearch.general(problems, _fixedEquipMasks);
  }

  BondSolverResult _result(BondSearchResult search, Stopwatch stopwatch, {int maxTies = 20}) {
    for (final _ in _resultSteps(search, stopwatch, maxTies: maxTies)) {}
    return _convertedResult!;
  }

  List<BondSolvedTeam> _retainCandidates(
    BondSolvedTeam best,
    List<BondSolvedTeam> retained,
    List<BondSolvedTeam> proposed,
    int limit,
    int? maxNew,
  ) {
    final byKey = {for (final team in retained) team._signature: team};
    var added = 0;
    if (!byKey.containsKey(best._signature)) {
      byKey[best._signature] = best;
      added++;
    }
    for (final team in proposed) {
      if (byKey.containsKey(team._signature)) continue;
      if (maxNew != null && added >= maxNew) break;
      byKey[team._signature] = team;
      added++;
    }
    final ranked = byKey.values.toList()..sort(_compareCandidates);
    return List.unmodifiable(ranked.take(limit));
  }

  static int _compareCandidates(BondSolvedTeam a, BondSolvedTeam b) {
    final score = b.totalBond.compareTo(a.totalBond);
    if (score != 0) return score;
    final cost = b.totalCost.compareTo(a.totalCost);
    return cost != 0 ? cost : a._signature.compareTo(b._signature);
  }

  Iterable<void> _collectCandidatesSteps({
    required BondSolvedTeam witness,
    required List<BondSolvedTeam> seeds,
    required bool expand,
    required bool proven,
    required int limit,
    required int? maxNew,
    required List<BondSolvedTeam> retained,
    required _CandidateEquipment? equipment,
    required void Function(BondSolvedTeam, List<BondSolvedTeam>) onComplete,
  }) sync* {
    var best = witness;
    var proposed = const <BondSolvedTeam>[];
    if (expand) {
      yield* BondSolvedTeam._rankedCandidateSteps(
        [witness, ...seeds, if (equipment == null) ...retained],
        maxTeams: limit,
        normalize: _normalizeTeam,
        onComplete: (value) => proposed = value,
      );
    }
    if (equipment != null) {
      yield* equipment.completeSteps(witness, (value) => best = value);
      final completed = <BondSolvedTeam>[];
      for (final team in proposed) {
        yield null;
        yield* equipment.completeSteps(team, completed.add);
      }
      yield* bondSortSteps(completed, _compareCandidates);
      if (completed.isNotEmpty && _compareCandidates(completed.first, best) < 0) best = completed.first;
      proposed = completed;
    }
    final ranked = _retainCandidates(best, retained, proposed, limit, maxNew);
    if (equipment != null) {
      best = ranked.first;
      if (proven && best.totalBond != witness.totalBond) {
        throw StateError('completed candidate disagrees with the proven bond score');
      }
    }
    onComplete(best, ranked);
  }

  Iterable<void> _resultSteps(
    BondSearchResult search,
    Stopwatch stopwatch, {
    int maxTies = 20,
    bool expandCandidates = true,
    int? maxCandidates,
    int? maxNewCandidates,
    List<BondSolvedTeam> retainedCandidates = const [],
    _CandidateEquipment? candidateEquipment,
  }) sync* {
    final limit = math.min(maxCandidates ?? _candidateLimit, _candidateLimit);
    var best = search.best == null ? null : _normalizeTeam(_expand(search.best!));
    List<BondSolvedTeam> ties = const [], candidates = const [];
    if (best case final witness?) {
      if (expandCandidates && search.provenOptimal) {
        yield* BondSolvedTeam._concreteRepresentativeSteps(
          witness,
          [for (final tie in search.ties) _expand(tie)],
          maxTeams: maxTies,
          normalize: _normalizeTeam,
          onComplete: (value) => ties = value,
        );
      }
      final seeds = <BondSolvedTeam>[];
      if (expandCandidates) {
        for (final candidate in search.candidates) {
          seeds.add(_expand(candidate));
          yield null;
        }
      }
      yield* _collectCandidatesSteps(
        witness: witness,
        seeds: seeds,
        expand: expandCandidates,
        proven: search.provenOptimal,
        limit: limit,
        maxNew: maxNewCandidates,
        retained: retainedCandidates,
        equipment: candidateEquipment,
        onComplete: (team, ranked) {
          best = team;
          candidates = ranked;
        },
      );
    }
    _convertedResult = BondSolverResult(
      best: best,
      ties: ties,
      candidates: candidates,
      tieGroupCounts: search.tieGroupCounts,
      provenOptimal: search.provenOptimal,
      allTiesCollected: search.allTiesCollected,
      visitedNodes: search.visitedNodes,
      elapsedMilliseconds: stopwatch.elapsedMilliseconds,
      maxCost: _maxCost,
      fixedCost: _fixedCost,
      servantClassCount: _svtClasses.length,
      ownedCeClassCount: _ownedCeClasses.length,
      placementInvariantCeClassCount: _ownedCeClasses.where((ce) => ce.placementInvariant).length,
      receiverProfileCount: _profiles.length,
      itemCount: _itemCount,
      candidateSvtIds: _loadedFreeSvts ? _candidateSvtIds() : null,
      candidateCes: _candidateCes,
    );
  }

  BondSolverResult _concreteResult(_ConcreteBondSearchResult search, Stopwatch stopwatch, {int maxTies = 20}) {
    for (final _ in _concreteResultSteps(search, stopwatch, maxTies: maxTies)) {}
    return _convertedResult!;
  }

  Iterable<void> _concreteResultSteps(
    _ConcreteBondSearchResult search,
    Stopwatch stopwatch, {
    int maxTies = 20,
    bool expandCandidates = true,
    int? maxCandidates,
    int? maxNewCandidates,
    List<BondSolvedTeam> retainedCandidates = const [],
    _CandidateEquipment? candidateEquipment,
  }) sync* {
    final limit = math.min(maxCandidates ?? _candidateLimit, _candidateLimit);
    var best = search.best == null ? null : _normalizeTeam(search.best!);
    List<BondSolvedTeam> ties = const [], candidates = const [];
    if (best case final witness?) {
      if (expandCandidates && search.provenOptimal) {
        yield* BondSolvedTeam._concreteRepresentativeSteps(
          witness,
          search.ties,
          maxTeams: maxTies,
          normalize: _normalizeTeam,
          onComplete: (value) => ties = value,
        );
      }
      yield* _collectCandidatesSteps(
        witness: witness,
        seeds: search.candidates,
        expand: expandCandidates,
        proven: search.provenOptimal,
        limit: limit,
        maxNew: maxNewCandidates,
        retained: retainedCandidates,
        equipment: candidateEquipment,
        onComplete: (team, ranked) {
          best = team;
          candidates = ranked;
        },
      );
    }
    _convertedResult = BondSolverResult(
      best: best,
      ties: ties,
      candidates: candidates,
      tieGroupCounts: search.tieGroupCounts,
      provenOptimal: search.provenOptimal,
      allTiesCollected: false,
      visitedNodes: search.evaluatedCombinations,
      elapsedMilliseconds: stopwatch.elapsedMilliseconds,
      maxCost: _maxCost,
      fixedCost: _fixedCost,
      servantClassCount: _svtClasses.length,
      ownedCeClassCount: _ownedCeClasses.length,
      placementInvariantCeClassCount: _ownedCeClasses.where((ce) => ce.placementInvariant).length,
      receiverProfileCount: _profiles.length,
      itemCount: _itemCount,
      candidateSvtIds: _loadedFreeSvts ? _candidateSvtIds() : null,
      candidateCes: _candidateCes,
      possibleCombinations: search.possibleCombinations,
      isCeFirst: _preparedGrand?.usesCeFirst ?? true,
    );
  }

  Iterable<void> _prepareCeFirstSteps() sync* {
    _preparedCeFirst = null;
    if (_ownedCeClasses.any((ce) => !ce.placementInvariant)) return;
    if (_svtClasses.any(
      (svt) => svt.eventEffect.teamRates.any((v) => v != 0) || svt.eventEffect.teamValues.any((v) => v != 0),
    )) {
      return;
    }
    final decks = formation.svts.take(option.maxServants.clamp(1, 6)).toList();
    final fixedServantIds = <int>{};
    final fixedCeIds = <int>{};
    for (final deck in decks) {
      yield null;
      if (deck.supportType.isSupport) continue;
      if (deck.svt != null && !fixedServantIds.add(deck.svt!.id)) return;
      final grand = quest.isUseGrandBoard && deck.grandSvt && deck.svt != null;
      for (final equip in [deck.equip1, if (grand) deck.equip3]) {
        yield null;
        if (equip.ce != null &&
            BondCeIdentity.requiresUniqueOwnedIdentity(equip.ce!) &&
            !fixedCeIds.add(BondCeIdentity.of(equip.ce!.id))) {
          return;
        }
      }
    }
    final ownCes = <BondCeSource>[];
    for (final ce in _ownedCeClasses) {
      yield null;
      final ids = Map<int, bool>.of(ce.limitBreaks)..removeWhere((id, _) => fixedCeIds.contains(BondCeIdentity.of(id)));
      if (ids.isEmpty) continue;
      final effect = ce.byWearer.first;
      ownCes.add(
        BondCeSource(ce.cost, effect.teamRates, effect.teamValues, ids, ce.repeatable, identityOf: BondCeIdentity.of),
      );
    }
    final baseRates = List<int>.filled(_profiles.length, 0);
    final baseValues = List<int>.filled(_profiles.length, 0);
    void addSource(_Contribution effect) {
      for (var r = 0; r < _profiles.length; r++) {
        baseRates[r] += effect.teamRates[r];
        baseValues[r] += effect.teamValues[r];
      }
    }

    final supportFrontCount = option.frontlineBonus ? decks.take(3).where((d) => d.supportType.isSupport).length : 0;
    final positions = <_CeFirstPosition>[];
    var ceFixedCost = _fixedCost;
    for (final (p, deck) in decks.indexed) {
      yield null;
      final support = deck.supportType.isSupport;
      final fixedServant = !support && deck.svt != null;
      final grand = quest.isUseGrandBoard && deck.grandSvt && (fixedServant || support);
      final fixedCe1 = deck.equip1.ce == null ? null : BondSolvedCe(deck.equip1.ce!.id, deck.equip1.limitBreak);
      final fixedCe3 = !grand || deck.equip3.ce == null
          ? null
          : BondSolvedCe(deck.equip3.ce!.id, deck.equip3.limitBreak);
      final front = option.frontlineBonus && !support ? (p < 3 ? 200 : 0) + 40 * supportFrontCount : 0;
      final first = (quest.bond * (1 + front / 1000)).floor();
      if (support) {
        if (deck.equip1.ce != null) {
          addSource(_contribution(_ceVariant(deck.equip1.ce!, deck.equip1.limitBreak).supportEffects, const []));
        }
        if (fixedCe3 != null) {
          addSource(_contribution(_ceVariant(deck.equip3.ce!, deck.equip3.limitBreak).supportEffects, const []));
        }
        // Free support CEs: equip1 when unfixed, plus equip3 for a grand
        // support, enumerated as the product of both slots' choices.
        final freeCe1 = fixedCe1 == null ? <_CeClass?>[null, ..._supportCeClasses] : const <_CeClass?>[null];
        final freeCe3 = grand && fixedCe3 == null ? <_CeClass?>[null, ..._supportCeClasses] : const <_CeClass?>[null];
        final choices = <_CeFirstSupportChoice>[];
        for (final c1 in freeCe1) {
          for (final c3 in freeCe3) {
            yield null;
            final ce1LimitBreaks = _supportCeVariants(c1, fixedCe3?.id);
            if (c1 != null && ce1LimitBreaks.isEmpty) continue;
            final ce1Id = ce1LimitBreaks.keys.firstOrNull;
            final ce3LimitBreaks = _supportCeVariants(c3, ce1Id ?? fixedCe1?.id);
            if (c3 != null && ce3LimitBreaks.isEmpty) continue;
            final effect = _add(
              c1?.byWearer.first ?? _Contribution.zero(_profiles.length),
              c3?.byWearer.first ?? _Contribution.zero(_profiles.length),
            );
            final ce3Entry = ce3LimitBreaks.isEmpty ? null : ce3LimitBreaks.entries.first;
            choices.add(
              _CeFirstSupportChoice(
                effect.teamRates,
                effect.teamValues,
                ce1Id == null ? null : BondSolvedCe(ce1Id, ce1LimitBreaks[ce1Id]!),
                ce1LimitBreaks,
                ce3Entry == null ? null : BondSolvedCe(ce3Entry.key, ce3Entry.value),
                ce3LimitBreaks,
              ),
            );
          }
        }
        final competitiveChoices = <_CeFirstSupportChoice>[];
        for (var i = 0; i < choices.length; i++) {
          yield null;
          var dominated = false;
          for (var j = 0; j < choices.length; j++) {
            yield null;
            if (i != j && _supportChoiceDominates(choices[j], choices[i])) {
              dominated = true;
              break;
            }
          }
          if (!dominated) competitiveChoices.add(choices[i]);
        }
        positions.add(
          _CeFirstPosition(
            support: true,
            fixedServant: false,
            bondLimit: false,
            freeCe1: false,
            freeCe3: false,
            first: 0,
            fixedCe1: fixedCe1,
            fixedCe3: fixedCe3,
            fixedCe1Cost: 0,
            servants: const [],
            supportChoices: competitiveChoices,
          ),
        );
        continue;
      }

      final svtClasses = fixedServant ? _fixedSvtClasses(deck) : _svtClasses;
      if (svtClasses.isEmpty) return;
      final c1 = fixedCe1 == null ? null : _fixedCeClass(deck.equip1);
      final c3 = fixedCe3 == null ? null : _fixedCeClass(deck.equip3);
      for (final ce in [c1, c3]) {
        yield null;
        if (ce == null) continue;
        final reference = ce.byWearer[svtClasses.first.profile];
        for (final svt in svtClasses.skip(1)) {
          yield null;
          final other = ce.byWearer[svt.profile];
          if (!listEquals(reference.teamRates, other.teamRates) ||
              !listEquals(reference.teamValues, other.teamValues)) {
            return;
          }
        }
      }
      if (fixedServant) {
        final reference = svtClasses.first.eventEffect;
        if (svtClasses.any(
          (svt) =>
              !listEquals(reference.teamRates, svt.eventEffect.teamRates) ||
              !listEquals(reference.teamValues, svt.eventEffect.teamValues),
        )) {
          return;
        }
        addSource(reference);
      }
      if (c1 != null) addSource(c1.byWearer[svtClasses.first.profile]);
      if (c3 != null) addSource(c3.byWearer[svtClasses.first.profile]);
      final bonus = option.svtBonus[p];
      if (fixedServant && bonus.isBond15) {
        for (var r = 0; r < baseRates.length; r++) {
          yield null;
          baseRates[r] += kBond15BonusRate;
        }
      }
      final servants = <_CeFirstServant>[];
      for (final svt in svtClasses) {
        yield null;
        final ce1Effect = c1?.byWearer[svt.profile];
        final ce3Effect = c3?.byWearer[svt.profile];
        final selfRate =
            svt.campaignRate +
            svt.eventEffect.selfRate +
            (ce1Effect?.selfRate ?? 0) +
            (ce3Effect?.selfRate ?? 0) +
            bonus.addRate;
        final selfValue =
            svt.eventEffect.selfValue + (ce1Effect?.selfValue ?? 0) + (ce3Effect?.selfValue ?? 0) + bonus.addValue;
        for (final entry in svt.limits.entries) {
          yield null;
          if (!fixedServant && fixedServantIds.contains(entry.key)) continue;
          servants.add(_CeFirstServant(entry.key, entry.value, svt.cost, svt.profile, selfRate, selfValue));
        }
      }
      final searchAscensions = fixedServant && option.searchFixedAscensions && servants.length > 1;
      if (fixedServant && option.searchFixedAscensions && !searchAscensions) {
        ceFixedCost += servants.single.cost;
      }
      positions.add(
        _CeFirstPosition(
          support: false,
          fixedServant: fixedServant,
          searchAscensions: searchAscensions,
          bondLimit: fixedServant && bonus.isBondReachLimit,
          freeCe1: fixedCe1 == null,
          freeCe3: grand && fixedCe3 == null,
          first: first,
          fixedCe1: fixedCe1,
          fixedCe3: fixedCe3,
          fixedCe1Cost: deck.equip1.ce?.cost ?? 0,
          servants: servants,
          supportChoices: const [],
        ),
      );
    }
    final slots1 = positions.where((p) => p.freeCe1).length;
    final slots3 = positions.where((p) => p.freeCe3).length;
    const maxMaterializedCeCombinations = 250000;
    const maxSupportMaterializedCeCombinations = 20000;
    var combinations = bondCeCombinationUpper(
      capacities: [for (final ce in ownCes) ce.repeatable ? slots1 + slots3 : ce.identityCapacity],
      slots1: slots1,
      slots3: slots3,
      limit: maxMaterializedCeCombinations,
    );
    var supportCombinations = 1;
    for (final position in positions.where((p) => p.support)) {
      yield null;
      supportCombinations *= position.supportChoices.length;
      if (supportCombinations > maxMaterializedCeCombinations) {
        supportCombinations = maxMaterializedCeCombinations + 1;
        break;
      }
    }
    combinations *= supportCombinations;
    // With support alternatives, preparing every combination's upper bound
    // can cost more than streamed proof. Probe actual size before switching.
    final materializedLimit = supportCombinations > 1
        ? maxSupportMaterializedCeCombinations
        : maxMaterializedCeCombinations;
    final needsProbe = combinations > materializedLimit;
    final streamingGrand = _grandLayouts.isNotEmpty;
    final probe = needsProbe && supportCombinations <= materializedLimit && !forceStreamingCeFirst && !streamingGrand
        ? BondPreparationProbe<_CeFirstSelection>(
            maxItems: materializedLimit ~/ math.max(1, supportCombinations),
            maxSteps: 500000,
          )
        : null;
    if (kDebugMode) {
      debugPrint(
        '[BondSolver] capacity-aware CE combination upper: $combinations materializedLimit=$materializedLimit',
      );
    }
    final problem = _CeFirstProblem(
      maxCost: _maxCost,
      rateCap: ConstData.constants.maxFriendShipUpRatio,
      fixedCost: ceFixedCost,
      fixedRates: baseRates,
      fixedValues: baseValues,
      positions: positions,
      ownCes: ownCes,
      fixedCeIdentities: fixedCeIds,
      preparedOwnSelections: probe?.items,
      streaming: streamingGrand || forceStreamingCeFirst || supportCombinations > materializedLimit,
    );
    if (probe != null) {
      // No servant DP runs during the probe, so fallback starts with the
      // original evaluation budget and cannot discard an existing witness.
      yield* probe.collect(_ownCeSelections(problem));
      if (!probe.complete) {
        if (kDebugMode) debugPrint('[BondSolver] CE probe capped: steps=${probe.steps}; selecting streaming search');
        _preparedCeFirst = problem.asStreaming();
        return;
      }
      if (kDebugMode) {
        debugPrint(
          '[BondSolver] CE probe complete: owned=${probe.items.length} '
          'combinations=${probe.items.length * supportCombinations} steps=${probe.steps}',
        );
      }
    }
    _preparedCeFirst = problem;
  }

  bool _supportChoiceDominates(_CeFirstSupportChoice stronger, _CeFirstSupportChoice weaker) {
    var strict = false;
    for (var r = 0; r < _profiles.length; r++) {
      if (stronger.rates[r] < weaker.rates[r] || stronger.values[r] < weaker.values[r]) return false;
      strict |= stronger.rates[r] > weaker.rates[r] || stronger.values[r] > weaker.values[r];
    }
    return strict;
  }

  Set<int>? _releasedIds() {
    final region = _releaseReference.region;
    if (region.isJP) return null;
    final ids = db.gameData.mappingData.entityRelease.ofRegion(region);
    if (ids == null || ids.isEmpty) {
      throw StateError('release table for ${region.name} is unavailable');
    }
    return ids.toSet();
  }

  Iterable<void> _loadFreeServantsSteps(Set<int>? released) sync* {
    _loadedFreeSvts = true;
    for (final svt in db.gameData.servantsById.values) {
      yield null;
      if (svt.collectionNo <= 0 || !svt.isUserSvt) continue;
      if (option.excludedSvts.contains(svt.id)) continue;
      if (released != null && !released.contains(svt.id)) continue;
      if (_releaseReference == BondReleaseReference.questClosedAt) {
        final releasedAt = svt.extra.getReleasedAt();
        if (releasedAt > 0 && releasedAt > quest.closedAt) continue;
      }
      if (option.favoriteSvtOnly && !svt.status.favorite) continue;
      if (option.maxBond > 0 && svt.status.bond >= option.maxBond) continue;
      if (option.bondNotFullOnly && svt.status.isReachBondLimit) continue;
      final effects = _eventEffects(svt);
      final campaign = _campaignRate(svt.id);
      final limits = _svtLimits(svt);
      final seen = <String>{};
      for (final limit in limits) {
        yield null;
        final traits = _traits(svt, limit);
        if (!_matchesQuestRestrictions(traits)) continue;
        final cost = _svtCost(svt, limit);
        final key = '$cost|${traits.join(',')}';
        if (!seen.add(key)) continue;
        _svtVariants.add(_SvtVariant(svt, limit, cost, traits, effects, campaign));
      }
    }
  }

  Iterable<void> _loadFreeCesSteps(Set<int>? released) sync* {
    // Each family contributes one eligible representative, preferring owned
    // members. An unreleased first member must not hide released members.
    final skippedFamilyIds = <int>{};
    for (final family in BondCeIdentity.families) {
      final eligible = <int>[];
      final owned = <int>[];
      for (final id in family) {
        final ce = db.gameData.craftEssencesById[id];
        if (ce == null || (released != null && !released.contains(id))) continue;
        eligible.add(id);
        if (db.curUser.craftEssences[ce.collectionNo]?.favorite == true) owned.add(id);
      }
      eligible.sort();
      owned.sort();
      final representative = (owned.isEmpty ? eligible : owned).firstOrNull;
      skippedFamilyIds.addAll(family.where((id) => id != representative));
    }
    for (final ce in db.gameData.craftEssencesById.values.toList()..sort((a, b) => a.id.compareTo(b.id))) {
      yield null;
      if (ce.collectionNo <= 0) continue;
      if (BondCeIdentity.excluded(ce.id, option.excludedCes)) continue;
      if (skippedFamilyIds.contains(ce.id)) continue;
      // favoriteSvtEquipOnly keeps only owned CEs. It gates what an owned
      // servant may wear, not a support slot: a support borrows its CE from
      // someone else, so the user's ownership says nothing about it.
      final canOwn = !option.favoriteSvtEquipOnly || db.curUser.craftEssences[ce.collectionNo]?.favorite == true;
      if (released != null && !released.contains(ce.id)) continue;
      for (final lb in [false, true]) {
        yield null;
        final variant = _ceVariant(ce, lb);
        final ownEligible = canOwn && variant.ownEffects.isNotEmpty && variant.ownEffects.every(_isFreeCeEffect);
        final supportEffects = variant.supportEffects.where(_isFreeCeEffect).toList();
        if (!ownEligible && supportEffects.isEmpty) continue;
        _ceVariants.add(_CeVariant(ce, lb, ownEligible ? variant.ownEffects : const [], supportEffects));
      }
    }
    _candidateCes = _groupCandidateCes();
  }

  static bool _isFreeCeEffect(CeBondEffect effect) =>
      effect.scope == BondEffectScope.team && effect.wearerActIndiv.isEmpty && effect.wearerRequiredIndiv == 0;

  List<int> _candidateSvtIds() => {for (final variant in _svtVariants) variant.svt.id}.toList()..sort();

  BondCandidateCes _groupCandidateCes() {
    final traitRestricted = <int>{};
    final limited = <int>{};
    final repeatable = <int>{};
    for (final variant in _ceVariants) {
      if (variant.ownEffects.isEmpty) continue;
      if (variant.ownEffects.any((effect) => effect.hasTargetCondition)) {
        traitRestricted.add(variant.ce.id);
      } else if (BondCeIdentity.requiresUniqueOwnedIdentity(variant.ce)) {
        limited.add(variant.ce.id);
      } else {
        repeatable.add(variant.ce.id);
      }
    }
    // A CE with a trait effect at either limit break belongs to the first group.
    limited.removeAll(traitRestricted);
    repeatable.removeAll(traitRestricted);
    return (
      traitRestricted: List.unmodifiable(traitRestricted),
      limited: List.unmodifiable(limited),
      repeatable: List.unmodifiable(repeatable),
    );
  }

  Iterable<void> _loadFixedEffectsSteps(List<PlayerSvtData> decks) sync* {
    final seenSvtIds = <int>{};
    for (final variant in _svtVariants) {
      yield null;
      if (seenSvtIds.add(variant.svt.id)) _allEffects.addAll(variant.eventEffects);
    }
    for (final deck in decks) {
      yield null;
      if (!deck.supportType.isSupport && deck.svt != null) {
        _allEffects.addAll(_eventEffects(deck.svt!));
      }
      final grand = quest.isUseGrandBoard && deck.grandSvt && (deck.svt != null || deck.supportType.isSupport);
      for (final equip in [deck.equip1, if (grand) deck.equip3]) {
        yield null;
        if (equip.ce == null) continue;
        final variant = _ceVariant(equip.ce!, equip.limitBreak);
        _allEffects.addAll(variant.ownEffects);
        _allEffects.addAll(variant.supportEffects);
      }
    }
    for (final variant in _ceVariants) {
      yield null;
      _allEffects.addAll(variant.ownEffects);
      _allEffects.addAll(variant.supportEffects);
    }
    final unique = <String, CeBondEffect>{};
    for (final effect in _allEffects) {
      yield null;
      final key =
          '${effect.wearerActIndiv.join(',')}|${effect.wearerRequiredIndiv}'
          '|${effect.targetOrAll.map((e) => e.join(',')).join(';')}|${effect.targetPartial.join(',')}';
      unique.putIfAbsent(key, () => effect);
    }
    _allEffects
      ..clear()
      ..addAll(unique.values);
  }

  Iterable<void> _buildProfilesSteps(List<PlayerSvtData> decks) sync* {
    void enroll(List<int> traits) {
      final raw = (traits.toSet().toList()..sort()).join(',');
      if (_profileByRawTraits.containsKey(raw)) return;
      final signature = StringBuffer();
      for (final effect in _allEffects) {
        signature
          ..write(effect.wearerMatches(traits) ? '1' : '0')
          ..write(effect.targetMatches(traits) ? '1' : '0');
      }
      final profile = _profileBySignature.putIfAbsent(signature.toString(), () {
        _profiles.add(traits);
        return _profiles.length - 1;
      });
      _profileByRawTraits[raw] = profile;
    }

    enroll(const []);
    for (final variant in _svtVariants) {
      yield null;
      enroll(variant.traits);
    }
    for (final deck in decks) {
      yield null;
      if (!deck.supportType.isSupport && deck.svt != null) {
        for (final limit in _fixedSvtLimits(deck)) {
          if (_matchesQuestRestrictions(_traits(deck.svt!, limit))) enroll(_traits(deck.svt!, limit));
        }
      }
    }
  }

  int _profileOf(List<int> traits) {
    final raw = (traits.toSet().toList()..sort()).join(',');
    return _profileByRawTraits[raw]!;
  }

  Iterable<void> _buildSvtClassesSteps() sync* {
    final byKey = <String, _SvtClass>{};
    for (final variant in _svtVariants) {
      yield null;
      final profile = _profileOf(variant.traits);
      final effect = _contribution(variant.eventEffects, _profiles[profile]);
      final key = '${variant.cost}|$profile|${variant.campaignRate}|${effect.signature}';
      final existing = byKey[key];
      if (existing == null) {
        byKey[key] = _SvtClass(variant.cost, profile, variant.campaignRate, effect, {
          variant.svt.id: variant.limitCount,
        });
      } else {
        existing.limits.putIfAbsent(variant.svt.id, () => variant.limitCount);
      }
    }
    _svtClasses.addAll(byKey.values);
    for (final (i, cls) in _svtClasses.indexed) {
      yield null;
      cls.searchIndex = i;
    }
  }

  Iterable<void> _buildCeClassesSteps() sync* {
    final owned = <String, _CeClass>{};
    final support = <String, _CeClass>{};
    for (final variant in _ceVariants) {
      yield null;
      final repeatable = !BondCeIdentity.requiresUniqueOwnedIdentity(variant.ce);
      final ownEffect = _freeCeContribution(variant.ownEffects);
      yield null;
      final supportEffect = _freeCeContribution(variant.supportEffects);
      final supportSignature = supportEffect.signature;
      if (!ownEffect.isZero) {
        final ownEffects = List<_Contribution>.unmodifiable(List.filled(_profiles.length, ownEffect));
        // Preserve the full matrix key; serialize each identical row only once.
        final ownSignature = ownEffect.signature;
        final key =
            '${variant.ce.cost}|${List.filled(_profiles.length, ownSignature).join(';')}'
            '|${List.filled(_profiles.length, supportSignature).join(';')}|$repeatable';
        final cls = owned.putIfAbsent(key, () => _CeClass(variant.ce.cost, ownEffects, {}, repeatable: repeatable));
        cls.limitBreaks[variant.ce.id] = cls.limitBreaks[variant.ce.id] == true || variant.lb;
      }
      if (supportEffect.teamRates.any((v) => v != 0) || supportEffect.teamValues.any((v) => v != 0)) {
        final key = '$supportSignature|$repeatable';
        final cls = support.putIfAbsent(key, () => _CeClass(0, [supportEffect], {}, repeatable: repeatable));
        cls.limitBreaks[variant.ce.id] = cls.limitBreaks[variant.ce.id] == true || variant.lb;
      }
    }
    _ownedCeClasses.addAll(owned.values);
    _supportCeClasses.addAll(support.values);
    for (final cls in [..._ownedCeClasses, ..._supportCeClasses]) {
      if (!cls.repeatable) continue;
      final id = cls.limitBreaks.keys.reduce(math.min);
      final lb = cls.limitBreaks[id]!;
      cls.limitBreaks
        ..clear()
        ..[id] = lb;
    }
  }

  _Contribution _freeCeContribution(List<CeBondEffect> effects) {
    // _loadFreeCesSteps admits only wearer-independent team effects. Fixed
    // CEs use separate builders and may still depend on the wearer's traits.
    assert(
      effects.every((e) => e.scope == BondEffectScope.team && e.wearerActIndiv.isEmpty && e.wearerRequiredIndiv == 0),
    );
    final effect = _contribution(effects, const []);
    return _Contribution(0, 0, List<int>.unmodifiable(effect.teamRates), List<int>.unmodifiable(effect.teamValues));
  }

  /// Removal requires enough dominating identity capacity for every owned
  /// slot. A reusable generic class alone provides that capacity.
  Iterable<void> _pruneOwnedCeClassesSteps(List<PlayerSvtData> decks) sync* {
    final autoSlots = _grandLayouts.isEmpty ? 0 : _grandLayouts.first.length;
    final maxOwnedCeSlots = decks.fold<int>(autoSlots, (count, deck) {
      if (deck.supportType.isSupport) return count;
      return count + 1 + (quest.isUseGrandBoard && deck.grandSvt && deck.svt != null ? 1 : 0);
    });
    if (pruneDominatedCes && maxOwnedCeSlots > 0) {
      var changed = true;
      while (changed) {
        changed = false;
        for (final weaker in List<_CeClass>.of(_ownedCeClasses)) {
          yield null;
          final replacementIds = <int>{};
          var reusableReplacement = false;
          for (final stronger in _ownedCeClasses) {
            yield null;
            if (identical(stronger, weaker) || !_ceDominates(stronger, weaker)) continue;
            if (stronger.repeatable) {
              reusableReplacement = true;
              break;
            }
            replacementIds.addAll(stronger.limitBreaks.keys.map(BondCeIdentity.of));
          }
          // At most slots - 1 other uses can occupy restricted identities;
          // a reusable replacement cannot be exhausted by those uses.
          if (!reusableReplacement && replacementIds.length < maxOwnedCeSlots) continue;
          _ownedCeClasses.remove(weaker);
          changed = true;
          break;
        }
      }
    }
    for (final (i, cls) in _ownedCeClasses.indexed) {
      yield null;
      cls.searchIndex = i;
    }
  }

  bool _ceDominates(_CeClass stronger, _CeClass weaker) {
    if (!stronger.placementInvariant || stronger.cost > weaker.cost) return false;
    final replacement = stronger.byWearer.first;
    for (final (wearer, old) in weaker.byWearer.indexed) {
      for (var target = 0; target < _profiles.length; target++) {
        if (replacement.teamRates[target] < old.teamRates[target] ||
            replacement.teamValues[target] < old.teamValues[target]) {
          return false;
        }
      }
      if (replacement.teamRates[wearer] < old.teamRates[wearer] + old.selfRate ||
          replacement.teamValues[wearer] < old.teamValues[wearer] + old.selfValue) {
        return false;
      }
    }
    return true;
  }

  Map<int, bool> _supportCeVariants(_CeClass? cls, int? reserved) {
    if (cls == null) return const {};
    if (cls.repeatable || reserved == null) return cls.limitBreaks;
    return Map<int, bool>.of(cls.limitBreaks)
      ..removeWhere((id, _) => BondCeIdentity.of(id) == BondCeIdentity.of(reserved));
  }

  List<BondSearchItem> _supportItems(PlayerSvtData deck, bool grand) {
    final ce1 = deck.equip1.ce == null
        ? <_CeClass?>[null, ..._supportCeClasses]
        : <_CeClass?>[_fixedSupportCeClass(deck.equip1)];
    // A grand support also searches its reward (equip3) slot, mirroring own
    // grand servants; a fixed equip3 stays fixed and a non-grand support has
    // no equip3 at all.
    final ce3 = !grand
        ? const <_CeClass?>[null]
        : deck.equip3.ce == null
        ? <_CeClass?>[null, ..._supportCeClasses]
        : <_CeClass?>[_fixedSupportCeClass(deck.equip3)];
    final items = <BondSearchItem>[];
    var order = 0;
    for (final c1 in ce1) {
      for (final c3 in ce3) {
        final ce1LimitBreaks = _supportCeVariants(c1, grand ? deck.equip3.ce?.id : null);
        if (c1 != null && ce1LimitBreaks.isEmpty) continue;
        final ce1Id = ce1LimitBreaks.keys.firstOrNull;
        final ce3LimitBreaks = _supportCeVariants(c3, ce1Id);
        if (c3 != null && ce3LimitBreaks.isEmpty) continue;
        final effect = _add(
          c1?.byWearer.first ?? _Contribution.zero(_profiles.length),
          c3?.byWearer.first ?? _Contribution.zero(_profiles.length),
        );
        items.add(
          BondSearchItem(
            cost: 0,
            receiverProfile: null,
            selfRate: 0,
            selfValue: 0,
            teamRates: effect.teamRates,
            teamValues: effect.teamValues,
            wornCeCount: (ce1Id == null ? 0 : 1) + (ce3LimitBreaks.isEmpty ? 0 : 1),
            symmetryOrder: order++,
            payload: _ItemPayload(
              isSupport: true,
              fixedServant: false,
              servantLimits: const {},
              ce1LimitBreaks: ce1LimitBreaks,
              ce3LimitBreaks: ce3LimitBreaks,
              supportCe1: ce1Id,
            ),
          ),
        );
      }
    }
    return items;
  }

  Iterable<void> _ownItemsSteps(int position, PlayerSvtData deck, bool grand, {bool autoGrand = false}) sync* {
    final fixedSvt = deck.svt != null;
    final svts = fixedSvt ? _fixedSvtClasses(deck) : _svtClasses;
    final ce1 = deck.equip1.ce == null
        ? <_CeClass?>[null, ..._ownedCeClasses]
        : <_CeClass?>[_fixedCeClass(deck.equip1)];
    final ce3 = autoGrand
        ? _ownedCeClasses
        : grand
        ? (deck.equip3.ce == null ? <_CeClass?>[null, ..._ownedCeClasses] : <_CeClass?>[_fixedCeClass(deck.equip3)])
        : <_CeClass?>[null];
    final bonus = option.svtBonus[position];
    final items = <BondSearchItem>[];
    var order = 0;
    for (final svt in svts) {
      final ids = autoGrand ? svt.limits.keys.where(_grandEligibleIds.contains).toSet() : svt.limits.keys.toSet();
      if (ids.isEmpty) continue;
      final limits = autoGrand ? {for (final id in ids) id: svt.limits[id]!} : svt.limits;
      for (final c1 in ce1) {
        for (final c3 in ce3) {
          yield null;
          final effect = _add(
            _add(svt.eventEffect, c1?.byWearer[svt.profile] ?? _Contribution.zero(_profiles.length)),
            c3?.byWearer[svt.profile] ?? _Contribution.zero(_profiles.length),
          );
          final teamRates = List<int>.of(effect.teamRates);
          if (fixedSvt && bonus.isBond15) {
            for (var r = 0; r < teamRates.length; r++) {
              teamRates[r] += kBond15BonusRate;
            }
          }
          final ceIds = <Set<int>>[];
          final matchCe1 = c1 != null && !c1.repeatable;
          final matchCe3 = c3 != null && !c3.repeatable;
          if (matchCe1) ceIds.add(c1.limitBreaks.keys.toSet());
          if (matchCe3) ceIds.add(c3.limitBreaks.keys.toSet());
          items.add(
            BondSearchItem(
              cost: svt.cost + (c1?.cost ?? 0),
              receiverProfile: fixedSvt && bonus.isBondReachLimit ? null : svt.profile,
              selfRate: svt.campaignRate + effect.selfRate + bonus.addRate,
              selfValue: effect.selfValue + bonus.addValue,
              teamRates: teamRates,
              teamValues: effect.teamValues,
              servantIds: ids,
              ownedCeIds: ceIds,
              wornCeCount: (c1 == null ? 0 : 1) + (c3 == null ? 0 : 1),
              servantClassIndex: svt.searchIndex,
              ownedCeClassIndices: [
                if (c1?.searchIndex != null) c1!.searchIndex!,
                if (c3?.searchIndex != null) c3!.searchIndex!,
              ],
              symmetryOrder: order++,
              payload: _ItemPayload(
                isSupport: false,
                fixedServant: fixedSvt,
                enableGrand: autoGrand,
                servantLimits: limits,
                ce1LimitBreaks: c1?.limitBreaks ?? const {},
                ce3LimitBreaks: c3?.limitBreaks ?? const {},
                matchCe1Identity: matchCe1,
                matchCe3Identity: matchCe3,
              ),
            ),
          );
        }
      }
    }
    if (!fixedSvt && !autoGrand && deck.equip1.ce == null) {
      items.add(
        BondSearchItem(
          cost: 0,
          receiverProfile: null,
          selfRate: 0,
          selfValue: 0,
          teamRates: List.filled(_profiles.length, 0),
          teamValues: List.filled(_profiles.length, 0),
          symmetryOrder: order,
          payload: const _ItemPayload(
            isSupport: false,
            fixedServant: false,
            servantLimits: {},
            ce1LimitBreaks: {},
            ce3LimitBreaks: {},
          ),
        ),
      );
    }
    _preparedItems = items;
  }

  Servant _formServant(BondSolvedSlot target, Servant svt) =>
      target.fixedServant ? formation.svts[target.position].dispSvt ?? svt : svt;

  List<int> _svtLimits(Servant svt) => _svtLimitCache.putIfAbsent(
    svt.id,
    () => List.unmodifiable(BondReleaseRules.ascensionLimits(svt, _releasedCostumes)),
  );

  List<int> _fixedSvtLimits(PlayerSvtData deck) {
    final svt = deck.dispSvt!;
    if (option.searchFixedAscensions) return _svtLimits(svt);
    return [?BondReleaseRules.playableLimit(svt, deck.limitCount)];
  }

  List<_SvtClass> _fixedSvtClasses(PlayerSvtData deck) {
    final svt = deck.svt!;
    final seen = <String>{};
    final classes = <_SvtClass>[];
    for (final limit in _fixedSvtLimits(deck)) {
      final traits = _traits(svt, limit);
      if (!_matchesQuestRestrictions(traits)) continue;
      final profile = _profileOf(traits);
      final cost = _svtCost(svt, limit);
      final effect = _contribution(_eventEffects(svt), traits);
      if (!seen.add('$cost|$profile|${effect.signature}')) continue;
      classes.add(_SvtClass(cost, profile, _campaignRate(svt.id), effect, {svt.id: limit}));
    }
    return classes;
  }

  _CeClass _fixedCeClass(SvtEquipData equip) {
    final variant = _ceVariant(equip.ce!, equip.limitBreak);
    return _CeClass(
      equip.ce!.cost,
      [for (final traits in _profiles) _contribution(variant.ownEffects, traits)],
      {equip.ce!.id: equip.limitBreak},
      repeatable: !BondCeIdentity.requiresUniqueOwnedIdentity(equip.ce!),
    );
  }

  /// Fixed CE class for a support slot: support-scope effects and no cost.
  _CeClass _fixedSupportCeClass(SvtEquipData equip) {
    final variant = _ceVariant(equip.ce!, equip.limitBreak);
    return _CeClass(
      0,
      [_contribution(variant.supportEffects, const [])],
      {equip.ce!.id: equip.limitBreak},
      repeatable: !BondCeIdentity.requiresUniqueOwnedIdentity(equip.ce!),
    );
  }

  BondSolvedTeam _expand(BondSearchWitness witness) => _expandWitness(witness, _fixedEquipMasks);

  late final _fixedEquipMasks = (
    equip1: _fixedEquipMask((deck) => deck.equip1.ce != null),
    equip3: _fixedEquipMask((deck) => (deck.svt != null || deck.supportType.isSupport) && deck.equip3.ce != null),
  );

  int _fixedEquipMask(bool Function(PlayerSvtData) includes) {
    return formation.svts.indexed.fold<int>(0, (mask, entry) => includes(entry.$2) ? mask | (1 << entry.$1) : mask);
  }

  static BondSolvedTeam _expandWitness(BondSearchWitness witness, ({int equip1, int equip3}) fixedEquips) {
    final slots = <BondSolvedSlot>[];
    for (final (p, item) in witness.items.indexed) {
      final payload = item.payload! as _ItemPayload;
      final svtId = witness.servantIds[p];
      final chosenCes = witness.ownedCeIds[p];
      var ci = 0;
      BondSolvedCe? ce1, ce3;
      if (payload.isSupport) {
        final id = payload.supportCe1;
        if (id != null) ce1 = BondSolvedCe(id, payload.ce1LimitBreaks[id]!);
        final id3 = payload.ce3LimitBreaks.keys.firstOrNull;
        if (id3 != null) ce3 = BondSolvedCe(id3, payload.ce3LimitBreaks[id3]!);
      } else {
        if (payload.ce1LimitBreaks.isNotEmpty) {
          final id = payload.matchCe1Identity ? chosenCes[ci++] : payload.ce1LimitBreaks.keys.single;
          ce1 = BondSolvedCe(id, payload.ce1LimitBreaks[id]!);
        }
        if (payload.ce3LimitBreaks.isNotEmpty) {
          final id = payload.matchCe3Identity ? chosenCes[ci++] : payload.ce3LimitBreaks.keys.single;
          ce3 = BondSolvedCe(id, payload.ce3LimitBreaks[id]!);
        }
      }
      slots.add(
        BondSolvedSlot(
          position: p,
          servantId: svtId,
          limitCount: svtId == null ? null : payload.servantLimits[svtId],
          equip1: ce1,
          equip3: ce3,
          isSupport: payload.isSupport,
          fixedServant: payload.fixedServant,
          enableGrand: payload.enableGrand,
          bond: witness.slotBonds[p],
          cost: item.cost,
          servantCandidates: payload.servantLimits.keys.toList()..sort(),
          equip1Candidates: payload.ce1LimitBreaks.keys.toList()..sort(),
          equip3Candidates: payload.ce3LimitBreaks.keys.toList()..sort(),
          servantVariants: payload.servantLimits,
          equip1Variants: payload.ce1LimitBreaks,
          equip3Variants: payload.ce3LimitBreaks,
          fixedEquip1: fixedEquips.equip1 & (1 << p) != 0,
          fixedEquip3: fixedEquips.equip3 & (1 << p) != 0,
        ),
      );
    }
    return BondSolvedTeam(witness.totalBond, witness.totalCost, slots);
  }

  List<int> _traits(Servant svt, int limit) => BondReleaseRules.traits(svt, limit, _eventId, _releaseReference);

  bool _matchesQuestRestrictions(List<int> traits) {
    for (final restriction in _questIndivRestrictions) {
      if (!Restriction.checkSvtIndiv(restriction.rangeType, restriction.targetVals, traits)) return false;
    }
    return true;
  }

  int _svtCost(Servant svt, int limit) => svt.getAscended(limit, (a) => a.overwriteCost) ?? svt.cost;

  int _campaignRate(int svtId) => option.campaignBonusesFor(svtId).fold(0, (total, bonus) => total + bonus.rate);

  List<NiceSkill> _activeEventSkills(Servant svt) =>
      option.enableEvent ? svt.resolveBondEventSkills(quest, logicEventId: _eventId) : const [];

  List<CeBondEffect> _eventEffects(Servant svt) => _eventCache.putIfAbsent(
    svt.id,
    () => [for (final skill in _activeEventSkills(svt)) ..._eventSkillEffects(skill)],
  );

  _CeVariant _ceVariant(CraftEssence ce, bool lb) {
    return _ceCache.putIfAbsent('${ce.id}|$lb', () {
      return _CeVariant(
        ce,
        lb,
        CeBondEffect.extractAll(ce, lb, quest, support: false, logicEventId: _eventId),
        CeBondEffect.extractAll(ce, lb, quest, support: true, logicEventId: _eventId),
      );
    });
  }

  List<CeBondEffect> _eventSkillEffects(NiceSkill skill) {
    final effects = <CeBondEffect>[];
    for (final func in skill.functions) {
      // Activity passives contribute only to their owner in the solver.
      if (func.funcType != FuncType.servantFriendshipUp || func.funcTargetType != FuncTargetType.self) continue;
      if (func.funcquestTvals.isNotEmpty &&
          !Individuality.checkSignedIndivPartialMatch(self: _questTraits, signedTarget: func.funcquestTvals)) {
        continue;
      }
      final vals = func.svals.firstOrNull;
      if (vals == null) continue;
      if (vals.EventId != null && vals.EventId != 0 && vals.EventId != _eventId) continue;
      final rate = vals.RateCount ?? 0;
      final value = vals.AddCount ?? 0;
      if (rate == 0 && value == 0) continue;
      final targetOrAll = func.getOverwriteTvalsList();
      effects.add(
        CeBondEffect(
          scope: BondEffectScope.self,
          rate: rate,
          value: value,
          wearerActIndiv: skill.actIndividuality,
          wearerRequiredIndiv: vals.Individuality ?? 0,
          targetOrAll: targetOrAll,
          targetPartial: targetOrAll.isEmpty ? func.functvals : const [],
        ),
      );
    }
    return effects;
  }

  _Contribution _contribution(List<CeBondEffect> effects, List<int> wearerTraits) {
    var selfRate = 0, selfValue = 0;
    final teamRates = List<int>.filled(_profiles.length, 0);
    final teamValues = List<int>.filled(_profiles.length, 0);
    for (final effect in effects) {
      if (!effect.wearerMatches(wearerTraits)) continue;
      if (effect.scope == BondEffectScope.self) {
        if (effect.targetMatches(wearerTraits)) {
          selfRate += effect.rate;
          selfValue += effect.value;
        }
      } else {
        for (final (r, targetTraits) in _profiles.indexed) {
          if (!effect.targetMatches(targetTraits)) continue;
          teamRates[r] += effect.rate;
          teamValues[r] += effect.value;
        }
      }
    }
    return _Contribution(selfRate, selfValue, teamRates, teamValues);
  }

  _Contribution _add(_Contribution a, _Contribution b) => _Contribution(
    a.selfRate + b.selfRate,
    a.selfValue + b.selfValue,
    [for (var i = 0; i < _profiles.length; i++) a.teamRates[i] + b.teamRates[i]],
    [for (var i = 0; i < _profiles.length; i++) a.teamValues[i] + b.teamValues[i]],
  );

  static BondSearchResult _runPreparedBondSearch(_SearchInput input) => BondSearch.solve(
    input.problem,
    maxNodes: input.maxNodes,
    maxTies: input.maxTies,
    maxCandidates: input.maxCandidates,
  );

  static void _runProgressiveBondSearch(_ProgressInput input) {
    try {
      final grand = input.grand;
      if (grand != null) {
        for (final _ in grand.solveSteps(
          maxCandidates: input.maxCandidates,
          onProgress: (progress) => input.port.send(<Object?>['concrete', progress]),
          onComplete: (result) => input.port.send(<Object?>['concrete', result]),
        )) {}
      } else if (input.ceFirst != null) {
        final clock = Stopwatch()..start();
        var lastReport = -200;
        var sentWitness = false, sentProof = false;
        final result = _CeFirstSearch(input.ceFirst!, maxCandidates: input.maxCandidates).solve(
          onProgress: (progress) {
            final critical = (!sentWitness && progress.best != null) || (!sentProof && progress.provenOptimal);
            if (!critical && clock.elapsedMilliseconds - lastReport < 200) return;
            input.port.send(<Object?>['concrete', progress]);
            sentWitness |= progress.best != null;
            sentProof |= progress.provenOptimal;
            lastReport = clock.elapsedMilliseconds;
          },
        );
        input.port.send(<Object?>['concrete', result]);
      } else {
        final result = BondSearch.solve(
          input.general!,
          maxCandidates: input.maxCandidates,
          onProgress: (progress) => input.port.send(<Object?>['general', progress]),
        );
        input.port.send(<Object?>['general', result]);
      }
    } catch (e) {
      input.port.send(<Object?>['error', e.toString()]);
    } finally {
      input.port.send(<Object?>['done', null]);
    }
  }

  static _ConcreteBondSearchResult _runCeFirstSearch(_CeFirstSearchInput input) => _CeFirstSearch(
    input.problem,
    maxTies: input.maxTies,
    maxCandidates: input.maxCandidates,
  ).solve(maxEvaluations: input.maxEvaluations);
}

class _SvtVariant {
  final Servant svt;
  final int limitCount;
  final int cost;
  final List<int> traits;
  final List<CeBondEffect> eventEffects;
  final int campaignRate;
  const _SvtVariant(this.svt, this.limitCount, this.cost, this.traits, this.eventEffects, this.campaignRate);
}

class _CeVariant {
  final CraftEssence ce;
  final bool lb;
  final List<CeBondEffect> ownEffects;
  final List<CeBondEffect> supportEffects;
  const _CeVariant(this.ce, this.lb, this.ownEffects, this.supportEffects);
}

class _SvtClass {
  final int cost;
  final int profile;
  final int campaignRate;
  final _Contribution eventEffect;
  final Map<int, int> limits;
  int? searchIndex;
  _SvtClass(this.cost, this.profile, this.campaignRate, this.eventEffect, this.limits);
}

class _CeClass {
  final int cost;
  final List<_Contribution> byWearer;
  final Map<int, bool> limitBreaks;
  int? searchIndex;
  final bool repeatable;
  _CeClass(this.cost, this.byWearer, this.limitBreaks, {this.repeatable = false});

  int capacity(int slots) => repeatable ? slots : limitBreaks.keys.map(BondCeIdentity.of).toSet().length;

  bool get placementInvariant {
    if (byWearer.isEmpty) return false;
    final first = byWearer.first;
    if (first.selfRate != 0 || first.selfValue != 0) return false;
    for (final contribution in byWearer.skip(1)) {
      if (contribution.selfRate != 0 || contribution.selfValue != 0) return false;
      if (!listEquals(first.teamRates, contribution.teamRates) ||
          !listEquals(first.teamValues, contribution.teamValues)) {
        return false;
      }
    }
    return true;
  }
}

class _Contribution {
  final int selfRate;
  final int selfValue;
  final List<int> teamRates;
  final List<int> teamValues;
  const _Contribution(this.selfRate, this.selfValue, this.teamRates, this.teamValues);

  factory _Contribution.zero(int profiles) =>
      _Contribution(0, 0, List<int>.filled(profiles, 0), List<int>.filled(profiles, 0));

  bool get isZero =>
      selfRate == 0 && selfValue == 0 && teamRates.every((e) => e == 0) && teamValues.every((e) => e == 0);

  String get signature => '$selfRate|$selfValue|${teamRates.join(',')}|${teamValues.join(',')}';
}

class _ItemPayload {
  final bool isSupport;
  final bool fixedServant;
  final bool enableGrand;
  final Map<int, int> servantLimits;
  final Map<int, bool> ce1LimitBreaks;
  final Map<int, bool> ce3LimitBreaks;
  final int? supportCe1;
  final bool matchCe1Identity;
  final bool matchCe3Identity;

  const _ItemPayload({
    required this.isSupport,
    required this.fixedServant,
    this.enableGrand = false,
    required this.servantLimits,
    required this.ce1LimitBreaks,
    required this.ce3LimitBreaks,
    this.supportCe1,
    this.matchCe1Identity = true,
    this.matchCe3Identity = true,
  });
}

class _SearchInput {
  final BondSearchProblem problem;
  final int? maxNodes;
  final int maxTies;
  final int maxCandidates;
  const _SearchInput(this.problem, this.maxNodes, this.maxTies, this.maxCandidates);
}

class _ProgressInput {
  final SendPort port;
  final BondSearchProblem? general;
  final _CeFirstProblem? ceFirst;
  final int maxCandidates;

  final _GrandFormationSearch? grand;

  const _ProgressInput(this.port, this.general, this.ceFirst, this.grand, this.maxCandidates);
}
