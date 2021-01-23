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
    with DefaultScrollBarMixin {
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
    var mainRecords = db.gameData.events.mainRecords.values.toList();
    mainRecords.sort((a, b) => a.startTimeJp.compareTo(b.startTimeJp));
    if (widget.reverse) {
      // first three chapters has the same startTimeJp
      mainRecords = mainRecords.reversed.toList();
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
        Divider(thickness: 1),
        Expanded(
          child: wrapDefaultScrollBar(
            controller: _scrollController,
            child: ListView.separated(
              controller: _scrollController,
              itemCount: mainRecords.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, indent: 16),
              itemBuilder: (context, index) {
                final record = mainRecords[index];
                final name = record.name;
                final plan = db.curUser.events.mainRecords;
                return ListTile(
                  title: AutoSizeText(record.chapter,
                      maxLines: 1, maxFontSize: 16),
                  subtitle: AutoSizeText(record.title, maxLines: 1),
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
                    SplitRoute.push(
                      context: context,
                      builder: (context, _) => MainRecordDetailPage(name: name),
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
