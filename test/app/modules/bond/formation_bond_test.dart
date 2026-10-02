import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/app/modules/battle/formation/team.dart';
import 'package:chaldea/app/modules/bond/formation_bond.dart';
import 'package:chaldea/app/modules/bond/solver/solver.dart';
import 'package:chaldea/app/modules/bond/solver/widgets.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';

void main() {
  setUpAll(() async {
    await S.load(const Locale('en'));
    await db.initiateForTest(testAppPath: const String.fromEnvironment('APP_PATH'));
    db.gameData = (await GameDataLoader.instance.reload(offline: true, silent: true))!;
  });

  test('solver settings belong to the formation option', () {
    final first = User();
    final second = User();
    expect(first.formationBondOption.maxCost, isNull);
    expect(second.formationBondOption.maxCost, isNull);
    expect(first.formationBondOption, isNot(same(second.formationBondOption)));

    first.formationBondOption
      ..maxCost = 120
      ..maxCandidateTeams = 60
      ..excludedSvts.add(100100);
    final restored = User.fromJson(first.toJson());
    expect(restored.formationBondOption.maxCost, 120);
    expect(restored.formationBondOption.maxCandidateTeams, 60);
    expect(restored.formationBondOption.excludedSvts, {100100});
    expect(second.formationBondOption.maxCost, isNull);
  });

  test('empty support slot survives formation serialization', () {
    final team = BattleTeamSetup();
    team.svts[2].supportType = SupportSvtType.friend;
    final saved = team.toFormationData();
    expect(saved.svts[2]?.supportType, SupportSvtType.friend);
    final restored = BattleTeamFormation.fromJson(saved.toJson());
    expect(restored.svts[2]?.supportType, SupportSvtType.friend);
    expect(restored.svts[2]?.svtId, isNull);
  });

  test('formation draft copies a fixed CE independently', () {
    final source = FormationBondOption(
      maxCost: 120,
      excludedSvts: {100100},
      teamFormation: BattleTeamFormation(
        svts: [
          SvtSaveData(equip1: SvtEquipSaveData(id: 9401060)),
          null,
          null,
          null,
          null,
          null,
        ],
      ),
    );
    final draft = FormationBondOption.fromJson(source.toJson());
    expect(draft.teamFormation.svts[0]?.equip1.id, 9401060);
    draft.teamFormation.svts[0]?.equip1.id = 9401061;
    draft.excludedSvts.add(100200);
    expect(source.teamFormation.svts[0]?.equip1.id, 9401060);
    expect(source.excludedSvts, {100100});
  });

  testWidgets('team page shows quest before formation and solver below shared settings', (tester) async {
    final quest = db.gameData.questPhases.values.firstWhere((phase) => phase.bond > 0);
    final supplied = FormationBondOption(quest: BattleQuestInfo.quest(quest));
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [S.delegate, ...GlobalMaterialLocalizations.delegates],
        home: Scaffold(body: FormationBondTab(option: supplied)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining(quest.lNameWithChapter), findsOneWidget);
    expect(find.textContaining('Base ${S.current.bond}: ${quest.bond}'), findsOneWidget);
    expect(find.byType(TeamSetupCard), findsOneWidget);
    expect(find.text('Solve max bond'), findsNothing);
    await tester.scrollUntilVisible(find.text('Solve max bond'), 300);
    expect(find.text('Favorite servants only'), findsWidgets);
    expect(find.text('Excluded craft essences'), findsWidgets);
    expect(supplied.quest!.id, quest.id);
  });

  testWidgets('user option is shared directly and receives filter edits', (tester) async {
    final user = db.userData.curUser;
    final oldFormation = user.formationBondOption;
    user.formationBondOption = FormationBondOption();
    final stored = user.formationBondOption;
    addTearDown(() => user.formationBondOption = oldFormation);

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [S.delegate, ...GlobalMaterialLocalizations.delegates],
        home: Scaffold(body: FormationBondTab()),
      ),
    );
    await tester.pumpAndSettle();
    final team = tester.widget<TeamSetupCard>(find.byType(TeamSetupCard)).formation;
    expect(team.svts[2].supportType, SupportSvtType.friend);
    expect(stored.teamFormation.svts[2]?.supportType, SupportSvtType.friend);
    await tester.scrollUntilVisible(find.text('Favorite servants only'), 250);
    await tester.tap(find.text('Favorite servants only'));
    await tester.pump();
    expect(user.formationBondOption, same(stored));
    expect(stored.favoriteOnly, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Solve saves user-backed options before searching', (tester) async {
    final user = db.userData.curUser;
    final oldFormation = user.formationBondOption;
    final quest = QuestPhase(id: 987654321, name: 'Solver test quest', bond: 1000);
    final url = AtlasApi.questPhaseUrl(quest.id, quest.phase, null, Region.jp);
    AtlasApi.cachedQuestPhases[url] = quest;
    user.formationBondOption = FormationBondOption(quest: BattleQuestInfo.quest(quest), maxCost: 120);
    addTearDown(() {
      user.formationBondOption = oldFormation;
      AtlasApi.cachedQuestPhases.remove(url);
    });

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [S.delegate, ...GlobalMaterialLocalizations.delegates],
        home: Scaffold(body: FormationBondTab()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Solve max bond'), 300);
    await tester.tap(find.text('Solve max bond'));
    await tester.pump();
    expect(user.formationBondOption.quest?.id, quest.id);
    expect(user.formationBondOption.maxCost, 120);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('supplied option is used directly without changing the user option', (tester) async {
    final user = db.userData.curUser;
    final oldFormation = user.formationBondOption;
    user.formationBondOption = FormationBondOption(maxCost: 123);
    final stored = user.formationBondOption;
    addTearDown(() => user.formationBondOption = oldFormation);
    final supplied = FormationBondOption.fromJson(stored.toJson())..maxCost = 999;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [S.delegate, ...GlobalMaterialLocalizations.delegates],
        home: Scaffold(body: FormationBondTab(option: supplied)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Max COST'), 250);
    expect(find.textContaining('999/'), findsWidgets);
    final frontline = find.text('${S.current.bond_bonus}: ${S.current.team_starting_member}');
    await tester.ensureVisible(frontline);
    await tester.tap(frontline);
    await tester.pump();
    expect(supplied.frontlineBonus, isFalse);
    expect(user.formationBondOption, same(stored));
    expect(stored.frontlineBonus, isTrue);
    expect(stored.maxCost, 123);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('results show ranked candidates from multiple score groups', (tester) async {
    const first = BondSolvedTeam(1000, 70, []);
    const second = BondSolvedTeam(1000, 65, []);
    const third = BondSolvedTeam(950, 60, []);
    const result = BondSolverResult(
      best: first,
      ties: [first, second],
      candidates: [first, second, third],
      tieGroupCounts: [],
      provenOptimal: true,
      allTiesCollected: false,
      visitedNodes: 2,
      elapsedMilliseconds: 1,
      maxCost: 108,
      fixedCost: 0,
      servantClassCount: 0,
      ownedCeClassCount: 0,
      placementInvariantCeClassCount: 0,
      receiverProfileCount: 0,
      itemCount: 0,
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [S.delegate, ...GlobalMaterialLocalizations.delegates],
        home: Scaffold(
          body: SingleChildScrollView(
            child: BondSolverResults(
              solved: result,
              formation: BattleTeamSetup(),
              option: FormationBondOption(),
              quest: QuestPhase(id: 987654321, name: 'Result display', bond: 1000),
              solving: false,
              visibleCandidateCount: 5,
              onShowMore: () {},
              onShowFewer: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Team 1: 1000'), findsOneWidget);
    expect(find.text('Team 2: 1000'), findsOneWidget);
    expect(find.text('Team 3: 950'), findsOneWidget);
    expect(find.textContaining('3/100 feasible teams found'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
