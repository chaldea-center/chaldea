import 'package:chaldea/app/modules/event/detail/shop.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'base.dart';

class TimerShopTab extends StatelessWidget {
  final Region region;
  final List<NiceShop> shops;
  final TimerFilterData filterData;
  const TimerShopTab({super.key, required this.region, required this.shops, required this.filterData});

  @override
  Widget build(BuildContext context) {
    final groups = filterData.getSorted(TimerShopItem.group(shops, region));
    return ListView(children: [for (final group in groups) group.buildItem(context, expanded: true)]);
  }
}

class TimerShopItem with TimerItem {
  final List<NiceShop> shops;
  final Region region;
  TimerShopItem(this.shops, this.region);

  static List<TimerShopItem> group(List<NiceShop> shops, Region region) {
    final now = DateTime.now().timestamp;
    Map<String, List<NiceShop>> groups = {};
    shops = shops.toList();
    shops.sortByList((e) => [e.closedAt > now ? -1 : 1, (e.closedAt - now).abs(), e.priority]);
    for (final shop in shops) {
      groups.putIfAbsent([shop.openedAt, shop.closedAt, shop.payType.name].join('-'), () => []).add(shop);
    }
    return groups.values.map((e) => TimerShopItem(e, region)).toList();
  }

  @override
  int get startedAt => shops.first.openedAt;
  @override
  int get endedAt => shops.first.closedAt;

  @override
  Widget buildItem(BuildContext context, {bool expanded = false}) {
    final shop = shops.first;
    return SimpleAccordion(
      expanded: expanded,
      headerBuilder: (context, _) {
        final now = DateTime.now().timestamp;
        Item? payItem = switch (shop.payType) {
          PayType.mana => Items.manaPrism,
          PayType.rarePri => Items.rarePrism,
          _ => null,
        };
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
          minLeadingWidth: 24,
          horizontalTitleGap: 8,
          leading: payItem == null
              ? null
              : Item.iconBuilder(context: context, item: payItem, icon: payItem.icon, width: 20),
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: [fmtDate(shop.openedAt), fmtDate(shop.closedAt)].join(" ~ ")),
              ],
            ),
          ),
          trailing: CountDown(
            endedAt: shop.closedAt.sec2date(),
            startedAt: shop.openedAt.sec2date(),
            textAlign: TextAlign.end,
          ),
          enabled: shop.closedAt > now,
        );
      },
      contentBuilder: (context) {
        return Card(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [for (final shop in shops) ShopDescriptor(shop: shop, showTime: false, region: region)],
          ),
        );
      },
    );
  }
}
