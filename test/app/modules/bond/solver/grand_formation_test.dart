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

  final extra = QuestPhaseExtraDetail()
    ..setValue('isUseGrandBoard', 1)
    ..setValue('isUseGrandBoardInitPos', [1, 2, 3, 4, 5, 6]);
  final quest = QuestPhase(id: 4000848, bond: 1000, extraDetail: extra);

  test('only explicitly supported recollection phases expose the adjustable limit', () {
    final rules = BondGrandRules.forQuest(quest)!;
    expect(rules.positions, {0, 1, 2, 3, 4, 5});
    expect(rules.ownedLimit(null), 6);
    expect(rules.ownedLimit(0), 0);
    expect(rules.ownedLimit(9), 6);
    expect(BondGrandRules.forQuest(QuestPhase(id: 4000848, phase: 2, extraDetail: extra)), isNull);
    expect(BondGrandRules.forQuest(QuestPhase(id: 4000849, extraDetail: extra)), isNull);
    expect(
      BondGrandRules.forQuest(
        QuestPhase(id: 4000848, extraDetail: QuestPhaseExtraDetail()..setValue('isUseGrandBoard', 1)),
      ),
      isNull,
    );
    final differentPositions = QuestPhaseExtraDetail()
      ..setValue('isUseGrandBoard', 1)
      ..setValue('isUseGrandBoardInitPos', [1, 2, 3]);
    expect(BondGrandRules.forQuest(QuestPhase(id: 4000848, extraDetail: differentPositions)), isNull);
    final activeGrandBoard = Restriction(
      id: 94151711,
      type: RestrictionType.activeGrandBoard,
      rangeType: RestrictionRangeType.equal,
      targetVals: [1, 2, 3, 4, 5, 6],
    );
    final restrictedQuest = QuestPhase(
      id: quest.id,
      extraDetail: extra,
      restrictions: [QuestPhaseRestriction(restriction: activeGrandBoard)],
    );
    expect(BondGrandRules.forQuest(restrictedQuest)?.maxOwned, 6);
    activeGrandBoard.targetVals.removeLast();
    expect(BondGrandRules.forQuest(restrictedQuest), isNull);
    final disabled = QuestPhaseExtraDetail()
      ..setValue('isUseGrandBoard', 0)
      ..setValue('isUseGrandBoardInitPos', [1, 2, 3, 4, 5, 6]);
    expect(BondGrandRules.forQuest(QuestPhase(id: quest.id, extraDetail: disabled)), isNull);

    final saved = FormationBondOption(maxGrandServants: 0);
    expect(saved.copy().maxGrandServants, 0);
    expect(FormationBondOption.fromJson(saved.toJson()).maxGrandServants, 0);
    expect(FormationBondOption.fromJson(saved.toJson()..remove('maxGrandServants')).maxGrandServants, isNull);
  });

  test('progressive Grand candidates fill affordable empty equip1 slots before publication', () async {
    final svt = db.gameData.servantsById.values.firstWhere(
      (svt) => svt.collectionNo > 0 && svt.isUserSvt && svt.cost == 16,
    );
    final repeatableCe = db.gameData.craftEssencesById[9403990]!;
    final restrictedCe = db.gameData.craftEssencesById[9401970]!;
    final saved = (svt.status.favorite, svt.status.grandSvt);
    addTearDown(() {
      svt.status
        ..favorite = saved.$1
        ..grandSvt = saved.$2;
    });
    svt.status
      ..favorite = true
      ..grandSvt = true;
    final allowed = {repeatableCe.id, restrictedCe.id};
    final option = FormationBondOption(
      maxServants: 1,
      maxCost: svt.cost + repeatableCe.cost,
      maxBond: 0,
      enableEvent: false,
      favoriteSvtEquipOnly: false,
      excludedSvts: db.gameData.servantsById.keys.toSet()..remove(svt.id),
      excludedCes: db.gameData.craftEssencesById.keys.toSet()..removeAll(allowed),
    );
    final formation = BattleTeamSetup();
    final expected = FormationBondSolver.solve(option: option, quest: quest, formation: formation);
    for (final worker in [false, true]) {
      final results = await FormationBondSolver.solveProgressively(
        option: option,
        quest: quest,
        formation: formation,
        useWorkerIsolate: worker,
      ).toList();
      final first = results.firstWhere((result) => result.best != null);
      expect(first.provenOptimal, isFalse);
      expect(first.best!.slots.single.equip1?.id, repeatableCe.id);
      expect(first.best!.slots.single.equip3?.id, restrictedCe.id);
      expect(results.last.provenOptimal, isTrue);
      expect(results.last.best!.totalBond, expected.best!.totalBond);
      var previous = 0;
      for (final result in results.where((result) => result.best != null)) {
        expect(result.best!.totalBond, greaterThanOrEqualTo(previous));
        previous = result.best!.totalBond;
        for (final candidate in result.candidates) {
          final input = option.copy();
          final manual = input.calcResults(quest, candidate.applyTo(formation, input));
          expect(candidate.totalBond, manual.fold<int>(0, (sum, slot) => sum + slot.totalBond));
          expect(candidate.totalCost, lessThanOrEqualTo(option.maxCost!));
          final slot = candidate.slots.single;
          expect(slot.equip1?.id, isNotNull);
          expect([slot.equip1?.id, slot.equip3?.id].where((id) => id == restrictedCe.id).length, lessThanOrEqualTo(1));
        }
      }
    }

    option.excludedCes.add(repeatableCe.id);
    final restrictedOnly = await FormationBondSolver.solveProgressively(
      option: option,
      quest: quest,
      formation: formation,
      useWorkerIsolate: false,
    ).firstWhere((result) => result.best != null);
    final slot = restrictedOnly.best!.slots.single;
    expect(slot.equip3?.id, restrictedCe.id);
    expect(slot.equip1, isNull);

    final repeatableOnly = option.copy()
      ..excludedCes.remove(repeatableCe.id)
      ..excludedCes.add(restrictedCe.id);
    for (final fast in [false, true]) {
      BondSolverResult countChoices(int cap) => FormationBondSolver.solve(
        option: repeatableOnly..maxGrandServants = cap,
        quest: quest,
        formation: formation,
        useCeFirst: fast,
      );
      expect(countChoices(0).itemCount, 3);
      expect(countChoices(1).itemCount, 5);
    }
  });

  test('shared Grand placements agree with exhaustive scoring and survive apply', () async {
    final playable = db.gameData.servantsById.values.where((svt) => svt.collectionNo > 0 && svt.isUserSvt);
    final roster = [...playable.where((svt) => svt.cost == 16).take(5), playable.firstWhere((svt) => svt.cost == 12)];
    final servants = roster.take(3).toList();
    final grands = servants.take(2).map((svt) => svt.id).toSet();
    final saved = {for (final svt in roster) svt.id: (svt.status.favorite, svt.status.grandSvt)};
    addTearDown(() {
      for (final svt in roster) {
        final (favorite, grand) = saved[svt.id]!;
        svt.status
          ..favorite = favorite
          ..grandSvt = grand;
      }
    });
    for (final svt in servants) {
      svt.status
        ..favorite = true
        ..grandSvt = grands.contains(svt.id);
    }
    final ce = db.gameData.craftEssencesById.values.firstWhere((ce) {
      if (ce.collectionNo <= 0 || BondCeIdentity.requiresUniqueOwnedIdentity(ce) || !ce.canBeGrandSvtRewardEquip) {
        return false;
      }
      final effects = CeBondEffect.extractAll(ce, true, quest, support: false);
      return effects.isNotEmpty && effects.every((e) => e.scope == BondEffectScope.team && e.isFlat && e.rate > 0);
    });
    final option = FormationBondOption(
      maxServants: 2,
      maxCost: 32,
      maxBond: 0,
      frontlineBonus: false,
      enableEvent: false,
      favoriteSvtEquipOnly: false,
      excludedSvts: db.gameData.servantsById.keys.toSet()..removeAll(servants.map((svt) => svt.id)),
      excludedCes: db.gameData.craftEssencesById.keys.toSet()..remove(ce.id),
      maxCandidateTeams: 4,
    );
    final formation = BattleTeamSetup();
    int score(BattleTeamSetup team) => option.calcResults(quest, team).fold(0, (sum, slot) => sum + slot.totalBond);

    final exhaustiveByCap = <int, int>{};
    for (final cap in [0, 1, 2]) {
      option.maxGrandServants = cap;
      var exhaustive = 0;
      // Main CEs exceed the budget here. The one repeatable reward is
      // beneficial and free for every active crown, so enumerate those slots.
      for (final first in servants) {
        for (final second in servants.where((svt) => svt.id != first.id)) {
          for (var mask = 0; mask < 4; mask++) {
            final pair = [first, second];
            final positions = [
              for (var p = 0; p < pair.length; p++)
                if (mask & (1 << p) != 0) p,
            ];
            if (positions.length > cap || positions.any((p) => !grands.contains(pair[p].id))) continue;
            final team = BattleTeamSetup();
            for (final (p, svt) in pair.indexed) {
              final slot = team.svts[p] = PlayerSvtData.svt(svt)..limitCount = 4;
              if (positions.contains(p)) {
                slot.grandSvt = true;
                slot.equip3
                  ..ce = ce
                  ..limitBreak = true;
              }
            }
            final value = score(team);
            if (value > exhaustive) exhaustive = value;
          }
        }
      }
      exhaustiveByCap[cap] = exhaustive;
      for (final ceFirst in [false, true]) {
        final result = FormationBondSolver.solve(
          option: option,
          quest: quest,
          formation: formation,
          useCeFirst: ceFirst,
        );
        expect(result.isCeFirst, ceFirst);
        expect(result.provenOptimal, isTrue);
        final best = result.best!;
        expect(best.totalBond, exhaustive, reason: 'cap=$cap, ceFirst=$ceFirst');
        expect(best.slots.map((slot) => slot.servantId).toSet(), hasLength(2));
        expect(best.slots.where((slot) => slot.enableGrand), hasLength(cap.clamp(0, 2)));
        expect(score(best.applyTo(formation, option.copy())), exhaustive);
      }
    }

    option.maxGrandServants = 1;
    final isolated = await FormationBondSolver.solveAsync(option: option, quest: quest, formation: formation);
    expect(isolated.provenOptimal, isTrue);
    expect(isolated.best!.totalBond, exhaustiveByCap[1]);
    expect(score(isolated.best!.applyTo(formation, option.copy())), exhaustiveByCap[1]);

    final withUnowned = option.copy()
      ..favoriteSvtOnly = false
      ..maxGrandServants = 2
      ..excludedSvts.add(servants.last.id);
    servants.first.status.favorite = false;
    final mixed = FormationBondSolver.solve(option: withUnowned, quest: quest, formation: formation).best!;
    expect(mixed.slots.map((slot) => slot.servantId), unorderedEquals([servants.first.id, servants[1].id]));
    expect(mixed.slots.where((slot) => slot.enableGrand).map((slot) => slot.servantId), [servants[1].id]);
    servants.first.status.favorite = true;

    final fixed = BattleTeamSetup()..svts[0] = (PlayerSvtData.svt(servants.first)..grandSvt = true);
    final filled = FormationBondSolver.solve(option: option, quest: quest, formation: fixed);
    expect(filled.best!.slots[1].servantId, isNotNull);
    expect(filled.best!.slots[1].enableGrand, isFalse);
    option.maxGrandServants = 0;
    expect(
      () => FormationBondSolver.validateFormation(option: option, quest: quest, formation: fixed),
      throwsA(isA<BondGrandLimitError>()),
    );

    option.maxGrandServants = 6;
    option.excludedCes.add(ce.id);
    final unrewarded = FormationBondSolver.solve(option: option, quest: quest, formation: formation);
    expect(unrewarded.best!.slots.every((slot) => !slot.enableGrand), isTrue);

    for (final svt in roster) {
      svt.status
        ..favorite = true
        ..grandSvt = true;
      option.excludedSvts.remove(svt.id);
    }
    option
      ..maxServants = 6
      ..maxCost = 92;
    option.excludedCes.remove(ce.id);
    final first = FormationBondSolver.solve(option: option, quest: quest, formation: BattleTeamSetup(), maxNodes: 1);
    expect(first.best?.slots.where((slot) => slot.enableGrand), hasLength(6));
    expect(first.best!.totalCost, 92);
    for (final withSupport in [false, true]) {
      option.maxGrandServants = withSupport ? 5 : 6;
      final team = BattleTeamSetup();
      if (withSupport) {
        team.svts[2]
          ..supportType = SupportSvtType.friend
          ..grandSvt = true;
      }
      final result = FormationBondSolver.solve(option: option, quest: quest, formation: team);
      expect(result.provenOptimal, isTrue);
      expect(result.best!.slots.where((slot) => slot.enableGrand), hasLength(withSupport ? 5 : 6));
      expect(score(result.best!.applyTo(team, option.copy())), result.best!.totalBond);
    }
  });
}
