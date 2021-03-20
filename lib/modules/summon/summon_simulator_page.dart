import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/craft/craft_detail_page.dart';
import 'package:chaldea/modules/servant/servant_detail_page.dart';
import 'package:getwidget/getwidget.dart';

class SummonSimulatorPage extends StatefulWidget {
  final Summon summon;
  final int initIndex;

  SummonSimulatorPage({Key? key, required this.summon, this.initIndex = 0})
      : super(key: key);

  @override
  _SummonSimulatorPageState createState() => _SummonSimulatorPageState();
}

class _SummonSimulatorPageState extends State<SummonSimulatorPage> {
  Summon get summon => widget.summon;
  int curIndex = 0;

  SummonData get data => summon.dataList[curIndex];

  int totalQuartz = 0;
  int totalTimes = 0;
  int _curHistory = -1;
  List<List> history = [];

  Map<dynamic, int> allSummons = {};

  // [(card1,0),(card2,0.4),...,(cardN,99.0)]
  List<MapEntry<dynamic, double>> probabilityList = [];

  @override
  void initState() {
    super.initState();
    curIndex = max(0, widget.initIndex);
    double acc = 0; //max 100
    for (var block in [...data.svts, ...data.crafts]) {
      for (int i = 0; i < block.ids.length; i++) {
        var key = block.isSvt
            ? db.gameData.servants[block.ids[i]]
            : db.gameData.crafts[block.ids[i]];
        double value = acc + i * block.weight / block.ids.length;
        probabilityList.add(MapEntry(key, value));
      }
      acc += block.weight;
    }
  }

