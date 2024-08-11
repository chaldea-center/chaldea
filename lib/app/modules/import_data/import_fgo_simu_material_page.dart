import 'dart:convert';

import 'package:flutter/scheduler.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../models/models.dart';

class ImportFgoSimuMaterialPage extends StatefulWidget {
  ImportFgoSimuMaterialPage({super.key});

  @override
  _ImportFgoSimuMaterialPageState createState() => _ImportFgoSimuMaterialPageState();
}

class _ImportFgoSimuMaterialPageState extends State<ImportFgoSimuMaterialPage> with SingleTickerProviderStateMixin {
  late TextEditingController _textEditingController;
  late TabController _tabController;

  Map<int, int> itemMapping = {};

  Map<int, int> itemResult = {};
  List<_OneServantData> svtResult = [];
  final List _ignoredItemIds = [];
  final List _ignoredSvtIds = [];

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
        bottom: FixedHeight.tabBar(TabBar(
          controller: _tabController,
          tabs: [const Tab(text: 'Input'), Tab(text: S.current.servant), Tab(text: S.current.item)],
        )),
        actions: [
          IconButton(
            onPressed: () {
              SimpleCancelOkDialog(
                title: Text(S.current.help),
                scrollable: true,
                content: const Text('Import servant and item data from fgosimulator'
                    '\n\n"https://fgosim.github.io/Material/" -> My Chaldea -> 引継ぎコード'),
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
            child: TextFormField(
              controller: _textEditingController,
              expands: true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              contextMenuBuilder: (context, editableTextState) =>
                  AdaptiveTextSelectionToolbar.editableText(editableTextState: editableTextState),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                helperText: 'Copy servant or item data from fgosimulator(webcrow)',
                helperMaxLines: 5,
              ),
            ),
          ),
        ),
        kDefaultDivider,
        SafeArea(
          child: OverflowBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _parse,
                child: const Text('Parse Data'),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget get servantTab {
    List<Widget> children = [];
    if (svtResult.isEmpty) {
      children.add(const Center(child: Text('Nothing yet')));
    }
    if (_ignoredSvtIds.isNotEmpty) {
      children.add(ListTile(
        title: Text('${S.current.ignore}: $_ignoredSvtIds'),
      ));
    }

    svtResult.sort((a, b) =>
        SvtFilterData.compare(a.svt, b.svt, keys: [SvtCompare.rarity, SvtCompare.no], reversed: [true, false]));
    Widget _getSummary(SvtPlan plan) {
      String text = '${plan.ascension}-';
      text += plan.skills.map((e) => e.toString().padLeft(2)).join('/');
      text += '\n';
      text += plan.appendSkills.map((e) => e.toString().padLeft(2)).join('/');
      return Center(
        child: AutoSizeText(
          text,
          maxLines: 2,
          minFontSize: 2,
          style: kMonoStyle,
          maxFontSize: 14,
          textAlign: TextAlign.end,
        ),
      );
    }

    for (final record in svtResult) {
      children.add(ListTile(
        leading: record.svt.iconBuilder(context: context),
        horizontalTitleGap: 4,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showId(realId: record.svt.collectionNo, webcrowId: record.webcrowId),
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
        SafeArea(
          child: OverflowBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  for (final record in svtResult) {
                    db.curUser.servants[record.svt.collectionNo] = SvtStatus(cur: record.cur);
                    db.curSvtPlan[record.svt.collectionNo] = record.target;
                  }
                  db.itemCenter.init();
                  db.saveUserData();
                  EasyLoading.showSuccess('Import ${svtResult.length} servants');
                },
                child: Text(S.current.import_data),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget get itemTab {
    List<Widget> children = [];
    if (itemResult.isEmpty) {
      children.add(const Center(child: Text('Nothing yet')));
    }
    if (_ignoredItemIds.isNotEmpty) {
      children.add(ListTile(
        title: Text('${S.current.ignore}: $_ignoredItemIds'),
      ));
    }
    final _itemMappingReverse = itemMapping.map((key, value) => MapEntry(value, key));
    itemResult.forEach((itemId, value) {
      children.add(ListTile(
        leading: Item.iconBuilder(context: context, item: null, itemId: itemId),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showId(realId: itemId, webcrowId: _itemMappingReverse[itemId]),
            const SizedBox(width: 8),
            Text(Item.getName(itemId)),
          ],
        ),
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
        SafeArea(
          child: OverflowBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  db.curUser.items.addAll(itemResult);
                  EasyLoading.showSuccess('Import ${itemResult.length} items');
                },
                child: Text(S.current.import_data),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _showId({required int realId, required dynamic webcrowId, double width = 36}) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: width),
      child: Text.rich(
        TextSpan(
          text: realId.toString(),
          children: [
            TextSpan(
              text: '\n($webcrowId)',
              style: const TextStyle(fontSize: 12),
            )
          ],
        ),
        textAlign: TextAlign.center,
        textScaler: const TextScaler.linear(0.9),
      ),
    );
  }

  void _parse() {
    try {
      final text = _textEditingController.text.trim();
      if (text.isEmpty) {
        return;
      }
      var data = jsonDecode(text);
      if (data is List) {
        // svt: [8,  0,4,  10,10,  8,10,  8,10,  1,0]
        //       0   1 2   3  4    5 6    7 8    9 10
        // [235 ,0,4, 1,1, 1,2, 1,3, <1,0>, 4,5, 5,6, 6,7]
        //  0    1 2  3 4  5 6  7 8         11-12 13-14 15-16
        _ignoredSvtIds.clear();
        svtResult.clear();
        for (final List row in data) {
          final int webcrowId = row[0];
          int? svtId = db.gameData.wiki.webcrowMapping[webcrowId];
          if (webcrowId < 149) {
            svtId ??= webcrowId;
          }
          final svt = db.gameData.servantsNoDup[svtId];
          if (svt == null || row.length < 9) {
            _ignoredSvtIds.add(webcrowId);
            continue;
          }
          if (row.length < 17) {
            row.addAll(List.generate(17 - row.length, (index) => 0));
          }
          for (int start in [11, 13, 15]) {
            final from = row[start], to = row[start + 1];
            if (from <= 1 && to <= 1) {
              row[start] = row[start + 1] = 0;
            }
          }

          svtResult.add(_OneServantData(
            webcrowId: webcrowId,
            svt: svt,
            cur: SvtPlan(
              favorite: true,
              ascension: row[1],
              skills: [row[3], row[5], row[7]],
              appendSkills: [row[11], row[13], row[15]],
            ),
            target: SvtPlan(
              favorite: true,
              ascension: row[2],
              skills: [row[4], row[6], row[8]],
              appendSkills: [row[12], row[14], row[16]],
            ),
          ));
        }

        setState(() {});
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          _tabController.index = 1;
        });
      } else if (data is Map) {
        // item
        _ignoredItemIds.clear();
        itemResult.clear();
        data.forEach((key, value) {
          int? srcId = int.tryParse(key);
          if (srcId == null || itemMapping[srcId] == null || value is! int) {
            _ignoredItemIds.add(key);
            return;
          }
          itemResult[itemMapping[srcId]!] = value;
        });

        setState(() {});
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
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
    for (final item in db.gameData.items.values) {
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
      if (group.isEmpty) continue;
      int base = rarityBaseMap[group.first.background]!;
      for (int i = 0; i < group.length; i++) {
        itemMapping[base + i] = group[i].id;
      }
    }
  }
}

class _OneServantData {
  int webcrowId;
  Servant svt;
  SvtPlan cur;
  SvtPlan target;

  _OneServantData({required this.webcrowId, required this.svt, required this.cur, required this.target});
}
