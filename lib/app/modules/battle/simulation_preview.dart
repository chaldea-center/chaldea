import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/modules/battle/battle_simulation.dart';
import 'package:chaldea/app/modules/battle/svt_option_editor.dart';
import 'package:chaldea/app/modules/mystic_code/mystic_code_list.dart';
import 'package:chaldea/app/modules/quest/quest_card.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../quest/breakdown/quest_phase.dart';
import '../quest/quest.dart';

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

  late TextEditingController questIdTextController;

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

  @override
  void initState() {
    super.initState();
    region = widget.region;
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
    }
    questIdTextController = TextEditingController(text: initText);
    if (db.settings.battleSim.previousQuestPhase != null) {
      fetchInitial();
    }
  }

  Future<void> fetchInitial() async {
    questIdTextController.text = db.settings.battleSim.previousQuestPhase!;
    await _fetchQuestPhase();
    if (mounted) setState(() {});
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
    final List<Widget> topListChildren = [];

    topListChildren.add(questSelector());

    topListChildren.add(ResponsiveLayout(
      children: [
        partyOrganization(onFieldSvtDataList, S.current.battle_select_battle_servants),
        partyOrganization(backupSvtDataList, S.current.battle_select_backup_servants),
      ],
    ));

    topListChildren.add(buildMisc());

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AutoSizeText(S.current.battle_simulation_setup, maxLines: 1),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: divideTiles(
                topListChildren,
                divider: const Divider(height: 8, thickness: 2),
              ),
            ),
          ),
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

  static const _validRegions = [Region.jp, Region.na];

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
              labelText: 'questId/phase ${S.current.logic_type_or} chaldea/AADB quest url',
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
        ListTile(
          dense: true,
          title: Text('${S.current.battle_quest_from} ${S.current.event}/${S.current.main_story}'),
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
        // kDefaultDivider,
        if (questErrorMsg != null)
          SFooter.rich(TextSpan(text: questErrorMsg, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        if (questPhase == null)
          Text(
            S.current.battle_no_quest_phase,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        if (questPhase != null)
          TextButton(
            onPressed: () {
              QuestPhaseWidget.addPhaseSelectCallback(_questSelectCallback);
              router.push(
                url: Routes.questI(questPhase!.id),
                child: QuestDetailPage(quest: questPhase),
                detail: true,
              );
            },
            child: Text('>>> ${S.current.quest_detail_btn} >>>'),
          ),
        if (questPhase != null)
          QuestCard(
            region: region,
            offline: false,
            quest: questPhase,
            displayPhases: [questPhase!.phase],
            battleOnly: true,
            preferredPhases: [questPhase!],
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
                    supportServants: questPhase?.supportServants ?? [],
                    onChange: () {
                      if (mounted) setState(() {});
                    },
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }

  Widget buttonBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            errorMsg ?? "",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
        FilledButton.icon(
          onPressed: errorMsg != null
              ? null
              : () {
                  QuestPhaseWidget.removePhaseSelectCallback(_questSelectCallback);
                  _startSimulation();
                },
          icon: const Icon(Icons.arrow_right_rounded),
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
  }

  void _questSelectCallback(final QuestPhase selected) {
    questPhase = selected;
    if (!mounted) return;
    final curRoute = ModalRoute.of(context);
    if (curRoute != null) {
      Navigator.popUntil(context, (route) => route == curRoute);
    }
    questErrorMsg = null;
    setState(() {});
  }

  Widget buildMisc() {
    Widget mysticCode = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        mysticCodeData.mysticCode.iconBuilder(context: context, width: 48, jumpToDetail: false),
        AutoSizeText(
          mysticCodeData.mysticCode.lName.l,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        IconButton(
          onPressed: () => setState(() => db.curUser.isGirl = !db.curUser.isGirl),
          color: Theme.of(context).colorScheme.primaryContainer,
          icon: FaIcon(
            db.curUser.isGirl ? FontAwesomeIcons.venus : FontAwesomeIcons.mars,
          ),
          iconSize: 20,
        ),
      ],
    );
    mysticCode = InkWell(
      onTap: () {
        router.pushPage(
          MysticCodeListPage(
            onSelected: (selectedMC) {
              mysticCodeData.mysticCode = selectedMC;
              if (mounted) setState(() {});
            },
          ),
          detail: true,
        );
      },
      child: SizedBox(width: 64, child: mysticCode),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text(
            S.current.battle_misc_config,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        // use Responsible if more settings
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 16),
            mysticCode,
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ServantOptionEditPage.buildSlider(
                    leadingText: S.current.battle_mc_lv,
                    min: 1,
                    max: 10,
                    value: mysticCodeData.level,
                    label: mysticCodeData.level.toString(),
                    onChange: (v) {
                      mysticCodeData.level = v.round();
                      if (mounted) setState(() {});
                    },
                  ),
                  ServantOptionEditPage.buildSlider(
                    leadingText: S.current.battle_probability_threshold,
                    min: 0,
                    max: 10,
                    value: probabilityThreshold ~/ 100,
                    label: '${probabilityThreshold ~/ 10} %',
                    onChange: (v) {
                      probabilityThreshold = v.round() * 100;
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
    router.pushPage(BattleSimulationPage(
      questPhase: questPhase!,
      onFieldSvtDataList: onFieldSvtDataList,
      backupSvtDataList: backupSvtDataList,
      mysticCodeData: mysticCodeData,
      fixedRandom: fixedRandom,
      probabilityThreshold: probabilityThreshold,
      isAfter7thAnni: isAfter7thAnni,
    ));
  }
}

class ServantSelector extends StatelessWidget {
  final PlayerSvtData playerSvtData;
  final List<SupportServant> supportServants;
  final VoidCallback onChange;

  ServantSelector({super.key, required this.playerSvtData, required this.supportServants, required this.onChange});

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
          supportServants: supportServants,
          onChange: onChange,
        ));
      },
      child: svtIcon,
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
          onChange: onChange,
        ));
      },
      child: ceIcon,
    );
    children.add(Center(child: ceIcon));

    // ce btn
    String ceInfo = '';
    if (playerSvtData.ce != null) {
      ceInfo = 'Lv.${playerSvtData.ceLv}';
      if (playerSvtData.ceLimitBreak) {
        ceInfo += ' ${S.current.ce_max_limit_break}';
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
    final List<NiceTd> shownTds = [];
    // only case where we different groups of noblePhantasms exist are for npCardTypeChange
    for (final td in svt.groupedNoblePhantasms[1] ?? <NiceTd>[]) {
      if (shownTds.every((storedTd) => storedTd.id != td.id)) {
        shownTds.add(td);
      }
    }

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
