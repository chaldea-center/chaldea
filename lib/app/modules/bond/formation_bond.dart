import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/craft_essence/craft_list.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../battle/formation/team.dart';
import 'bond_rules.dart';
import 'formation_bond_calc.dart';
import 'solver/results.dart';
import 'solver/solver.dart';

/// Runtime state for the page. The persisted settings live in [FormationBondOption].
class _FormationBondRuntime {
  _FormationBondRuntime({required this.userBacked});

  final bool userBacked;
  bool restored = false;
  BondSolverResult? solverResult;
  QuestPhase? resultQuest;
  String? solverError;
  bool solving = false;
  StreamSubscription<BondSolverResult>? search;
  int searchRevision = 0;
  int lastDebugSecond = -1;

  void stopSearch() {
    searchRevision++;
    search?.cancel();
  }

  void clearResults() {
    solverResult = null;
    resultQuest = null;
    solverError = null;
    solving = false;
  }

  void logProgress(BondSolverResult solved) {
    if (!kDebugMode) return;
    final second = solved.elapsedMilliseconds ~/ 1000;
    if (second == lastDebugSecond && !solved.provenOptimal) return;
    lastDebugSecond = second;
    debugPrint(
      '[BondSolver] ${solved.possibleCombinations == null ? "general" : "CE-first"} '
      'elapsed=${solved.elapsedMilliseconds}ms steps=${solved.visitedNodes}'
      '${solved.possibleCombinations == null ? "" : "/${solved.possibleCombinations}"} '
      'best=${solved.best?.totalBond} proven=${solved.provenOptimal}',
    );
  }

  String get status {
    final solved = solverResult;
    if (solving) {
      if (solved == null) return 'Preparing search candidates…';
      if (solved.provenOptimal) return 'Maximum proven; collecting equal-score groups…';
      if (solved.best == null) return 'Searching for a feasible team…';
      return 'Best team found; still proving the maximum…';
    }
    if (solverError != null) return 'Search failed';
    if (solved == null) return 'Ready to search';
    if (solved.provenOptimal) {
      return solved.allTiesCollected ? 'Maximum proven' : 'Maximum proven · equal-score groups may be incomplete';
    }
    return 'Stopped · Maximum not proven';
  }
}

class FormationBondPage extends StatefulWidget {
  /// Callers supply a temporary option if edits must not affect the current user.
  final FormationBondOption? option;
  const FormationBondPage({super.key, this.option});

  @override
  State<FormationBondPage> createState() => _FormationBondPageState();
}

