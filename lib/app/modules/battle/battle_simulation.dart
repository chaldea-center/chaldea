import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
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
  Widget build(BuildContext context) {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: onFieldSvtDataList
              .map((playerSvtData) => Expanded(
                    child: ServantSelector(
                      playerSvtData: playerSvtData,
                      onChange: (_) {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: backupSvtDataList
              .map((playerSvtData) => Expanded(
                    child: ServantSelector(
                      playerSvtData: playerSvtData,
                      onChange: (_) {
                        if (mounted) setState(() {});
                      },
                    ),
                  ))
              .toList(),
        ),
      ],
    ));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const AutoSizeText('Battle Simulation', maxLines: 1),
        centerTitle: false,
      ),
      body: ListView(
        children: divideTiles(
          topListChildren,
          divider: const Divider(height: 8, thickness: 2),
        ),
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
                  errorMsg = escapeDioError(e);
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
        if (errorMsg != null)
          SFooter.rich(TextSpan(text: errorMsg, style: TextStyle(color: Theme.of(context).colorScheme.error))),
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
    errorMsg = null;
    final text = questIdTextController.text.trim();
    // quest id and phase
    final match = RegExp(r'(\d+)(?:/(\d+))?').firstMatch(text);
    if (match == null) {
      errorMsg = 'Invalid quest id or url';
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
      errorMsg = 'Quest $questId not found';
      return;
    }
    if (phase == null || !quest.phases.contains(phase)) {
      // event quests released in the next day usually have no valid phase data
      phase = quest.phases.getOrNull(0) ?? 1;
    }
    questPhase = await AtlasApi.questPhase(questId, phase, hash: hash, region: region);
    if (questPhase == null) {
      errorMsg = 'Not found: /${region.upper}/quest/$questId/$phase';
      if (hash != null) errorMsg = '${errorMsg!}?hash=$hash';
    }
  }

  void _questSelectCallback(QuestPhase selected) {
    questPhase = selected;
    if (!mounted) return;
    final curRoute = ModalRoute.of(context);
    if (curRoute != null) {
      Navigator.popUntil(context, (route) => route == curRoute);
    }
    setState(() {});
  }
}

class ServantSelector extends StatelessWidget {
  static const emptyIconUrl = 'https://static.atlasacademy.io/JP/SkillIcons/skill_999999.png';
  final PlayerSvtData playerSvtData;
  final ValueChanged<Servant> onChange;

  ServantSelector({super.key, required this.playerSvtData, required this.onChange});

  @override
  Widget build(BuildContext context) {
    Widget textBuilder(TextStyle style) {
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
              child: db.getIconImage(Atlas.asset('Terminal/Info/CommonUIAtlas/icon_nplv.png'), width: 13, height: 13),
            ),
          ),
          TextSpan(text: playerSvtData.npLv.toString()),
          TextSpan(text: '\n${playerSvtData.ascension}-${playerSvtData.skillLvs.join('/')}'),
          if (playerSvtData.appendLvs.any((lv) => lv > 0))
            TextSpan(text: "\n${playerSvtData.appendLvs.map((e) => e == 0 ? '-' : e.toString()).join('/')}"),
        ]),
        textScaleFactor: 0.9,
      );
    }

    final iconImage = playerSvtData.svt == null
        ? db.getIconImage(emptyIconUrl, width: 72, aspectRatio: 132 / 144)
        : playerSvtData.svt!.iconBuilder(context: context, jumpToDetail: false, width: 72);

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
                image: iconImage,
                textBuilder: playerSvtData.svt != null ? textBuilder : null,
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
            )
          ],
        ),
      ),
    );
  }

  void _onSelectServant(final Servant selectedSvt) {
    playerSvtData.svt = selectedSvt;
    // TODO: tune playerSvtData based on user setting as default
    playerSvtData.lv = getDefaultSvtLv(selectedSvt.rarity);
    onChange(selectedSvt);
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
}