  void reset() {
    setState(() {
      totalTimes = 0;
      totalQuartz = 0;
      // newAdded.clear();
      history.clear();
      allSummons.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: AutoSizeText(summon.localizedName, maxLines: 1),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.replay),
            tooltip: S.current.reset,
            onPressed: reset,
          )
        ],
      ),
      body: customScrollView,
    );
  }

  Widget get customScrollView {
    List<Widget> banners = [];
    for (String? url in [summon.bannerUrl, summon.bannerUrlJp]) {
      if (url?.isNotEmpty == true) {
        banners.add(CachedImage(
          imageUrl: url,
          imageBuilder: (context, image) =>
              FittedBox(child: Image(image: image)),
          isMCFile: true,
          placeholder: (_, __) => Container(),
        ));
      }
    }
    return CustomScrollView(
      slivers: [
        SliverList(
            delegate: SliverChildListDelegate([
          if (banners.isNotEmpty)
            GFCarousel(
              items: banners,
              autoPlay: false,
              aspectRatio: 8 / 3,
              viewportFraction: 1.0,
              enableInfiniteScroll: banners.length > 1,
            ),
          if (summon.dataList.length > 1) dropdownButton,
          details,
        ])),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverPersistentHeaderDelegate(
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                border: Border.symmetric(
                    horizontal: Divider.createBorderSide(context)),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Center(
                child: FittedBox(
                  child: Row(
                      children: summon.luckyBag > 0
                          ? [gachaLucky]
                          : [gacha1, gacha10]),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          statisticHint,
          kDefaultDivider,
          SimpleAccordion(
            expanded: true,
            headerBuilder: (context, _) => ListTile(
              dense: true,
              title: Text('抽卡结果'),
            ),
            contentBuilder: (context) => curResult(),
          ),
          for (bool isSvt in [true, false])
            for (int rarity in [5, 4, 3]) accResultOf(isSvt, rarity),
          kDefaultDivider,
          Center(
            child: Text(
              '仅供娱乐, 如有雷同, 纯属巧合',
              style: TextStyle(color: Colors.grey),
            ),
          )
        ]))
      ],
    );
  }

  Widget get statisticHint {
    return ListTile(
      title: Text('共计: $totalTimes抽'
          ' $totalQuartz石'
          '(${(totalQuartz / 167).toStringAsFixed(2)}单,'
          ' ${(totalQuartz / 167 * 518).toStringAsFixed(0)}RMB)'),
      subtitle: summon.luckyBag == 0 && summon.roll11
          ? Text('还有${9 - totalTimes % 11}次即可获得1次额外召唤')
          : null,
    );
  }

  Widget accResultOf(bool isSvt, int rarity) {
    List<Widget> counts = [];
    int totalCount = 0;
    allSummons.forEach((key, value) {
      if ((isSvt && key is Servant && key.info.rarity == rarity) ||
          (!isSvt && key is CraftEssence && key.rarity == rarity)) {
        counts.add(_cardIcon(key, value.toString()));
        totalCount += value;
      }
    });
    return SimpleAccordion(
      expanded: rarity > 3,
      headerBuilder: (context, _) => ListTile(
        dense: true,
        title: Text('获得的★$rarity${isSvt ? "英灵" : "礼装"}'),
        trailing: Text(totalCount.toString()),
      ),
      contentBuilder: (context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Center(
          child: Wrap(children: counts),
        ),
      ),
    );
  }

  Widget get dropdownButton {
    List<DropdownMenuItem<int>> items = [];
    items.addAll(summon.dataList.map((e) => DropdownMenuItem(
          child: AutoSizeText(e.name, maxLines: 2, maxFontSize: 14),
          value: summon.dataList.indexOf(e),
        )));
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Text('日替  ', style: TextStyle(color: Colors.redAccent)),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                  border: Border(bottom: Divider.createBorderSide(context))),
              child: DropdownButton<int>(
                value: curIndex,
                items: items,
                underline: Container(),
                onChanged: (v) {
                  curIndex = v ?? curIndex;
                  reset();
                },
                isExpanded: true,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget get details {
    String formatWeight(double w) {
      return double.parse(w.toStringAsFixed(5)).toString();
    }

    List<Widget> svtRow = [];
    data.svts.forEach((block) {
      if (block.ids.isEmpty || !block.display) return; // should always not
      String weight = formatWeight(block.weight / block.ids.length);
      block.ids.forEach((id) {
        svtRow.add(_cardIcon(db.gameData.servants[id]!, '$weight%'));
      });
    });
    List<Widget> craftRow = [];
    data.crafts.forEach((block) {
      if (block.ids.isEmpty || !block.display) return; // should always not
      String weight = formatWeight(block.weight / block.ids.length);
      block.ids.forEach((id) {
        craftRow.add(_cardIcon(db.gameData.crafts[id]!, '$weight%'));
      });
    });
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (svtRow.isNotEmpty) Wrap(children: svtRow),
          if (craftRow.isNotEmpty) Wrap(children: craftRow),
        ],
      ),
    );
  }

  Widget curResult() {
    if (history.isEmpty) return Container();

    Widget _buildRow(List rowItems) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: rowItems.map((e) => _cardIcon(e)).toList(),
      );
    }

    Widget _buildOneHistory(List data) {
      List<Widget> rows = [];
      rows.add(_buildRow(data.sublist(0, min(6, data.length))));
      if (data.length > 6) rows.add(_buildRow(data.sublist(6, data.length)));
      Widget child = Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: rows,
          ),
        ),
      );
      if (data.isNotEmpty)
        child = FittedBox(
          child: child,
          fit: BoxFit.scaleDown,
        );
      return child;
    }

    if (_curHistory < 0 || _curHistory >= history.length)
      _curHistory = history.length - 1;
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _curHistory == 0
                  ? null
                  : () {
                      setState(() {
                        _curHistory -= 1;
                      });
                    },
              icon: Icon(Icons.keyboard_arrow_left),
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 10 / 4,
                child: _buildOneHistory(history[_curHistory]),
              ),
            ),
            IconButton(
              onPressed: _curHistory == history.length - 1
                  ? null
                  : () {
                      setState(() {
                        _curHistory += 1;
                      });
                    },
              icon: Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
        Text(
          '${_curHistory + 1}/${history.length}',
          style: Theme.of(context).textTheme.caption,
        ),
        Padding(padding: EdgeInsets.only(bottom: 6)),
      ],
    );
  }

  Widget get gacha1 {
    String iconKey;
    int gachaNum = 1;
    if (!summon.roll11) {
      iconKey = '召唤1次按钮.png';
    } else if (totalTimes % 11 == 9) {
      iconKey = '日服召唤按钮_2次.png';
      gachaNum = 2;
    } else {
      iconKey = '日服召唤按钮_1次.png';
    }
    return _summonButton(times: gachaNum, quartz: 3, iconKey: iconKey);
  }

  Widget get gacha10 {
    return _summonButton(
        times: summon.roll11 ? 11 : 10,
        quartz: 30,
        iconKey: summon.roll11 ? '日服召唤按钮_11次.png' : '召唤10次按钮.png');
  }

  Widget get gachaLucky {
    return _summonButton(
        times: summon.roll11 ? 11 : 10,
        quartz: 15,
        iconKey: summon.roll11 ? '日服召唤按钮_福袋.png' : '福袋召唤按钮.png');
  }

  Widget _summonButton(
      {required int times, required int quartz, required String iconKey}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: InkWell(
        onTap: () => startGacha(times, quartz),
        child: db.getIconImage(iconKey, height: 50),
      ),
    );
  }

  Widget _cardIcon(dynamic obj, [String? text]) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: InkWell(
        onTap: () {
          SplitRoute.push(
            context: context,
            builder: (context, _) {
              if (obj is Servant) return ServantDetailPage(obj);
              if (obj is CraftEssence) return CraftDetailPage(ce: obj);
              throw 'obj must be Servant or CraftEssence: ${obj.runtimeType}';
            },
          );
        },
        child: ImageWithText(
          image: db.getIconImage(obj.icon, width: 50),
          text: text,
        ),
      ),
    );
  }

  void startGacha(int times, int quartz) {
    List newAdded = summonWithGuarantee(times);
    newAdded.shuffle(random);
    newAdded.forEach((element) {
      allSummons[element] = (allSummons[element] ?? 0) + 1;
    });
    history.add(newAdded);
    totalTimes += times;
    totalQuartz += quartz;
    _curHistory = history.length - 1;
    setState(() {});
  }

  List summonWithGuarantee(int times) {
    List results = [];
    // 10or11连抽保底
    if (times >= 10) {
      //福袋保底
      if (summon.luckyBag > 0) {
        results.addAll(randomSummon(svtProbs((r) => r == 5), 1));
        //带4星的福袋保底
        if (summon.luckyBag == 2) {
          results.addAll(randomSummon(svtProbs((r) => r == 4), 1));
        }
      }
      //从者保底
      if (!results.any((e) => e is Servant)) {
        results.addAll(randomSummon(svtProbs(), 1));
      }
      //金卡保底
      if (!results.any((e) =>
          (e is Servant && e.info.rarity > 3) ||
          (e is CraftEssence && e.rarity > 3)))
        results.addAll(randomSummon(cardProbs((r) => r > 3), 1));
    }
    results.addAll(randomSummon(cardProbs(), times - results.length));
    return results;
  }

  final random = Random(DateTime.now().microsecondsSinceEpoch);

  /// 无任何保底，纯随机
  List randomSummon(Map<dynamic, double> probMap, int times) {
    final probList = probMap.entries.toList();
    List result = [];
    double totalProb = 0;
    probList.forEach((element) => totalProb += element.value);
    for (int i = 0; i < times; i++) {
      double p = random.nextDouble() * totalProb * 0.9999999;
      var target;
      double acc = 0;
      for (int j = 0; j < probList.length; j++) {
        acc += probList[j].value;
        if (acc > p) {
          target = probList[j].key;
          break;
        }
      }
      // double accuracy problem
      assert(target != null);
      target ??= probList.last.key;
      result.add(target);
    }
    return result;
  }

  /// null-所有从者, 4/5-福袋4/5星从者
  Map<dynamic, double> svtProbs([bool Function(int r)? rarityTest]) {
    Map<dynamic, double> probs = {};
    data.svts
        .where((block) => rarityTest == null || rarityTest(block.rarity))
        .forEach((block) {
      _addProbMap(
          result: probs,
          ids: block.ids,
          totalWeight: block.weight,
          isSvt: block.isSvt);
    });
    return probs;
  }

  /// 从者+礼装
  Map<dynamic, double> cardProbs([bool Function(int r)? rarityTest]) {
    Map<dynamic, double> probs = {};
    data.allBlocks
        .where((block) => rarityTest == null || rarityTest(block.rarity))
        .forEach((block) {
      _addProbMap(
          result: probs,
          ids: block.ids,
          totalWeight: block.weight,
          isSvt: block.isSvt);
    });
    _printMap(probs);
    return probs;
  }

  void _printMap(Map<dynamic, double> probs) {
    // Map s = {};
    // probs.forEach((key, value) {
    //   s[key] = value.toStringAsFixed(3).trimCharRight('0');
    // });
    // print(s);
  }

  Servant? svtFromId(int id) => db.gameData.servants[id];

  CraftEssence? craftFromId(int id) => db.gameData.crafts[id];

  Map<dynamic, double> _addProbMap({
    Map<dynamic, double>? result,
    required List<int> ids,
    required double totalWeight,
    required bool isSvt,
    bool skipExistKey = true,
  }) {
    result ??= {};
    double weight = totalWeight / ids.length;
    for (var id in ids) {
      var key = (isSvt ? db.gameData.servants : db.gameData.crafts)[id];
      if (skipExistKey) {
        result.putIfAbsent(key, () => weight);
      } else {
        result[key] = weight;
      }
    }
    return result;
  }
}

class _SliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _SliverPersistentHeaderDelegate({required this.height, required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
