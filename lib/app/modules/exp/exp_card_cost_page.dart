import 'dart:math';

import 'package:flutter/services.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/filter_group.dart';

class ExpCardCostPage extends StatefulWidget {
  ExpCardCostPage({super.key});

  @override
  _ExpCardCostPageState createState() => _ExpCardCostPageState();
}

class _ExpCardCostPageState extends State<ExpCardCostPage> {
  int expCardRarity = 4;
  bool sameClass = true;

  late TextEditingController _startController;
  late TextEditingController _endController;
  late TextEditingController _nextController;

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController(text: data.startLv.toString());
    _endController = TextEditingController(text: data.endLv.toString());
    _nextController = TextEditingController(text: data.next.toString());
  }

  @override
  void dispose() {
    super.dispose();
    _startController.dispose();
    _endController.dispose();
    _nextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data.calculate(expCardRarity: expCardRarity, sameClass: sameClass);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.exp_card_title),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       SimpleCancelOkDialog(
        //         scrollable: true,
        //         title: Text(S.current.help),
        //         content: const Text('Help messages'),
        //       ).showDialog(context);
        //     },
        //     icon: const Icon(Icons.help_outline),
        //     tooltip: S.current.help,
        //   ),
        // ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: selector,
          ),
          kDefaultDivider,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterGroup<int>(
                options: const [3, 4, 5],
                values: FilterRadioData.nonnull(expCardRarity),
                combined: true,
                optionBuilder: (v) => Text('EXP$v'),
                onFilterChanged: (v, _) {
                  expCardRarity = v.radioValue ?? expCardRarity;
                  setState(() {});
                },
              ),
              CheckboxWithLabel(
                value: sameClass,
                onChanged: (v) => setState(() {
                  sameClass = v ?? sameClass;
                }),
                label: Text(S.current.exp_card_same_class),
              ),
            ],
          ),
          kDefaultDivider,
          stageCostList,
        ],
      ),
    );
  }

  ExpUpData data = ExpUpData();

  Widget get selector {
    Widget _oneGroup(String text, List<Widget> children) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(text),
          const SizedBox(width: 4),
          ...children,
        ],
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      children: [
        _oneGroup(S.current.exp_card_plan_lv, [
          SizedBox(
            width: 48,
            child: TextFormField(
              controller: _startController,
              decoration: const InputDecoration(
                counter: SizedBox(),
                isDense: true,
              ),
              maxLength: 3,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (s) {
                _onChanged();
                setState(() {});
              },
            ),
          ),
          const Text(' → '),
          // Text(' ${data.startLv} -> ${data.endLv} '),
          SizedBox(
            width: 48,
            child: TextFormField(
              controller: _endController,
              decoration: const InputDecoration(
                counter: SizedBox(),
                isDense: true,
              ),
              maxLength: 3,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (s) {
                _onChanged();
                setState(() {});
              },
            ),
          ),
        ]),
        _oneGroup(S.current.servant, [
          DropdownButton<int>(
            value: data.rarity,
            items: List.generate(
              6,
              (index) => DropdownMenuItem(
                value: 5 - index,
                child: Text('${5 - index}$kStarChar'),
              ),
            ),
            onChanged: (v) => setState(() {
              data.rarity = v ?? data.rarity;
            }),
            itemHeight: null,
            isDense: true,
          ),
        ]),
        _oneGroup(S.current.exp_card_plan_next, [
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: _nextController,
              decoration: const InputDecoration(
                counter: SizedBox(),
                isDense: true,
              ),
              // maxLength: ,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (s) {
                _onChanged();
                setState(() {});
              },
            ),
          ),
        ]),
      ],
    );
  }

  void _onChanged() {
    int? a = int.tryParse(_startController.text),
        b = int.tryParse(_endController.text);
    if (a != null && a >= 1 && a <= 120) {
      data.startLv = a;
    }
    if (b != null && b >= 1 && b <= 120) {
      data.endLv = b;
    }
    data.endLv = max(data.startLv, data.endLv);
    data.next = max(0, int.tryParse(_nextController.text) ?? 0);
  }

  Widget _itemIcon(int? itemId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CachedImage(
        imageUrl: itemId == null ? null : Item.getIcon(itemId, bordered: true),
        width: 132 * 0.25,
        height: 144 * 0.25,
      ),
    );
  }

  Widget get stageCostList {
    Color? headerColor = Theme.of(context).highlightColor;
    List<TableRow> rows = [
      TableRow(
        decoration: BoxDecoration(color: headerColor),
        children: [
          const Center(child: Text('...')),
          _itemIcon(9770000 + expCardRarity * 100),
          _itemIcon(Items.qpId),
          _itemIcon(Items.grailId),
          _itemIcon(db.gameData.servantsNoDup[1]?.coin?.item.id),
        ],
      )
    ];
    Widget _valToWidget(String val, [bool header = false]) {
      if (val == '0' || val.isEmpty) {
        return const SizedBox();
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AutoSizeText(
            val,
            style: TextStyle(
              fontWeight: header ? FontWeight.bold : null,
            ),
            maxLines: 1,
          ),
        ),
      );
    }

    for (int index = 0; index < data.stageNames.length; index++) {
      rows.add(TableRow(
        decoration: index == 0 ? BoxDecoration(color: headerColor) : null,
        children: [
          _valToWidget(data.stageNames[index], index == 0),
          _valToWidget(data.expStages[index].toString(), index == 0),
          _valToWidget(data.qpStages[index].format(), index == 0),
          _valToWidget(data.grailStages[index].format(), index == 0),
          _valToWidget(data.coinStages[index].format(), index == 0),
        ],
      ));
    }
    //2 1 1 1 2 1
    return Table(
      border: TableBorder(horizontalInside: Divider.createBorderSide(context)),
      defaultColumnWidth: const FlexColumnWidth(1),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(2),
        2: FlexColumnWidth(1.5),
      },
      children: rows,
    );
  }
}

