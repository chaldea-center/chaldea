import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:fl_chart/fl_chart.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class StatisticServantTab extends StatefulWidget {
  StatisticServantTab({super.key});

  @override
  _StatisticServantTabState createState() => _StatisticServantTabState();
}

class _StatisticServantTabState extends State<StatisticServantTab> {
  late ScrollController _scrollController;

  List<int> rarityTotal = List.filled(6, 0);
  List<int> rarityOwn = List.filled(6, 0);
  List<int> rarity999 = List.filled(6, 0);
  List<bool> raritySelected = List.filled(6, true);

  FilterGroupData<int> get priorityFilter => db.settings.svtFilterData.priority;

  void _calcRarityCounts() {
    rarityTotal = List.filled(6, 0);
    rarityOwn = List.filled(6, 0);
    rarity999 = List.filled(6, 0);

    for (final svt in db.gameData.servantsNoDup.values) {
      if (!svt.isUserSvt) continue;
      rarityTotal[svt.rarity] += 1;
      if (!priorityFilter.matchOne(svt.status.priority)) {
        continue;
      }
      final stat = svt.status;
      if (stat.favorite) {
        rarityOwn[svt.rarity] += 1;
      }
      if (stat.cur.skills.every((e) => e >= 9)) {
        rarity999[svt.rarity] += 1;
      }
    }
  }

  void _calcServantClass() {
    svtClassCount = Map.fromIterable([...SvtClassX.regular, SvtClass.EXTRA], value: (_) => 0);
    for (final svt in db.gameData.servantsNoDup.values) {
      final status = db.curUser.svtStatusOf(svt.collectionNo);
      if (!status.favorite) continue;
      if (raritySelected.contains(true) && !raritySelected[svt.rarity]) {
        continue;
      }
      if (!priorityFilter.matchOne(status.priority)) continue;
      if (svtClassCount.containsKey(svt.className)) {
        svtClassCount[svt.className] = (svtClassCount[svt.className] ?? 0) + 1;
      } else {
        svtClassCount[SvtClass.EXTRA] = (svtClassCount[SvtClass.EXTRA] ?? 0) + 1;
      }
    }
    svtClassCount.removeWhere((key, value) => value <= 0);
    // print(svtClassCount);
  }

  Map<SvtClass, int> svtClassCount = {};

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
    _calcRarityCounts();
    final priority = db.settings.svtFilterData.priority;
    List<Widget> children = [
      ListTile(
        title: Text(
          S.current.priority,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing:
            Text(priority.options.isEmpty ? S.current.general_all : (priority.options.toList()..sort()).join(', ')),
      )
    ];
    children.add(pieChart());
    children.add(ListTile(
      title: Text(S.current.rarity),
      trailing: Text(S.current.svt_stat_own_total),
      // dense: true,
    ));
    children.addAll(_oneRarity(
      selected: raritySelected.every((e) => e),
      title: 'ALL',
      skillMax: Maths.sum(rarity999),
      own: Maths.sum(rarityOwn),
      total: Maths.sum(rarityTotal),
      onChanged: (v) {
        setState(() {
          raritySelected.fillRange(0, raritySelected.length, v);
        });
      },
    ));
    for (int i = rarityTotal.length - 1; i >= 0; i--) {
      children.addAll(_oneRarity(
        selected: raritySelected[i],
        title: '$kStarChar$i ${S.current.servant}',
        skillMax: rarity999[i],
        own: rarityOwn[i],
        total: rarityTotal[i],
        onChanged: (v) {
          setState(() {
            raritySelected[i] = v;
          });
        },
      ));
    }
    children.add(const SafeArea(
      child: Center(
        child: Text(
          'Red: skill >=999',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    ));
    children = divideTiles(children);
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 6),
      children: children,
    );
  }

