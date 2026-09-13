import 'dart:math' as math;

import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import 'ce_pool.dart';
import 'svt_pool.dart';

const int _kMaxSvtNum = 6;

/// Hard cap on DFS node expansions. Beyond it the best-so-far solution is
/// returned with `provenOptimal = false`.
const int _kNodeCap = 1200000;

/// Tighter cap for the second phase (targeted-CE verification): the first
/// phase already solved the no-targeted subspace exactly, so this phase only
/// hunts for strictly better targeted-wearing solutions.
const int _kPhase2NodeCap = 60000;

/// Maximum number of equal-value solutions kept for tie grouping.
const int _kTieCap = 20;

/// DFS levels that run on the async (yielding) path: levels `0.._kAsyncDepth-1`.
/// The tree is deep and narrow (branching factor ~10), so the top levels hold
/// only ~10^d nodes while the exponential mass lives in the deeper levels.
/// Making only these levels async costs a few hundred async calls instead of
/// ~1.3M, which is what keeps the search fast.
const int _kAsyncDepth = 3;

/// Time handed back to the event loop at each yield point. Long enough to let
/// a frame be scheduled, short enough not to stall the search.
const Duration _kYieldPause = Duration(milliseconds: 5);

/// Temporary diagnostics flag for bound tuning.
const bool _kDebugBound = bool.fromEnvironment('BOND_SOLVER_DEBUG');

/// Thrown for invalid solver inputs (e.g. two support slots in one formation).
class BondSolverException implements Exception {
  final String message;
  const BondSolverException(this.message);

  @override
  String toString() => 'BondSolverException: $message';
}

/// One slot's outcome inside a [BondSolutionCandidate].
class BondSlotSolution {
  final int position;

  /// Chosen servant equivalence class (free own slots only).
  final BondSvtClass? svtClass;

  /// Chosen equip1 CE class (free own slots / fixed-servant free-CE slots).
  final BondCeClass? ceClass;

  /// Chosen equip3 CE class (fixed grand slots with a free equip3).
  final BondCeClass? ce3Class;

  /// Support CE candidate chosen for a free support slot.
  final SupportCeCandidate? supportCe;

  /// Pinned servant id (fixed slots).
  final int? fixedSvtId;

  /// Pinned equip1 CE id (fixed slots).
  final int? fixedCeId;

  /// Pinned equip3 CE id (fixed grand slots).
  final int? fixedCe3Id;

  final bool isSupport;

  /// Bond gained by this slot, teapot ×1. 0 for support / bond-limit / empty.
  final int slotBond;

  /// Cost paid by this slot (servant + equip1 CE; support always 0).
  final int slotCost;

  const BondSlotSolution({
    required this.position,
    this.svtClass,
    this.ceClass,
    this.ce3Class,
    this.supportCe,
    this.fixedSvtId,
    this.fixedCeId,
    this.fixedCe3Id,
    this.isSupport = false,
    required this.slotBond,
    required this.slotCost,
  });
}

/// One (possibly tied) optimal team at equivalence-class level.
class BondSolutionCandidate {
  final int totalBond;
  final int totalCost;

  /// Team-wide rate scalar T actually accumulated in this solution
  /// (per-slot capping is applied inside the bond formula).
  final int teamRate;

  /// Team-wide flat value scalar V accumulated in this solution.
  final int teamValue;

  final List<BondSlotSolution> slots;

  const BondSolutionCandidate({
    required this.totalBond,
    required this.totalCost,
    required this.teamRate,
    required this.teamValue,
    required this.slots,
  });
}

class BondSolverResult {
  /// Maximum total bond, teapot ×1. Multiply by the teapot setting for display.
  final int totalBond;
  final int totalCost;
  final int teamRate;
  final int teamValue;

  /// false when the iteration cap was hit (result may be suboptimal).
  final bool provenOptimal;
  final List<String> warnings;

  /// Tied optimal solutions (capped at [_kTieCap]).
  final List<BondSolutionCandidate> candidates;

  /// Cost already consumed by pinned servants/CEs before the search.
  final int fixedCost;

  /// Cost budget available to the search (maxCost - fixedCost).
  final int budget;

  /// DFS node expansions used (diagnostics for tuning).
  final int nodeCount;

  const BondSolverResult({
    required this.totalBond,
    required this.totalCost,
    required this.teamRate,
    required this.teamValue,
    required this.provenOptimal,
    required this.warnings,
    required this.candidates,
    required this.fixedCost,
    required this.budget,
    required this.nodeCount,
  });
}

class _NodeCapExceeded implements Exception {
  const _NodeCapExceeded();
}

// ==================================================================================
// Internal search models
// ==================================================================================

/// Slot value is deferred: the final rate depends on team-wide contributions
/// from later assignments, so only `rateExcl`/`valueExcl` are accumulated
/// during the DFS and the floor chain is applied exactly once at each leaf.
class _Deferred {
  final int position;
  final int base;
  final int front;

  /// receiver identity for targeted team effects (exactly one is non-null)
  final BondSvtClass? svtClass;
  final List<int>? fixedTraits;

  /// targeted-class receipt cache for fixed-trait receivers (ci → rate)
  final Map<int, int>? fixedTargetedRecv;

  /// optimistic sum of receipts from ALL targeted classes for this receiver
  final int targetedAll;

  int rateExcl = 0;
  int valueExcl = 0;
  int targetedWorn = 0;

  _Deferred({
    required this.position,
    required this.base,
    required this.front,
    this.svtClass,
    this.fixedTraits,
    this.fixedTargetedRecv,
    required this.targetedAll,
  });
}

/// One selectable choice for a search slot.
class _Item {
  /// free own slots: chosen servant class (null = leave slot empty)
  final BondSvtClass? svt;
  final int svtIdx; // -1 when svt == null

  /// owned CE classes worn by this slot (equip1 then equip3)
  final List<BondCeClass> ces;

  /// indices (with multiplicity) into the CE class list, for capacity checks
  final List<int> ceConsumes;

  /// support slot: chosen support CE candidate (equip1)
  final SupportCeCandidate? supportCe;

  final int cost;

  /// complete self-scope rate/value of the slot under this item
  /// (event self + campaign + custom + fixed-source receipt + CE self effects)
  final int selfRate;
  final int selfValue;

  final int flatRate;
  final int flatValue;

  /// CE class indices (owned) whose targeted effects fire with this item
  final List<int> targetedCeIdxs;

  /// optimistic sum of targeted receipts for this item's own receiver
  final int targetedAll;

  /// optimistic DP value (unfloored, optimistic rate); set during bound build
  double dpValue = 0;

  _Item({
    this.svt,
    this.svtIdx = -1,
    required this.ces,
    required this.ceConsumes,
    this.supportCe,
    required this.cost,
    required this.selfRate,
    required this.selfValue,
    required this.flatRate,
    required this.flatValue,
    required this.targetedCeIdxs,
    required this.targetedAll,
  });
}

/// A slot the DFS searches over.
class _SearchSlot {
  final int position;

  /// free own slot (servant + CE searched)
  final bool isFreeOwn;

  /// whether this slot produces a bond value (false: support / bond-reach-limit)
  final bool producesValue;

  final int base;
  final int front;

  // fixed-servant slots with free CE dimensions:
  final List<int>? fixedTraits;
  final Map<int, int>? fixedTargetedRecvMap;
  final bool isSupport;
  final int? fixedSvtId;
  final int? fixedCeId;
  final int? fixedCe3Id;
  final int fixedTargetedAll;
  final int fixedSlotCost; // servant + pinned-equip1 cost (searched CE cost extra)

  final List<_Item> items;

  /// symmetry group id among consecutive free-own slots (-1: none)
  final int group;

  /// dp[budget] bound for slots from this level on; assigned in bound build
  List<double> dp = const [];
  double dpTail = 0;

  _SearchSlot({
    required this.position,
    required this.isFreeOwn,
    required this.producesValue,
    required this.base,
    required this.front,
    this.fixedTraits,
    this.fixedTargetedRecvMap,
    this.isSupport = false,
    this.fixedSvtId,
    this.fixedCeId,
    this.fixedCe3Id,
    this.fixedTargetedAll = 0,
    this.fixedSlotCost = 0,
    required this.items,
    required this.group,
  });
}

class _TieRecord {
  final List<_Item> choices;
  final List<int> values;
  final int tCur;
  final int vCur;
  const _TieRecord(this.choices, this.values, this.tCur, this.vCur);
}

class _Int2 {
  int a = 0, b = 0;
}

class _FixedOwn {
  final int position;
  final int svtId;
  final List<int> traits;
  final int baseRate;
  final int baseValue;
  final int front;
  final bool producesValue;
  final int slotCost;
  final int? pinnedCeId;
  final int? pinnedCe3Id;
  final bool freeE1;
  final bool freeE3;

  const _FixedOwn({
    required this.position,
    required this.svtId,
    required this.traits,
    required this.baseRate,
    required this.baseValue,
    required this.front,
    required this.producesValue,
    required this.slotCost,
    this.pinnedCeId,
    this.pinnedCe3Id,
    required this.freeE1,
    required this.freeE3,
  });

  bool get needsSearch => freeE1 || freeE3;
}