class ExpUpData {
  int rarity;

  int get rarity2 => rarity == 0 ? 2 : rarity;

  int startLv;
  int endLv;
  int next;

  List<String> stageNames = [];
  List<int> qpStages = [];
  List<int> expStages = [];
  List<int> grailStages = [];
  List<int> coinStages = [];

  ExpUpData({this.rarity = 5, this.startLv = 1, this.endLv = 90, this.next = 0})
      : assert(rarity >= 0 && rarity <= 5);

  void calculate({int expCardRarity = 4, bool sameClass = true}) {
    int expPerCard = [0, 1000, 3000, 9000, 27000, 81000][expCardRarity];
    if (sameClass) expPerCard = (expPerCard * 1.2).toInt();
    stageNames.clear();
    expStages.clear();
    qpStages.clear();
    grailStages.clear();
    coinStages.clear();

    final svt = db.gameData.servantsNoDup.values.firstWhere((svt) =>
        svt.rarity == rarity && svt.isUserSvt && svt.originalCollectionNo > 1);

    // level->ascension
    final ascensionLevels = svt.ascensionAdd.lvMax.ascension
        .map((key, value) => MapEntry(value, key));
    int maxAscensionLv = Maths.max(ascensionLevels.keys, 0);
    final grailCost = db.gameData.constData.svtGrailCost[svt.rarity]!;
    Map<int, int> grailLvQp = grailCost.map((key, value) => MapEntry(
        maxAscensionLv + (grailCost[key - 1]?.addLvMax ?? 0),
        grailCost[key]?.qp ?? 0));
    int lv = startLv;
    List<int> addedLvs = [];
    int _nextExp = next;
    while (lv < endLv) {
      int qp = 0, cards = 0, grail = 0, coin = 0;
      String stageName;
      if (_nextExp > 0) addedLvs.add(lv);
      if (!addedLvs.contains(lv) && grailLvQp[lv] != null) {
        coin = lv >= 100 && lv % 2 == 0 ? 30 : 0;
        qp += grailLvQp[lv]!;
        grail += 1;
        addedLvs.add(lv);
        stageName = lv.toString();
      } else if (!addedLvs.contains(lv) && ascensionLevels[lv] != null) {
        qp += svt.ascensionMaterials[ascensionLevels[lv]]?.qp ?? 0;
        addedLvs.add(lv);
        stageName = lv.toString();
      } else {
        int nextUpgrade = Maths.min(
            [...grailLvQp.keys, ...ascensionLevels.keys].where((e) => e > lv),
            120);
        if (nextUpgrade > endLv) {
          nextUpgrade = endLv;
        }

        stageName = '$lv→$nextUpgrade';
        int curExp = svt.expGrowth[lv - 1];
        if (_nextExp > 0 && lv < 120) {
          int curLvExp = svt.expGrowth[lv] - curExp;
          _nextExp = min(_nextExp, curLvExp);
          stageName = '$lv($_nextExp)→$nextUpgrade';
          curExp = svt.expGrowth[lv] - _nextExp;
          _nextExp = 0;
        }

        int expDemand = svt.expGrowth[nextUpgrade - 1] - curExp;
        cards = (expDemand / expPerCard).ceil();
        int usedCards = 0;
        while (usedCards < cards) {
          int _cards = min(20, cards - usedCards);
          usedCards += _cards;
          // use ★1 servant data, ★5=6	★4=4	★3=2	★2=1.5  ★1=1
          qp += (lvQpCostList[lv] * _cards * [1.5, 1, 1.5, 2, 4, 6][rarity])
              .toInt();
          int nextExp = curExp + usedCards * expPerCard;
          lv = svt.expGrowth.indexWhere((e) => e > nextExp);
          if (lv < 0) lv = 120;
        }
      }
      coinStages.add(coin);
      qpStages.add(qp);
      expStages.add(cards);
      grailStages.add(grail);
      stageNames.add(stageName);
    }

    //sum
    stageNames.insert(0, '$startLv→$endLv');
    expStages.insert(0, Maths.sum(expStages));
    qpStages.insert(0, Maths.sum(qpStages));
    grailStages.insert(0, Maths.sum(grailStages));
    coinStages.insert(0, Maths.sum(coinStages));
  }

