import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/event/main_record_detail_page.dart';

class MainRecordTab extends StatefulWidget {
  final bool reversed;
  final bool showOutdated;

  const MainRecordTab(
      {Key? key, this.reversed = false, this.showOutdated = false})
      : super(key: key);

  @override
  _MainRecordTabState createState() => _MainRecordTabState();
}

class _MainRecordTabState extends State<MainRecordTab> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<MainRecord> mainRecords =
        db.gameData.events.mainRecords.values.toList();
    if (!widget.showOutdated) {
      mainRecords.removeWhere((e) {
        final plan = db.curUser.events.mainRecordOf(e.indexKey);
        return e.isOutdated() && !plan.enabled;
      });
    }
    // first three chapters has the same startTimeJp
    EventBase.sortEvents(mainRecords, reversed: widget.reversed);
    Color? _outdatedColor = Theme.of(context).textTheme.caption?.color;
    return Column(
      children: <Widget>[
        CustomTile(
          title: Text(S.of(context).main_record_chapter),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(S.of(context).main_record_fixed_drop),
              Padding(padding: EdgeInsets.only(right: 6)),
              Text(S.of(context).main_record_bonus)
            ],
          ),
        ),
        kDefaultDivider,
        Expanded(
          child: db.streamBuilder(
            (context) => ListView.separated(
              controller: _scrollController,
              itemCount: mainRecords.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, indent: 16),
              itemBuilder: (context, index) {
                final record = mainRecords[index];
                final plan = db.curUser.events.mainRecordOf(record.indexKey);
                bool outdated = record.isOutdated();
                Widget? title, subtitle;
                if (Language.isEN) {
                  title = AutoSizeText(
                    Localized.chapter.of(record.name),
                    maxLines: 2,
                    maxFontSize: 16,
                    style: outdated ? TextStyle(color: _outdatedColor) : null,
                  );
                } else {
                  title = AutoSizeText(
                    record.localizedChapter,
                    maxLines: 1,
                    maxFontSize: 16,
                    style: outdated ? TextStyle(color: Colors.grey) : null,
                  );
                  subtitle = AutoSizeText(
                    record.localizedTitle,
                    maxLines: 1,
                    style: outdated
                        ? TextStyle(color: _outdatedColor?.withAlpha(200))
                        : null,
                  );
                }
                return ListTile(
                  title: title,
                  subtitle: subtitle,
                  trailing: Wrap(
                    children: [
                      Switch.adaptive(
                        value: plan.drop,
                        onChanged: (v) {
                          plan.drop = v;
                          db.itemStat.updateEventItems();
                        },
                      ),
                      Switch.adaptive(
                        value: plan.reward,
                        onChanged: (v) {
                          plan.reward = v;
                          db.itemStat.updateEventItems();
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    SplitRoute.push(
                      context,
                      MainRecordDetailPage(record: record),
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
