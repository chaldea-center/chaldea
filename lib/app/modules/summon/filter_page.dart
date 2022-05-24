import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import '../common/filter_group.dart';

class SummonFilterPage extends FilterPage<SummonFilterData> {
  const SummonFilterPage({
    Key? key,
    required SummonFilterData filterData,
    ValueChanged<SummonFilterData>? onChanged,
  }) : super(key: key, onChanged: onChanged, filterData: filterData);

  @override
  _CmdCodeFilterPageState createState() => _CmdCodeFilterPageState();
}

class _CmdCodeFilterPageState extends FilterPageState<SummonFilterData> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        SwitchListTile.adaptive(
          value: filterData.showBanner,
          title: Text(S.current.summon_show_banner),
          onChanged: (v) {
            filterData.showBanner = v;
            update();
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        SwitchListTile.adaptive(
          value: filterData.showOutdated,
          title: Text(S.current.show_outdated),
          onChanged: (v) {
            filterData.showOutdated = v;
            update();
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        FilterGroup<SummonType>(
          title: Text(S.of(context).filter_category),
          options: List.of(SummonType.values),
          values: filterData.category,
          optionBuilder: (v) {
            return Text(v.name);
          },
          onFilterChanged: (value, _) {
            // filterData.category = value;
            update();
          },
        ),
      ]),
    );
  }
}
