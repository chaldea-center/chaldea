import 'dart:async';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../enemy/quest_enemy_summary.dart';

class TdDetailPage extends StatefulWidget {
  final int? id;
  final BaseTd? td;
  final Region? region;
  const TdDetailPage({super.key, this.id, this.td, this.region}) : assert(id != null || td != null);

  @override
  State<TdDetailPage> createState() => _TdDetailPageState();
}

class _TdDetailPageState extends State<TdDetailPage> with RegionBasedState<BaseTd, TdDetailPage> {
  int get id => widget.td?.id ?? widget.id ?? data?.id ?? -1;
  BaseTd get td => data!;

  int? _lv;
  int? _oc;

  @override
  void initState() {
    super.initState();
    region = widget.region ?? (widget.td == null ? Region.jp : null);
    doFetchData();
  }

  @override
  Future<BaseTd?> fetchData(Region? r) async {
    BaseTd? v;
    if (r == null || r == widget.region) v = widget.td;
    if (r == Region.jp) {
      v ??= db.gameData.baseTds[id];
    }
    v ??= await AtlasApi.td(id, region: r ?? Region.jp);
    return v;
  }

  @override
  Widget build(BuildContext context) {
    return InheritSelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            data?.lName.l ?? '${S.current.noble_phantasm} $id',
            overflow: TextOverflow.fade,
          ),
          actions: [
            dropdownRegion(shownNone: widget.td != null),
            popupMenu,
          ],
        ),
        body: buildBody(context),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, BaseTd td) {
    final svts = ReverseGameData.td2Svt(id).toList()..sort2((e) => e.collectionNo);
    final enemies = ReverseGameData.questEnemies((e) => e.noblePhantasm.noblePhantasmId == id);
    _lv = (_lv ?? td.maxLv).clamp2(1, td.maxLv);
    _oc = (_oc ?? 1).clamp2(1, td.maxOC);
    return ListView(
      children: [
        CustomTable(children: [
          CustomTableRow.fromTexts(texts: ['No.${td.id}'], isHeader: true),
          CustomTableRow.fromChildren(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  isDense: true,
                  items: [
                    for (int level = 1; level <= td.maxLv; level++)
                      DropdownMenuItem(value: level, child: Text('Lv.$level')),
                  ],
                  value: _lv,
                  onChanged: (v) {
                    setState(() {
                      _lv = v;
                    });
                  },
                ),
                const SizedBox(width: 24),
                DropdownButton<int>(
                  isDense: true,
                  items: [
                    for (int level = 1; level <= td.maxLv; level++)
                      DropdownMenuItem(value: level, child: Text('OC $level')),
                  ],
                  value: _oc,
                  onChanged: (v) {
                    setState(() {
                      _oc = v;
                    });
                  },
                ),
              ],
            )
          ]),
          TdDescriptor(
            td: td,
            level: _lv,
            oc: _oc,
            showEnemy: true,
            showNone: true,
            jumpToDetail: false,
            region: region,
            isBaseTd: true,
          ),
          CustomTableRow(children: [
            TableCellData(text: S.current.trait, isHeader: true),
            TableCellData(
              flex: 3,
              child: SharedBuilder.traitList(context: context, traits: td.individuality),
            )
          ]),
        ]),
        if (svts.isNotEmpty) cardList(S.current.servant, svts),
        if (enemies.isNotEmpty) enemyList(enemies),
      ],
    );
  }

  Widget cardList(String header, List<GameCardMixin> cards) {
    return TileGroup(
      header: header,
      children: [
        for (final card in cards)
          ListTile(
            dense: true,
            leading: card.iconBuilder(context: context),
            title: Text(card.lName.l),
            onTap: card.routeTo,
          )
      ],
    );
  }

  Widget enemyList(Map<int, List<QuestEnemy>> allEnemies) {
    List<Widget> children = [];
    for (final enemies in allEnemies.values) {
      if (enemies.isEmpty) continue;
      final enemy = enemies.first;
      children.add(ListTile(
        dense: true,
        leading: enemy.iconBuilder(context: context),
        title: Text(enemy.lName.l),
        onTap: () {
          router.pushPage(QuestEnemySummaryPage(svt: enemy.svt, enemies: enemies));
        },
      ));
    }
    return TileGroup(
      header: '${S.current.enemy_list}(${S.current.free_quest})',
      children: children,
    );
  }

  Widget get popupMenu {
    return PopupMenuButton(
      itemBuilder: (context) => SharedBuilder.websitesPopupMenuItems(atlas: Atlas.dbTd(id, region ?? Region.jp)),
    );
  }
}