// ==================================================================================
// Solver
// ==================================================================================

class FormationBondSolver {
  FormationBondSolver._({
    required this.option,
    required this.quest,
    required this.formation,
    required this.solverOptions,
    required this.region,
    required this.yieldInterval,
  });

  final FormationBondOption option;
  final QuestPhase? quest;
  final BattleTeamSetup formation;
  final BondSolverOptions solverOptions;
  final Region region;

  /// When set, the search periodically awaits so the UI isolate can render a
  /// frame. `null` (the default) runs the search fully synchronously — tests
  /// rely on that, since real pauses would add wall-clock time to every run.
  ///
  /// Only the top [_kAsyncDepth] DFS levels participate; deeper levels stay
  /// synchronous, so the cost is a few hundred async calls, not ~1.3M.
  final Duration? yieldInterval;

  /// Runs the solver. Always computes with teapot ×1 — multiply the result by
  /// the user's teapot setting for display only.
  ///
  /// Pass [yieldInterval] to keep the UI responsive during a long search; the
  /// caller must then block input (see `EasyLoadingMaskType.clear`), because
  /// yielding lets the event loop run while the solver still holds references
  /// to [formation] / [option] / the global game data.
  static Future<BondSolverResult> solve({
    required FormationBondOption option,
    QuestPhase? quest,
    required BattleTeamSetup formation,
    required BondSolverOptions solverOptions,
    Region region = Region.jp,
    Duration? yieldInterval,
  }) async {
    return FormationBondSolver._(
      option: option,
      quest: quest,
      formation: formation,
      solverOptions: solverOptions,
      region: region,
      yieldInterval: yieldInterval,
    )._run();
  }

  // ---- context ----
  late int eventId;
  late List<int> questIndivs;
  late bool hasQuest;
  late int rateCap;
  late int baseValue;
  late int maxCost;
  late int initialBudget;

  late CeBondPool cePool;
  late SvtBondPool svtPool;
  final List<(Event, EventCampaign)> enabledCampaigns = [];

  final List<String> warnings = [];

  // ---- fixed slot data ----
  final List<PlayerSvtData> decks = [];
  bool supportInFront = false;
  int supportPosition = -1;
  bool hasSupportSlot = false;
  int tConst = 0;
  int vConst = 0;
  final List<CeBondEffect> fixedSourceEffects = [];
  int fixedCost = 0;

  final List<_Deferred> deferred = [];
  final List<_FixedOwn> fixedOwnSlots = [];
  bool supportEquipSearched = false;

  /// number of fixed-slot deferred entries (search-created ones follow);
  /// used to reset [deferred] between phases after a node-cap interruption
  int _fixedDeferredCount = 0;

  // ---- class data ----
  late List<BondSvtClass> svtClasses; // after split + reduction
  late List<int> svtRem;
  late List<int> svtFixedRecvRate;
  late List<int> svtFixedRecvValue;
  late List<int> svtTargetedAll;
  late List<BondCeClass> ceClasses; // pool order
  late List<int> ceRem;
  late List<List<CeBondEffect>> ceTargeted;

  // ---- search state ----
  final List<_SearchSlot> searchSlots = [];
  int tUpper = 0;
  int maxV = 0;

  // bound helpers (precomputed in _buildBounds)
  double sumMult = 0; // Σ producing slots' base × (1 + front/1000)
  double maxMult = 0; // max producing slot's base × (1 + front/1000)
  int maxFlatItem = 0; // max flat rate a single future item can contribute
  int _maxCeFlatRate = 0;
  int _maxSvtTeamRate = 0;
  int wornRateSum = 0; // Σ rates of currently worn targeted classes
  final List<int> flatCapSuffix = []; // Σ max flat per item over slots k..n-1

  // ---- cooperative yielding (only when [yieldInterval] is set) ----
  final Stopwatch _yieldClock = Stopwatch();
  int _lastYieldMs = 0;

  int nodeCount = 0;
  int budgetLeft = 0;
  int tCur = 0;
  int vCur = 0;
  final Set<int> wornTargeted = {};
  int bestTotal = -1;
  final List<_TieRecord> ties = [];
  bool tieCapped = false;
  final List<int> _leafValues = List.filled(_kMaxSvtNum, 0);
  final List<int> _leafSetPositions = [];
  final List<_Item> _choices = [];
  final List<bool> _appliedNewlyWorn = [];
  final List<bool> _appliedCreatedDeferred = [];

  // ================================================================================

  Future<BondSolverResult> _run() async {
    eventId = quest?.logicEventId ?? 0;
    questIndivs = quest?.questIndividuality ?? const [];
    hasQuest = quest != null;
    rateCap = ConstData.constants.maxFriendShipUpRatio;
    baseValue = quest?.bond ?? 0;
    maxCost = solverOptions.maxCost ?? ConstData.maxUserCost;

    _classifySlots();
    _buildPools();
    _computeFixedConstants(); // pass 1: constants + fixed-source effects
    _createFixedDeferred(); // pass 2: deferred entries with final tConst/vConst
    _prepareClasses(); // split by fixed-source effects, per-class vectors
    _initCapacities();
    _reduceSvtClasses();

    // snapshot of the full class state (restored for the final phase)
    final fullClasses = svtClasses;
    final fullRem = svtRem;
    final fullRecvRate = svtFixedRecvRate;
    final fullRecvValue = svtFixedRecvValue;
    final fullTargetedAll = svtTargetedAll;
    final fullCeRem = ceRem;

    final hasTargetedItems = ceTargeted.any((effects) => effects.isNotEmpty);
    var provenOptimal = true;
    if (hasTargetedItems) {
      // Phase 1: exact search in the "no targeted CE worn" subspace. There the
      // servants' targeted-receipt vectors are irrelevant, so classes collapse
      // by their remaining dimensions — a dramatically smaller item space.
      _setupSearchPhase(
        classes: fullClasses,
        rem: fullRem,
        recvRate: fullRecvRate,
        recvValue: fullRecvValue,
        targetedAll: fullTargetedAll,
        ceRem0: fullCeRem,
        includeTargetedItems: false,
        dedupSvt: true,
      );
      provenOptimal = await _searchPhase(provenOptimal, nodeCap: _kNodeCap);
      // Phase 2: full space, seeded with the phase-1 incumbent so the DFS only
      // looks for strictly better (targeted-wearing) solutions.
      _setupSearchPhase(
        classes: fullClasses,
        rem: fullRem,
        recvRate: fullRecvRate,
        recvValue: fullRecvValue,
        targetedAll: fullTargetedAll,
        ceRem0: fullCeRem,
        includeTargetedItems: true,
        dedupSvt: false,
      );
      provenOptimal = await _searchPhase(provenOptimal, nodeCap: _kPhase2NodeCap);
    } else {
      _setupSearchPhase(
        classes: fullClasses,
        rem: fullRem,
        recvRate: fullRecvRate,
        recvValue: fullRecvValue,
        targetedAll: fullTargetedAll,
        ceRem0: fullCeRem,
        includeTargetedItems: true,
        dedupSvt: false,
      );
      provenOptimal = await _searchPhase(provenOptimal, nodeCap: _kNodeCap);
    }

    if (tieCapped) warnings.add('more optimal solutions exist (tie list capped at $_kTieCap)');
    if (ties.isEmpty) {
      throw const BondSolverException('no solution found');
    }
    return _assembleResult(provenOptimal);
  }

  /// (Re)builds search slots/bounds for one phase; `dedupSvt` merges servant
  /// classes whose targeted-receipt vectors differ (valid only when targeted
  /// items are excluded from the search).
  void _setupSearchPhase({
    required List<BondSvtClass> classes,
    required List<int> rem,
    required List<int> recvRate,
    required List<int> recvValue,
    required List<int> targetedAll,
    required List<int> ceRem0,
    required bool includeTargetedItems,
    required bool dedupSvt,
  }) {
    searchSlots.clear();
    flatCapSuffix.clear();
    tUpper = 0;
    maxV = 0;
    sumMult = 0;
    maxMult = 0;

    if (dedupSvt) {
      // merge by every dimension except ceTeamTargetRate
      final keys = <String, BondSvtClass>{};
      final mergedRem = <String, int>{};
      final mergedRecvRate = <String, int>{};
      final mergedRecvValue = <String, int>{};
      for (final (i, cls) in classes.indexed) {
        final key =
            '${cls.cost}|${cls.ownEventRate}|${cls.ownEventValue}|${cls.campaignRate}'
            '|${cls.flatTeamEventRate}|${cls.flatTeamEventValue}'
            '|${recvRate[i]}|${recvValue[i]}'
            '|${cls.ceSelfRate.join(',')}|${cls.ceSelfValue.join(',')}';
        final existing = keys[key];
        if (existing == null) {
          keys[key] = _copySvtClass(cls, List.of(cls.members), ceTeamTargetRate: List<int>.filled(ceClasses.length, 0));
          mergedRem[key] = rem[i];
          mergedRecvRate[key] = recvRate[i];
          mergedRecvValue[key] = recvValue[i];
        } else {
          existing.members.addAll(cls.members);
          mergedRem[key] = mergedRem[key]! + rem[i];
        }
      }
      svtClasses = [for (final c in keys.values) c];
      svtRem = [for (final k in keys.keys) mergedRem[k]!];
      svtFixedRecvRate = [for (final k in keys.keys) mergedRecvRate[k]!];
      svtFixedRecvValue = [for (final k in keys.keys) mergedRecvValue[k]!];
      svtTargetedAll = List<int>.filled(svtClasses.length, 0);
    } else {
      svtClasses = classes;
      svtRem = rem;
      svtFixedRecvRate = recvRate;
      svtFixedRecvValue = recvValue;
      svtTargetedAll = targetedAll;
    }
    ceRem = List<int>.of(ceRem0);
    _includeTargetedItems = includeTargetedItems;
    _buildSearchSlots();
    _buildBounds();
  }

