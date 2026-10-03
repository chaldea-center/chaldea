import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/app/modules/bond/bond_rules.dart';
import 'package:chaldea/app/modules/bond/formation_bond.dart';
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
    favoriteOnly: false,
    maxBond: 0,
    maxCost: 999,
  );
  final quest = QuestPhase(bond: 1000);
  List<CraftEssence> fillers() => db.gameData.craftEssencesById.values
      .where((ce) => ce.collectionNo > 0 && extractCeBondEffects(ce, true, quest, support: false).isEmpty)
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
      final manual = calcFormationBondResults(option, phase, applied);
      expect(team.slots.map((s) => s.bond).toList(), manual.map((s) => s.totalBond).toList());
      final cost = applied.totalCost;
      expect(team.totalCost, cost);
    }
  }

  test('FSN family has identical effects, shared exclusions and leaves collection 1972 alone', () {
    final family = BondCeIdentity.families.single;
    expect(BondCeIdentity.of(9308080), 9308080);
    final reference = extractCeBondEffects(db.gameData.craftEssencesById[family.first]!, true, quest, support: false);
    for (final id in family) {
      expect(BondCeIdentity.of(id), family.first);
      expect(BondCeIdentity.excluded(id, {family.last}), isTrue);
      final effects = extractCeBondEffects(db.gameData.craftEssencesById[id]!, true, quest, support: false);
      expect(
        effects.map((e) => '${e.rate}:${e.value}:${e.targetPartial}:${e.targetOrAll}').toList(),
        reference.map((e) => '${e.rate}:${e.value}:${e.targetPartial}:${e.targetOrAll}').toList(),
      );
    }
  });

  test('different fixed family IDs conflict but support may repeat and exclusions preserve pins', () {
    final team = formation();
    team.svts[0].equip1 = SvtEquipData(ce: db.gameData.craftEssencesById[9308110], limitBreak: true);
    team.svts[1].equip1 = SvtEquipData(ce: db.gameData.craftEssencesById[9308120], limitBreak: true);
    for (final fast in [false, true]) {
      expect(solve(team, options(), fast: fast).best, isNull);
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

  test('free family is one canonical wear and excluding any member excludes all', () {
    final team = formation();
    for (var p = 0; p < 3; p++) {
      team.svts[p].equip1 = SvtEquipData();
    }
    final family = BondCeIdentity.families.single.toSet();
    final option = options()..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..removeAll(family));
    for (final fast in [false, true]) {
      final result = solve(team, option, fast: fast);
      final worn = result.best!.slots.where((s) => family.contains(s.equip1?.id)).toList();
      expect(worn, hasLength(1));
      expect(worn.single.equip1!.id, family.first);
      checkScores(result, team, option, quest);
      final excluded = FormationBondOption.fromJson(option.toJson())..excludedCes.add(family.last);
      expect(solve(team, excluded, fast: fast).best!.slots.where((s) => family.contains(s.equip1?.id)), isEmpty);
    }
  });

  test('generic CEs use smallest available IDs and display later IDs first', () {
    final ces = db.gameData.craftEssencesById.values.where((ce) {
      if (ce.collectionNo <= 0 || ce.isRegionSpecific) return false;
      final effects = extractCeBondEffects(ce, true, quest, support: false);
      final support = extractCeBondEffects(ce, true, quest, support: true);
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
    final option = options()
      ..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..removeAll(sameCost.map((ce) => ce.id)));
    for (final fast in [false, true]) {
      final result = solve(team, option, fast: fast);
      for (final candidate in result.candidates.where((team) => team.totalBond == result.best!.totalBond)) {
        expect(candidate.slots.take(2).map((s) => s.equip1?.id).toList(), [sameCost[1].id, sameCost[0].id]);
      }
      final excluded = FormationBondOption.fromJson(option.toJson())..excludedCes.add(sameCost.first.id);
      expect(solve(team, excluded, fast: fast).best!.slots.take(2).map((s) => s.equip1?.id).toList(), [
        sameCost[2].id,
        sameCost[1].id,
      ]);
      checkScores(result, team, option, quest);
    }
  });

  test('mixed free CEs sort by traits, rate and ID while support and pins stay fixed', () {
    final flat = db.gameData.craftEssencesById.values.where((ce) {
      if (ce.collectionNo <= 0 || ce.isRegionSpecific) return false;
      final own = extractCeBondEffects(ce, true, quest, support: false);
      final support = extractCeBondEffects(ce, true, quest, support: true);
      return own.length == 1 &&
          own.single.isFlat &&
          own.single.rate == 50 &&
          own.single.value == 0 &&
          support.length == 1 &&
          support.single.rate == 50;
    }).toList()..sort((a, b) => a.id.compareTo(b.id));
    final generic = flat.where((ce) => ce.cost == flat.first.cost).take(2).toList();
    final fsnEffects = extractCeBondEffects(db.gameData.craftEssencesById[9308100]!, true, quest, support: false);
    final fsn = db.gameData.servantsById.values.firstWhere(
      (svt) =>
          svt.isUserSvt &&
          svt.collectionNo > 0 &&
          fsnEffects.any((effect) => effect.targetMatches(svt.getIndividuality(0, 4))),
    );
    final team = formation(first: fsn);
    for (var p = 0; p < 4; p++) {
      team.svts[p].equip1 = SvtEquipData();
    }
    final pinned = team.svts[4].equip1.ce!.id;
    team.svts[5].supportType = SupportSvtType.friend;
    final supportId = team.svts[5].equip1.ce!.id;
    final pool = {...BondCeIdentity.families.single, 9401060, ...generic.map((ce) => ce.id)};
    final option = options()..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..removeAll(pool));
    final expected = [9308100, generic[1].id, generic[0].id, 9401060];
    for (final fast in [false, true]) {
      final result = solve(team, option, fast: fast);
      expect(result.best!.slots.take(4).map((s) => s.equip1?.id).toList(), expected);
      expect(result.best!.slots[4].equip1!.id, pinned);
      expect(result.best!.slots[5].equip1!.id, supportId);
      checkScores(result, team, option, quest);
    }
    final original = db.gameData.craftEssencesById;
    try {
      db.gameData.craftEssencesById = Map.fromEntries(original.entries.toList().reversed);
      expect(solve(team, option).best!.slots.take(4).map((s) => s.equip1?.id).toList(), expected);
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
      expect(solve(team, options(), phase: phase, fast: fast).best, isNull);
      team.svts[0].equip3 = SvtEquipData();
      final option = options()
        ..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..removeAll(BondCeIdentity.families.single));
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
        final effects = extractCeBondEffects(ce, true, quest, support: false);
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
      validateFormationBondOption(option, phase);
      expect(option.releaseReference, BondReleaseReference.jp);
      expect(BondReleaseRules.resolve(BondReleaseReference.questClosedAt, phase), BondReleaseReference.jp);
    }
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
      ..excludedCes = (db.gameData.craftEssencesById.keys.toSet()..remove(ce.id));
    team.svts[0].svt = null;
    team.svts[0].equip1 = SvtEquipData();
    for (final reference in [BondReleaseReference.jp, BondReleaseReference.cn, BondReleaseReference.na]) {
      option.releaseReference = reference;
      final result = solve(team, option);
      expect(result.best!.slots[0].servantId, target.id);
      expect(result.best!.slots[0].equip1?.id, reference == BondReleaseReference.cn ? null : ce.id);
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
      (ce) => extractCeBondEffects(ce, true, quest, support: false).any(
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
}
