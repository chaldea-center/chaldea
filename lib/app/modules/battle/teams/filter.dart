import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';

class TeamFilterData {
  static List<int> get _blockedSvtIds => [16, 258, 284, 316];

  final blockedSvts = FilterGroupData<int>();

  List<FilterGroupData> get groups => [blockedSvts];

  void reset() {
    for (final group in groups) {
      group.reset();
    }
  }
}

class TeamFilter extends FilterPage<TeamFilterData> {
  const TeamFilter({
    super.key,
    required super.filterData,
    super.onChanged,
  });

  @override
  _ShopFilterState createState() => _ShopFilterState();
}

class _ShopFilterState extends FilterPageState<TeamFilterData, TeamFilter> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(restorationId: 'team_list_filter', children: [
        FilterGroup<int>(
          title: const Text("Blocked Servants"),
          options: TeamFilterData._blockedSvtIds,
          values: filterData.blockedSvts,
          optionBuilder: (v) {
            final svt = db.gameData.servantsNoDup[v];
            return Text(svt == null ? v.toString() : '$v-${svt.lName.l}');
          },
          onFilterChanged: (value, _) {
            update();
          },
        ),
      ]),
    );
  }
}
