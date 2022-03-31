import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/effect_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

class QuestEnemyDetail extends StatefulWidget {
  final QuestEnemy enemy;
  final Quest? quest;

  const QuestEnemyDetail({Key? key, required this.enemy, this.quest})
      : super(key: key);

  @override
  State<QuestEnemyDetail> createState() => _QuestEnemyDetailState();
}

class _QuestEnemyDetailState extends State<QuestEnemyDetail> {
  QuestEnemy get enemy => widget.enemy;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(enemy.name),
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
      CustomTableRow.fromTexts(texts: [enemy.name], isHeader: true),
      CustomTableRow.fromChildren(children: [
        if (enemy.svt.collectionNo > 0)
          TextButton(
            onPressed: () {
              router.push(url: Routes.servantI(enemy.svt.collectionNo));
            },
            child: Text(
                'Servant No.${enemy.svt.collectionNo} - ${enemy.svt.lName.l}'),
          ),
        if (enemy.svt.collectionNo == 0)
          TextButton(
            onPressed: () {
              //
            },
            child: Text('Enemy No.${enemy.svt.id} - ${enemy.svt.lName.l}'),
          ),
      ]),
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
                  'Charge',
                  enemy.chargeTurn.toString(),
                ],
                isHeaders: const [true, false, true, false],
              ),
              CustomTableRow.fromTextsWithHeader(
                texts: [
                  S.current.filter_sort_class,
                  Transl.svtClass(enemy.svt.className.id).l,
                  S.current.filter_attribute,
                  enemy.svt.attribute.name
                ],
                isHeaders: const [true, false, true, false],
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
              CustomTableRow.fromTextsWithHeader(
                texts: [
                  S.current.info_death_rate,
                  _dscPercent(enemy.deathRate, 10),
                  S.current.info_critical_rate,
                  _dscPercent(enemy.criticalRate, 10),
                ],
                isHeaders: const [true, false, true, false],
              ),
            ],
          ),
        )
      ]),
      CustomTableRow.fromTexts(
        texts: const ['NP Gain Mod', 'Def NP Gain Mod', 'Crit Star Mod'],
        isHeader: true,
      ),
      CustomTableRow.fromTexts(
        texts: [
          _dscPercent(enemy.serverMod.tdRate, 10),
          _dscPercent(enemy.serverMod.tdRate, 10),
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
          targetTeam: FuncApplyTarget.enemy,
        ),
      if (enemy.skills.skill2 != null)
        SkillDescriptor(
            skill: enemy.skills.skill2!,
            level: enemy.skills.skillLv2,
            targetTeam: FuncApplyTarget.enemy),
      if (enemy.skills.skill3 != null)
        SkillDescriptor(
            skill: enemy.skills.skill3!,
            level: enemy.skills.skillLv3,
            targetTeam: FuncApplyTarget.enemy),
      if (enemy.classPassive.classPassive.isNotEmpty ||
          enemy.classPassive.addPassive.isNotEmpty)
        CustomTableRow.fromTexts(
          texts: [S.current.passive_skill],
          isHeader: true,
        ),
      for (final skill in enemy.classPassive.classPassive)
        SkillDescriptor(skill: skill, targetTeam: FuncApplyTarget.enemy),
      for (final skill in enemy.classPassive.addPassive)
        SkillDescriptor(skill: skill, targetTeam: FuncApplyTarget.enemy),
      CustomTableRow.fromTexts(
        texts: [S.current.noble_phantasm],
        isHeader: true,
      ),
      if (enemy.noblePhantasm.noblePhantasm != null)
        TdDescriptor(
          td: enemy.noblePhantasm.noblePhantasm!,
          level: enemy.noblePhantasm.noblePhantasmLv,
          targetTeam: FuncApplyTarget.enemy,
        )
    ]);
  }
}

String _dscPercent(int v, int base) {
  return (v / base).toString().replaceFirst(RegExp(r'\.0+$'), '') + '%';
}
