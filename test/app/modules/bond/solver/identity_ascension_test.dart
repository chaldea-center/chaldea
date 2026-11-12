import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/app/modules/bond/bond_rules.dart';
import 'package:chaldea/app/modules/bond/formation_bond_calc.dart';
import 'package:chaldea/app/modules/bond/solver/bond_effect.dart';
import 'package:chaldea/app/modules/bond/solver/solver.dart';
import 'package:chaldea/models/models.dart';

import '../../../../test_init.dart';

void main() {
  setUpAll(initiateForTest);

  FormationBondOption options() => FormationBondOption(
    enableEvent: false,
    frontlineBonus: false,
    releaseReference: BondReleaseReference.jp,
    favoriteSvtOnly: false,
    favoriteSvtEquipOnly: false,
    maxBond: 0,
    maxCost: 999,
    // These tests compare pinned ascensions with explicitly enabled searching.
    searchFixedAscensions: false,
  );
  final quest = QuestPhase(bond: 1000);
  List<CraftEssence> fillers() => db.gameData.craftEssencesById.values
      .where((ce) => ce.collectionNo > 0 && CeBondEffect.extractAll(ce, true, quest, support: false).isEmpty)
      .take(6)
      .toList();
  BattleTeamSetup formation({Servant? first}) {
    final servants = db.gameData.servantsById.values
        .where((svt) => svt.collectionNo > 0 && svt.isUserSvt && svt.id != first?.id)
        .take(6)
        .toList();
    final ces = fillers();
    final result = BattleTeamSetup();
    for (var p = 0; p < 6; p++) {
      result.svts[p] = PlayerSvtData.svt(p == 0 && first != null ? first : servants[p])
        ..equip1 = SvtEquipData(ce: ces[p]);
    }
    return result;
  }

  Servant supportRecipient(CraftEssence ce, QuestPhase phase) {
    final effects = CeBondEffect.extractAll(ce, true, phase, support: true);
    return db.gameData.servantsById.values.firstWhere(
      (svt) =>
          svt.collectionNo > 0 &&
          svt.isUserSvt &&
          effects.any(
            (effect) =>
                effect.scope == BondEffectScope.team &&
                effect.wearerMatches(const []) &&
                (effect.rate > 0 || effect.value > 0) &&
                effect.targetMatches(BondReleaseRules.traits(svt, 4, 0, BondReleaseReference.jp)),
          ),
    );
  }

  BondSolverResult solve(BattleTeamSetup team, FormationBondOption option, {bool fast = true, QuestPhase? phase}) =>
      FormationBondSolver.solve(
        option: option,
        quest: phase ?? quest,
        formation: team,
        useCeFirst: fast,
        pruneDominatedCes: false,
      );
  void checkScores(BondSolverResult result, BattleTeamSetup input, FormationBondOption option, QuestPhase phase) {
    expect(result.provenOptimal, isTrue);
    for (final team in [result.best!, ...result.candidates]) {
      final applied = team.applyTo(input, FormationBondOption.fromJson(option.toJson()));
      final manual = option.calcResults(phase, applied);
      expect(team.slots.map((s) => s.bond).toList(), manual.take(team.slots.length).map((s) => s.totalBond).toList());
      final cost = applied.totalCost;
      expect(team.totalCost, cost);
    }
  }

  test('both restricted families are complete, effect-equivalent and share exclusions', () {
    expect(BondCeIdentity.of(9308080), 9308080);
    final ranges = [(99, 108), (1973, 1979)];
    for (final (index, family) in BondCeIdentity.families.indexed) {
      final (first, last) = ranges[index];
      expect(
        family.map((id) => db.gameData.craftEssencesById[id]!.collectionNo),
        List.generate(last - first + 1, (i) => first + i),
      );
      final reference = CeBondEffect.extractAll(
        db.gameData.craftEssencesById[family.first]!,
        true,
        quest,
        support: false,
      );
      for (final id in family) {
        expect(BondCeIdentity.of(id), family.first);
        expect(BondCeIdentity.excluded(id, {family.last}), isTrue);
        final effects = CeBondEffect.extractAll(db.gameData.craftEssencesById[id]!, true, quest, support: false);
        expect(
          effects.map((e) => '${e.scope}:${e.rate}:${e.value}:${e.targetPartial}:${e.targetOrAll}').toList(),
          reference.map((e) => '${e.scope}:${e.rate}:${e.value}:${e.targetPartial}:${e.targetOrAll}').toList(),
        );
      }
    }
  });

  test('different fixed family IDs conflict but support may repeat and exclusions preserve pins', () {
    final team = formation();
    team.svts[0].equip1 = SvtEquipData(ce: db.gameData.craftEssencesById[9308110], limitBreak: true);
    team.svts[1].equip1 = SvtEquipData(ce: db.gameData.craftEssencesById[9308120], limitBreak: true);
    for (final fast in [false, true]) {
      expect(() => solve(team, options(), fast: fast), throwsA(isA<BondFormationException>()));
    }
    team.svts[1].supportType = SupportSvtType.friend;
    final option = options()..excludedCes = {9308100};
    for (final fast in [false, true]) {
      final result = solve(team, option, fast: fast);
      expect(result.best!.slots[0].equip1!.id, 9308110);
      expect(result.best!.slots[1].equip1!.id, 9308120);
      checkScores(result, team, option, quest);
    }
  });

  test('each free family has one slot and fixed or excluded members block the whole group', () {
    for (final members in BondCeIdentity.families) {
      final team = formation();
      for (var p = 0; p < 3; p++) {
        team.svts[p].equip1 = SvtEquipData();
      }
      final family = members.toSet();
      final option = options()..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..removeAll(family));
      for (final fast in [false, true]) {
        final result = solve(team, option, fast: fast);
        final worn = result.best!.slots.where((s) => family.contains(s.equip1?.id)).toList();
        expect(worn, hasLength(1));
        expect(worn.single.equip1!.id, members.first);
        checkScores(result, team, option, quest);
        final excluded = FormationBondOption.fromJson(option.toJson())..excludedCes.add(members.last);
        expect(solve(team, excluded, fast: fast).best!.slots.where((s) => family.contains(s.equip1?.id)), isEmpty);
        final pinned = team.copy();
        pinned.svts[4].equip1 = SvtEquipData(ce: db.gameData.craftEssencesById[members.last], limitBreak: true);
        final fixedResult = solve(pinned, option, fast: fast);
        expect(fixedResult.best!.slots.take(3).where((s) => family.contains(s.equip1?.id)), isEmpty);
        expect(fixedResult.best!.slots[4].equip1!.id, members.last);
      }
    }
  });

  test('restricted fixed inputs fail before search and support may repeat owned identities', () async {
    for (final ids in [
      for (final family in BondCeIdentity.families) [family.first, family.last],
      [9403520, 9403520],
      [9401970, 9401970],
    ]) {
      final team = formation();
      team.svts[0].equip1 = SvtEquipData(ce: db.gameData.craftEssencesById[ids[0]], limitBreak: true);
      team.svts[1].equip1 = SvtEquipData(ce: db.gameData.craftEssencesById[ids[1]], limitBreak: true);
      final option = options();
      expect(
        () => FormationBondSolver.validateFixedCes(formation: team, quest: quest, maxServants: 6),
        throwsA(
          isA<BondFormationException>().having((e) => e.conflicts.map((s) => s.position).toList(), 'positions', [0, 1]),
        ),
      );
      var started = false;
      await expectLater(
        FormationBondSolver.solveProgressively(
          option: option,
          quest: quest,
          formation: team,
          onSearchStarted: () => started = true,
        ),
        emitsError(isA<BondFormationException>()),
      );
      expect(started, isFalse);
      team.svts[1].supportType = SupportSvtType.friend;
      for (final fast in [false, true]) {
        checkScores(solve(team, option, fast: fast), team, option, quest);
      }
    }
  });

  test('the two single-ID CEs cannot fill multiple free owned slots', () {
    for (final id in [9403520, 9401970]) {
      final team = formation();
      for (var p = 0; p < 3; p++) {
        team.svts[p].equip1 = SvtEquipData();
      }
      final option = options()..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..remove(id));
      for (final fast in [false, true]) {
        final result = solve(team, option, fast: fast);
        expect(result.best!.slots.where((s) => s.equip1?.id == id), hasLength(1));
        checkScores(result, team, option, quest);
      }
    }
  });

  test('mixed identity policies match a concrete two-slot enumeration at cost boundaries', () {
    final phase = QuestPhase(bond: 900);
    final fsn = CeBondEffect.extractAll(db.gameData.craftEssencesById[9308100]!, true, phase, support: false);
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 1 && s.isUserSvt).toList();
    final first = servants.firstWhere((s) => fsn.any((e) => e.targetMatches(s.getIndividuality(0, 4))));
    final second = servants.firstWhere((s) => !fsn.any((e) => e.targetMatches(s.getIndividuality(0, 4))));
    final generic = db.gameData.craftEssencesById[9403990]!;
    final ids = [9400970, 9401060, 9308100, 9308160, 9311320, 9311510, 9403520, 9401970, generic.id];
    final allowed = {...ids, ...BondCeIdentity.portraits, ...BondCeIdentity.fsn};
    final input = BattleTeamSetup();
    input.svts[0] = PlayerSvtData.svt(first);
    input.svts[1] = PlayerSvtData.svt(second);
    // This oracle encodes the specification directly, without calling the
    // solver's identity classifier or class-capacity/matching functions.
    int? identity(int? id) => switch (id) {
      9400970 || 9401060 => 1,
      9308100 || 9308160 => 2,
      9403520 || 9401970 => id,
      _ => null,
    };
    for (final ceBudget in [10, 18, 24]) {
      final option = options()
        ..maxServants = 2
        ..maxCost = first.cost + second.cost + ceBudget
        ..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..removeAll(allowed));
      var optimum = 0;
      for (final left in <int?>[null, ...ids]) {
        for (final right in <int?>[null, ...ids]) {
          if (identity(left) != null && identity(left) == identity(right)) continue;
          final team = input.copy();
          team.svts[0].equip1 = SvtEquipData(ce: db.gameData.craftEssencesById[left], limitBreak: true);
          team.svts[1].equip1 = SvtEquipData(ce: db.gameData.craftEssencesById[right], limitBreak: true);
          if (team.totalCost > option.maxCost!) continue;
          final score = option.calcResults(phase, team).fold<int>(0, (sum, slot) => sum + slot.totalBond);
          if (score > optimum) optimum = score;
        }
      }
      for (final fast in [false, true]) {
        for (final prune in [false, true]) {
          final result = FormationBondSolver.solve(
            option: option,
            quest: phase,
            formation: input,
            useCeFirst: fast,
            pruneDominatedCes: prune,
          );
          expect(result.provenOptimal, isTrue);
          expect(result.best!.totalBond, optimum, reason: 'CE budget $ceBudget, fast=$fast, prune=$prune');
          checkScores(result, input, option, phase);
        }
      }
    }
  });

  test('generic CEs reuse the smallest eligible ID without an identity capacity', () {
    final ces = db.gameData.craftEssencesById.values.where((ce) {
      if (ce.collectionNo <= 0 || ce.isRegionSpecific) return false;
      final effects = CeBondEffect.extractAll(ce, true, quest, support: false);
      final support = CeBondEffect.extractAll(ce, true, quest, support: true);
      return effects.length == 1 &&
          effects.single.isFlat &&
          effects.single.rate == 50 &&
          effects.single.value == 0 &&
          support.length == 1 &&
          support.single.isFlat &&
          support.single.rate == 50 &&
          support.single.value == 0;
    }).toList()..sort((a, b) => a.id.compareTo(b.id));
    final sameCost = ces.where((ce) => ce.cost == ces.first.cost).take(3).toList();
    expect(sameCost, hasLength(3));
    final team = formation();
    team.svts[0].equip1 = SvtEquipData();
    team.svts[1].equip1 = SvtEquipData();
    team.svts[3].equip1 = SvtEquipData(ce: sameCost.first, limitBreak: true);
    team.svts[4].equip1 = SvtEquipData(ce: sameCost.first, limitBreak: true);
    final option = options()
      ..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..removeAll(sameCost.map((ce) => ce.id)));
    for (final fast in [false, true]) {
      final result = solve(team, option, fast: fast);
      for (final candidate in result.candidates.where((team) => team.totalBond == result.best!.totalBond)) {
        expect(candidate.slots.take(2).map((s) => s.equip1?.id).toList(), [sameCost[0].id, sameCost[0].id]);
      }
      final excluded = FormationBondOption.fromJson(option.toJson())..excludedCes.add(sameCost.first.id);
      expect(solve(team, excluded, fast: fast).best!.slots.take(2).map((s) => s.equip1?.id).toList(), [
        sameCost[1].id,
        sameCost[1].id,
      ]);
      checkScores(result, team, option, quest);
    }
  });

  test('Pole 2 percent CEs are reusable representatives with per-ID exclusions', () {
    final poles =
        db.gameData.craftEssencesById.values.where((ce) => ce.collectionNo >= 2513 && ce.collectionNo <= 2532).toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    expect(poles, hasLength(20));
    final team = formation();
    team.svts[0].equip1 = SvtEquipData();
    team.svts[1].equip1 = SvtEquipData();
    team.svts[3].equip1 = SvtEquipData(ce: poles.first, limitBreak: true);
    team.svts[4].equip1 = SvtEquipData(ce: poles.first, limitBreak: true);
    final option = options()
      ..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..removeAll([poles.first.id, poles.last.id]));
    for (final fast in [false, true]) {
      final result = solve(team, option, fast: fast);
      expect(result.best!.slots.take(2).map((slot) => slot.equip1!.id), [poles.first.id, poles.first.id]);
      checkScores(result, team, option, quest);
      final excluded = option.copy()..excludedCes.add(poles.first.id);
      final other = solve(team, excluded, fast: fast);
      expect(other.best!.slots.take(2).map((slot) => slot.equip1!.id), [poles.last.id, poles.last.id]);
      expect(other.best!.slots[3].equip1!.id, poles.first.id);
      checkScores(other, team, excluded, quest);
    }
  });

  test('mixed free CEs sort by traits, rate and ID while support and pins stay fixed', () {
    final flat = db.gameData.craftEssencesById.values.where((ce) {
      if (ce.collectionNo <= 0 || ce.isRegionSpecific) return false;
      final own = CeBondEffect.extractAll(ce, true, quest, support: false);
      final support = CeBondEffect.extractAll(ce, true, quest, support: true);
      return own.length == 1 &&
          own.single.isFlat &&
          own.single.rate == 50 &&
          own.single.value == 0 &&
          support.length == 1 &&
          support.single.rate == 50;
    }).toList()..sort((a, b) => a.id.compareTo(b.id));
    final generic = flat.where((ce) => ce.cost == flat.first.cost).take(2).toList();
    final fsnEffects = CeBondEffect.extractAll(db.gameData.craftEssencesById[9308100]!, true, quest, support: false);
    final fsn = db.gameData.servantsById.values.firstWhere(
      (svt) =>
          svt.isUserSvt &&
          svt.collectionNo > 0 &&
          fsnEffects.any((effect) => effect.targetMatches(svt.getIndividuality(0, 4))),
    );
    final team = formation(first: fsn);
    final targets = db.gameData.servantsById.values
        .where(
          (svt) =>
              svt.isUserSvt &&
              svt.collectionNo > 0 &&
              fsnEffects.any((effect) => effect.targetMatches(svt.getIndividuality(0, 4))),
        )
        .take(5)
        .toList();
    for (var p = 0; p < 5; p++) {
      team.svts[p].svt = targets[p];
    }
    final phase = QuestPhase(bond: 900);
    for (var p = 0; p < 4; p++) {
      team.svts[p].equip1 = SvtEquipData();
    }
    final pinned = team.svts[4].equip1.ce!.id;
    team.svts[5].supportType = SupportSvtType.friend;
    final supportId = team.svts[5].equip1.ce!.id;
    final pool = {...BondCeIdentity.fsn, ...BondCeIdentity.portraits, ...generic.map((ce) => ce.id)};
    final option = options()..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..removeAll(pool));
    final expected = [9308100, generic[0].id, generic[0].id, BondCeIdentity.portraits.first];
    for (final fast in [false, true]) {
      final result = solve(team, option, fast: fast, phase: phase);
      expect(result.best!.slots.take(4).map((s) => s.equip1?.id).toList(), expected);
      expect(result.best!.slots[4].equip1!.id, pinned);
      expect(result.best!.slots[5].equip1!.id, supportId);
      checkScores(result, team, option, phase);
    }
    final original = db.gameData.craftEssencesById;
    try {
      db.gameData.craftEssencesById = Map.fromEntries(original.entries.toList().reversed);
      expect(solve(team, option, phase: phase).best!.slots.take(4).map((s) => s.equip1?.id).toList(), expected);
    } finally {
      db.gameData.craftEssencesById = original;
    }
  });

  test('fixed equip1 and equip3 share family capacity', () {
    final team = formation();
    team.svts[0]
      ..grandSvt = true
      ..equip1 = SvtEquipData(ce: db.gameData.craftEssencesById[9308110], limitBreak: true)
      ..equip3 = SvtEquipData(ce: db.gameData.craftEssencesById[9308120], limitBreak: true);
    final phase = QuestPhase(bond: 1000, extraDetail: QuestPhaseExtraDetail()..setValue('isUseGrandBoard', 1));
    for (final fast in [false, true]) {
      expect(() => solve(team, options(), phase: phase, fast: fast), throwsA(isA<BondFormationException>()));
      team.svts[0].equip3 = SvtEquipData();
      final option = options()
        ..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..removeAll(BondCeIdentity.fsn));
      final result = solve(team, option, phase: phase, fast: fast);
      expect(result.best!.slots[0].equip3, isNull);
      expect(result.best!.slots[0].equip1!.id, 9308110);
      checkScores(result, team, option, phase);
      team.svts[0].equip3 = SvtEquipData(ce: db.gameData.craftEssencesById[9308120], limitBreak: true);
    }
  });

  test('fixed ascension search matches exhaustive trait CE scores and marks requirements', () {
    (Servant, CraftEssence, int)? selected;
    for (final svt in db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt)) {
      final traits = [
        for (var limit = 0; limit <= 4; limit++)
          (svt.getAscended(limit, (a) => a.individuality2) ?? svt.traits).toSet().toList()..sort(),
      ];
      if (traits.every((t) => t.join(',') == traits.first.join(','))) continue;
      for (final ce in db.gameData.craftEssencesById.values.where((c) => c.collectionNo > 0 && !c.isRegionSpecific)) {
        final effects = CeBondEffect.extractAll(ce, true, quest, support: false);
        if (effects.length != 1 ||
            effects.single.scope != BondEffectScope.team ||
            !effects.single.hasTargetCondition ||
            effects.single.rate <= 0 ||
            effects.single.wearerActIndiv.isNotEmpty ||
            effects.single.wearerRequiredIndiv != 0) {
          continue;
        }
        final matches = traits.map(effects.single.targetMatches).toList();
        if (!matches.contains(true) || !matches.contains(false)) continue;
        selected = (svt, ce, matches.indexOf(false));
        break;
      }
      if (selected != null) break;
    }
    expect(selected, isNotNull);
    final (svt, ce, initial) = selected!;
    final team = formation(first: svt);
    team.svts[0].limitCount = initial;
    team.svts[1].equip1 = SvtEquipData(ce: ce, limitBreak: true);
    final option = options();
    final scores = <int>[];
    for (var limit = 0; limit <= 4; limit++) {
      final variant = team.copy();
      variant.svts[0].limitCount = limit;
      final solved = solve(variant, option);
      scores.add(solved.best!.totalBond);
    }
    expect(scores.toSet().length, greaterThan(1));
    option.searchFixedAscensions = true;
    for (final fast in [true, false]) {
      final result = solve(team, option, fast: fast);
      expect(result.best!.totalBond, greaterThanOrEqualTo(scores.reduce((a, b) => a > b ? a : b)));
      checkScores(result, team, option, quest);
      final requirement = FormationBondSolver.ascensionRequirement(
        team: result.best!,
        target: result.best!.slots[0],
        option: option,
        quest: quest,
        formation: team,
      );
      expect(requirement.restricted, isTrue);
      expect(requirement.allowed, isNot(contains(initial)));
      expect(requirement.allowed, contains(result.best!.slots[0].limitCount));
    }
  });

  test('searching pinned ascensions respects changed cost, keeps IDs and bond flags', () {
    final mash = db.gameData.servantsById.values.firstWhere((s) => s.collectionNo == 1);
    final expensive = mash.ascensionAdd.overwriteCost.all.entries.firstWhere((e) => e.value > mash.cost).key;
    final team = formation(first: mash);
    team.svts[0].limitCount = expensive;
    final option = options();
    option.svtBonus[0].isBond15 = true;
    option.svtBonus[0].isBondReachLimit = true;
    final fixed = solve(team, option);
    option.maxCost = fixed.best!.totalCost - 1;
    expect(solve(team, option).best, isNull);
    option.searchFixedAscensions = true;
    final fast = solve(team, option);
    final general = solve(team, option, fast: false);
    expect(fast.best!.totalBond, general.best!.totalBond);
    expect(fast.best!.totalCost, lessThanOrEqualTo(option.maxCost!));
    expect(fast.best!.slots[0].servantId, mash.id);
    expect(fast.best!.slots[0].bond, 0);
    checkScores(fast, team, option, quest);
    checkScores(general, team, option, quest);
    final requirement = FormationBondSolver.ascensionRequirement(
      team: fast.best!,
      target: fast.best!.slots[0],
      option: option,
      quest: quest,
      formation: team,
    );
    expect(requirement.restricted, isTrue);
    expect(requirement.allowed, isNot(contains(expensive)));
  });

  test('a quest-invalid pinned ascension can be replaced only when enabled', () {
    Servant? target;
    int? forbidden, allowed, trait;
    for (final svt in db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt)) {
      final base = svt.getAscended(0, (a) => a.individuality2) ?? svt.traits;
      for (var limit = 1; limit <= 4; limit++) {
        final alternate = svt.getAscended(limit, (a) => a.individuality2) ?? svt.traits;
        final difference = alternate.where((t) => !base.contains(t)).toList();
        if (difference.isEmpty) continue;
        target = svt;
        forbidden = 0;
        allowed = limit;
        trait = difference.first;
        break;
      }
      if (target != null) break;
    }
    expect(target, isNotNull);
    final team = formation(first: target);
    team.svts[0].limitCount = forbidden!;
    // Apply the trait restriction only to the changing servant by making all other slots supports.
    for (var p = 1; p < 6; p++) {
      team.svts[p].supportType = SupportSvtType.friend;
    }
    final phase = QuestPhase(
      bond: 1000,
      restrictions: [
        QuestPhaseRestriction(
          restriction: Restriction(
            id: 1,
            type: RestrictionType.individuality,
            rangeType: RestrictionRangeType.equal,
            targetVals: [trait!],
          ),
        ),
      ],
    );
    final option = options();
    expect(() => solve(team, option, phase: phase), throwsStateError);
    option.searchFixedAscensions = true;
    final fast = solve(team, option, phase: phase);
    final general = solve(team, option, phase: phase, fast: false);
    expect(fast.best!.totalBond, general.best!.totalBond);
    checkScores(fast, team, option, phase);
    final requirement = FormationBondSolver.ascensionRequirement(
      team: fast.best!,
      target: fast.best!.slots[0],
      option: option,
      quest: phase,
      formation: team,
    );
    expect(requirement.allowed, contains(allowed));
    expect(requirement.allowed, isNot(contains(forbidden)));
  });

  test('release reference defaults to JP, round-trips, and invalid dates reset to JP', () {
    expect(FormationBondOption().releaseReference, BondReleaseReference.jp);
    for (final reference in BondReleaseReference.values) {
      final option = options()..releaseReference = reference;
      expect(FormationBondOption.fromJson(option.toJson()).releaseReference, reference);
    }
    for (final phase in [null, QuestPhase(closedAt: 0), QuestPhase(closedAt: 2000000000)]) {
      final option = options()..releaseReference = BondReleaseReference.questClosedAt;
      option.validate(phase);
      expect(option.releaseReference, BondReleaseReference.jp);
      expect(BondReleaseRules.resolve(BondReleaseReference.questClosedAt, phase), BondReleaseReference.jp);
    }
  });

  test('legacy favoriteOnly key migrates to both split filters', () {
    final json = FormationBondOption().toJson()
      ..remove('favoriteSvtOnly')
      ..remove('favoriteSvtEquipOnly')
      ..['favoriteOnly'] = false;
    final option = FormationBondOption.fromJson(json);
    expect(option.favoriteSvtOnly, isFalse);
    expect(option.favoriteSvtEquipOnly, isFalse);
  });

  test('quest date filters free servants at the release boundary but preserves fixed servants', () {
    final target = db.gameData.servantsById.values.firstWhere(
      (svt) => svt.collectionNo > 0 && svt.isUserSvt && svt.extra.getReleasedAt() > 0,
    );
    final release = target.extra.getReleasedAt();
    final team = formation(first: target);
    for (var p = 1; p < 6; p++) {
      team.svts[p].supportType = SupportSvtType.friend;
    }
    final option = options()
      ..releaseReference = BondReleaseReference.questClosedAt
      ..excludedSvts = (db.gameData.servantsById.keys.toSet()..remove(target.id));
    final before = QuestPhase(bond: 1000, closedAt: release - 1);
    final atRelease = QuestPhase(bond: 1000, closedAt: release);
    expect(solve(team, option, phase: before).best, isNotNull);
    team.svts[0].svt = null;
    for (final fast in [false, true]) {
      expect(() => solve(team, option, phase: before, fast: fast), throwsStateError);
      final result = solve(team, option, phase: atRelease, fast: fast);
      expect(result.best!.slots[0].servantId, target.id);
      checkScores(result, team, option, atRelease);
      final invalidDate = solve(team, option, phase: QuestPhase(bond: 1000), fast: fast);
      expect(invalidDate.best!.slots[0].servantId, target.id);
    }
    final unknown = db.gameData.servantsById.values.firstWhere(
      (svt) => svt.collectionNo > 0 && svt.isUserSvt && svt.extra.getReleasedAt() == 0,
    );
    option.excludedSvts = db.gameData.servantsById.keys.toSet()..remove(unknown.id);
    expect(solve(team, option, phase: QuestPhase(bond: 1000, closedAt: 1)).best!.slots[0].servantId, unknown.id);
  });

  test('regional release lists filter free servants and CEs but keep fixed inputs', () {
    final team = formation();
    final target = team.svts[0].svt!;
    final ce = db.gameData.craftEssencesById[9401060]!;
    final releases = db.gameData.mappingData.entityRelease;
    final saved = (releases.cn, releases.tw, releases.na);
    addTearDown(() {
      releases.cn = saved.$1;
      releases.tw = saved.$2;
      releases.na = saved.$3;
    });
    releases.cn = [target.id];
    releases.tw = [ce.id];
    releases.na = [target.id, ce.id];
    final option = options()
      ..excludedSvts = (db.gameData.servantsById.keys.toSet()..remove(target.id))
      ..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..removeAll(BondCeIdentity.portraits));
    team.svts[0].svt = null;
    team.svts[0].equip1 = SvtEquipData();
    for (final reference in [BondReleaseReference.jp, BondReleaseReference.cn, BondReleaseReference.na]) {
      option.releaseReference = reference;
      final result = solve(team, option);
      expect(result.best!.slots[0].servantId, target.id);
      expect(
        result.best!.slots[0].equip1?.id,
        reference == BondReleaseReference.cn
            ? null
            : reference == BondReleaseReference.jp
            ? BondCeIdentity.portraits.first
            : ce.id,
      );
    }
    option.releaseReference = BondReleaseReference.tw;
    expect(solve(team, option).best!.slots[0].servantId, isNull);
    team.svts[0].svt = target;
    expect(solve(team, option).best!.slots[0].equip1!.id, ce.id);
  });

  test('costume traits agree in manual, both searches and CE details without mutating data', () {
    final target = db.gameData.servantsById.values.firstWhere(
      (svt) =>
          svt.collectionNo > 0 &&
          svt.isUserSvt &&
          BondReleaseRules.traits(svt, 4, 0, BondReleaseReference.jp).contains(Trait.hasCostume.value),
    );
    final ce = db.gameData.craftEssencesById.values.firstWhere(
      (ce) => CeBondEffect.extractAll(ce, true, quest, support: false).any(
        (effect) =>
            effect.scope == BondEffectScope.team &&
            effect.rate > 0 &&
            (effect.targetPartial.contains(Trait.hasCostume.value) ||
                effect.targetOrAll.any((group) => group.contains(Trait.hasCostume.value))),
      ),
    );
    final mapping = db.gameData.mappingData.svtTraitRelease;
    final saved = mapping[Trait.hasCostume.value];
    addTearDown(() {
      if (saved == null) {
        mapping.remove(Trait.hasCostume.value);
      } else {
        mapping[Trait.hasCostume.value] = saved;
      }
    });
    mapping[Trait.hasCostume.value] = MappingList(cn: [], tw: [], na: []);
    final baseTraits = List<int>.of(target.traits);
    final team = formation(first: target);
    team.svts[0].limitCount = 4;
    team.svts[0].equip1 = SvtEquipData(ce: ce, limitBreak: true);
    for (var p = 1; p < 6; p++) {
      team.svts[p].supportType = SupportSvtType.friend;
    }
    int? jpBond;
    for (final reference in BondReleaseReference.values) {
      final option = options()..releaseReference = reference;
      final phase = QuestPhase(bond: 1000, closedAt: 1700000000);
      for (final fast in [false, true]) {
        final result = solve(team, option, phase: phase, fast: fast);
        checkScores(result, team, option, phase);
        final best = result.best!;
        final details = best.traitCeBonusesFor(best.slots[0], phase, option);
        if (reference.region.isJP) {
          jpBond ??= best.slots[0].bond;
          expect(best.slots[0].bond, jpBond);
          expect(details, isNotEmpty);
        } else {
          expect(best.slots[0].bond, lessThan(jpBond!));
          expect(details, isEmpty);
        }
      }
    }
    expect(target.traits, baseTraits);
    expect(BondReleaseRules.traits(target, 4, 0, BondReleaseReference.jp), contains(Trait.hasCostume.value));
  });

  test('free family representative prefers the owned member with the smallest id', () {
    final family = BondCeIdentity.fsn;
    final saved = <int, CraftStatus?>{};
    for (final id in [9308130, 9308150]) {
      final ce = db.gameData.craftEssencesById[id]!;
      saved[ce.collectionNo] = db.curUser.craftEssences[ce.collectionNo];
      db.curUser.craftEssences[ce.collectionNo] = CraftStatus(status: CraftStatus.owned);
    }
    addTearDown(() {
      saved.forEach((no, status) {
        if (status == null) {
          db.curUser.craftEssences.remove(no);
        } else {
          db.curUser.craftEssences[no] = status;
        }
      });
    });
    final team = formation();
    for (var p = 0; p < 3; p++) {
      team.svts[p].equip1 = SvtEquipData();
    }
    final option = options()..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..removeAll(family));
    for (final fast in [false, true]) {
      final result = solve(team, option, fast: fast);
      final worn = result.best!.slots.where((s) => family.contains(s.equip1?.id)).toList();
      expect(worn, hasLength(1));
      expect(worn.single.equip1!.id, 9308130);
      checkScores(result, team, option, quest);
    }
  });

  test('favoriteSvtEquipOnly keeps only owned craft essences in the free pool', () {
    final team = formation();
    for (var p = 0; p < 3; p++) {
      team.svts[p].equip1 = SvtEquipData();
    }
    final pinnedIds = team.svts.skip(3).map((s) => s.equip1.ce?.id).toList();
    final ce = db.gameData.craftEssencesById[9401060]!;
    final option = options()..favoriteSvtEquipOnly = true;
    // Nothing owned: no free CE survives, while pinned CEs are untouched.
    final empty = solve(team, option);
    expect(empty.best!.slots.take(3).every((s) => s.equip1 == null), isTrue);
    expect(empty.best!.slots.skip(3).map((s) => s.equip1?.id).toList(), pinnedIds);
    final saved = db.curUser.craftEssences[ce.collectionNo];
    db.curUser.craftEssences[ce.collectionNo] = CraftStatus(status: CraftStatus.owned);
    addTearDown(() {
      if (saved == null) {
        db.curUser.craftEssences.remove(ce.collectionNo);
      } else {
        db.curUser.craftEssences[ce.collectionNo] = saved;
      }
    });
    final owned = solve(team, option);
    expect(owned.best!.slots.take(3).where((s) => s.equip1?.id == ce.id).length, 1);
    expect(owned.best!.slots.skip(3).map((s) => s.equip1?.id).toList(), pinnedIds);
    expect(owned.best!.totalBond, greaterThan(empty.best!.totalBond));
    checkScores(owned, team, option, quest);
  });

  test('favoriteSvtEquipOnly gates what an owned servant wears, not what a support borrows', () {
    final borrowed = db.gameData.craftEssencesById[9403520]!;
    final savedStatus = db.curUser.craftEssences[borrowed.collectionNo];
    db.curUser.craftEssences.remove(borrowed.collectionNo);
    addTearDown(() {
      if (savedStatus != null) db.curUser.craftEssences[borrowed.collectionNo] = savedStatus;
    });
    final team = formation();
    team.svts[0].supportType = SupportSvtType.friend;
    for (var p = 0; p < 6; p++) {
      team.svts[p].equip1 = SvtEquipData();
    }
    final option = options()
      ..favoriteSvtEquipOnly = true
      ..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..remove(borrowed.id));
    final result = solve(team, option);
    // A support borrows from someone else, so the user's collection says
    // nothing about it and the one remaining CE still fits.
    expect(result.best!.slots[0].equip1?.id, borrowed.id);
    // Owned servants still cannot wear what the user does not own.
    expect(result.best!.slots.skip(1).every((s) => s.equip1 == null), isTrue);
  });

  test('results report the free pool sizes and omit pools that were never built', () {
    final servants = db.gameData.servantsById.values
        .where((svt) => svt.collectionNo > 0 && svt.isUserSvt)
        .take(2)
        .toList();
    final ces = fillers();
    final team = BattleTeamSetup();
    team.svts[0] = PlayerSvtData.svt(servants[0])..equip1 = SvtEquipData(ce: ces[0]);
    team.svts[1].equip1 = SvtEquipData(ce: ces[1]);
    final option = options()
      ..maxServants = 2
      ..excludedSvts = (db.gameData.servantsById.keys.toSet()..removeAll(servants.map((svt) => svt.id)));
    final result = FormationBondSolver.solve(option: option, quest: quest, formation: team, maxNodes: 50000);
    // Position 2 has no servant, so a pool was built for it.
    expect(result.candidateSvtIds, isNotNull);
    expect(result.candidateSvtIds, isNotEmpty);
    // Every CE was pinned, so no CE pool was built at all — reported as null
    // rather than as a misleading zero.
    expect(result.candidateCeIds, isNull);
  });

  test('inactive equip3 cannot reappear beside equip1 in solved previews', () {
    for (final id in [9407480, 9400970, 9401970]) {
      final ce = db.gameData.craftEssencesById[id]!;
      final input = formation(first: supportRecipient(ce, quest));
      input.svts[0]
        ..limitCount = 4
        ..grandSvt = true
        ..equip1 = SvtEquipData(ce: ce, limitBreak: true)
        ..equip3 = SvtEquipData(ce: ce, limitBreak: true);
      input.svts[1]
        ..supportType = SupportSvtType.friend
        ..grandSvt = true
        ..equip1 = SvtEquipData()
        ..equip3 = SvtEquipData(ce: ce, limitBreak: true);
      final allowed = id == 9400970 ? BondCeIdentity.portraits : [id];
      final option = options()
        ..maxServants = 2
        ..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..removeAll(allowed));
      // Grand flags and saved reward CEs may remain after switching quests.
      // This quest does not activate those slots, so the preview must omit them.
      for (final (fast, streaming) in [(false, false), (true, false), (true, true)]) {
        final result = FormationBondSolver.solve(
          option: option,
          quest: quest,
          formation: input,
          useCeFirst: fast,
          useStreamingCeFirst: streaming,
        );
        final applied = result.best!.applyTo(input, option.copy());
        for (final p in [1, 0]) {
          final slot = result.best!.slots[p];
          expect(BondCeIdentity.of(slot.equip1!.id), BondCeIdentity.of(ce.id));
          expect(slot.equip3, isNull);
          final preview = applied.svts[p].toStoredData()!;
          expect(preview.equip1.id, slot.equip1!.id);
          expect(preview.equip3, isNull);
          expect(input.svts[p].equip3.ce!.id, ce.id);
        }
        checkScores(result, input, option, quest);
      }
    }
  });

  test('a pinned support equip1 still loads free Grand equip3 candidates', () {
    final phase = QuestPhase(bond: 1000, extraDetail: QuestPhaseExtraDetail()..setValue('isUseGrandBoard', 1));
    final ce = db.gameData.craftEssencesById[9403990]!;
    final input = formation();
    input.svts[1]
      ..supportType = SupportSvtType.friend
      ..equip1 = SvtEquipData(ce: ce, limitBreak: true)
      ..equip3 = SvtEquipData()
      ..grandSvt = true;
    final option = options()
      ..maxServants = 2
      ..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..remove(ce.id));
    for (final (fast, streaming) in [(false, false), (true, false), (true, true)]) {
      final result = FormationBondSolver.solve(
        option: option,
        quest: phase,
        formation: input,
        useCeFirst: fast,
        useStreamingCeFirst: streaming,
      );
      expect(result.isCeFirst, fast);
      final support = result.best!.slots[1];
      expect(support.equip1!.id, ce.id);
      expect(support.equip3?.id, ce.id);
      checkScores(result, input, option, phase);
    }
  });

  test('grand support identity policies cover both slots and all search routes', () {
    final phase = QuestPhase(bond: 1000, extraDetail: QuestPhaseExtraDetail()..setValue('isUseGrandBoard', 1));
    final traitCe = db.gameData.craftEssencesById.values.firstWhere(
      (ce) =>
          ce.collectionNo > 0 &&
          !BondCeIdentity.families.any((family) => family.contains(ce.id)) &&
          CeBondEffect.extractAll(ce, true, phase, support: true).any(
            (effect) =>
                effect.scope == BondEffectScope.team &&
                effect.wearerMatches(const []) &&
                effect.hasTargetCondition &&
                effect.rate > 0,
          ),
    );
    final cases = [
      (ids: [traitCe.id], repeatable: false),
      (ids: BondCeIdentity.portraits, repeatable: false),
      (ids: BondCeIdentity.fsn, repeatable: false),
      (ids: [9403520], repeatable: false),
      (ids: [9401970], repeatable: false),
      (ids: [9403990], repeatable: true),
      (ids: [9406010], repeatable: true),
    ];
    for (final fixture in cases) {
      final ce = db.gameData.craftEssencesById[fixture.ids.first]!;
      expect(BondCeIdentity.requiresUniqueOwnedIdentity(ce), !fixture.repeatable);
      if (fixture.repeatable) {
        final effect = CeBondEffect.extractAll(ce, true, phase, support: true).single;
        expect(effect.isFlat, isTrue);
        expect(effect.rate, ce.id == 9406010 ? 25 : 50);
      }
      final input = formation(first: supportRecipient(ce, phase));
      input.svts[0].limitCount = 4;
      input.svts[1]
        ..supportType = SupportSvtType.friend
        ..equip1 = SvtEquipData()
        ..equip3 = SvtEquipData()
        ..grandSvt = true;
      final option = options()
        ..maxServants = 2
        ..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..removeAll(fixture.ids));
      for (final (fast, streaming) in [(false, false), (true, false), (true, true)]) {
        for (final prune in [false, true]) {
          BondSolverResult run(BattleTeamSetup team) => FormationBondSolver.solve(
            option: option,
            quest: phase,
            formation: team,
            useCeFirst: fast,
            useStreamingCeFirst: streaming,
            pruneDominatedCes: prune,
          );
          // A pin on either support slot must reserve its identity only within
          // that support, independently of the same CE on an owned servant.
          for (final pin in [0, 1, 3]) {
            final team = input.copy();
            if (pin != 0) {
              team.svts[0].equip1 = SvtEquipData(ce: ce, limitBreak: true);
              if (pin == 1) {
                team.svts[1].equip1 = SvtEquipData(ce: ce, limitBreak: true);
              } else {
                team.svts[1].equip3 = SvtEquipData(ce: ce, limitBreak: true);
              }
            }
            final result = run(team);
            expect(result.isCeFirst, fast);
            if (streaming) expect(result.possibleCombinations, isNull);
            final support = result.best!.slots[1];
            final equipped = [support.equip1, support.equip3].nonNulls.toList();
            expect(equipped, hasLength(fixture.repeatable ? 2 : 1), reason: 'CE ${ce.id}, pin $pin');
            expect(equipped.every((e) => fixture.ids.contains(e.id)), isTrue);
            if (pin != 0) {
              expect((pin == 1 ? support.equip1 : support.equip3)!.id, ce.id);
              expect(result.best!.slots[0].equip1!.id, ce.id);
            }
            if (!fixture.repeatable) {
              for (final candidate in [result.best!, ...result.ties, ...result.candidates]) {
                final ids = [
                  candidate.slots[1].equip1,
                  candidate.slots[1].equip3,
                ].nonNulls.map((e) => BondCeIdentity.of(e.id)).toList();
                expect(ids.toSet(), hasLength(ids.length), reason: 'duplicate support identity for CE ${ce.id}');
              }
            }
            checkScores(result, team, option, phase);
          }
          final duplicate = input.copy();
          duplicate.svts[1]
            ..equip1 = SvtEquipData(ce: ce)
            ..equip3 = SvtEquipData(ce: db.gameData.craftEssencesById[fixture.ids.last], limitBreak: true);
          if (fixture.repeatable) {
            checkScores(run(duplicate), duplicate, option, phase);
          } else {
            expect(
              () => run(duplicate),
              throwsA(
                isA<BondFormationException>()
                    .having((e) => e.conflicts.map((c) => c.position).toList(), 'positions', [1, 1])
                    .having((e) => e.conflicts.map((c) => c.equip).toList(), 'equips', [1, 3]),
              ),
            );
          }
        }
      }
    }
  });

  test('a grand support also searches its free equip3 slot', () {
    final team = formation();
    team.svts[5]
      ..supportType = SupportSvtType.friend
      ..equip1 = SvtEquipData()
      ..equip3 = SvtEquipData()
      ..grandSvt = true;
    final phase = QuestPhase(bond: 1000, extraDetail: QuestPhaseExtraDetail()..setValue('isUseGrandBoard', 1));
    final option = options();
    for (final fast in [false, true]) {
      final result = solve(team, option, phase: phase, fast: fast);
      final support = result.best!.slots[5];
      expect(support.isSupport, isTrue);
      expect(support.equip1, isNotNull);
      expect(support.equip3, isNotNull);
      expect(support.equip3!.id, isNot(support.equip1!.id));
      for (final candidate in [result.best!, ...result.ties, ...result.candidates]) {
        final ids = [candidate.slots[5].equip1, candidate.slots[5].equip3].nonNulls
            .where((e) => BondCeIdentity.requiresUniqueOwnedIdentity(db.gameData.craftEssencesById[e.id]!))
            .map((e) => BondCeIdentity.of(e.id))
            .toList();
        expect(ids.toSet(), hasLength(ids.length));
      }
      checkScores(result, team, option, phase);
    }
    // Without the grand flag the support has no equip3 at all.
    team.svts[5].grandSvt = false;
    for (final fast in [false, true]) {
      final result = solve(team, option, phase: phase, fast: fast);
      expect(result.best!.slots[5].equip1, isNotNull);
      expect(result.best!.slots[5].equip3, isNull);
    }
  });
}
