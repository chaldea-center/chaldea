import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';

class UserPresentBoxFilterPage extends FilterPage<PresentBoxFilterData> {
  final Set<int> presentFromTypes;
  const UserPresentBoxFilterPage({
    super.key,
    required super.filterData,
    super.onChanged,
    this.presentFromTypes = const {},
  });

  @override
  _ShopFilterState createState() => _ShopFilterState();
}

class _ShopFilterState extends FilterPageState<PresentBoxFilterData, UserPresentBoxFilterPage> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaler: const TextScaler.linear(0.8)),
      actions: getDefaultActions(
        onTapReset: () {
          filterData.reset();
          update();
        },
      ),
      content: getListViewBody(
        restorationId: 'present_box_filter',
        children: [
          FilterGroup<int>(
            title: Text(S.current.general_type),
            options: {for (final v in PresentFromType.values) v.value, ...widget.presentFromTypes}.toList(),
            values: FilterGroupData(options: filterData.presentFromType.toSet()),
            optionBuilder: (v) => Text(
              Transl.enumsInt(v, (e) => e.presentFromType).l,
              style: widget.presentFromTypes.contains(v) ? null : TextStyle(color: Theme.of(context).disabledColor),
            ),
            onFilterChanged: (value, _) {
              filterData.presentFromType = value.options.toSet();
              update();
            },
          ),
          FilterGroup<PresentType>(
            title: Text(S.current.general_type),
            options: PresentType.values,
            values: FilterGroupData(options: filterData.presentTypes.toSet()),
            optionBuilder: (v) => Text(v.shownName),
            onFilterChanged: (value, _) {
              filterData.presentTypes = value.options.toSet();
              update();
            },
          ),
          FilterGroup<int>(
            title: Text(S.current.rarity),
            options: const [1, 2, 3, 4, 5],
            values: FilterGroupData(options: filterData.rarities.toSet()),
            onFilterChanged: (value, _) {
              filterData.rarities = value.options.toSet();
              update();
            },
          ),
          ListTile(
            dense: true,
            title: Text('Max num'),
            trailing: TextButton(
              onPressed: () {
                InputCancelOkDialog.number(
                  title: 'Max num',
                  validate: (v) => v >= 0,
                  onSubmit: (v) {
                    filterData.maxNum = v;
                    update();
                  },
                ).showDialog(context);
              },
              child: Text(filterData.maxNum.toString()),
            ),
          ),
        ],
      ),
    );
  }
}
