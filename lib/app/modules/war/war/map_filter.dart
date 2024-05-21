import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';

class WarMapFilterData with FilterDataMixin {
  bool showSpots = true;
  bool freeSpotsOnly = true;
  bool showRoads = false;
  bool showHeader = true;

  final gimmick = FilterGroupData<int?>();
  final validGimmickIds = <int>{};

  @override
  List<FilterGroupData> get groups => [gimmick];

  @override
  void reset() {
    super.reset();
    showRoads = showSpots = true;
    freeSpotsOnly = true;
    showHeader = true;
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

class _WarMapFilterPageState extends FilterPageState<WarMapFilterData, WarMapFilter> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filterData.validGimmickIds.isNotEmpty)
          FilterGroup<int?>(
            title: Text(S.current.map_gimmicks),
            options: [null, ...filterData.validGimmickIds.toList()..sort()],
            values: filterData.gimmick,
            optionBuilder: (v) {
              if (v == null) {
                return Text('(${S.current.general_all})');
              }
              String text = v.toString();
              String warId = widget.war.id.toString();
              if (text.startsWith(warId)) text = text.substring(warId.length);
              return Text(text);
            },
            onFilterChanged: (value, last) {
              if (last == null) {
                if (filterData.validGimmickIds.any((e) => !filterData.gimmick.options.contains(e))) {
                  filterData.gimmick.options = filterData.validGimmickIds.toSet();
                } else {
                  filterData.gimmick.options = {};
                }
                filterData.gimmick.options.remove(null);
              }
              update();
            },
          ),
        SwitchListTile.adaptive(
          controlAffinity: ListTileControlAffinity.trailing,
          value: filterData.showSpots,
          title: Text(S.current.map_show_spots),
          dense: true,
          onChanged: (v) {
            filterData.showSpots = v;
            update();
          },
        ),
        SwitchListTile.adaptive(
          controlAffinity: ListTileControlAffinity.trailing,
          value: filterData.freeSpotsOnly,
          title: Text(S.current.map_show_fq_spots_only),
          dense: true,
          onChanged: filterData.showSpots
              ? (v) {
                  filterData.freeSpotsOnly = v;
                  update();
                }
              : null,
        ),
        SwitchListTile.adaptive(
          controlAffinity: ListTileControlAffinity.trailing,
          value: filterData.showRoads,
          title: Text(S.current.map_show_roads),
          dense: true,
          onChanged: (v) {
            filterData.showRoads = v;
            update();
          },
        ),
        SwitchListTile.adaptive(
          controlAffinity: ListTileControlAffinity.trailing,
          value: filterData.showHeader,
          title: Text(S.current.map_show_header_image),
          dense: true,
          onChanged: (v) {
            filterData.showHeader = v;
            update();
          },
        ),
      ],
    );
  }
}
