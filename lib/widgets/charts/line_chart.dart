import 'dart:math';

import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';

class SimpleLineChartData<T extends num> {
  List<T> xx;
  List<T> yy;
  Color? color;
  String Function(double x, double y) tooltipFormatter;

  static String _tooltip(double x, double y) {
    return y.toInt().toString();
  }

  SimpleLineChartData({
    required this.xx,
    required this.yy,
    this.tooltipFormatter = _tooltip,
    this.color,
  }) : assert(xx.length == yy.length);

  List<T> ofAxis({required bool x}) => x ? xx : yy;
}

class SimpleLineChart<T extends num> extends StatelessWidget {
  const SimpleLineChart({
    super.key,
    required this.data,
    this.xFormatter,
    this.minX,
    this.maxX,
    this.minY,
    this.maxY,
    this.intervalX,
    this.intervalY,
  }) : assert(data.length > 0);

  static List<Color> get colors => [
        Colors.blue,
        Colors.red,
        Colors.green,
        Colors.cyan,
        Colors.pink,
        Colors.yellow,
        Colors.purple,
        // Colors.black,
        // Colors.white,
      ];

  Color getColor(int index) {
    return data[index].color ?? colors[index % colors.length];
  }

  final List<SimpleLineChartData<T>> data;
  final String Function(double x)? xFormatter; //only the first one
  final double? minX;
  final double? maxX;
  final double? minY;
  final double? maxY;
  final double? intervalX;
  final double? intervalY;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
              tooltipBgColor:
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
              // tooltipBgColor: Theme.of(context).hintColor.withOpacity(0.5),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (spots) {
                List<LineTooltipItem> items = [];
                for (int index = 0; index < spots.length; index++) {
                  final spot = spots[index];
                  final formatter = data[spot.barIndex].tooltipFormatter;
                  if (index == 0 && xFormatter != null) {
                    items.add(LineTooltipItem('${xFormatter!(spot.x)}\n',
                        const TextStyle(fontSize: 14),
                        children: [
                          TextSpan(
                            text: formatter(spot.x, spot.y),
                            style: TextStyle(
                              color: spot.bar.color,
                              fontSize: 14,
                            ),
                          )
                        ]));
                  } else {
                    items.add(LineTooltipItem(
                      formatter(spot.x, spot.y),
                      TextStyle(
                        color: spot.bar.color,
                        // fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ));
                  }
                }
                return items;
              }),
        ),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: intervalY,
              reservedSize: 48,
              getTitlesWidget: (value, titleMeta) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8, right: 4),
                  child: AutoSizeText(
                    titleMeta.formattedValue,
                    maxLines: 1,
                    maxFontSize: 14,
                    minFontSize: 6,
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: intervalX,
              getTitlesWidget: (value, titleMeta) {
                return Padding(
                  // You can use any widget here
                  padding: const EdgeInsets.only(top: 4),
                  child: AutoSizeText(
                    titleMeta.formattedValue,
                    maxLines: 1,
                    maxFontSize: 14,
                    minFontSize: 6,
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 16,
              getTitlesWidget: (_, __) => const Text(''),
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 16,
              getTitlesWidget: (_, __) => const Text(''),
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Theme.of(context).hintColor, width: 2),
        ),
        lineBarsData: List.generate(data.length, (index) {
          final datum = data[index];
          return LineChartBarData(
            isCurved: true,
            color: datum.color ?? colors[index % colors.length],
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            spots: [
              for (int index = 0;
                  index < min(datum.xx.length, datum.yy.length);
                  index++)
                FlSpot(
                  datum.xx[index].toDouble(),
                  datum.yy[index].toDouble(),
                ),
            ],
          );
        }),
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        clipData: FlClipData.horizontal(),
      ),
      swapAnimationDuration: const Duration(milliseconds: 250),
    );
  }
}
