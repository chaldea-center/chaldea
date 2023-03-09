import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/modules/quest/quest_card.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/atlas.dart';
import 'package:chaldea/widgets/widgets.dart';

class SimulationPreview extends StatefulWidget {
  final Region region;
  final Quest? quest;
  final int? phase;

  const SimulationPreview({
    super.key,
    this.region = Region.jp,
    this.quest,
    this.phase,
  });

  @override
  State<SimulationPreview> createState() => _SimulationPreviewState();
}

class _SimulationPreviewState extends State<SimulationPreview> {
  Quest? quest;

  late TextEditingController questIdTextController;
  late TextEditingController phaseTextController;

  @override
  void initState() {
    super.initState();

    quest = widget.quest;
    questIdTextController = TextEditingController(text: widget.quest != null ? widget.quest!.id.toString() : '');
    phaseTextController = TextEditingController(text: widget.phase != null ? widget.phase!.toString() : '1');
  }

  @override
  void dispose() {
    super.dispose();

    questIdTextController.dispose();
    phaseTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> topListChildren = [];
    topListChildren.add(
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Quest ID: '),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: TextFormField(
                controller: questIdTextController,
              ),
            ),
          ),
          const Text('Phase: '),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: TextFormField(
                controller: phaseTextController,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _fetchQuestPhase();
            },
            child: const Text('Fetch'),
          ),
        ],
      ),
    );

    final phase = int.tryParse(phaseTextController.text);
    if (quest == null || phase == null) {
      final questId = int.tryParse(questIdTextController.text);
      topListChildren.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('The quest phase either is not provided or is invalid.'),
            Text('$questId + $phase'),
          ],
        ),
      );
    } else {
      topListChildren.add(QuestCard(
        region: widget.region,
        offline: false,
        quest: quest,
        displayPhases: [quest!.phases.contains(phase) ? phase : quest!.phases.first],
        battleOnly: true,
      ));
    }

    final List<ServantSelector> onFieldSvtSelectors = [
      ServantSelector(),
      ServantSelector(),
      ServantSelector(),
    ];

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
          children: onFieldSvtSelectors.map((e) => Expanded(child: e)).toList(),
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

  void _fetchQuestPhase() async {
    final questId = int.tryParse(questIdTextController.text);
    final phase = int.tryParse(phaseTextController.text);
    if (questId == null || phase == null) {
      quest = null;
    } else {
      await AtlasApi.quest(questId, region: widget.region).then((fetchedQuest) => quest = fetchedQuest);
      if (widget.region == Region.jp) {
        quest ??= db.gameData.getQuestPhase(questId, phase);
      }
    }
    if (mounted) setState(() {});
  }
}

class ServantSelector extends StatefulWidget {
  ServantSelector({super.key});

  @override
  State<ServantSelector> createState() => _ServantSelectorState();

  void getServant() {
    // TODO: figure out how to get the selected svt from State......
  }
}

class _ServantSelectorState extends State<ServantSelector> {
  Servant? svt;
  final PlayerSvtData playerSvtData = PlayerSvtData(-1);

  static const emptyIconUrl = 'https://static.atlasacademy.io/JP/SkillIcons/skill_999999.png';

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

    final iconImage = svt == null
        ? db.getIconImage(emptyIconUrl, width: 72, aspectRatio: 132 / 144)
        : svt!.iconBuilder(context: context, jumpToDetail: false, width: 72);

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
                textBuilder: svt != null ? textBuilder : null,
                option: ImageWithTextOption(
                  shadowSize: 4,
                  textStyle: const TextStyle(fontSize: 11, color: Colors.black),
                  shadowColor: Colors.white,
                  alignment: AlignmentDirectional.bottomStart,
                  padding: const EdgeInsets.fromLTRB(4, 0, 2, 4),
                ),
                onTap: () {
                  print('I touched this');
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

  void _onSelectServant(final Servant selectedSVt) {
    svt = selectedSVt;
    // TODO: tune playerSvtData based on user setting as default
    playerSvtData.lv = getDefaultSvtLv(selectedSVt.rarity);

    if (mounted) setState(() {});
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
