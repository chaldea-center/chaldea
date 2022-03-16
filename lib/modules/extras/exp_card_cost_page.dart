import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

class ExpCardCostPage extends StatefulWidget {
  ExpCardCostPage({Key? key}) : super(key: key);

  @override
  _ExpCardCostPageState createState() => _ExpCardCostPageState();
}

class _ExpCardCostPageState extends State<ExpCardCostPage> {
  bool use5 = false;
  bool sameClass = true;

  @override
  Widget build(BuildContext context) {
    data.calculate(use5: use5, sameClass: sameClass);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.exp_card_title),
        actions: [
          IconButton(
            onPressed: () {
              SimpleCancelOkDialog(
                scrollable: true,
                title: Text(S.current.help),
                content: Text(LocalizedText.of(
                    chs: '''1.QP计算可能不准确，仅供参考。按每次20个狗粮计算。
2.如80->90，只计算80级时的再临(圣杯转临)所消耗的QP(圣杯)''',
                    jpn: """1. QPの計算は不正確である可能性があり、参照用です。 毎回20回で計算。
2. 例えば、80->90の場合、レベル80で再臨（聖杯転臨）によって消費されるQP（聖杯）のみを計算します。 """,
                    eng:
                        """1. The QP calculation may be inaccurate and is for reference only. 20 Exp cards every enhancement.
2. e.g. 80->90, only calculate the QP (Holy Grail) consumed by the ascension (Palingenesis) at level 80""",
                    kor: """1. QP의 계산은 정확하지 않을 가능성이 있어, 참고용입니다. 매회 20회씩 계산합니다.
2. 예를 들어, 80->90의 경우, 레벨 80에서 재림(성배재림)에 소비되는 QP(성배)만 계산합니다. """)),
              ).showDialog(context);
            },
            icon: const Icon(Icons.help_outline),
            tooltip: S.current.help,
          ),
        ],
      ),
      body: ListView(
        children: [
          selector,
          kDefaultDivider,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CheckboxWithLabel(
                value: use5,
                onChanged: (v) => setState(() {
                  use5 = v ?? use5;
                }),
                label: Text(S.current.exp_card_rarity5),
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
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(S.current.words_separate(S.current.servant, S.current.rarity)),
        DropdownButton<int>(
          value: data.rarity,
          items: List.generate(
            6,
            (index) => DropdownMenuItem(
              child: Text('${5 - index}☆'),
              value: 5 - index,
            ),
          ),
          onChanged: (v) => setState(() {
            data.rarity = v ?? data.rarity;
          }),
        ),
        Text(S.current.exp_card_plan_lv),
        TextButton(
          onPressed: () {
            data.lvs.sort();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return LayoutBuilder(builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: constraints.copyWith(
                        maxHeight: constraints.maxHeight * 0.6),
                    child: ExpLvRangeSelector(data: data),
                  );
                });
              },
            ).whenComplete(() => setState(() {}));
          },
          child: Text('${data.startLv}->${data.endLv}'),
        ),
        // IconButton(
        //   onPressed: () {},
        //   icon: Icon(Icons.add_circle),
        //   color: Colors.blue,
        // ),
        const Padding(padding: EdgeInsets.only(right: 16)),
      ],
    );
  }

  Widget _cardIcon(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CachedImage(
        imageUrl: name,
        isMCFile: true,
        cacheDir: db.paths.gameIconDir,
        width: 132 * 0.2,
        height: 144 * 0.2,
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
          _cardIcon('睿智的业火.png'),
          _cardIcon('睿智的猛火.png'),
          _cardIcon('睿智的大火.png'),
          _cardIcon('QP.jpg'),
          _cardIcon('圣杯.png'),
        ],
      )
    ];
    Widget _valToWidget(String val, [bool header = false]) {
      if (val == '0' || val.isEmpty) return Container();
      return Center(
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              val,
              style: TextStyle(
                fontWeight: header ? FontWeight.bold : null,
              ),
            ),
          ),
          fit: BoxFit.scaleDown,
        ),
      );
    }

    for (int index = 0; index < data.stages.length; index++) {
      rows.add(TableRow(
        decoration: index == 0 ? BoxDecoration(color: headerColor) : null,
        children: [
          _valToWidget(data.stages[index], index == 0),
          _valToWidget(data.exp5Stages[index].toString(), index == 0),
          _valToWidget(data.exp4Stages[index].toString(), index == 0),
          _valToWidget(data.exp3Stages[index].toString(), index == 0),
          _valToWidget(data.qpStages[index].format(), index == 0),
          _valToWidget(data.grailStages[index].format(), index == 0),
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
        4: FlexColumnWidth(2),
      },
      children: rows,
    );
  }
}

class ExpLvRangeSelector extends StatefulWidget {
  final ExpUpData data;

  const ExpLvRangeSelector({Key? key, required this.data}) : super(key: key);

  @override
  _ExpLvRangeSelectorState createState() => _ExpLvRangeSelectorState();
}

