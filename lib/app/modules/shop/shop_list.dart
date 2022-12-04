import 'package:flutter/material.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import '../../../widgets/searchable_list_state.dart';
import '../common/filter_page_base.dart';
import '../event/detail/shop.dart';
import 'filter.dart';

class ShopListHome extends StatefulWidget {
  const ShopListHome({super.key});

  @override
  State<ShopListHome> createState() => _ShopListHomeState();
}

class _ShopListHomeState extends State<ShopListHome> {
  late Region region = db.curUser.region;
  List<ShopType> get _kShownShopTypes => [
        ShopType.mana,
        ShopType.rarePri,
        ShopType.shop13,
        ShopType.svtCostume,
        ShopType.startUpSummon,
        ShopType.svtAnonymous,
        ShopType.limitMaterial,
        ShopType.bgm,
        ShopType.svtStorage,
        ShopType.svtEquipStorage,
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.shop),
        actions: [
          SharedBuilder.appBarRegionDropdown(
            context: context,
            region: region,
            onChanged: (v) {
              setState(() {
                if (v != null) region = v;
              });
            },
          )
        ],
      ),
      body: ListView(
        children: [
          for (final type in _kShownShopTypes)
            ListTile(
              title: Text(Transl.enums(type, (enums) => enums.shopType).l),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {
                router.push(
                  url: Routes.shops(type),
                  child: ShopListPage(type: type, region: region),
                );
              },
            ),
        ],
      ),
    );
  }
}

class ShopListPage extends StatefulWidget {
  final ShopType type;
  final Region region;

  const ShopListPage({super.key, required this.type, this.region = Region.jp});

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage>
    with SearchableListState<NiceShop, ShopListPage> {
  bool _loading = true;
  final filterData = ShopFilterData();

  List<NiceShop> shops = [];
  @override
  Iterable<NiceShop> get wholeData => shops;

  @override
  void initState() {
    super.initState();
    AtlasApi.searchShop(type: widget.type, eventId: 0, region: widget.region)
        .then((value) {
      if (value != null) shops = value;
      _loading = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: (a, b) {
      final aa = filterData.reversed ? b : a, bb = filterData.reversed ? a : b;
      return ListX.compareByList<NiceShop, int>(aa, bb, (e) {
        switch (filterData.sortType) {
          case ShopSort.priority:
            return [e.priority, -e.openedAt];
          case ShopSort.openTime:
            return [-e.openedAt, e.priority];
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(Transl.enums(widget.type, (enums) => enums.shopType).l),
        bottom: showSearchBar ? searchBar : null,
        actions: [
          searchIcon,
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () {
              final purchaseTypes = <PurchaseType>{
                for (final shop in shops) ...[
                  shop.purchaseType,
                  ...shop.itemSet.map((e) => e.purchaseType)
                ]
              };
              FilterPage.show(
                context: context,
                builder: (context) => ShopFilter(
                  filterData: filterData,
                  onChanged: (_) {
                    if (mounted) setState(() {});
                  },
                  purchaseTypes: purchaseTypes.toList(),
                ),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : EventShopsPage(event: null, shops: shownList, showTime: true),
    );
  }

  @override
  Iterable<String?> getSummary(NiceShop shop) sync* {
    yield shop.name;
    yield shop.detail;
  }

  @override
  bool filter(NiceShop shop) {
    if (!filterData.type.matchOne(shop.shopType)) {
      return false;
    }
    if (!filterData.permanent.matchOne(shop.closedAt > kNeverClosedTimestamp)) {
      return false;
    }
    if (!filterData.purchaseType.matchAny(
        [shop.purchaseType, ...shop.itemSet.map((e) => e.purchaseType)])) {
      return false;
    }
    return true;
  }

  @override
  Widget gridItemBuilder(NiceShop shop) {
    throw UnimplementedError();
  }

  @override
  Widget listItemBuilder(NiceShop shop) {
    throw UnimplementedError();
  }
}
