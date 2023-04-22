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
import 'options/default_lvs.dart';
import 'options/formation_storage.dart';
import 'options/svt_option_editor.dart';

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
  Region? region;
  QuestPhase? questPhase;
  String? questErrorMsg;
  String? errorMsg;

  TextEditingController questIdTextController = TextEditingController();

  final List<PlayerSvtData> onFieldSvtDataList = [
    PlayerSvtData.base(),
    PlayerSvtData.base(),
    PlayerSvtData.base(),
  ];
  final List<PlayerSvtData> backupSvtDataList = [
    PlayerSvtData.base(),
    PlayerSvtData.base(),
    PlayerSvtData.base(),
  ];
  final MysticCodeData mysticCodeData = MysticCodeData();

  int fixedRandom = ConstData.constants.attackRateRandomMin;
  int probabilityThreshold = 1000;
  bool isAfter7thAnni = true;
  static const _validRegions = [Region.jp, Region.na];
  late Region playerRegion = db.curUser.region;
  bool disableEvent = false;

  @override
  void initState() {
    super.initState();
    region = widget.region;
    mysticCodeData.level = db.curUser.mysticCodes[mysticCodeData.mysticCode?.id] ?? 10;
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
        partyOrganization(onFieldSvtDataList, S.current.battle_select_battle_servants),
        partyOrganization(backupSvtDataList, S.current.battle_select_backup_servants),
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
          if (errorMsg?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                errorMsg ?? "",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
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
    if (region != null && !_validRegions.contains(region)) {
      region = Region.jp;
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
              value: region,
              items: [
                for (final r in _validRegions)
                  DropdownMenuItem(value: r, child: Text(r.localName, textScaleFactor: 0.9)),
              ],
              hint: Text(Region.jp.localName),
              onChanged: (v) {
                setState(() {
                  if (v != null) region = v;
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
        _SelectFreeDropdowns(
          key: Key('_SelectFreeDropdowns_${questPhase?.id}'),
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
            region: region,
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
          value: playerRegion,
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
              if (v != null) playerRegion = v;
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
                    playerRegion: playerRegion,
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
    final allSvts = [...onFieldSvtDataList, ...backupSvtDataList];
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
      onFieldSvtDataList.setAll(0, allSvts.sublist(0, onFieldSvtDataList.length));
      backupSvtDataList.setAll(0, allSvts.sublist(onFieldSvtDataList.length));
    }

    if (mounted) setState(() {});
  }

  Widget buttonBar() {
    return Wrap(
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
  }

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
    Region region = this.region ??= const RegionConverter().fromJson(regionText ?? "");
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

  Widget buildMysticCode() {
    Widget mcIcon = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        mysticCodeData.mysticCode?.iconBuilder(context: context, width: 48, jumpToDetail: false) ??
            db.getIconImage(null, width: 48),
        if (mysticCodeData.mysticCode != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final skill in mysticCodeData.mysticCode!.skills)
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
              mysticCodeData
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
                leadingText: mysticCodeData.mysticCode?.lName.l ?? S.current.mystic_code,
                min: 1,
                max: 10,
                value: mysticCodeData.level,
                label: 'Lv.${mysticCodeData.level}',
                onChange: (v) {
                  mysticCodeData.level = v.round();
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
          value: probabilityThreshold ~/ 100,
          label: '${probabilityThreshold ~/ 10} %',
          onChange: (v) {
            probabilityThreshold = v.round() * 100;
            if (mounted) setState(() {});
          },
          padding: const EdgeInsetsDirectional.only(top: 8, start: 8),
        ),
        CheckboxListTile(
          dense: true,
          value: disableEvent,
          title: Text(S.current.disable_event_effects),
          onChanged: (v) {
            setState(() {
              disableEvent = v ?? disableEvent;
            });
          },
        )
      ],
    );
  }

  bool checkPreviewReady() {
    if (questPhase == null) {
      errorMsg = S.current.battle_no_quest_phase;
      return false;
    }
    if (onFieldSvtDataList.every((setting) => setting.svt == null) &&
        backupSvtDataList.every((setting) => setting.svt == null)) {
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
    if (disableEvent) {
      questCopy.warId = 0;
      questCopy.individuality.removeWhere((e) => e.isEventField);
    }
    router.push(
      url: Routes.laplaceBattle,
      child: BattleSimulationPage(
        questPhase: questCopy,
        onFieldSvtDataList: onFieldSvtDataList,
        backupSvtDataList: backupSvtDataList,
        mysticCodeData: mysticCodeData,
        fixedRandom: fixedRandom,
        probabilityThreshold: probabilityThreshold,
        isAfter7thAnni: isAfter7thAnni,
      ),
    );
  }

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
    }
  }

  Future<void> restoreFormation(BattleTeamFormation formation) async {
    for (int index = 0; index < 3; index++) {
      onFieldSvtDataList[index] = await PlayerSvtData.fromStoredData(formation.onFieldSvts.getOrNull(index));
      backupSvtDataList[index] = await PlayerSvtData.fromStoredData(formation.backupSvts.getOrNull(index));
    }

    mysticCodeData.fromStoredData(formation.mysticCode);
  }

  void saveFormation() {
    final curFormation = db.settings.battleSim.curFormation;
    curFormation.onFieldSvts = onFieldSvtDataList.map((e) => e.isEmpty ? null : e.toStoredData()).toList();
    curFormation.backupSvts = backupSvtDataList.map((e) => e.isEmpty ? null : e.toStoredData()).toList();
    curFormation.mysticCode = mysticCodeData.toStoredData();
  }
}

class _SelectFreeDropdowns extends StatefulWidget {
  final int? initQuestId;
  final ValueChanged<Quest> onChanged;

  const _SelectFreeDropdowns({super.key, this.initQuestId, required this.onChanged});

  @override
  State<_SelectFreeDropdowns> createState() => __SelectFreeDropdownsState();
}

class __SelectFreeDropdownsState extends State<_SelectFreeDropdowns> {
  int? warId = 308;
  Quest? quest;
  Map<int, NiceWar> wars = {};

  @override
  void initState() {
    super.initState();
    quest = db.gameData.quests[widget.initQuestId];
    warId = quest?.warId ?? warId;
    final warList = db.gameData.wars.values.where((e) => e.quests.any((q) => q.isAnyFree)).toList();
    warList.sort2((e) => e.id < 1000 ? 1000 - e.id : kNeverClosedTimestamp - (e.event?.startedAt ?? e.id));
    wars = {for (final war in warList) war.id: war};
    if (wars[warId] == null) {
      warId = wars.keys.firstOrNull;
      quest = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      // alignment: WrapAlignment.center,
      // spacing: 8,
      children: [
        const SizedBox(width: 16),
        const Text('③ '),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: warBtn(),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: questBtn(),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget warBtn() {
    return DropdownButton<int>(
      // isDense: true,
      isExpanded: true,
      value: warId,
      hint: Text(S.current.war, style: const TextStyle(fontSize: 14)),
      items: [
        for (final war in wars.values)
          DropdownMenuItem(
            value: war.id,
            child: Text(
              (war.id < 1000 ? war.lShortName : war.event?.lShortName.l ?? war.lShortName).setMaxLines(1).breakWord,
              maxLines: 2,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          )
      ],
      onChanged: (v) {
        setState(() {
          warId = v;
        });
      },
    );
  }

  Widget questBtn() {
    final quests = wars[warId]?.quests.where((q) => q.isAnyFree && q.phases.isNotEmpty).toList() ?? [];
    if (!quests.contains(quest)) quest = null;
    return DropdownButton<Quest>(
      // isDense: true,
      isExpanded: true,
      value: quest,
      hint: Text(S.current.quest, style: const TextStyle(fontSize: 14)),
      items: [
        for (final quest in quests)
          DropdownMenuItem(
            value: quest,
            child: Text(
              quest.lDispName.setMaxLines(1).breakWord,
              maxLines: 1,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          )
      ],
      onChanged: (v) {
        setState(() {
          quest = v;
          if (v != null) widget.onChanged(v);
        });
      },
    );
  }
}

class _DragSvtData {
  final PlayerSvtData svt;

  _DragSvtData(this.svt);
}

class _DragCEData {
  final PlayerSvtData svt;

  _DragCEData(this.svt);
}

class ServantSelector extends StatelessWidget {
  final PlayerSvtData playerSvtData;
  final Region playerRegion;
  final QuestPhase? questPhase;
  final VoidCallback onChange;
  final DragTargetAccept<PlayerSvtData> onDragSvt;
  final DragTargetAccept<PlayerSvtData> onDragCE;

  ServantSelector({
    super.key,
    required this.playerSvtData,
    required this.playerRegion,
    required this.questPhase,
    required this.onChange,
    required this.onDragSvt,
    required this.onDragCE,
  });

  @override
  Widget build(final BuildContext context) {
    List<Widget> children = [];

    TextStyle notSelectedStyle = TextStyle(color: Theme.of(context).textTheme.bodySmall?.color);

    // svt icon
    String svtInfo = '';
    if (playerSvtData.svt != null) {
      svtInfo = ' Lv.${playerSvtData.lv} NP${playerSvtData.tdLv}\n'
          ' ${playerSvtData.skillLvs.join("/")}\n'
          ' ${playerSvtData.appendLvs.map((e) => e == 0 ? "-" : e).join("/")}';
    }
    Widget svtIcon = GameCardMixin.cardIconBuilder(
      context: context,
      icon: playerSvtData.svt?.ascendIcon(playerSvtData.limitCount, true) ?? Atlas.common.emptySvtIcon,
      width: 80,
      aspectRatio: 132 / 144,
      text: svtInfo,
      option: ImageWithTextOption(
        textAlign: TextAlign.left,
        fontSize: 10,
        alignment: Alignment.bottomLeft,
        // padding: const EdgeInsets.fromLTRB(22, 0, 2, 4),
      ),
    );

    svtIcon = InkWell(
      onTap: () {
        router.pushPage(ServantOptionEditPage(
          playerSvtData: playerSvtData,
          questPhase: questPhase,
          playerRegion: playerRegion,
          onChange: onChange,
        ));
      },
      child: svtIcon,
    );

    final svtDraggable = Draggable<_DragSvtData>(
      feedback: svtIcon,
      data: _DragSvtData(playerSvtData),
      child: svtIcon,
    );
    svtIcon = DragTarget<_DragSvtData>(
      builder: (context, candidateData, rejectedData) {
        return svtDraggable;
      },
      onAccept: (data) {
        onDragSvt(data.svt);
      },
    );

    children.add(svtIcon);

    // svt name+btn
    children.add(SizedBox(
      height: 18,
      child: AutoSizeText(
        playerSvtData.svt?.lBattleName(playerSvtData.limitCount).l ?? S.current.servant,
        maxLines: 1,
        minFontSize: 10,
        textAlign: TextAlign.center,
        textScaleFactor: 0.9,
        style: playerSvtData.svt == null ? notSelectedStyle : null,
      ),
    ));
    children.add(const SizedBox(height: 8));

    // ce icon
    Widget ceIcon = db.getIconImage(
      playerSvtData.ce?.extraAssets.equipFace.equip?[playerSvtData.ce?.id] ?? Atlas.common.emptyCeIcon,
      width: 80,
      aspectRatio: 150 / 68,
    );
    if (playerSvtData.ce != null && playerSvtData.ceLimitBreak) {
      ceIcon = Stack(
        alignment: Alignment.bottomRight,
        children: [
          ceIcon,
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.yellow)),
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.auto_awesome, color: Colors.yellow[900], size: 14),
            ),
          )
        ],
      );
    }
    ceIcon = InkWell(
      onTap: () {
        router.pushPage(CraftEssenceOptionEditPage(
          playerSvtData: playerSvtData,
          questPhase: questPhase,
          onChange: onChange,
        ));
      },
      child: ceIcon,
    );

    final ceDraggable = Draggable<_DragCEData>(
      feedback: ceIcon,
      data: _DragCEData(playerSvtData),
      child: ceIcon,
    );
    ceIcon = DragTarget<_DragCEData>(
      builder: (context, candidateData, rejectedData) {
        return ceDraggable;
      },
      onAccept: (data) {
        onDragCE(data.svt);
      },
    );

    children.add(Center(child: ceIcon));

    // ce btn
    String ceInfo = '';
    if (playerSvtData.ce != null) {
      ceInfo = 'Lv.${playerSvtData.ceLv}';
      if (playerSvtData.ceLimitBreak) {
        ceInfo += ' ${S.current.max_limit_break}';
      }
    } else {
      ceInfo = 'Lv.-';
    }
    children.add(SizedBox(
      height: 18,
      child: AutoSizeText(
        ceInfo.breakWord,
        maxLines: 1,
        minFontSize: 10,
        textAlign: TextAlign.center,
        textScaleFactor: 0.9,
        style: playerSvtData.ce == null ? notSelectedStyle : null,
      ),
    ));

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }

  static final List<int> costumeOrtinaxIds = [12, 800140, 13, 800150];
  static final List<int> melusineDragonIds = [3, 4, 13, 304850];

  static List<NiceTd> getShownTds(final Servant svt, final int ascension) {
    final List<NiceTd> shownTds = svt.groupedNoblePhantasms[1]?.toList() ?? <NiceTd>[];
    // only case where we different groups of noblePhantasms exist are for npCardTypeChange

    // Servant specific
    final List<int> removeTdIdList = [];
    if (svt.collectionNo == 1) {
      // Mash
      if (costumeOrtinaxIds.contains(ascension)) {
        removeTdIdList.addAll([800100, 800101, 800104]);
      } else {
        removeTdIdList.add(800105);
      }
    } else if (svt.collectionNo == 312) {
      // Melusine
      if (melusineDragonIds.contains(ascension)) {
        removeTdIdList.add(304801);
      } else {
        removeTdIdList.add(304802);
      }
    }

    shownTds.removeWhere((niceTd) => removeTdIdList.contains(niceTd.id));
    return shownTds;
  }

  static List<NiceSkill> getShownSkills(final Servant svt, final int ascension, final int skillNum) {
    final List<NiceSkill> shownSkills = [];
    for (final skill in svt.groupedActiveSkills[skillNum] ?? <NiceSkill>[]) {
      if (shownSkills.every((storeSkill) => storeSkill.id != skill.id)) {
        shownSkills.add(skill);
      }
    }

    // Servant specific
    final List<int> removeSkillIdList = [];
    if (svt.collectionNo == 1) {
      // Mash
      if (costumeOrtinaxIds.contains(ascension)) {
        if (skillNum == 1) {
          removeSkillIdList.addAll([1000, 236000]);
        } else if (skillNum == 2) {
          removeSkillIdList.addAll([2000]);
        } else {
          removeSkillIdList.addAll([133000]);
        }
      } else {
        if (skillNum == 1) {
          removeSkillIdList.addAll([459550, 744450]);
        } else if (skillNum == 2) {
          removeSkillIdList.addAll([460250]);
        } else {
          removeSkillIdList.addAll([457000, 2162350]);
        }
      }
    } else if (svt.collectionNo == 312 && skillNum == 3) {
      // Melusine
      if (melusineDragonIds.contains(ascension)) {
        removeSkillIdList.add(888550);
      } else {
        removeSkillIdList.add(888575);
      }
    }

    shownSkills.removeWhere((niceSkill) => removeSkillIdList.contains(niceSkill.id));
    return shownSkills;
  }
}
