import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/drop_calculator/drop_calculator_page.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'item_detail_page.dart';

class ItemListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ItemListPageState();
}

class ItemListPageState extends State<ItemListPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool filtered = false;
  final List<int> categories = [1, 2, 3];

  @override
  void deactivate() {
    super.deactivate();
    db.saveUserData();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    db.runtimeData.itemStatistics.update(db.curUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).item_title),
        leading: SplitViewBackButton(),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                showDialog(
                    context: context,
                    child: SimpleDialog(
                      title: Text('Choose plan'),
                      children: List.generate(db.curUser.servantPlans.length,
                          (index) {
                        return ListTile(
                          title: Text('Plan ${index + 1}'),
                          selected: index == db.curUser.curPlanNo,
                          onTap: () {
                            Navigator.of(context).pop();
                            db.curUser.curPlanNo = index;
                            db.runtimeData.itemStatistics.update(db.curUser);
                            setState(() {});
                          },
                        );
                      }),
                    ));
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
              icon: Icon(Icons.toys),
              onPressed: () async {
                GLPKParams params = GLPKParams();
                db.runtimeData.itemStatistics
                  ..update()
                  ..leftItems.forEach((itemKey, value) {
                    if (db.gameData.glpk.rowNames.contains(itemKey) &&
                        value < 0) {
                      params.objRows.add(itemKey);
                      params.objNums.add(-value);
                    }
                  });
                SplitRoute.push(
                  context,
                  builder: (context) => DropCalculatorPage(params: params),
                );
              })
        ],
        bottom: TabBar(
          controller: _tabController,
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
          controller: _tabController,
          children: categories
              .map((category) =>
                  ItemListTab(category: category, filtered: filtered))
              .toList()),
    );
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

class _ItemListTabState extends State<ItemListTab> {
  TextInputsManager<Item> inputsManager = TextInputsManager();
  final qpKey = 'QP';
  FocusNode _blankNode = FocusNode();

  @override
  void initState() {
    super.initState();
    db.gameData.items.forEach((key, item) {
      if (item.category == widget.category || key == qpKey) {
        final node = FocusNode();
        node.addListener(() {
          // auto focus problem when deactivated->activated
          for (var component in inputsManager.components) {
            if (component.focusNode.hasFocus) {
              return;
            }
          }
          SchedulerBinding.instance.addPostFrameCallback(
              (_) => FocusScope.of(context).requestFocus(_blankNode));
        });
        inputsManager.components.add(InputComponent(
            data: item,
            controller: TextEditingController(
                text: (db.curUser.items[key] ?? 0).toString()),
            focusNode: node));
      }
    });
    inputsManager.components.sort((a, b) => a.data.id - b.data.id);
    int qpIndex =
        inputsManager.components.indexWhere((e) => e.data.name == qpKey);
    if (qpIndex >= 0) {
      inputsManager.components
          .insert(0, inputsManager.components.removeAt(qpIndex));
    }
  }

  @override
  void dispose() {
    super.dispose();
    inputsManager.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
    db.saveUserData();
  }

  @override
  Widget build(BuildContext context) {
    inputsManager.resetFocusList();
    List<Widget> children = [];
    for (var c in inputsManager.components) {
      Widget tile = buildItemTile(c);
      if (tile != null) {
        children.add(tile);
      }
    }
    return ListView.separated(
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
        itemCount: children.length);
  }

  Widget buildItemTile(InputComponent<Item> component) {
    final itemKey = component.data.name;
    final statistics = db.runtimeData.itemStatistics;
    bool isQp = itemKey == qpKey;
    bool enough = statistics.leftItems[itemKey] >= 0;

    if (widget.filtered && enough && !isQp) {
      return null;
    }
    inputsManager.addObserver(component);
    return StatefulBuilder(
      builder: (BuildContext context, setState2) {
        bool enough =
            statistics.leftItems[itemKey] >= 0; // update when text input

        final highlightStyle =
            TextStyle(color: enough ? null : Colors.redAccent);
        Widget textField = EnsureVisibleWhenFocused(
            child: TextField(
              maxLength: isQp ? 20 : 5,
              controller: component.controller,
              focusNode: component.focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                isDense: true,
                counterText: '',
                contentPadding: EdgeInsets.all(0),
              ),
              inputFormatters: [
                WhitelistingTextInputFormatter.digitsOnly,
                if (isQp) NumberInputFormatter(),
              ],
              onChanged: (v) {
                db.curUser.items[itemKey] =
                    int.tryParse(v.replaceAll(',', '')) ?? 0;
                setState2(() {
                  db.runtimeData.itemStatistics.updateLeftItems();
                });
              },
              onTap: () {
                component.onTap(context);
              },
              onSubmitted: (s) {
                inputsManager.moveNextFocus(context, component);
              },
            ),
            focusNode: component.focusNode);
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
                    '共需 ${formatNumToString(statistics.svtItems[itemKey], "decimal")}',
                    maxLines: 1,
                  )),
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    '剩余 ${formatNumToString(statistics.leftItems[itemKey], "decimal")}',
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
          subtitle = Row(
            children: <Widget>[
              Expanded(
                  child: AutoSizeText(
                '共需 ${statistics.svtItems[itemKey]}' +
                    '(${statistics.svtItemDetail.planItemCounts.values.map((e) => e[itemKey] ?? 0).join("/")})',
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
        return CustomTile(
          onTap: () => SplitRoute.popAndPush(context,
              builder: (context) => ItemDetailPage(itemKey)),
          leading: Image(image: db.getIconImage(itemKey), height: 110 * 0.5),
          title: title,
          subtitle: subtitle,
          titlePadding: isQp
              ? EdgeInsets.fromLTRB(16, 0, 0, 0)
              : EdgeInsets.fromLTRB(16, 0, 16, 0),
          trailing: isQp ? null : SizedBox(width: 50, child: textField),
        );
      },
    );
  }
}
