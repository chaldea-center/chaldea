import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:flutter/services.dart';

class ItemListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ItemListPageState();
}

class ItemListPageState extends State<ItemListPage>
    with SingleTickerProviderStateMixin {
  List<int> categories = [1, 2, 3, 4];

  //controller
  TabController _tabController;
  Map<int, TextInputsManager<Item>> inputManagers = {};
  InputComponent _lastComponent;
  ItemCostStatistics statistics;
  bool filtered = true;

  @override
  void deactivate() {
    super.deactivate();
    db.saveData();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    statistics = ItemCostStatistics(db.gameData, db.curPlan.servants);
    final items = db.gameData.items;
    InputComponent<Item> generateComponent(String k) {
      TextEditingController textEditingController =
          TextEditingController(text: (db.curPlan.items[k] ?? 0).toString());
      FocusNode focusNode = FocusNode();
      InputComponent<Item> component = InputComponent(
          data: items[k],
          controller: textEditingController,
          focusNode: focusNode);
      return component;
    }

    categories.forEach((e) {
      inputManagers[e] = TextInputsManager();
      final qpKey = 'QP';
      inputManagers[e].components.add(generateComponent(qpKey));
    });
    items.forEach((String key, Item item) {
      if (!categories.contains(item.category)) {
        return;
      }
      inputManagers[item.category].components.add(generateComponent(item.name));
    });
    inputManagers.forEach((key, group) {
      group.components.sort((a, b) => a.data.id - b.data.id);
      group.components.insert(0, group.components.removeLast());
    });
  }

  Widget getItemRow(
      {bool filtered,
      TextInputsManager<Item> manager,
      InputComponent<Item> component,
      int ownNum,
      PartSet<int> itemStat}) {
    final iconKey = component.data.name;
    final allNum = sum(itemStat.values);
    int leftNum = ownNum - allNum;
    bool enough = leftNum >= 0;
    final highlightStyle = TextStyle(color: enough ? null : Colors.redAccent);

    if (filtered && enough) {
      return null;
    }
    manager.addObserver(component);
    return CustomTile(
      onTap: () => SplitRoute.popAndPush(context,
          builder: (context) => ItemDetailPage(
                iconKey,
                statistics: statistics,
                parent: this,
              )),
      leading: Image.file(db.getIconFile(iconKey), height: 110 * 0.5),
      title: Text(iconKey),
      subtitle: Row(
        children: <Widget>[
          Expanded(
              flex: 3,
              child: Text(
                '共需 ${formatNumToString(allNum, "decimal")}' +
                    (iconKey == 'QP' ? '' : '(${itemStat.values.join("/")})'),
                style: highlightStyle,
              )),
          Text('剩余 ', style: highlightStyle),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 37),
            child: Align(
                alignment: Alignment.centerRight,
                child: Text(formatNumToString(leftNum, 'decimal'),
                    style: highlightStyle)),
          )
        ],
      ),
      titlePadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      trailing: SizedBox(
        width: 45,
        child: EnsureVisibleWhenFocused(
            child: TextField(
              maxLength: 4,
              controller: component.controller,
              focusNode: component.focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(counterText: ''),
              inputFormatters: [WhitelistingTextInputFormatter(RegExp(r'\d'))],
              onChanged: (v) {
                db.curPlan.items[component.data.name] = int.tryParse(v) ?? 0;
              },
              onTap: () {
                component.selectAll();
              },
              onSubmitted: (s) {
                manager.moveNextFocus(context, component);
              },
            ),
            focusNode: component.focusNode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).item_title),
        leading: SplitViewBackButton(),
        actions: <Widget>[
          IconButton(
            icon: Icon(
                filtered ? Icons.check_circle : Icons.check_circle_outline),
            onPressed: () {
              setState(() {
                filtered = !filtered;
              });
            },
          )
        ],
        bottom: TabBar(
            controller: _tabController,
            tabs: categories
                .map((category) => Tab(
                    text: ['x', 'Material', 'Gem', 'Piece', 'Event'][category]))
                .toList()),
      ),
      body: TabBarView(
          controller: _tabController,
          children: categories.map((tabKey) {
            final manager = inputManagers[tabKey];
            manager.resetFocusList();
            List<Widget> tiles = [];
            final len = manager.components.length;
            for (int index = 0; index < len; index++) {
              // for every item
              final component = manager.components[index];
              String iconKey = component.data.name;
              final itemStat = statistics.getNumOfItem(iconKey);
              final ownNum = db.curPlan.items[iconKey] ?? 0;
              Widget tile = getItemRow(
                  filtered: filtered,
                  manager: manager,
                  ownNum: ownNum,
                  itemStat: itemStat,
                  component: component);
              if (tile != null) {
                tiles.add(tile);
              }
            }
            return ListView(
              children: [TileGroup(tiles: tiles)],
            );
          }).toList()),
    );
  }

  @override
  void dispose() {
    super.dispose();
    inputManagers.forEach((key, manager) {
      manager.dispose();
    });
  }
}