  bool _includeTargetedItems = true;
  int _phaseNodeCap = _kNodeCap;
  int _phaseNodeStart = 0;

  /// Runs one DFS phase; resets the mutable search state beforehand.
  /// [nodeCap] limits this phase's expansions.
  Future<bool> _searchPhase(bool provenOptimal, {required int nodeCap}) async {
    budgetLeft = initialBudget;
    tCur = 0;
    vCur = 0;
    wornTargeted.clear();
    wornRateSum = 0;
    // A node-cap hit unwinds _dfs through the exception, skipping every _undo,
    // so deferred entries created along the interrupted path survive into the
    // next phase — truncate back to the fixed-slot baseline (see solver2's
    // identical fix for the full diagnosis).
    deferred.removeRange(_fixedDeferredCount, deferred.length);
    _phaseNodeCap = nodeCap;
    _phaseNodeStart = nodeCount;
    if (yieldInterval != null) {
      _yieldClock
        ..reset()
        ..start();
      _lastYieldMs = 0;
    }
    try {
      if (yieldInterval == null) {
        _dfs(0, 0);
      } else {
        await _dfsAsync(0, 0);
      }
    } on _NodeCapExceeded {
      if (provenOptimal) {
        warnings.add(
          'iteration cap reached ($nodeCap nodes in this phase); '
          'result may be suboptimal (a targeted-CE combination could beat it)',
        );
      }
      return false;
    }
    return provenOptimal;
  }

  // ================================================================================
  // Slot classification & pools
  // ================================================================================

  void _classifySlots() {
    decks.addAll(formation.svts.take(_kMaxSvtNum));
    while (decks.length < _kMaxSvtNum) {
      decks.add(PlayerSvtData.base());
    }
    final supportIdx = decks.indexWhere((d) => d.supportType.isSupport);
    if (supportIdx >= 0) {
      if (decks.where((d) => d.supportType.isSupport).length > 1) {
        throw const BondSolverException('at most one support slot is allowed in the formation');
      }
      hasSupportSlot = true;
      supportPosition = supportIdx;
      supportInFront = supportIdx < 3;
    }
  }

  void _buildPools() {
    cePool = CeBondPool.build(
      quest: quest,
      eventId: eventId,
      region: region,
      excludedCes: solverOptions.excludedCes,
      excludeUnreleased: solverOptions.excludeUnreleased,
    );

    for (final (evId, eventCampaigns) in option.campaigns.items) {
      final event = db.gameData.events[evId];
      if (event == null) continue;
      for (final (idx, enabled) in eventCampaigns.items) {
        if (!enabled) continue;
        EventCampaign? campaign;
        for (final c in event.campaigns) {
          if (c.idx == idx) {
            campaign = c;
            break;
          }
        }
        if (campaign != null) enabledCampaigns.add((event, campaign));
      }
    }

    svtPool = SvtBondPool.build(
      quest: quest,
      cePool: cePool,
      region: region,
      favoriteOnly: solverOptions.favoriteOnly,
      excludeUnreleased: solverOptions.excludeUnreleased,
      maxBond: solverOptions.maxBond,
      excludedSvts: solverOptions.excludedSvts,
      enabledCampaigns: enabledCampaigns,
      enableEvent: option.enableEvent,
    );
    warnings.addAll(svtPool.warnings);

    final hasFreeOwn = decks.any((d) => d.svt == null && !d.supportType.isSupport);
    if (hasFreeOwn && svtPool.classes.isEmpty) {
      warnings.add('no servant candidates (check favorite/bond/release filters)');
    }

    ceClasses = cePool.ownedClasses;
    ceTargeted = [
      for (final c in ceClasses)
        c.effects
            .where(
              (e) =>
                  e.scope == BondEffectScope.team &&
                  e.hasTargetCondition &&
                  e.wearerActIndiv.isEmpty &&
                  e.wearerRequiredIndiv == 0,
            )
            .toList(),
    ];

    // rare-effect warnings
    var warnedTargetedValue = false;
    for (final c in ceClasses) {
      for (final e in c.effects) {
        if (e.scope == BondEffectScope.team &&
            e.hasTargetCondition &&
            e.wearerActIndiv.isEmpty &&
            e.wearerRequiredIndiv == 0 &&
            e.value > 0) {
          if (!warnedTargetedValue) {
            warnedTargetedValue = true;
            warnings.add('targeted team bond VALUE from free-worn CEs is ignored (rare)');
          }
          break;
        }
      }
    }
    if (cePool.supportCandidates.any((c) => c.targetedEffects.isNotEmpty)) {
      warnings.add('targeted effects of support CE candidates are ignored (rare)');
    }
  }

  // ================================================================================
  // Fixed constants (pass 1)
  // ================================================================================

  /// Self-scope effects of one effect list against fixed traits.
  void _accumulateSelf(List<CeBondEffect> effects, List<int> traits, _Int2 acc) {
    for (final e in effects) {
      if (e.scope != BondEffectScope.self) continue;
      if (e.wearerMatches(traits) && e.targetMatches(traits)) {
        acc.a += e.rate;
        acc.b += e.value;
      }
    }
  }

  /// Team-scope effects of one effect list with a KNOWN wearer (pinned CE /
  /// fixed servant event passive): flat → team scalars, targeted → fixed-source.
  void _accumulateTeamFromKnownWearer(List<CeBondEffect> effects, List<int> wearerTraits) {
    for (final e in effects) {
      if (e.scope != BondEffectScope.team) continue;
      if (!e.wearerMatches(wearerTraits)) continue;
      if (e.hasTargetCondition) {
        fixedSourceEffects.add(e);
      } else {
        tConst += e.rate;
        vConst += e.value;
      }
    }
  }

  void _computeFixedConstants() {
    bool warnedMash = false;
    bool warnedSupportEquip3 = false;
    for (final (position, deck) in decks.indexed) {
      final svt = deck.svt;
      final isSupport = deck.supportType.isSupport;
      final front =
          (option.frontlineBonus && position < 3 ? 200 : 0) + (option.frontlineBonus && supportInFront ? 40 : 0);
      final isGrand = quest?.isUseGrandBoard == true && deck.grandSvt;

      if (isSupport) {
        // Support slot: produces no bond value and costs nothing. Only its
        // team-scope effects (event passives + pinned CEs) matter.
        final traits = svt == null ? const <int>[] : List<int>.of(svt.getIndividuality(eventId, deck.limitCount));
        final eventSkills = (option.enableEvent && quest != null && svt != null)
            ? SvtBondPool.resolveEventSkills(svt, quest!)
            : const <NiceSkill>[];
        final eventEffects = CeBondPool.extractBondEffects(
          eventSkills,
          eventId: eventId,
          questIndivs: questIndivs,
          hasQuest: hasQuest,
          supportWearerTraits: traits,
        );
        for (final e in eventEffects) {
          if (e.scope != BondEffectScope.team) continue;
          if (e.hasTargetCondition) {
            fixedSourceEffects.add(e);
          } else {
            tConst += e.rate;
            vConst += e.value;
          }
        }
        for (final equip in [deck.equip1, if (isGrand) deck.equip3]) {
          final ce = equip.ce;
          if (ce == null) continue;
          final effects = CeBondPool.extractBondEffects(
            ce.getActivatedSkills(equip.limitBreak).values.expand((e) => e),
            eventId: eventId,
            questIndivs: questIndivs,
            hasQuest: hasQuest,
            supportWearerTraits: traits,
          );
          for (final e in effects) {
            if (e.scope != BondEffectScope.team) continue;
            if (e.hasTargetCondition) {
              fixedSourceEffects.add(e);
            } else {
              tConst += e.rate;
              vConst += e.value;
            }
          }
        }
        if (isGrand && deck.equip3.ce == null && !warnedSupportEquip3) {
          warnedSupportEquip3 = true;
          warnings.add('solving a free equip3 on the support slot is not supported');
        }
        continue;
      }

      if (svt == null) continue; // free own slot — handled by the search

      // ---- fixed own servant ----
      final traits = List<int>.of(svt.getIndividuality(eventId, deck.limitCount));
      final bonus = _svtBonus(position);
      final producesValue = !bonus.isBondReachLimit;
      final acc = _Int2();

      // custom per-slot bonus (applies whenever the slot holds a servant)
      acc.a += bonus.addRate;
      acc.b += bonus.addValue;

      // event passives: self-scope → constants; team-scope → team scalars/sources
      if (option.enableEvent && quest != null) {
        final resolved = SvtBondPool.resolveEventSkills(svt, quest!);
        final effects = CeBondPool.extractBondEffects(
          resolved,
          eventId: eventId,
          questIndivs: questIndivs,
          hasQuest: hasQuest,
        );
        for (final e in effects) {
          if (e.scope == BondEffectScope.self) {
            if (e.wearerMatches(traits) && e.targetMatches(traits)) {
              acc.a += e.rate;
              acc.b += e.value;
            }
          } else if (e.scope == BondEffectScope.team) {
            if (svt.collectionNo == 1) {
              // Mash main-story team bond passives are ignored by the solver
              if (!warnedMash) {
                warnedMash = true;
                warnings.add('Mash main-story team bond passives are ignored');
              }
              continue;
            }
            if (e.hasTargetCondition) {
              fixedSourceEffects.add(e);
            } else {
              tConst += e.rate;
              vConst += e.value;
            }
          }
        }
      }

      // campaign bonus
      for (final (_, campaign) in enabledCampaigns) {
        if (!campaign.targetIds.contains(svt.id)) continue;
        switch (campaign.calcType) {
          case EventCombineCalc.addition:
            acc.a += math.max(0, campaign.value);
          case EventCombineCalc.multiplication:
            acc.a += math.max(0, campaign.value - 1000);
          case EventCombineCalc.fixedValue:
          case EventCombineCalc.none:
            break;
        }
      }

      // pinned CEs: self effects → constants; team effects → team scalars/sources
      for (final equip in [deck.equip1, if (isGrand) deck.equip3]) {
        final ce = equip.ce;
        if (ce == null) continue;
        final effects = CeBondPool.extractBondEffects(
          ce.getActivatedSkills(equip.limitBreak).values.expand((e) => e),
          eventId: eventId,
          questIndivs: questIndivs,
          hasQuest: hasQuest,
        );
        _accumulateSelf(effects, traits, acc);
        _accumulateTeamFromKnownWearer(effects, traits);
      }

      if (bonus.isBond15) tConst += 250;

      final svtCost = svt.getAscended(deck.limitCount, (a) => a.overwriteCost) ?? svt.cost;
      final ceCost = deck.equip1.ce?.cost ?? 0;
      fixedCost += svtCost + ceCost;

      fixedOwnSlots.add(
        _FixedOwn(
          position: position,
          svtId: svt.id,
          traits: traits,
          baseRate: acc.a,
          baseValue: acc.b,
          front: front,
          producesValue: producesValue,
          slotCost: svtCost + ceCost,
          pinnedCeId: deck.equip1.ce?.id,
          pinnedCe3Id: isGrand ? deck.equip3.ce?.id : null,
          freeE1: deck.equip1.ce == null,
          freeE3: isGrand && deck.equip3.ce == null,
        ),
      );
    }
    initialBudget = maxCost - fixedCost;
  }

