import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

class MainRecordTab extends StatefulWidget {
  @override
  _MainRecordTabState createState() => _MainRecordTabState();
}

class _MainRecordTabState extends State<MainRecordTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<Widget> children = [];
    db.gameData.events.mainRecords.forEach((chapter, record) {
      children.add(CustomTile(
        title: AutoSizeText(chapter, maxLines: 1),
        trailing: Wrap(
          children: List.generate(2, (i) {
            return Switch.adaptive(
                value: db.curPlan.mainRecords[chapter]?.elementAt(i) ?? false,
                onChanged: (v) {
                  setState(() {
                    db.curPlan.mainRecords[chapter] ??= List.filled(2, false);
                    db.curPlan.mainRecords[chapter][i] = v;
                  });
                });
          }).toList(),
        ),
      ));
    });
    return Column(
      children: <Widget>[
        CustomTile(
          title: Text('章节'),
          trailing: Wrap(
            spacing: 10,
            children: <Widget>[
              Text('主线掉落'),
              Text('主线奖励'),
            ],
          ),
        ),
        Divider(thickness: 1),
        Expanded(
            child: ListView(
          children: children,
        ))
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
