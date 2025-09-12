import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/raw.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class BonusEnemyCondPage extends StatefulWidget {
  final Event event;
  final Region region;
  const BonusEnemyCondPage({super.key, required this.event, required this.region});

  @override
  State<BonusEnemyCondPage> createState() => _BonusEnemyCondPageState();
}

class _BonusEnemyCondPageState extends State<BonusEnemyCondPage> {
  Map<int, Map<int, MstQuestHint>> mstQuestHints = {};
  Map<int, List<MstViewEnemy>> mstViewEnemies = {};
  Map<int, UserDeckFormationCond> userDeckFormationConds = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData({bool refresh = false}) async {
    final ref = widget.event.extra.script.commitRef;
    final expireAfter = refresh ? Duration.zero : null;
    final futures = [
      AtlasApi.mstData(
        'mstQuestHint',
        (json) => (json as List).map((e) => MstQuestHint.fromJson(e)).toList(),
        region: widget.region,
        expireAfter: expireAfter,
      ).then((value) {
        if (value != null) {
          mstQuestHints.clear();
          for (final hint in value) {
            mstQuestHints.putIfAbsent(hint.questId, () => {})[hint.questPhase] = hint;
          }
        }
        if (mounted) setState(() {});
      }),
      AtlasApi.mstData(
        'viewEnemy',
        (json) => (json as List).map((e) => MstViewEnemy.fromJson(e)).toList(),
        region: widget.region,
        expireAfter: expireAfter,
        ref: ref,
      ).then((value) {
        if (value != null) {
          mstViewEnemies.clear();
          for (final enemy in value) {
            mstViewEnemies.putIfAbsent(enemy.questId, () => []).add(enemy);
          }
        }
        if (mounted) setState(() {});
      }),
      AtlasApi.mstData(
        'mstUserDeckFormationCond',
        (json) => (json as List).map((e) => UserDeckFormationCond.fromJson(e)).toList(),
        region: widget.region,
        expireAfter: expireAfter,
        ref: ref,
      ).then((value) {
        if (value != null) {
          userDeckFormationConds.clear();
          for (final cond in value) {
            userDeckFormationConds[cond.id] = cond;
          }
        }
        if (mounted) setState(() {});
      }),
    ];
    await showEasyLoading(() => Future.wait(futures));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    List<(Quest quest, List<MstViewEnemy> enemies)> quests = [];
    for (final quest in widget.event.warIds.expand((e) => db.gameData.wars[e]?.quests ?? <Quest>[])) {
      if (!quest.isAnyFree) continue;
      final enemies =
          mstViewEnemies[quest.id]?.where((e) => (e.entryByUserDeckFormationCondId ?? 0) != 0).toList() ?? [];
      if (enemies.isNotEmpty) {
        quests.add((quest, enemies));
      }
    }
    quests.sortByList((e) => <int>[e.$1.id]);

    for (final (quest, enemies) in quests) {
      children.add(buildGroup(quest, enemies));
    }
    final usedCondIds = quests.expand((e) => e.$2).map((e) => e.entryByUserDeckFormationCondId ?? 0).toSet();
    final unusedConds = userDeckFormationConds.values.where((e) => !usedCondIds.contains(e.id)).toList();
    children.add(buildUnknownGroup(unusedConds));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bonus Enemy Conditions"),
        actions: [
          IconButton(
            onPressed: () {
              SimpleConfirmDialog(
                title: Text(S.current.refresh),
                onTapOk: () {
                  loadData(refresh: true);
                },
              ).showDialog(context);
            },
            icon: const Icon(Icons.refresh),
            tooltip: S.current.refresh,
          ),
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => const Divider(height: 16),
        itemCount: children.length,
      ),
    );
  }

  Widget buildGroup(Quest quest, List<MstViewEnemy> enemies) {
    enemies.sort2((e) => e.enemyId);
    List<Widget> children = [
      ListTile(
        dense: true,
        selected: true,
        selectedTileColor: Theme.of(context).secondaryHeaderColor,
        leading: db.getIconImage(quest.spot?.shownImage),
        title: Text(quest.lDispName),
        subtitle: Text('Lv.${quest.recommendLv} ${quest.lSpot.l}'),
        onTap: quest.routeTo,
      ),
    ];

    String hint = mstQuestHints[quest.id]?.values.firstOrNull?.message ?? "";
    hint = hint.trim().replaceAll('\n', ' ');
    if (hint.isNotEmpty) {
      children.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(hint, style: Theme.of(context).textTheme.bodySmall),
        ),
      );
    }

    for (final enemy in enemies) {
      final condId = enemy.entryByUserDeckFormationCondId;
      assert(condId != null && condId != 0);
      if (condId == null) continue;
      children.add(const Divider(indent: 16, endIndent: 16));
      children.add(
        ListTile(
          dense: true,
          leading: db.getIconImage(AssetURL.i.enemyId(enemy.iconId)),
          title: Text('${S.current.enemy}: ${enemy.name}'),
          subtitle: Text(Transl.svtClassId(enemy.classId).l),
          onTap: () {
            router.push(url: Routes.servantI(enemy.svtId));
          },
        ),
      );
      final cond = userDeckFormationConds[enemy.entryByUserDeckFormationCondId];
      if (cond == null) {
        children.add(ListTile(title: Text("Unknown UserDeckFormationCondId $condId")));
      } else {
        children.add(buildTargetSvts(context, cond));
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget buildUnknownGroup(List<UserDeckFormationCond> conds) {
    if (conds.isEmpty) return const SizedBox.shrink();
    List<Widget> children = [
      ListTile(
        dense: true,
        // selected: true,
        tileColor: Theme.of(context).cardColor,
        leading: db.getIconImage(null),
        title: const Text("Unused UserDeckFormationConds"),
      ),
    ];
    for (final cond in conds) {
      children.add(buildTargetSvts(context, cond));
    }

    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  static Widget buildTargetSvts(BuildContext context, UserDeckFormationCond cond) {
    List<Widget> cards = [
      Container(
        padding: const EdgeInsets.all(4),
        // decoration: BoxDecoration(
        //     border: Border.all(color: Theme.of(context).colorScheme.primary), borderRadius: BorderRadius.circular(4)),
        child: Text("Cond ${cond.id}: ", style: const TextStyle(fontSize: 12)),
      ),
    ];

    for (final trait in cond.targetVals) {
      Servant? svt0 = db.gameData.servantsById[trait];
      if (svt0 != null) {
        cards.add(svt0.iconBuilder(context: context, width: 36));
        continue;
      }
      final svt1 = db.gameData.entities[trait];
      if (svt1 != null) {
        cards.add(svt1.iconBuilder(context: context, width: 36));
        continue;
      }
      cards.add(
        InkWell(
          onTap: () {
            router.push(url: Routes.traitI(trait));
          },
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(Transl.traitName(trait), style: const TextStyle(fontSize: 12)),
          ),
        ),
      );
      if (trait == Trait.havingAnimalsCharacteristics.value) continue;
      final svts = db.gameData.servantsById.values
          .where((svt) => svt.traitAdd.expand((e) => e.trait).contains(trait))
          .toList();
      svts.sort(
        (a, b) => SvtFilterData.compare(
          a,
          b,
          keys: [SvtCompare.className, SvtCompare.rarity, SvtCompare.no],
          reversed: [false, true, true],
        ),
      );
      for (final svt in svts) {
        cards.add(svt.iconBuilder(context: context, width: 32));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.end,
        // runAlignment: ,
        children: cards,
      ),
    );
  }
}

class UserDeckFormationCondDetailPage extends StatefulWidget {
  final QuestEnemy? enemy;
  final int? condId;
  final UserDeckFormationCond? cond;

  const UserDeckFormationCondDetailPage({super.key, this.enemy, this.condId, this.cond});

  @override
  State<UserDeckFormationCondDetailPage> createState() => _UserDeckFormationCondDetailPageState();
}

class _UserDeckFormationCondDetailPageState extends State<UserDeckFormationCondDetailPage> {
  UserDeckFormationCond? cond;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    cond = widget.cond;
    final condId = widget.condId ?? 0;
    if (cond == null && condId > 0) {
      final conds = await showEasyLoading(
        () => AtlasApi.mstData(
          'mstUserDeckFormationCond',
          (json) => (json as List).map((e) => UserDeckFormationCond.fromJson(e)).toList(),
        ),
      );
      cond = conds?.firstWhereOrNull((e) => e.id == condId);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final enemy = widget.enemy;
    return Scaffold(
      appBar: AppBar(title: Text("Cond ${widget.cond?.id ?? widget.condId}")),
      body: ListView(
        children: [
          if (enemy != null)
            ListTile(
              dense: true,
              leading: db.getIconImage(enemy.icon),
              title: Text(enemy.name),
              subtitle: Text(Transl.svtClassId(enemy.svt.classId).l),
              onTap: enemy.routeTo,
            ),
          if (cond != null) _BonusEnemyCondPageState.buildTargetSvts(context, cond!),
        ],
      ),
    );
  }
}
