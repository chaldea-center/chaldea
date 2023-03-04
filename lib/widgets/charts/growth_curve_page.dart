import 'dart:math';

import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/modules/common/blank_page.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/charts/line_chart.dart';

class GrowthCurvePage extends StatefulWidget {
  final String title;
  final List<SimpleLineChartData<int>> data;
  final Widget? avatar;
  final int? maxX;

  const GrowthCurvePage({
    super.key,
    required this.title,
    required this.data,
    this.avatar,
    this.maxX,
  });

  GrowthCurvePage.fromCard({
    super.key,
    required this.title,
    required List<int> lvs,
    required List<int> hps,
    required List<int> atks,
    this.avatar,
    this.maxX,
  })  : assert(lvs.length == atks.length && atks.length == hps.length),
        data = [
          SimpleLineChartData(
              xx: List.generate(hps.length, (index) => index + 1),
              yy: List.of(hps),
              tooltipFormatter: (x, y) => 'HP ${y.toInt()}'),
          SimpleLineChartData(
              xx: List.generate(atks.length, (index) => index + 1),
              yy: List.of(atks),
              tooltipFormatter: (x, y) => 'ATK ${y.toInt()}'),
        ];

  @override
  _GrowthCurvePageState createState() => _GrowthCurvePageState();
}

class _GrowthCurvePageState extends State<GrowthCurvePage> {
  static const _preferredIntervals = [10, 20, 50, 100, 200, 500, 1000, 2000];

  double _resolveIntervalY() {
    int maxValue = widget.data.map((e) => e.yy.last).fold<int>(0, (p, c) => max(p, c));
    int minValue = widget.data.map((e) => e.yy.first).fold<int>(0, (p, c) => max(p, c));
    minValue = min(0, minValue);
    int interval = (maxValue - minValue) ~/ 6;
    interval = _preferredIntervals.firstWhereOrNull((e) => e > interval) ?? interval ~/ 1000 * 1000;
    return interval.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.title,
          maxLines: 1,
          minFontSize: 8,
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: BlankPage(),
            ),
          ),
          if (widget.avatar != null)
            Positioned(
              left: 72,
              top: 28,
              child: widget.avatar!,
            ),
          Positioned.fill(
            bottom: 24,
            child: LayoutBuilder(builder: (context, constraints) {
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
            }),
          ),
        ],
      ),
    );
  }
}
