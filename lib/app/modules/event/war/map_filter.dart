import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';

class WarMapFilterData {
  bool showRoads = true;
  bool showSpots = true;
  bool freeSpotsOnly = true;

  final gimmick = FilterGroupData<int>();
  final validGimmickIds = <int>{};

  void reset() {
    for (var v in <FilterGroupData>[gimmick]) {
      v.reset();
    }
    showRoads = showSpots = true;
    freeSpotsOnly = true;
  }
}

class WarMapFilter extends FilterPage<WarMapFilterData> {
  final NiceWar war;
  final WarMap map;
  const WarMapFilter({
    super.key,
    required super.filterData,
    required this.war,
    required this.map,
    super.onChanged,
  });

  @override
  _WarMapFilterPageState createState() => _WarMapFilterPageState();
}

class _WarMapFilterPageState
    extends FilterPageState<WarMapFilterData, WarMapFilter> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(restorationId: 'war_map_filter', children: [
        if (filterData.validGimmickIds.isNotEmpty)
          FilterGroup<int>(
            title: const Text('Gimmicks'),
            options: filterData.validGimmickIds.toList()..sort(),
            values: filterData.gimmick,
            optionBuilder: (v) {
              String text = v.toString();
              String warId = widget.war.id.toString();
              if (text.startsWith(warId)) text = text.substring(warId.length);
              return Text(text);
            },
            onFilterChanged: (value, _) {
              update();
            },
          ),
        SwitchListTile.adaptive(
          controlAffinity: ListTileControlAffinity.trailing,
          value: filterData.showRoads,
          title: const Text('Show Roads'),
          dense: true,
          onChanged: (v) {
            filterData.showRoads = v;
            update();
          },
        ),
        SwitchListTile.adaptive(
          controlAffinity: ListTileControlAffinity.trailing,
          value: filterData.showSpots,
          title: const Text('Show Spots'),
          dense: true,
          onChanged: (v) {
            filterData.showSpots = v;
            update();
          },
        ),
        SwitchListTile.adaptive(
          controlAffinity: ListTileControlAffinity.trailing,
          value: filterData.freeSpotsOnly,
          title: const Text('FQ Spots only'),
          dense: true,
          onChanged: filterData.showSpots
              ? (v) {
                  filterData.freeSpotsOnly = v;
                  update();
                }
              : null,
        ),
      ]),
    );
  }
}
