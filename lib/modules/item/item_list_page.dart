import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/drop_calculator/drop_calculator_page.dart';
import 'package:flutter/services.dart';

import 'item_detail_page.dart';

class ItemListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ItemListPageState();
}

class ItemListPageState extends State<ItemListPage>
    with SingleTickerProviderStateMixin, DefaultScrollBarMixin {
  TabController _tabController;
  bool filtered = false;
  final List<int> categories = [1, 2, 3];
  List<TextEditingController> _itemRedundantControllers;

  @override
  void deactivate() {
    super.deactivate();
    db.saveUserData();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _itemRedundantControllers = List.generate(
        3,
        (index) => TextEditingController(
            text: db.userData.itemAbundantValue[index].toString()));
    db.itemStat.update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).item_title),
        leading: SplitMasterBackButton(),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: Text('选择规划'),
                    children:
                        List.generate(db.curUser.servantPlans.length, (index) {
                      return ListTile(
                        title: Text('规划 ${index + 1}'),
                        selected: index == db.curUser.curSvtPlanNo,
                        onTap: () {
                          Navigator.of(context).pop();
                          db.curUser.curSvtPlanNo = index;
                          db.itemStat.update();
                          setState(() {});
                        },
                      );
                    }),
                  ),
                );
              }),
          IconButton(
            icon: Icon(
                filtered ? Icons.check_circle : Icons.check_circle_outline),
            onPressed: () {
              setState(() {
                filtered = !filtered;
              });
            },
          ),
          IconButton(
              icon: Icon(Icons.calculate),
              onPressed: () {
                SimpleCancelOkDialog(
                  title: Text('材料富余量'),
                  content: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(
                        3,
                        (index) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('铜银金'[index]),
                                SizedBox(
                                  width: 40,
                                  child: TextField(
                                    controller:
                                        _itemRedundantControllers[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(isDense: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    onChanged: (s) {
                                      db.userData.itemAbundantValue[index] =
                                          int.tryParse(s) ?? 0;
                                    },
                                  ),
                                )
                              ],
                            )),
                  ),
                  onTapOk: () {
                    Map<String, int> objective = {};
                    db.itemStat.leftItems.forEach((itemKey, value) {
                      final rarity = db.gameData.items[itemKey]?.rarity ?? -1;
                      if (rarity > 0 && rarity <= 3) {
                        value -= db.userData.itemAbundantValue[rarity - 1];
                      }
                      if (db.gameData.glpk.rowNames.contains(itemKey) &&
                          value < 0) {
                        objective[itemKey] = -value;
                      }
                    });
                    SplitRoute.push(
                      context: context,
                      builder: (context, _) =>
                          DropCalculatorPage(objectiveMap: objective),
                    );
                  },
                ).show(context);
              })
        ],
        bottom: TabBar(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          tabs: categories
              .map(
                  (category) => Tab(text: ['x', '普通素材', '技能石', '棋子'][category]))
              .toList(),
          onTap: (_) {
            FocusScope.of(context).unfocus();
          },
        ),
      ),
      body: TabBarView(
        // mostly, we focus on category 1 tab
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: List.generate(
          categories.length,
          (index) =>
              ItemListTab(category: categories[index], filtered: filtered),
        ),
      ),
    );
  }
}

class InputComponents<T> {
  T data;
  FocusNode focusNode;
  TextEditingController controller;

  InputComponents({this.data, this.focusNode, this.controller});

  void dispose() {
    focusNode?.dispose();
    controller?.dispose();
  }
}

class ItemListTab extends StatefulWidget {
  final int category;
  final bool filtered;

  const ItemListTab({Key key, this.category, this.filtered = false})
      : super(key: key);

  @override
  _ItemListTabState createState() => _ItemListTabState();
}

class _ItemListTabState extends State<ItemListTab> with DefaultScrollBarMixin {
  // TextInputsManager<Item> inputsManager = TextInputsManager();
  final qpKey = 'QP';

