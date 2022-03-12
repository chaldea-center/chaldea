import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/widgets/carousel_util.dart';

import 'summon_util.dart';

class SummonSimulatorPage extends StatefulWidget {
  final Summon summon;
  final int initIndex;

  const SummonSimulatorPage(
      {Key? key, required this.summon, this.initIndex = 0})
      : super(key: key);

  @override
  _SummonSimulatorPageState createState() => _SummonSimulatorPageState();
}

class _SummonSimulatorPageState extends State<SummonSimulatorPage> {
  Summon get summon => widget.summon;
  int curIndex = 0;

  SummonData get data => summon.dataList[curIndex];

  int totalQuartz = 0;
  int totalPulls = 0;
  int _curHistory = -1;
  List<List<GameCardMixin>> history = [];

  Map<GameCardMixin, int> allSummons = {};

  // [(card1,0),(card2,0.4),...,(cardN,99.0)]
  List<MapEntry<GameCardMixin, double>> probabilityList = [];

  @override
  void initState() {
    super.initState();
    curIndex = max(0, widget.initIndex);
    double acc = 0; //max 100
    for (var block in [...data.svts, ...data.crafts]) {
      for (int i = 0; i < block.ids.length; i++) {
        var card = block.isSvt
            ? db.gameData.servants[block.ids[i]]
            : db.gameData.crafts[block.ids[i]];
        double value = acc + i * block.weight / block.ids.length;
        if (card != null) probabilityList.add(MapEntry(card, value));
      }
      acc += block.weight;
    }
  }

