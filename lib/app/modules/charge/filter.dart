import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../models/models.dart';
import '../common/filter_group.dart';
import '../common/filter_page_base.dart';

enum NpChargeType {
  instantSum,
  instant,
  perTurn,
  special,
  ;

  String get shownName {
    switch (this) {
      case NpChargeType.instantSum:
        return '${S.current.np_charge_type_instant_sum}*';
      case NpChargeType.instant:
        return S.current.np_charge_type_instant;
      case NpChargeType.perTurn:
        return S.current.np_charge_type_perturn;
      case NpChargeType.special:
        return S.current.general_special;
    }
  }
}

class NpFilterData {
  int skillLv = 10; // -1-disable, 0-class passive, 1-10,
  int skillCD = 0;
  int tdLv = 0; // 0-disable, 1-5
  int tdOC = 1; // 1-5
  bool isSvt = true;

  final favorite = FilterRadioData.nonnull(FavoriteState.all);
  final type = FilterRadioData.nonnull(NpChargeType.instant);
  final ceMax = FilterGroupData<bool>();
  final ceAtkType = FilterGroupData<CraftATKType>();
  final svtClass = FilterGroupData<SvtClass>();
  final rarity = FilterGroupData<int>();
  final effectTarget = FilterGroupData<EffectTarget>();
  final region = FilterRadioData<Region>();
  final tdColor = FilterRadioData<CardType>();
  final tdType = FilterRadioData<TdEffectFlag>();

  List<SvtCompare> svtSortKeys = [SvtCompare.no, SvtCompare.no];
  List<CraftCompare> ceSortKeys = [CraftCompare.no, CraftCompare.no];
  List<bool> sortReversed = [false, false];

  void reset() {
    skillLv = 10;
    skillCD = 0;
    tdLv = 0;
    tdOC = 1;
    for (var v in <FilterGroupData>[
      favorite,
      type,
      ceMax,
      ceAtkType,
      svtClass,
      rarity,
      effectTarget,
      region,
      tdColor,
      tdType
    ]) {
      v.reset();
    }
  }

  static String textSkillLv(int skillLv) {
    if (skillLv == -1) return '${S.current.skill} ×';
    if (skillLv == 0) return S.current.passive_skill;
    return '${S.current.skill} Lv.$skillLv';
  }

  static String textTdLv(int tdLv) {
    if (tdLv == 0) return '${S.current.np_short} ×';
    return '${S.current.np_short} $tdLv';
  }

  static String textTdOC(int tdOC) {
    return 'OC $tdOC';
  }

  static const kEffectTargets = [
    EffectTarget.self,
    EffectTarget.ptOne,
    EffectTarget.ptAll,
    EffectTarget.ptOther,
  ];
}

class NpChargeFilterPage extends FilterPage<NpFilterData> {
  const NpChargeFilterPage({
    super.key,
    required super.filterData,
    super.onChanged,
  });

  @override
  _NpChargeFilterPageState createState() => _NpChargeFilterPageState();
}