class _ExpLvRangeSelectorState extends State<ExpLvRangeSelector> {
  ExpUpData get data => widget.data;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int i = 1; i <= Grail.maxLv; i++) {
      void _onTapLv() {
        data.clickAt(i);
        setState(() {});
      }

      bool isEndPoint = i == data.startLv || i == data.endLv;
      bool isInRange = i > data.startLv && i < data.endLv;
      Widget btn;
      btn = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        child: Material(
          color: isEndPoint
              ? Theme.of(context).colorScheme.primary
              : isInRange
                  ? Theme.of(context).colorScheme.background
                  : Theme.of(context).highlightColor,
          borderRadius: BorderRadius.circular(3),
          child: InkWell(
            onTap: _onTapLv,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: AutoSizeText(
                  i.toString(),
                  maxFontSize: 48,
                  minFontSize: 2,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),
        ),
      );

      children.add(btn);
    }
    Widget grid = LayoutBuilder(builder: (context, constraints) {
      int crossCount = constraints.maxWidth ~/ 32 ~/ 5 * 5;
      crossCount = max(5, crossCount);
      return GridView.count(
        shrinkWrap: true,
        crossAxisCount: crossCount,
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 24),
        childAspectRatio: 48 / 32,
        children: children,
      );
    });
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            toolbarHeight: 36,
            leading: const BackButton(),
            titleSpacing: 0,
            centerTitle: true,
            title: Text(
              S.current.exp_card_select_lvs,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Flexible(child: grid),
        ],
      ),
    );
  }
}

class ExpUpData {
  int rarity;

  int get rarity2 => rarity == 0 ? 2 : rarity;
  List<int> lvs;

  int get startLv => min(lvs[0], lvs[1]);

  int get endLv => max(lvs[0], lvs[1]);

  List<String> stages = [];
  List<int> qpStages = [];
  List<int> exp5Stages = [];
  List<int> exp4Stages = [];
  List<int> exp3Stages = [];
  List<int> grailStages = [];

  ExpUpData({this.rarity = 5, List<int>? lvs})
      : assert(rarity >= 0 && rarity <= 5),
        assert(lvs == null || lvs.length == 2),
        lvs = lvs ?? [1, 90];

  void clickAt(int lv) {
    if (lvs.contains(lv)) return;
    lvs.add(lv);
    lvs.removeAt(0);
  }

  void calculate({bool use5 = false, bool sameClass = true}) {
    stages.clear();
    exp5Stages.clear();
    exp4Stages.clear();
    exp3Stages.clear();
    qpStages.clear();
    grailStages.clear();

    List<int> lvs = Grail.maxAscensionGrailLvs(rarity: rarity2);
    for (int index = 0; index < lvs.length - 1; index++) {
      int lva = max(lvs[index], startLv), lvb = min(lvs[index + 1], endLv);
      if (lva >= lvb) {
        continue;
      }
      stages.add('$lva->$lvb');
      int baseExp = sameClass ? 1200 * 9 : 1000 * 9;
      int card3Num = ((lvExpList[lvb] - lvExpList[lva]) * 1.0 / baseExp).ceil();
      // print('$lva->$lvb, card3Num=$card3Num');
      if (use5) {
        exp5Stages.add(card3Num ~/ 9);
        exp4Stages.add((card3Num % 9) ~/ 3);
        exp3Stages.add(card3Num % 3);
      } else {
        exp5Stages.add(0);
        exp4Stages.add(card3Num ~/ 3);
        exp3Stages.add(card3Num % 3);
      }
      List<int> expCards = [
        ...List.generate(exp5Stages.last, (index) => baseExp * 9),
        ...List.generate(exp4Stages.last, (index) => baseExp * 3),
        ...List.generate(exp3Stages.last, (index) => baseExp),
      ];
      //qp
      int curLv = lva, qp = 0, curExp = lvExpList[curLv];
      List<int> ascensionQp = ascensionQpList[rarity2 - 1];
      grailStages.add(0);
      if (lva != Grail.maxLv && lvs.contains(lva)) {
        qp += ascensionQp[lvs.indexOf(lva) - 1] * 1000;
        if (index >= 5) grailStages[grailStages.length - 1] = 1;
        // print('ascension qp: ${ascensionQp[lvs.indexOf(lva) - 1] * 1000}');
      }
      while (expCards.isNotEmpty) {
        int n = 20;
        while (n > 0 && expCards.isNotEmpty) {
          n -= 1;
          curExp += expCards.removeAt(0);
          qp += (lvQpCostList[curLv] * [1.5, 1, 1.5, 2, 4, 6][rarity2]).toInt();
          // print('    Lv.$curLv - ${lvQpCostList[curLv]}');
        }
        if (curExp >= lvExpList.last) {
          curLv = Grail.maxLv;
        } else {
          curLv = lvExpList.indexWhere((e) => e > curExp) - 1;
        }
      }
      qpStages.add(qp);
    }
    //sum
    stages.insert(0, '$startLv->$endLv');
    exp5Stages.insert(0, Maths.sum(exp5Stages));
    exp4Stages.insert(0, Maths.sum(exp4Stages));
    exp3Stages.insert(0, Maths.sum(exp3Stages));
    qpStages.insert(0, Maths.sum(qpStages));
    grailStages.insert(0, Maths.sum(grailStages));
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
