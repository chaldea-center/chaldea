import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/app/modules/bond/bond_rules.dart';
import 'package:chaldea/app/modules/bond/formation_bond_calc.dart';
import 'package:chaldea/app/modules/bond/solver/solver.dart';
import 'package:chaldea/models/models.dart';

import '../../test/test_init.dart';

void main() {
  test('current solver whole-request benchmark', () async {
    await initiateForTest();
    const repeats = int.fromEnvironment('BOND_BENCH_REPEATS', defaultValue: 5);
    const warmups = int.fromEnvironment('BOND_BENCH_WARMUPS', defaultValue: 2);
    const candidates = int.fromEnvironment('BOND_BENCH_CANDIDATES', defaultValue: 1);
    const budget = int.fromEnvironment('BOND_BENCH_MAX_NODES', defaultValue: -1);
    final fingerprints = <String, String>{};
    for (var repeat = -warmups; repeat < repeats; repeat++) {
      for (final (count, grand) in [(3, false), (5, false), (6, false), (6, true)]) {
        final formation = BattleTeamSetup();
        if (grand) {
          for (var p = 0; p < 3; p++) {
            formation.svts[p] = PlayerSvtData.svt(db.gameData.servantsById[[100100, 200100, 300100][p]]!)
              ..grandSvt = true;
          }
          for (var p = 3; p < 6; p++) {
            formation.svts[p]
              ..supportType = SupportSvtType.friend
              ..grandSvt = true;
          }
        } else {
          formation.svts[2].supportType = SupportSvtType.friend;
        }
        final quest = grand
            ? QuestPhase(bond: 1000, extraDetail: QuestPhaseExtraDetail()..setValue('isUseGrandBoard', 1))
            : db.gameData.getQuestPhase(94137202, 1)!;
        final option = FormationBondOption(enableEvent: false, favoriteSvtOnly: false, favoriteSvtEquipOnly: false)
          ..maxServants = count
          ..maxCost = 113
          ..maxCandidateTeams = candidates
          ..searchFixedAscensions = !grand;
        final timer = Stopwatch()..start();
        final result = FormationBondSolver.solve(
          option: option,
          quest: quest,
          formation: formation,
          maxNodes: budget < 0 ? null : budget,
          maxTies: 1,
        );
        final microseconds = timer.elapsedMicroseconds;
        final teams = [if (result.best != null) result.best!, ...result.ties, ...result.candidates];
        for (final team in teams) {
          final applied = team.applyTo(formation, option);
          final manual = option.calcResults(quest, applied).take(count).map((slot) => slot.totalBond).toList();
          expect(team.slots.map((slot) => slot.bond).toList(), manual);
          expect(team.totalCost, applied.totalCost);
          expect(team.totalCost, lessThanOrEqualTo(113));
          final servants = <int>{}, ownedCes = <int>{};
          for (final slot in team.slots) {
            if (!slot.isSupport && slot.servantId != null) expect(servants.add(slot.servantId!), isTrue);
            final identities = slot.isSupport ? <int>{} : ownedCes;
            for (final ce in [slot.equip1, slot.equip3]) {
              if (ce != null && BondCeIdentity.requiresUniqueOwnedIdentity(db.gameData.craftEssencesById[ce.id]!)) {
                expect(identities.add(BondCeIdentity.of(ce.id)), isTrue);
              }
            }
          }
        }
        final witness = [
          for (final team in teams)
            [
              team.totalBond,
              team.totalCost,
              for (final slot in team.slots)
                [
                  slot.position,
                  slot.servantId,
                  slot.limitCount,
                  slot.bond,
                  slot.cost,
                  slot.equip1?.id,
                  slot.equip1?.limitBreak,
                  slot.equip3?.id,
                  slot.equip3?.limitBreak,
                ],
            ],
        ];
        final fingerprint = sha256.convert(utf8.encode(jsonEncode(witness))).toString();
        final key = '$count/$grand';
        expect(fingerprint, fingerprints.putIfAbsent(key, () => fingerprint));
        if (budget < 0) expect(result.provenOptimal, isTrue);
        if (repeat >= 0) {
          print(
            'BENCH ${jsonEncode({'repeat': repeat, 'slots': count, 'grand': grand, 'candidateLimit': candidates, 'budget': budget, 'microseconds': microseconds, 'nodes': result.visitedNodes, 'proven': result.provenOptimal, 'score': result.best?.totalBond, 'cost': result.best?.totalCost, 'candidates': result.candidates.length, 'ceFirst': result.isCeFirst, 'combinations': result.possibleCombinations, 'witnessSha256': fingerprint, 'processRss': ProcessInfo.currentRss, 'processPeakRss': ProcessInfo.maxRss})}',
          );
        }
      }
    }
  }, timeout: const Timeout(Duration(minutes: 10)));
}
