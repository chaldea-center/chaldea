import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class ItemSelectPage extends StatelessWidget {
  final bool includeSpecial;
  final ValueChanged<int> onSelected;
  final List<int> disabledItems;

  const ItemSelectPage({
    super.key,
    this.includeSpecial = false,
    required this.onSelected,
    this.disabledItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    Map<int, List<Item>> groupedItems = {};
    for (final item in db.gameData.items.values) {
      final key = item.category.index * 10 + item.background.index;
      groupedItems.putIfAbsent(key, () => []).add(item);
    }
    int normal = ItemCategory.normal.index,
        gem = ItemCategory.skill.index,
        ascension = ItemCategory.ascension.index;
    int bronze = ItemBGType.bronze.index,
        silver = ItemBGType.silver.index,
        gold = ItemBGType.gold.index;
    Map<int, String?> titles = {
      0: S.current.item_category_special,
      normal * 10 + bronze: S.current.item_category_bronze,
      normal * 10 + silver: S.current.item_category_silver,
      normal * 10 + gold: S.current.item_category_gold,
      gem * 10 + bronze: null, // S.current.item_category_gem,
      gem * 10 + silver: null, // S.current.item_category_magic_gem,
      gem * 10 + gold: null, // S.current.item_category_secret_gem,
      ascension * 10 + silver: null, // S.current.item_category_piece,
      ascension * 10 + gold: null, // S.current.item_category_monument,
    };
    List<Widget> children = [];
    for (int key in titles.keys) {
      if (key == 0) {
        if (!includeSpecial) continue;
        children.add(TileGroup(
          header: titles[key],
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 2,
                runSpacing: 2,
                children: [
                  _oneItem(context, Items.bondPointId, Items.lantern?.icon,
                      S.current.bond),
                  _oneItem(context, Items.expPointId, '', 'EXP'),
                ],
              ),
            )
          ],
        ));
      } else {
        final items = groupedItems[key];
        if (items == null || items.isEmpty) continue;
        items.sort2((e) => e.priority);
        children.add(TileGroup(
          header: titles[key],
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: GridView.extent(
                maxCrossAxisExtent: 50,
                childAspectRatio: 132 / 144,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  for (final item in items)
                    _oneItem(context, item.id, item.borderedIcon, item.lName.l)
                ],
              ),
            )
          ],
        ));
      }
    }
    return Scaffold(
      appBar: AppBar(title: Text(S.current.select_item_title)),
      body: ScrollRestoration(
        restorationId: 'item_select_page',
        builder: (context, controller) =>
            ListView(controller: controller, children: children),
      ),
    );
  }

  Widget _oneItem(BuildContext context, int id, String? icon, String name) {
    Widget child = Item.iconBuilder(
      context: context,
      item: null,
      icon: icon,
      width: 48,
      onTap: () {
        onSelected(id);
        Navigator.pop(context);
      },
    );
    if (disabledItems.contains(id)) {
      child = Opacity(
        opacity: 0.3,
        child: AbsorbPointer(child: child),
      );
    }
    return child;
  }
}
