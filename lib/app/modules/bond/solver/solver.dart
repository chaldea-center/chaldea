import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show compute, kIsWeb, listEquals;

import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/models/gamedata/individuality.dart' show Individuality;
import 'package:chaldea/models/models.dart';

import '../bond_rules.dart';
import 'bond_effect.dart';
import 'search.dart';

part 'ce_first.dart';

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

class BondSolvedSlot {
  final int position;
  final int? servantId;
  final int? limitCount;
  final BondSolvedCe? equip1;
  final BondSolvedCe? equip3;
  final bool isSupport;
  final bool fixedServant;
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
    (BondSolvedCe?, Map<int, bool>)? ce1,
    (BondSolvedCe?, Map<int, bool>)? ce3,
  }) => BondSolvedSlot(
    position: position,
    servantId: servantId,
    limitCount: limitCount ?? this.limitCount,
    equip1: ce1 == null ? equip1 : ce1.$1,
    equip3: ce3 == null ? equip3 : ce3.$1,
    isSupport: isSupport,
    fixedServant: fixedServant,
    bond: bond,
    cost: cost ?? this.cost,
    servantCandidates: servantCandidates,
    servantVariants: servantVariants,
    equip1Candidates: ce1 == null ? equip1Candidates : ce1.$2.keys.toList(),
    equip3Candidates: ce3 == null ? equip3Candidates : ce3.$2.keys.toList(),
    equip1Variants: ce1 == null ? equip1Variants : ce1.$2,
    equip3Variants: ce3 == null ? equip3Variants : ce3.$2,
    fixedEquip1: fixedEquip1,
    fixedEquip3: fixedEquip3,
  );
}

class BondSolvedTeam {
  final int totalBond;
  final int totalCost;
  final List<BondSolvedSlot> slots;
  const BondSolvedTeam(this.totalBond, this.totalCost, this.slots);