  List<Widget> _oneRarity({
    required bool selected,
    required String title,
    required int skillMax,
    required int own,
    required int total,
    required ValueChanged<bool> onChanged,
  }) {
    return [
      CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        value: selected,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        title: Row(
          children: [
            Expanded(child: Text(title)),
            Text(
              '($skillMax) ${'$own/$total'.padLeft(7)}',
              style: kMonoStyle,
            )
          ],
        ),
      ),
      Row(
        children: [
          Expanded(
            flex: skillMax,
            child: Container(height: 8, color: Colors.red[400]),
          ),
          Expanded(
            flex: own - skillMax,
            child: Container(
              height: 8,
              color: Colors.blue,
            ),
          ),
          Expanded(
            flex: total - own,
            child: Container(height: 8, color: Colors.grey[300]),
          ),
        ],
      ),
    ];
  }

  SvtClass? selectedPie;

  List<Color> get palette => const [
        // Color(0xFFCC0000),
        Color(0xFFCC6600),
        Color(0xFFCCCC00),
        Color(0xFF66CC00),
        Color(0xFF00CC00),
        Color(0xFF00CC66),
        Color(0xFF00CCCC),
        Color(0xFF0066CC),
        Color(0xFF0000CC),
        // Color(0xFF6600CC),
        // Color(0xFFCC00CC),
        // Color(0xFFCC0066),
      ].reversed.toList();

  Widget pieChart() {
    _calcServantClass();
    int total = Maths.sum(svtClassCount.values);
    if (kIsWeb && !kPlatformMethods.rendererCanvasKit) {
      // TODO: https://github.com/flutter/flutter/issues/44572
      // https://github.com/imaNNeoFighT/fl_chart/issues/955
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('Chart is disabled on web with "html" renderer'),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        double mag = min(1, constraints.maxWidth / 350);
        if (total <= 0) return Container(height: 280 * mag);
        return SizedBox(
          height: 280 * mag,
          child: PieChart(PieChartData(
            sections: List.generate(svtClassCount.length, (index) {
              final entry = svtClassCount.entries.elementAt(index);
              return _pieSection(entry.key, entry.value, total, mag, palette[index]);
            }),
            centerSpaceRadius: 0,
            pieTouchData: PieTouchData(touchCallback: (event, pieTouchResponse) {
              if (pieTouchResponse == null) return;
              bool _needsBuild = false;
              if (event is FlTapUpEvent &&
                  pieTouchResponse.touchedSection != null &&
                  pieTouchResponse.touchedSection!.touchedSectionIndex >= 0) {
                _needsBuild = true;
              }
              if (event is FlTapUpEvent || event is FlTapCancelEvent) {
                _needsBuild = true;
              }
              final desiredTouch = event is! FlTapUpEvent && event is! FlTapCancelEvent;
              if (desiredTouch && pieTouchResponse.touchedSection != null) {
                SvtClass? _newSelected;
                int index = pieTouchResponse.touchedSection!.touchedSectionIndex;
                if (index >= 0 && index < svtClassCount.length) {
                  _newSelected = svtClassCount.keys.elementAt(index);
                } else {
                  _newSelected = null;
                }
                if (selectedPie != _newSelected) {
                  selectedPie = _newSelected;
                  _needsBuild = true;
                }
              }
              if (_needsBuild) {
                setState(() {});
              }
            }),
          )),
        );
      },
    );
  }

  PieChartSectionData _pieSection(SvtClass clsName, int count, int total, double mag, Color? color) {
    bool selected = selectedPie == clsName;
    double ratio = count / total;
    double posRatio = ratio < 0.05 ? 1.2 : 1;
    return PieChartSectionData(
      value: count.toDouble(),
      title: selected ? '$count\n(${'${(ratio * 100).toStringAsFixed(0)}%'})' : count.toString(),
      titleStyle: TextStyle(color: Colors.white, fontSize: 16 * mag, fontWeight: FontWeight.bold),
      radius: (selected ? 120 : 100) * mag,
      badgeWidget: db.getIconImage(
        clsName.icon(5),
        width: 30 * mag,
        height: 30 * mag,
      ),
      badgePositionPercentageOffset: 1 * posRatio,
      titlePositionPercentageOffset: 0.6 * posRatio,
      color: color,
    );
  }
}
