import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../widgets/region_based.dart';
import '../../api/atlas.dart';
import '../../app.dart';
import '../common/builders.dart';
import 'ai_table.dart';

class AiPage extends StatefulWidget {
  final AiType aiType;
  final int? aiId;
  final NiceAiCollection? aiCollection;
  final Region? region;
  final EnemySkill? skills;
  final EnemyTd? td;

  final bool bodyOnly;

  const AiPage({
    super.key,
    required this.aiType,
    required this.aiId,
    this.aiCollection,
    this.region,
    this.skills,
    this.td,
    this.bodyOnly = false,
  });

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> with RegionBasedState<NiceAiCollection, AiPage> {
  int get id => widget.aiId ?? 0;
  NiceAiCollection get aiCollection => data!;

  final Map<int, GlobalKey> _keys = {};
  late final scrollController = ScrollController();

  GlobalKey getAiKey(int aiId) {
    return _keys.putIfAbsent(aiId, () => GlobalKey(debugLabel: 'AI $aiId'));
  }

  @override
  void initState() {
    super.initState();
    region = widget.region ?? (widget.aiCollection == null ? Region.jp : null);
    doFetchData();
  }

  @override
  Future<NiceAiCollection?> fetchData(Region? r, {Duration? expireAfter}) async {
    NiceAiCollection? v;
    if (r == null || r == widget.region) v = widget.aiCollection;
    if (id <= 0) return v;
    v ??= await AtlasApi.ai(widget.aiType, id, region: r ?? Region.jp, expireAfter: expireAfter);
    return v;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bodyOnly) return buildBody(context);
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          '${widget.aiType.name.toUpperCase()} AI $id',
          overflow: TextOverflow.fade,
          maxLines: 1,
          minFontSize: 14,
        ),
        actions: [
          dropdownRegion(shownNone: widget.aiCollection != null),
          popupMenu,
        ],
      ),
      body: buildBody(context),
    );
  }

  Widget get popupMenu {
    return PopupMenuButton(
      itemBuilder: (context) => [
        ...SharedBuilder.websitesPopupMenuItems(
          atlas: Atlas.ai(
            id,
            widget.aiType == AiType.svt,
            region: region ?? Region.jp,
            skillId1: widget.skills?.skillId1 ?? 0,
            skillId2: widget.skills?.skillId2 ?? 0,
            skillId3: widget.skills?.skillId3 ?? 0,
          ),
        ),
        PopupMenuItem(
          child: const Text("How to read AI?"),
          onTap: () {
            launch("https://apps.atlasacademy.io/db/JP/faq#svt-field-ai");
          },
        )
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context, NiceAiCollection aiCollection) {
    List<Widget> children = [];

    final parentAis = aiCollection.mainAis.firstOrNull?.parentAis ?? {};

    children.add(CustomTable(children: [
      CustomTableRow(
        children: [
          TableCellData(text: "Parent AI", isHeader: true),
          TableCellData(
            flex: 3,
            child: Wrap(
              spacing: 4,
              children: [
                if (parentAis.values.every((e) => e.isEmpty)) const Text('-'),
                for (final entry in parentAis.entries)
                  for (final aiId in entry.value) AiLink(type: entry.key, aiId: aiId, region: region)
              ],
            ),
          )
        ],
      ),
      CustomTableRow(
        children: [
          TableCellData(text: S.current.quest, isHeader: true),
          TableCellData(
            flex: 3,
            child: Wrap(
              spacing: 4,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final link in aiCollection.relatedQuests.take(5))
                  Text.rich(SharedBuilder.textButtonSpan(
                    context: context,
                    text: db.gameData.quests[link.questId]?.lNameWithChapter ?? "Quest ${link.questId}",
                    onTap: () {
                      router.push(url: Routes.questI(link.questId, link.phase));
                    },
                  )),
                if (aiCollection.relatedQuests.length > 5 || widget.aiType == AiType.svt)
                  TextButton(
                    onPressed: () {
                      launch(Uri.parse("https://apps.atlasacademy.io/db/JP/quests").replace(queryParameters: {
                        if (widget.aiType == AiType.svt) "enemySvtAiId": id.toString(),
                        if (widget.aiType == AiType.field) "fieldAiId": id.toString(),
                      }).toString());
                    },
                    child: Text(S.current.show_more, textScaler: const TextScaler.linear(0.8)),
                  ),
              ],
            ),
          )
        ],
      ),
    ]));

    final allAis = <int, Map<String, NiceAi>>{};
    for (final ai in [...aiCollection.mainAis, ...aiCollection.relatedAis]) {
      allAis.putIfAbsent(ai.id, () => {}).putIfAbsent(ai.primaryKey, () => ai);
    }
    for (final entry in allAis.entries) {
      final ais = NiceAiCollection.sortedAis(entry.value.values.toList());
      children.add(AiTable(
        key: getAiKey(entry.key),
        type: widget.aiType,
        ais: ais,
        region: region,
        skills: widget.skills,
        td: widget.td,
        onClickNextAi: onClickNextAi,
      ));
    }
    return SingleChildScrollView(
      controller: scrollController,
      child: ListBody(children: children),
    );
  }

  void onClickNextAi(int nextAiId) {
    final key = getAiKey(nextAiId);
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    if (scrollController.hasClients && scrollController.position.hasContentDimensions) {
      scrollController.position.ensureVisible(box, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }
}

class AiLink extends StatelessWidget {
  final AiType type;
  final int aiId;
  final Region? region;

  const AiLink({super.key, required this.type, required this.aiId, this.region});

  static TextSpan span({required BuildContext context, required AiType type, required int aiId, Region? region}) {
    return SharedBuilder.textButtonSpan(
      context: context,
      text: "${type.name}-$aiId",
      onTap: () {
        router.push(url: Routes.aiI(type, aiId), region: region);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        router.push(url: Routes.aiI(type, aiId), region: region);
      },
      child: Text(
        "${type.name}-$aiId",
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
