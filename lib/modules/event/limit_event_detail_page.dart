import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:flutter/services.dart';

class LimitEventDetailPage extends StatefulWidget {
  final String name;

  const LimitEventDetailPage({Key key, this.name}) : super(key: key);

  @override
  _LimitEventDetailPageState createState() => _LimitEventDetailPageState();
}

class _LimitEventDetailPageState extends State<LimitEventDetailPage> {
  LimitEvent event;
  LimitEventPlan plan;
  TextEditingController _lotteryController;
  TextInputsManager<String> manager = TextInputsManager();

  @override
  void initState() {
    super.initState();
    event = db.gameData.events.limitEvents[widget.name] ??
        LimitEvent(name: 'empty event');
    plan =
        db.curPlan.limitEvents.putIfAbsent(event.name, () => LimitEventPlan());
    if (event.lottery != null) {
      _lotteryController = TextEditingController(text: plan.lottery.toString());
    }
    if (event.hunting != null) {
      for (var day in event.hunting) {
        for (var name in day.keys) {
          manager.components.add(InputComponent(
              data: name,
              controller:
                  TextEditingController(text: plan.hunting[name]?.toString()),
              focusNode: FocusNode()));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int grailNum = event.grail + (plan.rerun ? 0 : event.grail2crystal),
        crystalNum = event.crystal + (plan.rerun ? event.grail2crystal : 0);
    List<Widget> children = [];
    if (event.grail2crystal > 0) {
      children.add(SwitchListTile.adaptive(
        title: Text('复刻活动'),
        subtitle: Text('圣杯替换为传承结晶 ${event.grail2crystal} 个'),
        value: plan.rerun,
        onChanged: (v) => setState(() => plan.rerun = v),
      ));
    }
    if (event.lottery != null) {
      children
        ..add(ListTile(
          title: Text('无限池共计'),
          trailing: SizedBox(
              width: 80,
              child: TextField(
                maxLength: 4,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                scrollPadding: EdgeInsets.zero,
                decoration: InputDecoration(
                  counterText: '',
                  suffixText: '池',
                ),
                controller: _lotteryController,
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp(r'\d'))
                ],
                onChanged: (v) {
                  plan.lottery = int.tryParse(v) ?? 0;
                },
              )),
        ))
        ..add(_buildItemList(event.lottery));
    }
    if (grailNum + crystalNum > 0 || event.items != null) {
      children
        ..add(ListTile(title: Center(child: Text('商店&任务&点数'))))
        ..add(_buildItemList({'圣杯': grailNum, '传承结晶': crystalNum}
          ..addAll(event.items)
          ..removeWhere((k, v) => v <= 0)));
    }
    if (event.hunting != null) {
      children
        ..add(ListTile(title: Center(child: Text('狩猎关卡'))))
        ..add(_buildHunting(event.hunting, plan.hunting));
    }
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: AutoSizeText(widget.name ?? '', maxLines: 1),
      ),
      body: ListView(
        children: divideTiles(children,
            divider: Divider(
              thickness: 1,
            )),
      ),
    );
  }

  Widget _buildItemList(Map<String, int> data) {
    final divided = divideItemsToGroups(data.keys.toList(), rarity: true);
    List<Widget> children = [];
    for (var key in divided.keys) {
      children
        ..add(Text(getNameOfCategory(key ~/ 10, key % 10)))
        ..add(GridView.count(
          padding: EdgeInsets.only(top: 3, bottom: 6),
          childAspectRatio: 132 / 144,
          crossAxisCount: 6,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: divided[key]
              .map((item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 1),
                    child: ImageWithText(
                      image: Image(image: db.getIconFile(item.name)),
                      text: formatNumToString(data[item.name], 'kilo'),
                      padding: EdgeInsets.only(right: 3),
                    ),
                  ))
              .toList(),
        ));
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildHunting(
      List<Map<String, double>> data, Map<String, int> huntingPlan) {
    manager.resetFocusList();
    List<Widget> children = [];
    for (var i = 0; i < data.length; i++) {
      children.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Day ${i + 1}'),
      ));
      data[i].forEach((name, drop) {
        final component = manager.getComponentByData(name);
        manager.addObserver(component);
        children.add(CustomTile(
          leading: Image(image: db.getIconFile(name), height: 110 * 0.5),
          title: Text(name),
          subtitle: Text('参考掉率: $drop AP/个'),
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
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp(r'\d'))
                  ],
                  decoration: InputDecoration(counterText: ''),
                  onChanged: (v) {
                    if (huntingPlan != null) {
                      int value = int.tryParse(v) ?? 0;
                      huntingPlan[name] = value;
                    }
                  },
                  onTap: () => component.selectAll(),
                  onSubmitted: (_) {
                    manager.moveNextFocus(context, component);
                  },
                ),
                focusNode: component.focusNode),
          ),
        ));
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Map<int, List<Item>> divideItemsToGroups(List<String> items,
      {bool category = true, bool rarity = false}) {
    Map<int, List<Item>> groups = {};
    for (String itemKey in items) {
      final item = db.gameData.items[itemKey];
      final groupKey =
          (category ? item.category * 10 : 0) + (rarity ? item.rarity : 0);
      groups[groupKey] ??= [];
      groups[groupKey].add(item);
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

  @override
  void dispose() {
    super.dispose();
    _lotteryController?.dispose();
    manager.dispose();
  }
}