  /// Targeted-class receipt cache for a fixed-trait receiver (ci → rate).
  Map<int, int>? _buildFixedRecvMap(List<int> traits) {
    Map<int, int>? map;
    for (final (ci, effects) in ceTargeted.indexed) {
      if (effects.isEmpty) continue;
      var r = 0;
      for (final e in effects) {
        if (e.targetMatches(traits)) r += e.rate;
      }
      if (r != 0) (map ??= {})[ci] = r;
    }
    return map;
  }

  void _createFixedDeferred() {
    for (final fs in fixedOwnSlots) {
      if (!fs.producesValue) continue;
      var recvRate = 0, recvValue = 0;
      for (final e in fixedSourceEffects) {
        if (e.targetMatches(fs.traits)) {
          recvRate += e.rate;
          recvValue += e.value;
        }
      }
      final recvMap = _buildFixedRecvMap(fs.traits);
      var targetedAll = 0;
      recvMap?.forEach((_, r) => targetedAll += r);
      deferred.add(
        _Deferred(
            position: fs.position,
            base: baseValue,
            front: fs.front,
            fixedTraits: fs.traits,
            fixedTargetedRecv: recvMap,
            targetedAll: targetedAll,
          )
          ..rateExcl = tConst + fs.baseRate + recvRate
          ..valueExcl = vConst + fs.baseValue + recvValue,
      );
    }
    _fixedDeferredCount = deferred.length;
  }

  // ================================================================================
  // Class preparation
  // ================================================================================

  void _prepareClasses() {
    // Split classes whose members disagree on any fixed-source targeted effect,
    // so "receives effect" is unambiguous per class.
    var classes = List<BondSvtClass>.of(svtPool.classes);
    for (final effect in fixedSourceEffects) {
      if (effect.rate <= 0 && effect.value <= 0) continue;
      final next = <BondSvtClass>[];
      for (final cls in classes) {
        final matched = cls.members.where((m) => effect.targetMatches(m.traits)).toList();
        if (matched.isEmpty || matched.length == cls.members.length) {
          next.add(cls);
          continue;
        }
        final unmatched = cls.members.where((m) => !matched.contains(m)).toList();
        next.add(_copySvtClass(cls, matched));
        next.add(_copySvtClass(cls, unmatched));
      }
      classes = next;
    }
    svtClasses = classes;

    svtFixedRecvRate = List<int>.filled(classes.length, 0);
    svtFixedRecvValue = List<int>.filled(classes.length, 0);
    svtTargetedAll = List<int>.filled(classes.length, 0);
    for (final (i, cls) in classes.indexed) {
      // after splitting every member agrees on each fixed-source effect
      final m = cls.members.first;
      for (final e in fixedSourceEffects) {
        if (e.targetMatches(m.traits)) {
          svtFixedRecvRate[i] += e.rate;
          svtFixedRecvValue[i] += e.value;
        }
      }
      for (final effects in ceTargeted) {
        for (final e in effects) {
          if (e.targetMatches(m.traits)) svtTargetedAll[i] += e.rate;
        }
      }
    }
  }

  static BondSvtClass _copySvtClass(BondSvtClass cls, List<BondSvtMember> members, {List<int>? ceTeamTargetRate}) {
    return BondSvtClass(
      cost: cls.cost,
      ownEventRate: cls.ownEventRate,
      ownEventValue: cls.ownEventValue,
      campaignRate: cls.campaignRate,
      flatTeamEventRate: cls.flatTeamEventRate,
      flatTeamEventValue: cls.flatTeamEventValue,
      ceSelfRate: cls.ceSelfRate,
      ceSelfValue: cls.ceSelfValue,
      ceTeamActive: cls.ceTeamActive,
      ceTeamTargetRate: ceTeamTargetRate ?? cls.ceTeamTargetRate,
      members: members,
    );
  }

  void _initCapacities() {
    ceRem = [for (final c in ceClasses) c.capacity];
    svtRem = [for (final s in svtClasses) s.capacity];

    // pinned CE ids consume owned-class capacity (support slots never do —
    // the follower's CE never conflicts with owned copies)
    final ceIdToClass = <int, int>{};
    for (final (ci, c) in ceClasses.indexed) {
      for (final id in c.memberIds) {
        ceIdToClass[id] = ci;
      }
    }
    for (final fs in fixedOwnSlots) {
      for (final id in [fs.pinnedCeId, fs.pinnedCe3Id]) {
        if (id == null) continue;
        final ci = ceIdToClass[id];
        if (ci != null) ceRem[ci]--;
      }
    }

    // pinned own servants consume servant-class capacity (a servant, in any
    // ascension slice, appears at most once per team)
    for (final fs in fixedOwnSlots) {
      for (final (si, cls) in svtClasses.indexed) {
        for (final m in cls.members) {
          if (m.svt.id == fs.svtId) {
            svtRem[si]--;
            break;
          }
        }
      }
    }
  }

  // ================================================================================
  // Reductions
  // ================================================================================

  /// Drops servant classes dominated by another class whose remaining capacity
  /// can absorb any usage (≤ 6 slots). Mixed-team usage could otherwise exhaust
  /// a smaller-capacity dominator, so the guard is required for exactness.
  void _reduceSvtClasses() {
    final n = svtClasses.length;
    if (n <= 1) return;
    final keep = List<bool>.filled(n, true);
    for (int b = 0; b < n; b++) {
      for (int a = 0; a < n; a++) {
        if (a == b || !keep[a] || svtRem[a] < _kMaxSvtNum) continue;
        if (_svtDominates(a, b)) {
          keep[b] = false;
          break;
        }
      }
    }
    if (keep.every((k) => k)) return;
    final keptClasses = <BondSvtClass>[],
        keptRem = <int>[],
        keptRecvRate = <int>[],
        keptRecvValue = <int>[],
        keptTargetedAll = <int>[];
    for (final (i, k) in keep.indexed) {
      if (!k) continue;
      keptClasses.add(svtClasses[i]);
      keptRem.add(svtRem[i]);
      keptRecvRate.add(svtFixedRecvRate[i]);
      keptRecvValue.add(svtFixedRecvValue[i]);
      keptTargetedAll.add(svtTargetedAll[i]);
    }
    svtClasses = keptClasses;
    svtRem = keptRem;
    svtFixedRecvRate = keptRecvRate;
    svtFixedRecvValue = keptRecvValue;
    svtTargetedAll = keptTargetedAll;
  }

