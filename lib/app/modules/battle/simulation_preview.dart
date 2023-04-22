import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/battle/battle_simulation.dart';
import 'package:chaldea/app/modules/mystic_code/mystic_code_list.dart';
import 'package:chaldea/app/modules/quest/quest_card.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../quest/breakdown/quest_phase.dart';
import '../quest/quest.dart';
import 'formation/default_lvs.dart';
import 'formation/formation_storage.dart';
import 'formation/quest_selector.dart';
import 'formation/svt_selector.dart';

class SimulationPreview extends StatefulWidget {
  final Region? region;
  final QuestPhase? questPhase;

  const SimulationPreview({
    super.key,
    this.region,
    this.questPhase,
  });

  @override
  State<SimulationPreview> createState() => _SimulationPreviewState();
}

class _SimulationPreviewState extends State<SimulationPreview> {
  static const _validQuestRegions = [Region.jp, Region.na];

  Region? questRegion; // region for quest selector
  QuestPhase? questPhase;
  String? questErrorMsg;
  String? errorMsg;

  TextEditingController questIdTextController = TextEditingController();

  final BattleOptions options = BattleOptions();

  List<PlayerSvtData> get onFieldSvts => options.onFieldSvtDataList;
  List<PlayerSvtData> get backupSvts => options.backupSvtDataList;

  @override
  void initState() {
    super.initState();
    questRegion = widget.region;
    options.mysticCodeData.level = db.curUser.mysticCodes[options.mysticCodeData.mysticCode?.id] ?? 10;
    questPhase = widget.questPhase;
    String? initText;
    if (questPhase != null) {
      initText = '${questPhase!.id}/${questPhase!.phase}';
      if (questPhase!.enemyHash != null && questPhase!.enemyHashes.length > 1) {
        initText += '?hash=${questPhase!.enemyHash}';
      }
      if (widget.region != null) {
        initText = '/${widget.region!.upper}/quest/$initText';
      }
      questIdTextController.text = initText;
    } else if (db.settings.battleSim.previousQuestPhase != null) {
      questIdTextController.text = db.settings.battleSim.previousQuestPhase!;
      _fetchQuestPhase();
    }
    initFormation();
  }

  @override
  void dispose() {
    super.dispose();
    questIdTextController.dispose();
    QuestPhaseWidget.removePhaseSelectCallback(_questSelectCallback);
  }

  @override
  Widget build(final BuildContext context) {
    checkPreviewReady();
    final List<Widget> children = [];

    children.add(questSelector());
    children.add(header(S.current.quest));
    children.add(questDetail());

    children.add(header(S.current.battle_simulation_setup));
    children.add(partyOption());
    children.add(DividerWithTitle(
      indent: 16,
      title: db.settings.battleSim.curFormation.shownName(db.settings.battleSim.curFormationIndex),
    ));
    children.add(ResponsiveLayout(
      horizontalDivider: kIndentDivider,
      children: [
        partyOrganization(onFieldSvts, S.current.battle_select_battle_servants),
        partyOrganization(backupSvts, S.current.battle_select_backup_servants),
      ],
    ));
    children.add(header(S.current.mystic_code));
    children.add(buildMysticCode());
    children.add(header(S.current.battle_misc_config));
    children.add(buildMisc());

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AutoSizeText(S.current.battle_simulation_setup, maxLines: 1),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: ListView(children: children)),
          kDefaultDivider,
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: buttonBar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget header(String title) {
    return DividerWithTitle(
      title: S.current.quest,
      titleWidget: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      thickness: 2,
      padding: const EdgeInsets.only(top: 8),
    );
  }

