import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/charts/growth_curve_page.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../creator/creator_detail.dart';

class SvtInfoTab extends StatelessWidget {
  final Servant svt;

  const SvtInfoTab({super.key, required this.svt});

  static final headerData = TableCellData(isHeader: true, maxLines: 1);
  static final contentData = TableCellData(textAlign: TextAlign.center, maxLines: 1);

  @override
  Widget build(BuildContext context) {
    Set<String> names = {
      svt.name,
      ...svt.ascensionAdd.overWriteServantName.all.values,
      ...svt.svtChange.map((e) => e.name),
    };
    final baseTraits = [
      ...svt.traits,
      // for (final traitAdd in svt.traitAdd)
      //   if (traitAdd.isAlwaysValid) ...traitAdd.trait,
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
            CustomTableRow(
              children: [TableCellData(child: name, isHeader: true, padding: const EdgeInsets.all(4))],
            ),
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
            CustomTableRow.fromChildren(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  children: [
                    for (final rarity in <int>{
                      ...svt.limits.values.map((e) => e.rarity ?? svt.rarity),
                      svt.rarity,
                      ...svt.ascensionAdd.overwriteRarity.all.values,
                    })
                      if (rarity != 0)
                        CachedImage(
                          imageUrl:
                              "https://static.atlasacademy.io/JP/CharaGraphOption/CharaGraphOption/CharaGraphOptionAtlas/rarity${rarity}_0.png",
                          height: 24,
                          placeholder: (_, _) => Text(kStarChar2 * rarity),
                        ),
                  ],
                ),
              ],
            ),
            CustomTableRow.fromChildren(
              children: [
                Text(
                  svt.isDupSvt ? 'No.${svt.originalCollectionNo}\n${svt.collectionNo}' : 'No.${svt.collectionNo}',
                  textAlign: TextAlign.center,
                ),
                Text('No. ${svt.id}', textAlign: TextAlign.center, maxLines: 1),
                GestureDetector(
                  onTap: () {
                    SvtClassX.routeTo(svt.classId);
                  },
                  child: Text.rich(
                    TextSpan(
                      children: [
                        CenterWidgetSpan(child: db.getIconImage(svt.clsIcon, width: 20, aspectRatio: 1)),
                        SharedBuilder.textButtonSpan(context: context, text: ' ${Transl.svtClassId(svt.classId).l}'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            CustomTableRow.fromTexts(
              texts: [S.current.illustrator, S.current.info_cv, S.current.gender],
              defaults: headerData,
            ),
            CustomTableRow(
              children: [
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
                TableCellData(text: Transl.enums(svt.gender, (enums) => enums.gender).l, textAlign: TextAlign.center),
              ],
            ),
            CustomTableRow.fromTexts(
              texts: [
                S.current.info_strength,
                S.current.info_endurance,
                S.current.info_agility,
                S.current.info_mana,
                S.current.info_luck,
                S.current.info_np,
              ],
              defaults: headerData,
            ),
            CustomTableRow.fromTexts(
              texts: [
                _infoWithLimits(svt.profile.stats?.strength ?? '-', svt.limits.values.map((e) => e.strength)),
                _infoWithLimits(svt.profile.stats?.endurance ?? '-', svt.limits.values.map((e) => e.endurance)),
                _infoWithLimits(svt.profile.stats?.agility ?? '-', svt.limits.values.map((e) => e.agility)),
                _infoWithLimits(svt.profile.stats?.magic ?? '-', svt.limits.values.map((e) => e.magic)),
                _infoWithLimits(svt.profile.stats?.luck ?? '-', svt.limits.values.map((e) => e.luck)),
                _infoWithLimits(svt.profile.stats?.np ?? '-', svt.limits.values.map((e) => e.np)),
              ],
              defaults: contentData,
            ),
            CustomTableRow(
              children: [
                TableCellData(text: S.current.svt_sub_attribute, isHeader: true, flex: 2),
                TableCellData(text: S.current.svt_attribute, isHeader: true, flex: 2),
                TableCellData(text: S.current.general_type, isHeader: true, flex: 2),
              ],
            ),
            CustomTableRow(
              children: [
                TableCellData(
                  text: _infoWithLimits(
                    svt.attribute,
                    svt.ascensionAdd.attribute.all.values,
                    (v) => Transl.svtSubAttribute(v).l,
                  ),
                ),
                TableCellData(
                  text: _infoWithLimits<(ServantPolicy?, ServantPersonality?)>(
                    (svt.profile.stats?.policy, svt.profile.stats?.personality),
                    svt.limits.values.map((e) {
                      if (e.policy == null && e.personality == null) return null;
                      return (e.policy ?? svt.profile.stats?.policy, e.personality ?? svt.profile.stats?.personality);
                    }),
                    (v) =>
                        '${Transl.servantPolicy(v.$1 ?? ServantPolicy.none).l}·${Transl.servantPersonality(v.$2 ?? ServantPersonality.none).l}',
                  ),
                  textAlign: TextAlign.center,
                ),
                TableCellData(text: Transl.enums(svt.type, (enums) => enums.svtType).l),
              ],
            ),
            ..._atkHpTable(context),
            CustomTableRow.fromTexts(texts: [S.current.info_cards], defaults: headerData),
            CustomTableRow(
              children: [
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
                ),
              ],
            ),
            if (svt.cards.any((card) => !svt.cardDetails.containsKey(card)))
              CustomTableRow(
                children: [
                  TableCellData(text: S.current.svt_card_deck_incorrect, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            if (svt.cardDetails.isNotEmpty) CustomTableRow.fromTexts(texts: const ['Hits'], defaults: headerData),
            for (final entry in svt.cardDetails.entries) _addCardDetail(context, entry.key.name.toTitle(), entry.value),
            for (final td in tdHits.values)
              if (td.damageType != TdEffectFlag.support)
                _addCardDetail(
                  context,
                  S.current.np_short,
                  CardDetail(attackIndividuality: [], hitsDistribution: td.damage),
                ),
            if (svt.noblePhantasms.isNotEmpty) ...[
              CustomTableRow.fromTexts(texts: [S.current.info_np_rate], defaults: headerData),
              CustomTableRow.fromTexts(
                texts: const ['Buster', 'Arts', 'Quick', 'Extra', 'NP', 'Def'],
                defaults: TableCellData(isHeader: true, maxLines: 1),
              ),
            ],
            ..._npRates(),
            CustomTableRow.fromTexts(
              texts: [S.current.info_star_rate, S.current.info_death_rate, S.current.info_critical_rate],
              defaults: headerData,
            ),
            CustomTableRow.fromTexts(
              texts: [
                '${svt.starGen / 10}%',
                '${svt.instantDeathChance / 10}%',
                _infoWithLimits(svt.criticalWeight, svt.limits.values.map((e) => e.criticalWeight)),
              ],
              defaults: contentData,
            ),
            CustomTableRow.fromTexts(texts: [S.current.trait], defaults: headerData),
            ..._addTraits(context, null, baseTraits, []),
            for (final entry in svt.ascensionAdd.individuality.ascension.entries)
              ..._addTraits(
                context,
                TextSpan(text: '${S.current.ascension_short} ${entry.key}: '),
                entry.value,
                baseTraits,
              ),
            for (final entry in svt.ascensionAdd.individuality.costume.entries)
              ..._addTraits(
                context,
                TextSpan(text: '${svt.profile.costume[entry.key]?.lName.l ?? entry.key}: '),
                entry.value,
                baseTraits,
              ),
            for (final traitAdd in svt.traitAdd)
              ..._addTraits(
                context,
                () {
                  final eventIdStr = traitAdd.eventId.toString(), idxStr = traitAdd.idx.toString();
                  return TextSpan(
                    children: [
                      if (traitAdd.condType != CondType.none)
                        CenterWidgetSpan(
                          child: InkWell(
                            child: Icon(Icons.info_outline, size: 16, color: AppTheme(context).tertiary),
                            onTap: () {
                              SimpleConfirmDialog(
                                title: Text(S.current.condition),
                                content: CondTargetValueDescriptor(
                                  condType: traitAdd.condType,
                                  target: traitAdd.condId,
                                  value: traitAdd.condNum,
                                ),
                              ).showDialog(context);
                            },
                          ),
                        ),
                      if (traitAdd.limitCount != -1) TextSpan(text: '(${svt.getLimitName(traitAdd.limitCount)})'),
                      if (traitAdd.eventId != 0) ...[
                        SharedBuilder.textButtonSpan(
                          context: context,
                          text: traitAdd.eventId.toString(),
                          onTap: () {
                            router.push(url: Routes.eventI(traitAdd.eventId));
                          },
                        ),
                        TextSpan(text: (idxStr.startsWith(eventIdStr) ? idxStr.substring(eventIdStr.length) : idxStr)),
                      ],
                      if (traitAdd.eventId == 0) TextSpan(text: idxStr),
                      const TextSpan(text: ': '),
                    ],
                  );
                }(),
                traitAdd.trait,
                [],
                0.9,
              ),
            if (svt.bondGrowth.isNotEmpty) ...[
              CustomTableRow.fromTexts(texts: [S.current.info_bond_points], defaults: headerData),
              for (int row = 0; row < svt.bondGrowth.length / 5; row++) ...[
                CustomTableRow.fromTexts(
                  texts: ['Lv.', for (int i = row * 5; i < row * 5 + 5; i++) (i + 1).toString()],
                  defaults: TableCellData(color: TableCellData.resolveHeaderColor(context).withAlpha(128)),
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
                if (svt.bondGifts.isNotEmpty)
                  CustomTableRow.fromChildren(
                    defaults: TableCellData(maxLines: 1),
                    children: [
                      Text('Gift'),
                      for (int i = row * 5; i < row * 5 + 5; i++)
                        Wrap(
                          children: [
                            for (final gift in svt.bondGifts[i + 1] ?? <Gift>[])
                              gift.iconBuilder(context: context, width: 28),
                          ],
                        ),
                    ],
                  ),
              ],
            ],
            ...relateEvents(),
            if (svt.isUserSvt && svt.collectionNo > 1) ...[
              CustomTableRow.fromTexts(texts: ['${S.current.time}(estimated)'], isHeader: true),
              CustomTableRow.fromTexts(
                texts: [svt.extra.getReleasedAt()].map((e) => e == 0 ? '-' : e.sec2date().toDateString()).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _infoWithLimits<T>(T base, Iterable<T?> limits, [String Function(T v)? format]) {
    return <T>{base, ...limits.whereType<T>()}.map((e) => format?.call(e) ?? e.toString()).join(' / ');
  }

  List<Widget> relateEvents() {
    List<Widget> children = [];
    if (svt.obtains.contains(SvtObtain.eventReward) || svt.type == SvtType.svtMaterialTd) {
      for (final event in db.gameData.events.values) {
        if (event.statItemFixed.containsKey(svt.id)) {
          children.add(ListTile(dense: true, title: Text(event.lName.l), onTap: event.routeTo));
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
      if (trait.id == Trait.canBeInBattle.value) continue;
      if (baseTraitIds.contains(trait.signedId)) {
        showMore = true;
        continue;
      }
      shownTraits.add(trait);
    }
    if (shownTraits.isEmpty) return [];
    List<InlineSpan> children = [];
    if (prefix != null) children.add(prefix);
    children.addAll(SharedBuilder.traitSpans(context: context, traits: shownTraits));
    if (showMore) {
      children.add(
        CenterWidgetSpan(
          child: InkWell(
            child: const Icon(Icons.more_outlined, size: 16),
            onTap: () {
              showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) {
                  return SimpleConfirmDialog(
                    title: Text.rich(
                      TextSpan(
                        text: S.current.trait,
                        children: prefix == null ? null : [const TextSpan(text: ' '), prefix],
                      ),
                    ),
                    showCancel: false,
                    content: SharedBuilder.traitList(context: context, traits: traits),
                  );
                },
              );
            },
          ),
        ),
      );
    }
    return [
      CustomTableRow(
        children: [
          TableCellData(
            alignment: null,
            child: Text.rich(
              TextSpan(children: children),
              textScaler: textScaleFactor == null ? null : TextScaler.linear(textScaleFactor),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _addCardDetail(BuildContext context, String card, CardDetail detail) {
    List<InlineSpan> spans = [];
    final buffer = StringBuffer('  ');
    if (detail.hitsDistribution.isEmpty) {
      buffer.write('-');
    } else {
      buffer.write(
        '${detail.hitsDistribution.length} Hits '
        '(${detail.hitsDistribution.join(', ')})',
      );
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
    final positionDamageRates = detail.positionDamageRates?.map((e) => e.format(percent: true, base: 10)).toList();
    if (positionDamageRates != null) {
      String text =
          switch (detail.positionDamageRatesSlideType) {
            SvtCardPositionDamageRatesSlideType.front => '(${S.current.team_starting_member})',
            SvtCardPositionDamageRatesSlideType.back => '(${S.current.team_backup_member})',
            SvtCardPositionDamageRatesSlideType.none || null => '',
          } +
          positionDamageRates.toString();
      scripts['positionDamageRates'] = text;
    }
    scripts.removeWhere(((key, value) => value == null));
    if (scripts.isNotEmpty) {
      spans.add(const TextSpan(text: '\n'));
      spans.add(
        TextSpan(
          text: '   (${scripts.entries.map((e) => '${e.key} ${e.value}').join(', ')})',
          style: const TextStyle(fontSize: 12),
        ),
      );
    }
    return CustomTableRow(
      children: [
        TableCellData(text: card, isHeader: true),
        TableCellData(
          child: Text.rich(TextSpan(children: spans)),
          flex: 5,
          alignment: Alignment.centerLeft,
        ),
      ],
    );
  }

  List<Widget> _atkHpTable(BuildContext context) {
    final rows = <Widget>[
      CustomTableRow.fromTexts(
        texts: [S.current.info_value, 'Lv.1', 'Lv.${svt.lvMax}', 'Lv.90', 'Lv.100', 'Lv.120'],
        defaults: headerData,
      ),
    ];

    void _addGroup(int limit, int atkBase, int atkMax, int hpBase, int hpMax, SvtExpData curveData) {
      Widget _addAtkHpRow(String header, List<int?> vals, [int? multiplier]) {
        final texts = vals.map(
          (e) => e == null ? '-' : (multiplier == null ? e.toString() : (e * multiplier ~/ 1000).toString()),
        );
        return CustomTableRow(
          children: [
            TableCellData(
              child: InkWell(
                onTap: () {
                  if (db.gameData.constData.svtExp.containsKey(svt.growthCurve)) {
                    router.pushPage(
                      GrowthCurvePage.fromCard(
                        title: '${S.current.growth_curve} - ${svt.lName.l}',
                        lvs: curveData.lv,
                        atks: curveData.atk,
                        hps: curveData.hp,
                        avatar: CachedImage(
                          imageUrl:
                              svt.extraAssets.status.ascension?[limit] ??
                              svt.extraAssets.status.costume?[limit] ??
                              svt.icon,
                          height: 90,
                          placeholder: (_, _) => Container(),
                        ),
                      ),
                    );
                  }
                },
                child: Text(header),
              ),
              isHeader: true,
              maxLines: 1,
            ),
            for (final text in texts) TableCellData(text: text, maxLines: 1),
          ],
        );
      }

      rows.addAll([
        _addAtkHpRow('ATK', [
          atkBase,
          atkMax,
          curveData.atk.getOrNull(89),
          curveData.atk.getOrNull(99),
          curveData.atk.getOrNull(119),
        ]),
        _addAtkHpRow('ATK*', [
          atkBase,
          atkMax,
          curveData.atk.getOrNull(89),
          curveData.atk.getOrNull(99),
          curveData.atk.getOrNull(119),
        ], db.gameData.constData.classInfo[svt.classId]?.attackRate),
        _addAtkHpRow('HP', [
          hpBase,
          hpMax,
          curveData.hp.getOrNull(89),
          curveData.hp.getOrNull(99),
          curveData.hp.getOrNull(119),
        ]),
      ]);
    }

    _addGroup(1, svt.atkBase, svt.atkMax, svt.hpBase, svt.hpMax, svt.curveData);
    final overwriteLimits = <int>{
      ...svt.ascensionAdd.overwriteAtkBase.all.keys,
      ...svt.ascensionAdd.overwriteAtkMax.all.keys,
      ...svt.ascensionAdd.overwriteHpBase.all.keys,
      ...svt.ascensionAdd.overwriteHpMax.all.keys,
    };
    Map<(int, int, int, int, int), List<int>> map = {};
    for (final limit in overwriteLimits) {
      final key = (
        svt.ascensionAdd.overwriteAtkBase.all[limit] ?? svt.atkBase,
        svt.ascensionAdd.overwriteAtkMax.all[limit] ?? svt.atkMax,
        svt.ascensionAdd.overwriteHpBase.all[limit] ?? svt.hpBase,
        svt.ascensionAdd.overwriteHpMax.all[limit] ?? svt.hpMax,
        svt.ascensionAdd.overwriteExpType.all[limit] ?? svt.growthCurve,
      );
      (map[key] ??= []).add(limit);
    }
    for (final (key, limits) in map.items) {
      rows.add(
        CustomTableRow.fromTexts(texts: [limits.map((e) => svt.getLimitName(e)).join(" / ")], defaults: contentData),
      );
      final (atkBase, atkMax, hpBase, hpMax, expType) = key;
      _addGroup(
        limits.first,
        atkBase,
        atkMax,
        hpBase,
        hpMax,
        SvtExpData.from(type: expType, atkBase: atkBase, atkMax: atkMax, hpBase: hpBase, hpMax: hpMax),
      );
    }

    return rows;
  }

  List<Widget> _npRates() {
    List<Widget> rows = [];
    List<List<int?>> values = [];
    for (final td in svt.noblePhantasms) {
      final v = td.npGain.firstValues;
      if (values.any((e) => e.toString() == v.toString())) continue;
      values.add(v);
      rows.add(
        CustomTableRow.fromTexts(
          texts: v.map((e) => '${(e ?? 0) / 100}%').toList(),
          defaults: TableCellData(textAlign: TextAlign.center, maxLines: 1),
        ),
      );
    }
    return rows;
  }
}