  bool _svtDominates(int a, int b) {
    final ca = svtClasses[a], cb = svtClasses[b];
    if (ca.cost > cb.cost ||
        ca.ownEventRate < cb.ownEventRate ||
        ca.ownEventValue < cb.ownEventValue ||
        ca.campaignRate < cb.campaignRate ||
        ca.flatTeamEventRate < cb.flatTeamEventRate ||
        ca.flatTeamEventValue < cb.flatTeamEventValue ||
        svtFixedRecvRate[a] < svtFixedRecvRate[b] ||
        svtFixedRecvValue[a] < svtFixedRecvValue[b] ||
        svtTargetedAll[a] < svtTargetedAll[b]) {
      return false;
    }
    for (final i in range(ceClasses.length)) {
      if (ca.ceSelfRate[i] < cb.ceSelfRate[i] ||
          ca.ceSelfValue[i] < cb.ceSelfValue[i] ||
          ca.ceTeamTargetRate[i] < cb.ceTeamTargetRate[i]) {
        return false;
      }
    }
    return true;
  }

  // ================================================================================
  // Search slots & items
  // ================================================================================

  FormationBondSvtBonus _svtBonus(int position) {
    final list = option.svtBonus;
    if (position < list.length) return list[position];
    return FormationBondSvtBonus();
  }

  void _buildSearchSlots() {
    int groupSeq = 0;
    int lastGroup = -1;
    ({int front, int rate, int value})? lastProfile;
    final receivers = _receiversForDominance();

    for (final (position, deck) in decks.indexed) {
      if (deck.supportType.isSupport) {
        _buildSupportSlot(position, deck);
        lastProfile = null;
        continue;
      }
      final fs = _fixedOwnAt(position);
      if (fs != null) {
        _buildFixedCeSlot(fs, receivers);
        lastProfile = null;
        continue;
      }

      // ---- free own slot ----
      final bonus = _svtBonus(position);
      final front =
          (option.frontlineBonus && position < 3 ? 200 : 0) + (option.frontlineBonus && supportInFront ? 40 : 0);
      final profile = (front: front, rate: bonus.addRate, value: bonus.addValue);
      final grouped = lastProfile != null && _sameProfile(lastProfile, profile);
      final group = grouped ? lastGroup : groupSeq++;
      lastGroup = group;
      lastProfile = profile;

      final items = <_Item>[];
      for (final (si, s) in svtClasses.indexed) {
        if (svtRem[si] <= 0) continue;
        final baseSelfRate = s.ownEventRate + s.campaignRate + bonus.addRate + svtFixedRecvRate[si];
        final baseSelfValue = s.ownEventValue + bonus.addValue + svtFixedRecvValue[si];
        // no CE
        items.add(
          _Item(
            svt: s,
            svtIdx: si,
            ces: const [],
            ceConsumes: const [],
            cost: s.cost,
            selfRate: baseSelfRate,
            selfValue: baseSelfValue,
            flatRate: s.flatTeamEventRate,
            flatValue: s.flatTeamEventValue,
            targetedCeIdxs: const [],
            targetedAll: svtTargetedAll[si],
          ),
        );
        for (final (ci, c) in ceClasses.indexed) {
          if (ceRem[ci] <= 0) continue;
          if (!_includeTargetedItems && ceTargeted[ci].isNotEmpty) continue;
          items.add(
            _Item(
              svt: s,
              svtIdx: si,
              ces: [c],
              ceConsumes: [ci],
              cost: s.cost + c.cost,
              selfRate: baseSelfRate + s.ceSelfRate[ci],
              selfValue: baseSelfValue + s.ceSelfValue[ci],
              flatRate: s.flatTeamEventRate + c.flatTeamRate,
              flatValue: s.flatTeamEventValue + c.flatTeamValue,
              targetedCeIdxs: ceTargeted[ci].isEmpty ? const [] : [ci],
              targetedAll: svtTargetedAll[si],
            ),
          );
        }
      }
      // leave the slot empty
      items.add(_emptyItem());
      final reduced = _reduceItemsPerSvt(items, receivers);
      searchSlots.add(
        _SearchSlot(
          position: position,
          isFreeOwn: true,
          producesValue: true,
          base: baseValue,
          front: front,
          items: reduced,
          group: group,
        ),
      );
    }
  }

  _FixedOwn? _fixedOwnAt(int position) {
    for (final fs in fixedOwnSlots) {
      if (fs.position == position) return fs;
    }
    return null;
  }

  bool _sameProfile(({int front, int rate, int value}) a, ({int front, int rate, int value}) b) =>
      a.front == b.front && a.rate == b.rate && a.value == b.value;

  _Item _emptyItem() => _Item(
    ces: const [],
    ceConsumes: const [],
    cost: 0,
    selfRate: 0,
    selfValue: 0,
    flatRate: 0,
    flatValue: 0,
    targetedCeIdxs: const [],
    targetedAll: 0,
  );

  /// Support slot with a free equip1: items are support CE candidates
  /// (cost 0, no capacity conflicts, may duplicate owned CEs).
  void _buildSupportSlot(int position, PlayerSvtData deck) {
    if (deck.equip1.ce != null) return; // pinned support CE — constant
    supportEquipSearched = true;
    final isGrand = quest?.isUseGrandBoard == true && deck.grandSvt;
    if (isGrand && deck.equip3.ce == null) {
      warnings.add('solving a free equip3 on the support slot is not supported');
    }
    final items = <_Item>[];
    for (final candidate in cePool.supportCandidates) {
      if (candidate.flatTeamRate <= 0 && candidate.flatTeamValue <= 0) continue;
      items.add(
        _Item(
          ces: const [],
          ceConsumes: const [],
          supportCe: candidate,
          cost: 0,
          selfRate: 0,
          selfValue: 0,
          flatRate: candidate.flatTeamRate,
          flatValue: candidate.flatTeamValue,
          targetedCeIdxs: const [],
          targetedAll: 0,
        ),
      );
    }
    items.add(_emptyItem());
    final reduced = items
        .where(
          (item) => !items.any(
            (o) =>
                !identical(o, item) &&
                o.flatRate >= item.flatRate &&
                o.flatValue >= item.flatValue &&
                (o.flatRate > item.flatRate || o.flatValue > item.flatValue),
          ),
        )
        .toList();
    searchSlots.add(
      _SearchSlot(
        position: position,
        isFreeOwn: false,
        producesValue: false,
        base: 0,
        front: 0,
        isSupport: true,
        fixedSvtId: deck.svt?.id,
        fixedCe3Id: isGrand ? deck.equip3.ce?.id : null,
        items: reduced,
        group: -1,
      ),
    );
  }

  /// Fixed own servant with at least one free CE dimension (equip1 / grand equip3).
  /// Both dimensions are enumerated exactly (≤ 18×18 combinations).
  void _buildFixedCeSlot(_FixedOwn fs, List<Object> receivers) {
    if (!fs.needsSearch) return;
    final e1Options = fs.freeE1 ? _fixedCeOptions(fs, equip1: true) : [_ceNoneOption()];
    final e3Options = fs.freeE3 ? _fixedCeOptions(fs, equip1: false) : [_ceNoneOption()];
    final recvMap = _buildFixedRecvMap(fs.traits);
    var targetedAll = 0;
    recvMap?.forEach((_, r) => targetedAll += r);

    final items = <_Item>[];
    for (final e1 in e1Options) {
      for (final e3 in e3Options) {
        final ces = [...e1.ces, ...e3.ces];
        if (ces.isEmpty) continue; // "no CE in both dims" = constant, skip item
        final consumes = [...e1.consumes, ...e3.consumes];
        final targeted = [...e1.targeted, ...e3.targeted];
        items.add(
          _Item(
            ces: ces,
            ceConsumes: consumes,
            cost: e1.cost,
            selfRate: fs.baseRate + e1.selfRate + e3.selfRate,
            selfValue: fs.baseValue + e1.selfValue + e3.selfValue,
            flatRate: e1.flatRate + e3.flatRate,
            flatValue: e1.flatValue + e3.flatValue,
            targetedCeIdxs: targeted,
            targetedAll: targetedAll,
          ),
        );
      }
    }
    // "no CE at all" item (servant only)
    items.add(
      _Item(
        ces: const [],
        ceConsumes: const [],
        cost: 0,
        selfRate: fs.baseRate,
        selfValue: fs.baseValue,
        flatRate: 0,
        flatValue: 0,
        targetedCeIdxs: const [],
        targetedAll: targetedAll,
      ),
    );
    final reduced = _dominanceFilter(items, receivers);
    searchSlots.add(
      _SearchSlot(
        position: fs.position,
        isFreeOwn: false,
        producesValue: fs.producesValue,
        base: baseValue,
        front: fs.front,
        fixedTraits: fs.traits,
        fixedTargetedRecvMap: recvMap,
        fixedSvtId: fs.svtId,
        fixedCeId: fs.pinnedCeId,
        fixedCe3Id: fs.pinnedCe3Id,
        fixedTargetedAll: targetedAll,
        fixedSlotCost: fs.slotCost,
        items: reduced,
        group: -1,
      ),
    );
  }

