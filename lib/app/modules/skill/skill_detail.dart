import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/enemy/quest_enemy_summary.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/filter_group.dart';

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

  int? _lv;
  FuncApplyTarget _view = FuncApplyTarget.playerAndEnemy;

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
    _lv = (_lv ?? skill.maxLv).clamp2(1, skill.maxLv);

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
          CustomTableRow.fromChildren(children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                DropdownButton<int>(
                  isDense: true,
                  items: [
                    for (int level = 1; level <= skill.maxLv; level++)
                      DropdownMenuItem(value: level, child: Text('Lv.$level')),
                  ],
                  value: _lv,
                  onChanged: (v) {
                    setState(() {
                      _lv = v;
                    });
                  },
                ),
                FilterGroup(
                  padding: EdgeInsets.zero,
                  combined: true,
                  options: const [FuncApplyTarget.playerAndEnemy, FuncApplyTarget.player, FuncApplyTarget.enemy],
                  values: FilterRadioData.nonnull(_view),
                  optionBuilder: (v) {
                    switch (v) {
                      case FuncApplyTarget.player:
                        return Text(S.current.player);
                      case FuncApplyTarget.enemy:
                        return Text(S.current.enemy);
                      case FuncApplyTarget.playerAndEnemy:
                        return Text(S.current.general_all);
                    }
                  },
                  onFilterChanged: (v, _) {
                    setState(() {
                      _view = v.radioValue ?? _view;
                    });
                  },
                ),
              ],
            )
          ]),
          SkillDescriptor(
            skill: skill,
            showPlayer: _view == FuncApplyTarget.playerAndEnemy || _view == FuncApplyTarget.player,
            showEnemy: _view == FuncApplyTarget.playerAndEnemy || _view == FuncApplyTarget.enemy,
            showNone: true,
            jumpToDetail: false,
            level: _lv,
            region: region,
          ),
          CustomTableRow(children: [
            TableCellData(text: S.current.general_type, isHeader: true),
            TableCellData(flex: 2, text: skill.type.name)
          ]),
          CustomTableRow.fromTexts(texts: [
            'num ${skill.svt.num} / priority ${skill.svt.priority} / strengthStatus ${skill.svt.strengthStatus}'
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
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: data != null,
          onTap: () async {
            try {
              final text = const JsonEncoder.withIndent('  ').convert(skill);
              // ignore: use_build_context_synchronously
              await FilePickerU.saveFile(
                dialogContext: context,
                data: utf8.encode(text),
                filename: "skill-${skill.id}-${DateTime.now().toSafeFileName()}.json",
              );
            } catch (e, s) {
              EasyLoading.showError(e.toString());
              logger.e('dump skill json failed', e, s);
              return;
            }
          },
          child: Text('${S.current.general_export} JSON'),
        ),
        ...SharedBuilder.websitesPopupMenuItems(atlas: Atlas.dbSkill(id, region ?? Region.jp)),
      ],
    );
  }
}
