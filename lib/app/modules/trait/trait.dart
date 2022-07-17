import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../enemy/quest_enemy_summary.dart';

class TraitDetailPage extends StatefulWidget {
  final int id;
  const TraitDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  State<TraitDetailPage> createState() => _TraitDetailPageState();
}

class _TraitDetailPageState extends State<TraitDetailPage>
    with SingleTickerProviderStateMixin {
  int get id => widget.id;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String name = Transl.trait(id).l;
    String title = '${S.current.info_trait} $id';
    if (name != id.toString()) {
      title += ' - $name';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: FixedHeight.tabBar(
            TabBar(isScrollable: true, controller: _tabController, tabs: [
          Tab(text: S.current.servant),
          Tab(text: S.current.enemy),
          Tab(text: S.current.super_effective_damage),
        ])),
      ),
      body: ListTileTheme(
        data: const ListTileThemeData(horizontalTitleGap: 8),
        child: TabBarView(
          controller: _tabController,
          children: [
            _ServantTab(id),
            _EnemyTab(id),
            _BuffSE(id),
          ],
        ),
      ),
    );
  }
}

class _ServantTab extends StatelessWidget {
  final int id;
  const _ServantTab(this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Servant> servants = db.gameData.servants.values
        .where((svt) => svt.traitsAll.contains(id))
        .toList();
    servants.sort2((e) => e.collectionNo);
    if (servants.isEmpty) return const Center(child: Text('No record'));
    return ListView.builder(
      itemBuilder: (context, index) {
        final svt = servants[index];
        List<String> details = [];
        bool isCommon = _addComment([
          ...svt.traits,
          for (final traitAdd in svt.traitAdd)
            if (traitAdd.idx == 1) ...traitAdd.trait
        ], id, '')
            .isNotEmpty;
        if (!isCommon) {
          for (final asc in svt.ascensionAdd.individuality.ascension.keys) {
            details.addAll(_addComment(
              svt.ascensionAdd.individuality.ascension[asc]!,
              id,
              '${S.current.ascension_short} $asc',
            ));
          }
          for (final costumeId in svt.ascensionAdd.individuality.costume.keys) {
            final costumeName =
                svt.profile.costume[costumeId]?.lName.l ?? costumeId.toString();
            details.addAll(_addComment(
              svt.ascensionAdd.individuality.costume[costumeId]!,
              id,
              costumeName,
            ));
          }
          for (final traitAdd in svt.traitAdd) {
            if (traitAdd.idx == 1) continue;
            final event = db.gameData.events[traitAdd.idx ~/ 100];
            String name = traitAdd.idx.toString();
            if (event != null) {
              name += '(${event.lName.l})';
            }
            details.addAll(_addComment(traitAdd.trait, id, name));
          }
        }

        return ListTile(
          dense: true,
          leading: svt.iconBuilder(context: context),
          title: Text('No.${svt.collectionNo}-${svt.lName.l}'),
          subtitle: details.isEmpty
              ? null
              : Text(details.join(' / '), textScaleFactor: 0.9),
          onTap: () => svt.routeTo(),
        );
      },
      itemCount: servants.length,
    );
  }
}

List<String> _addComment(List<NiceTrait> traits, int id, String comment) {
  List<String> comments = [];
  traits = traits.where((e) => e.id == id).toList();
  if (traits.isEmpty) return [];
  if (traits.any((e) => e.negative)) {
    comments.add('$comment(NOT)');
  }
  if (traits.any((e) => !e.negative)) {
    comments.add(comment);
  }
  return comments;
}

class _EnemyTab extends StatelessWidget {
  final int id;
  const _EnemyTab(this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<QuestEnemy> allEnemies = [];
    for (final quest in db.gameData.questPhases.values) {
      allEnemies.addAll(quest.allEnemies
          .where((enemy) => enemy.traits.any((e) => e.id == id)));
    }
    Map<int, List<QuestEnemy>> grouped = {};
    for (final enemy in allEnemies) {
      grouped.putIfAbsent(enemy.svt.id, () => []).add(enemy);
    }
    final svtIds = grouped.keys.toList()..sort();
    if (svtIds.isEmpty) return const Center(child: Text('No record'));
    return ListView.builder(
      itemBuilder: (context, index) {
        final enemies = grouped[svtIds[index]]!;
        final enemy = enemies.first;
        return ListTile(
          leading: enemy.svt.iconBuilder(context: context, jumpToDetail: false),
          title: Text(enemy.svt.lName.l),
          subtitle: Text([
            if (!Transl.isJP) enemy.svt.name,
            'No.${enemy.svt.id} ${Transl.svtClass(enemy.svt.className).l}'
          ].join('\n')),
          dense: true,
          onTap: () {
            router.pushPage(
                QuestEnemySummaryPage(svt: enemy.svt, enemies: enemies));
          },
        );
      },
      itemCount: svtIds.length,
    );
  }
}

enum _BuffSEScope {
  active,
  td,
  passive,
  // append, // buff upAtk
  tdSE,
  ce,
  cc,
}

class _BuffSE extends StatefulWidget {
  final int id;
  const _BuffSE(this.id, {Key? key}) : super(key: key);