  Widget questSelector() {
    if (questRegion != null && !_validQuestRegions.contains(questRegion)) {
      questRegion = Region.jp;
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextFormField(
            controller: questIdTextController,
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              hintText: '93031014/3 ${S.current.logic_type_or} **/JP/quest/93031014/3'.breakWord,
              labelText: '① questId/phase ${S.current.logic_type_or} chaldea/AADB quest url',
              hintStyle: const TextStyle(overflow: TextOverflow.visible),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            DropdownButton<Region>(
              isDense: true,
              value: questRegion,
              items: [
                for (final r in _validQuestRegions)
                  DropdownMenuItem(value: r, child: Text(r.localName, textScaleFactor: 0.9)),
              ],
              hint: Text(Region.jp.localName),
              onChanged: (v) {
                setState(() {
                  if (v != null) questRegion = v;
                });
              },
            ),
            ElevatedButton(
              onPressed: () async {
                EasyLoading.show();
                try {
                  await _fetchQuestPhase();
                } catch (e, s) {
                  logger.e('fetch quest phase failed', e, s);
                  questErrorMsg = escapeDioError(e);
                } finally {
                  EasyLoading.dismiss();
                  if (mounted) setState(() {});
                }
              },
              child: Text(S.current.search),
            ),
          ],
        ),
        kDefaultDivider,
        ListTile(
          dense: true,
          title: Text('② ${S.current.battle_quest_from} ${S.current.event}/${S.current.main_story}'),
          subtitle: Text.rich(TextSpan(
            text: '${S.current.event}→${S.current.war}→${S.current.quest}→',
            children: [
              CenterWidgetSpan(
                child: Icon(
                  Icons.calculate,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            ],
          )),
          trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          onTap: () {
            QuestPhaseWidget.addPhaseSelectCallback(_questSelectCallback);
            router.push(url: Routes.events, detail: true);
          },
        ),
        kDefaultDivider,
        FQSelectDropdown(
          key: Key('FQSelectDropdown_${questPhase?.id}'),
          initQuestId: questPhase?.id,
          onChanged: (Quest quest) async {
            EasyLoading.show();
            final phase = await AtlasApi.questPhase(quest.id, quest.phases.last);
            EasyLoading.dismiss();
            if (mounted) {
              if (phase != null) {
                questPhase = phase;
                questIdTextController.text = '${phase.id}/${phase.phase}';
              }
              setState(() {});
            }
          },
        ),
      ],
    );
  }

  Widget questDetail() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (questErrorMsg != null)
          SFooter.rich(TextSpan(text: questErrorMsg, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        if (questPhase == null)
          Text(
            S.current.battle_no_quest_phase,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        if (questPhase != null) ...[
          // kDefaultDivider,
          TextButton(
            onPressed: () {
              QuestPhaseWidget.addPhaseSelectCallback(_questSelectCallback);
              router.push(
                url: Routes.questI(questPhase!.id),
                child: QuestDetailPage(quest: questPhase),
                detail: true,
              );
            },
            style: kTextButtonDenseStyle,
            child: Text('>>> ${S.current.quest_detail_btn} >>>'),
          ),
          QuestCard(
            region: questRegion,
            offline: false,
            quest: questPhase,
            displayPhases: [questPhase!.phase],
            battleOnly: true,
            preferredPhases: [questPhase!],
          ),
        ]
      ],
    );
  }

