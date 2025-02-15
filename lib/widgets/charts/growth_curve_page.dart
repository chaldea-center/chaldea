import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_table_2/data_table_2.dart';

import 'package:chaldea/app/modules/common/blank_page.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/charts/line_chart.dart';
import 'package:chaldea/widgets/widgets.dart';

class GrowthCurvePage extends StatefulWidget {
  final String title;
  final List<SimpleLineChartData<int>> data;
  final Widget? avatar;
  final int? maxX;

  const GrowthCurvePage({super.key, required this.title, required this.data, this.avatar, this.maxX});

  GrowthCurvePage.fromCard({
    super.key,
    required this.title,
    required List<int> lvs,
    required List<int> hps,
    required List<int> atks,
    this.avatar,
    this.maxX,
  }) : assert(lvs.length == atks.length && atks.length == hps.length),
       data = [
         SimpleLineChartData(
           xx: List.generate(hps.length, (index) => index + 1),
           yy: List.of(hps),
           tooltipFormatter: (x, y) => 'HP ${y.toInt()}',
         ),
         SimpleLineChartData(
           xx: List.generate(atks.length, (index) => index + 1),
           yy: List.of(atks),
           tooltipFormatter: (x, y) => 'ATK ${y.toInt()}',
         ),
       ];

  @override
  _GrowthCurvePageState createState() => _GrowthCurvePageState();
}

class _GrowthCurvePageState extends State<GrowthCurvePage> with SingleTickerProviderStateMixin {
  static const _preferredIntervals = [10, 20, 50, 100, 200, 500, 1000, 2000];

  late final _tabController = TabController(length: 2, vsync: this);

  double _resolveIntervalY() {
    int maxValue = widget.data.map((e) => e.yy.last).fold<int>(0, (p, c) => max(p, c));
    int minValue = widget.data.map((e) => e.yy.first).fold<int>(0, (p, c) => max(p, c));
    minValue = min(0, minValue);
    int interval = (maxValue - minValue) ~/ 6;
    interval = _preferredIntervals.firstWhereOrNull((e) => e > interval) ?? interval ~/ 1000 * 1000;
    return interval.toDouble();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(widget.title, maxLines: 1, minFontSize: 8),
        bottom: FixedHeight.tabBar(
          TabBar(controller: _tabController, tabs: const [Tab(text: 'Chart'), Tab(text: 'Table')]),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [chartTab, tableTab],
      ),
    );
  }

  Widget get chartTab {
    return Stack(
      children: [
        const Positioned.fill(child: Opacity(opacity: 0.1, child: BlankPage())),
        if (widget.avatar != null) Positioned(left: 72, top: 28, child: widget.avatar!),
        Positioned.fill(
          bottom: 24,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SafeArea(
                child: SimpleLineChart(
                  data: widget.data,
                  minX: 0,
                  maxX: widget.maxX?.toDouble(),
                  minY: 0,
                  intervalX: constraints.maxWidth > 450 ? 10 : 20,
                  intervalY: _resolveIntervalY(),
                  xFormatter: (v) => 'Lv.${v.toInt()}',
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _tableAscending = true;
  Widget get tableTab {
    if (widget.data.length != 2) {
      return const Center(child: Text('Wrong format'));
    }
    final hps = widget.data[0], atks = widget.data[1];
    List<int> indices = List.generate(hps.xx.length, (index) => index);
    if (!_tableAscending) indices = indices.reversed.toList();

    void _onSort(int _, bool ascending) {
      setState(() {
        _tableAscending = !_tableAscending;
      });
    }

    return DataTable2(
      dataRowHeight: 36,
      headingRowDecoration: BoxDecoration(color: Theme.of(context).cardColor),
      headingRowHeight: 42,
      columns: [
        DataColumn2(label: const Text('Lv'), numeric: true, onSort: _onSort, size: ColumnSize.S),
        DataColumn2(label: const Text("ATK"), numeric: true, onSort: _onSort, size: ColumnSize.L),
        DataColumn2(label: const Text("HP"), numeric: true, onSort: _onSort, size: ColumnSize.L),
      ],
      rows:
          indices.map((index) {
            final lv = hps.xx[index], hp = hps.yy[index], atk = atks.yy.getOrNull(index);
            final style = lv % 10 == 0 ? TextStyle(color: Theme.of(context).colorScheme.primaryContainer) : null;
            Text _text(int? s) =>
                Text(s?.format(compact: false, groupSeparator: ',') ?? "", style: style, textAlign: TextAlign.center);
            return DataRow2(cells: [DataCell(_text(lv)), DataCell(_text(atk)), DataCell(_text(hp))]);
          }).toList(),
    );
  }
}
