import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class QuestEnemyDetail extends StatefulWidget {
  final QuestEnemy enemy;
  final List<int>? npcAis;
  final Quest? quest;
  final Region? region;
  final String? overrideTitle;

  const QuestEnemyDetail({
    super.key,
    required this.enemy,
    this.npcAis,
    this.quest,
    this.region,
    this.overrideTitle,
  });

  @override
  State<QuestEnemyDetail> createState() => _QuestEnemyDetailState();
}

class _QuestEnemyDetailState extends State<QuestEnemyDetail> {
  QuestEnemy get enemy => widget.enemy;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('[${widget.overrideTitle ?? S.current.enemy}] ${enemy.lShownName}'),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: Text(S.current.copy),
                onTap: () {
                  db.runtimeData.clipBoard.questEnemy = enemy;
                },
              )
            ];
          })
        ],
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
              CustomTableRow(children: [
                TableCellData(text: S.current.svt_class, isHeader: true),
                TableCellData(
                  flex: 3,
                  textAlign: TextAlign.center,
                  child: InkWell(
                    onTap: () => SvtClassX.routeTo(enemy.svt.classId),
                    child: Text.rich(
                      TextSpan(children: [
                        CenterWidgetSpan(
                          child: db.getIconImage(enemy.svt.clsIcon, width: 24),
                        ),
                        TextSpan(text: Transl.svtClassId(enemy.svt.classId).l)
                      ]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ]),
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
                  S.current.rarity,
                  enemy.svt.rarity.toString(),
                  S.current.filter_attribute,
                  Transl.svtAttribute(enemy.svt.attribute).l,
                ],
                isHeaders: const [true, false, true, false],
                defaults: TableCellData(maxLines: 1),
              ),
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
                texts: ['HP', enemy.hp.format(compact: false), 'ATK', enemy.atk.format(compact: false)],
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
        texts: [S.current.trait],
        isHeader: true,
      ),
      CustomTableRow.fromChildren(
          children: [SharedBuilder.traitList(context: context, traits: enemy.traits.toList()..sort2((e) => e.id))]),
      if (enemy.ai != null) ...[
        CustomTableRow.fromTexts(texts: [
          'AI ID',
          if (enemy.ai!.minActNum != null && enemy.ai!.minActNum != 0) 'Min Act',
          'Max Act',
          'Act Priority',
        ], isHeader: true),
        CustomTableRow(
          children: [
            TableCellData(
              child: Text.rich(
                TextSpan(
                  children: divideList(
                    [
                      for (final aiId in [enemy.ai!.aiId, ...?widget.npcAis])
                        if (aiId != 0)
                          SharedBuilder.textButtonSpan(
                            context: context,
                            text: aiId.toString(),
                            onTap: () {
                              launch(Atlas.ai(enemy.ai!.aiId, true,
                                  region: widget.region ?? Region.jp,
                                  skillId1: enemy.skills.skillId1,
                                  skillId2: enemy.skills.skillId2,
                                  skillId3: enemy.skills.skillId3));
                            },
                          ),
                    ],
                    const TextSpan(text: ' / '),
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (enemy.ai!.minActNum != null && enemy.ai!.minActNum != 0)
              TableCellData(text: enemy.ai!.minActNum.toString()),
            TableCellData(text: enemy.ai!.maxActNum.toString()),
            TableCellData(text: enemy.ai!.actPriority.toString()),
          ],
        )
      ],
      ...enemyScriptInfo(),
      ...enemyDrops(),
      if (enemy.skills.skill1 != null || enemy.skills.skill2 != null || enemy.skills.skill3 != null)
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
          region: widget.region,
        ),
      if (enemy.skills.skill2 != null)
        SkillDescriptor(
          skill: enemy.skills.skill2!,
          level: enemy.skills.skillLv2,
          showEnemy: true,
          showPlayer: true,
          region: widget.region,
        ),
      if (enemy.skills.skill3 != null)
        SkillDescriptor(
          skill: enemy.skills.skill3!,
          level: enemy.skills.skillLv3,
          showEnemy: true,
          showPlayer: true,
          region: widget.region,
        ),
      if (enemy.classPassive.classPassive.isNotEmpty || enemy.classPassive.addPassive.isNotEmpty)
        CustomTableRow.fromTexts(
          texts: [S.current.passive_skill],
          isHeader: true,
        ),
      for (final skill in enemy.classPassive.classPassive)
        SkillDescriptor(
          skill: skill,
          showEnemy: true,
          showPlayer: true,
          region: widget.region,
        ),
      for (int index = 0; index < enemy.classPassive.addPassive.length; index++)
        SkillDescriptor(
          skill: enemy.classPassive.addPassive[index],
          level: enemy.classPassive.addPassiveLvs?.getOrNull(index),
          showEnemy: true,
          showPlayer: true,
          region: widget.region,
        ),
      if (enemy.classPassive.appendPassiveSkillIds?.isNotEmpty == true) ...[
        CustomTableRow.fromTexts(
          texts: [S.current.append_skill],
          isHeader: true,
        ),
        for (int index = 0; index < enemy.classPassive.appendPassiveSkillIds!.length; index++)
          SkillDescriptor.fromId(
            id: enemy.classPassive.appendPassiveSkillIds![index],
            builder: (context, skill) => SkillDescriptor(
              skill: skill,
              level: enemy.classPassive.appendPassiveSkillLvs?.getOrNull(index),
              showEnemy: true,
              showPlayer: true,
              region: widget.region,
            ),
          ),
      ],
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
          region: widget.region,
        ),
      if (enemy.originalEnemyScript?.isNotEmpty == true) ...[
        CustomTableRow.fromTexts(
          texts: const ['Enemy Script'],
          isHeader: true,
        ),
        for (final entry in enemy.originalEnemyScript!.entries)
          CustomTableRow(children: [
            TableCellData(text: entry.key, alignment: AlignmentDirectional.centerEnd, textAlign: TextAlign.end),
            TableCellData(text: entry.value.toString(), alignment: AlignmentDirectional.centerStart),
          ])
      ]
    ]);
  }

  Iterable<Widget> enemyDrops() sync* {
    if (enemy.drops.isEmpty) return;
    yield CustomTableRow.fromTexts(
        texts: ['${S.current.game_drop}(${S.current.quest_runs(enemy.drops.first.runs)})'], isHeader: true);
    final drops = enemy.drops.toList();
    drops.sort((a, b) => Item.compare2(a.objectId, b.objectId));
    List<Widget> children = [];
    for (final drop in drops) {
      String? text;
      if (drop.runs != 0) {
        double dropRate = drop.dropCount / drop.runs;
        text = dropRate.format(percent: true, maxDigits: 3);
      }
      if (text != null) {
        if (drop.num == 1) {
          text = ' \n$text';
        } else {
          text = '×${drop.num.format(minVal: 999)}\n$text';
        }
      }
      children.add(GameCardMixin.anyCardItemBuilder(
        context: context,
        id: drop.objectId,
        width: 42,
        text: text ?? '-',
        option: ImageWithTextOption(fontSize: 42 * 0.27, padding: EdgeInsets.zero),
      ));
    }
    yield CustomTableRow.fromChildren(children: [Wrap(spacing: 3, runSpacing: 2, children: children)]);
    if (enemy.dropsFromAllHashes == true) {
      yield CustomTableRow(
        children: [
          TableCellData(text: S.current.drop_from_all_hashes_hint, style: Theme.of(context).textTheme.bodySmall)
        ],
      );
    }
  }

  List<Widget> enemyScriptInfo() {
    List<Widget> children = [
      if (enemy.enemyScript.isRare) CustomTableRow.fromTexts(texts: [S.current.rare_enemy_hint]),
      if (enemy.enemyScript.leader == true) CustomTableRow.fromTexts(texts: [S.current.enemy_leader_hint]),
    ];
    if (children.isNotEmpty) {
      children.insert(0, CustomTableRow.fromTexts(texts: const ['Hint'], isHeader: true));
    }
    return children;
  }
}

String _dscPercent(int v, int base) {
  return '${(v / base).toString().replaceFirst(RegExp(r'\.0+$'), '')}%';
}
