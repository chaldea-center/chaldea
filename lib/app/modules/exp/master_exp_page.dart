import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_table_2/data_table_2.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/region_based.dart';

class MasterExpPage extends StatefulWidget {
  const MasterExpPage({super.key});

  @override
  State<MasterExpPage> createState() => _MasterExpPageState();
}

class _MasterExpPageState extends State<MasterExpPage>
    with RegionBasedState<Map<int, MasterUserLvDetail>, MasterExpPage> {
  Map<int, MasterUserLvDetail> get userExps => data!;

  @override
  void initState() {
    super.initState();
    region = Region.jp;
    doFetchData();
  }

  @override
  Future<Map<int, MasterUserLvDetail>?> fetchData(Region? r, {Duration? expireAfter}) async {
    if (r == Region.jp) {
      return db.gameData.constData.userLevel;
    } else {
      return AtlasApi.exportedData(
        'NiceUserLevel',
        (json) =>
            (json as Map).map((key, value) => MapEntry(int.parse(key), MasterUserLvDetail.fromJson(Map.from(value)))),
        region: r ?? Region.jp,
        expireAfter: expireAfter,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Master Level"), actions: [dropdownRegion()]),
      body: buildBody(context),
    );
  }

  @override
  Widget buildContent(BuildContext context, Map<int, MasterUserLvDetail> userExps) {
    final lvs = userExps.keys.toList();
    lvs.sort((a, b) => b - a);
    return DataTable2(
      fixedTopRows: 1,
      columnSpacing: 8,
      headingRowHeight: 36,
      horizontalMargin: 8,
      // smRatio: 0.5,
      lmRatio: 2,
      columns: [
        DataColumn2(label: text('Lv.')),
        DataColumn2(label: text('Exp'), size: ColumnSize.L),
        DataColumn2(label: text('AP')),
        DataColumn2(label: text('Cost')),
        DataColumn2(label: text('Friend')),
        DataColumn2(label: text('Gift')),
      ],
      rows: [for (final lv in lvs) buildRow(lv, userExps[lv]!)],
    );
  }

  DataRow buildRow(int lv, MasterUserLvDetail detail) {
    final prevExp = userExps[lv - 1]?.requiredExp;
    final addExp = prevExp == null ? null : detail.requiredExp - prevExp;
    return DataRow(
      cells: [
        DataCell(text(lv.toString())),
        DataCell(
          Center(
            child: AutoSizeText.rich(
              TextSpan(
                text: fmtExp(detail.requiredExp),
                children: addExp == null
                    ? null
                    : [
                        TextSpan(
                          text: '\n+${fmtExp(addExp)}',
                          style: TextStyle(
                            // fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
              ),
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              minFontSize: 6,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataCell(text(detail.maxAp.toString())),
        DataCell(text(detail.maxCost.toString())),
        DataCell(text(detail.maxFriend.toString())),
        DataCell(detail.gift == null ? const SizedBox.shrink() : detail.gift!.iconBuilder(context: context, width: 32)),
      ],
    );
  }

  Widget text(String v) {
    return Center(
      child: Text(v, style: const TextStyle(fontSize: 14), textAlign: TextAlign.center),
    );
  }

  String fmtExp(int v) {
    return v.format(compact: false, groupSeparator: ',');
  }
}
