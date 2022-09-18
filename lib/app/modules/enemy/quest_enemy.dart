import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class QuestEnemyDetail extends StatefulWidget {
  final QuestEnemy enemy;
  final Quest? quest;

  const QuestEnemyDetail({super.key, required this.enemy, this.quest});

  @override
  State<QuestEnemyDetail> createState() => _QuestEnemyDetailState();
}

class _QuestEnemyDetailState extends State<QuestEnemyDetail> {
  QuestEnemy get enemy => widget.enemy;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('[${S.current.enemy}] ${enemy.lShownName}'),
      ),
      body: ListView(
        children: [
          baseInfoTable,
        ],
      ),
    );
  }

  Widget get baseInfoTable {
    return CustomTable(children: [
      CustomTableRow.fromTexts(texts: [enemy.lShownName], isHeader: true),
      if (!Transl.isJP) CustomTableRow.fromTexts(texts: [enemy.name]),
      TextButton(
        onPressed: () {
          if (enemy.svt.collectionNo > 0) {
            router.push(url: Routes.servantI(enemy.svt.collectionNo));
          } else {
            router.push(url: Routes.enemyI(enemy.svt.id));
          }
        },
        style: kTextButtonDenseStyle,
        child: Text(enemy.svt.collectionNo > 0
            ? '${S.current.servant} No.${enemy.svt.collectionNo} - ${enemy.svt.lName.l}'
            : '${S.current.enemy} No.${enemy.svt.id} - ${enemy.svt.lName.l}'),
      ),
      CustomTableRow(children: [
        TableCellData(
          child: enemy.svt.iconBuilder(context: context, height: 64),
        ),
        TableCellData(
          flex: 3,
          padding: EdgeInsets.zero,
          child: CustomTable(
            hideOutline: true,
            children: [
              CustomTableRow.fromTextsWithHeader(
                texts: [
                  'Lv',
                  '${enemy.lv}',
                  S.current.info_charge,
                  enemy.chargeTurn.toString(),
                ],
                isHeaders: const [true, false, true, false],
              ),
              CustomTableRow.fromTextsWithHeader(
                texts: [
                  'Deck',
                  enemy.deck.name,
                  'DeckId',
                  enemy.deckId.toString(),
                ],
                isHeaders: const [true, false, true, false],
                defaults: TableCellData(maxLines: 1),
              ),
              CustomTableRow.fromTextsWithHeader(
                texts: [
                  S.current.filter_sort_class,
                  Transl.svtClass(enemy.svt.className).l,
                  S.current.filter_attribute,
                  Transl.svtAttribute(enemy.svt.attribute).l,
                ],
                isHeaders: const [true, false, true, false],
                defaults: TableCellData(maxLines: 1),
              ),
              CustomTableRow.fromTextsWithHeader(
                texts: [
                  'HP',
                  enemy.hp.format(compact: false),
                  'ATK',
                  enemy.atk.format(compact: false)
                ],
                isHeaders: const [true, false, true, false],
              ),
              // CustomTableRow.fromTextsWithHeader(
              //   texts: [
              //     S.current.info_death_rate,
              //     _dscPercent(enemy.deathRate, 10),
              //     S.current.info_critical_rate,
              //     _dscPercent(enemy.criticalRate, 10),
              //   ],
              //   isHeaders: const [true, false, true, false],
              // ),
            ],
          ),
        )
      ]),
      CustomTableRow.fromTexts(
        texts: [
          'Role Type',
          S.current.info_death_rate,
          S.current.info_critical_rate,
        ],
        isHeader: true,
      ),
      CustomTableRow.fromTexts(
        texts: [
          enemy.roleType.name.toTitle(),
          _dscPercent(enemy.deathRate, 10),
          _dscPercent(enemy.criticalRate, 10),
        ],
      ),
      CustomTableRow.fromTexts(
        texts: [
          S.current.np_gain_mod,
          S.current.def_np_gain_mod,
          S.current.crit_star_mod,
        ],
        isHeader: true,
      ),
      CustomTableRow.fromTexts(
        texts: [
          _dscPercent(enemy.serverMod.tdRate, 10),
          _dscPercent(enemy.serverMod.tdAttackRate, 10),
          _dscPercent(enemy.serverMod.starRate, 10),
        ],
      ),
      CustomTableRow.fromTexts(
        texts: [S.current.info_trait],
        isHeader: true,
      ),
      CustomTableRow.fromChildren(children: [
        SharedBuilder.traitList(context: context, traits: enemy.traits)
      ]),
      if (enemy.skills.skill1 != null ||
          enemy.skills.skill2 != null ||
          enemy.skills.skill3 != null)
        CustomTableRow.fromTexts(
          texts: [S.current.skill],
          isHeader: true,
        ),
      if (enemy.skills.skill1 != null)
        SkillDescriptor(
          skill: enemy.skills.skill1!,
          level: enemy.skills.skillLv1,
          showEnemy: true,
          showPlayer: true,
        ),
      if (enemy.skills.skill2 != null)
        SkillDescriptor(
          skill: enemy.skills.skill2!,
          level: enemy.skills.skillLv2,
          showEnemy: true,
          showPlayer: true,
        ),
      if (enemy.skills.skill3 != null)
        SkillDescriptor(
          skill: enemy.skills.skill3!,
          level: enemy.skills.skillLv3,
          showEnemy: true,
          showPlayer: true,
        ),
      if (enemy.classPassive.classPassive.isNotEmpty ||
          enemy.classPassive.addPassive.isNotEmpty)
        CustomTableRow.fromTexts(
          texts: [S.current.passive_skill],
          isHeader: true,
        ),
      for (final skill in enemy.classPassive.classPassive)
        SkillDescriptor(
          skill: skill,
          showEnemy: true,
          showPlayer: true,
        ),
      for (final skill in enemy.classPassive.addPassive)
        SkillDescriptor(
          skill: skill,
          showEnemy: true,
          showPlayer: true,
        ),
      CustomTableRow.fromTexts(
        texts: [S.current.noble_phantasm],
        isHeader: true,
      ),
      if (enemy.noblePhantasm.noblePhantasm != null)
        TdDescriptor(
          td: enemy.noblePhantasm.noblePhantasm!,
          level: enemy.noblePhantasm.noblePhantasmLv,
          showEnemy: true,
          showPlayer: true,
        )
    ]);
  }
}

String _dscPercent(int v, int base) {
  return '${(v / base).toString().replaceFirst(RegExp(r'\.0+$'), '')}%';
}
