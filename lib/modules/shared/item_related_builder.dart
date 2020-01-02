import 'package:chaldea/components/components.dart';

Widget buildClassifiedItemList(Map<String, int> data,
    {void onTap(String iconKey)}) {
  final divided = divideItemsToGroups(data.keys.toList(), rarity: true);
  List<Widget> children = [];
  for (var key in divided.keys) {
    children.add(TileGroup(
      header: getNameOfCategory(key ~/ 10, key % 10),
      padding: EdgeInsets.only(bottom: 0),
      children: <Widget>[
        GridView.count(
          padding: EdgeInsets.only(left: 10, top: 3, bottom: 3),
          childAspectRatio: 132 / 144,
          crossAxisCount: 6,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: divided[key]
              .map((item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 1),
                    child: ImageWithText(
                      onTap: onTap == null ? null : () => onTap(item.name),
                      image: Image(image: db.getIconImage(item.name)),
                      text: formatNumToString(data[item.name], 'kilo'),
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

Map<int, List<Item>> divideItemsToGroups(List<String> items,
    {bool category = true, bool rarity = false}) {
  Map<int, List<Item>> groups = {};
  for (String itemKey in items) {
    final item = db.gameData.items[itemKey];
    if (item != null) {
      final groupKey =
          (category ? item.category * 10 : 0) + (rarity ? item.rarity : 0);
      groups[groupKey] ??= [];
      groups[groupKey].add(item);
    }
  }
  final sortedKeys = groups.keys.toList()..sort();
  return Map.fromEntries(sortedKeys.map((key) {
    return MapEntry(key, groups[key]..sort((a, b) => a.id - b.id));
  }));
}

String getNameOfCategory(int category, int rarity) {
  switch (category) {
    case 1:
      return ['素材', '铜素材', '银素材', '金素材', '稀有'][rarity];
    case 2:
      return ['技能石', '辉石', '魔石', '秘石'][rarity];
    case 3:
      return ['职阶棋子', 'Unknown', '银棋', '金像'][rarity];
    case 4:
      return '活动从者灵基再临素材';
    default:
      return '其他';
  }
}
