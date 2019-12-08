import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'item_detail_page.dart';

class ItemListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ItemListPageState();
}

class ItemListPageState extends State<ItemListPage>
    with SingleTickerProviderStateMixin {
  List<int> categories = [1, 2, 3];

  //controller
  TabController _tabController;

  bool filtered = false;

  @override
  void deactivate() {
    super.deactivate();
    db.saveData();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    db.runtimeData.itemsOfEvents = db.gameData.events.getAllItems(db.curPlan);
    db.runtimeData.itemsOfSvts.update(db.gameData, db.curPlan.servants);
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
                .map((category) =>
                    Tab(text: ['x', '普通素材', '技能石', '棋子', '活动素材'][category]))
                .toList()),
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
                text: (db.curPlan.items[key] ?? 0).toString()),
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
    db.saveData();
  }

  @override
  Widget build(BuildContext context) {
    inputsManager.resetFocusList();
    List<Widget> children = [
      for (var c in inputsManager.components) buildItemTile(c)
    ];
    children.removeWhere((e) => e == null);
    return ListView.separated(
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
        itemCount: children.length);
  }

  Widget buildItemTile(InputComponent<Item> component) {
    final itemKey = component.data.name;
    PartSet<int> svtCostStat = db.runtimeData.itemsOfSvts.getNumOfItem(itemKey);
    int svtCostNum = sum(svtCostStat.values);
    int eventNum = db.runtimeData.itemsOfEvents[itemKey] ?? 0;
    int ownNum = db.curPlan.items[itemKey] ?? 0;
    int leftNum = ownNum + eventNum - svtCostNum;
    bool enough = leftNum >= 0;
    bool isQp = itemKey == qpKey;
    if (widget.filtered && enough && !isQp) {
      return null;
    }
    inputsManager.addObserver(component);
    return StatefulBuilder(
      builder: (BuildContext context, setState2) {
        int ownNum = db.curPlan.items[itemKey] ?? 0;
        int leftNum = ownNum + eventNum - svtCostNum;
        bool enough = leftNum >= 0;

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
                db.curPlan.items[component.data.name] =
                    int.tryParse(v.replaceAll(',', '')) ?? 0;
                setState2(() {});
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
                    '共需 ${formatNumToString(svtCostNum, "decimal")}',
                    maxLines: 1,
                  )),
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    '剩余 ${formatNumToString(leftNum, "decimal")}',
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
                    child: AutoSizeText(leftNum.toString(),
                        style: highlightStyle, maxLines: 1),
                  )),
            ],
          );
          subtitle = Row(
            children: <Widget>[
              Expanded(
                  child: AutoSizeText(
                '共需 $svtCostNum' + '(${svtCostStat.values.join("/")})',
                maxLines: 1,
              )),
              Text('活动'),
              SizedBox(
                  width: 40,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AutoSizeText(eventNum.toString(),
                        style: highlightStyle, maxLines: 1),
                  )),
            ],
          );
        }
        return CustomTile(
          onTap: () => SplitRoute.popAndPush(context,
              builder: (context) => ItemDetailPage(itemKey)),
          leading: Image(image: db.getIconFile(itemKey), height: 110 * 0.5),
          title: title,
          subtitle: subtitle,
          titlePadding: isQp
              ? EdgeInsets.fromLTRB(16, 0, 0, 0)
              : EdgeInsets.fromLTRB(16, 0, 16, 0),
          trailing: isQp
              ? null
              : SizedBox(
                  width: 50,
                  child: textField,
                ),
        );
      },
    );
  }
}
