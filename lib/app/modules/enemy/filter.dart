import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../models/models.dart';
import '../common/filter_group.dart';
import '../common/filter_page_base.dart';

class EnemyFilterPage extends FilterPage<EnemyFilterData> {
  const EnemyFilterPage({
    Key? key,
    required EnemyFilterData filterData,
    ValueChanged<EnemyFilterData>? onChanged,
  }) : super(key: key, onChanged: onChanged, filterData: filterData);

  @override
  _EnemyFilterPageState createState() => _EnemyFilterPageState();
}

class _EnemyFilterPageState extends FilterPageState<EnemyFilterData> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        getGroup(header: S.of(context).filter_sort, children: [
          FilterGroup.display(
            useGrid: filterData.useGrid,
            onChanged: (v) {
              if (v != null) filterData.useGrid = v;
              update();
            },
          ),
        ]),
        SwitchListTile.adaptive(
          value: filterData.onlyShowQuestEnemy,
          controlAffinity: ListTileControlAffinity.trailing,
          title: const Text(
            'Only Show Quest Enemy',
            textScaleFactor: 0.8,
          ),
          onChanged: (v) {
            filterData.onlyShowQuestEnemy = v;
            update();
          },
        ),
        buildClassFilter(filterData.svtClass),
        FilterGroup<Attribute>(
          title: Text(S.of(context).filter_attribute, style: textStyle),
          options: Attribute.values.sublist(0, 5),
          values: filterData.attribute,
          optionBuilder: (v) => Text(Transl.svtAttribute(v).l),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<Trait>(
          title: Text('${S.current.info_trait}*', style: textStyle),
          options: _traitsForFilter,
          values: filterData.trait,
          optionBuilder: (v) =>
              Text(v.id != null ? Transl.trait(v.id!).l : v.name),
          showMatchAll: true,
          showInvert: true,
          onFilterChanged: (value) {
            update();
          },
        ),
        SFooter(S.current.enemy_filter_trait_hint),
      ]),
    );
  }
}

const _traitsForFilter = <Trait>[
  Trait.humanoid,
  Trait.human,
  Trait.genderFemale,
  Trait.genderMale,
  Trait.demonic,
  Trait.divine,
  Trait.dragon,
  Trait.demonBeast,
  Trait.wildbeast,
  Trait.demon,
  Trait.undead,
  Trait.oni,
  Trait.king,
  Trait.superGiant,
  Trait.giant,
  Trait.mechanical,
  Trait.greekMythologyMales,
  Trait.roman,
  Trait.fae,
];