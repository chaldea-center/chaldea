import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/timer/base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../runtime.dart';
import 'shop.dart';

class ShopEventListPage extends StatelessWidget {
  final FakerRuntime runtime;

  const ShopEventListPage({super.key, required this.runtime});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    children.add(
      ListTile(
        title: Text('Shop ID'),
        trailing: IconButton(
          onPressed: () {
            InputCancelOkDialog.number(
              title: 'Shop ID',
              validate: (v) => v > 0,
              onSubmit: (value) async {
                final shop = await showEasyLoading<NiceShop?>(() => AtlasApi.shop(value, region: runtime.region));
                if (shop == null) {
                  EasyLoading.showError('Shop $value not found');
                  return;
                }
                router.pushPage(UserShopsPage(runtime: runtime, title: S.current.shop, shops: [shop]));
              },
            ).showDialog(context);
          },
          icon: Icon(Icons.edit),
        ),
      ),
    );

    final now = DateTime.now().timestamp;

    final List<ShopType> _kShownShopTypes = [ShopType.mana, ShopType.rarePri, ShopType.revivalItem];
    children.addAll([for (final shopType in _kShownShopTypes) _buildShopType(context, shopType)]);

    final events = runtime.gameData.timerData.events.values
        .where((e) => e.shop.isNotEmpty && e.startedAt <= now && e.shopClosedAt > now)
        .toList();
    events.sort2((e) => -e.bannerPriority);
    children.addAll([for (final event in events) ?_buildEvent(context, event)]);

    return Scaffold(
      appBar: AppBar(title: Text(S.current.shop)),
      body: ListView.separated(
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, _) => const Divider(),
        itemCount: children.length,
      ),
    );
  }

  Widget _buildShopType(BuildContext context, ShopType shopType) {
    final now = DateTime.now().timestamp;
    List<NiceShop> recentShops = runtime.gameData.timerData.shops.values
        .where((shop) => shop.shopType == shopType && shop.openedAt <= now && shop.closedAt > now)
        .toList();

    void onTap(bool showFull) async {
      List<NiceShop>? _shops = recentShops;
      if (recentShops.isEmpty || showFull) {
        _shops = await showEasyLoading<List<NiceShop>?>(
          () => AtlasApi.searchShop(type: shopType, eventId: 0, region: runtime.region),
        );
      }
      if (_shops == null || _shops.isEmpty) {
        EasyLoading.showError(S.current.empty_hint);
        return;
      }
      router.pushPage(
        UserShopsPage(runtime: runtime, title: Transl.enums(shopType, (enums) => enums.shopType).l, shops: _shops),
      );
    }

    String? icon = switch (shopType) {
      ShopType.mana => Items.manaPrism?.icon,
      ShopType.rarePri => Items.rarePrism?.icon,
      ShopType.revivalItem => Items.revivalItem?.icon,
      _ => null,
    };

    return ListTile(
      dense: true,
      leading: icon == null ? null : db.getIconImage(icon, width: 24, height: 24),
      title: Text(Transl.enums(shopType, (enums) => enums.shopType).l),
      subtitle: recentShops.isEmpty
          ? null
          : CountDown(endedAt: _getShopClosedAt(recentShops).sec2date(), fitted: false),
      trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
      onTap: () => onTap(false),
      onLongPress: () => onTap(true),
    );
  }

  Widget? _buildEvent(BuildContext context, Event event) {
    final banner = event.extra.resolvedBanner.l;
    Widget? bannerWidget;
    if (banner != null) {
      bannerWidget = ConstrainedBox(constraints: BoxConstraints(maxWidth: 150), child: db.getIconImage(banner));
    }
    final shops = event.shop
        .where((shop) => shop.purchaseType != PurchaseType.lotteryShop && shop.scriptId == null)
        .toList();
    if (shops.isEmpty) return null;
    final groups = <int, List<NiceShop>>{};
    for (final shop in shops) {
      groups.putIfAbsent(shop.slot, () => []).add(shop);
    }
    if (groups.length == 1) {
      return ListTile(
        dense: true,
        title: Text(event.lName.l),
        subtitle: CountDown(
          endedAt: event.endedAt.sec2date(),
          endedAt2: _getShopClosedAt(shops, event.endedAt).sec2date(),
          fitted: false,
        ),
        trailing: bannerWidget,
        onTap: () {
          router.pushPage(
            UserShopsPage(runtime: runtime, title: event.lShortName.l.setMaxLines(1), shops: shops, event: event),
          );
        },
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ListTile(
            dense: true,
            title: Text(event.lName.l),
            subtitle: CountDown(endedAt: event.endedAt.sec2date()),
            trailing: bannerWidget,
          ),
          for (final slot in groups.keys.toList()..sort())
            ListTile(
              dense: true,
              leading: const SizedBox.shrink(),
              title: Text('Slot $slot'),
              subtitle: CountDown(endedAt: _getShopClosedAt(groups[slot]!).sec2date()),
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
      );
    }
  }

  int _getShopClosedAt(List<NiceShop> shops, [int eventEndedAt = 0]) {
    final shopClosedAt = Maths.min(shops.map((e) => e.closedAt));
    if (eventEndedAt == 0) return shopClosedAt;
    if (shopClosedAt > eventEndedAt + 60) return shopClosedAt;
    return eventEndedAt;
  }
}
