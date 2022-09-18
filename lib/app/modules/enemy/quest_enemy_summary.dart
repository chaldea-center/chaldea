import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/quest/quest_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class QuestEnemySummaryPage extends StatelessWidget {
  final BasicServant svt;
  final List<QuestEnemy> enemies;
  const QuestEnemySummaryPage(
      {super.key, required this.svt, required this.enemies});

  List<T> _getValues<T>(T Function(QuestEnemy e) prop,
      [int Function(T a)? compare]) {
    final values = enemies.map((e) => prop(e)).toSet().toList();
    if (compare != null) {
      values.sort((a, b) => compare(a).compareTo(compare(b)));
    } else {
      values.sort();
    }
    return values;
  }

  @override
  Widget build(BuildContext context) {
    final attributes = _getValues<Attribute>(
            (e) => e.svt.attribute, (v) => Attribute.values.indexOf(v)),
        charges = _getValues((e) => e.chargeTurn),
        deathRates = _getValues((e) => e.deathRate),
        critRates = _getValues((e) => e.criticalRate),
        npGainMods = _getValues((e) => e.serverMod.tdRate),
        defNpGainMods = _getValues((e) => e.serverMod.tdAttackRate),
        critStarMods = _getValues((e) => e.serverMod.starRate);
    List<int> allTraits = {
          for (final enemy in enemies) ...enemy.traits.map((e) => e.signedId)
        }.toList(),
        staticTraits = allTraits
            .where((e) => enemies.every(
                (enemy) => enemy.traits.any((trait) => trait.signedId == e)))
            .toList(),
        mutatingTraits =
            allTraits.where((e) => !staticTraits.contains(e)).toList();
    staticTraits.sort();
    mutatingTraits.sort();

    List<int> skillIds = {
          for (final enemy in enemies) ...[
            enemy.skills.skillId1,
            enemy.skills.skillId2,
            enemy.skills.skillId3,
          ],
        }.where((e) => e > 0 && db.gameData.baseSkills[e] != null).toList(),
        classPassiveIds = {
          for (final enemy in enemies) ...[
            ...enemy.classPassive.classPassive.map((e) => e.id),
            ...enemy.classPassive.addPassive.map((e) => e.id),
          ],
        }.where((e) => e > 0 && db.gameData.baseSkills[e] != null).toList(),
        tdIds = {
          for (final enemy in enemies) enemy.noblePhantasm.noblePhantasmId,
        }.where((e) => e > 0 && db.gameData.baseTds[e] != null).toList();

    return Scaffold(
      appBar: AppBar(title: Text('[${S.current.enemy}] ${svt.lName.l}')),
      body: ListView(
        children: [
          CustomTable(
            children: <Widget>[
              CustomTableRow(children: [
                TableCellData(
                  child: Text(svt.lName.l,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  isHeader: true,
                )
              ]),
              if (!Transl.isJP)
                CustomTableRow(children: [
                  TableCellData(text: svt.lName.jp, textAlign: TextAlign.center)
                ]),
              TextButton(
                onPressed: () {
                  svt.routeTo();
                },
                style: kTextButtonDenseStyle,
                child: Text('${S.current.enemy} No.${svt.id} - ${svt.lName.l}'),
              ),
              CustomTableRow.fromChildren(children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 2,
                  runSpacing: 2,
                  children: [
                    for (final icon in _getValues((e) => e.svt.icon))
                      db.getIconImage(icon, width: 48, height: 48)
                  ],
                )
              ]),
              CustomTableRow.fromTexts(
                texts: [
                  S.current.filter_attribute,
                  S.current.info_charge,
                  S.current.info_death_rate,
                  S.current.info_critical_rate,
                ],
                isHeader: true,
              ),
              CustomTableRow.fromTexts(
                texts: [
                  attributes.map((e) => Transl.svtAttribute(e).l).join('/'),
                  charges.join('/'),
                  deathRates
                      .map((e) => e.format(base: 10, percent: true))
                      .join('/'),
                  critRates
                      .map((e) => e.format(base: 10, percent: true))
                      .join('/'),
                ],
                defaults: TableCellData(textAlign: TextAlign.center),
              ),
              CustomTableRow.fromTexts(
                texts: [
                  S.current.filter_sort_class,
                  S.current.np_gain_mod,
                  S.current.def_np_gain_mod,
                  S.current.crit_star_mod,
                ],
                isHeader: true,
              ),
              CustomTableRow(children: [
                TableCellData(
                  textAlign: TextAlign.center,
                  child: Text.rich(
                    TextSpan(children: [
                      CenterWidgetSpan(
                        child: db.getIconImage(
                          svt.className.icon(svt.rarity),
                          width: 24,
                        ),
                      ),
                      TextSpan(text: Transl.svtClass(svt.className).l)
                    ]),
                    textAlign: TextAlign.center,
                  ),
                ),
                TableCellData(
                    text: npGainMods
                        .map((e) => e.format(base: 10, percent: true))
                        .join('/')),
                TableCellData(
                    text: defNpGainMods
                        .map((e) => e.format(base: 10, percent: true))
                        .join('/')),
                TableCellData(
                    text: critStarMods
                        .map((e) => e.format(base: 10, percent: true))
                        .join('/')),
              ]),
              CustomTableRow.fromTexts(
                texts: [S.current.info_trait],
                isHeader: true,
              ),
              CustomTableRow.fromChildren(children: [
                Text.rich(TextSpan(children: [
                  ...SharedBuilder.traitSpans(
                    context: context,
                    traits:
                        staticTraits.map((e) => NiceTrait.signed(e)).toList(),
                  ),
                  if (mutatingTraits.isNotEmpty) ...[
                    TextSpan(text: '\n${S.current.general_special}*: '),
                    ...SharedBuilder.traitSpans(
                      context: context,
                      traits: mutatingTraits
                          .map((e) => NiceTrait.signed(e))
                          .toList(),
                    )
                  ]
                ])),
              ]),
              if (skillIds.isNotEmpty) ...[
                CustomTableRow.fromTexts(
                  texts: [S.current.skill],
                  isHeader: true,
                ),
                for (final skillId in skillIds..sort())
                  SkillDescriptor(
                    skill: db.gameData.baseSkills[skillId]!,
                    showEnemy: true,
                  ),
              ],
              if (classPassiveIds.isNotEmpty) ...[
                CustomTableRow.fromTexts(
                  texts: [S.current.passive_skill],
                  isHeader: true,
                ),
                for (final skillId in classPassiveIds..sort())
                  SkillDescriptor(
                    skill: db.gameData.baseSkills[skillId]!,
                    showEnemy: true,
                  ),
              ],
              if (tdIds.isNotEmpty) ...[
                CustomTableRow.fromTexts(
                  texts: [S.current.noble_phantasm],
                  isHeader: true,
                ),
                for (final tdId in tdIds..sort())
                  TdDescriptor(
                    td: db.gameData.baseTds[tdId]!,
                    showEnemy: true,
                  ),
              ],
            ],
          ),
          CustomTableRow.fromTexts(
            texts: [S.current.quest],
            isHeader: true,
          ),
          questTile(context),
          kDefaultDivider,
          ListTile(subtitle: Text(S.current.quest_enemy_summary_hint)),
        ],
      ),
    );
  }

  Widget questTile(BuildContext context) {
    final quests = db.gameData.questPhases.values
        .where((q) => q.allEnemies.any((e) => e.svt.id == svt.id))
        .toList();
    return TextButton(
      onPressed: () {
        router.pushPage(QuestListPage(quests: quests));
      },
      style: kTextButtonDenseStyle,
      child: Text('${quests.length} ${S.current.free_quest}'),
    );
  }
}
