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
}

extension NpChargeTypeX on NpChargeType {
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
  int tdLv = 0; // 0-disable, 1-5
  int tdOC = 1; // 1-5

  final favorite = FilterRadioData.nonnull(FavoriteState.all);
  final type = FilterRadioData.nonnull(NpChargeType.instant);
  final svtClass = FilterGroupData<SvtClass>();
  final rarity = FilterGroupData<int>();
  final effectTarget = FilterRadioData<EffectTarget>();
  final region = FilterRadioData<Region>();
  final tdColor = FilterRadioData<CardType>();
  final tdType = FilterRadioData<TdEffectFlag>();

  List<SvtCompare> sortKeys = [SvtCompare.no, SvtCompare.no];
  List<bool> sortReversed = [false, false];

  void reset() {
    skillLv = 10;
    tdLv = 0;
    tdOC = 1;
    for (var v in <FilterGroupData>[
      favorite,
      type,
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
        getGroup(header: S.current.filter_sort, children: [
          for (int i = 0; i < filterData.sortKeys.length; i++)
            getSortButton<SvtCompare>(
              prefix: '${i + 1}',
              value: filterData.sortKeys[i],
              items: {for (final e in SvtCompare.values) e: e.showName},
              onSortAttr: (key) {
                filterData.sortKeys[i] = key ?? filterData.sortKeys[i];
                update();
              },
              reversed: filterData.sortReversed[i],
              onSortDirectional: (reversed) {
                filterData.sortReversed[i] = reversed;
                update();
              },
            )
        ]),
        FilterGroup<NpChargeType>(
          title: Text(S.current.general_type, style: textStyle),
          options: NpChargeType.values,
          values: filterData.type,
          optionBuilder: (v) => Text(v.shownName),
          onFilterChanged: (v, _) {
            update();
          },
        ),
        SFooter(
          '* ${S.current.np_charge_type_instant_sum} testing...',
          padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 5),
        ),
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
        FilterGroup<FavoriteState>(
          // title: Text(S.current.filter_sort_rarity, style: textStyle),
          options: FavoriteState.values,
          values: filterData.favorite,
          optionBuilder: (v) => Icon(v.icon, size: 16),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        buildClassFilter(filterData.svtClass),
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
        FilterGroup<CardType>(
          title: Text(S.current.noble_phantasm, style: textStyle),
          options: const [CardType.arts, CardType.buster, CardType.quick],
          values: filterData.tdColor,
          optionBuilder: (v) => Text(v.name.toTitle()),
          onFilterChanged: (value, _) {
            update();
          },
        ),
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
