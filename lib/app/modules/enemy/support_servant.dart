import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SupportServantPage extends StatefulWidget {
  final SupportServant svt;
  final Region? region;

  const SupportServantPage(this.svt, {super.key, this.region});

  @override
  State<SupportServantPage> createState() => _SupportServantPageState();
}

class _SupportServantPageState extends State<SupportServantPage> {
  SupportServant get svt => widget.svt;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '[${S.current.support_servant_short}] ${Transl.svtNames(svt.shownName).l}'),
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
      CustomTableRow.fromTexts(texts: [svt.shownName], isHeader: true),
      TextButton(
        onPressed: () {
          if (svt.svt.collectionNo > 0) {
            router.push(url: Routes.servantI(svt.svt.collectionNo));
          } else {
            router.push(url: Routes.enemyI(svt.svt.id));
          }
        },
        style: kTextButtonDenseStyle,
        child: Text(svt.svt.collectionNo > 0
            ? '${S.current.servant} No.${svt.svt.collectionNo} - ${svt.svt.lName.l}'
            : '${S.current.enemy} No.${svt.svt.id} - ${svt.svt.lName.l}'),
      ),
      if (svt.script?.eventDeckIndex != null)
        CustomTableRow.fromTexts(
            texts: ['Event Deck Index: ${svt.script!.eventDeckIndex}']),
      CustomTableRow(children: [
        TableCellData(
          child: svt.svt.iconBuilder(context: context, height: 64),
        ),
        TableCellData(
          flex: 3,
          padding: EdgeInsets.zero,
          child: CustomTable(
            hideOutline: true,
            children: [
              CustomTableRow(children: [
                TableCellData(
                    text: S.current.filter_sort_class, isHeader: true),
                TableCellData(
                  flex: 3,
                  textAlign: TextAlign.center,
                  child: InkWell(
                    onTap: svt.svt.className.routeTo,
                    child: Text.rich(
                      TextSpan(children: [
                        CenterWidgetSpan(
                          child: db.getIconImage(
                            svt.svt.className.icon(svt.svt.rarity),
                            width: 24,
                          ),
                        ),
                        TextSpan(text: Transl.svtClass(svt.svt.className).l)
                      ]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ]),
              CustomTableRow.fromTextsWithHeader(
                texts: [
                  S.current.rarity,
                  svt.svt.rarity.toString(),
                  S.current.filter_attribute,
                  Transl.svtAttribute(svt.svt.attribute).l,
                ],
                isHeaders: const [true, false, true, false],
                defaults: TableCellData(maxLines: 1),
              ),
              CustomTableRow.fromTextsWithHeader(
                texts: [
                  'Lv',
                  '${svt.lv}',
                  S.current.ascension_short,
                  svt.limit.limitCount.toString(),
                ],
                isHeaders: const [true, false, true, false],
              ),
              CustomTableRow.fromTextsWithHeader(
                texts: [
                  'HP',
                  svt.hp.format(compact: false),
                  'ATK',
                  svt.atk.format(compact: false)
                ],
                isHeaders: const [true, false, true, false],
              ),
            ],
          ),
        )
      ]),
      CustomTableRow.fromTexts(
        texts: [S.current.info_trait],
        isHeader: true,
      ),
      CustomTableRow.fromChildren(children: [
        SharedBuilder.traitList(
            context: context, traits: svt.traits.toList()..sort2((e) => e.id))
      ]),
      if (svt.skills.skill1 != null ||
          svt.skills.skill2 != null ||
          svt.skills.skill3 != null)
        CustomTableRow.fromTexts(
          texts: [S.current.skill],
          isHeader: true,
        ),
      if (svt.skills.skill1 != null)
        SkillDescriptor(
          skill: svt.skills.skill1!,
          level: svt.skills.skillLv1,
          showEnemy: true,
          showPlayer: true,
          region: widget.region,
        ),
      if (svt.skills.skill2 != null)
        SkillDescriptor(
          skill: svt.skills.skill2!,
          level: svt.skills.skillLv2,
          showEnemy: true,
          showPlayer: true,
          region: widget.region,
        ),
      if (svt.skills.skill3 != null)
        SkillDescriptor(
          skill: svt.skills.skill3!,
          level: svt.skills.skillLv3,
          showEnemy: true,
          showPlayer: true,
          region: widget.region,
        ),
      CustomTableRow.fromTexts(
        texts: [S.current.noble_phantasm],
        isHeader: true,
      ),
      if (svt.noblePhantasm.noblePhantasm != null)
        TdDescriptor(
          td: svt.noblePhantasm.noblePhantasm!,
          level: svt.noblePhantasm.noblePhantasmLv,
          showEnemy: true,
          showPlayer: true,
          region: widget.region,
        ),
      ...getCes(),
      if (svt.releaseConditions.isNotEmpty) ...[
        CustomTableRow.fromTexts(
          texts: [S.current.open_condition],
          isHeader: true,
        ),
        CustomTableRow.fromChildren(children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final cond in svt.releaseConditions)
                CondTargetValueDescriptor(
                  condType: cond.type,
                  target: cond.targetId,
                  value: cond.value,
                  leading: const TextSpan(text: kULLeading),
                )
            ],
          )
        ])
      ],
    ]);
  }

  List<Widget> getCes() {
    if (svt.equips.isEmpty) return [];
    List<Widget> children = [
      CustomTableRow.fromTexts(
        texts: [S.current.craft_essence],
        isHeader: true,
      ),
    ];
    for (final ce in svt.equips) {
      children.add(ListTile(
        leading: ce.equip.iconBuilder(context: context, width: 48),
        title: Text(ce.equip.lName.l),
        subtitle: Text(
            'Lv.${ce.lv} ${ce.limitCount == 4 ? S.current.ce_max_limit_break : ""}'),
      ));
      final skills = ce.equip.skills
          .where((skill) => skill.condLimitCount == ce.limitCount);
      children.addAll(
          skills.map((e) => SkillDescriptor(skill: e, region: widget.region)));
    }

    return children;
  }
}
