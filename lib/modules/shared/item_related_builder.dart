import 'package:chaldea/components/components.dart';

class CommonBuilder {
  /// build a grid view with [ImageWithText] as its children.
  /// The key and value of [data] are Servant/Item icon name and its' num or text
  /// for image and text in [ImageWithText].
  static Widget buildIconGridView(
      {Map<String, dynamic> data,
      int crossCount = 7,
      void onTap(String key),
      double childAspectRatio = 132 / 144,
      bool scrollable = false}) {
    return GridView.count(
      childAspectRatio: childAspectRatio,
      crossAxisCount: crossCount,
      shrinkWrap: true,
      physics: scrollable ? null : NeverScrollableScrollPhysics(),
      children: data.entries
          .map((entry) => Padding(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 1),
                child: ImageWithText(
                  onTap: onTap == null ? null : () => onTap(entry.key),
                  image: Image(image: db.getIconImage(entry.key)),
                  text: entry.key == Item.qp && entry.value is int
                      ? formatNumber(entry.value, compact: true)
                      : entry.value.toString(),
                  padding: EdgeInsets.symmetric(horizontal: 3),
                ),
              ))
          .toList(),
    );
  }
}

Widget buildClassifiedItemList({
  @required Map<String, int> data,
  void onTap(String iconKey),
  bool divideCategory = true,
  bool divideRarity = true,
  int crossCount = 7,
}) {
  final divided = divideItemsToGroups(data.keys.toList(),
      divideCategory: divideCategory, divideRarity: divideRarity);
  List<Widget> children = [];
  for (var key in divided.keys) {
    children.add(TileGroup(
      header: Item.getNameOfCategory(key ~/ 10, key % 10),
      padding: EdgeInsets.only(bottom: 0),
      children: <Widget>[
        GridView.count(
          padding: EdgeInsets.only(left: 10, top: 3, bottom: 3),
          childAspectRatio: 132 / 144,
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: divided[key]
              .map((item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 1),
                    child: ImageWithText(
                      onTap: onTap == null ? null : () => onTap(item.name),
                      image: Image(image: db.getIconImage(item.name)),
                      text: formatNumber(data[item.name]),
                      padding: EdgeInsets.only(right: 3),
                    ),
                  ))
              .toList(),
        )
      ],
    ));
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );
}

/// Divide list of items into groups according to [category] and/or [rarity].
/// If [divideRarity] is set to false, only divide into [category] groups.
/// The key of returned Map is [category] if [divideRarity], else [category]*10+[rarity]
Map<int, List<Item>> divideItemsToGroups(List<String> items,
    {bool divideCategory = true, bool divideRarity = true}) {
  Map<int, List<Item>> groups = {};
  for (String itemKey in items) {
    final item = db.gameData.items[itemKey];
    if (item != null) {
      final groupKey = (divideCategory ? item.category * 10 : 0) + (divideRarity ? item.rarity : 0);
      groups[groupKey] ??= [];
      groups[groupKey].add(item);
    }
  }
  final sortedKeys = groups.keys.toList()..sort();
  return Map.fromEntries(sortedKeys.map((key) {
    return MapEntry(key, groups[key]..sort((a, b) => a.id - b.id));
  }));
}
