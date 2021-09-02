import 'package:chaldea/components/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class SQTableTab extends StatefulWidget {
  const SQTableTab({Key? key}) : super(key: key);

  @override
  _SQTableTabState createState() => _SQTableTabState();
}

class _SQTableTabState extends State<SQTableTab> {
  late ScrollControllers _scrollControllers;

  SaintQuartzPlan get plan => db.curUser.saintQuartzPlan;

  final _tableKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _scrollControllers = ScrollControllers();
  }

  @override
  Widget build(BuildContext context) {
    return StickyHeadersTable(
      key: _tableKey,
      scrollControllers: _scrollControllers,
      columnsLength: 4,
      rowsLength: plan.solution.length,
      legendCell: Text(LocalizedText.of(chs: '日期', jpn: '日付', eng: 'Date')),
      cellDimensions: CellDimensions.variableColumnWidth(
          columnWidths: [50, 50, 50, 500],
          contentCellHeight: 48,
          stickyLegendWidth: 120,
          stickyLegendHeight: 36),
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
          return Text(
            detail.events.join('\n'),
            textScaleFactor: 0.8,
            overflow: TextOverflow.fade,
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