class _NpChargeFilterPageState
    extends FilterPageState<NpFilterData, NpChargeFilterPage> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content:
          getListViewBody(restorationId: 'np_charge_list_filter', children: [
        FilterGroup<bool>(
          options: const [true, false],
          values: FilterRadioData.nonnull(filterData.isSvt),
          optionBuilder: (v) =>
              Text(v ? S.current.servant : S.current.craft_essence),
          onFilterChanged: (v, _) {
            filterData.isSvt = v.radioValue ?? true;
            if (v.radioValue == false &&
                filterData.type.radioValue == NpChargeType.instantSum) {
              filterData.type.toggle(NpChargeType.instant);
            }
            update();
          },
        ),
        getGroup(header: S.current.filter_sort, children: [
          if (filterData.isSvt)
            for (int i = 0; i < filterData.svtSortKeys.length; i++)
              getSortButton<SvtCompare>(
                prefix: '${i + 1}',
                value: filterData.svtSortKeys[i],
                items: {for (final e in SvtCompare.values) e: e.showName},
                onSortAttr: (key) {
                  filterData.svtSortKeys[i] = key ?? filterData.svtSortKeys[i];
                  update();
                },
                reversed: filterData.sortReversed[i],
                onSortDirectional: (reversed) {
                  filterData.sortReversed[i] = reversed;
                  update();
                },
              ),
          if (!filterData.isSvt)
            for (int i = 0; i < filterData.ceSortKeys.length; i++)
              getSortButton<CraftCompare>(
                prefix: '${i + 1}',
                value: filterData.ceSortKeys[i],
                items: {for (final e in CraftCompare.values) e: e.shownName},
                onSortAttr: (key) {
                  filterData.ceSortKeys[i] = key ?? filterData.ceSortKeys[i];
                  update();
                },
                reversed: filterData.sortReversed[i],
                onSortDirectional: (reversed) {
                  filterData.sortReversed[i] = reversed;
                  update();
                },
              ),
        ]),
        FilterGroup<NpChargeType>(
          title: Text(S.current.general_type, style: textStyle),
          options: filterData.isSvt
              ? NpChargeType.values
              : NpChargeType.values
                  .where((e) => e != NpChargeType.instantSum)
                  .toList(),
          values: filterData.type,
          optionBuilder: (v) => Text(v.shownName),
          onFilterChanged: (v, _) {
            update();
          },
        ),
        if (filterData.isSvt)
          SFooter(
            '* ${S.current.np_charge_type_instant_sum} testing...',
            padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 5),
          ),
        if (filterData.isSvt)
          getGroup(header: S.current.level, children: [
            DropdownButton<int>(
              value: filterData.skillLv,
              items: [
                for (int lv = -1; lv <= 10; lv++)
                  DropdownMenuItem(
                    value: lv,
                    child: Text(
                      NpFilterData.textSkillLv(lv),
                      textScaleFactor: 0.9,
                    ),
                  )
              ],
              onChanged: (v) {
                if (v != null) filterData.skillLv = v;
                update();
              },
            ),
            DropdownButton<int>(
              value: filterData.skillCD >= 3 && filterData.skillCD <= 8
                  ? filterData.skillCD
                  : 0,
              items: [
                 const DropdownMenuItem(
                    value: 0,
                    child: Text(
                      'CD',
                      textScaleFactor: 0.9,
                    ),
                  ),
                for (int cd = 3; cd <= 8; cd++)
                  DropdownMenuItem(
                    value: cd,
                    child: Text(
                      'CD≤$cd',
                      textScaleFactor: 0.9,
                    ),
                  )
              ],
              onChanged: filterData.skillLv >= 1
                  ? (v) {
                      if (v != null) filterData.skillCD = v;
                      update();
                    }
                  : null,
            ),
            DropdownButton<int>(
              value: filterData.tdLv,
              items: [
                for (int lv = 0; lv <= 5; lv++)
                  DropdownMenuItem(
                    value: lv,
                    child: Text(
                      NpFilterData.textTdLv(lv),
                      textScaleFactor: 0.9,
                    ),
                  )
              ],
              onChanged: (v) {
                if (v != null) filterData.tdLv = v;
                update();
              },
            ),
            DropdownButton<int>(
              value: filterData.tdOC,
              items: [
                for (int lv = 1; lv <= 5; lv++)
                  DropdownMenuItem(
                    value: lv,
                    child: Text(
                      NpFilterData.textTdOC(lv),
                      textScaleFactor: 0.9,
                    ),
                  )
              ],
              onChanged: filterData.tdLv == 0
                  ? null
                  : (v) {
                      if (v != null) filterData.tdOC = v;
                      update();
                    },
            ),
          ]),
        if (!filterData.isSvt)
          FilterGroup<bool>(
            title: Text(S.current.ce_max_limit_break),
            options: const [false, true],
            values: filterData.ceMax,
            optionBuilder: (v) => Text(v
                ? S.current.ce_max_limit_break
                : 'NOT ${S.current.ce_max_limit_break}'),
            onFilterChanged: (value, _) {
              update();
            },
          ),
        if (!filterData.isSvt)
          FilterGroup<CraftATKType>(
            title: Text(S.current.filter_atk_hp_type),
            options: CraftATKType.values,
            values: filterData.ceAtkType,
            optionBuilder: (v) => Text(v.shownName),
            onFilterChanged: (value, _) {
              update();
            },
          ),
        FilterGroup<EffectTarget>(
          title: Text(S.current.effect_target),
          options: const [...NpFilterData.kEffectTargets, EffectTarget.special],
          values: filterData.effectTarget,
          optionBuilder: (v) => Text(v.shownName),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        buildGroupDivider(text: 'General'),
        if (filterData.isSvt)
          FilterGroup<FavoriteState>(
            // title: Text(S.current.filter_sort_rarity, style: textStyle),
            options: FavoriteState.values,
            values: filterData.favorite,
            optionBuilder: (v) => Icon(v.icon, size: 16),
            onFilterChanged: (value, _) {
              update();
            },
          ),
        if (filterData.isSvt) buildClassFilter(filterData.svtClass),
        FilterGroup<int>(
          title: Text(S.current.filter_sort_rarity, style: textStyle),
          options: const [0, 1, 2, 3, 4, 5],
          values: filterData.rarity,
          optionBuilder: (v) => Text('$v$kStarChar'),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<Region>(
          title: Text(S.current.game_server, style: textStyle),
          options: Region.values,
          values: filterData.region,
          optionBuilder: (v) => Text(v.localName),
          onFilterChanged: (v, _) {
            update();
          },
        ),
        if (filterData.isSvt)
          FilterGroup<CardType>(
            title: Text(S.current.noble_phantasm, style: textStyle),
            options: const [CardType.arts, CardType.buster, CardType.quick],
            values: filterData.tdColor,
            optionBuilder: (v) => Text(v.name.toTitle()),
            onFilterChanged: (value, _) {
              update();
            },
          ),
        if (filterData.isSvt)
          FilterGroup<TdEffectFlag>(
            values: filterData.tdType,
            options: TdEffectFlag.values,
            optionBuilder: (v) =>
                Text(Transl.enums(v, (enums) => enums.tdEffectFlag).l),
            onFilterChanged: (value, _) {
              update();
            },
          ),
      ]),
    );
  }
}
