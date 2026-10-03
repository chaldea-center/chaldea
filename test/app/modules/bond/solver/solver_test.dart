import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/app/modules/bond/formation_bond.dart';
import 'package:chaldea/app/modules/bond/solver/solver.dart';
import 'package:chaldea/models/models.dart';

import '../../../../test_init.dart';

FormationBondOption _withFilters(
  FormationBondOption option, {
  int? maxCost,
  bool? favoriteOnly,
  BondReleaseReference? releaseReference,
  int? maxBond,
  Set<int>? excludedSvts,
  Set<int>? excludedCes,
}) {
  if (maxCost != null) option.maxCost = maxCost;
  if (favoriteOnly != null) option.favoriteOnly = favoriteOnly;
  if (releaseReference != null) option.releaseReference = releaseReference;
  if (maxBond != null) option.maxBond = maxBond;
  if (excludedSvts != null) option.excludedSvts = excludedSvts;
  if (excludedCes != null) option.excludedCes = excludedCes;
  return option;
}

void main() {
  setUpAll(initiateForTest);

  test('quest individuality restrictions filter free servants and reject invalid fixed servants', () {
    final servants = db.gameData.servantsById.values.where((svt) => svt.collectionNo > 0 && svt.isUserSvt).toList();
    final saberTrait = Trait.classSaber.value;
    final sabers = servants.where((svt) => svt.traits.contains(saberTrait)).take(6).toList();
    final others = servants
        .where(
          (svt) =>
              !svt.traits.contains(saberTrait) &&
              svt.ascensionAdd.individuality2.all.values.every((traits) => !traits.contains(saberTrait)) &&
              svt.traitAdd.every((add) => !add.trait.contains(saberTrait)),
        )
        .take(6)
        .toList();
    expect(sabers, hasLength(6));
    expect(others, hasLength(6));
    final ces = db.gameData.craftEssencesById.values
        .where((ce) => ce.collectionNo > 0 && !ce.isRegionSpecific)
        .take(6)
        .toList();
    final formation = BattleTeamSetup();
    for (var i = 0; i < 5; i++) {
      formation.svts[i] = PlayerSvtData.svt(sabers[i])..equip1 = SvtEquipData(ce: ces[i]);
    }
    formation.svts[5].equip1 = SvtEquipData(ce: ces[5]);
    final option = _withFilters(
      FormationBondOption(enableEvent: false),
      maxCost: 999,
      favoriteOnly: false,
      releaseReference: BondReleaseReference.jp,
      maxBond: 0,
      excludedSvts: servants.map((svt) => svt.id).toSet()..removeAll([sabers[5].id, others[5].id]),
    );

    QuestPhase restricted(RestrictionRangeType rangeType) => QuestPhase(
      bond: 1000,
      restrictions: [
        QuestPhaseRestriction(
          restriction: Restriction(
            id: 1,
            type: RestrictionType.individuality,
            rangeType: rangeType,
            targetVals: [saberTrait],
          ),
        ),
      ],
    );

    BondSolverResult solve(QuestPhase quest, BattleTeamSetup team) =>
        FormationBondSolver.solve(option: option, quest: quest, formation: team);

    final saberOnly = solve(restricted(RestrictionRangeType.equal), formation);
    expect(saberOnly.provenOptimal, isTrue);
    expect(saberOnly.best!.slots[5].servantId, sabers[5].id);
    expect(saberOnly.ties.every((team) => team.slots[5].servantId == sabers[5].id), isTrue);

    final noSaber = restricted(RestrictionRangeType.notEqual);
    expect(() => solve(noSaber, formation), throwsStateError);
    final validFormation = formation.copy();
    for (var i = 0; i < 5; i++) {
      validFormation.svts[i] = PlayerSvtData.svt(others[i])..equip1 = SvtEquipData(ce: ces[i]);
    }
    final inverted = solve(noSaber, validFormation);
    expect(inverted.provenOptimal, isTrue);
    expect(inverted.best!.slots[5].servantId, others[5].id);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('fully pinned own formation matches the manual calculation', () async {
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt).take(6).toList();
    final ces = db.gameData.craftEssencesById.values
        .where((c) => c.collectionNo > 0 && !c.isRegionSpecific)
        .take(6)
        .toList();
    expect(servants.length, 6);
    expect(ces.length, 6);
    final formation = BattleTeamSetup();
    for (var i = 0; i < 6; i++) {
      formation.svts[i] = PlayerSvtData.svt(servants[i])
        ..limitCount = i % 5
        ..equip1 = SvtEquipData(ce: ces[i], limitBreak: i.isEven);
    }
    final option = FormationBondOption(enableEvent: false, teapotTimes: 1);
    final quest = QuestPhase(bond: 1000);
    final expected = calcFormationBondResults(option, quest, formation);
    final result = FormationBondSolver.solve(
      option: _withFilters(
        option,
        maxCost: 999,
        favoriteOnly: false,
        releaseReference: BondReleaseReference.jp,
        maxBond: 0,
      ),
      quest: quest,
      formation: formation,
    );
    expect(result.provenOptimal, isTrue);
    expect(result.best, isNotNull);
    expect(result.best!.totalBond, expected.fold<int>(0, (v, slot) => v + slot.totalBond));
    expect([for (final slot in result.best!.slots) slot.bond], [for (final slot in expected) slot.totalBond]);
    expect([for (final slot in result.best!.slots) slot.servantId], [for (final s in servants) s.id]);
    final background = await FormationBondSolver.solveAsync(
      option: _withFilters(
        option,
        maxCost: 999,
        favoriteOnly: false,
        releaseReference: BondReleaseReference.jp,
        maxBond: 0,
      ),
      quest: quest,
      formation: formation,
    );
    expect(background.provenOptimal, isTrue);
    expect(background.best!.totalBond, result.best!.totalBond);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('frontline support placeholder applies a flat follower CE', () {
    final ce = db.gameData.craftEssencesById[9403520];
    expect(ce, isNotNull);
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt).take(6).toList();
    final fillerCes = db.gameData.craftEssencesById.values
        .where((c) => c.collectionNo > 0 && !c.isRegionSpecific && c.id != ce!.id)
        .take(5)
        .toList();
    final formation = BattleTeamSetup();
    formation.svts[0] = PlayerSvtData.base()
      ..supportType = SupportSvtType.friend
      ..equip1 = SvtEquipData(ce: ce, limitBreak: true);
    for (var i = 1; i < 6; i++) {
      formation.svts[i] = PlayerSvtData.svt(servants[i - 1])..equip1 = SvtEquipData(ce: fillerCes[i - 1]);
    }
    final option = FormationBondOption(enableEvent: false);
    final quest = QuestPhase(bond: 1000);
    final result = FormationBondSolver.solve(
      option: _withFilters(option, maxCost: 999, releaseReference: BondReleaseReference.jp),
      quest: quest,
      formation: formation,
    );
    expect(result.provenOptimal, isTrue);
    expect(result.best!.slots[0].isSupport, isTrue);
    expect(result.best!.slots[0].servantId, isNull);
    expect(result.best!.slots[0].equip1!.id, ce!.id);

    final virtualManual = calcFormationBondResults(option, quest, formation);
    expect(result.best!.totalBond, virtualManual.fold<int>(0, (v, slot) => v + slot.totalBond));
    final applied = result.best!.applyTo(formation, option);
    expect(applied.svts[0].svt, isNull);
    final reappliedScore = calcFormationBondResults(option, quest, applied);
    expect(result.best!.totalBond, reappliedScore.fold<int>(0, (v, slot) => v + slot.totalBond));

    // This follower CE has no wearer trait condition, so a real support in the
    // manual page gives the same effect as the solver's no-trait placeholder.
    final manualFormation = formation.copy();
    manualFormation.svts[0] = PlayerSvtData.svt(servants.last)
      ..supportType = SupportSvtType.friend
      ..equip1 = SvtEquipData(ce: ce, limitBreak: true);
    final manual = calcFormationBondResults(option, quest, manualFormation);
    expect(result.best!.totalBond, manual.fold<int>(0, (v, slot) => v + slot.totalBond));
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('Heroic Spirit Portrait data correction gives every owned servant +50', () {
    final portrait = db.gameData.craftEssencesById[9401060];
    expect(portrait, isNotNull);
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt).take(6).toList();
    final fillers = db.gameData.craftEssencesById.values
        .where(
          (ce) =>
              ce.collectionNo > 0 &&
              ce.id != portrait!.id &&
              !ce
                  .getActivatedSkills(true)
                  .values
                  .expand((skills) => skills)
                  .any((skill) => skill.functions.any((func) => func.funcType == FuncType.servantFriendshipUp)),
        )
        .take(5)
        .toList();
    final formation = BattleTeamSetup();
    for (var i = 0; i < 6; i++) {
      formation.svts[i] = PlayerSvtData.svt(servants[i])..equip1 = SvtEquipData(ce: i == 0 ? portrait : fillers[i - 1]);
    }
    final option = FormationBondOption(enableEvent: false, frontlineBonus: false);
    final quest = QuestPhase(bond: 1000);
    final manual = calcFormationBondResults(option, quest, formation);
    expect([for (final slot in manual) slot.totalBond], List<int>.filled(6, 1050));
    final solved = FormationBondSolver.solve(
      option: _withFilters(option, maxCost: 999, releaseReference: BondReleaseReference.jp),
      quest: quest,
      formation: formation,
    );
    expect(solved.provenOptimal, isTrue);
    expect([for (final slot in solved.best!.slots) slot.bond], List<int>.filled(6, 1050));

    final supportFormation = formation.copy();
    supportFormation.svts[0] = PlayerSvtData.base()
      ..supportType = SupportSvtType.friend
      ..equip1 = SvtEquipData(ce: portrait);
    final supportManual = calcFormationBondResults(option, quest, supportFormation);
    expect([for (final slot in supportManual) slot.totalBond], [0, 1050, 1050, 1050, 1050, 1050]);
    final supportSolved = FormationBondSolver.solve(
      option: _withFilters(option, maxCost: 999, releaseReference: BondReleaseReference.jp),
      quest: quest,
      formation: supportFormation,
    );
    expect(supportSolved.provenOptimal, isTrue);
    expect([for (final slot in supportSolved.best!.slots) slot.bond], [0, 1050, 1050, 1050, 1050, 1050]);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('pinned Grand Board equip3 matches the manual calculation', () {
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt).take(6).toList();
    final ce3 = db.gameData.craftEssencesById[9401970];
    expect(ce3, isNotNull);
    final fillerCes = db.gameData.craftEssencesById.values
        .where((c) => c.collectionNo > 0 && !c.isRegionSpecific && c.id != ce3!.id)
        .take(6)
        .toList();
    final formation = BattleTeamSetup();
    for (var i = 0; i < 6; i++) {
      formation.svts[i] = PlayerSvtData.svt(servants[i])..equip1 = SvtEquipData(ce: fillerCes[i]);
    }
    formation.svts[0]
      ..grandSvt = true
      ..equip3 = SvtEquipData(ce: ce3, limitBreak: true);
    final option = FormationBondOption(enableEvent: false);
    final extra = QuestPhaseExtraDetail()..setValue('isUseGrandBoard', 1);
    final quest = QuestPhase(bond: 1000, extraDetail: extra);
    final result = FormationBondSolver.solve(
      option: _withFilters(option, maxCost: 999, releaseReference: BondReleaseReference.jp),
      quest: quest,
      formation: formation,
    );
    expect(result.provenOptimal, isTrue);
    expect(result.best!.slots[0].equip3!.id, ce3!.id);
    final manual = calcFormationBondResults(option, quest, formation);
    expect(result.best!.totalBond, manual.fold<int>(0, (v, slot) => v + slot.totalBond));
    expect([for (final slot in result.best!.slots) slot.bond], [for (final slot in manual) slot.totalBond]);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('pinned support Grand Board equip3 uses the virtual support wearer', () {
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt).take(5).toList();
    final supportCe1 = db.gameData.craftEssencesById[9403520]!;
    final supportCe3 = db.gameData.craftEssencesById[9401970]!;
    final fillers = db.gameData.craftEssencesById.values
        .where(
          (ce) =>
              ce.collectionNo > 0 &&
              ce.id != supportCe1.id &&
              ce.id != supportCe3.id &&
              !ce
                  .getActivatedSkills(true)
                  .values
                  .expand((v) => v)
                  .any((skill) => skill.functions.any((func) => func.funcType == FuncType.servantFriendshipUp)),
        )
        .take(5)
        .toList();
    final formation = BattleTeamSetup();
    formation.svts[0] = PlayerSvtData.base()
      ..supportType = SupportSvtType.friend
      ..grandSvt = true
      ..equip1 = SvtEquipData(ce: supportCe1, limitBreak: true)
      ..equip3 = SvtEquipData(ce: supportCe3, limitBreak: true);
    for (var i = 1; i < 6; i++) {
      formation.svts[i] = PlayerSvtData.svt(servants[i - 1])..equip1 = SvtEquipData(ce: fillers[i - 1]);
    }
    final extra = QuestPhaseExtraDetail()..setValue('isUseGrandBoard', 1);
    final quest = QuestPhase(bond: 1000, extraDetail: extra);
    final option = FormationBondOption(enableEvent: false);
    final manual = calcFormationBondResults(option, quest, formation);
    final solved = FormationBondSolver.solve(
      option: _withFilters(option, maxCost: 999, releaseReference: BondReleaseReference.jp),
      quest: quest,
      formation: formation,
    );
    expect(solved.provenOptimal, isTrue);
    expect(solved.best!.slots.first.servantId, isNull);
    expect(solved.best!.slots.first.equip3!.id, supportCe3.id);
    expect([for (final slot in solved.best!.slots) slot.bond], [for (final slot in manual) slot.totalBond]);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('a pinned CE remains fixed while its servant is searched', () {
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt).take(5).toList();
    final pinnedCe = db.gameData.craftEssencesById[9401970];
    expect(pinnedCe, isNotNull);
    final fillerCes = db.gameData.craftEssencesById.values
        .where((c) => c.collectionNo > 0 && !c.isRegionSpecific && c.id != pinnedCe!.id)
        .take(5)
        .toList();
    final formation = BattleTeamSetup();
    for (var i = 0; i < 5; i++) {
      formation.svts[i] = PlayerSvtData.svt(servants[i])..equip1 = SvtEquipData(ce: fillerCes[i]);
    }
    formation.svts[5].equip1 = SvtEquipData(ce: pinnedCe, limitBreak: true);
    final option = FormationBondOption(enableEvent: false, maxCandidateTeams: 30);
    final quest = QuestPhase(bond: 1000);
    final result = FormationBondSolver.solve(
      option: _withFilters(
        option,
        maxCost: 999,
        favoriteOnly: false,
        releaseReference: BondReleaseReference.jp,
        maxBond: 0,
      ),
      quest: quest,
      formation: formation,
      maxNodes: 100000,
    );
    expect(result.best, isNotNull);
    expect(result.provenOptimal, isTrue);
    expect(result.candidates.length, greaterThan(20));
    expect(result.candidates.length, lessThanOrEqualTo(option.maxCandidateTeams));
    for (final candidate in [result.candidates.first, result.candidates[15], result.candidates.last]) {
      final candidateOption = FormationBondOption.fromJson(option.toJson());
      final candidateFormation = candidate.applyTo(formation, candidateOption);
      final checked = calcFormationBondResults(candidateOption, quest, candidateFormation);
      expect(candidate.totalBond, checked.fold<int>(0, (sum, slot) => sum + slot.totalBond));
    }
    final chosen = result.best!.slots[5];
    expect(chosen.equip1!.id, pinnedCe!.id);
    expect(chosen.servantId, isNotNull);
    formation.svts[5] = PlayerSvtData.svt(db.gameData.servantsById[chosen.servantId]!)
      ..limitCount = chosen.limitCount!
      ..equip1 = SvtEquipData(ce: pinnedCe, limitBreak: true);
    final manual = calcFormationBondResults(option, quest, formation);
    expect(result.best!.totalBond, manual.fold<int>(0, (v, slot) => v + slot.totalBond));
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('bond flags on a free servant position do not affect the solve', () {
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt).take(5).toList();
    final ces = db.gameData.craftEssencesById.values
        .where((c) => c.collectionNo > 0 && !c.isRegionSpecific)
        .take(5)
        .toList();
    final formation = BattleTeamSetup();
    for (var i = 0; i < 5; i++) {
      formation.svts[i] = PlayerSvtData.svt(servants[i])..equip1 = SvtEquipData(ce: ces[i]);
    }
    final option = FormationBondOption(enableEvent: false);
    final extra = QuestPhaseExtraDetail()..setValue('isUseGrandBoard', 1);
    final quest = QuestPhase(bond: 1000, extraDetail: extra);
    _withFilters(option, maxCost: 999, favoriteOnly: false, releaseReference: BondReleaseReference.jp, maxBond: 0);
    final baseline = FormationBondSolver.solve(option: option, quest: quest, formation: formation, maxNodes: 100000);
    option.svtBonus[5]
      ..isBond15 = true
      ..isBondReachLimit = true;
    formation.svts[5]
      ..grandSvt = true
      ..equip3 = SvtEquipData(ce: db.gameData.craftEssencesById[9401970], limitBreak: true);
    final flagged = FormationBondSolver.solve(option: option, quest: quest, formation: formation, maxNodes: 100000);
    expect(baseline.provenOptimal, isTrue);
    expect(flagged.provenOptimal, isTrue);
    expect(flagged.best!.totalBond, baseline.best!.totalBond);
    expect(flagged.best!.slots[5].bond, baseline.best!.slots[5].bond);
    expect(flagged.best!.slots[5].equip3, isNull);
    final applied = flagged.best!.applyTo(formation, option);
    expect(option.svtBonus[5].isBond15, isFalse);
    expect(option.svtBonus[5].isBondReachLimit, isFalse);
    final manual = calcFormationBondResults(option, quest, applied);
    expect(flagged.best!.totalBond, manual.fold<int>(0, (v, slot) => v + slot.totalBond));
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('fixed teams agree with manual scoring across real quest phases', () {
    final quests = [
      ...db.gameData.questPhases.values.where((q) => q.bond > 0 && q.logicEventId != null).take(5),
      ...db.gameData.questPhases.values.where((q) => q.bond > 0 && q.logicEventId == null).take(5),
    ];
    expect(quests, isNotEmpty);
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 1 && s.isUserSvt).take(6).toList();
    final ces = db.gameData.craftEssencesById.values
        .where(
          (c) =>
              c.collectionNo > 0 &&
              c
                  .getActivatedSkills(true)
                  .values
                  .expand((v) => v)
                  .any((skill) => skill.functions.any((func) => func.funcType == FuncType.servantFriendshipUp)),
        )
        .take(6)
        .toList();
    expect(ces.length, 6);
    for (final quest in quests) {
      final formation = BattleTeamSetup();
      for (var i = 0; i < 6; i++) {
        formation.svts[i] = PlayerSvtData.svt(servants[i])
          ..limitCount = i % 5
          ..equip1 = SvtEquipData(ce: ces[i], limitBreak: true);
      }
      final option = FormationBondOption(enableEvent: true);
      option.svtBonus[0].isBond15 = true;
      option.svtBonus[1].isBondReachLimit = true;
      option.svtBonus[2]
        ..addRate = 123
        ..addValue = 17;
      final manual = calcFormationBondResults(option, quest, formation);
      final result = FormationBondSolver.solve(
        option: _withFilters(option, maxCost: 999, releaseReference: BondReleaseReference.jp),
        quest: quest,
        formation: formation,
      );
      expect(result.provenOptimal, isTrue, reason: 'quest ${quest.id}/${quest.phase}');
      expect(
        [for (final slot in result.best!.slots) slot.bond],
        [for (final slot in manual) slot.totalBond],
        reason: 'quest ${quest.id}/${quest.phase}',
      );
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('conditioned CE effects agree with manual scoring', () {
    final quest = db.gameData.questPhases.values.firstWhere((q) => q.bond > 0);
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt).take(6).toList();
    final fillerCes = db.gameData.craftEssencesById.values
        .where(
          (ce) =>
              ce.collectionNo > 0 &&
              !ce
                  .getActivatedSkills(true)
                  .values
                  .expand((v) => v)
                  .any((skill) => skill.functions.any((func) => func.funcType == FuncType.servantFriendshipUp)),
        )
        .take(5)
        .toList();
    final ces = db.gameData.craftEssencesById.values
        .where((ce) {
          if (ce.collectionNo <= 0) return false;
          return ce.getActivatedSkills(true).values.expand((v) => v).any((skill) {
            return skill.functions.any((func) {
              return func.funcType == FuncType.servantFriendshipUp &&
                  (skill.actIndividuality.isNotEmpty ||
                      func.getOverwriteTvalsList().isNotEmpty ||
                      func.functvals.isNotEmpty ||
                      (func.svals.firstOrNull?.Individuality ?? 0) != 0);
            });
          });
        })
        .take(30)
        .toList();
    expect(ces.length, greaterThanOrEqualTo(10));
    final option = FormationBondOption(enableEvent: false);
    for (final ce in ces) {
      final formation = BattleTeamSetup();
      for (var i = 0; i < 6; i++) {
        formation.svts[i] = PlayerSvtData.svt(servants[i])
          ..limitCount = i % 5
          ..equip1 = i == 0 ? SvtEquipData() : SvtEquipData(ce: fillerCes[i - 1]);
      }
      formation.svts[0].equip1 = SvtEquipData(ce: ce, limitBreak: true);
      final manual = calcFormationBondResults(option, quest, formation);
      final solved = FormationBondSolver.solve(
        option: _withFilters(option, maxCost: 999, releaseReference: BondReleaseReference.jp),
        quest: quest,
        formation: formation,
      );
      expect(solved.provenOptimal, isTrue, reason: 'CE ${ce.id}');
      expect(
        [for (final slot in solved.best!.slots) slot.bond],
        [for (final slot in manual) slot.totalBond],
        reason: 'CE ${ce.id}',
      );
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('one free position returns a concrete team with manual-page score', () async {
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt).take(5).toList();
    final ces = db.gameData.craftEssencesById.values
        .where((c) => c.collectionNo > 0 && !c.isRegionSpecific)
        .take(5)
        .toList();
    final formation = BattleTeamSetup();
    for (var i = 0; i < 5; i++) {
      formation.svts[i] = PlayerSvtData.svt(servants[i])..equip1 = SvtEquipData(ce: ces[i]);
    }
    final option = FormationBondOption(enableEvent: false);
    final quest = QuestPhase(bond: 1000);
    final clock = Stopwatch()..start();
    final result = await FormationBondSolver.solveAsync(
      option: _withFilters(
        option,
        maxCost: 999,
        favoriteOnly: false,
        releaseReference: BondReleaseReference.jp,
        maxBond: 0,
      ),
      quest: quest,
      formation: formation,
      maxNodes: 100000,
    );
    print('one-free solver: ${clock.elapsedMilliseconds}ms, ${result.visitedNodes} search steps');
    expect(result.best, isNotNull);
    expect(result.provenOptimal, isTrue);
    final chosen = result.best!.slots.last;
    if (chosen.servantId != null) {
      formation.svts[5] = PlayerSvtData.svt(db.gameData.servantsById[chosen.servantId]!)
        ..limitCount = chosen.limitCount!
        ..equip1 = SvtEquipData(
          ce: chosen.equip1 == null ? null : db.gameData.craftEssencesById[chosen.equip1!.id],
          limitBreak: chosen.equip1?.limitBreak ?? false,
        );
    }
    final manual = calcFormationBondResults(option, quest, formation);
    expect(result.best!.totalBond, manual.fold<int>(0, (v, slot) => v + slot.totalBond));
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('CE dominance pruning preserves an exact one-free optimum', () {
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt).take(5).toList();
    final ces = db.gameData.craftEssencesById.values
        .where((c) => c.collectionNo > 0 && !c.isRegionSpecific)
        .take(5)
        .toList();
    final formation = BattleTeamSetup();
    for (var i = 0; i < 5; i++) {
      formation.svts[i] = PlayerSvtData.svt(servants[i])..equip1 = SvtEquipData(ce: ces[i]);
    }
    final option = FormationBondOption(enableEvent: false);
    final quest = QuestPhase(bond: 1000);
    _withFilters(option, maxCost: 999, favoriteOnly: false, releaseReference: BondReleaseReference.jp, maxBond: 0);
    final baseline = FormationBondSolver.solve(
      option: option,
      quest: quest,
      formation: formation,
      pruneDominatedCes: false,
    );
    final pruned = FormationBondSolver.solve(option: option, quest: quest, formation: formation);
    expect(baseline.provenOptimal, isTrue);
    expect(pruned.provenOptimal, isTrue);
    expect(pruned.best!.totalBond, baseline.best!.totalBond);
    expect(pruned.ownedCeClassCount, lessThan(baseline.ownedCeClassCount));
    expect(pruned.itemCount, lessThan(baseline.itemCount));
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('CE dominance pruning preserves two slots on one fixed Grand servant', () {
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt).take(6).toList();
    final ces = db.gameData.craftEssencesById.values
        .where((c) => c.collectionNo > 0 && !c.isRegionSpecific)
        .take(5)
        .toList();
    final formation = BattleTeamSetup();
    for (var i = 0; i < 6; i++) {
      formation.svts[i] = PlayerSvtData.svt(servants[i]);
      if (i > 0) formation.svts[i].equip1 = SvtEquipData(ce: ces[i - 1]);
    }
    formation.svts[0].grandSvt = true;
    final extra = QuestPhaseExtraDetail()..setValue('isUseGrandBoard', 1);
    final quest = QuestPhase(bond: 1000, extraDetail: extra);
    final option = FormationBondOption(enableEvent: false);
    _withFilters(option, maxCost: 999, favoriteOnly: false, releaseReference: BondReleaseReference.jp, maxBond: 0);
    final baseline = FormationBondSolver.solve(
      option: option,
      quest: quest,
      formation: formation,
      pruneDominatedCes: false,
    );
    final pruned = FormationBondSolver.solve(option: option, quest: quest, formation: formation);
    expect(baseline.provenOptimal, isTrue);
    expect(pruned.provenOptimal, isTrue);
    expect(pruned.best!.totalBond, baseline.best!.totalBond);
    expect(pruned.ownedCeClassCount, lessThan(baseline.ownedCeClassCount));
    final applied = pruned.best!.applyTo(formation, option);
    final manual = calcFormationBondResults(option, quest, applied);
    expect(pruned.best!.totalBond, manual.fold<int>(0, (sum, slot) => sum + slot.totalBond));
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('two free positions have a proven maximum and manual-valid team', () {
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt).take(4).toList();
    final ces = db.gameData.craftEssencesById.values
        .where((c) => c.collectionNo > 0 && !c.isRegionSpecific)
        .take(4)
        .toList();
    final formation = BattleTeamSetup();
    for (var i = 0; i < 4; i++) {
      formation.svts[i] = PlayerSvtData.svt(servants[i])..equip1 = SvtEquipData(ce: ces[i]);
    }
    final option = FormationBondOption(enableEvent: false);
    final quest = QuestPhase(bond: 1000);
    final clock = Stopwatch()..start();
    final result = FormationBondSolver.solve(
      option: _withFilters(
        option,
        maxCost: 999,
        favoriteOnly: false,
        releaseReference: BondReleaseReference.jp,
        maxBond: 0,
      ),
      quest: quest,
      formation: formation,
    );
    print(
      'two-free solver: ${clock.elapsedMilliseconds}ms, ${result.visitedNodes} search steps, '
      'proven=${result.provenOptimal}, svt=${result.servantClassCount}, '
      'ce=${result.ownedCeClassCount}, profiles=${result.receiverProfileCount}, items=${result.itemCount}',
    );
    final winner = result.best;
    expect(winner, isNotNull);
    expect(result.provenOptimal, isTrue);
    final ids = [
      for (final slot in winner!.slots)
        if (slot.servantId != null) slot.servantId!,
    ];
    expect(ids.toSet().length, ids.length);
    for (final chosen in winner.slots.skip(4)) {
      if (chosen.servantId == null) continue;
      formation.svts[chosen.position] = PlayerSvtData.svt(db.gameData.servantsById[chosen.servantId]!)
        ..limitCount = chosen.limitCount!
        ..equip1 = SvtEquipData(
          ce: chosen.equip1 == null ? null : db.gameData.craftEssencesById[chosen.equip1!.id],
          limitBreak: chosen.equip1?.limitBreak ?? false,
        );
    }
    final manual = calcFormationBondResults(option, quest, formation);
    expect(winner.totalBond, manual.fold<int>(0, (v, slot) => v + slot.totalBond));
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('five free positions have a proven maximum and manual-valid team', () {
    final first = db.gameData.servantsById.values.firstWhere((s) => s.collectionNo > 0 && s.isUserSvt);
    final formation = BattleTeamSetup()..svts[0] = PlayerSvtData.svt(first);
    final option = FormationBondOption(enableEvent: false);
    final quest = QuestPhase(bond: 1000);
    final result = FormationBondSolver.solve(
      option: _withFilters(option, favoriteOnly: false, releaseReference: BondReleaseReference.jp, maxBond: 0),
      quest: quest,
      formation: formation,
    );
    print(
      'five-free solver: ${result.elapsedMilliseconds}ms, ${result.visitedNodes} search steps, '
      'best=${result.best?.totalBond}, proven=${result.provenOptimal}, items=${result.itemCount}, '
      'CE classes=${result.ownedCeClassCount}, placement invariant=${result.placementInvariantCeClassCount}, '
      'candidates=${result.candidates.length}',
    );
    expect(result.best, isNotNull);
    expect(result.provenOptimal, isTrue);
    expect(result.ownedCeClassCount, result.placementInvariantCeClassCount);
    final applied = result.best!.applyTo(formation, option);
    final manual = calcFormationBondResults(option, quest, applied);
    expect(result.best!.totalBond, manual.fold<int>(0, (sum, slot) => sum + slot.totalBond));
    expect(result.best!.totalCost, lessThanOrEqualTo(result.maxCost));
    expect(result.ties.length, greaterThan(1));
    expect(result.ties.length, lessThanOrEqualTo(20));
    expect(result.candidates.length, greaterThan(20));
    expect(result.candidates.length, lessThanOrEqualTo(option.maxCandidateTeams));
    for (var i = 1; i < result.candidates.length; i++) {
      expect(result.candidates[i].totalBond, lessThanOrEqualTo(result.candidates[i - 1].totalBond));
      if (result.candidates[i].totalBond == result.candidates[i - 1].totalBond) {
        expect(result.candidates[i].totalCost, lessThanOrEqualTo(result.candidates[i - 1].totalCost));
      }
    }
    for (final candidate in result.candidates) {
      expect(candidate.totalCost, lessThanOrEqualTo(result.maxCost));
      final ownedServants = candidate.slots
          .where((s) => !s.isSupport)
          .map((s) => s.servantId)
          .whereType<int>()
          .toList();
      expect(ownedServants.toSet().length, ownedServants.length);
      final ownedCes = candidate.slots
          .where((s) => !s.isSupport)
          .expand((s) => [s.equip1?.id, s.equip3?.id])
          .whereType<int>()
          .toList();
      expect(ownedCes.toSet().length, ownedCes.length);
    }
    final signatures = <String>{};
    for (final team in result.ties) {
      expect(team.totalBond, result.best!.totalBond);
      expect(team.totalCost, lessThanOrEqualTo(result.maxCost));
      final ids = team.slots.where((slot) => !slot.isSupport).map((slot) => slot.servantId).whereType<int>().toList();
      expect(ids.toSet().length, ids.length);
      final ceIds = team.slots
          .where((slot) => !slot.isSupport)
          .expand((slot) => [slot.equip1?.id, slot.equip3?.id])
          .whereType<int>()
          .toList();
      expect(ceIds.toSet().length, ceIds.length);
      expect(
        signatures.add(
          team.slots
              .map((slot) => '${slot.servantId}:${slot.limitCount}:${slot.equip1?.id}:${slot.equip3?.id}')
              .join('|'),
        ),
        isTrue,
      );
      final candidateOption = FormationBondOption.fromJson(option.toJson());
      final candidate = team.applyTo(formation, candidateOption);
      final checked = calcFormationBondResults(candidateOption, quest, candidate);
      expect(checked.fold<int>(0, (sum, slot) => sum + slot.totalBond), team.totalBond);
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('CE-first search agrees with the exhaustive general search on small real-data pools', () {
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt).take(14).toList();
    final allCes = db.gameData.craftEssencesById.values.toList();
    final bondCes = allCes
        .where(
          (ce) =>
              ce.collectionNo > 0 &&
              ce
                  .getActivatedSkills(true)
                  .values
                  .expand((skills) => skills)
                  .any((skill) => skill.functions.any((func) => func.funcType == FuncType.servantFriendshipUp)),
        )
        .take(7)
        .toList();
    final fillers = allCes
        .where(
          (ce) =>
              ce.collectionNo > 0 &&
              !ce
                  .getActivatedSkills(true)
                  .values
                  .expand((skills) => skills)
                  .any((skill) => skill.functions.any((func) => func.funcType == FuncType.servantFriendshipUp)),
        )
        .take(4)
        .toList();
    expect(servants.length, 14);
    expect(bondCes.length, 7);
    expect(fillers.length, 4);
    final availableSvts = servants.skip(4).map((s) => s.id).toSet();
    final availableCes = bondCes.map((ce) => ce.id).toSet();
    final excludedSvts = db.gameData.servantsById.keys.toSet().difference(availableSvts);
    final excludedCes = db.gameData.craftEssencesById.keys.toSet().difference(availableCes);
    for (var trial = 0; trial < 12; trial++) {
      final formation = BattleTeamSetup();
      for (var i = 0; i < 4; i++) {
        formation.svts[i] = PlayerSvtData.svt(servants[i])..equip1 = SvtEquipData(ce: fillers[i]);
      }
      final option = FormationBondOption(
        enableEvent: false,
        frontlineBonus: trial.isEven,
        maxCost: trial == 0
            ? 100000
            : trial < 4
            ? 999
            : trial < 8
            ? 65
            : 45,
        favoriteOnly: false,
        releaseReference: BondReleaseReference.jp,
        maxBond: 0,
        excludedSvts: Set.of(excludedSvts),
        excludedCes: Set.of(excludedCes),
      );
      QuestPhase quest = QuestPhase(bond: 1000);
      if (trial % 4 == 1) {
        formation.svts[4].equip1 = SvtEquipData(ce: bondCes.first, limitBreak: true);
      } else if (trial % 4 == 2) {
        formation.svts[0]
          ..grandSvt = true
          ..equip3 = SvtEquipData();
        final extra = QuestPhaseExtraDetail()..setValue('isUseGrandBoard', 1);
        quest = QuestPhase(bond: 1000, extraDetail: extra);
      } else if (trial % 4 == 3) {
        formation.svts[0] = PlayerSvtData.base()..supportType = SupportSvtType.friend;
      }
      final fast = FormationBondSolver.solve(option: option, quest: quest, formation: formation);
      final exhaustive = FormationBondSolver.solve(
        option: option,
        quest: quest,
        formation: formation,
        useCeFirst: false,
      );
      expect(fast.provenOptimal, isTrue, reason: 'trial $trial fast');
      expect(exhaustive.provenOptimal, isTrue, reason: 'trial $trial exhaustive');
      expect(fast.best?.totalBond, exhaustive.best?.totalBond, reason: 'trial $trial');
      for (final team in exhaustive.ties.take(5)) {
        expect(team.totalBond, exhaustive.best!.totalBond, reason: 'trial $trial alternative');
        final candidateOption = FormationBondOption.fromJson(option.toJson());
        final candidate = team.applyTo(formation, candidateOption);
        final checked = calcFormationBondResults(candidateOption, quest, candidate);
        expect(checked.fold<int>(0, (sum, slot) => sum + slot.totalBond), team.totalBond);
      }
      if (fast.best != null) {
        final applied = fast.best!.applyTo(formation, option);
        final manual = calcFormationBondResults(option, quest, applied);
        expect(fast.best!.totalBond, manual.fold<int>(0, (sum, slot) => sum + slot.totalBond));
        expect(
          fast.best!.slots.where((slot) => slot.servantId != null).map((slot) => slot.servantId).toSet().length,
          fast.best!.slots.where((slot) => slot.servantId != null).length,
        );
      }
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('progressive search emits a feasible candidate and a proven result', () async {
    final first = db.gameData.servantsById.values.firstWhere((s) => s.collectionNo > 0 && s.isUserSvt);
    final formation = BattleTeamSetup()..svts[0] = PlayerSvtData.svt(first);
    final option = FormationBondOption(enableEvent: false);
    final quest = QuestPhase(bond: 1000);
    final updates = await FormationBondSolver.solveProgressively(
      option: _withFilters(option, favoriteOnly: false, releaseReference: BondReleaseReference.jp, maxBond: 0),
      quest: quest,
      formation: formation,
    ).toList();
    expect(updates, isNotEmpty);
    final candidate = updates.firstWhere((update) => update.best != null);
    expect(candidate.provenOptimal, isFalse);
    expect(updates.last.provenOptimal, isTrue);
    expect(updates.last.best!.totalBond, greaterThanOrEqualTo(candidate.best!.totalBond));
    final applied = updates.last.best!.applyTo(formation, option);
    final manual = calcFormationBondResults(option, quest, applied);
    expect(updates.last.best!.totalBond, manual.fold<int>(0, (sum, slot) => sum + slot.totalBond));
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('a fixed event CE keeps its wearer-only bond effect', () {
    final quest = QuestPhase(warId: 8385, bond: 1000);
    expect(quest.logicEventId, 80432);
    final eventCe = db.gameData.craftEssencesById[9407110]!;
    final servants = db.gameData.servantsById.values.where((s) => s.collectionNo > 0 && s.isUserSvt).take(6).toList();
    final fillers = db.gameData.craftEssencesById.values
        .where(
          (ce) =>
              ce.collectionNo > 0 &&
              ce.id != eventCe.id &&
              !ce
                  .getActivatedSkills(true)
                  .values
                  .expand((v) => v)
                  .any((skill) => skill.functions.any((func) => func.funcType == FuncType.servantFriendshipUp)),
        )
        .take(5)
        .toList();
    final formation = BattleTeamSetup();
    for (var i = 0; i < 6; i++) {
      formation.svts[i] = PlayerSvtData.svt(servants[i])
        ..equip1 = SvtEquipData(ce: i == 0 ? eventCe : fillers[i - 1], limitBreak: true);
    }
    final option = FormationBondOption(enableEvent: false, frontlineBonus: false);
    final manual = calcFormationBondResults(option, quest, formation);
    expect(manual.first.totalBond, greaterThan(manual[1].totalBond));
    final solved = FormationBondSolver.solve(
      option: _withFilters(
        option,
        maxCost: 999,
        favoriteOnly: false,
        releaseReference: BondReleaseReference.jp,
        maxBond: 0,
      ),
      quest: quest,
      formation: formation,
    );
    expect(solved.provenOptimal, isTrue);
    expect([for (final slot in solved.best!.slots) slot.bond], [for (final slot in manual) slot.totalBond]);
  }, timeout: const Timeout(Duration(minutes: 2)));
}
