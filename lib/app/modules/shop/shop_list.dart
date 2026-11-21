import 'package:material_ui/material_ui.dart';

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
    ShopType.exRoomShop,
    ShopType.exRoomShopDaily,
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
  final ShopType? type;
  final int? groupId;
  final Region? region;

  const ShopListPage({super.key, required ShopType this.type, this.region}) : groupId = null;
  const ShopListPage.groupId({super.key, required int this.groupId, this.region}) : type = null;

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> with SearchableListState<NiceShop, ShopListPage> {
  bool _loading = false;
  final filterData = ShopFilterData();

  List<NiceShop> shops = [];
  @override
  Iterable<NiceShop> get wholeData => shops;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _loading = true;
    List<NiceShop>? _shops;
    if (widget.type != null) {
      _shops = await AtlasApi.searchShop(type: widget.type, eventId: 0, region: widget.region ?? Region.jp);
    } else if (widget.groupId != null) {
      _shops = await AtlasApi.searchShop(groupId: widget.groupId, region: widget.region ?? Region.jp);
    }
    if (_shops != null) shops = _shops;
    _loading = false;
    if (mounted) setState(() {});
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

    String title;
    if (widget.type != null) {
      title = Transl.enums(widget.type!, (enums) => enums.shopType).l;
    } else if (widget.groupId != null) {
      title = 'ShopGroup ${widget.groupId}';
    } else {
      title = 'Shop List';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
          : shops.isEmpty
          ? Center(child: Text('Not Found (${(widget.region ?? Region.jp).localName})'))
          : EventShopsPage(event: null, shops: shownList, showTime: true, region: widget.region),
    );
  }

  @override
  Iterable<String?> getSummary(NiceShop shop) sync* {
    Set<String> names = {shop.name};
    if (shop.purchaseType == PurchaseType.equip) {
      for (final targetId in shop.targetIds) {
        final equip = db.gameData.mysticCodes[targetId];
        if (equip != null) {
          names.add(equip.name);
          names.add(equip.lName.l);
        }
      }
    } else if (shop.purchaseType == PurchaseType.costumeRelease) {
      for (final targetId in shop.targetIds) {
        final costume = db.gameData.servantsById[targetId ~/ 100]?.costume.values.firstWhereOrNull(
          (e) => e.costumeCollectionNo == targetId % 100,
        );
        if (costume != null) {
          names.add(costume.name);
          names.add(costume.lName.l);
        }
      }
    } else {
      for (final targetId in shop.getItemAndCardIds()) {
        final lName =
            db.gameData.entities[targetId]?.lName ??
            db.gameData.commandCodesById[targetId]?.lName ??
            db.gameData.items[targetId]?.lName;
        if (lName != null) {
          names.add(lName.key);
          names.add(lName.l);
        }
      }
    }

    yield* names;
    yield shop.detail;
  }

  @override
  bool filter(NiceShop shop) {
    return filterData.filter(shop);
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