  List<
    ({
      List<BondCeClass> ces,
      List<int> consumes,
      int cost,
      int selfRate,
      int selfValue,
      int flatRate,
      int flatValue,
      List<int> targeted,
    })
  >
  _fixedCeOptions(_FixedOwn fs, {required bool equip1}) {
    final options =
        <
          ({
            List<BondCeClass> ces,
            List<int> consumes,
            int cost,
            int selfRate,
            int selfValue,
            int flatRate,
            int flatValue,
            List<int> targeted,
          })
        >[];
    for (final (ci, c) in ceClasses.indexed) {
      if (ceRem[ci] <= 0) continue;
      if (!_includeTargetedItems && ceTargeted[ci].isNotEmpty) continue;
      final self = _ceSelfEffects(c, fs.traits);
      options.add((
        ces: [c],
        consumes: [ci],
        cost: equip1 ? c.cost : 0,
        selfRate: self.a,
        selfValue: self.b,
        flatRate: c.flatTeamRate,
        flatValue: c.flatTeamValue,
        targeted: ceTargeted[ci].isEmpty ? const <int>[] : [ci],
      ));
    }
    options.add(_ceNoneOption());
    return options;
  }

  ({
    List<BondCeClass> ces,
    List<int> consumes,
    int cost,
    int selfRate,
    int selfValue,
    int flatRate,
    int flatValue,
    List<int> targeted,
  })
  _ceNoneOption() => (
    ces: const [],
    consumes: const [],
    cost: 0,
    selfRate: 0,
    selfValue: 0,
    flatRate: 0,
    flatValue: 0,
    targeted: const [],
  );

  _Int2 _ceSelfEffects(BondCeClass c, List<int> traits) {
    final acc = _Int2();
    _accumulateSelf(c.effects, traits, acc);
    return acc;
  }

  /// Receiver list for targeted-effect dominance comparison:
  /// reduced servant classes + fixed producing slots' traits.
  List<Object> _receiversForDominance() {
    return [
      ...svtClasses,
      for (final fs in fixedOwnSlots)
        if (fs.producesValue) fs.traits,
    ];
  }

  /// Per-s CE dominance for free own slots: drop (s, c1) when another CE choice
  /// (or none) is at least as good in every dimension and capacity-safe.
  List<_Item> _reduceItemsPerSvt(List<_Item> items, List<Object> receivers) {
    final bySvt = <int, List<_Item>>{};
    for (final item in items) {
      bySvt.putIfAbsent(item.svtIdx, () => []).add(item);
    }
    final result = <_Item>[];
    for (final list in bySvt.values) {
      result.addAll(_dominanceFilter(list, receivers));
    }
    return result;
  }

  List<_Item> _dominanceFilter(List<_Item> items, List<Object> receivers) {
    final kept = <_Item>[];
    for (final item in items) {
      var dominated = false;
      for (final other in items) {
        if (identical(other, item)) continue;
        if (!_capacitySafe(other, item)) continue;
        if (other.cost <= item.cost &&
            other.selfRate >= item.selfRate &&
            other.selfValue >= item.selfValue &&
            other.flatRate >= item.flatRate &&
            other.flatValue >= item.flatValue &&
            _targetedVecGe(other, item, receivers)) {
          dominated = true;
          break;
        }
      }
      if (!dominated) kept.add(item);
    }
    return kept;
  }

  bool _capacitySafe(_Item dominator, _Item item) {
    if (item.ceConsumes.isEmpty) return true;
    final needed = _multiplicity(item.ceConsumes);
    final provided = _multiplicity(dominator.ceConsumes);
    for (final (ci, count) in needed.items) {
      final p = provided[ci] ?? 0;
      if (p >= count) continue;
      // extra copies must be coverable by remaining capacity: rem ≥ 6 means
      // the class can supply any usage a 6-slot team can demand
      if (ceRem[ci] < _kMaxSvtNum) return false;
    }
    return true;
  }

  /// Whether dominator's targeted receipts cover the item's for every receiver.
  bool _targetedVecGe(_Item dominator, _Item item, List<Object> receivers) {
    if (item.targetedCeIdxs.isEmpty) return true;
    if (dominator.targetedCeIdxs.isEmpty) return false;
    for (final r in receivers) {
      if (_itemReceipt(dominator, r) < _itemReceipt(item, r)) return false;
    }
    return true;
  }

  int _itemReceipt(_Item item, Object receiver) {
    var total = 0;
    for (final ci in item.targetedCeIdxs) {
      total += _recvTargetedRate(ci, receiver);
    }
    return total;
  }

  Map<int, int> _multiplicity(List<int> idxs) {
    final map = <int, int>{};
    for (final ci in idxs) {
      map[ci] = (map[ci] ?? 0) + 1;
    }
    return map;
  }

  /// Targeted-only rate one CE class grants to a receiver (class or fixed traits).
  int _recvTargetedRate(int ci, Object receiver) {
    if (receiver is BondSvtClass) {
      return receiver.ceTeamTargetRate[ci] - ceClasses[ci].flatTeamRate;
    } else if (receiver is List<int>) {
      var total = 0;
      for (final e in ceTargeted[ci]) {
        if (e.targetMatches(receiver)) total += e.rate;
      }
      return total;
    }
    return 0;
  }

  // ================================================================================
  // Bounds
  // ================================================================================

  void _buildBounds() {
    final n = searchSlots.length;

    // slot multipliers for rate→value conversion bounds
    for (final (position, deck) in decks.indexed) {
      if (deck.supportType.isSupport) continue;
      final isFixed = deck.svt != null;
      final bonus = _svtBonus(position);
      if (isFixed && bonus.isBondReachLimit) continue;
      final front =
          (option.frontlineBonus && position < 3 ? 200 : 0) + (option.frontlineBonus && supportInFront ? 40 : 0);
      final mult = baseValue * (1 + front / 1000);
      sumMult += mult;
      maxMult = math.max(maxMult, mult);
    }

    // T upper bound: greedy best per-copy flat rates (CE classes + support
    // candidates when actually searched) + svt team rates
    final copyRates = <int>[];
    for (final (ci, c) in ceClasses.indexed) {
      if (c.flatTeamRate > 0) {
        for (final _ in range(math.min(ceRem[ci], n))) {
          copyRates.add(c.flatTeamRate);
        }
      }
    }
    if (supportEquipSearched) {
      for (final cand in cePool.supportCandidates) {
        if (cand.flatTeamRate > 0) copyRates.add(cand.flatTeamRate);
      }
    }
    copyRates.sort((a, b) => b.compareTo(a));
    int greedyCe = 0;
    for (final i in range(math.min(copyRates.length, n))) {
      greedyCe += copyRates[i];
    }
    int maxSvtTeam = 0;
    for (final s in svtClasses) {
      maxSvtTeam = math.max(maxSvtTeam, s.flatTeamEventRate);
    }
    _maxSvtTeamRate = maxSvtTeam;
    tUpper = tConst + greedyCe + n * maxSvtTeam;

    // max flat rate one future item can contribute (equip1 + equip3 + svt team)
    int maxCeFlat = 0, maxSupportFlat = 0;
    for (final c in ceClasses) {
      maxCeFlat = math.max(maxCeFlat, c.flatTeamRate);
    }
    _maxCeFlatRate = maxCeFlat;
    if (supportEquipSearched) {
      for (final cand in cePool.supportCandidates) {
        maxSupportFlat = math.max(maxSupportFlat, cand.flatTeamRate);
      }
    }
    maxFlatItem = math.max(2 * maxCeFlat + maxSvtTeam, maxSupportFlat);

    int maxCeV = 0, maxSupportV = 0;
    for (final c in ceClasses) {
      maxCeV = math.max(maxCeV, c.flatTeamValue);
    }
    for (final cand in cePool.supportCandidates) {
      maxSupportV = math.max(maxSupportV, cand.flatTeamValue);
    }
    int maxSvtV = 0;
    for (final s in svtClasses) {
      maxSvtV = math.max(maxSvtV, s.flatTeamEventValue);
    }
    maxV = math.max(maxCeV + maxSvtV, maxSupportV);

    // suffix sums: per-slot flat caps
    flatCapSuffix.length = 0;
    flatCapSuffix.add(0);
    for (int k = n - 1; k >= 0; k--) {
      final slot = searchSlots[k];
      final cap = slot.isFreeOwn ? _maxCeFlatRate + _maxSvtTeamRate : 2 * _maxCeFlatRate + _maxSvtTeamRate;
      flatCapSuffix.insert(0, flatCapSuffix.first + cap);
    }

    // per-item optimistic DP values (unfloored, rate at optimistic maximum),
    // then sort items by DP value descending so the DFS dives into promising
    // branches first and improves the incumbent early
    for (final slot in searchSlots) {
      for (final item in slot.items) {
        item.dpValue = _dpValueOf(slot, item);
      }
      final list = slot.items;
      final indexed = [for (final (i, it) in list.indexed) (i, it)];
      indexed.sort((a, b) {
        final c = b.$2.dpValue.compareTo(a.$2.dpValue);
        return c != 0 ? c : a.$1.compareTo(b.$1);
      });
      list
        ..clear()
        ..addAll([for (final e in indexed) e.$2]);
    }

    // DP tables per search slot (MCKP relaxation ignoring capacities/counts)
    final budgetSize = math.max(initialBudget, 0) + 1;
    final dp = List.generate(n + 1, (_) => List<double>.filled(budgetSize, 0.0));
    final maxBudget = math.max(initialBudget, 0);
    for (int k = n - 1; k >= 0; k--) {
      final slot = searchSlots[k];
      final pairs = [
        for (final item in slot.items)
          if (item.cost <= maxBudget) (item.cost, item.dpValue),
      ]..sort((a, b) => a.$1.compareTo(b.$1));
      final pareto = <(int, double)>[];
      double best = double.negativeInfinity;
      for (final (cost, value) in pairs) {
        if (value > best) {
          pareto.add((cost, value));
          best = value;
        }
      }
      final next = dp[k + 1];
      for (final b in range(budgetSize)) {
        double v = 0;
        for (final (cost, value) in pareto) {
          if (cost > b) break;
          final rest = next[b - cost];
          if (value + rest > v) v = value + rest;
        }
        dp[k][b] = v;
      }
    }
    for (int k = 0; k < n; k++) {
      final nRem = n - k;
      searchSlots[k].dp = dp[k];
      searchSlots[k].dpTail = (nRem * (nRem - 1)).toDouble() * maxV;
    }
  }

