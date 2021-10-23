import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
    Key? key,
    required this.data,
    this.xFormatter,
    this.minX,
    this.maxX,
    this.minY,
    this.maxY,
    this.intervalX,
    this.intervalY,
  })  : assert(data.length > 0),
        super(key: key);

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
                    items.add(LineTooltipItem(xFormatter!(spot.x) + '\n',
                        const TextStyle(fontSize: 14),
                        children: [
                          TextSpan(
                            text: formatter(spot.x, spot.y),
                            style: TextStyle(
                              color: spot.bar.colors[0],
                              fontSize: 14,
                            ),
                          )
                        ]));
                  } else {
                    items.add(LineTooltipItem(
                      formatter(spot.x, spot.y),
                      TextStyle(
                        color: spot.bar.colors[0],
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
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            margin: 10,
            interval: intervalX,
            getTextStyles: (context, value) => const TextStyle(
              // color: Color(0xff72719b),
              // fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            getTitles: (value) {
              if (value.toInt() % 10 == 0) return value.toInt().toString();
              return '';
            },
          ),
          rightTitles: SideTitles(showTitles: true, getTitles: (v) => ''),
          topTitles: SideTitles(showTitles: true, getTitles: (v) => ''),
          leftTitles: SideTitles(
            showTitles: true,
            margin: 8,
            interval: intervalY,
            reservedSize: 36,
            getTextStyles: (context, value) => const TextStyle(fontSize: 14),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Theme.of(context).hintColor, width: 2),
            left: BorderSide(color: Theme.of(context).hintColor, width: 2),
            right: const BorderSide(color: Colors.transparent),
            top: const BorderSide(color: Colors.transparent),
          ),
        ),
        lineBarsData: List.generate(data.length, (index) {
          final datum = data[index];
          return LineChartBarData(
            isCurved: true,
            colors: [datum.color ?? colors[index % colors.length]],
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
      ),
      swapAnimationDuration: const Duration(milliseconds: 250),
    );
  }

  LineChartBarData get lineChartBarData1_3 => LineChartBarData(
        isCurved: true,
        colors: const [Color(0xff27b6fc)],
        barWidth: 8,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 2.8),
          FlSpot(3, 1.9),
          FlSpot(6, 3),
          FlSpot(10, 1.3),
          FlSpot(13, 2.5),
        ],
      );
}
