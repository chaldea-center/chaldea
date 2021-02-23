//@dart=2.9
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
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainRecords = db.gameData.events.mainRecords;
    var mainRecordKeys = db.gameData.events.mainRecords.keys.toList();
    mainRecordKeys.sort((a, b) =>
        mainRecords[a].startTimeJp.compareTo(mainRecords[b].startTimeJp));
    if (widget.reverse) {
      // first three chapters has the same startTimeJp
      mainRecordKeys = mainRecordKeys.reversed.toList();
    }
    return Column(
      children: <Widget>[
        CustomTile(
          title: Text(S.of(context).main_record_chapter),
          trailing: Wrap(
            spacing: 10,
            children: <Widget>[
              Text(S.of(context).main_record_fixed_drop),
              Text(S.of(context).main_record_bonus)
            ],
          ),
        ),
        kDefaultDivider,
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            child: ListView.separated(
              controller: _scrollController,
              itemCount: mainRecordKeys.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, indent: 16),
              itemBuilder: (context, index) {
                final record = mainRecords[mainRecordKeys[index]];
                final plan = db.curUser.events.mainRecordOf(record.indexKey);
                return ListTile(
                  title: AutoSizeText(record.localizedChapter,
                      maxLines: 1, maxFontSize: 16),
                  subtitle: record.localizedTitle == null
                      ? null
                      : AutoSizeText(record.localizedTitle, maxLines: 1),
                  trailing: Wrap(
                    children: List.generate(2, (i) {
                      return Switch.adaptive(
                          value: plan[i],
                          onChanged: (v) {
                            setState(() {
                              plan[i] = v;
                              db.itemStat.updateEventItems();
                            });
                          });
                    }).toList(),
                  ),
                  onTap: () {
                    SplitRoute.push(
                      context: context,
                      builder: (context, _) =>
                          MainRecordDetailPage(name: mainRecordKeys[index]),
                      popDetail: true,
                    );
                  },
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