  double _dpValueOf(_SearchSlot slot, _Item item) {
    if (!slot.producesValue) return 0;
    if (slot.isFreeOwn && item.svt == null) return 0; // empty slot
    final rate = math.min(item.selfRate + tUpper, rateCap);
    final own = slot.base * (1 + slot.front / 1000) * (1 + rate / 1000) + item.selfValue + item.flatValue;
    // The item's targeted effects credit every receiver; attribute the FULL
    // team gain to the wearer so the DP can trade targeted CEs off against
    // value/rate CEs consistently (replaces a loose team-wide optimism term).
    if (item.targetedCeIdxs.isEmpty) return own;
    var targetedRate = 0;
    for (final ci in item.targetedCeIdxs) {
      targetedRate += _targetedClassRates[ci];
    }
    return own + targetedRate * sumMult / 1000;
  }

  // ================================================================================
  // DFS
  // ================================================================================

  void _dfs(int k, int symStart) {
    if (k == searchSlots.length) {
      _leaf();
      return;
    }
    nodeCount++;
    if (nodeCount - _phaseNodeStart > _phaseNodeCap) throw const _NodeCapExceeded();

    final slot = searchSlots[k];
    final threshold = (tieCapped ? bestTotal + 1 : bestTotal).toDouble();
    final nRem = searchSlots.length - k;
    // Node bound components:
    //  - optimistic (unfloored) value of already-initialized slots, with the
    //    future flat rate capped by the number of remaining assignments
    //  - DP relaxation bound for the remaining slots (targeted gains folded
    //    into item DP values)
    //  - team value inherited by not-yet-created deferred entries (vCur)
    //  - W: receipts of already-worn targeted classes for remaining slots
    final assigned = _assignedBound(k, nRem);
    final worn = _wornGain(nRem);
    final bound = assigned + slot.dp[_budgetIndex(budgetLeft)] + slot.dpTail + nRem * vCur + worn;
    if (_kDebugBound && nodeCount < 200) {
      // ignore: avoid_print
      print(
        'DBG k=$k nRem=$nRem assigned=$assigned dp=${slot.dp[_budgetIndex(budgetLeft)]} '
        'tail=${slot.dpTail} vcur=$nRem*$vCur W=$worn '
        'bound=$bound threshold=$threshold best=$bestTotal items=${slot.items.length}',
      );
    }
    if (bound < threshold) return;

    final nextSlot = k + 1 < searchSlots.length ? searchSlots[k + 1] : null;
    final nextDp = nextSlot == null ? 0.0 : nextSlot.dp[_budgetIndex(budgetLeft)] + nextSlot.dpTail;
    // constants for the early-break bound (items are sorted by dpValue desc,
    // so once the leading item cannot reach the threshold, none can)
    final breakConst = assigned + (vConst + vCur) + (nRem - 1) * maxV + nextDp + (nRem - 1) * (vCur + maxV) + worn;

    final items = slot.items;
    for (int i = symStart; i < items.length; i++) {
      final item = items[i];
      if (breakConst + item.dpValue < threshold) break;
      // cost 0 stays selectable even when the fixed part already exceeds budget
      if (item.cost > math.max(budgetLeft, 0)) continue;
      if (!_capacityOk(item)) continue;
      // per-item pre-filter (tighter than the break: uses the item's own cost)
      if (nextSlot != null) {
        final pre =
            assigned +
            item.dpValue +
            (vConst + vCur) +
            (nRem - 1) * maxV +
            nextSlot.dp[_budgetIndex(budgetLeft - item.cost)] +
            nextSlot.dpTail +
            (nRem - 1) * (vCur + item.flatValue + maxV) +
            worn;
        if (pre < threshold) continue;
      }

      _apply(k, slot, item);
      int nextSym = 0;
      if (nextSlot != null && nextSlot.isFreeOwn && slot.isFreeOwn && slot.group >= 0 && nextSlot.group == slot.group) {
        nextSym = i;
      }
      _dfs(k + 1, nextSym);
      _undo(k, slot, item);
    }
  }

  /// Async twin of [_dfs] for the top [_kAsyncDepth] levels: identical search,
  /// but it awaits between sibling subtrees so the UI isolate can render frames
  /// while a long search runs. Deeper levels recurse through [_dfs].
  ///
  /// The two loops must stay in step — a divergence here silently changes
  /// results. The only intentional differences are the recursion call (async vs
  /// sync) and the yield check; the debug bound print is not duplicated.
  Future<void> _dfsAsync(int k, int symStart) async {
    if (k == searchSlots.length) {
      _leaf();
      return;
    }
    nodeCount++;
    if (nodeCount - _phaseNodeStart > _phaseNodeCap) throw const _NodeCapExceeded();

    final slot = searchSlots[k];
    final threshold = (tieCapped ? bestTotal + 1 : bestTotal).toDouble();
    final nRem = searchSlots.length - k;
    final assigned = _assignedBound(k, nRem);
    final worn = _wornGain(nRem);
    final bound = assigned + slot.dp[_budgetIndex(budgetLeft)] + slot.dpTail + nRem * vCur + worn;
    if (bound < threshold) return;

    final nextSlot = k + 1 < searchSlots.length ? searchSlots[k + 1] : null;
    final nextDp = nextSlot == null ? 0.0 : nextSlot.dp[_budgetIndex(budgetLeft)] + nextSlot.dpTail;
    final breakConst = assigned + (vConst + vCur) + (nRem - 1) * maxV + nextDp + (nRem - 1) * (vCur + maxV) + worn;

    final items = slot.items;
    for (int i = symStart; i < items.length; i++) {
      final item = items[i];
      if (breakConst + item.dpValue < threshold) break;
      if (item.cost > math.max(budgetLeft, 0)) continue;
      if (!_capacityOk(item)) continue;
      if (nextSlot != null) {
        final pre =
            assigned +
            item.dpValue +
            (vConst + vCur) +
            (nRem - 1) * maxV +
            nextSlot.dp[_budgetIndex(budgetLeft - item.cost)] +
            nextSlot.dpTail +
            (nRem - 1) * (vCur + item.flatValue + maxV) +
            worn;
        if (pre < threshold) continue;
      }

      _apply(k, slot, item);
      int nextSym = 0;
      if (nextSlot != null && nextSlot.isFreeOwn && slot.isFreeOwn && slot.group >= 0 && nextSlot.group == slot.group) {
        nextSym = i;
      }
      if (k + 1 < _kAsyncDepth) {
        await _dfsAsync(k + 1, nextSym);
      } else {
        _dfs(k + 1, nextSym);
      }
      _undo(k, slot, item);
      // Yield with the search state fully unwound for this item.
      if (_shouldYield()) await _yieldFrame();
    }
  }

  bool _shouldYield() {
    final interval = yieldInterval;
    if (interval == null) return false;
    return _yieldClock.elapsedMilliseconds - _lastYieldMs >= interval.inMilliseconds;
  }

  Future<void> _yieldFrame() async {
    await Future<void>.delayed(_kYieldPause);
    _lastYieldMs = _yieldClock.elapsedMilliseconds;
  }

  int _budgetIndex(int b) => math.max(b, 0).clamp(0, math.max(initialBudget, 0));

  bool _capacityOk(_Item item) {
    if (item.svtIdx >= 0 && svtRem[item.svtIdx] <= 0) return false;
    for (final ci in item.ceConsumes) {
      if (ceRem[ci] <= 0) return false;
    }
    return true;
  }

  /// Σ over initialized deferred slots of their optimistic (unfloored) value.
  /// Future flat rate is capped by the per-slot flat caps of remaining items;
  /// future targeted receipts are covered team-wide by [_targetedGain].
  double _assignedBound(int k, int nRem) {
    final tFuture = math.min(tUpper - tCur, flatCapSuffix[k]);
    double sum = 0;
    for (final d in deferred) {
      final rate = math.min(d.rateExcl + tFuture, rateCap);
      sum += d.base * (1 + d.front / 1000) * (1 + rate / 1000) + d.valueExcl + nRem * maxV;
    }
    return sum;
  }

