import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:flutter/cupertino.dart';

class EventDetailPage extends StatefulWidget {
  final String name;

  const EventDetailPage({Key key, this.name}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  TextEditingController _editingController = TextEditingController(text: '0');
  TextInputsManager<String> manager = TextInputsManager();
  bool rerun = true;

  @override
  void initState() {
    super.initState();
    final hunting = db.gameData.events[widget.name].hunting;
    if (hunting != null) {
      for (var day in hunting) {
        for (var name in day.keys) {
          manager.components.add(InputComponent(
              data: name,
              textEditingController: TextEditingController(),
              focusNode: FocusNode()));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = db.gameData.events[widget.name];
    int grailNum = event.grail + (rerun ? 0 : event.grail2crystal),
        crystalNum = event.crystal + (rerun ? event.grail2crystal : 0);
    List<Widget> children = [
      if (event.grail2crystal > 0)
        CustomTile(
          title: Text('复刻活动'),
          subtitle: Text('圣杯替换传承结晶 ${event.grail2crystal} 个'),
          trailing: CupertinoSwitch(
              value: rerun, onChanged: (v) => setState(() => rerun = v)),
        ),
      if (grailNum + crystalNum > 0)
        _buildItemList({'圣杯': grailNum, '传承结晶': crystalNum}
          ..removeWhere((_, n) => n <= 0)),
      if (event.lottery != null) ...[
        CustomTile(
          title: Text('无限池',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 60,
//                height: 30,
                child: TextField(
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: InputDecoration(counterText: ''),
                  controller: _editingController,
                ),
              ),
              Text(' 池  ')
            ],
          ),
        ),
        _buildLottery(event.lottery)
      ],
      if (event.items != null && event.items.length > 0) ...[
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Center(
              child: Text(
            '商店&任务&点数',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          )),
        ),
        _buildItemList(event.items)
      ],
      if (event.hunting != null) _buildHunting(event.hunting),
    ];
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
    final divided = divideGroups(data.keys.toList(), rarity: true);
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
                      image: Image.file(db.getIconFile(item.name)),
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

  Widget _buildLottery(Map<String, int> data) {
    final divided = divideGroups(data.keys.toList(), rarity: true);
    List<Widget> children = [];
    for (var key in divided.keys) {
      children
        ..add(Text(getNameOfCategory(key ~/ 10, key % 10)))
        ..add(GridView.count(
          padding: EdgeInsets.only(top: 3, bottom: 6),
          childAspectRatio: 132 / 144,
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: divided[key]
              .map((item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 1),
                    child: ImageWithText(
                      image: Image.file(db.getIconFile(item.name)),
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

  Widget _buildHunting(List<Map<String, double>> data) {
    manager.resetFocusList();
    List<Widget> children = [];
    for (var i = 0; i < data.length; i++) {
      children.add(Text('Day ${i + 1}'));
      data[i].forEach((name, drop) {
        final component = manager.getComponentByData(name);
        manager.addFocus(component.focusNode);
        children.add(CustomTile(
          leading: Image.file(db.getIconFile(name), height: 110 * 0.5),
          title: Text(name),
          subtitle: Text('参考掉率: $drop AP/个'),
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
                  onSubmitted: (_) {
                    manager.moveNextFocus(context, component.focusNode);
                  },
                ),
                focusNode: component.focusNode),
          ),
        ));
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 12, thickness: 1),
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Center(
              child: Text(
            '狩猎关卡',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          )),
        ),
        Divider(height: 12, thickness: 1),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        )
      ],
    );
  }

  Map<int, List<Item>> divideGroups(List<String> items,
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
    _editingController.dispose();
    manager.dispose();
  }
}