  Widget partyOption() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        DropdownButton<Region>(
          isDense: true,
          value: options.playerRegion,
          items: [
            for (final r in Region.values)
              DropdownMenuItem(
                value: r,
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: '${S.current.strength_status}:',
                      style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                    TextSpan(text: r.localName),
                  ]),
                  textScaleFactor: 0.9,
                ),
              ),
          ],
          onChanged: (v) {
            setState(() {
              if (v != null) options.playerRegion = v;
            });
          },
        ),
        TextButton(
          onPressed: () {
            router.pushPage(const PlayerSvtDefaultLvEditPage());
          },
          child: Text(S.current.default_lvs),
        ),
        CheckboxWithLabel(
          value: db.settings.battleSim.preferPlayerData,
          label: Text(S.current.battle_prefer_player_data),
          onChanged: (v) {
            setState(() {
              if (v != null) db.settings.battleSim.preferPlayerData = v;
            });
          },
        ),
      ],
    );
  }

  Responsive partyOrganization(List<PlayerSvtData> svts, String title) {
    return Responsive(
      small: 12,
      middle: 6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          Row(
            children: [
              for (final svt in svts)
                Expanded(
                  child: ServantSelector(
                    playerSvtData: svt,
                    playerRegion: options.playerRegion,
                    questPhase: questPhase,
                    onChange: () {
                      if (mounted) setState(() {});
                    },
                    onDragSvt: (svtFrom) {
                      onDrag(svtFrom, svt, false);
                    },
                    onDragCE: (svtFrom) {
                      onDrag(svtFrom, svt, true);
                    },
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }

  void onDrag(PlayerSvtData from, PlayerSvtData to, bool isCE) {
    final allSvts = [...onFieldSvts, ...backupSvts];
    final fromIndex = allSvts.indexOf(from), toIndex = allSvts.indexOf(to);
    if (fromIndex < 0 || toIndex < 0 || fromIndex == toIndex) return;
    if (isCE) {
      final ce = from.ce, ceLv = from.ceLv, ceLimitBreak = from.ceLimitBreak;
      from
        ..ce = to.ce
        ..ceLv = to.ceLv
        ..ceLimitBreak = to.ceLimitBreak;
      to
        ..ce = ce
        ..ceLv = ceLv
        ..ceLimitBreak = ceLimitBreak;
    } else {
      allSvts[fromIndex] = to;
      allSvts[toIndex] = from;
      onFieldSvts.setAll(0, allSvts.sublist(0, onFieldSvts.length));
      backupSvts.setAll(0, allSvts.sublist(onFieldSvts.length));
    }

    if (mounted) setState(() {});
  }

  Widget buildMysticCode() {
    Widget mcIcon = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        options.mysticCodeData.mysticCode?.iconBuilder(context: context, width: 48, jumpToDetail: false) ??
            db.getIconImage(null, width: 48),
        if (options.mysticCodeData.mysticCode != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final skill in options.mysticCodeData.mysticCode!.skills)
                db.getIconImage(skill.icon, width: 24, aspectRatio: 1, padding: const EdgeInsets.all(1)),
            ],
          ),
      ],
    );
    mcIcon = InkWell(
      onTap: () {
        router.pushPage(
          MysticCodeListPage(
            onSelected: (selectedMC) {
              options.mysticCodeData
                ..mysticCode = selectedMC
                ..level = db.curUser.mysticCodes[selectedMC.id] ?? 10;
              if (mounted) setState(() {});
            },
          ),
          detail: true,
        );
      },
      child: SizedBox(width: 88, child: mcIcon),
    );
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 8),
        mcIcon,
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SliderWithTitle(
                leadingText: options.mysticCodeData.mysticCode?.lName.l ?? S.current.mystic_code,
                min: 1,
                max: 10,
                value: options.mysticCodeData.level,
                label: 'Lv.${options.mysticCodeData.level}',
                onChange: (v) {
                  options.mysticCodeData.level = v.round();
                  if (mounted) setState(() {});
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildMisc() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderWithTitle(
          leadingText: S.current.battle_probability_threshold,
          min: 0,
          max: 10,
          value: options.probabilityThreshold ~/ 100,
          label: '${options.probabilityThreshold ~/ 10} %',
          onChange: (v) {
            options.probabilityThreshold = v.round() * 100;
            if (mounted) setState(() {});
          },
          padding: const EdgeInsetsDirectional.only(top: 8, start: 8),
        ),
        CheckboxListTile(
          dense: true,
          value: options.disableEvent,
          title: Text(S.current.disable_event_effects),
          onChanged: (v) {
            setState(() {
              options.disableEvent = v ?? options.disableEvent;
            });
          },
        )
      ],
    );
  }

  Widget buttonBar() {
    Widget child = Wrap(
      spacing: 4,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: () => _editFormations(),
          icon: const Icon(Icons.people),
          label: Text(S.current.team),
        ),
        FilledButton.icon(
          onPressed: errorMsg != null
              ? null
              : () {
                  QuestPhaseWidget.removePhaseSelectCallback(_questSelectCallback);
                  _startSimulation();
                },
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(S.current.battle_start_simulation),
        ),
      ],
    );
    if (errorMsg?.isNotEmpty == true) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorMsg ?? "",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
          child,
        ],
      );
    }
    return child;
  }

  ///

  Future<void> _fetchQuestPhase() async {
    questErrorMsg = null;
    final text = questIdTextController.text.trim();
    // quest id and phase
    final match = RegExp(r'(\d+)(?:/(\d+))?').firstMatch(text);
    if (match == null) {
      questErrorMsg = S.current.invalid_input;
      return;
    }
    final questId = int.parse(match.group(1)!);
    int? phase = int.tryParse(match.group(2) ?? "");
    // region
    final regionText = RegExp(r'(JP|NA|CN|TW|KR)/').firstMatch(text)?.group(1);
    Region region = questRegion ??= const RegionConverter().fromJson(regionText ?? "");
    // hash
    final hash = RegExp(r'\?hash=([0-9a-zA-Z_\-]{14})$').firstMatch(text)?.group(1);

    Quest? quest;
    if (region == Region.jp) quest = db.gameData.quests[questId];
    quest ??= await AtlasApi.quest(questId, region: region);
    if (quest == null) {
      questErrorMsg = '${S.current.not_found}: $questId';
      return;
    }
    if (phase == null || !quest.phases.contains(phase)) {
      // event quests released in the next day usually have no valid phase data
      phase = quest.phases.getOrNull(0) ?? 1;
    }
    questPhase = await AtlasApi.questPhase(questId, phase, hash: hash, region: region);
    if (questPhase == null) {
      questErrorMsg = '${S.current.not_found}: /${region.upper}/quest/$questId/$phase';
      if (hash != null) questErrorMsg = '${questErrorMsg!}?hash=$hash';
    }
    if (mounted) setState(() {});
  }

  void _questSelectCallback(final QuestPhase selected) {
    questPhase = selected;
    if (!mounted) return;
    final curRoute = ModalRoute.of(context);
    if (curRoute != null) {
      Navigator.popUntil(context, (route) => route == curRoute);
    }
    questErrorMsg = null;
    db.settings.battleSim.previousQuestPhase = '${selected.id}/${selected.phase}';
    if (mounted) {
      questIdTextController.text = db.settings.battleSim.previousQuestPhase!;
    }
    setState(() {});
  }

  bool checkPreviewReady() {
    if (questPhase == null) {
      errorMsg = S.current.battle_no_quest_phase;
      return false;
    }
    if (onFieldSvts.every((setting) => setting.svt == null) && backupSvts.every((setting) => setting.svt == null)) {
      errorMsg = S.current.battle_no_servant;
      return false;
    }

    errorMsg = null;
    return true;
  }

  void _startSimulation() {
    db.settings.battleSim.previousQuestPhase = '${questPhase!.id}/${questPhase!.phase}';
    saveFormation();
    final questCopy = QuestPhase.fromJson(questPhase!.toJson());
    if (options.disableEvent) {
      questCopy.warId = 0;
      questCopy.individuality.removeWhere((e) => e.isEventField);
    }
    router.push(
      url: Routes.laplaceBattle,
      child: BattleSimulationPage(
        questPhase: questCopy,
        options: options,
      ),
    );
  }

  /// Formation part

  void _editFormations() async {
    saveFormation();
    final prevFormation = db.settings.battleSim.curFormation;
    await router.pushPage(const FormationEditor());
    final formation = db.settings.battleSim.curFormation;
    if (formation != prevFormation) {
      await restoreFormation(formation);
    }

    if (mounted) setState(() {});
  }

  Future<void> initFormation() async {
    EasyLoading.show();
    try {
      await restoreFormation(db.settings.battleSim.curFormation);
    } catch (e) {
      rethrow;
    } finally {
      EasyLoading.dismiss();
      if (mounted) setState(() {});
    }
  }

  Future<void> restoreFormation(BattleTeamFormation formation) async {
    for (int index = 0; index < 3; index++) {
      onFieldSvts[index] = await PlayerSvtData.fromStoredData(formation.onFieldSvts.getOrNull(index));
      backupSvts[index] = await PlayerSvtData.fromStoredData(formation.backupSvts.getOrNull(index));
    }

    options.mysticCodeData.loadStoredData(formation.mysticCode);
  }

  void saveFormation() {
    final curFormation = db.settings.battleSim.curFormation;
    curFormation.onFieldSvts = onFieldSvts.map((e) => e.isEmpty ? null : e.toStoredData()).toList();
    curFormation.backupSvts = backupSvts.map((e) => e.isEmpty ? null : e.toStoredData()).toList();
    curFormation.mysticCode = options.mysticCodeData.toStoredData();
  }
}
