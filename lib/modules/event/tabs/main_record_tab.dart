import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/event/main_record_detail_page.dart';

class MainRecordTab extends StatefulWidget {
  final bool reverse;

  const MainRecordTab({Key key, this.reverse}) : super(key: key);

  @override
  _MainRecordTabState createState() => _MainRecordTabState();
}

class _MainRecordTabState extends State<MainRecordTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final mainRecords = db.gameData.events.mainRecords.values.toList();
    mainRecords.sort((a, b) {
      return (a.startTimeJp).compareTo(b.startTimeJp) *
          (widget.reverse ? -1 : 1);
    });
    return Column(
      children: <Widget>[
        CustomTile(
          title: Text('章节'),
          trailing: Wrap(
            spacing: 10,
            children: <Widget>[Text('主线掉落'), Text('主线奖励')],
          ),
        ),
        Divider(thickness: 1),
        Expanded(
            child: ListView.separated(
                itemCount: mainRecords.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, indent: 16),
                itemBuilder: (context, index) {
                  final chapter = mainRecords[index].name;
                  final plan = db.curPlan.mainRecords;
                  return CustomTile(
                    title: AutoSizeText(chapter, maxLines: 1, maxFontSize: 16),
                    trailing: Wrap(
                      children: List.generate(2, (i) {
                        return Switch.adaptive(
                            value: plan[chapter]?.elementAt(i) ?? false,
                            onChanged: (v) {
                              setState(() {
                                plan[chapter] ??= List.filled(2, false);
                                plan[chapter][i] = v;
                              });
                            });
                      }).toList(),
                    ),
                    onTap: () {
                      SplitRoute.popAndPush(context,
                          builder: (context) =>
                              MainRecordDetailPage(name: chapter));
                    },
                  );
                }))
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
