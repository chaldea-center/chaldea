import 'dart:math';

import 'package:flutter/material.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class SQTableTab extends StatefulWidget {
  SQTableTab({super.key});

  @override
  _SQTableTabState createState() => _SQTableTabState();
}

const double _eventHeight = 24;
const double _summonHeight = 36;

class _SQTableTabState extends State<SQTableTab> {
  SaintQuartzPlan get plan => db.curUser.saintQuartzPlan;
  final PaginatorController _controller = PaginatorController();
  late final _PlanDataSource source;

  @override
  void initState() {
    super.initState();
    source = _PlanDataSource(context, plan);
    plan.notifier.addListener(source.notify);
  }

  @override
  void dispose() {
    super.dispose();
    source.dispose();
    plan.notifier.removeListener(source.notify);
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            overscroll: false,
            physics: const ClampingScrollPhysics(),
          ),
          child: dataTable(),
        ),
      ),
    );
  }

  Widget dataTable() {
    return PaginatedDataTable2(
      columnSpacing: 0,
      wrapInCard: false,
      renderEmptyRowsInTheEnd: false,
      horizontalMargin: 0,
      autoRowsToHeight: false,
      rowsPerPage: 30,
      availableRowsPerPage: const [30, 60, 120, 180],
      minWidth: 800,
      headingRowHeight: 36,
      headingRowColor: MaterialStateColor.resolveWith((states) => Theme.of(context).highlightColor),
      fit: FlexFit.tight,
      border: TableBorder(
        bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        verticalInside: BorderSide(color: Colors.grey[300]!, width: 0.5),
        horizontalInside: BorderSide(color: Colors.grey[300]!, width: 0.5),
      ),
      onRowsPerPageChanged: (value) {
        // enable rowsPerPage dropdown
      },
      showFirstLastButtons: true,
      initialFirstRowIndex: 0,
      controller: _controller,
      // hidePaginator: true,
      columns: [
        DataColumn2(label: Center(child: Text(S.current.date, textAlign: TextAlign.center)), fixedWidth: 120),
        DataColumn2(label: Center(child: Text(S.current.sq_short, textAlign: TextAlign.center)), fixedWidth: 50),
        DataColumn2(
            label: Center(child: Text(S.current.summon_ticket_short, textAlign: TextAlign.center)), fixedWidth: 50),
        DataColumn2(label: Center(child: Text(S.current.item_apple, textAlign: TextAlign.center)), fixedWidth: 50),
        DataColumn2(label: Text(' ${S.current.event}')),
      ],
      empty: const SizedBox.shrink(),
      source: source,
    );
  }
}

class _PlanDataSource extends DataTableSource {
  final BuildContext context;
  final SaintQuartzPlan plan;

  _PlanDataSource(this.context, this.plan);

  void notify() {
    notifyListeners();
  }

  @override
  int get rowCount => plan.solution.length;
  @override
  bool isRowCountApproximate = false;
  @override
  int selectedRowCount = 0;

  @override
  DataRow getRow(int index, [Color? color]) {
    final detail = plan.solution[index];
    final height = max(48, detail.events.length * _eventHeight + detail.summons.length * _summonHeight + 4);
    List<DataCell> cells = [
      DataCell(_accWithAdd(
        detail.date.toDateString(),
        '${DateFormat(DateFormat.ABBR_WEEKDAY).format(detail.date)}'
        ' ${detail.accLogin}(${detail.continuousLogin})',
      )),
      DataCell(_accWithAdd('${detail.accSQ}', detail.addSQ == 0 ? '' : '+${detail.addSQ}')),
      DataCell(_accWithAdd('${detail.accTicket}', detail.addTicket == 0 ? '' : '+${detail.addTicket}')),
      DataCell(_accWithAdd(detail.accApple.format(compact: false, precision: 1),
          detail.addApple == 0.0 ? '' : ('+${detail.addApple.format(compact: false, precision: 1)}'))),
    ];

    cells.add(DataCell(getEvents(detail)));
    return DataRow2(
      specificRowHeight: height.toDouble(),
      cells: cells,
      color: index.isOdd
          ? MaterialStateColor.resolveWith((states) => Theme.of(context).highlightColor.withAlpha(32))
          : null,
    );
  }

  Widget _accWithAdd(String acc, String add) {
    return Center(
      child: Text.rich(
        TextSpan(children: [
          TextSpan(text: acc),
          if (add.trim().isNotEmpty) TextSpan(text: '\n$add', style: Theme.of(context).textTheme.bodySmall),
        ]),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget getEvents(SQDayDetail detail) {
    Widget _wrap({required Widget child, required VoidCallback? onTap, double height = _eventHeight}) {
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

    List<Widget> children = [
      for (final event in detail.events)
        _wrap(
          child: Text(
            event.shownName,
            textScaler: const TextScaler.linear(0.8),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          onTap: event.routeTo,
        ),
      for (final summon in detail.summons)
        _wrap(
          child: Text.rich(
            TextSpan(children: [
              for (final svt in summon.shownSvts)
                WidgetSpan(
                    child: GameCardMixin.cardIconBuilder(
                  icon: db.gameData.servantsNoDup[svt]?.borderedIcon,
                  context: context,
                  height: _summonHeight,
                )),
              TextSpan(
                text: summon.lName.l,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ]),
            maxLines: 1,
            textScaler: const TextScaler.linear(0.8),
            overflow: TextOverflow.ellipsis,
          ),
          onTap: summon.routeTo,
          height: _summonHeight,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
