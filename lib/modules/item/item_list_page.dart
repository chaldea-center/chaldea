import 'package:chaldea/components/custom_tile.dart';
import 'package:chaldea/components/tile_items.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/servant/servant_tabs.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/components/components.dart';
//

class InputComponent<T> {
  T data;
  TextEditingController textEditingController;
  FocusNode focusNode;

  InputComponent(
      {@required this.data, this.textEditingController, this.focusNode})
      : assert(data != null);

  void dispose() {
    textEditingController?.dispose();
    focusNode?.dispose();
  }
}

class TextInputsManager<T> {
  List<InputComponent<T>> components = [];

  // for focus switching
  List<FocusNode> _focusList = [];

  void addEntry({T datum, TextEditingController controller, FocusNode node}) {
    // whether they are all required?
    components.add(InputComponent(
        data: datum, textEditingController: controller, focusNode: node));
  }

  // focus part
  void addFocus(FocusNode node) {
    // could node of _focusList not in _focusNodes list?
    // if could, it's just two functionality
    _focusList.add(node);
  }

  void moveNextFocus(BuildContext context, FocusNode node) {
    final index = _focusList.indexOf(node);
    if (index < 0) {
      print('WARNING: focus node not in list!');
    } else if (index == _focusList.length - 1) {
      FocusScope.of(context).unfocus();
    } else {
      FocusScope.of(context).requestFocus(_focusList[index + 1]);
    }
  }

  void resetFocusList() {
    _focusList.clear();
  }

  void dispose() {
    components.forEach((e) => e.dispose());
  }
}

class ItemListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage>
    with SingleTickerProviderStateMixin {
  List<String> categories = ['material', 'gem', 'piece', 'event'];

  //controller
  TabController _tabController;
  Map<String, TextInputsManager<Item>> inputManagers = {};
  TextEditingController _lastFocusedController;
  ItemCostStatistics statistics;
  bool filtered = true;

  void getFocused(TextEditingController controller, FocusNode node,
      {bool isTap = false}) {
    if ((node.hasFocus || isTap) && _lastFocusedController != controller) {
      _lastFocusedController?.selection =
          TextSelection(baseOffset: 0, extentOffset: 0);
      controller.selection =
          TextSelection(baseOffset: 0, extentOffset: controller.text.length);
      _lastFocusedController = controller;
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    print('ItemListPage deactived.');
    db.saveData(user: true);
  }

  void update() {
    // for sub-page callback
    setState(() {
//      print('update item_list_page');
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    statistics = ItemCostStatistics(db.gameData, db.userData.servants);
    final items = db.gameData.items;
    categories.forEach((e) {
      inputManagers[e] = TextInputsManager();
    });
    items.forEach((String key, Item item) {
      if (!categories.contains(item.category)) {
        return;
      }
      TextEditingController textEditingController = TextEditingController(
          text: (db.userData.items[item.name] ?? 0).toString());
      FocusNode focusNode = FocusNode();
      textEditingController.addListener(() {
        int num = int.parse('0' + textEditingController.text);
        db.userData.items[item.name] = num;
        getFocused(textEditingController, focusNode);
      });
      inputManagers[item.category].addEntry(
          datum: item, controller: textEditingController, node: focusNode);
    });
    inputManagers.forEach((key, group) {
      group.components.sort((a, b) => a.data.id - b.data.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S
            .of(context)
            .item_title),
        leading: BackButton(),
        actions: <Widget>[
          IconButton(
            icon: Icon(
                filtered ? Icons.check_circle : Icons.check_circle_outline),
            onPressed: () {
              filtered = !filtered;
              setState(() {});
            },
          )
        ],
        bottom: TabBar(
            controller: _tabController,
            tabs: categories.map((category) => Tab(text: category)).toList()),
      ),
      body: TabBarView(
          controller: _tabController,
          children: categories.map((tabKey) {
//            final group = inputControllers[tabKey];
            final manager = inputManagers[tabKey];
            manager.resetFocusList();
            List<Widget> tiles = [];
            final len = manager.components.length;
            for (int index = 0; index < len; index++) {
              // for every item
              final component = manager.components[index];
              String iconKey = component.data.name;
              final itemStat = statistics.getNumOfItem(iconKey);
              final allNum = sum(itemStat.values);
              final ownNum = db.userData.items[iconKey] ?? 0;
              bool enough = allNum <= ownNum;

              if (filtered && enough) {
                continue;
              }
              manager.addFocus(component.focusNode);
              tiles.add(CustomTile(
                onTap: () {
                  SplitRoute.popAndPush(context,
                      builder: (context) =>
                          ItemDetailPage(iconKey,
                              statistics: statistics, updateParent: update),
                      settings: RouteSettings(isInitialRoute: false));
                },
                leading: Image.file(
                  db.getIconFile(iconKey),
                  height: 110 * 0.5,
                ),
                title: Text(iconKey),
                subtitle: Row(
                  children: <Widget>[
                    Expanded(
                        flex: 3,
                        child: Text(
                          '共需 $allNum(${itemStat.ascension}/${itemStat
                              .skill}/${itemStat.dress})',
                          style: TextStyle(
                              color: enough ? null : Colors.redAccent),
                        )),
                    Expanded(
                        flex: 2,
                        child: Text(
                          '剩余 ${ownNum - allNum}',
                          style: TextStyle(
                              color: enough ? null : Colors.redAccent),
                        ))
                  ],
                ),
                titlePadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                trailing: SizedBox(
                  width: 45,
                  child: EnsureVisibleWhenFocused(
                      child: TextField(
                        maxLength: 4,
                        controller: component.textEditingController,
                        focusNode: component.focusNode,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(counterText: ''),
                        onTap: () {
                          getFocused(component.textEditingController,
                              component.focusNode,
                              isTap: true);
                        },
                        onSubmitted: (s) {
                          manager.moveNextFocus(context, component.focusNode);
                        },
                      ),
                      focusNode: component.focusNode),
                ),
              ));
            }
            return ListView(
              shrinkWrap: true,
              children: [TileGroup(tiles: tiles)],
            );
          }).toList()),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    inputManagers.forEach((key, manager) {
      manager.dispose();
    });
  }
}
