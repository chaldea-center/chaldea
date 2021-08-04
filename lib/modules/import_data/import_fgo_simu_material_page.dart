import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:flutter/scheduler.dart';

class ImportFgoSimuMaterialPage extends StatefulWidget {
  const ImportFgoSimuMaterialPage({Key? key}) : super(key: key);

  @override
  _ImportFgoSimuMaterialPageState createState() =>
      _ImportFgoSimuMaterialPageState();
}

class _ImportFgoSimuMaterialPageState extends State<ImportFgoSimuMaterialPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textEditingController;
  late TabController _tabController;

  Map<int, String> itemMapping = {};

  Map<String, int> itemResult = {};
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
        leading: BackButton(),
        titleSpacing: 0,
        title: Text('FGO Simulator - Material'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Input'),
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
                content: Text(LocalizedText.of(
                        chs: '导入fgosimulator.webcrow.jp的从者和素材数据',
                        jpn: 'fgosimulator.webcrow.jpのサーヴァントとアイテムをインポートします ',
                        eng:
                            'Import servant and item data from fgosimulator.webcrow.jp.') +
                    '\n"http://fgosimulator.webcrow.jp/Material/" -> My Chaldea -> 引継ぎコード'),
              ).showDialog(context);
            },
            icon: Icon(Icons.help),
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
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              controller: _textEditingController,
              expands: true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              toolbarOptions: const ToolbarOptions(
                  copy: true, cut: true, paste: true, selectAll: true),
              decoration: InputDecoration(
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
            ElevatedButton(onPressed: _parse, child: Text('Parse Data')),
          ],
        )
      ],
    );
  }

  Widget get servantTab {
    List<Widget> children = [];
    if (svtResult.isEmpty) children.add(Center(child: Text('Nothing yet')));
    for (final record in svtResult) {
      final svt = db.gameData.servants[record.id];
      if (svt == null) continue;
      children.add(ListTile(
        leading: svt.iconBuilder(context: context),
        title: AutoSizeText(svt.info.localizedName, maxLines: 2),
        trailing: Text(
          '${record.cur.ascension}-${record.cur.skills.join('/')}'
          ' → '
          '${record.target.ascension}-${record.target.skills.join('/')}',
          style: TextStyle(fontFamily: kMonoFont),
          textAlign: TextAlign.center,
        ),
      ));
    }
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8),
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
                  db.curUser.servants[record.id] =
                      ServantStatus(curVal: record.cur);
                  db.curPlan[record.id] = record.target;
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
    if (itemResult.isEmpty) children.add(Center(child: Text('Nothing yet')));
    itemResult.forEach((itemKey, value) {
      children.add(ListTile(
        leading: Item.iconBuilder(context: context, itemKey: itemKey),
        title: Text(Item.localizedNameOf(itemKey)),
        trailing: Text(value.toString()),
      ));
    });
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8),
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
                db.curUser.items.addAll(itemResult);
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
          int svtId = row[0];
          svtResult.add(_OneServantData(
            id: svtId,
            cur: ServantPlan(
              favorite: true,
              ascension: row[1],
              skills: [row[3], row[5], row[7]],
            ),
            target: ServantPlan(
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
    itemMapping.clear();
    final groupMapping = {
      32: 100,
      33: 110,
      11: 200,
      12: 210,
      13: 220,
      21: 300,
      22: 400,
      23: 500,
    };
    for (var item in db.gameData.items.values) {
      int group = item.id ~/ 100, numberInGroup = item.id % 100 - 1;
      int? base = groupMapping[group];
      if (base != null) {
        itemMapping[base + numberInGroup] = item.name;
      }
    }
    itemMapping[800] = Items.crystal;
    itemMapping[900] = Items.qp;
  }
}

class _OneServantData {
  int id;
  ServantPlan cur;
  ServantPlan target;

  _OneServantData({required this.id, required this.cur, required this.target});
}