  /// Lists concrete CE instances whose trait-targeted effects apply to [target].
  List<BondCeRecipientBonus> traitCeBonusesFor(BondSolvedSlot target, QuestPhase quest, FormationBondOption option) {
    final reference = BondReleaseRules.resolve(option.releaseReference, quest);
    final targetSvt = target.servantId == null ? null : db.gameData.servantsById[target.servantId];
    if (targetSvt == null) return const [];
    final targetTraits = BondReleaseRules.traits(targetSvt, target.limitCount ?? 4, quest.logicEventId ?? 0, reference);
    final bonuses = <BondCeRecipientBonus>[];
    for (final wearer in slots) {
      final wearerSvt = wearer.servantId == null ? null : db.gameData.servantsById[wearer.servantId];
      final wearerTraits = wearer.isSupport || wearerSvt == null
          ? const <int>[]
          : BondReleaseRules.traits(wearerSvt, wearer.limitCount ?? 4, quest.logicEventId ?? 0, reference);
      for (final equipped in [wearer.equip1, wearer.equip3]) {
        if (equipped == null) continue;
        final ce = db.gameData.craftEssencesById[equipped.id];
        if (ce == null) continue;
        final effects = CeBondEffect.extractAll(ce, equipped.limitBreak, quest, support: wearer.isSupport);
        var rate = 0, value = 0;
        final targetTraitGroups = <List<int>>[];
        for (final effect in effects) {
          if (!effect.hasCondition || !effect.wearerMatches(wearerTraits)) continue;
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
  BattleTeamSetup applyTo(BattleTeamSetup source, FormationBondOption option) {
    final applied = source.copy();
    for (final slot in slots) {
      final deck = applied.svts[slot.position];
      if (slot.isSupport) {
        deck.svt = null;
        _setEquip(deck.equip1, slot.equip1);
        if (slot.equip3 != null) _setEquip(deck.equip3, slot.equip3);
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
        applied.svts[slot.position] = PlayerSvtData.svt(svt)..limitCount = slot.limitCount ?? 4;
      }
      final target = applied.svts[slot.position];
      target.limitCount = slot.limitCount ?? target.limitCount;
      _setEquip(target.equip1, slot.equip1);
      if (slot.equip3 != null) _setEquip(target.equip3, slot.equip3);
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
  static List<BondSolvedTeam> _concreteRepresentatives(
    BondSolvedTeam best,
    List<BondSolvedTeam> groups, {
    int maxTeams = 20,
    BondSolvedTeam Function(BondSolvedTeam)? normalize,
  }) {
    final teams = <BondSolvedTeam>[];
    final seen = <String>{};
    void add(BondSolvedTeam team) {
      if (normalize != null) team = normalize(team);
      if (team.totalBond == best.totalBond && seen.add(team._signature)) teams.add(team);
    }

    add(best);
    for (final group in groups) {
      if (teams.length == maxTeams) break;
      add(group);
    }
    final seeds = List<BondSolvedTeam>.of(teams);
    final choices = <Iterator<BondSolvedTeam>>[];
    for (final seed in seeds) {
      for (var p = 0; p < seed.slots.length; p++) {
        for (var kind = 0; kind < 3; kind++) {
          choices.add(_substituteOneMember(seed, p, kind).iterator);
        }
      }
    }
    while (teams.length < maxTeams) {
      var advanced = false;
      for (final choice in choices) {
        if (!choice.moveNext()) continue;
        advanced = true;
        add(choice.current);
        if (teams.length == maxTeams) break;
      }
      if (!advanced) break;
    }
    return List.unmodifiable(teams);
  }

  /// Expand a bounded set of feasible seeds by score tier. Lower scores are used
  /// only after the available higher-score concrete variants have been added.
  static List<BondSolvedTeam> _rankedCandidates(
    List<BondSolvedTeam> seeds, {
    required int maxTeams,
    BondSolvedTeam Function(BondSolvedTeam)? normalize,
  }) {
    if (seeds.isEmpty || maxTeams < 1) return const [];
    final byScore = <int, List<BondSolvedTeam>>{};
    for (final seed in seeds) {
      byScore.putIfAbsent(seed.totalBond, () => []).add(seed);
    }
    final scores = byScore.keys.toList()..sort((a, b) => b.compareTo(a));
    final result = <BondSolvedTeam>[];
    for (final score in scores) {
      final group = byScore[score]!..sort((a, b) => b.totalCost.compareTo(a.totalCost));
      final representatives = _concreteRepresentatives(
        group.first,
        group,
        maxTeams: maxTeams - result.length,
        normalize: normalize,
      ).toList()..sort((a, b) => b.totalCost.compareTo(a.totalCost));
      result.addAll(representatives);
      if (result.length >= maxTeams) break;
    }
    return List.unmodifiable(result);
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
        if (member.isSupport) continue;
        if (member.servantId != null && !ownedServants.add(member.servantId!)) return null;
        for (final ce in [member.equip1, member.equip3]) {
          if (ce != null && !ownedCes.add(BondCeIdentity.of(ce.id))) return null;
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

  /// Number of feasible CE combinations prepared by the CE-first search.
  /// Null for the general branch-and-bound search.
  final int? possibleCombinations;

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
    this.possibleCombinations,
  });
}

class BondAscensionRequirement {
  final List<int> all;
  final List<int> allowed;
  const BondAscensionRequirement(this.all, this.allowed);
  bool get restricted => allowed.length < all.length;
}

/// Converts game data into effect-equivalent search choices, then invokes the
/// exact search core. The quest and formation are read only during preparation;
/// [solveAsync] moves the prepared search problem to a background isolate.
class FormationBondSolver {
  FormationBondSolver._(this.option, this.quest, this.formation, this.pruneDominatedCes);

  final FormationBondOption option;
  final QuestPhase quest;
  final BattleTeamSetup formation;
  final bool pruneDominatedCes;
  BondReleaseReference get _releaseReference => BondReleaseRules.resolve(option.releaseReference, quest);
  int get _candidateLimit => option.maxCandidateTeams.clamp(1, 200).toInt();

  final List<_SvtVariant> _svtVariants = [];
  final List<_CeVariant> _ceVariants = [];
  final List<CeBondEffect> _allEffects = [];
  final List<List<int>> _profiles = [];
  final Map<String, int> _profileBySignature = {};
  final Map<String, int> _profileByRawTraits = {};
  final List<_SvtClass> _svtClasses = [];
  final List<_CeClass> _ownedCeClasses = [];
  final List<_CeClass> _supportCeClasses = [];
  final Map<int, List<CeBondEffect>> _eventCache = {};
  final Map<String, _CeVariant> _ceCache = {};

  late final int _eventId = quest.logicEventId ?? 0;
  late final List<int> _questTraits = quest.questIndividuality;
  late final List<Restriction> _questIndivRestrictions = [
    for (final entry in quest.restrictions)
      if (entry.restriction.type == RestrictionType.individuality) entry.restriction,
  ];
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
    final svt = db.gameData.servantsById[target.servantId];
    if (svt == null || target.isSupport) return const BondAscensionRequirement([], []);
    final evaluator = FormationBondSolver._(option, quest, formation, false);
    final all = (evaluator._svtLimits(svt).toSet()..add(target.limitCount ?? 4)).toList()..sort();
    final allowed = <int>[];
    for (final limit in all) {
      if (!evaluator._matchesQuestRestrictions(evaluator._traits(svt, limit))) continue;
      final changed = BondSolvedTeam(team.totalBond, team.totalCost, [
        for (final slot in team.slots) slot.position == target.position ? slot.copyWith(limitCount: limit) : slot,
      ]);
      final score = evaluator._scoreConcrete(changed);
      if (score.$2 == team.totalCost && listEquals(score.$1, team.slots.map((slot) => slot.bond).toList())) {
        allowed.add(limit);
      }
    }
    return BondAscensionRequirement(all, allowed);
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
        if (slot.fixedServant && option.svtBonus[slot.position].isBond15) {
          for (var r = 0; r < rates.length; r++) {
            rates[r] += 250;
          }
        }
      }
      final effects = <CeBondEffect>[
        if (!slot.isSupport && slot.servantId != null) ..._eventEffects(db.gameData.servantsById[slot.servantId]!),
        for (final equipped in [slot.equip1, slot.equip3])
          if (equipped != null)
            ...(slot.isSupport
                ? _ceVariant(db.gameData.craftEssencesById[equipped.id]!, equipped.limitBreak).supportEffects
                : _ceVariant(db.gameData.craftEssencesById[equipped.id]!, equipped.limitBreak).ownEffects),
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
    final supportFront = option.frontlineBonus ? team.slots.where((s) => s.isSupport && s.position < 3).length : 0;
    final bonds = List<int>.filled(team.slots.length, 0);
    for (final (p, slot) in team.slots.indexed) {
      if (slot.isSupport ||
          slot.servantId == null ||
          (slot.fixedServant && option.svtBonus[slot.position].isBondReachLimit)) {
        continue;
      }
      final front = option.frontlineBonus ? (slot.position < 3 ? 200 : 0) + 40 * supportFront : 0;
      final first = (quest.bond * (1 + front / 1000)).floor();
      final rate = math.min(rates[p], ConstData.constants.maxFriendShipUpRatio);
      bonds[p] = (first * (1 + rate / 1000)).floor() + values[p];
    }
    return (bonds, cost);
  }

  /// Concrete representatives are stable; rearrangements preserve the source multiset.
  BondSolvedTeam _normalizeTeam(BondSolvedTeam team) {
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
            final id = (candidates.keys.toList()..sort()).first;
            final chosen = BondSolvedCe(id, candidates[id]!);
            final effects = _ceVariant(db.gameData.craftEssencesById[id]!, chosen.limitBreak).supportEffects;
            final variants = effects.every((e) => e.isFlat) ? {id: chosen.limitBreak} : candidates;
            slots[p] = third ? slots[p].copyWith(ce3: (chosen, variants)) : slots[p].copyWith(ce1: (chosen, variants));
          }
        } else if (fixed) {
          used.add(BondCeIdentity.of(ce.id));
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
        if (!used.add(identity)) continue;
        final ce = BondSolvedCe(id, candidates[id]!);
        if (assign(index + 1)) {
          final effects = _ceVariant(db.gameData.craftEssencesById[id]!, ce.limitBreak).ownEffects;
          final variants = effects.every((e) => e.isFlat) ? {id: ce.limitBreak} : candidates;
          slots[p] = third ? slots[p].copyWith(ce3: (ce, variants)) : slots[p].copyWith(ce1: (ce, variants));
          return true;
        }
        used.remove(identity);
      }
      return false;
    }

    if (!assign(0)) throw StateError('solved CE identities cannot be instantiated');
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
    return BondSolvedTeam(team.totalBond, team.totalCost, slots);
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
  }) {
    final stopwatch = Stopwatch()..start();
    return FormationBondSolver._(
      option,
      quest,
      formation.copy(),
      pruneDominatedCes,
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
  }) async {
    final stopwatch = Stopwatch()..start();
    final solver = FormationBondSolver._(option, quest, formation.copy(), pruneDominatedCes);
    final problem = solver._prepareProblem();
    final ceFirst = useCeFirst ? solver._prepareCeFirst() : null;
    if (ceFirst != null) {
      final search = await compute(
        FormationBondSolver._runCeFirstSearch,
        _CeFirstSearchInput(ceFirst, maxNodes, maxTies, solver._candidateLimit),
      );
      return solver._ceFirstResult(search, stopwatch, maxTies: maxTies);
    }
    final search = await compute(
      FormationBondSolver._runPreparedBondSearch,
      _SearchInput(problem, maxNodes, maxTies, solver._candidateLimit),
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
  }) async* {
    final stopwatch = Stopwatch()..start();
    final solver = FormationBondSolver._(option, quest, formation.copy(), pruneDominatedCes);
    final problem = solver._prepareProblem();
    final ceFirst = solver._prepareCeFirst();
    if (kIsWeb) {
      // Web has no worker isolate. Keep the same provisional/final contract.
      if (ceFirst != null) {
        final provisional = _CeFirstSearch(ceFirst, maxCandidates: solver._candidateLimit).solve(maxEvaluations: 8);
        yield solver._ceFirstResult(provisional, stopwatch);
        if (!provisional.provenOptimal) {
          yield solver._ceFirstResult(
            _CeFirstSearch(ceFirst, maxCandidates: solver._candidateLimit).solve(),
            stopwatch,
          );
        }
      } else {
        final provisional = BondSearch.solve(problem, maxNodes: 1200000, maxCandidates: solver._candidateLimit);
        yield solver._result(provisional, stopwatch);
        if (!provisional.provenOptimal) {
          yield solver._result(BondSearch.solve(problem, maxCandidates: solver._candidateLimit), stopwatch);
        }
      }
      return;
    }

    final messages = ReceivePort();
    final worker = await Isolate.spawn(
      FormationBondSolver._runProgressiveBondSearch,
      _ProgressInput(messages.sendPort, problem, ceFirst, solver._candidateLimit),
    );
    try {
      await for (final message in messages) {
        final parts = message as List<Object?>;
        switch (parts[0]) {
          case 'ce':
            yield solver._ceFirstResult(parts[1]! as _CeFirstResult, stopwatch);
          case 'general':
            yield solver._result(parts[1]! as BondSearchResult, stopwatch);
          case 'error':
            throw StateError(parts[1] as String);
          case 'done':
            return;
        }
      }
    } finally {
      messages.close();
      worker.kill(priority: Isolate.immediate);
    }
  }

  BondSolverResult _solve({
    int? maxNodes,
    required int maxTies,
    required bool useCeFirst,
    required Stopwatch stopwatch,
  }) {
    final problem = _prepareProblem();
    final ceFirst = useCeFirst ? _prepareCeFirst() : null;
    if (ceFirst != null) {
      return _ceFirstResult(
        _CeFirstSearch(ceFirst, maxTies: maxTies, maxCandidates: _candidateLimit).solve(maxEvaluations: maxNodes),
        stopwatch,
        maxTies: maxTies,
      );
    }
    final search = BondSearch.solve(problem, maxNodes: maxNodes, maxTies: maxTies, maxCandidates: _candidateLimit);
    return _result(search, stopwatch, maxTies: maxTies);
  }

  BondSearchProblem _prepareProblem() {
    if (option.svtBonus.length < 6) throw StateError('formation bond bonuses must contain six positions');
    final decks = formation.svts.take(6).toList();
    for (final (position, deck) in decks.indexed) {
      if (deck.supportType.isSupport || deck.svt == null) continue;
      if (!_fixedSvtLimits(deck).any((limit) => _matchesQuestRestrictions(_traits(deck.svt!, limit)))) {
        throw StateError('fixed servant at position ${position + 1} does not meet quest restrictions');
      }
    }
    final maxCost = _maxCost = option.maxCost ?? ConstData.userLevel[ConstData.maxUserLevel]?.maxCost ?? -1;
    if (maxCost < 0) throw StateError('master-level cost table is unavailable');
    final needsFreeServant = decks.any((d) => !d.supportType.isSupport && d.svt == null);
    final needsFreeCe = decks.any(
      (d) =>
          d.equip1.ce == null ||
          (quest.isUseGrandBoard && d.grandSvt && !d.supportType.isSupport && d.svt != null && d.equip3.ce == null),
    );
    final released = needsFreeServant || needsFreeCe ? _releasedIds() : null;

    if (needsFreeServant) _loadFreeServants(released);
    if (needsFreeCe) _loadFreeCes(released);
    _loadFixedEffects(decks);
    _buildProfiles(decks);
    _buildSvtClasses();
    _buildCeClasses();
    _pruneOwnedCeClasses(decks);

    final positions = <BondSearchPosition>[];
    final supportFrontCount = option.frontlineBonus ? decks.take(3).where((d) => d.supportType.isSupport).length : 0;
    var fixedCost = 0;
    var symmetryGroup = 0;
    final freeGroupByProfile = <String, int>{};
    for (final (p, deck) in decks.indexed) {
      final isSupport = deck.supportType.isSupport;
      final fixedSvt = !isSupport && deck.svt != null;
      final grand = quest.isUseGrandBoard && deck.grandSvt && (fixedSvt || isSupport);
      final front = option.frontlineBonus && !isSupport ? (p < 3 ? 200 : 0) + 40 * supportFrontCount : 0;
      final items = isSupport ? _supportItems(deck, grand) : _ownItems(p, deck, grand);
      if (items.isEmpty) throw StateError('no candidate at position ${p + 1}');

      int? group;
      if (!fixedSvt && !isSupport && deck.equip1.ce == null) {
        final bonus = option.svtBonus[p];
        final key = '$front|${bonus.addRate}|${bonus.addValue}';
        group = freeGroupByProfile.putIfAbsent(key, () => symmetryGroup++);
      }
      positions.add(BondSearchPosition(frontlineRate: front, items: items, symmetryGroup: group));
      if (!isSupport) {
        if (fixedSvt && !option.searchFixedAscensions) fixedCost += _svtCost(deck.svt!, deck.limitCount);
        fixedCost += deck.equip1.ce?.cost ?? 0;
      }
    }

    _fixedCost = fixedCost;
    _itemCount = positions.fold<int>(0, (sum, position) => sum + position.items.length);
    return BondSearchProblem(
      baseBond: quest.bond,
      rateCap: ConstData.constants.maxFriendShipUpRatio,
      maxCost: maxCost,
      receiverProfileCount: _profiles.length,
      positions: positions,
      servantClassCapacities: [for (final cls in _svtClasses) cls.limits.length],
      ownedCeClassCapacities: [for (final cls in _ownedCeClasses) cls.limitBreaks.length],
      ownedCeIdentities: {
        for (final family in BondCeIdentity.families)
          for (final id in family) id: family.first,
      },
    );
  }

  BondSolverResult _result(BondSearchResult search, Stopwatch stopwatch, {int maxTies = 20}) {
    final best = search.best == null ? null : _normalizeTeam(_expand(search.best!));
    return BondSolverResult(
      best: best,
      ties: best == null
          ? const []
          : BondSolvedTeam._concreteRepresentatives(
              best,
              [for (final tie in search.ties) _expand(tie)],
              maxTeams: maxTies,
              normalize: _normalizeTeam,
            ),
      candidates: best == null
          ? const []
          : BondSolvedTeam._rankedCandidates(
              [best, for (final candidate in search.candidates) _expand(candidate)],
              maxTeams: _candidateLimit,
              normalize: _normalizeTeam,
            ),
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
    );
  }

  BondSolverResult _ceFirstResult(_CeFirstResult search, Stopwatch stopwatch, {int maxTies = 20}) {
    return BondSolverResult(
      best: search.best == null ? null : _normalizeTeam(search.best!),
      ties: search.best == null
          ? const []
          : BondSolvedTeam._concreteRepresentatives(
              search.best!,
              search.ties,
              maxTeams: maxTies,
              normalize: _normalizeTeam,
            ),
      candidates: search.best == null
          ? const []
          : BondSolvedTeam._rankedCandidates(
              [search.best!, ...search.candidates],
              maxTeams: _candidateLimit,
              normalize: _normalizeTeam,
            ),
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
      possibleCombinations: search.possibleCombinations,
    );
  }

  _CeFirstProblem? _prepareCeFirst() {
    if (_ownedCeClasses.any((ce) => !ce.placementInvariant)) return null;
    if (_svtClasses.any(
      (svt) => svt.eventEffect.teamRates.any((v) => v != 0) || svt.eventEffect.teamValues.any((v) => v != 0),
    )) {
      return null;
    }
    final decks = formation.svts.take(6).toList();
    final fixedServantIds = <int>{};
    final fixedCeIds = <int>{};
    for (final deck in decks) {
      if (deck.supportType.isSupport) continue;
      if (deck.svt != null && !fixedServantIds.add(deck.svt!.id)) return null;
      final grand = quest.isUseGrandBoard && deck.grandSvt && deck.svt != null;
      for (final equip in [deck.equip1, if (grand) deck.equip3]) {
        if (equip.ce != null && !fixedCeIds.add(BondCeIdentity.of(equip.ce!.id))) return null;
      }
    }
    final ownCes = <_CeFirstCe>[];
    for (final ce in _ownedCeClasses) {
      final ids = Map<int, bool>.of(ce.limitBreaks)..removeWhere((id, _) => fixedCeIds.contains(BondCeIdentity.of(id)));
      if (ids.isEmpty) continue;
      final effect = ce.byWearer.first;
      ownCes.add(_CeFirstCe(ce.cost, effect.teamRates, effect.teamValues, ids));
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
        final choices = <_CeFirstSupportChoice>[
          _CeFirstSupportChoice(List.filled(_profiles.length, 0), List.filled(_profiles.length, 0), null),
        ];
        if (fixedCe1 == null) {
          for (final ce in _supportCeClasses) {
            final id = ce.limitBreaks.keys.firstOrNull;
            if (id == null) continue;
            final effect = ce.byWearer.first;
            choices.add(
              _CeFirstSupportChoice(
                effect.teamRates,
                effect.teamValues,
                BondSolvedCe(id, ce.limitBreaks[id]!),
                ce.limitBreaks,
              ),
            );
          }
        }
        final competitiveChoices = <_CeFirstSupportChoice>[];
        for (var i = 0; i < choices.length; i++) {
          var dominated = false;
          for (var j = 0; j < choices.length; j++) {
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
      if (svtClasses.isEmpty) return null;
      final c1 = fixedCe1 == null ? null : _fixedCeClass(deck.equip1);
      final c3 = fixedCe3 == null ? null : _fixedCeClass(deck.equip3);
      for (final ce in [c1, c3]) {
        if (ce == null) continue;
        final reference = ce.byWearer[svtClasses.first.profile];
        for (final svt in svtClasses.skip(1)) {
          final other = ce.byWearer[svt.profile];
          if (!listEquals(reference.teamRates, other.teamRates) ||
              !listEquals(reference.teamValues, other.teamValues)) {
            return null;
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
          return null;
        }
        addSource(reference);
      }
      if (c1 != null) addSource(c1.byWearer[svtClasses.first.profile]);
      if (c3 != null) addSource(c3.byWearer[svtClasses.first.profile]);
      final bonus = option.svtBonus[p];
      if (fixedServant && bonus.isBond15) {
        for (var r = 0; r < baseRates.length; r++) {
          baseRates[r] += 250;
        }
      }
      final servants = <_CeFirstServant>[];
      for (final svt in svtClasses) {
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
    var combinations = _multisetCount(ownCes.length, positions.where((p) => p.freeCe1).length);
    combinations *= _multisetCount(ownCes.length, positions.where((p) => p.freeCe3).length);
    for (final position in positions.where((p) => p.support)) {
      combinations *= position.supportChoices.length;
      if (combinations > 250000) return null;
    }
    if (combinations > 250000) return null;
    return _CeFirstProblem(
      maxCost: _maxCost,
      rateCap: ConstData.constants.maxFriendShipUpRatio,
      fixedCost: ceFixedCost,
      fixedRates: baseRates,
      fixedValues: baseValues,
      positions: positions,
      ownCes: ownCes,
    );
  }

  bool _supportChoiceDominates(_CeFirstSupportChoice stronger, _CeFirstSupportChoice weaker) {
    var strict = false;
    for (var r = 0; r < _profiles.length; r++) {
      if (stronger.rates[r] < weaker.rates[r] || stronger.values[r] < weaker.values[r]) return false;
      strict |= stronger.rates[r] > weaker.rates[r] || stronger.values[r] > weaker.values[r];
    }
    return strict;
  }

  int _multisetCount(int classes, int slots) {
    var result = 1;
    for (var i = 1; i <= slots; i++) {
      result = result * (classes + i) ~/ i;
      if (result > 250000) return result;
    }
    return result;
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

  void _loadFreeServants(Set<int>? released) {
    for (final svt in db.gameData.servantsById.values) {
      if (svt.collectionNo <= 0 || !svt.isUserSvt) continue;
      if (option.excludedSvts.contains(svt.id)) continue;
      if (released != null && !released.contains(svt.id)) continue;
      if (_releaseReference == BondReleaseReference.questClosedAt) {
        final releasedAt = svt.extra.getReleasedAt();
        if (releasedAt > 0 && releasedAt > quest.closedAt) continue;
      }
      if (option.favoriteOnly && !svt.status.favorite) continue;
      if (option.maxBond > 0 && svt.status.bond >= option.maxBond) continue;
      final effects = _eventEffects(svt);
      final campaign = _campaignRate(svt.id);
      final limits = _svtLimits(svt);
      final seen = <String>{};
      for (final limit in limits) {
        final traits = _traits(svt, limit);
        if (!_matchesQuestRestrictions(traits)) continue;
        final cost = _svtCost(svt, limit);
        final key = '$cost|${traits.join(',')}';
        if (!seen.add(key)) continue;
        _svtVariants.add(_SvtVariant(svt, limit, cost, traits, effects, campaign));
      }
    }
  }

  void _loadFreeCes(Set<int>? released) {
    for (final ce in db.gameData.craftEssencesById.values.toList()..sort((a, b) => a.id.compareTo(b.id))) {
      if (ce.collectionNo <= 0) continue;
      if (BondCeIdentity.excluded(ce.id, option.excludedCes)) continue;
      if (BondCeIdentity.of(ce.id) != ce.id) continue;
      if (released != null && !released.contains(ce.id)) continue;
      for (final lb in [false, true]) {
        final variant = _ceVariant(ce, lb);
        final ownEligible =
            variant.ownEffects.isNotEmpty &&
            variant.ownEffects.every(
              (effect) =>
                  effect.scope == BondEffectScope.team &&
                  effect.wearerActIndiv.isEmpty &&
                  effect.wearerRequiredIndiv == 0,
            );
        final supportEffects = variant.supportEffects
            .where(
              (effect) =>
                  effect.scope == BondEffectScope.team &&
                  effect.wearerActIndiv.isEmpty &&
                  effect.wearerRequiredIndiv == 0,
            )
            .toList();
        if (!ownEligible && supportEffects.isEmpty) continue;
        _ceVariants.add(_CeVariant(ce, lb, ownEligible ? variant.ownEffects : const [], supportEffects));
      }
    }
  }

  void _loadFixedEffects(List<PlayerSvtData> decks) {
    final seenSvtIds = <int>{};
    for (final variant in _svtVariants) {
      if (seenSvtIds.add(variant.svt.id)) _allEffects.addAll(variant.eventEffects);
    }
    for (final deck in decks) {
      if (!deck.supportType.isSupport && deck.svt != null) {
        _allEffects.addAll(_eventEffects(deck.svt!));
      }
      final grand = quest.isUseGrandBoard && deck.grandSvt && (deck.svt != null || deck.supportType.isSupport);
      for (final equip in [deck.equip1, if (grand) deck.equip3]) {
        if (equip.ce == null) continue;
        final variant = _ceVariant(equip.ce!, equip.limitBreak);
        _allEffects.addAll(variant.ownEffects);
        _allEffects.addAll(variant.supportEffects);
      }
    }
    for (final variant in _ceVariants) {
      _allEffects.addAll(variant.ownEffects);
      _allEffects.addAll(variant.supportEffects);
    }
    final unique = <String, CeBondEffect>{};
    for (final effect in _allEffects) {
      final key =
          '${effect.wearerActIndiv.join(',')}|${effect.wearerRequiredIndiv}'
          '|${effect.targetOrAll.map((e) => e.join(',')).join(';')}|${effect.targetPartial.join(',')}';
      unique.putIfAbsent(key, () => effect);
    }
    _allEffects
      ..clear()
      ..addAll(unique.values);
  }

  void _buildProfiles(List<PlayerSvtData> decks) {
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
      enroll(variant.traits);
    }
    for (final deck in decks) {
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

  void _buildSvtClasses() {
    final byKey = <String, _SvtClass>{};
    for (final variant in _svtVariants) {
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
      cls.searchIndex = i;
    }
  }

  void _buildCeClasses() {
    final owned = <String, _CeClass>{};
    final support = <String, _CeClass>{};
    for (final variant in _ceVariants) {
      final ownEffects = [for (final traits in _profiles) _contribution(variant.ownEffects, traits)];
      if (ownEffects.any((e) => !e.isZero)) {
        final supportEffects = [for (final traits in _profiles) _contribution(variant.supportEffects, traits)];
        final key =
            '${variant.ce.cost}|${ownEffects.map((e) => e.signature).join(';')}'
            '|${supportEffects.map((e) => e.signature).join(';')}';
        final cls = owned.putIfAbsent(key, () => _CeClass(variant.ce.cost, ownEffects, {}));
        cls.limitBreaks[variant.ce.id] = cls.limitBreaks[variant.ce.id] == true || variant.lb;
      }
      final rawSupportEffect = _contribution(variant.supportEffects, const []);
      final supportEffect = _Contribution(0, 0, rawSupportEffect.teamRates, rawSupportEffect.teamValues);
      if (supportEffect.teamRates.any((v) => v != 0) || supportEffect.teamValues.any((v) => v != 0)) {
        final key = supportEffect.signature;
        final cls = support.putIfAbsent(key, () => _CeClass(0, [supportEffect], {}));
        cls.limitBreaks[variant.ce.id] = cls.limitBreaks[variant.ce.id] == true || variant.lb;
      }
    }
    _ownedCeClasses.addAll(owned.values);
    _supportCeClasses.addAll(support.values);
  }

  /// A CE can be removed only when enough distinct, individually dominating
  /// CE IDs remain to replace it in every possible owned slot at once.
  void _pruneOwnedCeClasses(List<PlayerSvtData> decks) {
    final maxOwnedCeSlots = decks.fold<int>(0, (count, deck) {
      if (deck.supportType.isSupport) return count;
      return count + 1 + (quest.isUseGrandBoard && deck.grandSvt && deck.svt != null ? 1 : 0);
    });
    if (pruneDominatedCes && maxOwnedCeSlots > 0) {
      var changed = true;
      while (changed) {
        changed = false;
        for (final weaker in List<_CeClass>.of(_ownedCeClasses)) {
          final replacementIds = <int>{};
          for (final stronger in _ownedCeClasses) {
            if (identical(stronger, weaker) || !_ceDominates(stronger, weaker)) continue;
            replacementIds.addAll(stronger.limitBreaks.keys);
          }
          // A team using weaker has at most maxOwnedCeSlots - 1 other IDs.
          // Hence one of these replacements is guaranteed to be unused.
          if (replacementIds.length < maxOwnedCeSlots) continue;
          _ownedCeClasses.remove(weaker);
          changed = true;
          break;
        }
      }
    }
    for (final (i, cls) in _ownedCeClasses.indexed) {
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

  List<BondSearchItem> _supportItems(PlayerSvtData deck, bool grand) {
    final fixed3 = grand && deck.equip3.ce != null
        ? _contribution(_ceVariant(deck.equip3.ce!, deck.equip3.limitBreak).supportEffects, const [])
        : _Contribution.zero(_profiles.length);
    final choices = deck.equip1.ce == null
        ? <_CeClass?>[null, ..._supportCeClasses]
        : <_CeClass?>[
            _CeClass(
              0,
              [_contribution(_ceVariant(deck.equip1.ce!, deck.equip1.limitBreak).supportEffects, const [])],
              {deck.equip1.ce!.id: deck.equip1.limitBreak},
            ),
          ];
    final items = <BondSearchItem>[];
    for (final (order, ce) in choices.indexed) {
      final effect = _add(fixed3, ce?.byWearer.first ?? _Contribution.zero(_profiles.length));
      final ceId = ce?.limitBreaks.keys.firstOrNull;
      items.add(
        BondSearchItem(
          cost: 0,
          receiverProfile: null,
          selfRate: 0,
          selfValue: 0,
          teamRates: effect.teamRates,
          teamValues: effect.teamValues,
          wornCeCount: (ceId == null ? 0 : 1) + (grand && deck.equip3.ce != null ? 1 : 0),
          symmetryOrder: order,
          payload: _ItemPayload(
            isSupport: true,
            fixedServant: false,
            servantLimits: const {},
            ce1LimitBreaks: ce?.limitBreaks ?? const {},
            ce3LimitBreaks: grand && deck.equip3.ce != null ? {deck.equip3.ce!.id: deck.equip3.limitBreak} : const {},
            supportCe1: ceId,
          ),
        ),
      );
    }
    return items;
  }

  List<BondSearchItem> _ownItems(int position, PlayerSvtData deck, bool grand) {
    final fixedSvt = deck.svt != null;
    final svts = fixedSvt ? _fixedSvtClasses(deck) : _svtClasses;
    final ce1 = deck.equip1.ce == null
        ? <_CeClass?>[null, ..._ownedCeClasses]
        : <_CeClass?>[_fixedCeClass(deck.equip1)];
    final ce3 = grand
        ? (deck.equip3.ce == null ? <_CeClass?>[null, ..._ownedCeClasses] : <_CeClass?>[_fixedCeClass(deck.equip3)])
        : <_CeClass?>[null];
    final bonus = option.svtBonus[position];
    final items = <BondSearchItem>[];
    var order = 0;
    for (final svt in svts) {
      for (final c1 in ce1) {
        for (final c3 in ce3) {
          final effect = _add(
            _add(svt.eventEffect, c1?.byWearer[svt.profile] ?? _Contribution.zero(_profiles.length)),
            c3?.byWearer[svt.profile] ?? _Contribution.zero(_profiles.length),
          );
          final teamRates = List<int>.of(effect.teamRates);
          if (fixedSvt && bonus.isBond15) {
            for (var r = 0; r < teamRates.length; r++) {
              teamRates[r] += 250;
            }
          }
          final ceIds = <Set<int>>[];
          if (c1 != null) ceIds.add(c1.limitBreaks.keys.toSet());
          if (c3 != null) ceIds.add(c3.limitBreaks.keys.toSet());
          items.add(
            BondSearchItem(
              cost: svt.cost + (c1?.cost ?? 0),
              receiverProfile: fixedSvt && bonus.isBondReachLimit ? null : svt.profile,
              selfRate: svt.campaignRate + effect.selfRate + bonus.addRate,
              selfValue: effect.selfValue + bonus.addValue,
              teamRates: teamRates,
              teamValues: effect.teamValues,
              servantIds: svt.limits.keys.toSet(),
              ownedCeIds: ceIds,
              servantClassIndex: svt.searchIndex,
              ownedCeClassIndices: [
                if (c1?.searchIndex != null) c1!.searchIndex!,
                if (c3?.searchIndex != null) c3!.searchIndex!,
              ],
              symmetryOrder: order++,
              payload: _ItemPayload(
                isSupport: false,
                fixedServant: fixedSvt,
                servantLimits: svt.limits,
                ce1LimitBreaks: c1?.limitBreaks ?? const {},
                ce3LimitBreaks: c3?.limitBreaks ?? const {},
              ),
            ),
          );
        }
      }
    }
    if (!fixedSvt && deck.equip1.ce == null) {
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
    return items;
  }

  List<int> _svtLimits(Servant svt) => (<int>{
    0,
    1,
    2,
    3,
    4,
    ...svt.costume.keys,
    ...svt.ascensionAdd.individuality2.all.keys,
    ...svt.ascensionAdd.overwriteCost.all.keys,
  }.toList()..sort());

  List<int> _fixedSvtLimits(PlayerSvtData deck) =>
      option.searchFixedAscensions ? _svtLimits(deck.svt!) : [deck.limitCount];

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
    );
  }

  BondSolvedTeam _expand(BondSearchWitness witness) {
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
          final id = chosenCes[ci++];
          ce1 = BondSolvedCe(id, payload.ce1LimitBreaks[id]!);
        }
        if (payload.ce3LimitBreaks.isNotEmpty) {
          final id = chosenCes[ci++];
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
          bond: witness.slotBonds[p],
          cost: item.cost,
          servantCandidates: payload.servantLimits.keys.toList()..sort(),
          equip1Candidates: payload.ce1LimitBreaks.keys.toList()..sort(),
          equip3Candidates: payload.ce3LimitBreaks.keys.toList()..sort(),
          servantVariants: payload.servantLimits,
          equip1Variants: payload.ce1LimitBreaks,
          equip3Variants: payload.ce3LimitBreaks,
          fixedEquip1: formation.svts[p].equip1.ce != null,
          fixedEquip3: formation.svts[p].equip3.ce != null,
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

  int _campaignRate(int svtId) {
    var rate = 0;
    for (final eventEntry in option.campaigns.entries) {
      final event = db.gameData.events[eventEntry.key];
      if (event == null) continue;
      for (final campaignEntry in eventEntry.value.entries) {
        if (!campaignEntry.value) continue;
        for (final campaign in event.campaigns) {
          if (campaign.idx != campaignEntry.key || !campaign.targetIds.contains(svtId)) continue;
          switch (campaign.calcType) {
            case EventCombineCalc.addition:
              rate += math.max(0, campaign.value);
            case EventCombineCalc.multiplication:
              rate += math.max(0, campaign.value - 1000);
            case EventCombineCalc.fixedValue:
            case EventCombineCalc.none:
              break;
          }
        }
      }
    }
    return rate;
  }

  List<CeBondEffect> _eventEffects(Servant svt) => _eventCache.putIfAbsent(svt.id, () {
    if (!option.enableEvent) return const [];
    // The solver models event servant bonuses as effects earned by that
    // servant. Team-wide extra passives (currently Mash only, besides the
    // separately configured Bond 15 skill) are outside the requested scope.
    return _extractEffects(
      svt.resolveBondEventSkills(quest),
      support: false,
    ).where((effect) => effect.scope == BondEffectScope.self).toList();
  });

  _CeVariant _ceVariant(CraftEssence ce, bool lb) {
    return _ceCache.putIfAbsent('${ce.id}|$lb', () {
      return _CeVariant(
        ce,
        lb,
        CeBondEffect.extractAll(ce, lb, quest, support: false),
        CeBondEffect.extractAll(ce, lb, quest, support: true),
      );
    });
  }

  List<CeBondEffect> _extractEffects(Iterable<NiceSkill> skills, {required bool support}) {
    final effects = <CeBondEffect>[];
    for (final skill in skills) {
      for (final func in skill.functions) {
        if (func.funcType != FuncType.servantFriendshipUp) continue;
        if (func.funcquestTvals.isNotEmpty &&
            !Individuality.checkSignedIndivPartialMatch(self: _questTraits, signedTarget: func.funcquestTvals)) {
          continue;
        }
        final vals = support ? (func.followerVals?.firstOrNull ?? func.svals.firstOrNull) : func.svals.firstOrNull;
        if (vals == null) continue;
        if (support && vals.ApplySupportSvt == 0) continue;
        if (vals.EventId != null && vals.EventId != 0 && vals.EventId != _eventId) continue;
        final rate = vals.RateCount ?? 0;
        final value = vals.AddCount ?? 0;
        if (rate == 0 && value == 0) continue;
        final scope = switch (func.funcTargetType) {
          FuncTargetType.self => BondEffectScope.self,
          FuncTargetType.ptFull => BondEffectScope.team,
          _ => null,
        };
        if (scope == null) continue; // manual page does not target other scopes
        final targetOrAll = func.getOverwriteTvalsList();
        effects.add(
          CeBondEffect(
            scope: scope,
            rate: rate,
            value: value,
            wearerActIndiv: skill.actIndividuality,
            wearerRequiredIndiv: vals.Individuality ?? 0,
            targetOrAll: targetOrAll,
            targetPartial: targetOrAll.isEmpty ? func.functvals : const [],
          ),
        );
      }
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
      if (input.ceFirst != null) {
        final clock = Stopwatch()..start();
        var lastReport = -200;
        final result = _CeFirstSearch(input.ceFirst!, maxCandidates: input.maxCandidates).solve(
          onProgress: (progress) {
            if (clock.elapsedMilliseconds - lastReport < 200) return;
            input.port.send(<Object?>['ce', progress]);
            lastReport = clock.elapsedMilliseconds;
          },
        );
        input.port.send(<Object?>['ce', result]);
      } else {
        final result = BondSearch.solve(
          input.general,
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

  static _CeFirstResult _runCeFirstSearch(_CeFirstSearchInput input) => _CeFirstSearch(
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
  _CeClass(this.cost, this.byWearer, this.limitBreaks);

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
  final Map<int, int> servantLimits;
  final Map<int, bool> ce1LimitBreaks;
  final Map<int, bool> ce3LimitBreaks;
  final int? supportCe1;

  const _ItemPayload({
    required this.isSupport,
    required this.fixedServant,
    required this.servantLimits,
    required this.ce1LimitBreaks,
    required this.ce3LimitBreaks,
    this.supportCe1,
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
  final BondSearchProblem general;
  final _CeFirstProblem? ceFirst;
  final int maxCandidates;

  const _ProgressInput(this.port, this.general, this.ceFirst, this.maxCandidates);
}
