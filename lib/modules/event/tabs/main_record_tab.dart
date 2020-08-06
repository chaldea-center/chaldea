import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/event/main_record_detail_page.dart';

class MainRecordTab extends StatefulWidget {
  final bool reverse;

  const MainRecordTab({Key key, this.reverse}) : super(key: key);

  @override
  _MainRecordTabState createState() => _MainRecordTabState();
}

class _MainRecordTabState extends State<MainRecordTab> {
  @override
  Widget build(BuildContext context) {
    var mainRecords = db.gameData.events.mainRecords.values.toList();
    mainRecords.sort((a, b) => a.startTimeJp.compareTo(b.startTimeJp));
    if (widget.reverse) {
      // first three chapters has the same startTimeJp
      mainRecords = mainRecords.reversed.toList();
    }
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
                separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
                itemBuilder: (context, index) {
                  final name = mainRecords[index].name;
                  final plan = db.curUser.events.mainRecords;
                  return ListTile(
                    title: AutoSizeText(name, maxLines: 1, maxFontSize: 16),
                    subtitle: AutoSizeText(mainRecords[index].title, maxLines: 1),
                    trailing: Wrap(
                      children: List.generate(2, (i) {
                        return Switch.adaptive(
                            value: plan[name]?.elementAt(i) ?? false,
                            onChanged: (v) {
                              setState(() {
                                plan[name] ??= List.filled(2, false);
                                plan[name][i] = v;
                                db.itemStat.updateEventItems();
                              });
                            });
                      }).toList(),
                    ),
                    onTap: () {
                      SplitRoute.popAndPush(context,
                          builder: (context) => MainRecordDetailPage(name: name));
                    },
                  );
                }))
      ],
    );
  }
}