  void reset() {
    setState(() {
      totalPulls = 0;
      totalQuartz = 0;
      history.clear();
      allSummons.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: AutoSizeText(
          summon.lName,
          maxLines: 1,
          overflow: TextOverflow.fade,
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.replay),
            tooltip: S.current.reset,
            onPressed: reset,
          )
        ],
      ),
      body: customScrollView,
    );
  }

  Widget get customScrollView {
    return CustomScrollView(
      slivers: [
        SliverList(
            delegate: SliverChildListDelegate([
          CarouselUtil.limitHeightWidget(
            context: context,
            imageUrls: [summon.bannerUrlJp, summon.bannerUrl],
          ),
          if (summon.dataList.length > 1) dropdownButton,
          details,
        ])),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverPersistentHeaderDelegate(
            height: 60,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: FittedBox(
                  child: Row(
                      children:
                          summon.isLuckyBag ? [gachaLucky] : [gacha1, gacha10]),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          statisticHint,
          SimpleAccordion(
            expanded: true,
            headerBuilder: (context, _) => ListTile(
              dense: true,
              title: Text(
                  LocalizedText.of(chs: '抽卡结果', jpn: 'ガチャ結果', eng: 'Results')),
            ),
            contentBuilder: (context) => curResult(),
          ),
          for (bool isSvt in [true, false])
            for (int rarity in [5, 4, 3]) accResultOf(isSvt, rarity),
          kDefaultDivider,
          Center(
            child: Text(
              LocalizedText.of(
                  chs: '仅供娱乐, 如有雷同, 纯属巧合',
                  jpn: '娯楽のみ',
                  eng: 'Just for entertainment'),
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          )
        ]))
      ],
    );
  }

  Widget get statisticHint {
    double suits = (totalQuartz / 167);
    String title, subtitle;
    int extraLeft = 9 - totalPulls % 11;
    if (Language.isZH) {
      title = '共计: $totalPulls抽'
          ' $totalQuartz石'
          '(${suits.toStringAsFixed(2)}单,'
          ' ${(suits * 518).round()}RMB)';
      subtitle = '剩余$extraLeft次获得额外召唤';
    } else if (Language.isJP) {
      suits = (totalQuartz / 168);
      title = '合計: $totalPulls回'
          ' $totalQuartz石'
          '(${suits.toStringAsFixed(2)}×10000='
          '${(suits * 10000).round()}円)';
      subtitle = 'あと$extraLeft回で1回ボーナス召喚';
    } else if (Language.isKO) {
      title = '합계: $totalPulls회 $totalQuartz석'
          ' (${suits.toStringAsFixed(2)}×93200/95000=₩${(suits * 93200).round()}/${(suits * 95000).round()})';
      subtitle = '$extraLeft번 더 돌리면 보너스 소환 기회 획득';
    } else {
      title = 'Total $totalPulls Pulls $totalQuartz SQ'
          ' (${suits.toStringAsFixed(2)}×100=\$${(suits * 100).round()})';
      subtitle = '$extraLeft more pulls to get 1 extra summon';
    }
    return ListTile(
      title: Text(title),
      subtitle: (summon.isLimited && summon.roll11) || summon.isStory
          ? Text(subtitle)
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
        title: Text('★$rarity ' +
            (isSvt ? S.current.servant : S.current.craft_essence)),
        trailing: Text(totalCount.toString()),
      ),
      contentBuilder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Center(
          child: Wrap(children: counts),
        ),
      ),
    );
  }

  Widget get dropdownButton {
    List<DropdownMenuItem<int>> items = [];
    items.addAll(summon.dataList.map((e) => DropdownMenuItem(
          child: AutoSizeText(
            SummonUtil.summonNameLocalize(e.name),
            maxLines: 2,
            maxFontSize: 14,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          value: summon.dataList.indexOf(e),
        )));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Text(LocalizedText.of(chs: '日替: ', jpn: '日替: ', eng: 'Daily: '),
              style: const TextStyle(color: Colors.redAccent)),
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
    List<Widget> svtRow = [];
    data.svts.forEach((block) {
      if (block.ids.isEmpty || !block.display) return; // should always not
      double weight = block.weight / block.ids.length;
      block.ids.forEach((id) {
        Servant? svt = db.gameData.servants[id];
        if (svt == null) return;
        svtRow.add(SummonUtil.buildCard(
          context: context,
          card: svt,
          weight: weight,
          showCategory: true,
        ));
      });
    });
    List<Widget> craftRow = [];
    data.crafts.forEach((block) {
      if (block.ids.isEmpty || !block.display) return; // should always not
      double weight = block.weight / block.ids.length;
      block.ids.forEach((id) {
        CraftEssence? ce = db.gameData.crafts[id];
        if (ce == null) return;
        craftRow.add(SummonUtil.buildCard(
          context: context,
          card: ce,
          weight: weight,
        ));
      });
    });
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (svtRow.isNotEmpty)
            Wrap(spacing: 4, runSpacing: 4, children: svtRow),
          const SizedBox(height: 4),
          if (craftRow.isNotEmpty)
            Wrap(spacing: 4, runSpacing: 4, children: craftRow),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: rows,
          ),
        ),
      );
      if (data.isNotEmpty) {
        child = FittedBox(
          child: child,
          fit: BoxFit.scaleDown,
        );
      }
      return child;
    }

    if (_curHistory < 0 || _curHistory >= history.length) {
      _curHistory = history.length - 1;
    }
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
              icon: const Icon(Icons.keyboard_arrow_left),
            ),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 128),
                child: AspectRatio(
                  aspectRatio: 5 / 2 * 132 / 144,
                  child: _buildOneHistory(history[_curHistory]),
                ),
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
              icon: const Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
        Text(
          '${_curHistory + 1}/${history.length}',
          style: Theme.of(context).textTheme.caption,
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget get gacha1 {
    String iconKey;
    int gachaNum = 1;
    if (!summon.roll11) {
      iconKey = '召唤1次按钮.png';
    } else if (totalPulls % 11 == 9) {
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
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: InkWell(
        onTap: () => startGacha(times, quartz),
        child: db.getIconImage(iconKey, height: 50),
      ),
    );
  }

  Widget _cardIcon(GameCardMixin card, [String? text]) {
    return card.iconBuilder(
      context: context,
      text: text,
      width: 48,
      padding: const EdgeInsets.all(3),
      textPadding: const EdgeInsets.only(right: 4, bottom: 4),
    );
  }

  void startGacha(int times, int quartz) {
    // // Monte Carlo test
    // // 100(11000000) = 1.03640 + 3.11976 + 39.80255 + 4.15877 + 12.48025 + 39.40226
    // // standards: 1+3+40+4+12+40
    // int total = 0, s5 = 0, s4 = 0, s3 = 0, c5 = 0, c4 = 0, c3 = 0;
    // for (int i = 0; i < 1000000; i++) {
    //   final cards = summonWithGuarantee(11);
    //   total += cards.length;
    //   s5 += cards.where((e) => e is Servant && e.rarity == 5).length;
    //   s4 += cards.where((e) => e is Servant && e.rarity == 4).length;
    //   s3 += cards.where((e) => e is Servant && e.rarity == 3).length;
    //   c5 += cards.where((e) => e is CraftEssence && e.rarity == 5).length;
    //   c4 += cards.where((e) => e is CraftEssence && e.rarity == 4).length;
    //   c3 += cards.where((e) => e is CraftEssence && e.rarity == 3).length;
    //   if ((i + 1) % 1000 == 0) {
    //     String _percent(int x) => (x / total * 100).toStringAsFixed(5);
    //     print('${i + 1}: 100($total) ='
    //         ' ${_percent(s5)} +'
    //         ' ${_percent(s4)} +'
    //         ' ${_percent(s3)} +'
    //         ' ${_percent(c5)} +'
    //         ' ${_percent(c4)} +'
    //         ' ${_percent(c3)}');
    //   }
    // }
    // return;
    List<GameCardMixin> newAdded = summonWithGuarantee(times);
    newAdded.shuffle(random);
    newAdded.forEach((element) {
      allSummons[element] = (allSummons[element] ?? 0) + 1;
    });
    history.add(newAdded);
    totalPulls += times;
    totalQuartz += quartz;
    _curHistory = history.length - 1;
    setState(() {});
  }

  List<GameCardMixin> summonWithGuarantee(int times) {
    List<GameCardMixin> results = [];
    // 10or11连抽保底
    //
    // void _ensureCardR4() {
    //   if (!results.any((e) => e.rarity >= 4)) {
    //     results.addAll(randomSummon(cardProbs((r) => r >= 4), 1));
    //   }
    // }
    //
    // void _ensureSvtR(int r) {
    //   if (results.any((e) => e is Servant && e.rarity >= r)) {
    //     results.addAll(randomSummon(cardProbs(), 1));
    //   } else {
    //     results.addAll(randomSummon(svtProbs((_r) => _r >= r), 1));
    //   }
    // }
    results.addAll(randomSummon(cardProbs(), times));

    if (times >= 10) {
      // New
      if (summon.isLuckyBag) {
        List<GameCardMixin> newResults = [];
        final s5 =
            results.firstWhereOrNull((e) => e is Servant && e.rarity == 5);
        if (s5 != null) {
          results.remove(s5);
          newResults.add(s5);
        } else {
          newResults.addAll(randomSummon(svtProbs((r) => r == 5), 1));
        }
        if (summon.isLuckyBagWithSR) {
          final s4 =
              results.firstWhereOrNull((e) => e is Servant && e.rarity >= 4);
          if (s4 != null) {
            results.remove(s4);
            newResults.add(s4);
          } else {
            newResults.addAll(randomSummon(svtProbs((r) => r >= 4), 1));
          }
        }
        newResults.addAll(results.sublist(0, times - newResults.length));
        results = newResults;
      } else {
        final r4 = results.indexWhere((e) => e.rarity >= 4);
        final s3 = results.indexWhere((e) => e is Servant && e.rarity >= 3);
        if (r4 < 0) {
          if (s3 < 0) {
            // 4 svt
            results.removeLast();
            results.addAll(randomSummon(svtProbs((r) => r >= 4), 1));
          } else {
            // 4 card
            results.removeAt(s3 == 0 ? 1 : 0);
            results.addAll(randomSummon(cardProbs((r) => r >= 4), 1));
          }
        } else {
          if (s3 < 0) {
            // 3 svt
            results.removeAt(r4 == 0 ? 1 : 0);
            results.addAll(randomSummon(svtProbs((r) => r >= 3), 1));
          } else {
            //
          }
        }
      }
    }
    assert(
        results.any((e) => e is Servant) && results.any((e) => e.rarity >= 4),
        results.map((e) => '${e.runtimeType}-${e.rarity}'));

    return results;
  }

  final random = Random(DateTime.now().microsecondsSinceEpoch);

  /// 无任何保底，纯随机
  List<GameCardMixin> randomSummon(
      Map<GameCardMixin, double> probMap, int times) {
    final probList = probMap.entries.toList();
    probList.shuffle();
    List<GameCardMixin> result = [];
    double totalProb = 0;
    probList.forEach((element) => totalProb += element.value);
    for (int i = 0; i < times; i++) {
      double p = random.nextDouble() * totalProb * 0.9999999;
      GameCardMixin? target;
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
  Map<GameCardMixin, double> svtProbs([bool Function(int r)? rarityTest]) {
    Map<GameCardMixin, double> probs = {};
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
  Map<GameCardMixin, double> cardProbs([bool Function(int r)? rarityTest]) {
    Map<GameCardMixin, double> probs = {};
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

  void _printMap(Map<GameCardMixin, double> probs) {
    // Map s = {};
    // probs.forEach((key, value) {
    //   s[key] = value.toStringAsFixed(3).trimCharRight('0');
    // });
    // print(s);
  }

  Servant? svtFromId(int id) => db.gameData.servants[id];

  CraftEssence? craftFromId(int id) => db.gameData.crafts[id];

  Map<GameCardMixin, double> _addProbMap({
    Map<GameCardMixin, double>? result,
    required List<int> ids,
    required double totalWeight,
    required bool isSvt,
    bool skipExistKey = true,
  }) {
    result ??= {};
    double weight = totalWeight / ids.length;
    for (var id in ids) {
      var key = (isSvt ? db.gameData.servants : db.gameData.crafts)[id];
      if (key == null) continue;
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
