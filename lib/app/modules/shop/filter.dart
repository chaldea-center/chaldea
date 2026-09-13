import 'package:material_ui/material_ui.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import '../../../../models/models.dart';

enum ShopSort { priority, openTime }

class ShopFilterData with FilterDataMixin {
  final permanent = FilterGroupData<bool>();
  final opening = FilterGroupData<int>();
  final type = FilterGroupData<ShopType>();
  final purchaseType = FilterGroupData<PurchaseType>();
  final svtType = FilterGroupData<SvtType>();
  final itemCategory = FilterGroupData<ItemCategory>();
  bool hasFreeCond = false;

  ShopSort sortType = ShopSort.openTime;
  bool reversed = false;

  @override
  List<FilterGroupData> get groups => [type, permanent, opening, purchaseType, svtType, itemCategory];

  @override
  void reset() {
    super.reset();
    hasFreeCond = false;
  }

  bool filter(NiceShop shop) {
    final filterData = this;
    if (!filterData.type.matchOne(shop.shopType)) {
      return false;
    }
    final now = DateTime.now().timestamp;
    int openStatus = shop.closedAt < now ? 0 : (shop.openedAt <= now ? 1 : 2);
    if (!filterData.opening.matchOne(openStatus)) {
      return false;
    }
    if (!filterData.permanent.matchOne(shop.closedAt > kNeverClosedTimestamp)) {
      return false;
    }
    if (filterData.hasFreeCond && !shop.hasFreeCond) {
      return false;
    }
    if (!filterData.purchaseType.matchAny([shop.purchaseType, ...shop.itemSet.map((e) => e.purchaseType)])) {
      return false;
    }
    if (filterData.svtType.isNotEmpty) {
      Set<int> svtIds = {};
      if (shop.purchaseType == PurchaseType.servant) {
        svtIds.addAll(shop.targetIds);
      }
      for (final setitem in shop.itemSet) {
        if (setitem.purchaseType == PurchaseType.servant) {
          svtIds.add(setitem.targetId);
        }
        for (final gift in setitem.gifts) {
          if (gift.type == GiftType.servant) {
            svtIds.add(gift.objectId);
          }
        }
      }
      if (!filterData.svtType.matchAny(svtIds.map((e) => db.gameData.entities[e]?.type).whereType())) {
        return false;
      }
    }
    if (filterData.itemCategory.isNotEmpty) {
      Set<int> itemIds = {};
      if (shop.purchaseType == PurchaseType.item) {
        itemIds.addAll(shop.targetIds);
      }
      for (final setitem in shop.itemSet) {
        if (setitem.purchaseType == PurchaseType.item) {
          itemIds.add(setitem.targetId);
        }
        for (final gift in setitem.gifts) {
          if (gift.type == GiftType.item) {
            itemIds.add(gift.objectId);
          }
        }
      }
      if (!filterData.itemCategory.matchAny(itemIds.map((e) => db.gameData.items[e]?.category).whereType())) {
        return false;
      }
    }
    return true;
  }
}

class ShopFilter extends FilterPage<ShopFilterData> {
  final List<PurchaseType> purchaseTypes;

  const ShopFilter({
    super.key,
    required super.filterData,
    super.onChanged,
    this.purchaseTypes = const [],
    super.extraFilters,
  });

  @override
  _ShopFilterState createState() => _ShopFilterState();
}

class _ShopFilterState extends FilterPageState<ShopFilterData, ShopFilter> {
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
        restorationId: 'shop_list_filter',
        children: [
          getGroup(
            header: S.current.sort_order,
            children: [
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
            ],
          ),
          ...?widget.extraFilters?.call(context, update),
          FilterGroup<bool>(
            title: Text(S.current.opening_time),
            options: const [true, false],
            values: filterData.permanent,
            optionBuilder: (v) => Text(v ? S.current.permanent : S.current.limited_time),
            onFilterChanged: (value, _) {
              update();
            },
          ),
          FilterGroup<int>(
            options: const [0, 1, 2],
            values: filterData.opening,
            optionBuilder: (v) => Text(["Closed", "Opening", "Future"].getOrNull(v) ?? v.toString()),
            onFilterChanged: (value, _) {
              update();
            },
          ),
          FilterGroup<bool>(
            options: const [true],
            values: FilterRadioData(filterData.hasFreeCond),
            optionBuilder: (v) => Text(v ? S.current.shop_free_condition : v.toString()),
            onFilterChanged: (value, _) {
              filterData.hasFreeCond = value.radioValue == true;
              update();
            },
          ),
          FilterGroup<PurchaseType>(
            title: Text(S.current.game_rewards),
            options: widget.purchaseTypes.isEmpty
                ? PurchaseType.values
                : (widget.purchaseTypes.toList()..sort2((e) => e.index)),
            values: filterData.purchaseType,
            optionBuilder: (v) => Text(Transl.enums(v, (enums) => enums.purchaseType).l),
            onFilterChanged: (value, _) {
              update();
            },
          ),
          FilterGroup<ItemCategory>(
            title: const Text('Item Category'),
            options: ItemCategory.values,
            values: filterData.itemCategory,
            optionBuilder: (v) => Text(Transl.enums(v, (enums) => enums.itemCategory).l),
            onFilterChanged: (value, _) {
              update();
            },
          ),
          FilterGroup<SvtType>(
            enabled: filterData.purchaseType.contain(PurchaseType.servant),
            title: const Text('Card Type'),
            options: const [
              SvtType.normal,
              SvtType.svtMaterialTd,
              SvtType.servantEquip,
              SvtType.combineMaterial,
              SvtType.statusUp,
            ],
            values: filterData.svtType,
            optionBuilder: (v) => Text(Transl.enums(v, (enums) => enums.svtType).l),
            onFilterChanged: (value, _) {
              update();
            },
          ),
        ],
      ),
    );
  }
}
