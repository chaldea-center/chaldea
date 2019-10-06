import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/custom_tile.dart';
import 'package:chaldea/components/tile_items.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:flutter/material.dart';

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
  State<StatefulWidget> createState() => ItemListPageState();
}

class ItemListPageState extends State<ItemListPage>
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
    db.saveData();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    statistics = ItemCostStatistics(db.gameData, db.curPlan.servants);
    final items = db.gameData.items;
    categories.forEach((e) {
      inputManagers[e] = TextInputsManager();
    });
    items.forEach((String key, Item item) {
      if (!categories.contains(item.category)) {
        return;
      }
      TextEditingController textEditingController = TextEditingController(
          text: (db.curPlan.items[item.name] ?? 0).toString());
      FocusNode focusNode = FocusNode();
      textEditingController.addListener(() {
        int num = int.parse('0' + textEditingController.text);
        db.curPlan.items[item.name] = num;
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
        title: Text(S.of(context).item_title),
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
              final ownNum = db.curPlan.items[iconKey] ?? 0;
              int leftNum = ownNum - allNum;
              bool enough = leftNum >= 0;

              if (filtered && enough) {
                continue;
              }
              final highlightStyle =
                  TextStyle(color: enough ? null : Colors.redAccent);
              manager.addFocus(component.focusNode);
              tiles.add(CustomTile(
                onTap: () {
                  SplitRoute.popAndPush(context,
                      builder: (context) => ItemDetailPage(
                            iconKey,
                            statistics: statistics,
                            parent: this,
                          ),
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
                          '共需 $allNum(${itemStat.ascension}/${itemStat.skill}/${itemStat.dress})',
                          style: highlightStyle,
                        )),
                    Text(
                      '剩余 ',
                      style: highlightStyle,
                    ),
                    SizedBox(
                        width: 37,
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(leftNum.toString(),
                                style: highlightStyle)))
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
