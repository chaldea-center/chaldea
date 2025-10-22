import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import '../state.dart';
import 'shop.dart';

class ShopEventListPage extends StatelessWidget {
  final FakerRuntime runtime;

  const ShopEventListPage({super.key, required this.runtime});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().timestamp;
    final List<ShopType> _kShownShopTypes = [ShopType.mana, ShopType.rarePri, ShopType.revivalItem];
    List<Widget> children = [
      for (final shopType in _kShownShopTypes)
        ListTile(
          dense: true,
          title: Text(Transl.enums(shopType, (enums) => enums.shopType).l),
          trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          onTap: () async {
            List<NiceShop>? shops = runtime.gameData.timerData.shops.values
                .where((shop) => shop.shopType == shopType && shop.openedAt <= now && shop.closedAt > now)
                .toList();
            if (shopType == ShopType.revivalItem) {
              shops = await showEasyLoading<List<NiceShop>?>(
                () => AtlasApi.searchShop(type: shopType, eventId: 0, region: runtime.region),
              );
            }
            if (shops == null || shops.isEmpty) {
              EasyLoading.showError(S.current.empty_hint);
              return;
            }
            router.pushPage(
              UserShopsPage(runtime: runtime, title: Transl.enums(shopType, (enums) => enums.shopType).l, shops: shops),
            );
          },
        ),
    ];

    final events = runtime.gameData.timerData.events.values
        .where((e) => e.shop.isNotEmpty && e.startedAt <= now && e.shopClosedAt > now)
        .toList();
    events.sort2((e) => -e.bannerPriority);

    for (final event in events) {
      final banner = event.extra.resolvedBanner.l;
      Widget? bannerWidget;
      if (banner != null) {
        bannerWidget = ConstrainedBox(constraints: BoxConstraints(maxWidth: 150), child: db.getIconImage(banner));
      }
      final shops = event.shop
          .where((shop) => shop.purchaseType != PurchaseType.lotteryShop && shop.scriptId == null)
          .toList();
      if (shops.isEmpty) continue;
      final groups = <int, List<NiceShop>>{};
      for (final shop in shops) {
        groups.putIfAbsent(shop.slot, () => []).add(shop);
      }
      if (groups.length == 1) {
        children.add(
          ListTile(
            dense: true,
            title: Text(event.lName.l),
            trailing: bannerWidget,
            onTap: () {
              router.pushPage(
                UserShopsPage(runtime: runtime, title: event.lShortName.l.setMaxLines(1), shops: shops, event: event),
              );
            },
          ),
        );
      } else {
        children.add(
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ListTile(dense: true, title: Text(event.lName.l), trailing: bannerWidget),
              for (final slot in groups.keys.toList()..sort())
                ListTile(
                  dense: true,
                  leading: const SizedBox.shrink(),
                  title: Text('Slot $slot'),
                  trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                  onTap: () {
                    router.pushPage(
                      UserShopsPage(
                        runtime: runtime,
                        title: event.lShortName.l.setMaxLines(1),
                        shops: groups[slot]!,
                        event: event,
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(S.current.shop)),
      body: ListView.separated(
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, _) => Divider(),
        itemCount: children.length,
      ),
    );
  }
}