class _FormationBondPageState extends State<FormationBondPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);
  late final User _user = db.userData.curUser;
  late final FormationBondOption option = widget.option ?? _user.formationBondOption;
  late final _FormationBondRuntime _runtime = _FormationBondRuntime(userBacked: widget.option == null);
  // runtime formation, converted from/to [FormationBondOption.teamFormation] on load/save
  final BattleTeamSetup formation = BattleTeamSetup();
  QuestPhase? questEntity;

  void updateSharedInput(VoidCallback change) {
    if (!mounted) return;
    final hadSearch = _runtime.solving || _runtime.solverResult != null;
    _runtime.stopSearch();
    setState(() {
      change();
      _runtime.clearResults();
    });
    if (hadSearch) EasyLoading.showToast('Search results are outdated. Solve again.');
  }

  @override
  void initState() {
    super.initState();
    if (_runtime.userBacked && option.teamFormation.svts.every((svt) => svt == null)) {
      option.teamFormation.svts[2] = SvtSaveData(supportType: SupportSvtType.friend);
    }
    restore();
  }

  /// Restore the two non-JSON runtime values (team setup, quest entity) from the option.
  /// Quest resolution falls back to network; on failure the quest is cleared but other settings kept.
  Future<void> restore() async {
    final questInfo = option.quest;
    if (questInfo != null) {
      questEntity =
          db.gameData.getQuestPhase(questInfo.id, questInfo.phase) ??
          await AtlasApi.questPhase(questInfo.id, questInfo.phase);
      if (questEntity == null) option.quest = null;
    }

    final saved = option.teamFormation;
    final svts = <PlayerSvtData>[];
    for (int index = 0; index < max(6, saved.svts.length); index++) {
      svts.add(await PlayerSvtData.fromStoredData(saved.svts.getOrNull(index)));
    }
    formation.svts
      ..clear()
      ..addAll(svts);
    formation.mysticCodeData.loadStoredData(saved.mysticCode);
    _runtime.restored = true;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _runtime.stopSearch();
    _tabController.dispose();
    if (_runtime.restored) saveData();
    super.dispose();
  }

  /// Persist runtime formation/quest into the option supplied to this page.
  void saveData() {
    option.teamFormation = formation.toFormationData();
    option.quest = questEntity == null ? null : BattleQuestInfo.quest(questEntity!);
  }

  void validate() {
    option.validate(questEntity);
  }

  List<SvtBondBonusResult> calcResults() => option.calcResults(questEntity, formation);

  String strTime(int t) => t.sec2date().toStringShort(omitSec: true);

  String _strRate(int value) => value.format(percent: true, base: 10);

  FormationBondOption _buildSolverRequest(QuestPhase quest, BattleTeamSetup team) {
    final solveOption = FormationBondOption.fromJson(option.toJson());
    solveOption.validate(quest);
    solveOption
      ..quest = BattleQuestInfo.quest(quest)
      ..teamFormation = team.toFormationData();
    return solveOption;
  }

  Future<void> solve() async {
    if (!_runtime.restored) return;
    final selectedQuest = questEntity;
    if (selectedQuest == null) {
      setState(() => _runtime.solverError = 'Select a quest first');
      return;
    }
    if (_runtime.userBacked && db.userData.curUser.id != _user.id) {
      setState(() => _runtime.solverError = 'The active user changed. Reopen this page before solving.');
      return;
    }
    final revision = ++_runtime.searchRevision;
    await _runtime.search?.cancel();
    if (!mounted || revision != _runtime.searchRevision) return;
    setState(() {
      _runtime.clearResults();
      _runtime.solving = true;
    });
    _tabController.animateTo(1);
    // Defer preparation until the tab transition has painted.
    await Future<void>.delayed(_tabController.animationDuration);
    if (!mounted || revision != _runtime.searchRevision) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || revision != _runtime.searchRevision) return;
    if (_runtime.userBacked && db.userData.curUser.id != _user.id) {
      setState(() {
        _runtime.solving = false;
        _runtime.solverError = 'The active user changed. Reopen this page before solving.';
      });
      return;
    }
    // Selection/restoration resolves missing phases before Solve is available.
    // Bundled phases are authoritative, including Grand Board restrictions.
    final solveQuest = db.gameData.getQuestPhase(selectedQuest.id, selectedQuest.phase) ?? selectedQuest;
    _runtime.resultQuest = solveQuest;
    final solveFormation = formation.copy();
    final solveOption = _buildSolverRequest(solveQuest, solveFormation);
    if (_runtime.userBacked) {
      saveData();
      await db.saveUserData();
    }
    if (!mounted || revision != _runtime.searchRevision) return;
    _runtime.lastDebugSecond = -1;
    if (kDebugMode) debugPrint('[BondSolver] search started: quest ${solveQuest.id}/${solveQuest.phase}');
    _runtime.search =
        FormationBondSolver.solveProgressively(
          option: solveOption,
          quest: solveQuest,
          formation: solveFormation,
        ).listen(
          (solved) {
            if (!mounted || revision != _runtime.searchRevision) return;
            setState(() => _runtime.solverResult = solved);
            _runtime.logProgress(solved);
          },
          onError: (Object e) {
            if (!mounted || revision != _runtime.searchRevision) return;
            setState(() {
              _runtime.solverError = e.toString();
              _runtime.solving = false;
            });
            if (kDebugMode) debugPrint('[BondSolver] search failed: $e');
          },
          onDone: () {
            if (!mounted || revision != _runtime.searchRevision) return;
            setState(() => _runtime.solving = false);
            if (kDebugMode) debugPrint('[BondSolver] search finished: proven=${_runtime.solverResult?.provenOptimal}');
          },
        );
  }

  void cancelSolve() {
    _runtime.stopSearch();
    if (kDebugMode) debugPrint('[BondSolver] search cancelled: proven=${_runtime.solverResult?.provenOptimal}');
    setState(() => _runtime.solving = false);
  }

  void _editNumber({
    required String title,
    required int? initial,
    required void Function(int) update,
    String? hintText,
  }) {
    InputCancelOkDialog.number(
      title: title,
      initValue: initial,
      validate: (v) => v >= 0,
      onSubmit: (v) => updateSharedInput(() => update(v)),
      hintText: hintText,
    ).showDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_runtime.userBacked && db.userData.curUser.id != _user.id) {
      return Scaffold(
        appBar: AppBar(title: const Text('Formation Bond')),
        body: const Center(child: Text('The active user changed. Reopen Formation Bond to load this user’s team.')),
      );
    }
    final quest = questEntity;
    final eventId = quest?.logicEventId;
    final eventSkillIds = {
      if (eventId != null)
        for (final svt in db.gameData.servantsNoDup.values)
          for (final skill in svt.extraPassive)
            if (skill.functions.any((e) => e.funcType == FuncType.servantFriendshipUp))
              for (final extraPassive in skill.extraPassive)
                if (extraPassive.getValidEventIds().contains(eventId)) skill.id,
    }.toList()..sort();
    // A stored date reference must survive until its quest finishes restoring.
    if (_runtime.restored) validate();
    final results = calcResults();
    // resolve id/idx-keyed campaigns into runtime Event/EventCampaign instances
    final eventCampaignToggles = <(Event, EventCampaign, bool)>[];
    for (final (eventId, eventCampaigns) in option.campaigns.items) {
      final event = db.gameData.events[eventId];
      if (event == null) continue;
      for (final (idx, enabled) in eventCampaigns.items) {
        final campaign = event.campaigns.firstWhereOrNull((e) => e.idx == idx);
        if (campaign == null) continue;
        eventCampaignToggles.add((event, campaign, enabled));
      }
    }
    final inputContent = ListView(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 12),
      children: [
        TileGroup(
          header: '${S.current.quest} / ${S.current.bond}',
          children: [
            _BondQuestPicker(quest: quest, onChanged: (v) => updateSharedInput(() => questEntity = v)),
            ListTile(
              dense: true,
              title: Text(
                '${S.current.time}(${S.current.servant}/${S.current.craft_essence_short}/${S.current.costume})',
              ),
              subtitle: option.releaseReference == BondReleaseReference.questClosedAt
                  ? Text(
                      'CE availability and costume traits currently use JP data.',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : null,
              trailing: DropdownButton<BondReleaseReference>(
                value: option.releaseReference,
                underline: const SizedBox.shrink(),
                items: [
                  for (final reference in BondReleaseReference.values)
                    DropdownMenuItem(
                      value: reference,
                      enabled:
                          reference != BondReleaseReference.questClosedAt || BondReleaseRules.hasClosingDate(quest),
                      child: Text(
                        reference == BondReleaseReference.questClosedAt
                            ? (BondReleaseRules.hasClosingDate(quest)
                                  ? Region.jp.getDateTimeByOffset(quest!.closedAt).toString().substring(0, 10)
                                  : S.current.date)
                            : reference.region.upper,
                      ),
                    ),
                ],
                onChanged: (reference) {
                  if (reference != null) updateSharedInput(() => option.releaseReference = reference);
                },
              ),
            ),
          ],
        ),
        TileGroup(
          header: S.current.team,
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
          children: [
            TeamSetupCard(
              formation: formation,
              quest: quest,
              playerRegion: Region.jp,
              onChanged: () => updateSharedInput(() {}),
            ),
          ],
        ),
        TileGroup(
          header: '${S.current.general_custom} / ${S.current.bond} 15 / ${S.current.bond_limit}',
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  for (final index in range(option.svtBonus.length))
                    Expanded(child: Center(child: buildExtraBonus(index))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  for (final index in range(results.length))
                    Expanded(child: Center(child: buildResult(index, results[index]))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text.rich(
                TextSpan(
                  text: '${S.current.total} ',
                  children: [
                    TextSpan(
                      text: Maths.sum(results.map((e) => e.totalBond)).toString(),
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    ),
                    const TextSpan(text: '  COST '),
                    TextSpan(
                      text: formation.totalCost.toString(),
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        TileGroup(
          header: '${S.current.bond_bonus} ${S.current.settings_tab_name}',
          children: [
            SimpleAccordion(
              headerBuilder: (context, expanded) => ListTile(
                dense: true,
                title: Text(S.current.event),
                subtitle: Text(
                  '${(option.enableEvent ? 1 : 0) + eventCampaignToggles.where((entry) => entry.$3).length}'
                  '/${eventCampaignToggles.length + 1} enabled',
                ),
              ),
              contentBuilder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile.adaptive(
                    dense: true,
                    title: Text(S.current.event_skill),
                    subtitle: eventSkillIds.isEmpty
                        ? null
                        : Text('${db.gameData.events[eventId]?.lShortName.l ?? eventId}'),
                    value: option.enableEvent,
                    onChanged: (v) => updateSharedInput(() => option.enableEvent = v),
                  ),
                  if (eventSkillIds.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final skillId in eventSkillIds)
                            Text.rich(
                              SharedBuilder.textButtonSpan(
                                context: context,
                                text: db.gameData.baseSkills[skillId]?.lName.l ?? skillId.toString(),
                                onTap: () => router.push(url: Routes.skillI(skillId)),
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  for (final (event, campaign, enabled) in eventCampaignToggles)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SwitchListTile.adaptive(
                            dense: true,
                            title: Text(event.lShortName.l),
                            subtitle: Text(
                              '${S.current.bond} ${campaign.calcType.operatorText}${campaign.value.format(percent: true, base: 10)}'
                              '\n${strTime(event.startedAt)}~${strTime(event.endedAt)}',
                            ),
                            value: enabled,
                            onChanged: (v) =>
                                updateSharedInput(() => (option.campaigns[event.id] ??= {})[campaign.idx] = v),
                          ),
                        ),
                        IconButton(
                          onPressed: event.routeTo,
                          icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            ListTile(
              dense: true,
              leading: Item.iconBuilder(
                context: context,
                item: null,
                itemId: Items.teapotId,
                width: 28,
                jumpToDetail: false,
              ),
              title: Text(Transl.itemNames('星見のティーポット').l),
              trailing: DropdownButton<int>(
                value: option.teapotTimes,
                items: [
                  for (final times in [1, 2, 3])
                    DropdownMenuItem(value: times, child: Text(times == 1 ? '--' : '×$times')),
                ],
                onChanged: (v) {
                  setState(() {
                    if (v != null) option.teapotTimes = v;
                  });
                },
              ),
            ),
            SwitchListTile.adaptive(
              dense: true,
              value: option.frontlineBonus,
              title: Text('${S.current.bond_bonus}: ${S.current.team_starting_member}'),
              subtitle: Text(
                '${Transl.funcTargetType(FuncTargetType.self).l}+20%; '
                '[${S.current.support_servant_short}] ${Transl.funcTargetType(FuncTargetType.ptFull).l} +4%',
              ),
              onChanged: (v) => updateSharedInput(() => option.frontlineBonus = v),
            ),
          ],
        ),
        ..._solverSection(),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.team_bond),
        bottom: FixedHeight.tabBar(
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: S.current.team),
              Tab(text: S.current.results),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveBuilder(
            builder: (context) => Column(
              children: [
                Expanded(child: inputContent),
                _buildSolveBar(),
              ],
            ),
          ),
          KeepAliveBuilder(
            builder: (context) => BondSolverResultsTab(
              solved: _runtime.solverResult,
              formation: formation,
              option: option,
              quest: _runtime.resultQuest ?? questEntity,
              solving: _runtime.solving,
              status: _runtime.status,
              error: _runtime.solverError,
              onCancel: cancelSolve,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolveBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _runtime.solving || !_runtime.restored ? null : solve,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Solve max bond'),
              ),
            ),
            if (_runtime.solving) ...[
              const SizedBox(width: 8),
              TextButton(onPressed: cancelSolve, child: const Text('Cancel')),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _solverSection() {
    final standardCost = ConstData.userLevel[ConstData.maxUserLevel]?.maxCost ?? 0;
    return [
      Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        margin: const EdgeInsets.fromLTRB(8, 12, 8, 4),
        child: ListTile(
          dense: true,
          leading: Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.onSecondaryContainer),
          title: Text(S.current.drop_calc_solve),
          subtitle: const Text('Limits and filters'),
        ),
      ),
      TileGroup(
        header: S.current.settings_general,
        children: [
          ListTile(
            dense: true,
            title: const Text('COST'),
            subtitle: Text('${Region.jp.localName} COST ${ConstData.maxUserCost} (Lv.${ConstData.maxUserLevel})'),
            trailing: TextButton(
              onPressed: () => _editNumber(
                title: 'Max COST',
                initial: option.maxCost ?? standardCost,
                update: (v) => option.maxCost = v == 0 ? null : v,
                hintText: '0 = ${S.current.general_default}',
              ),
              child: Text(
                option.maxCost == null
                    ? '$standardCost (${S.current.general_default})'
                    : '${option.maxCost} / $standardCost',
              ),
            ),
          ),
          // ListTile(
          //   dense: true,
          //   title: const Text('Max teams kept'),
          //   trailing: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Text('${option.maxCandidateTeams}'),
          //       const SizedBox(width: 4),
          //       const Icon(Icons.chevron_right, size: 20),
          //     ],
          //   ),
          //   onTap: () => InputCancelOkDialog.number(
          //     title: 'Candidate teams (1–200)',
          //     initValue: option.maxCandidateTeams,
          //     validate: (v) => v >= 1 && v <= 200,
          //     onSubmit: (v) => updateSharedInput(() => option.maxCandidateTeams = v),
          //   ).showDialog(context),
          // ),
        ],
      ),
      TileGroup(
        header:
            '${S.current.filter} - ${S.current.servant} '
            '(${S.current.cur_account}: [${db.curUser.region.localName}] ${db.curUser.name})',
        children: [
          SwitchListTile.adaptive(
            dense: true,
            title: Text(S.current.bond_search_fixed_ascensions),
            value: option.searchFixedAscensions,
            onChanged: (v) => updateSharedInput(() => option.searchFixedAscensions = v),
          ),
          SwitchListTile.adaptive(
            dense: true,
            title: Text(S.current.favorite),
            value: option.favoriteOnly,
            onChanged: (v) => updateSharedInput(() => option.favoriteOnly = v),
          ),
          ListTile(
            dense: true,
            title: Text(S.current.bond),
            trailing: TextButton(
              onPressed: () => _editNumber(
                title: '${S.current.bond}≤',
                initial: option.maxBond,
                update: (v) => option.maxBond = v,
                hintText: '0 = ${S.current.general_any}',
              ),
              child: Text(option.maxBond <= 0 ? S.current.general_any : '≤${option.maxBond}'),
            ),
          ),
        ],
      ),
      BondExcludedCards(
        title: '${S.current.exclude} - ${S.current.servant}',
        ids: option.excludedSvts,
        servant: true,
        onAdd: () {
          router.pushPage(
            ServantListPage(
              filterData: SvtFilterData(useGrid: true),
              onSelected: (svt) {
                if (mounted) updateSharedInput(() => option.excludedSvts.add(svt.id));
              },
            ),
          );
        },
        onRemove: (id) => updateSharedInput(() => option.excludedSvts.remove(id)),
      ),
      BondExcludedCards(
        title: '${S.current.exclude} - ${S.current.craft_essence}',
        ids: option.excludedCes,
        servant: false,
        onAdd: () {
          router.pushPage(
            CraftListPage(
              filterData: CraftFilterData(useGrid: true)..obtain.options = {CEObtain.davinciBondBonus},
              onSelected: (ce) {
                if (mounted) updateSharedInput(() => option.excludedCes.add(ce.id));
              },
            ),
          );
        },
        onRemove: (id) => updateSharedInput(() => option.excludedCes.remove(id)),
      ),
    ];
  }

  Widget buildExtraBonus(int index) {
    final deckSvt = formation.svts.getOrNull(index);
    if (deckSvt == null || deckSvt.svt == null || deckSvt.supportType.isSupport) return const SizedBox.shrink();
    final detail = option.svtBonus[index];

    Widget _textButton(String text, VoidCallback onTap) {
      Widget child = InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: 18),
          padding: EdgeInsets.symmetric(vertical: 2),
          child: AutoSizeText(
            text,
            maxLines: 1,
            minFontSize: 2,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      );
      return child;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _textButton('+${detail.addValue}', () {
          InputCancelOkDialog.number(
            title: 'Bond Add Value',
            autofocus: true,
            initValue: detail.addValue,
            validate: (v) => v >= 0,
            onSubmit: (value) => updateSharedInput(() => detail.addValue = value),
          ).showDialog(context);
        }),
        _textButton('+${detail.addRate.format(percent: true, base: 10)}', () {
          InputCancelOkDialog(
            title: 'Bond Add Percent(%)',
            autofocus: true,
            initValue: (detail.addValue / 10).format(),
            validate: (s) => (double.parse(s) * 10).toInt() >= 0,
            onSubmit: (s) => updateSharedInput(() => detail.addRate = (double.parse(s) * 10).toInt()),
          ).showDialog(context);
        }),
        Checkbox(
          visualDensity: VisualDensity.compact,
          value: detail.isBond15,
          onChanged: (v) => updateSharedInput(() => detail.isBond15 = v!),
        ),
        Checkbox(
          visualDensity: VisualDensity.compact,
          value: detail.isBondReachLimit,
          onChanged: (v) => updateSharedInput(() => detail.isBondReachLimit = v!),
        ),
      ],
    );
  }

  Widget buildResult(int index, SvtBondBonusResult result) {
    final deckSvt = formation.svts.getOrNull(index);
    if (deckSvt == null || deckSvt.svt == null) return const SizedBox.shrink();
    final detail = option.svtBonus[index];
    if (deckSvt.supportType.isSupport) {
      return Text('-', style: Theme.of(context).textTheme.bodySmall);
    } else if (detail.isBondReachLimit) {
      return Text('Lv.MAX', style: Theme.of(context).textTheme.bodySmall);
    }

    Widget _row(String text, [double? textScaleFactor]) {
      return InkWell(
        onTap: () {
          Widget _param(String name, String value) {
            return ListTile(contentPadding: EdgeInsets.zero, dense: true, title: Text(name), trailing: Text(value));
          }

          SimpleConfirmDialog(
            title: Text('Params'),
            scrollable: true,
            showCancel: false,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (k, v) in <String, String>{
                  "baseValue": result.baseValue.toString(),
                  "equipAddRate": _strRate(result.equipAddRate),
                  "equipAddValue": result.equipAddValue.toString(),
                  "eventAddRate": _strRate(result.eventAddRate),
                  "eventAddValue": result.eventAddValue.toString(),
                  "customAddRate": _strRate(result.customAddRate),
                  "customAddValue": result.customAddValue.toString(),
                  "frontlineAddRate": _strRate(result.frontlineAddRate),
                }.items)
                  _param(k, v),
                kDefaultDivider,
                for (final (k, v) in <String, String>{
                  "totalAddRate": _strRate(result.totalAddRate),
                  "totalAddValue": '+${result.totalAddValue}',
                  "teapotTimes": '×${result.teapotTimes}',
                  "totalBond": result.totalBond.toString(),
                }.items)
                  _param(k, v),
              ],
            ),
          ).showDialog(context);
        },
        child: AutoSizeText(text, maxLines: 1, maxFontSize: 16, minFontSize: 2, textScaleFactor: textScaleFactor),
      );
    }

    final totalBond = result.totalBond;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [_row('+${totalBond - result.baseValue}', 0.9), _row(totalBond.toString())],
    );
  }
}

/// Quest (id + phase) picker for the combined team and solver page.
///
/// Resolves the chosen quest phase from local game data first and falls back to
/// the network; reports the resolved phase through [onChanged] (null on failure).
class _BondQuestPicker extends StatelessWidget {
  final QuestPhase? quest;
  final ValueChanged<QuestPhase?> onChanged;

  const _BondQuestPicker({required this.quest, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final quest = this.quest;
    return ListTile(
      dense: true,
      title: Text('${S.current.quest} ID'),
      subtitle: quest == null ? null : Text('${quest.lNameWithChapter}\nBase ${S.current.bond}: ${quest.bond}'),
      onTap: quest?.routeTo,
      trailing: TextButton(
        onPressed: () {
          InputCancelOkDialog.number(
            title: 'Quest ID',
            initValue: quest?.id,
            validate: (v) => v > 0,
            onSubmit: (v) async {
              final _quest = db.gameData.quests[v] ?? await showEasyLoading(() => AtlasApi.quest(v));
              if (!context.mounted) return;
              if (_quest == null) {
                EasyLoading.showError(S.current.not_found);
                return;
              }
              int? phase;
              if (_quest.phases.length == 1) {
                phase = _quest.phases.single;
              } else {
                phase = await router.showDialog<int>(
                  builder: (context) => SimpleDialog(
                    title: const Text("Quest Phase"),
                    children: [
                      for (final phase in _quest.phases)
                        ListTile(
                          enabled: !_quest.phasesNoBattle.contains(phase),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                          onTap: () => Navigator.pop(context, phase),
                          title: Text('phase $phase'),
                        ),
                    ],
                  ),
                );
              }
              if (phase == null || !_quest.phases.contains(phase)) return;

              final questPhase =
                  db.gameData.getQuestPhase(_quest.id, phase) ??
                  await showEasyLoading(() => AtlasApi.questPhase(_quest.id, phase!));
              if (!context.mounted) return;
              if (questPhase == null) {
                EasyLoading.showError(S.current.not_found);
                return;
              }
              onChanged(questPhase);
            },
          ).showDialog(context);
        },
        child: Text(quest == null ? '0' : '${quest.id}/${quest.phase}'),
      ),
    );
  }
}
