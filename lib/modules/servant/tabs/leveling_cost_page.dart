import 'package:chaldea/components/components.dart';

class LevelingCostPage extends StatefulWidget {
  final List<List<Item>> costList;
  final int curLv;
  final int targetLv;
  final String title;

  const LevelingCostPage(
      {Key key,
      @required this.costList,
      this.curLv = 0,
      this.targetLv = 0,
      this.title = ''})
      : assert(curLv <= targetLv),
        super(key: key);

  @override
  State<StatefulWidget> createState() => LevelingCostPageState();
}

class LevelingCostPageState extends State<LevelingCostPage> {
  bool showAll = false;

  Widget buildOneLevel(String title, List<Item> lvCost) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CustomTile(
            title: Text(title),
            contentPadding: EdgeInsets.zero,
          ),
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: lvCost
                .map((item) => ImageWithText(
                      image: Image(image:db.getIconFile(item.name)),
                      text: formatNumToString(item.num, 'kilo'),
                      padding: EdgeInsets.only(right: 3),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int offset = widget.costList.length == 9 ? -1 : 0;
    final bool _showAll = showAll || widget.curLv >= widget.targetLv;
    final int lva = _showAll ? 0 : widget.curLv + offset,
        lvb = _showAll ? widget.costList.length : widget.targetLv + offset;
    assert(0 <= lva && lvb <= widget.costList.length);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(showAll ? Icons.pie_chart_outlined : Icons.pie_chart),
              onPressed: () {
                showAll = !showAll;
                setState(() {});
              })
        ],
      ),
      body: ListView(
        children: List.generate(lvb - lva, (i) {
          return buildOneLevel(
            'Lv.${lva + i - offset} → Lv.${lva + i - offset + 1}',
            widget.costList[lva + i],
          );
        }),
      ),
    );
  }
}
