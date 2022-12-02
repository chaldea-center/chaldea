import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import '../../../models/models.dart';

enum ShopSort {
  priority,
  openTime,
}

class ShopFilterData {
  final type = FilterGroupData<ShopType>();
  final permanent = FilterGroupData<bool>();
  final purchaseType = FilterGroupData<PurchaseType>();

  ShopSort sortType = ShopSort.openTime;
  bool reversed = false;

  List<FilterGroupData> get groups => [type, permanent, purchaseType];

  void reset() {
    for (final group in groups) {
      group.reset();
    }
  }
}

class ShopFilter extends FilterPage<ShopFilterData> {
  final List<PurchaseType> purchaseTypes;

  const ShopFilter({
    super.key,
    required super.filterData,
    super.onChanged,
    this.purchaseTypes = const [],
  });

  @override
  _ShopFilterState createState() => _ShopFilterState();
}

class _ShopFilterState extends FilterPageState<ShopFilterData, ShopFilter> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(restorationId: 'shop_list_filter', children: [
        getGroup(header: S.current.sort_order, children: [
          getSortButton<ShopSort>(
            prefix: null,
            value: filterData.sortType,
            items: {for (final e in ShopSort.values) e: e.name},
            onSortAttr: (key) {
              filterData.sortType = key ?? filterData.sortType;
              update();
            },
            reversed: filterData.reversed,
            onSortDirectional: (reversed) {
              filterData.reversed = reversed;
              update();
            },
          ),
        ]),
        FilterGroup<bool>(
          title: Text(S.current.opening_time),
          options: const [true, false],
          values: filterData.permanent,
          optionBuilder: (v) =>
              Text(v ? S.current.permanent : S.current.limited_time),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<PurchaseType>(
          title: Text(S.current.game_rewards),
          options: widget.purchaseTypes.isEmpty
              ? PurchaseType.values
              : (widget.purchaseTypes.toList()..sort2((e) => e.index)),
          values: filterData.purchaseType,
          optionBuilder: (v) =>
              Text(Transl.enums(v, (enums) => enums.purchaseType).l),
          onFilterChanged: (value, _) {
            update();
          },
        ),
      ]),
    );
  }
}