  /// Receipts of already-worn targeted classes for not-yet-assigned slots.
  /// Each remaining slot gains at most Σ(worn rates) × maxMult / 1000.
  double _wornGain(int nRem) => nRem * wornRateSum * maxMult / 1000;

  void _apply(int k, _SearchSlot slot, _Item item) {
    while (_choices.length <= k) {
      _choices.add(item);
      _appliedNewlyWorn.add(false);
      _appliedCreatedDeferred.add(false);
    }
    _choices[k] = item;
    budgetLeft -= item.cost;
    if (item.svtIdx >= 0) svtRem[item.svtIdx]--;
    for (final ci in item.ceConsumes) {
      ceRem[ci]--;
    }

    final fr = item.flatRate, fv = item.flatValue;
    if (fr != 0 || fv != 0) {
      tCur += fr;
      vCur += fv;
      for (final d in deferred) {
        d.rateExcl += fr;
        d.valueExcl += fv;
      }
    }
    var newlyWorn = false;
    if (item.targetedCeIdxs.isNotEmpty) {
      for (final ci in item.targetedCeIdxs) {
        if (wornTargeted.add(ci)) {
          newlyWorn = true;
          wornRateSum += _targetedClassRates[ci];
        }
      }
      for (final d in deferred) {
        for (final ci in item.targetedCeIdxs) {
          final r = _recvTargetedRateForDeferred(ci, d);
          d.rateExcl += r;
          d.targetedWorn += r;
        }
      }
    }
    _appliedNewlyWorn[k] = newlyWorn;

    var created = false;
    if (slot.producesValue && (!slot.isFreeOwn || item.svt != null)) {
      var wornRecv = 0;
      if (item.svt != null) {
        for (final ci in wornTargeted) {
          wornRecv += item.svt!.ceTeamTargetRate[ci] - ceClasses[ci].flatTeamRate;
        }
      } else {
        final cache = slot.fixedTargetedRecvMap;
        for (final ci in wornTargeted) {
          wornRecv += cache?[ci] ?? 0;
        }
      }
      deferred.add(
        _Deferred(
            position: slot.position,
            base: slot.base,
            front: slot.front,
            svtClass: item.svt,
            fixedTraits: slot.fixedTraits,
            fixedTargetedRecv: slot.fixedTargetedRecvMap,
            targetedAll: slot.isFreeOwn ? item.targetedAll : slot.fixedTargetedAll,
          )
          ..rateExcl = tConst + tCur + item.selfRate + wornRecv
          ..valueExcl = vConst + vCur + item.selfValue
          ..targetedWorn = wornRecv,
      );
      created = true;
    }
    _appliedCreatedDeferred[k] = created;
  }

  int _recvTargetedRateForDeferred(int ci, _Deferred d) {
    if (d.svtClass != null) {
      return d.svtClass!.ceTeamTargetRate[ci] - ceClasses[ci].flatTeamRate;
    }
    return d.fixedTargetedRecv?[ci] ?? 0;
  }

  late final List<int> _targetedClassRates = [
    for (final effects in ceTargeted)
      () {
        var rate = 0;
        for (final e in effects) {
          rate += e.rate;
        }
        return rate;
      }(),
  ];

  void _undo(int k, _SearchSlot slot, _Item item) {
    if (_appliedCreatedDeferred[k]) {
      deferred.removeLast();
      _appliedCreatedDeferred[k] = false;
    }
    if (item.targetedCeIdxs.isNotEmpty) {
      for (final d in deferred) {
        for (final ci in item.targetedCeIdxs) {
          final r = _recvTargetedRateForDeferred(ci, d);
          d.rateExcl -= r;
          d.targetedWorn -= r;
        }
      }
      if (_appliedNewlyWorn[k]) {
        wornTargeted.removeAll(item.targetedCeIdxs);
        for (final ci in item.targetedCeIdxs) {
          wornRateSum -= _targetedClassRates[ci];
        }
        _appliedNewlyWorn[k] = false;
      }
    }
    final fr = item.flatRate, fv = item.flatValue;
    if (fr != 0 || fv != 0) {
      tCur -= fr;
      vCur -= fv;
      for (final d in deferred) {
        d.rateExcl -= fr;
        d.valueExcl -= fv;
      }
    }
    for (final ci in item.ceConsumes) {
      ceRem[ci]++;
    }
    if (item.svtIdx >= 0) svtRem[item.svtIdx]++;
    budgetLeft += item.cost;
  }

  void _leaf() {
    var total = 0;
    _leafSetPositions.clear();
    for (final d in deferred) {
      final v = _bondOf(d.base, d.front, d.rateExcl, d.valueExcl);
      total += v;
      _leafValues[d.position] = v;
      _leafSetPositions.add(d.position);
    }
    if (total > bestTotal) {
      bestTotal = total;
      ties.clear();
      ties.add(_snapshot());
      tieCapped = false;
    } else if (total == bestTotal && !tieCapped) {
      ties.add(_snapshot());
      if (ties.length >= _kTieCap) tieCapped = true;
    }
    for (final p in _leafSetPositions) {
      _leafValues[p] = 0;
    }
  }

  _TieRecord _snapshot() {
    final choices = List<_Item>.of(_choices.take(searchSlots.length));
    final values = List<int>.of(_leafValues);
    return _TieRecord(choices, values, tCur, vCur);
  }

  /// Exact per-slot bond formula — mirrors `calcFormationBondResults`:
  /// floor(base × (1 + front/1000)), then floor(× (1 + min(rate, cap)/1000)) + value.
  /// The expressions are kept character-identical so double rounding matches.
  int _bondOf(int base, int front, int rate, int value) {
    int v = (base * (1 + front / 1000)).floor();
    v = (v * (1 + math.min(rate, rateCap) / 1000)).floor();
    return v + value;
  }

  // ================================================================================
  // Result assembly
  // ================================================================================

  BondSolverResult _assembleResult(bool provenOptimal) {
    final candidates = <BondSolutionCandidate>[];
    for (final tie in ties) {
      final slots = <BondSlotSolution>[];
      // fixed own slots without searched CE dimensions
      for (final fs in fixedOwnSlots) {
        if (fs.needsSearch) continue; // represented by its search slot below
        slots.add(
          BondSlotSolution(
            position: fs.position,
            fixedSvtId: fs.svtId,
            fixedCeId: fs.pinnedCeId,
            fixedCe3Id: fs.pinnedCe3Id,
            slotBond: fs.producesValue ? tie.values[fs.position] : 0,
            slotCost: fs.slotCost,
          ),
        );
      }
      // support slot (only when its CE is pinned — searched support below)
      if (hasSupportSlot && !supportEquipSearched) {
        final deck = decks[supportPosition];
        slots.add(
          BondSlotSolution(
            position: supportPosition,
            isSupport: true,
            fixedSvtId: deck.svt?.id,
            fixedCeId: deck.equip1.ce?.id,
            fixedCe3Id: deck.equip3.ce?.id,
            slotBond: 0,
            slotCost: 0,
          ),
        );
      }
      // search slots
      var cost = fixedCost;
      for (final (k, slot) in searchSlots.indexed) {
        final item = tie.choices[k];
        cost += item.cost;
        if (slot.isFreeOwn) {
          slots.add(
            BondSlotSolution(
              position: slot.position,
              svtClass: item.svt,
              ceClass: item.ces.isEmpty ? null : item.ces.first,
              slotBond: item.svt == null ? 0 : tie.values[slot.position],
              slotCost: item.cost,
            ),
          );
        } else if (slot.isSupport) {
          slots.add(
            BondSlotSolution(
              position: slot.position,
              isSupport: true,
              fixedSvtId: slot.fixedSvtId,
              fixedCe3Id: slot.fixedCe3Id,
              supportCe: item.supportCe,
              slotBond: 0,
              slotCost: 0,
            ),
          );
        } else {
          // fixed servant + searched CE(s)
          slots.add(
            BondSlotSolution(
              position: slot.position,
              fixedSvtId: slot.fixedSvtId,
              fixedCeId: slot.fixedCeId,
              fixedCe3Id: slot.fixedCe3Id,
              ceClass: item.ces.isEmpty ? null : item.ces.first,
              ce3Class: item.ces.length > 1 ? item.ces.last : null,
              slotBond: slot.producesValue ? tie.values[slot.position] : 0,
              slotCost: slot.fixedSlotCost + item.cost,
            ),
          );
        }
      }
      slots.sort((a, b) => a.position.compareTo(b.position));
      candidates.add(
        BondSolutionCandidate(
          totalBond: bestTotal,
          totalCost: cost,
          teamRate: tConst + tie.tCur,
          teamValue: vConst + tie.vCur,
          slots: slots,
        ),
      );
    }
    final best = candidates.first;
    return BondSolverResult(
      totalBond: bestTotal,
      totalCost: best.totalCost,
      teamRate: best.teamRate,
      teamValue: best.teamValue,
      provenOptimal: provenOptimal,
      warnings: warnings,
      candidates: candidates,
      fixedCost: fixedCost,
      budget: initialBudget,
      nodeCount: nodeCount,
    );
  }
}