  // total EXP for every lv
  static const List<int> lvExpList = [
    -1,
    0,
    100,
    400,
    1000,
    2000,
    3500,
    5600,
    8400,
    12000,
    16500,
    22000,
    28600,
    36400,
    45500,
    56000,
    68000,
    81600,
    96900,
    114000,
    133000,
    154000,
    177100,
    202400,
    230000,
    260000,
    292500,
    327600,
    365400,
    406000,
    449500,
    496000,
    545600,
    598400,
    654500,
    714000,
    777000,
    843600,
    913900,
    988000,
    1066000,
    1148000,
    1234100,
    1324400,
    1419000,
    1518000,
    1621500,
    1729600,
    1842400,
    1960000,
    2082500,
    2210000,
    2342600,
    2480400,
    2623500,
    2772000,
    2926000,
    3085600,
    3250900,
    3422000,
    3599000,
    3782000,
    3971100,
    4166400,
    4368000,
    4576000,
    4790500,
    5011600,
    5239400,
    5474000,
    5715500,
    5964000,
    6219600,
    6482400,
    6752500,
    7030000,
    7315000,
    7607600,
    7907900,
    8216000,
    8532000,
    8856000,
    9188100,
    9528400,
    9877000,
    10234000,
    10599500,
    10973600,
    11356400,
    11748000,
    12148500,
    12567000,
    13021900,
    13532000,
    14116500,
    14795000,
    15587500,
    16514400,
    17596500,
    18855000,
    20311500 * 1, //Lv.100
    20311500 * 2, //Lv.101
    20311500 * 3,
    20311500 * 4,
    20311500 * 5,
    20311500 * 6,
    20311500 * 7,
    20311500 * 8,
    20311500 * 9,
    20311500 * 10,
    20311500 * 11,
    20311500 * 12,
    20311500 * 13,
    20311500 * 14,
    20311500 * 15,
    20311500 * 16,
    20311500 * 17,
    20311500 * 18,
    20311500 * 19,
    20311500 * 20,
    20311500 * 21, // Lv.120
  ];

  // use ★1 servant data, ★5=6	★4=4	★3=2	★2=1.5  ★1=1
  static const List<int> lvQpCostList = [
    -1,
    100, //Lv.1
    130,
    160,
    190,
    220,
    250,
    280,
    310,
    340,
    370,
    400,
    430,
    460,
    490,
    520,
    550,
    580,
    610,
    640,
    670,
    700,
    730,
    760,
    790,
    820,
    850,
    880,
    910,
    940,
    970,
    1000,
    1030,
    1060,
    1090,
    1120,
    1150,
    1180,
    1210,
    1240,
    1270,
    1300,
    1330,
    1360,
    1390,
    1420,
    1450,
    1480,
    1510,
    1540,
    1570,
    1600,
    1630,
    1660,
    1690,
    1720,
    1750,
    1780,
    1810,
    1840,
    1870,
    1900,
    1930,
    1960,
    1990,
    2020,
    2050,
    2080,
    2110,
    2140,
    2170,
    2200,
    2230,
    2260,
    2290,
    2320,
    2350,
    2380,
    2410,
    2440,
    2470,
    2500,
    2530,
    2560,
    2590,
    2620,
    2650,
    2680,
    2710,
    2740,
    2770,
    2800,
    2830,
    2860,
    2890,
    2920,
    2950,
    2980,
    3010,
    3040,
    3070, //Lv.100
    3100, //Lv.101
    3130,
    3160,
    3190,
    3220,
    3250,
    3280,
    3310,
    3340,
    3370,
    3400,
    3430,
    3460,
    3490,
    3520,
    3550,
    3580,
    3610,
    3640,
    3670, // Lv.120
  ];

  // including Ascension and Palingenesis QP cost
  // unit: k
  static List<List<int>> ascensionQpList = [
    [
      10,
      30,
      90,
      300,
      400,
      600,
      800,
      1000,
      2000,
      3000,
      4000,
      5000,
      6000,
      7000,
      ...List.generate(10, (index) => 8000)
    ],
    [
      15,
      45,
      150,
      450,
      600,
      800,
      1000,
      2000,
      3000,
      4000,
      5000,
      6000,
      7000,
      8000,
      ...List.generate(10, (index) => 8000)
    ],
    [
      30,
      100,
      300,
      900,
      1000,
      2000,
      3000,
      4000,
      5000,
      6000,
      7000,
      8000,
      9000,
      ...List.generate(10, (index) => 8000)
    ],
    [
      50,
      150,
      500,
      1500,
      4000,
      5000,
      6000,
      7000,
      8000,
      9000,
      10000,
      ...List.generate(10, (index) => 8000)
    ],
    [
      100,
      300,
      1000,
      3000,
      9000,
      10000,
      11000,
      12000,
      13000,
      ...List.generate(10, (index) => 8000)
    ],
  ];
}
