import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../models/models.dart';

class ImportFgoSimuMaterialPage extends StatefulWidget {
  ImportFgoSimuMaterialPage({Key? key}) : super(key: key);

  @override
  _ImportFgoSimuMaterialPageState createState() =>
      _ImportFgoSimuMaterialPageState();
}

class _ImportFgoSimuMaterialPageState extends State<ImportFgoSimuMaterialPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textEditingController;
  late TabController _tabController;

  Map<int, int> itemMapping = {};

  Map<int, int> itemResult = {};
  List<_OneServantData> svtResult = [];

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
    parseItemMapping();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const AutoSizeText('FGO Simulator - Material', maxLines: 1),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Input'),
            Tab(text: S.current.servant),
            Tab(text: S.current.item)
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              SimpleCancelOkDialog(
                title: Text(S.current.help),
                scrollable: true,
                content: const Text(
                    'Import servant and item data from fgosimulator.webcrow.jp.'
                    '\n\n"http://fgosimulator.webcrow.jp/Material/" -> My Chaldea -> 引継ぎコード'),
              ).showDialog(context);
            },
            icon: const Icon(Icons.help),
            tooltip: S.current.help,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [inputTab, servantTab, itemTab],
      ),
    );
  }

  Widget get inputTab {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              controller: _textEditingController,
              expands: true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              toolbarOptions: const ToolbarOptions(
                  copy: true, cut: true, paste: true, selectAll: true),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                helperText:
                    'Copy servant or item data from fgosimulator.webcrow.jp',
                helperMaxLines: 5,
              ),
            ),
          ),
        ),
        kDefaultDivider,
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _parse, child: const Text('Parse Data')),
          ],
        )
      ],
    );
  }

  Widget get servantTab {
    List<Widget> children = [];
    if (svtResult.isEmpty) {
      children.add(const Center(child: Text('Nothing yet')));
    }
    svtResult.sort((a, b) => SvtFilterData.compare(a.svt, b.svt,
        keys: [SvtCompare.rarity, SvtCompare.no], reversed: [true, false]));
    Widget _getSummary(SvtPlan plan) {
      String text = '${plan.ascension}-';
      text += plan.skills.map((e) => e.toString().padLeft(2)).join('/');
      return Center(
        child: AutoSizeText(
          text,
          maxLines: 1,
          minFontSize: 2,
          style: kMonoStyle,
        ),
      );
    }

    for (final record in svtResult) {
      children.add(ListTile(
        leading: record.svt.iconBuilder(context: context),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _getSummary(record.cur)),
            const Text(' → '),
            Expanded(child: _getSummary(record.target)),
          ],
        ),
      ));
    }
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) => children[index],
            separatorBuilder: (_, __) => const Divider(
              height: 2,
              thickness: 0.5,
              indent: 64,
            ),
            itemCount: children.length,
          ),
        ),
        kDefaultDivider,
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                svtResult.forEach((record) {
                  db2.curUser.servants[record.svt.collectionNo] =
                      SvtStatus(cur: record.cur);
                  db2.curPlan[record.svt.collectionNo] = record.target;
                });
                EasyLoading.showSuccess('Import ${svtResult.length} servants');
              },
              child: Text(S.current.import_data),
            ),
          ],
        )
      ],
    );
  }

  Widget get itemTab {
    List<Widget> children = [];
    if (itemResult.isEmpty) {
      children.add(const Center(child: Text('Nothing yet')));
    }
    itemResult.forEach((itemId, value) {
      children.add(ListTile(
        leading: Item.iconBuilder(context: context, item: null, itemId: itemId),
        title: Text(Item.getName(itemId)),
        trailing: Text(value.toString()),
      ));
    });
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) => children[index],
            separatorBuilder: (_, __) => const Divider(
              height: 2,
              thickness: 0.5,
              indent: 64,
            ),
            itemCount: children.length,
          ),
        ),
        kDefaultDivider,
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                db2.curUser.items.addAll(itemResult);
                EasyLoading.showSuccess('Import ${itemResult.length} items');
              },
              child: Text(S.current.import_data),
            ),
          ],
        )
      ],
    );
  }

  void _parse() {
    try {
      final text = _textEditingController.text.trim();
      var data = jsonDecode(text);
      if (data is List) {
        // svt: [8,  0,4,  10,10,  8,10,  8,10,  1,0]
        //       0   1 2   3  4    5 6    7 8    9 10
        svtResult.clear();
        for (final List row in data) {
          if (row.length < 9) continue;
          int? svtId = db2.gameData.wiki.webcrowMapping[row[0]];
          // svtId ??= row[0] < 149 ? row[0] : row[0] + 5;
          final svt = db2.gameData.servants[svtId];
          if (svt == null) continue;
          svtResult.add(_OneServantData(
            svt: svt,
            cur: SvtPlan(
              favorite: true,
              ascension: row[1],
              skills: [row[3], row[5], row[7]],
            ),
            target: SvtPlan(
              favorite: true,
              ascension: row[2],
              skills: [row[4], row[6], row[8]],
            ),
          ));
        }

        setState(() {});
        SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
          _tabController.index = 1;
        });
      } else if (data is Map) {
        // item
        itemResult.clear();
        data.forEach((key, value) {
          int? srcId = int.tryParse(key);
          if (srcId == null || itemMapping[srcId] == null || value is! int) {
            return;
          }
          itemResult[itemMapping[srcId]!] = value;
        });

        setState(() {});
        SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
          _tabController.index = 2;
        });
      }
    } catch (e, s) {
      logger.e('parse fgo_simu_material failed', e, s);
      EasyLoading.showError('Invalid Format');
    }
  }

  void parseItemMapping() {
    Map<ItemBGType, List<Item>> mItems = {
      ItemBGType.bronze: [],
      ItemBGType.silver: [],
      ItemBGType.gold: [],
    };
    for (final item in db2.gameData.items.values) {
      if (item.id >= 6500 && item.id < 6900) {
        mItems[item.background]!.add(item);
      }
    }
    for (final group in mItems.values) {
      group.sort2((e) => e.priority);
    }

    itemMapping = {
      for (int i = 0; i < 7; i++) ...{
        100 + i: 7001 + i,
        110 + i: 7101 + i,
        200 + i: 6001 + i,
        210 + i: 6101 + i,
        220 + i: 6201 + i,
      },
      800: 6999,
      900: Items.qpId
    };
    // 300-bronze, 400-silver, 500-gold
    final rarityBaseMap = {
      ItemBGType.bronze: 300,
      ItemBGType.silver: 400,
      ItemBGType.gold: 500,
    };
    for (final bg in rarityBaseMap.keys) {
      final group = mItems[bg]!;
      group.sort2((e) => e.priority);
      int base = rarityBaseMap[group.first.background]!;
      for (int i = 0; i < group.length; i++) {
        itemMapping[base + i] = group[i].id;
      }
    }
  }
}

class _OneServantData {
  Servant svt;
  SvtPlan cur;
  SvtPlan target;

  _OneServantData({required this.svt, required this.cur, required this.target});
}