  @override
  State<_BuffSE> createState() => __BuffSEState();
}

class __BuffSEState extends State<_BuffSE> {
  int get id => widget.id;

  final filter = FilterGroupData<_BuffSEScope>();

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (final svt in db.gameData.servants.values.toList()
      ..sort2((e) => e.collectionNo)) {
      if (filter.matchOne(_BuffSEScope.active)) {
        children.addAll(checkSkills(svt, svt.skills));
      }
      if (filter.matchOne(_BuffSEScope.td)) {
        children.addAll(checkSkills(svt, svt.noblePhantasms));
      }
      if (filter.matchOne(_BuffSEScope.passive)) {
        children.addAll(checkSkills(svt, svt.classPassive));
      }
      // if (filter.matchOne(_BuffSEScope.append)) {
      //   children.addAll(
      //       checkSkills(svt, svt.appendPassive.map((e) => e.skill).toList()));
      // }
      if (filter.matchOne(_BuffSEScope.tdSE)) {
        children.addAll(checkTdSE(svt, svt.noblePhantasms));
      }
    }
    if (filter.matchOne(_BuffSEScope.ce)) {
      for (final ce in db.gameData.craftEssences.values.toList()
        ..sort2((e) => e.collectionNo)) {
        children.addAll(checkSkills(ce, ce.skills));
      }
    }
    if (filter.matchOne(_BuffSEScope.cc)) {
      for (final cc in db.gameData.commandCodes.values.toList()
        ..sort2((e) => e.collectionNo)) {
        children.addAll(checkSkills(cc, cc.skills));
      }
    }

    return Column(
      children: [
        buttons,
        Expanded(
          child: children.isEmpty
              ? const Center(child: Text('No record'))
              : ListView.builder(
                  itemBuilder: (context, index) => children[index],
                  itemCount: children.length,
                ),
        ),
      ],
    );
  }

  Widget get buttons {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for (final scopes in [
          [
            _BuffSEScope.active,
            _BuffSEScope.td,
            _BuffSEScope.passive,
            // _BuffSEScope.append
          ],
          [_BuffSEScope.tdSE],
          [_BuffSEScope.ce, _BuffSEScope.cc]
        ])
          FilterGroup<_BuffSEScope>(
            options: scopes,
            values: filter,
            optionBuilder: (v) {
              switch (v) {
                case _BuffSEScope.active:
                  return Text(S.current.active_skill_short);
                case _BuffSEScope.td:
                  return Text(S.current.np_short);
                case _BuffSEScope.passive:
                  return Text(S.current.passive_skill_short);
                // case _BuffSEScope.append:
                //   return Text(S.current.append_skill_short);
                case _BuffSEScope.tdSE:
                  return Text('${S.current.np_short}(D)');
                case _BuffSEScope.ce:
                  return Text(S.current.craft_essence);
                case _BuffSEScope.cc:
                  return Text(S.current.command_code);
              }
            },
            combined: true,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            onFilterChanged: (v, _) {
              setState(() {});
            },
          )
      ],
    );
  }

  List<Widget> checkSkills(GameCardMixin card, List<SkillOrTd> skills) {
    List<Widget> children = [];
    for (final skill in skills) {
      for (final func in skill.functions) {
        if (func.buffs.isEmpty) continue;
        final buff = func.buffs.first;
        if (![
          BuffType.upDamage,
          BuffType.upDamageIndividuality, // not used yet
          BuffType.upDamageIndividualityActiveonly,
        ].contains(buff.type)) {
          continue;
        }
        if (buff.ckOpIndv.any((e) => e.id == id)) {
          children.add(_buildRow(card, skill));
        }
      }
    }
    return children;
  }

  List<Widget> checkTdSE(GameCardMixin card, List<NiceTd> tds) {
    List<Widget> children = [];
    for (final td in tds) {
      for (final func in td.functions) {
        if (![
          FuncType.damageNpIndividual,
          FuncType.damageNpIndividualSum,
          FuncType.damageNpStateIndividual,
          FuncType.damageNpStateIndividualFix,
        ].contains(func.funcType)) {
          continue;
        }
        final vals = func.svals.getOrNull(0);
        if (vals == null) continue;
        bool matched = false;
        switch (func.funcType) {
          case FuncType.damageNpIndividual:
          case FuncType.damageNpStateIndividualFix:
            matched = vals.Target == id;
            break;
          case FuncType.damageNpIndividualSum:
            matched = vals.TargetList?.contains(id) == true;
            break;
          case FuncType.damageNpStateIndividual:
            // not used
            break;
          default:
            break;
        }
        if (matched) {
          children.add(_buildRow(card, td));
        }
      }
    }
    return children;
  }

  Widget _buildRow(GameCardMixin card, SkillOrTd skill) {
    return ListTile(
      leading: card.iconBuilder(context: context, jumpToDetail: false),
      title: Text(skill.lName.l, textScaleFactor: 0.9),
      subtitle: Text(skill.lDetail ?? '???', textScaleFactor: 0.9),
      dense: true,
      onTap: () {
        card.routeTo();
      },
    );
  }
}
