import 'package:chaldea/components/custom_tile.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/components/components.dart';
//

class MyTextController<T> {
  T data;
  TextEditingController textEditingController;
  FocusNode focusNode;

  MyTextController(
      {@required this.data, this.textEditingController, this.focusNode})
      : assert(data != null);

  void dispose() {
    textEditingController?.dispose();
    focusNode?.dispose();
  }
}

class ItemPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage>
    with SingleTickerProviderStateMixin {
  List<String> categories = ['material', 'gem', 'piece', 'event'];

  //controller
  TabController _tabController;
  ScrollController _scrollController;
  Map<String, List<MyTextController<Item>>> inputControllers = {};
  TextEditingController _lastFocusedController;

  // to be moved
  Map<String, List<int>> allCost = {},
      planCost = {};
  bool filtered = false;

  void calculateItemCost() {
    db.gameData.items.forEach((itemName, _) {
      allCost[itemName] = [0, 0, 0];
      planCost[itemName] = [0, 0, 0];
    });
    db.gameData.servants.forEach((key, svt) {
      final plan = db.userData.servants[svt.no.toString()];
      if (plan == null) {
        return;
      }
      for (int i = plan.ascensionLv[0]; i < plan.ascensionLv[1]; i++) {
        for (var item in svt.itemCost.ascension[i]) {
          planCost[item.name][0] += item.num;
        }
      }
      for (int i = 0; i < 3; i++) {
        for (int j = plan.skillLv[i][0]; j < plan.skillLv[i][1]; j++) {
          for (var item in svt.itemCost.skill[j - 1]) {
            planCost[item.name][1] += item.num;
          }
        }
      }
      for (int i = 0; i < svt.itemCost.dress.length; i++) {
        if (plan.dressLv[i] == [0, 1]) {
          for (var item in svt.itemCost.dress[i]) {
            planCost[item.name][2] += item.num;
          }
        }
      }
    });
  }

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
    // TODO: implement deactivate
    super.deactivate();
    db.saveData(user: true);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _scrollController = ScrollController();
    final items = db.gameData.items;
    categories.forEach((e) {
      inputControllers[e] = [];
    });
    items.forEach((String key, Item item) {
      if (!categories.contains(item.category)) {
        return;
      }
      TextEditingController textEditingController = TextEditingController(
          text: db.userData.items[item.name]?.toString() ?? '0');
      FocusNode focusNode = FocusNode();
      textEditingController.addListener(() {
        int num = int.parse('0' + textEditingController.text);
        db.userData.items[item.name] = num;
        getFocused(textEditingController, focusNode);
      });
      inputControllers[item.category].add(MyTextController(
          data: item,
          textEditingController: textEditingController,
          focusNode: focusNode));
    });
    inputControllers.forEach((key, group) {
      group.sort((a, b) {
        return a.data.id - b.data.id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    calculateItemCost();
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
          children: categories.map((key) {
            final group = inputControllers[key];
            List<Widget> tiles = [];
            final len = group.length;
            for (int index = 0; index < len; index++) {
              final controller = group[index];
              String iconKey = controller.data.name;
              final r = [planCost[iconKey]?.fold(0, (p, c) => p + c) ?? 0]
                ..addAll(planCost[iconKey] ?? [0, 0, 0]);
              bool enough = r[0] <= (db.userData.items[iconKey] ?? 0);
              if (filtered && enough) {
                continue;
              }
              tiles.add(CustomTile(
                leading: Image.file(
                  db.getIconFile(iconKey),
                  height: 110 * 0.5,
                ),
                title: Text(iconKey),
                subtitle: Text(
                  '共需 ${r[0]}(${r[1]}/${r[2]}/${r[3]})',
                  style: enough ? null : TextStyle(color: Colors.redAccent),
                ),
                titlePadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                trailing: SizedBox(
                  width: 45,
                  child: EnsureVisibleWhenFocused(
                      child: TextField(
                        maxLength: 4,
                        controller: controller.textEditingController,
                        focusNode: controller.focusNode,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onTap: () {
                          getFocused(controller.textEditingController,
                              controller.focusNode,
                              isTap: true);
                        },
                        onSubmitted: (s) {
                          if (index + 1 == len) {
                            FocusScope.of(context).unfocus();
                          } else {
                            FocusScope.of(context)
                                .requestFocus(group[index + 1].focusNode);
                          }
                        },
                      ),
                      focusNode: controller.focusNode),
                ),
              ));
            }
            return ListView(
              controller: _scrollController,
              shrinkWrap: true,
              children: tiles,
            );
          }).toList()),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    inputControllers.forEach((key, group) {
      group.forEach((e) {
        e.dispose();
      });
    });
  }
}
