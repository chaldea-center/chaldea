import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import '../../../models/models.dart';

class BuffFilterData {
  final stackable = FilterGroupData<bool>();
  final buffType = FilterGroupData<BuffType>();
  final trait = FilterGroupData<int>();

  BuffFilterData();

  List<FilterGroupData> get groups => [stackable, buffType, trait];

  void reset() {
    for (final group in groups) {
      group.reset();
    }
  }
}

class BuffFilter extends FilterPage<BuffFilterData> {
  const BuffFilter({
    Key? key,
    required BuffFilterData filterData,
    ValueChanged<BuffFilterData>? onChanged,
  }) : super(key: key, onChanged: onChanged, filterData: filterData);

  @override
  _BuffFilterState createState() => _BuffFilterState();
}

class _BuffFilterState extends FilterPageState<BuffFilterData, BuffFilter> {
  Map<BuffType, String> buffTypes = {};

  @override
  void initState() {
    super.initState();
    buffTypes = {
      for (final buff in db.gameData.baseBuffs.values)
        buff.type: SearchUtil.getSortAlphabet(Transl.buffType(buff.type).l),
    };
    buffTypes =
        Map.fromEntries(buffTypes.entries.toList()..sort2((e) => e.value));
  }

  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(restorationId: 'buff_list_filter', children: [
        FilterGroup<bool>(
          title: const Text("Stackable"),
          options: const [true, false],
          values: filterData.stackable,
          optionBuilder: (v) => Text(v ? "Stackable" : "Not-Stackable"),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<BuffType>(
          title: Text(S.current.effect_target),
          options: buffTypes.keys.toList(),
          values: filterData.buffType,
          optionBuilder: (v) => Text(Transl.buffType(v).l),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        // FilterGroup<int>(
        //   title: const Text('Condition Traits'),
        //   options: [],
        //   values: filterData.trait,
        //   showMatchAll: false,
        //   showInvert: false,
        //   optionBuilder: (v) => Text(Transl.trait(v).l),
        //   onFilterChanged: (value, _) {
        //     update();
        //   },
        // ),
      ]),
    );
  }
}
