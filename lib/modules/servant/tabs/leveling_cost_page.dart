import 'package:chaldea/components/components.dart';

class LevelingCostPage extends StatefulWidget {
  final List<Map<String, int>> costList;
  final int curLv;
  final int targetLv;
  final String title;
  final String Function(int level)? levelFormatter;

  const LevelingCostPage({
    Key? key,
    required this.costList,
    this.curLv = 0,
    this.targetLv = 0,
    this.title = '',
    this.levelFormatter,
  })  : assert(curLv <= targetLv),
        super(key: key);

  @override
  State<StatefulWidget> createState() => LevelingCostPageState();
}

class LevelingCostPageState extends State<LevelingCostPage> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    // final int offset = widget.costList.length == 9 ? -1 : 0;
    final bool _showAll = showAll || widget.curLv >= widget.targetLv;
    final int lva = _showAll ? 0 : widget.curLv,
        lvb = _showAll ? widget.costList.length : widget.targetLv;
    assert(0 <= lva && lvb <= widget.costList.length);

    final size = MediaQuery.of(context).size;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      title: Text(
        widget.title,
        style: const TextStyle(fontSize: 16),
      ),
      content: SizedBox(
        width: min(380, size.width * 0.8),
        child: ListView(
          shrinkWrap: true,
          children: List.generate(lvb - lva, (i) {
            return buildOneLevel(
              '${_formatLevel(lva + i)} → ${_formatLevel(lva + i + 1)}',
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
          child: const Text('OK'),
        )
      ],
    );
  }

  Widget buildOneLevel(String title, Map<String, int> lvCost) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          ),
          if (lvCost.isNotEmpty)
            GridView.count(
              crossAxisCount: 6,
              childAspectRatio: 132 / 144,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: lvCost.entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 2),
                        child: ImageWithText(
                          image: Item.iconBuilder(
                              context: context, itemKey: entry.key),
                          text: formatNumber(entry.value, compact: true),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  String _formatLevel(int lv) {
    if (widget.levelFormatter != null) return widget.levelFormatter!(lv);
    return 'Lv.$lv';
  }
}
