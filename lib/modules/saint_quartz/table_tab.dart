import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/summon/summon_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class SQTableTab extends StatefulWidget {
  const SQTableTab({Key? key}) : super(key: key);

  @override
  _SQTableTabState createState() => _SQTableTabState();
}

const double _eventHeight = 24;
const double _summonHeight = 36;

class _SQTableTabState extends State<SQTableTab> {
  late ScrollControllers _scrollControllers;

  SaintQuartzPlan get plan => db.curUser.saintQuartzPlan;

  final _tableKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _scrollControllers = ScrollControllers();
  }

  double x = 0;
  double y = 0;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: table,
    );
  }

  Widget get table {
    return StickyHeadersTable(
      key: _tableKey,
      scrollControllers: _scrollControllers,
      initialScrollOffsetX: x,
      initialScrollOffsetY: y,
      onEndScrolling: (_x, _y) {
        x = _x;
        y = _y;
      },
      columnsLength: 4,
      rowsLength: plan.solution.length,
      legendCell: Text(LocalizedText.of(chs: '日期', jpn: '日付', eng: 'Date')),
      cellDimensions: CellDimensions.variableColumnWidthAndRowHeight(
        columnWidths: [50, 50, 50, 500],
        rowHeights: plan.solution
            .map((e) => max(
                    48,
                    e.events.length * _eventHeight +
                        e.summons.length * _summonHeight +
                        4)
                .toDouble())
            .toList(),
        stickyLegendWidth: 120,
        stickyLegendHeight: 36,
      ),
      cellAlignments: CellAlignments.variableColumnAlignment(
        columnAlignments: List.generate(
            4, (index) => index == 3 ? Alignment.centerLeft : Alignment.center),
        stickyRowAlignments: List.generate(
            4, (index) => index == 3 ? Alignment.centerLeft : Alignment.center),
        stickyColumnAlignment: Alignment.center,
        stickyLegendAlignment: Alignment.center,
      ),
      columnsTitleBuilder: (col) => Text(
        [
          LocalizedText.of(chs: '石', jpn: '石', eng: 'SQ'),
              LocalizedText.of(chs: '呼符', jpn: '呼符', eng: 'Ticket'),
              LocalizedText.of(chs: '果实', jpn: '果実', eng: 'Apple'),
              S.current.event_title
            ][col],
            textAlign: col != 3 ? TextAlign.center : null,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
      rowsTitleBuilder: (row) {
        final detail = plan.solution[row];
        return _accWithAdd(
          detail.date.toDateString(),
          '${DateFormat(DateFormat.ABBR_WEEKDAY).format(detail.date)}'
              ' ${detail.accLogin}(${detail.continuousLogin})',
        );
      },
      contentCellBuilder: (col, row) {
        final detail = plan.solution[row];
        if (col == 0) {
          return _accWithAdd(
              '${detail.accSQ}', detail.addSQ == 0 ? '' : '+${detail.addSQ}');
        } else if (col == 1) {
          return _accWithAdd('${detail.accTicket}',
              detail.addTicket == 0 ? '' : '+${detail.addTicket}');
        } else if (col == 2) {
          return _accWithAdd(
              formatNumber(detail.accApple, precision: 1),
              detail.addApple == 0.0
                  ? ''
                  : ('+' + formatNumber(detail.addApple, precision: 1)));
        } else if (col == 3) {
          Widget _wrap(
              {required Widget child,
              required VoidCallback? onTap,
              double height = _eventHeight}) {
            return InkWell(
              onTap: onTap,
              child: SizedBox(
                height: height,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: child,
                ),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final event in detail.events)
                _wrap(
                  child: Text(
                    event.localizedName,
                    textScaleFactor: 0.8,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  onTap: () {
                    SplitRoute.push(context, event.resolveDetailPage());
                  },
                ),
              for (final summon in detail.summons)
                _wrap(
                  child: RichText(
                    text: TextSpan(children: [
                      for (final svt in summon.shownServants())
                        if (svt.info.rarity >= 4)
                          WidgetSpan(
                              child: svt.iconBuilder(
                            context: context,
                            height: _summonHeight,
                            jumpToDetail: false,
                          )),
                      TextSpan(
                        text: summon.lName,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ]),
                    maxLines: 1,
                    textScaleFactor: 0.8,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    SplitRoute.push(context, SummonDetailPage(summon: summon));
                  },
                  height: _summonHeight,
                ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _accWithAdd(String acc, String add) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(acc),
        Text(add, style: Theme.of(context).textTheme.caption),
      ],
    );
  }
}
