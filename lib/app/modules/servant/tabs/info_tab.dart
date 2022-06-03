import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SvtInfoTab extends StatelessWidget {
  final Servant svt;

  const SvtInfoTab({Key? key, required this.svt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerData = TableCellData(isHeader: true, maxLines: 1);
    final contentData = TableCellData(textAlign: TextAlign.center, maxLines: 1);
    Set<String> names = {
      svt.name,
      ...svt.ascensionAdd.overWriteServantName.all.values,
      ...svt.svtChange.map((e) => e.name)
    };
    final baseTraits = [
      ...svt.traits,
      for (final traitAdd in svt.traitAdd)
        if (traitAdd.idx == 1) ...traitAdd.trait,
    ];
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: SafeArea(
        child: CustomTable(
          children: <Widget>[
            CustomTableRow.fromChildren(
              defaults: headerData.copyWith(maxLines: names.length),
              children: [
                Text(
                  names.map((e) => Transl.svtNames(e).l).join(' / '),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )
              ],
            ),
            if (!Transl.isJP)
              CustomTableRow.fromTexts(
                texts: [names.join(' / ')],
                defaults: TableCellData(textAlign: TextAlign.center),
              ),
            if (!Transl.isEN)
              CustomTableRow.fromTexts(
                texts: [
                  names.map((e) => Transl.svtNames(e).na).join(' / '),
                ],
                defaults: TableCellData(textAlign: TextAlign.center),
              ),
            CustomTableRow.fromChildren(
              children: [
                Text('No.${svt.collectionNo}',
                    textAlign: TextAlign.center, maxLines: 1),
                Text('No. ${svt.id}', textAlign: TextAlign.center, maxLines: 1),
                Text.rich(
                  TextSpan(children: [
                    CenterWidgetSpan(
                        child: db.getIconImage(svt.className.icon(svt.rarity),
                            width: 20, aspectRatio: 1)),
                    TextSpan(text: ' ${Transl.svtClass(svt.className).l}')
                  ]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            CustomTableRow.fromTexts(texts: [
              S.current.illustrator,
              S.current.info_cv,
              S.current.info_gender,
            ], defaults: headerData),
            CustomTableRow.fromTexts(texts: [
              Transl.illustratorNames(svt.profile.illustrator).l,
              Transl.cvNames(svt.profile.cv).l,
              Transl.enums(svt.gender, (enums) => enums.gender).l,
            ], defaults: TableCellData(textAlign: TextAlign.center)),
            CustomTableRow.fromTexts(texts: [
              S.current.info_strength,
              S.current.info_endurance,
              S.current.info_agility,
              S.current.info_mana,
              S.current.info_luck,
              S.current.info_np
            ], defaults: headerData),
            CustomTableRow.fromTexts(texts: [
              svt.profile.stats?.strength ?? '-',
              svt.profile.stats?.endurance ?? '-',
              svt.profile.stats?.agility ?? '-',
              svt.profile.stats?.magic ?? '-',
              svt.profile.stats?.luck ?? '-',
              svt.profile.stats?.np ?? '-',
            ], defaults: contentData),
            CustomTableRow(children: [
              TableCellData(
                  text: S.current.filter_attribute, isHeader: true, flex: 2),
              TableCellData(
                  text: S.current.info_alignment, isHeader: true, flex: 2),
              TableCellData(
                  text: S.current.general_type, isHeader: true, flex: 2),
            ]),
            CustomTableRow(children: [
              TableCellData(text: Transl.svtAttribute(svt.attribute).l),
              TableCellData(
                text: [
                  if (svt.profile.stats?.policy != null)
                    Transl.servantPolicy(svt.profile.stats!.policy!).l,
                  if (svt.profile.stats?.personality != null)
                    Transl.servantPersonality(svt.profile.stats!.personality!)
                        .l,
                ].join('·'),
                textAlign: TextAlign.center,
              ),
              TableCellData(
                  text: Transl.enums(svt.type, (enums) => enums.svtType).l),
            ]),
            CustomTableRow.fromTexts(texts: [
              S.current.info_value,
              'Lv.1',
              'Lv.Max',
              'Lv.90',
              'Lv.100',
              'Lv.120'
            ], defaults: headerData),
            _addAtkHpRow(context, 'ATK', [
              svt.atkBase,
              svt.atkMax,
              svt.atkGrowth.getOrNull(89),
              svt.atkGrowth.getOrNull(99),
              svt.atkGrowth.getOrNull(119),
            ]),
            _addAtkHpRow(
              context,
              'ATK*',
              [
                svt.atkBase,
                svt.atkMax,
                svt.atkGrowth.getOrNull(89),
                svt.atkGrowth.getOrNull(99),
                svt.atkGrowth.getOrNull(119),
              ],
              db.gameData.constData.classAttackRate[svt.className],
            ),
            _addAtkHpRow(context, 'HP', [
              svt.hpBase,
              svt.hpMax,
              svt.hpGrowth.getOrNull(89),
              svt.hpGrowth.getOrNull(99),
              svt.hpGrowth.getOrNull(119),
            ]),
            CustomTableRow.fromTexts(
                texts: [S.current.info_cards], defaults: headerData),
            CustomTableRow(children: [
              if (svt.noblePhantasms.isNotEmpty)
                TableCellData(
                  child: CommandCardWidget(
                      card: svt.noblePhantasms.first.card, width: 55),
                  flex: 1,
                ),
              TableCellData(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: svt.cards
                      .map((e) => CommandCardWidget(card: e, width: 44))
                      .toList(),
                ),
                flex: 3,
              )
            ]),
            if (svt.hitsDistribution.isNotEmpty)
              CustomTableRow.fromTexts(
                  texts: const ['Hits'], defaults: headerData),
            for (final entry in svt.hitsDistribution.entries)
              CustomTableRow(children: [
                TableCellData(text: entry.key.name.toTitle(), isHeader: true),
                TableCellData(
                  text: entry.value.isEmpty
                      ? '   -'
                      : '   ${entry.value.length} Hits '
                          '(${entry.value.join(', ')})',
                  flex: 5,
                  alignment: Alignment.centerLeft,
                )
              ]),
            if (svt.noblePhantasms.isNotEmpty) ...[
              CustomTableRow.fromTexts(
                  texts: [S.current.info_np_rate], defaults: headerData),
              CustomTableRow.fromTexts(texts: const [
                'Buster',
                'Arts',
                'Quick',
                'Extra',
                'NP',
                'Def'
              ], defaults: TableCellData(isHeader: true, maxLines: 1)),
            ],
            ..._npRates(),
            CustomTableRow.fromTexts(texts: [
              S.current.info_star_rate,
              S.current.info_death_rate,
              S.current.info_critical_rate
            ], defaults: headerData),
            CustomTableRow.fromTexts(
              texts: [
                '${svt.starGen / 10}%',
                '${svt.instantDeathChance / 10}%',
                svt.starAbsorb.toString(),
              ],
              defaults: contentData,
            ),
            CustomTableRow.fromTexts(
                texts: [S.current.info_trait], defaults: headerData),
            ..._addTraits(context, null, baseTraits, []),
            for (final entry
                in svt.ascensionAdd.individuality.ascension.entries)
              ..._addTraits(
                  context,
                  TextSpan(text: '${S.current.ascension_short} ${entry.key}: '),
                  entry.value,
                  baseTraits),
            for (final entry in svt.ascensionAdd.individuality.costume.entries)
              ..._addTraits(
                context,
                TextSpan(
                    text:
                        '${svt.profile.costume[entry.key]?.lName.l ?? entry.key}: '),
                entry.value,
                baseTraits,
              ),
            if (svt.bondGrowth.isNotEmpty) ...[
              CustomTableRow.fromTexts(
                  texts: [S.current.info_bond_points], defaults: headerData),
              for (int row = 0; row < svt.bondGrowth.length / 5; row++) ...[
                CustomTableRow.fromTexts(
                  texts: [
                    'Lv.',
                    for (int i = row * 5; i < row * 5 + 5; i++)
                      (i + 1).toString()
                  ],
                  defaults: TableCellData(
                      color: TableCellData.resolveHeaderColor(context)
                          .withOpacity(0.5)),
                ),
                CustomTableRow.fromTexts(
                  texts: [
                    S.of(context).info_bond_points_single,
                    for (int i = row * 5; i < row * 5 + 5; i++)
                      i >= svt.bondGrowth.length
                          ? '-'
                          : ((svt.bondGrowth.getOrNull(i) ?? 0) -
                                  (svt.bondGrowth.getOrNull(i - 1) ?? 0))
                              .toString(),
                  ],
                  defaults: TableCellData(maxLines: 1),
                ),
                CustomTableRow.fromTexts(
                  texts: [
                    S.of(context).info_bond_points_sum,
                    for (int i = row * 5; i < row * 5 + 5; i++)
                      i >= svt.bondGrowth.length
                          ? '-'
                          : svt.bondGrowth[i].toString(),
                  ],
                  defaults: TableCellData(maxLines: 1),
                ),
              ],
            ]
          ],
        ),
      ),
    );
  }

  List<Widget> _addTraits(
    BuildContext context,
    InlineSpan? prefix,
    List<NiceTrait> traits, [
    List<NiceTrait> baseTraits = const [],
  ]) {
    List<Widget> children = [];
    if (traits.isEmpty) return children;
    List<NiceTrait> shownTraits = [];
    bool showMore = false;
    final baseTraitIds = baseTraits.map((e) => e.signedId).toSet();
    for (final trait in traits) {
      if (trait.id == Trait.canBeInBattle.id) continue;
      if (baseTraitIds.contains(trait.signedId)) {
        showMore = true;
        continue;
      }
      shownTraits.add(trait);
    }
    return [
      CustomTableRow(children: [
        TableCellData(
          alignment: null,
          child: Text.rich(
            TextSpan(
              children: [
                if (prefix != null) prefix,
                ...SharedBuilder.traitSpans(
                    context: context, traits: shownTraits),
                if (showMore)
                  CenterWidgetSpan(
                      child: InkWell(
                    child: const Icon(Icons.more_outlined, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        useRootNavigator: false,
                        builder: (context) {
                          return SimpleCancelOkDialog(
                            title: Text.rich(TextSpan(
                              text: S.current.info_trait,
                              children: prefix == null
                                  ? null
                                  : [const TextSpan(text: ' '), prefix],
                            )),
                            hideCancel: true,
                            content: SharedBuilder.traitList(
                              context: context,
                              traits: traits,
                              alignment: WrapAlignment.start,
                            ),
                          );
                        },
                      );
                    },
                  ))
              ],
            ),
          ),
        )
      ]),
    ];
  }

  Widget _addAtkHpRow(BuildContext context, String header, List<int?> vals,
      [int? multiplier]) {
    final texts = vals.map((e) => e == null
        ? '-'
        : multiplier == null
            ? e.toString()
            : (e * multiplier ~/ 1000).toString());
    return CustomTableRow(children: [
      TableCellData(text: header, isHeader: true, maxLines: 1),
      for (final text in texts) TableCellData(text: text, maxLines: 1),
    ]);
  }

  List<Widget> _npRates() {
    List<Widget> rows = [];
    List<List<int?>> values = [];
    for (final td in svt.noblePhantasms) {
      final v = td.npGain.firstValues;
      if (values.any((e) => e.toString() == v.toString())) continue;
      values.add(v);
      rows.add(CustomTableRow.fromTexts(
        texts: v.map((e) => '${(e ?? 0) / 100}%').toList(),
        defaults: TableCellData(textAlign: TextAlign.center, maxLines: 1),
      ));
    }
    return rows;
  }
}
