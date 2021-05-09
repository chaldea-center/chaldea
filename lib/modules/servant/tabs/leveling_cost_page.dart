import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';

class LevelingCostPage extends StatefulWidget {
  final List<Map<String, int>> costList;
  final int curLv;
  final int targetLv;
  final String title;

  const LevelingCostPage({
    Key? key,
    required this.costList,
    this.curLv = 0,
    this.targetLv = 0,
    this.title = '',
  })  : assert(curLv <= targetLv),
        super(key: key);

  @override
  State<StatefulWidget> createState() => LevelingCostPageState();
}

class LevelingCostPageState extends State<LevelingCostPage> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    final int offset = widget.costList.length == 9 ? -1 : 0;
    final bool _showAll = showAll || widget.curLv >= widget.targetLv;
    final int lva = _showAll ? 0 : widget.curLv + offset,
        lvb = _showAll ? widget.costList.length : widget.targetLv + offset;
    assert(0 <= lva && lvb <= widget.costList.length);

    final size = MediaQuery.of(context).size;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      title: Center(child: Text(widget.title)),
      content: Container(
        width: min(380, size.width * 0.8),
        child: ListView(
          shrinkWrap: true,
          children: List.generate(lvb - lva, (i) {
            return buildOneLevel(
              'Lv.${lva + i - offset} → Lv.${lva + i - offset + 1}',
              widget.costList[lva + i],
            );
          }),
        ),
      ),
      actions: [
        TextButton(
          // minWidth: 120,
          onPressed: () {
            setState(() => showAll = !showAll);
          },
          // style: TextButton.styleFrom(),
          child: Text(showAll ? 'SHOW LESS' : 'SHOW MORE'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        )
      ],
    );
  }

  Widget buildOneLevel(String title, Map<String, int> lvCost) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CustomTile(
            title: Text(title),
            subtitle: lvCost.isEmpty
                ? Text(LocalizedText.of(
                    chs: '不消耗素材', jpn: '素材消費なし', eng: 'No item consumption'))
                : null,
            contentPadding: EdgeInsets.symmetric(horizontal: 0),
          ),
          if (lvCost.isNotEmpty)
            GridView.count(
              crossAxisCount: 6,
              childAspectRatio: 132 / 144,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: lvCost.entries
                  .map((entry) => Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                        child: ImageWithText(
                          image: db.getIconImage(entry.key, preferPng: false),
                          text: formatNumber(entry.value, compact: true),
                          onTap: entry.key == 'QP'
                              ? null
                              : () => SplitRoute.push(
                                    context: context,
                                    builder: (context, _) =>
                                        ItemDetailPage(itemKey: entry.key),
                                    popDetail: true,
                                  ),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
