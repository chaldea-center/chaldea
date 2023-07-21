import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../creator/creator_detail.dart';

class SvtInfoTab extends StatelessWidget {
  final Servant svt;

  const SvtInfoTab({super.key, required this.svt});

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
    final name = RubyText(
      [RubyTextData(svt.name, ruby: svt.ruby)],
      style: const TextStyle(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
    final tdHits = {for (final td in svt.noblePhantasms) td.damage.toString(): td};
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: SafeArea(
        child: CustomTable(
          selectable: true,
          children: <Widget>[
            CustomTableRow(children: [
              TableCellData(
                child: name,
                isHeader: true,
                padding: const EdgeInsets.all(4),
              )
            ]),
            if (names.length > 1)
              CustomTableRow.fromTexts(
                texts: [names.join(' / ')],
                defaults: TableCellData(textAlign: TextAlign.center),
              ),
            if (!Transl.isJP)
              CustomTableRow.fromTexts(
                texts: [names.map((e) => Transl.svtNames(e).l).join(' / ')],
                defaults: TableCellData(textAlign: TextAlign.center),
              ),
            if (!Transl.isEN)
              CustomTableRow.fromTexts(
                texts: [names.map((e) => Transl.svtNames(e).na).join(' / ')],
                defaults: TableCellData(textAlign: TextAlign.center),
              ),
            CustomTableRow.fromChildren(children: [
              if (svt.rarity != 0)
                CachedImage(
                  imageUrl:
                      "https://static.atlasacademy.io/JP/CharaGraphOption/CharaGraphOption/CharaGraphOptionAtlas/rarity${svt.rarity}_0.png",
                  height: 24,
                ),
            ]),
            CustomTableRow.fromChildren(
              children: [
                Text(
                  svt.collectionNo == svt.originalCollectionNo
                      ? 'No.${svt.collectionNo}'
                      : 'No.${svt.originalCollectionNo}\n${svt.collectionNo}',
                  textAlign: TextAlign.center,
                ),
                Text('No. ${svt.id}', textAlign: TextAlign.center, maxLines: 1),
                GestureDetector(
                  onTap: () {
                    SvtClassX.routeTo(svt.classId);
                  },
                  child: Text.rich(
                    TextSpan(children: [
                      CenterWidgetSpan(child: db.getIconImage(svt.clsIcon, width: 20, aspectRatio: 1)),
                      SharedBuilder.textButtonSpan(
                        context: context,
                        text: ' ${Transl.svtClassId(svt.classId).l}',
                      )
                    ]),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
            CustomTableRow.fromTexts(texts: [
              S.current.illustrator,
              S.current.info_cv,
              S.current.gender,
            ], defaults: headerData),
            CustomTableRow(children: [
              TableCellData(
                child: Text.rich(
                  SharedBuilder.textButtonSpan(
                    context: context,
                    text: Transl.illustratorNames(svt.profile.illustrator).l,
                    onTap: () {
                      router.pushPage(CreatorDetail.illust(name: svt.profile.illustrator));
                    },
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              TableCellData(
                child: Text.rich(
                  SharedBuilder.textButtonSpan(
                    context: context,
                    text: Transl.cvNames(svt.profile.cv).l,
                    onTap: () {
                      router.pushPage(CreatorDetail.cv(name: svt.profile.cv));
                    },
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              TableCellData(
                text: Transl.enums(svt.gender, (enums) => enums.gender).l,
                textAlign: TextAlign.center,
              )
            ]),
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
              TableCellData(text: S.current.filter_attribute, isHeader: true, flex: 2),
              TableCellData(text: S.current.info_alignment, isHeader: true, flex: 2),
              TableCellData(text: S.current.general_type, isHeader: true, flex: 2),
            ]),
            CustomTableRow(children: [
              TableCellData(text: Transl.svtAttribute(svt.attribute).l),
              TableCellData(
                text: [
                  if (svt.profile.stats?.policy != null) Transl.servantPolicy(svt.profile.stats!.policy!).l,
                  if (svt.profile.stats?.personality != null)
                    Transl.servantPersonality(svt.profile.stats!.personality!).l,
                ].join('·'),
                textAlign: TextAlign.center,
              ),
              TableCellData(text: Transl.enums(svt.type, (enums) => enums.svtType).l),
            ]),
            CustomTableRow.fromTexts(
                texts: [S.current.info_value, 'Lv.1', 'Lv.Max', 'Lv.90', 'Lv.100', 'Lv.120'], defaults: headerData),
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
              db.gameData.constData.classInfo[svt.classId]?.attackRate,
            ),
            _addAtkHpRow(context, 'HP', [
              svt.hpBase,
              svt.hpMax,
              svt.hpGrowth.getOrNull(89),
              svt.hpGrowth.getOrNull(99),
              svt.hpGrowth.getOrNull(119),
            ]),
            CustomTableRow.fromTexts(texts: [S.current.info_cards], defaults: headerData),
            CustomTableRow(children: [
              if (svt.noblePhantasms.isNotEmpty)
                TableCellData(
                  child: FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: svt.noblePhantasms
                          .map((e) => e.svt.card)
                          .toSet()
                          .map((e) => CommandCardWidget(card: e, width: 55))
                          .toList(),
                    ),
                  ),
                  flex: 2,
                ),
              TableCellData(
                child: svt.cards.isEmpty
                    ? const Text(' ')
                    : Opacity(
                        opacity: svt.cards.any((card) => !svt.cardDetails.containsKey(card)) ? 0.6 : 1,
                        child: FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: svt.cards.map((e) => CommandCardWidget(card: e, width: 44)).toList(),
                          ),
                        ),
                      ),
                flex: 4,
              )
            ]),
            if (svt.cards.any((card) => !svt.cardDetails.containsKey(card)))
              CustomTableRow(children: [
                TableCellData(
                  text: S.current.svt_card_deck_incorrect,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              ]),
            if (svt.cardDetails.isNotEmpty) CustomTableRow.fromTexts(texts: const ['Hits'], defaults: headerData),
            for (final entry in svt.cardDetails.entries) _addCardDetail(context, entry.key.name.toTitle(), entry.value),
            for (final td in tdHits.values)
              if (td.damageType != TdEffectFlag.support)
                _addCardDetail(
                    context, S.current.np_short, CardDetail(attackIndividuality: [], hitsDistribution: td.damage)),
            if (svt.noblePhantasms.isNotEmpty) ...[
              CustomTableRow.fromTexts(texts: [S.current.info_np_rate], defaults: headerData),
              CustomTableRow.fromTexts(
                  texts: const ['Buster', 'Arts', 'Quick', 'Extra', 'NP', 'Def'],
                  defaults: TableCellData(isHeader: true, maxLines: 1)),
            ],
            ..._npRates(),
            CustomTableRow.fromTexts(
                texts: [S.current.info_star_rate, S.current.info_death_rate, S.current.info_critical_rate],
                defaults: headerData),
            CustomTableRow.fromTexts(
              texts: [
                '${svt.starGen / 10}%',
                '${svt.instantDeathChance / 10}%',
                svt.starAbsorb.toString(),
              ],
              defaults: contentData,
            ),
            CustomTableRow.fromTexts(texts: [S.current.trait], defaults: headerData),
            ..._addTraits(context, null, baseTraits, []),
            for (final entry in svt.ascensionAdd.individuality.ascension.entries)
              ..._addTraits(
                  context, TextSpan(text: '${S.current.ascension_short} ${entry.key}: '), entry.value, baseTraits),
            for (final entry in svt.ascensionAdd.individuality.costume.entries)
              ..._addTraits(
                context,
                TextSpan(text: '${svt.profile.costume[entry.key]?.lName.l ?? entry.key}: '),
                entry.value,
                baseTraits,
              ),
            for (final traitAdd in svt.traitAdd)
              if (traitAdd.idx != 1)
                ..._addTraits(
                  context,
                  () {
                    final event = db.gameData.events[traitAdd.idx ~/ 100];
                    return TextSpan(
                      children: [
                        if (event != null) ...[
                          SharedBuilder.textButtonSpan(
                            context: context,
                            text: event.id.toString(),
                            onTap: event.routeTo,
                          ),
                          TextSpan(text: (traitAdd.idx % 100).toString().padLeft(2, '0'))
                        ],
                        if (event == null) TextSpan(text: traitAdd.idx.toString()),
                        const TextSpan(text: ': ')
                      ],
                    );
                  }(),
                  traitAdd.trait,
                  baseTraits,
                  0.9,
                ),
            if (svt.bondGrowth.isNotEmpty) ...[
              CustomTableRow.fromTexts(texts: [S.current.info_bond_points], defaults: headerData),
              for (int row = 0; row < svt.bondGrowth.length / 5; row++) ...[
                CustomTableRow.fromTexts(
                  texts: ['Lv.', for (int i = row * 5; i < row * 5 + 5; i++) (i + 1).toString()],
                  defaults: TableCellData(color: TableCellData.resolveHeaderColor(context).withOpacity(0.5)),
                ),
                CustomTableRow.fromTexts(
                  texts: [
                    S.current.info_bond_points_single,
                    for (int i = row * 5; i < row * 5 + 5; i++)
                      i >= svt.bondGrowth.length
                          ? '-'
                          : ((svt.bondGrowth.getOrNull(i) ?? 0) - (svt.bondGrowth.getOrNull(i - 1) ?? 0)).toString(),
                  ],
                  defaults: TableCellData(maxLines: 1),
                ),
                CustomTableRow.fromTexts(
                  texts: [
                    S.current.info_bond_points_sum,
                    for (int i = row * 5; i < row * 5 + 5; i++)
                      i >= svt.bondGrowth.length ? '-' : svt.bondGrowth[i].toString(),
                  ],
                  defaults: TableCellData(maxLines: 1),
                ),
              ],
            ],
            ...relateEvents(),
          ],
        ),
      ),
    );
  }

  List<Widget> relateEvents() {
    List<Widget> children = [];
    if (svt.extra.obtains.contains(SvtObtain.eventReward) || svt.type == SvtType.svtMaterialTd) {
      for (final event in db.gameData.events.values) {
        if (event.statItemFixed.containsKey(svt.id)) {
          children.add(ListTile(
            dense: true,
            title: Text(event.lName.l),
            onTap: event.routeTo,
          ));
        }
      }
    }
    if (children.isEmpty) return [];
    return [
      CustomTableRow.fromTexts(texts: [S.current.event], isHeader: true),
      ...children,
    ];
  }

  List<Widget> _addTraits(
    BuildContext context,
    InlineSpan? prefix,
    List<NiceTrait> traits, [
    List<NiceTrait> baseTraits = const [],
    double? textScaleFactor,
  ]) {
    if (traits.isEmpty) return [];
    traits = traits.toList()..sort2((e) => e.id);
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
    List<InlineSpan> children = [];
    if (prefix != null) children.add(prefix);
    children.addAll(SharedBuilder.traitSpans(context: context, traits: shownTraits));
    if (showMore) {
      children.add(CenterWidgetSpan(
        child: InkWell(
          child: const Icon(Icons.more_outlined, size: 16),
          onTap: () {
            showDialog(
              context: context,
              useRootNavigator: false,
              builder: (context) {
                return SimpleCancelOkDialog(
                  title: Text.rich(TextSpan(
                    text: S.current.trait,
                    children: prefix == null ? null : [const TextSpan(text: ' '), prefix],
                  )),
                  hideCancel: true,
                  content: SharedBuilder.traitList(
                    context: context,
                    traits: traits,
                  ),
                );
              },
            );
          },
        ),
      ));
    }
    return [
      CustomTableRow(children: [
        TableCellData(
          alignment: null,
          child: Text.rich(TextSpan(children: children), textScaleFactor: textScaleFactor),
        )
      ]),
    ];
  }

  Widget _addCardDetail(BuildContext context, String card, CardDetail detail) {
    List<InlineSpan> spans = [];
    final buffer = StringBuffer('  ');
    if (detail.hitsDistribution.isEmpty) {
      buffer.write('-');
    } else {
      buffer.write('${detail.hitsDistribution.length} Hits '
          '(${detail.hitsDistribution.join(', ')})');
    }
    if (detail.attackType == CommandCardAttackType.all) {
      buffer.write(' ');
      buffer.write(Transl.enums(TdEffectFlag.attackEnemyAll, (enums) => enums.tdEffectFlag).l);
    }
    spans.add(TextSpan(text: buffer.toString()));
    final scripts = {
      S.current.damage_rate: detail.damageRate?.format(percent: true, base: 10),
      S.current.attack_np_rate: detail.attackNpRate?.format(percent: true, base: 10),
      S.current.defense_np_rate: detail.defenseNpRate?.format(percent: true, base: 10),
      S.current.info_star_rate: detail.dropStarRate?.format(percent: true, base: 10),
    };
    scripts.removeWhere(((key, value) => value == null));
    if (scripts.isNotEmpty) {
      spans.add(const TextSpan(text: '\n'));
      spans.add(TextSpan(
          text: '   (${scripts.entries.map((e) => '${e.key} ${e.value}').join(', ')})',
          style: const TextStyle(fontSize: 12)));
    }
    return CustomTableRow(children: [
      TableCellData(text: card, isHeader: true),
      TableCellData(
        child: Text.rich(TextSpan(children: spans)),
        flex: 5,
        alignment: Alignment.centerLeft,
      )
    ]);
  }

  Widget _addAtkHpRow(BuildContext context, String header, List<int?> vals, [int? multiplier]) {
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
