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
  final List<ShopType> _kShownShopTypes = [
    ShopType.mana,
    ShopType.rarePri,
    ShopType.revivalItem,
    ShopType.purePri,
    ShopType.svtCostume,
    ShopType.eventSvtEquip,
    ShopType.startUpSummon,
    ShopType.svtAnonymous,
    ShopType.limitMaterial,
    ShopType.bgm,
    ShopType.svtStorage,
    ShopType.svtEquipStorage,
    ShopType.exchangeSvtCoin,
  ];

  late final textEditController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textEditController.dispose();
  }

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
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _custom(),
          for (final type in _kShownShopTypes)
            ListTile(
              title: Text(Transl.enums(type, (enums) => enums.shopType).l),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {
                router.push(url: Routes.shops(type), child: ShopListPage(type: type, region: region));
              },
            ),
        ],
      ),
    );
  }

  Widget _custom() {
    int? id = int.tryParse(textEditController.text.trim());
    return ListTile(
      dense: true,
      title: TextFormField(
        decoration: InputDecoration(
          isDense: true,
          labelText: '${S.current.shop} ID',
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        controller: textEditController,
        onChanged: (value) {
          setState(() {});
        },
        onFieldSubmitted: (s) => goTo(int.tryParse(s)),
      ),
      trailing: IconButton(
        onPressed: id == null ? null : () => goTo(id),
        icon: const Icon(Icons.keyboard_double_arrow_right),
        tooltip: 'GO!',
      ),
    );
  }

  void goTo(int? id) {
    if (id == null) return;
    router.push(url: Routes.shopI(id), region: region);
  }
}

class ShopListPage extends StatefulWidget {
  final ShopType type;
  final Region? region;

  const ShopListPage({super.key, required this.type, this.region});

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> with SearchableListState<NiceShop, ShopListPage> {
  bool _loading = true;
  final filterData = ShopFilterData();

  List<NiceShop> shops = [];
  @override
  Iterable<NiceShop> get wholeData => shops;

  @override
  void initState() {
    super.initState();
    AtlasApi.searchShop(type: widget.type, eventId: 0, region: widget.region ?? Region.jp).then((value) {
      if (value != null) shops = value;
      _loading = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(
      compare: (a, b) {
        final aa = filterData.reversed ? b : a, bb = filterData.reversed ? a : b;
        return ListX.compareByList<NiceShop, int>(aa, bb, (e) {
          switch (filterData.sortType) {
            case ShopSort.priority:
              return [e.priority, -e.openedAt];
            case ShopSort.openTime:
              return [-e.openedAt, e.priority];
          }
        });
      },
    );

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
                for (final shop in shops) ...[shop.purchaseType, ...shop.itemSet.map((e) => e.purchaseType)],
              };
              FilterPage.show(
                context: context,
                builder:
                    (context) => ShopFilter(
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
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : shops.isEmpty
              ? Center(child: Text('Not Found (${(widget.region ?? Region.jp).localName})'))
              : EventShopsPage(event: null, shops: shownList, showTime: true, region: widget.region),
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