  Map<Item, InputComponents<Item>> _allGroups = {};
  List<InputComponents<Item>> _shownGroups = [];
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    db.gameData.items.forEach((key, item) {
      if (item.category == widget.category && key != qpKey) {
        _allGroups[item] = InputComponents(
          data: item,
          focusNode: FocusNode(),
          controller: TextEditingController(
            text: formatNumber(db.curUser.items[key] ?? 0,
                groupSeparator: key == Item.qp ? ',' : null),
          ),
        );
      }
    });
    // sort by item id
    final sortedEntries = _allGroups.entries.toList()
      ..sort((a, b) => a.key.id - b.key.id);
    // always show QP at top
    sortedEntries.insert(
        0,
        MapEntry(
          db.gameData.items[qpKey],
          InputComponents(
              data: db.gameData.items[qpKey],
              focusNode: FocusNode(),
              controller: TextEditingController(
                  text: formatNumber(db.curUser.items[qpKey] ?? 0))),
        ));
    _allGroups = Map.fromEntries(sortedEntries);
  }

  @override
  void dispose() {
    _allGroups.values.forEach((element) => element?.dispose());
    _scrollController?.dispose();
    super.dispose();
  }

  void unfocusAll() {
    _allGroups.values.forEach((element) => element.focusNode?.unfocus());
  }

  @override
  void deactivate() {
    unfocusAll();
    db.saveUserData();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ItemStatistics>(
        initialData: db.itemStat,
        stream: db.itemStat.onUpdated.stream,
        builder: (context, snapshot) {
          List<Widget> children = [];
          final stat = snapshot.data;
          _shownGroups.clear();
          for (var group in _allGroups.values) {
            if (!widget.filtered ||
                group.data.name == qpKey ||
                stat.leftItems[group.data.name] < 0) {
              _shownGroups.add(group);
              children.add(buildItemTile(group, stat));
            }
          }
          return wrapDefaultScrollBar(
            controller: _scrollController,
            child: ListView.separated(
              controller: _scrollController,
              itemBuilder: (context, index) => children[index],
              separatorBuilder: (context, index) =>
                  Divider(height: 1, indent: 16),
              itemCount: children.length,
            ),
          );
        });
  }

  Widget buildItemTile(InputComponents group, ItemStatistics statistics) {
    final itemKey = group.data.name;
    bool isQp = itemKey == qpKey;

    return StatefulBuilder(
      builder: (BuildContext context, setState2) {
        // update when text input
        bool enough = statistics.leftItems[itemKey] >= 0;
        final highlightStyle =
            TextStyle(color: enough ? null : Colors.redAccent);
        Widget textField = TextField(
          maxLength: isQp ? 20 : 5,
          controller: group.controller,
          focusNode: group.focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(counterText: ''),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'-?[\d,]*')),
            if (itemKey == Item.qp) NumberInputFormatter(),
          ],
          onChanged: (v) {
            db.curUser.items[itemKey] =
                int.tryParse(v.replaceAll(',', '')) ?? 0;
            statistics.updateLeftItems(shouldBroadcast: false);
            setState2(() {});
          },
          onTap: () {
            // select all text at first tap
            if (!group.focusNode.hasFocus && group.controller != null) {
              group.controller.selection = TextSelection(
                  baseOffset: 0, extentOffset: group.controller.text.length);
            }
          },
          onEditingComplete: () {
            FocusScope.of(context).nextFocus();
          },
        );
        Widget title, subtitle;
        if (isQp) {
          title = Row(
            children: <Widget>[
              Text(itemKey + '  '),
              Expanded(child: textField)
            ],
          );
          subtitle = Row(
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    '共需 ${formatNumber(statistics.svtItems[itemKey])}',
                    maxLines: 1,
                  )),
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    '剩余 ${formatNumber(statistics.leftItems[itemKey])}',
                    maxLines: 1,
                    style: highlightStyle,
                    minFontSize: 10,
                  ))
            ],
          );
        } else {
          title = Row(
            children: <Widget>[
              Expanded(child: AutoSizeText(itemKey, maxLines: 1)),
              Text('剩余'),
              SizedBox(
                  width: 40,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AutoSizeText(
                        statistics.leftItems[itemKey].toString(),
                        style: highlightStyle,
                        maxLines: 1),
                  )),
            ],
          );
          List<int> _countsInSubTitle = statistics.svtItemDetail.planItemCounts
              .valuesIfGrail(itemKey)
              .map((e) => e[itemKey] ?? 0)
              .toList();
          subtitle = Row(
            children: <Widget>[
              Expanded(
                  child: AutoSizeText(
                '共需 ${statistics.svtItems[itemKey]}' +
                    '(${_countsInSubTitle.join("/")})',
                maxLines: 1,
              )),
              Text('活动'),
              SizedBox(
                  width: 40,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AutoSizeText(
                        (statistics.eventItems[itemKey] ?? 0).toString(),
                        maxLines: 1),
                  )),
            ],
          );
        }

        return ListTile(
          onTap: () => SplitRoute.push(
            context: context,
            builder: (context, _) => ItemDetailPage(itemKey),
            popDetail: true,
          ),
          leading: Image(image: db.getIconImage(itemKey), height: 110 * 0.5),
          title: title,
          focusNode: FocusNode(canRequestFocus: true, skipTraversal: true),
          subtitle: subtitle,
          // titlePadding: isQp
          //     ? EdgeInsets.fromLTRB(16, 0, 0, 0)
          //     : EdgeInsets.fromLTRB(16, 0, 16, 0),
          trailing: isQp ? null : SizedBox(width: 50, child: textField),
        );
      },
    );
  }
}
