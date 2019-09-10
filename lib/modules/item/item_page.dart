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
    return Scaffold(
      appBar: AppBar(
        title: Text(S
            .of(context)
            .item_title),
        leading: BackButton(),
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
              tiles.add(CustomTile(
                leading: Image.file(
                  db.getIconFile(controller.data.name),
                  height: 110 * 0.5,
                ),
                title: Text(controller.data.name),
                subtitle: Text('库存数量:  '),
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
