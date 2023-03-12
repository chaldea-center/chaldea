import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/modules/battle/battle_simulation.dart';
import 'package:chaldea/app/modules/battle/svt_option_editor.dart';
import 'package:chaldea/app/modules/craft_essence/craft_list.dart';
import 'package:chaldea/app/modules/mystic_code/mystic_code_list.dart';
import 'package:chaldea/app/modules/quest/quest_card.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../quest/breakdown/quest_phase.dart';

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
  }

  @override
  void dispose() {
    super.dispose();
    questIdTextController.dispose();
    QuestPhaseWidget.removePhaseSelectCallback(_questSelectCallback);
  }

  @override
  Widget build(final BuildContext context) {
    final List<Widget> topListChildren = [];

    topListChildren.add(questSelector());

    topListChildren.add(Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Text(
            'Select Battle Servants',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: onFieldSvtDataList
              .map((playerSvtData) => Expanded(
                    child: ServantSelector(
                      playerSvtData: playerSvtData,
                      onChange: () {
                        if (mounted) setState(() {});
                      },
                    ),
                  ))
              .toList(),
        ),
      ],
    ));

    topListChildren.add(Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Text(
            'Select Backup Servants',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: backupSvtDataList
              .map((playerSvtData) => Expanded(
                    child: ServantSelector(
                      playerSvtData: playerSvtData,
                      onChange: () {
                        if (mounted) setState(() {});
                      },
                    ),
                  ))
              .toList(),
        ),
      ],
    ));
    topListChildren.add(buildMiscController());

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const AutoSizeText('Battle Simulation Preview', maxLines: 1),
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
          DecoratedBox(
            decoration: BoxDecoration(border: Border(top: Divider.createBorderSide(context, width: 0.5))),
            child: SafeArea(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ButtonBar(
                    buttonPadding: const EdgeInsets.symmetric(horizontal: 2),
                    children: [
                      if (errorMsg != null)
                        SFooter.rich(
                          TextSpan(text: errorMsg, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ),
                      TextButton(
                        onPressed: () {
                          if (!_isPreviewReady()) {
                            if (mounted) setState(() {});
                            return;
                          }

                          _startSimulation();
                        },
                        child: const Text('Start Simulation'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
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
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              hintText: '93031014/3 or **/JP/quest/93031014/3',
              labelText: 'QuestId/phase or chaldea/AADB quest url',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
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
              child: const Text('Fetch'),
            ),
            const SizedBox(width: 0),
            TextButton(
              onPressed: () {
                QuestPhaseWidget.addPhaseSelectCallback(_questSelectCallback);
                router.push(url: Routes.events);
              },
              child: Text(S.current.event),
            ),
          ],
        ),
        if (questErrorMsg != null)
          SFooter.rich(TextSpan(text: questErrorMsg, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        if (questPhase == null)
          const SFooter.rich(
            TextSpan(
              text: 'Choose quest from Events→Wars→Quest→Calculator button',
              children: [CenterWidgetSpan(child: Icon(Icons.calculate, size: 14))],
            ),
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

  Future<void> _fetchQuestPhase() async {
    questErrorMsg = null;
    final text = questIdTextController.text.trim();
    // quest id and phase
    final match = RegExp(r'(\d+)(?:/(\d+))?').firstMatch(text);
    if (match == null) {
      questErrorMsg = 'Invalid quest id or url';
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
      questErrorMsg = 'Quest $questId not found';
      return;
    }
    if (phase == null || !quest.phases.contains(phase)) {
      // event quests released in the next day usually have no valid phase data
      phase = quest.phases.getOrNull(0) ?? 1;
    }
    questPhase = await AtlasApi.questPhase(questId, phase, hash: hash, region: region);
    if (questPhase == null) {
      questErrorMsg = 'Not found: /${region.upper}/quest/$questId/$phase';
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

  Widget buildMiscController() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Text(
            'Misc Configs',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onLongPress: () {},
                    child: mysticCodeData.mysticCode.iconBuilder(context: context, width: 100, jumpToDetail: false),
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
                  ),
                  AutoSizeText(
                    mysticCodeData.mysticCode.lName.l,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    onPressed: () => setState(() => db.curUser.isGirl = !db.curUser.isGirl),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    icon: FaIcon(
                      db.curUser.isGirl ? FontAwesomeIcons.venus : FontAwesomeIcons.mars,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ServantOptionEditPage.buildSlider(
                    leadingText: 'MC Lv',
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
                    leadingText: 'Rate',
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

  bool _isPreviewReady() {
    if (questPhase == null) {
      errorMsg = 'No quest phase selected.';
      return false;
    }
    if (onFieldSvtDataList.every((setting) => setting.svt == null) &&
        backupSvtDataList.every((setting) => setting.svt == null)) {
      errorMsg = 'No servant selected.';
      return false;
    }

    errorMsg = null;
    return true;
  }

  void _startSimulation() {
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
  static const emptyIconUrl = 'https://static.atlasacademy.io/JP/SkillIcons/skill_999999.png';
  final PlayerSvtData playerSvtData;
  final VoidCallback onChange;

  ServantSelector({super.key, required this.playerSvtData, required this.onChange});

  @override
  Widget build(final BuildContext context) {
    Widget svtTextBuilder(final TextStyle style) {
      return Text.rich(
        TextSpan(style: style, children: [
          TextSpan(text: 'Lv${playerSvtData.lv}'),
          WidgetSpan(
            style: style,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 3,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: db.getIconImage(Atlas.asset('Terminal/Info/CommonUIAtlas/icon_nplv.png'), width: 15, height: 15),
            ),
          ),
          TextSpan(text: playerSvtData.npLv.toString()),
          TextSpan(text: '\n${playerSvtData.skillLvs.join('/')}'),
          if (playerSvtData.appendLvs.any((lv) => lv > 0))
            TextSpan(text: "\n${playerSvtData.appendLvs.map((e) => e == 0 ? '-' : e.toString()).join('/')}"),
        ]),
        textScaleFactor: 1,
      );
    }

    Widget ceTextBuilder(final TextStyle style) {
      return Text.rich(
        TextSpan(
          style: style,
          text: 'Lv${playerSvtData.ceLv}-${playerSvtData.ceLimitBreak ? 'LB' : 'not LB'}',
        ),
        textScaleFactor: 1,
      );
    }

    final playerIconImage = playerSvtData.svt == null
        ? db.getIconImage(emptyIconUrl, width: 100, aspectRatio: 132 / 144)
        : playerSvtData.svt!.iconBuilder(
            context: context,
            jumpToDetail: false,
            width: 100,
            overrideIcon: getSvtAscensionBorderedIconUrl(playerSvtData.svt!, playerSvtData.ascensionPhase),
          );

    final ceIconImage = playerSvtData.ce == null
        ? db.getIconImage(emptyIconUrl, width: 100, aspectRatio: 132 / 144)
        : playerSvtData.ce!.iconBuilder(context: context, jumpToDetail: false, width: 100);

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onLongPress: () {},
              child: ImageWithText(
                image: playerIconImage,
                textBuilder: playerSvtData.svt != null ? svtTextBuilder : null,
                option: ImageWithTextOption(
                  shadowSize: 4,
                  textStyle: const TextStyle(fontSize: 11, color: Colors.black),
                  shadowColor: Colors.white,
                  alignment: AlignmentDirectional.bottomStart,
                  padding: const EdgeInsets.fromLTRB(4, 0, 2, 4),
                ),
                onTap: () {
                  router.pushPage(
                    ServantListPage(
                      planMode: false,
                      onSelected: (selectedSvt) {
                        _onSelectServant(selectedSvt);
                      },
                    ),
                    detail: true,
                  );
                },
              ),
            ),
            AutoSizeText(
              playerSvtData.svt == null
                  ? 'Click icon to select servant'
                  : Transl.svtNames(getSvtName(playerSvtData.svt!, playerSvtData.ascensionPhase)).l,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
            if (playerSvtData.svt != null)
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      router.pushPage(ServantOptionEditPage(
                        playerSvtData: playerSvtData,
                        onChange: onChange,
                      ));
                    },
                    icon: const Icon(Icons.edit, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      playerSvtData.svt = null;
                      onChange();
                    },
                    icon: const Icon(Icons.person_off, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ],
              ),
            InkWell(
              onLongPress: () {},
              child: ImageWithText(
                image: ceIconImage,
                textBuilder: playerSvtData.ce != null ? ceTextBuilder : null,
                option: ImageWithTextOption(
                  shadowSize: 4,
                  textStyle: const TextStyle(fontSize: 11, color: Colors.black),
                  shadowColor: Colors.white,
                  alignment: AlignmentDirectional.bottomStart,
                  padding: const EdgeInsets.fromLTRB(4, 0, 2, 4),
                ),
                onTap: () {
                  router.pushPage(
                    CraftListPage(
                      onSelected: (selectedCe) {
                        _onSelectCE(selectedCe);
                      },
                    ),
                    detail: true,
                  );
                },
              ),
            ),
            AutoSizeText(
              playerSvtData.ce == null ? 'Click icon to select CE' : playerSvtData.ce!.lName.l,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
            if (playerSvtData.ce != null)
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      router.pushPage(CraftEssenceOptionEditPage(
                        playerSvtData: playerSvtData,
                        onChange: onChange,
                      ));
                    },
                    icon: const Icon(Icons.edit, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      playerSvtData.ce = null;
                      onChange();
                    },
                    icon: const Icon(Icons.extension_off_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _onSelectCE(final CraftEssence selectedCE) {
    playerSvtData
      ..ce = selectedCE
      ..ceLimitBreak = true
      ..ceLv = selectedCE.lvMax;
    onChange();
  }

  void _onSelectServant(final Servant selectedSvt) {
    if (selectedSvt.isUserSvt) {
      playerSvtData.svt = selectedSvt;
      final status = db.curUser.svtStatusOf(selectedSvt.collectionNo).cur;
      if (status.favorite) {
        playerSvtData
          ..ascensionPhase = status.ascension
          ..lv = selectedSvt.grailedLv(status.grail)
          ..npStrengthenLv = getShownTds(selectedSvt, playerSvtData.ascensionPhase).length
          ..npLv = status.npLv
          ..skillLvs = status.skills.toList()
          ..appendLvs = status.appendSkills.toList()
          ..atkFou = status.fouAtk > 0 ? 1000 + status.fouAtk * 20 : status.fouAtk3 * 50
          ..hpFou = status.fouHp > 0 ? 1000 + status.fouHp * 20 : status.fouHp3 * 50
          ..cardStrengthens = [0, 0, 0, 0, 0]
          ..commandCodeIds = [-1, -1, -1, -1, -1];
      } else {
        playerSvtData
          ..ascensionPhase = 4
          ..lv = getDefaultSvtLv(selectedSvt.rarity)
          ..npStrengthenLv = getShownTds(selectedSvt, playerSvtData.ascensionPhase).length
          ..npLv = 5
          ..skillLvs = [10, 10, 10]
          ..appendLvs = [0, 0, 0]
          ..atkFou = 1000
          ..hpFou = 1000
          ..cardStrengthens = [0, 0, 0, 0, 0]
          ..commandCodeIds = [-1, -1, -1, -1, -1];
      }
      for (int i = 0; i < selectedSvt.groupedActiveSkills.length; i += 1) {
        playerSvtData.skillStrengthenLvs[i] = getShownSkills(selectedSvt, playerSvtData.ascensionPhase, i).length;
      }
      onChange();
    }
  }

  static int getDefaultSvtLv(final int rarity) {
    switch (rarity) {
      case 5:
        return 90;
      case 4:
        return 80;
      case 3:
        return 70;
      case 2:
      case 0:
        return 65;
      case 1:
        return 60;
      default:
        return -1;
    }
  }

  static String? getSvtAscensionBorderedIconUrl(final Servant svt, final int ascension) {
    final ascensions = svt.extraAssets.faces.ascension;
    if (ascensions != null && ascensions.containsKey(ascension)) {
      return svt.bordered(ascensions[ascension]);
    }
    final costumes = svt.extraAssets.faces.costume;
    if (costumes != null && costumes.containsKey(ascension)) {
      return svt.bordered(costumes[ascension]);
    }
    return null;
  }

  static final List<int> costumeOrtinaxIds = [800140, 800150];
  static final List<int> melusineDragonIds = [3, 4, 304850];

  static List<NiceTd> getShownTds(final Servant svt, final int ascension) {
    final List<NiceTd> shownTds = [];
    // only case where we different groups of noblePhantasms exist are for npCardTypeChange
    for (final td in svt.groupedNoblePhantasms.first) {
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

  static List<NiceSkill> getShownSkills(final Servant svt, final int ascension, final int skillGroupIndex) {
    final List<NiceSkill> shownSkills = [];
    for (final skill in svt.groupedActiveSkills[skillGroupIndex]) {
      if (shownSkills.every((storeSkill) => storeSkill.id != skill.id)) {
        shownSkills.add(skill);
      }
    }

    // Servant specific
    final List<int> removeSkillIdList = [];
    if (svt.collectionNo == 1) {
      // Mash
      if (costumeOrtinaxIds.contains(ascension)) {
        if (skillGroupIndex == 0) {
          removeSkillIdList.addAll([1000, 236000]);
        } else if (skillGroupIndex == 1) {
          removeSkillIdList.addAll([2000]);
        } else {
          removeSkillIdList.addAll([133000]);
        }
      } else {
        if (skillGroupIndex == 0) {
          removeSkillIdList.addAll([459550, 744450]);
        } else if (skillGroupIndex == 1) {
          removeSkillIdList.addAll([460250]);
        } else {
          removeSkillIdList.addAll([457000, 2162350]);
        }
      }
    } else if (svt.collectionNo == 312 && skillGroupIndex == 2) {
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

  static String getSvtName(final Servant svt, final int ascension) {
    final overrideName = svt.ascensionAdd.overWriteServantName;
    if (overrideName.ascension.containsKey(ascension)) {
      return overrideName.ascension[ascension]!;
    }
    final costumes = svt.profile.costume;
    if (costumes.containsKey(ascension) && overrideName.costume.containsKey(costumes[ascension]!.id)) {
      return overrideName.costume[costumes[ascension]!.id]!;
    }
    return svt.name;
  }

  static String getSvtBattleName(final Servant svt, final int ascension) {
    final overrideName = svt.ascensionAdd.overWriteServantBattleName;
    if (overrideName.ascension.containsKey(ascension)) {
      return overrideName.ascension[ascension]!;
    }
    final costumes = svt.profile.costume;
    if (costumes.containsKey(ascension) && overrideName.costume.containsKey(costumes[ascension]!.id)) {
      return overrideName.costume[costumes[ascension]!.id]!;
    }
    return svt.battleName;
  }
}
