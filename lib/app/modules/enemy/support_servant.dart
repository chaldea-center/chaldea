import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/enemy/quest_enemy.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../craft_essence/craft.dart';

class SupportServantPage extends StatefulWidget {
  final SupportServant svt;
  final Region? region;

  const SupportServantPage(this.svt, {super.key, this.region});

  @override
  State<SupportServantPage> createState() => _SupportServantPageState();
}

class _SupportServantPageState extends State<SupportServantPage> {
  SupportServant get svt => widget.svt;
  QuestEnemy? get detail => widget.svt.detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('[${S.current.support_servant_short}] ${Transl.svtNames(svt.shownName).l}')),
      body: ListView(children: [baseInfoTable]),
    );
  }

  Widget get baseInfoTable {
    return CustomTable(
      children: [
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
          child: Text(
            svt.svt.collectionNo > 0
                ? '${S.current.servant} No.${svt.svt.collectionNo} - ${svt.svt.lName.l}'
                : '${S.current.enemy} No.${svt.svt.id} - ${svt.svt.lName.l}',
          ),
        ),
        if (svt.script?.eventDeckIndex != null)
          CustomTableRow.fromTexts(texts: ['Event Deck Index: ${svt.script!.eventDeckIndex}']),
        CustomTableRow(
          children: [
            TableCellData(child: svt.svt.iconBuilder(context: context, height: 64)),
            TableCellData(
              flex: 3,
              padding: EdgeInsets.zero,
              child: CustomTable(
                hideOutline: true,
                children: [
                  CustomTableRow(
                    children: [
                      TableCellData(text: S.current.svt_class, isHeader: true),
                      TableCellData(
                        flex: 3,
                        textAlign: TextAlign.center,
                        child: InkWell(
                          onTap: () => SvtClassX.routeTo(svt.svt.classId),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                CenterWidgetSpan(child: db.getIconImage(svt.svt.clsIcon, width: 24)),
                                TextSpan(text: Transl.svtClassId(svt.svt.classId).l),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  CustomTableRow.fromTextsWithHeader(
                    texts: [
                      S.current.rarity,
                      svt.svt.rarity.toString(),
                      S.current.svt_sub_attribute,
                      Transl.svtSubAttribute(svt.svt.attribute).l,
                    ],
                    isHeaders: const [true, false, true, false],
                    defaults: TableCellData(maxLines: 1),
                  ),
                  CustomTableRow.fromTextsWithHeader(
                    texts: ['Lv', '${svt.lv}', S.current.ascension_short, svt.limit.limitCount.toString()],
                    isHeaders: const [true, false, true, false],
                  ),
                  CustomTableRow.fromTextsWithHeader(
                    texts: ['HP', svt.hp.format(compact: false), 'ATK', svt.atk.format(compact: false)],
                    isHeaders: const [true, false, true, false],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (svt.detail != null)
          TextButton(
            onPressed: () {
              router.pushPage(
                QuestEnemyDetail(enemy: svt.detail!, overrideTitle: "${S.current.support_servant_short}*"),
              );
            },
            style: kTextButtonDenseStyle,
            child: Text(S.current.details),
          ),
        CustomTableRow.fromTexts(texts: [S.current.trait], isHeader: true),
        CustomTableRow.fromChildren(
          children: [SharedBuilder.traitList(context: context, traits: svt.traits2.toList()..sort2((e) => e.id))],
        ),
        if (svt.passiveSkills.isNotEmpty) CustomTableRow.fromTexts(texts: [S.current.extra_passive], isHeader: true),
        for (final passive in svt.passiveSkills)
          if (passive.skill != null)
            SkillDescriptor(
              skill: passive.skill!,
              level: passive.skillLv,
              showEnemy: false,
              showPlayer: true,
              region: widget.region,
            ),
        if (svt.skills2.skills.any((e) => e != null))
          CustomTableRow.fromTexts(texts: [S.current.skill], isHeader: true),
        for (int index = 0; index < svt.skills2.skills.length; index++)
          if (svt.skills2.skills[index] != null)
            SkillDescriptor(
              skill: svt.skills2.skills[index]!,
              level: svt.skills2.skillLvs[index],
              showEnemy: false,
              showPlayer: true,
              region: widget.region,
            ),
        if (svt.td2 != null) ...[
          CustomTableRow.fromTexts(texts: [S.current.noble_phantasm], isHeader: true),
          TdDescriptor(td: svt.td2!, level: svt.td2Lv, showEnemy: false, showPlayer: true, region: widget.region),
        ],
        if (svt.classPassive.isNotEmpty) ...[
          CustomTableRow.fromTexts(texts: [S.current.passive_skill], isHeader: true),
          for (final skill in svt.classPassive.classPassive)
            SkillDescriptor(skill: skill, showEnemy: false, showPlayer: true, region: widget.region),
          for (int index = 0; index < svt.classPassive.addPassive.length; index++)
            SkillDescriptor(
              skill: svt.classPassive.addPassive[index],
              level: svt.classPassive.addPassiveLvs.getOrNull(index),
              showEnemy: false,
              showPlayer: true,
              region: widget.region,
            ),
        ],
        ...getCes(),
        if (svt.releaseConditions.isNotEmpty) ...[
          CustomTableRow.fromTexts(texts: [S.current.open_condition], isHeader: true),
          CustomTableRow.fromChildren(
            children: [
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
                    ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  List<Widget> getCes() {
    if (svt.equips.isEmpty) return [];
    List<Widget> children = [
      CustomTableRow.fromTexts(texts: [S.current.craft_essence], isHeader: true),
    ];
    for (final ce in svt.equips) {
      children.add(
        ListTile(
          leading: ce.equip.iconBuilder(context: context, width: 48),
          title: Text(ce.equip.lName.l),
          subtitle: Text('Lv.${ce.lv} ${ce.limitCount == 4 ? S.current.max_limit_break : ""}'),
          onTap: () {
            router.push(url: ce.equip.route, child: CraftDetailPage(ce: ce.equip));
          },
        ),
      );
      final skills = ce.equip.skills.where((skill) => skill.svt.condLimitCount == ce.limitCount);
      children.addAll(skills.map((e) => SkillDescriptor(skill: e, region: widget.region)));
    }

    return children;
  }
}

class SupportServantTile extends StatelessWidget {
  final SupportServant svt;
  final VoidCallback? onTap;
  final Region? region;
  final bool hasLv100;
  const SupportServantTile({super.key, required this.svt, required this.onTap, this.region, this.hasLv100 = false});

  TextSpan _mono(dynamic v, int width) => TextSpan(text: v.toString().padRight(width), style: kMonoStyle);

  String _nullLevel(int lv, dynamic skill) {
    return skill == null ? '-' : lv.toString();
  }

  @override
  Widget build(BuildContext context) {
    Widget support = Text.rich(
      TextSpan(
        children: [
          CenterWidgetSpan(
            child: svt.svt.iconBuilder(
              context: context,
              width: 32,
              onTap: () {
                router.pushPage(SupportServantPage(svt, region: region));
              },
            ),
          ),
          TextSpan(
            children: [
              const TextSpan(text: ' Lv.'),
              _mono(svt.lv, hasLv100 ? 3 : 2),
              TextSpan(text: ' ${S.current.np_short} Lv.'),
              _mono(_nullLevel(svt.noblePhantasm.noblePhantasmLv, svt.noblePhantasm.noblePhantasm), 1),
              TextSpan(text: ' ${S.current.skill} Lv.'),
              _mono(
                '${_nullLevel(svt.skills.skillLv1, svt.skills.skill1)}'
                '/${_nullLevel(svt.skills.skillLv2, svt.skills.skill2)}'
                '/${_nullLevel(svt.skills.skillLv3, svt.skills.skill3)}',
                8,
              ),
              const TextSpan(text: '  '),
            ],
            style: svt.script?.eventDeckIndex == null ? null : TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          for (final ce in svt.equips) ...[
            CenterWidgetSpan(child: ce.equip.iconBuilder(context: context, width: 32)),
            TextSpan(
              children: [const TextSpan(text: ' Lv.'), _mono(ce.lv, 2)],
              style: ce.limitCount == 4 ? TextStyle(color: Theme.of(context).colorScheme.error) : null,
            ),
          ],
        ],
      ),
      textScaler: const TextScaler.linear(0.9),
    );
    if (onTap != null) {
      support = InkWell(
        child: support,
        onTap: () {
          router.pushPage(SupportServantPage(svt, region: region));
        },
      );
    }
    return support;
  }
}
