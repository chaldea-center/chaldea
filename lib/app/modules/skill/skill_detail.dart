import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:ruby_text/ruby_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/enemy/quest_enemy_summary.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';

class SkillDetailPage extends StatefulWidget {
  final int? id;
  final BaseSkill? skill;
  final Region? region;
  const SkillDetailPage({super.key, this.id, this.skill, this.region}) : assert(id != null || skill != null);

  @override
  State<SkillDetailPage> createState() => _SkillDetailPageState();
}

class _SkillDetailPageState extends State<SkillDetailPage> with RegionBasedState<BaseSkill, SkillDetailPage> {
  int get id => widget.skill?.id ?? widget.id ?? data?.id ?? -1;
  BaseSkill get skill => data!;

  @override
  void initState() {
    super.initState();
    region = widget.region ?? (widget.skill == null ? Region.jp : null);
    doFetchData();
  }

  @override
  Future<BaseSkill?> fetchData(Region? r) async {
    BaseSkill? v;
    if (r == null || r == widget.region) v = widget.skill;
    if (r == Region.jp) {
      v ??= db.gameData.baseSkills[id];
    }
    v ??= await AtlasApi.skill(id, region: r ?? Region.jp);
    return v;
  }

  @override
  Widget build(BuildContext context) {
    return InheritSelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            data?.lName.l ?? '${S.current.skill} $id',
            overflow: TextOverflow.fade,
            maxLines: 1,
            minFontSize: 14,
          ),
          actions: [
            dropdownRegion(shownNone: widget.skill != null),
            popupMenu,
          ],
        ),
        body: buildBody(context),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, BaseSkill skill) {
    final svts = ReverseGameData.skill2Svt(id).toList()..sort2((e) => e.collectionNo);
    final ces = ReverseGameData.skill2CE(id).toList()..sort2((e) => e.collectionNo);
    final ccs = ReverseGameData.skill2CC(id).toList()..sort2((e) => e.collectionNo);
    final mcs = ReverseGameData.skill2MC(id).toList()..sort2((e) => e.id);
    final enemies =
        ReverseGameData.questEnemies((e) => e.skills.skillIds.contains(id) || e.classPassive.containSkill(id));

    return ListView(
      children: [
        CustomTable(children: [
          CustomTableRow.fromTexts(texts: ['No.${skill.id}'], isHeader: true),
          CustomTableRow.fromChildren(children: [
            RubyText(
              [RubyTextData(skill.name, ruby: skill.ruby)],
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )
          ]),
          SkillDescriptor(
            skill: skill,
            showEnemy: true,
            showNone: true,
            jumpToDetail: false,
            region: region,
          ),
          CustomTableRow(children: [
            TableCellData(text: S.current.general_type, isHeader: true),
            TableCellData(flex: 2, text: skill.type.name)
          ]),
        ]),
        if (svts.isNotEmpty) cardList(S.current.servant, svts),
        if (ces.isNotEmpty) cardList(S.current.craft_essence, ces),
        if (ccs.isNotEmpty) cardList(S.current.command_code, ccs),
        if (mcs.isNotEmpty) cardList(S.current.mystic_code, mcs),
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
      itemBuilder: (context) => SharedBuilder.websitesPopupMenuItems(atlas: Atlas.dbSkill(id, region ?? Region.jp)),
    );
  }
}
