import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/analysis/analysis.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/carousel_util.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'summon_util.dart';

class SummonSimulatorPage extends StatefulWidget {
  final LimitedSummon summon;
  final int initIndex;

  const SummonSimulatorPage({super.key, required this.summon, this.initIndex = 0});

  @override
  _SummonSimulatorPageState createState() => _SummonSimulatorPageState();
}

class _SummonSimulatorPageState extends State<SummonSimulatorPage> {
  late final summon = widget.summon;
  int curIndex = 0;

  SubSummon get data =>
      // SubSummon get data =>
      summon.subSummons.getOrNull(curIndex) ?? SubSummon(title: 'Error');

  int totalQuartz = 0;
  int totalPulls = 0;
  int _curHistory = -1;
  List<List<GameCardMixin>> history = [];

  Map<GameCardMixin, int> allSummons = {};

  @override
  void initState() {
    super.initState();
    curIndex = widget.initIndex.clamp2(0, summon.subSummons.length - 1);
  }

  int _debugPullCount = 0;

  @override
  void dispose() {
    super.dispose();
    if (_debugPullCount > 0) {
      AppAnalysis.instance.logEvent('summon_simulator', {
        "count": "1",
        // "sum": _debugPullCount.toString(),
      });
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
        title: AutoSizeText(summon.lName.l, maxLines: 1, overflow: TextOverflow.fade),
        titleSpacing: 0,
        actions: [
          IconButton(icon: const Icon(Icons.replay), tooltip: S.current.reset, onPressed: reset),
          PopupMenuButton(
            itemBuilder: (context) => [PopupMenuItem(onTap: monteCarloTest, child: const Text('Monte Carlo Test'))],
          ),
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
            CarouselUtil.limitHeightWidget(context: context, imageUrls: summon.resolvedBanner.values.toList()),
            if (summon.subSummons.length > 1) dropdownButton,
            data.probs.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('No data')),
                  )
                : details,
            if (summon.isDestiny) destinyOrderSelects,
          ]),
        ),
        if (data.probs.isNotEmpty) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverPersistentHeaderDelegate(
              height: 60,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Row(children: summon.isLuckyBag ? [gachaLucky] : [gacha1, gacha10]),
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
                headerBuilder: (context, _) => ListTile(dense: true, title: Text(S.current.summon_gacha_result)),
                contentBuilder: (context) => curResult(),
              ),
              for (bool isSvt in [true, false])
                for (int rarity in [5, 4, 3]) accResultOf(isSvt, rarity),
              kDefaultDivider,
              SafeArea(
                child: Center(
                  child: Text(
                    S.current.summon_gacha_footer,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ],
    );
  }

  Widget get statisticHint {
    double suits = (totalQuartz / 167);
    String title, subtitle;
    int extraLeft = 9 - totalPulls % 11;
    if (Language.isZH) {
      title =
          '共计: $totalPulls抽'
          ' $totalQuartz石'
          '(${suits.toStringAsFixed(2)}单,'
          ' ${(suits * 518).round()}RMB)';
      subtitle = '剩余$extraLeft次获得额外召唤';
    } else if (Language.isJP) {
      suits = (totalQuartz / 168);
      title =
          '合計: $totalPulls回'
          ' $totalQuartz石'
          '(${suits.toStringAsFixed(2)}×10000='
          '${(suits * 10000).round()}円)';
      subtitle = 'あと$extraLeft回で1回ボーナス召喚';
    } else if (Language.isKO) {
      title =
          '합계: $totalPulls회 $totalQuartz석'
          ' (${suits.toStringAsFixed(2)}×93200/95000=₩${(suits * 93200).round()}/${(suits * 95000).round()})';
      subtitle = '$extraLeft번 더 돌리면 보너스 소환 기회 획득';
    } else {
      title =
          'Total $totalPulls Pulls $totalQuartz SQ'
          ' (${suits.toStringAsFixed(2)}×100=\$${(suits * 100).round()})';
      subtitle = '$extraLeft more pulls to get 1 extra summon';
    }
    return ListTile(title: Text(title), subtitle: (summon.rollCount == 11) ? Text(subtitle) : null);
  }

  Widget accResultOf(bool isSvt, int rarity) {
    List<Widget> counts = [];
    int totalCount = 0;
    allSummons.forEach((card, value) {
      if ((isSvt && card is Servant && card.rarity == rarity) ||
          (!isSvt && card is CraftEssence && card.rarity == rarity)) {
        counts.add(_cardIcon(card, value.toString()));
        totalCount += value;
      }
    });
    return SimpleAccordion(
      expanded: rarity > 3,
      headerBuilder: (context, _) => ListTile(
        dense: true,
        title: Text('$kStarChar$rarity ${isSvt ? S.current.servant : S.current.craft_essence}'),
        trailing: Text(totalCount.toString()),
      ),
      contentBuilder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Center(child: Wrap(children: counts)),
      ),
    );
  }

  Widget get dropdownButton {
    List<DropdownMenuItem<int>> items = [];
    items.addAll(
      summon.subSummons.map(
        (e) => DropdownMenuItem(
          value: summon.subSummons.indexOf(e),
          child: AutoSizeText(
            SummonUtil.summonNameLocalize(e.title),
            maxLines: 2,
            maxFontSize: 14,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Text('${S.current.summon_daily}: ', style: const TextStyle(color: Colors.redAccent)),
          Flexible(
            child: Container(
              decoration: BoxDecoration(border: Border(bottom: Divider.createBorderSide(context))),
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
          ),
        ],
      ),
    );
  }

  bool _expanded = false;

  Widget get details {
    List<Widget> svtRow = [];
    for (final block in data.svts) {
      if (block.ids.isEmpty) continue;
      if (!_expanded && !block.display) {
        if (block.rarity == 5 &&
            summon.isLuckyBag &&
            data.svts.where((e) => e.rarity == 5).length == 1 &&
            block.ids.length < 100) {
          //
        } else {
          continue;
        }
      }
      double weight = block.weight / block.ids.length;
      for (final id in block.ids) {
        Servant? svt = db.gameData.servantsNoDup[id];
        if (svt == null) continue;
        svtRow.add(
          SummonUtil.buildCard(context: context, card: svt, weight: weight, showCategory: true, showNpLv: false),
        );
      }
    }

    List<Widget> craftRow = [];
    for (final block in data.crafts) {
      if (block.ids.isEmpty) continue;
      if (!_expanded && !block.display) continue;
      double weight = block.weight / block.ids.length;
      for (final id in block.ids) {
        CraftEssence? ce = db.gameData.craftEssences[id];
        if (ce == null) continue;
        craftRow.add(SummonUtil.buildCard(context: context, card: ce, weight: weight));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (svtRow.isNotEmpty) Wrap(spacing: 4, runSpacing: 4, children: svtRow),
          const SizedBox(height: 4),
          if (craftRow.isNotEmpty) Wrap(spacing: 4, runSpacing: 4, children: craftRow),
          Center(
            child: ExpandIcon(
              onPressed: (v) {
                setState(() {
                  _expanded = !v;
                });
              },
              isExpanded: _expanded,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget get destinyOrderSelects {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final classId in summon.destinyClasses)
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                constraints: const BoxConstraints(maxWidth: 56),
                child: buildDestinyClassSelect(classId),
              ),
            ),
        ],
      ),
    );
  }

  Map<int, Servant> selectedDestinyOrderServants = {};
  SvtFilterData destinyOrderSvtFilter = SvtFilterData();

  Widget buildDestinyClassSelect(int clsId) {
    final svtClass2 = SvtClass.fromInt(clsId) ?? SvtClass.unknown;
    final svt = selectedDestinyOrderServants[clsId];
    Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        db.getIconImage(SvtClassX.clsIcon(clsId, 5), width: 32, height: 32, padding: const EdgeInsets.all(4)),
        CachedImage(imageUrl: svt?.customIcon ?? Atlas.common.emptySvtIcon, aspectRatio: 132 / 144),
      ],
    );
    child = InkWell(
      onTap: () {
        router.pushPage(
          ServantListPage(
            filterData: destinyOrderSvtFilter
              ..svtClass.options = SvtClassX.resolveClasses(svtClass2, expandBeast: false).toSet()
              ..rarity.options = {5},
            onSelected: (selectedSvt) {
              if (selectedSvt.type == SvtType.normal &&
                  selectedSvt.collectionNo > 0 &&
                  selectedSvt.rarity == 5 &&
                  SvtClassX.match(selectedSvt.className, svtClass2) &&
                  data.svts.any((e) => e.ids.contains(selectedSvt.collectionNo))) {
                if (mounted) {
                  setState(() {
                    selectedDestinyOrderServants[clsId] = selectedSvt;
                  });
                }
              } else {
                EasyLoading.showError(S.current.invalid_input);
              }
            },
          ),
        );
      },
      onLongPress: () {
        selectedDestinyOrderServants.remove(clsId);
        setState(() {});
      },
      child: child,
    );
    return child;
  }

  Widget curResult() {
    if (history.isEmpty) return Container();

    Widget _buildRow(List rowItems) {
      return Row(mainAxisSize: MainAxisSize.min, children: rowItems.map((e) => _cardIcon(e)).toList());
    }

    Widget _buildOneHistory(List data) {
      List<Widget> rows = [];
      rows.add(_buildRow(data.sublist(0, min(6, data.length))));
      if (data.length > 6) rows.add(_buildRow(data.sublist(6, data.length)));
      Widget child = Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Center(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: rows),
        ),
      );
      if (data.isNotEmpty) {
        child = FittedBox(fit: BoxFit.contain, child: child);
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
                constraints: const BoxConstraints(maxHeight: 240),
                child: AspectRatio(aspectRatio: 6 / 2 * 132 / 144, child: _buildOneHistory(history[_curHistory])),
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
        Text('${_curHistory + 1}/${history.length}', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget get gacha1 {
    String iconKey;
    int gachaNum = 1;
    if (summon.rollCount != 11) {
      iconKey = 'gacha1_old.png';
    } else if (totalPulls % 11 == 9) {
      iconKey = 'gacha2.png';
      gachaNum = 2;
    } else {
      iconKey = 'gacha1.png';
    }
    return _summonButton(times: gachaNum, quartz: 3, fn: iconKey);
  }

  Widget get gacha10 {
    return _summonButton(
      times: summon.rollCount,
      quartz: 30,
      fn: summon.rollCount == 11 ? 'gacha11.png' : 'gacha10_old.png',
    );
  }

  Widget get gachaLucky {
    return _summonButton(
      times: summon.rollCount,
      quartz: summon.isDestiny ? 30 : 15,
      fn: summon.rollCount == 11 ? 'gacha11_gssr.png' : 'gacha10_gssr.png',
    );
  }

  Widget _summonButton({required int times, required int quartz, required String fn}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: InkWell(
        onTap: () => startGacha(times, quartz),
        child: db.getIconImage(
          'https://assets.chaldea.center/images/$fn',
          height: 50,
          placeholder: (context) =>
              ElevatedButton(onPressed: () => startGacha(times, quartz), child: Text('Gacha $times')),
        ),
      ),
    );
  }

  Widget _cardIcon(GameCardMixin card, [String? text]) {
    return card.iconBuilder(
      context: context,
      text: text,
      width: 48,
      padding: const EdgeInsets.all(1),
      option: ImageWithTextOption(padding: const EdgeInsets.only(right: 4, bottom: 4)),
    );
  }

  void startGacha(int times, int quartz) {
    final destinyClasses = summon.destinyClasses;
    if (summon.isDestiny && !selectedDestinyOrderServants.keys.toSet().equalTo(destinyClasses.toSet())) {
      EasyLoading.showInfo("Only ${selectedDestinyOrderServants.length}/${destinyClasses.length} selected!");
      return;
    }
    List<GameCardMixin> newAdded = summonWithGuarantee(times);
    newAdded.shuffle(random);
    for (final element in newAdded) {
      allSummons[element] = (allSummons[element] ?? 0) + 1;
    }
    history.add(newAdded);
    totalPulls += times;
    totalQuartz += quartz;
    _curHistory = history.length - 1;
    _debugPullCount += 1;
    setState(() {});
  }

  void monteCarloTest() async {
    // standards: 1+3+40+4+12+40
    // Monte Carlo test
    // 1. before chaldea 2024.05.14:
    //    100(11000000) =  1.03640 +  3.11976 + 39.80255 +  4.15877 + 12.48025 + 39.40226
    // 2. start from 2024.05.14
    //    100(1100000)  =  1.03155 +  2.97573 + 41.12909 +  4.00864 + 18.14609 + 32.70891

    final String? _inputTenCount = await InputCancelOkDialog.number(
      title: "Monte Carlo Test: N×${summon.rollCount}",
      initValue: 100000,
      validate: (v) => v > 0,
    ).showDialog(context);
    if (_inputTenCount == null) return;

    final inputTenCount = int.parse(_inputTenCount);
    int total = 0, s5 = 0, s4 = 0, s3 = 0, c5 = 0, c4 = 0, c3 = 0;

    String _percent(int x) => (x / total * 100).toStringAsFixed(5).padLeft(8);

    for (int i = 0; i < inputTenCount; i++) {
      final cards = summonWithGuarantee(summon.rollCount);
      total += cards.length;
      s5 += cards.where((e) => e is Servant && e.rarity == 5).length;
      s4 += cards.where((e) => e is Servant && e.rarity == 4).length;
      s3 += cards.where((e) => e is Servant && e.rarity == 3).length;
      c5 += cards.where((e) => e is CraftEssence && e.rarity == 5).length;
      c4 += cards.where((e) => e is CraftEssence && e.rarity == 4).length;
      c3 += cards.where((e) => e is CraftEssence && e.rarity == 3).length;
      if ((i + 1) % (inputTenCount / 100) == 0 || i + 1 == inputTenCount) {
        print(
          '${i + 1}: 100($total) ='
          ' ${_percent(s5)} +'
          ' ${_percent(s4)} +'
          ' ${_percent(s3)} +'
          ' ${_percent(c5)} +'
          ' ${_percent(c4)} +'
          ' ${_percent(c3)}',
        );
      }
    }
    if (!mounted) return;
    SimpleConfirmDialog(
      scrollable: true,
      showCancel: false,
      title: const Text("Monte Carlo Test"),
      content: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              style: Theme.of(context).textTheme.bodySmall,
              children: [
                TextSpan(text: summon.lName.l),
                TextSpan(
                  text:
                      '\ntype=${Transl.enums(summon.type, (enums) => enums.summonType).l}, destiny=${summon.isDestiny}',
                ),
              ],
            ),
            TextSpan(
              style: kMonoStyle,
              children: [
                TextSpan(
                  text:
                      '\nCount: $inputTenCount×${summon.rollCount}=${total.format(compact: false, groupSeparator: ",")}',
                ),
                TextSpan(
                  text:
                      '\nsvt : ${_percent(s5 + s4 + s3)}\n  5★ ${_percent(s5)}\n  4★ ${_percent(s4)}\n  3★ ${_percent(s3)}',
                ),
                TextSpan(
                  text:
                      '\nce  : ${_percent(c5 + c4 + c3)}\n  5★ ${_percent(c5)}\n  4★ ${_percent(c4)}\n  3★ ${_percent(c3)}',
                ),
              ],
            ),
          ],
        ),
      ),
    ).showDialog(context, barrierDismissible: false);
  }

  /// 保底:
  /// - Destiny Order(SSR): 5★Destiny -> 4★卡牌 -> 3★从者 -> others
  /// - 福袋(SSR): 5★从者 -> 4★卡牌 -> 3★从者 -> others
  /// - 福袋(SSR+SR): 5★从者 -> 4★从者 -> 4★卡牌 -> 3★从者 -> others
  /// - 普通: 4★卡牌 -> 3★从者 -> others
  List<GameCardMixin> summonWithGuarantee(int times) {
    List<GameCardMixin> results = [];

    if (times >= 10) {
      int hasCe5Count = 0;

      Map<GameCardMixin, double> _scaleProbs(Map<GameCardMixin, double> probs, double totalProb) {
        final scale = totalProb / Maths.sum(probs.values);
        return probs.map((key, value) => MapEntry(key, value * scale));
      }

      void _guarantee(Map<int, double> svtProbs, Map<int, double> ceProbs, int n) {
        assert((Maths.sum([...svtProbs.values, ...ceProbs.values]) - 100).abs() < 0.001, "$svtProbs, $ceProbs");
        if (ceProbs.containsKey(5) && ceProbs[5]! > 0) {
          hasCe5Count += 1;
        }
        Map<GameCardMixin, double> _probs = {};
        for (final (rarity, totalProb) in svtProbs.items) {
          _probs.addAll(_scaleProbs(_cardProbs([rarity], true, false), totalProb));
        }
        for (final (rarity, totalProb) in ceProbs.items) {
          _probs.addAll(_scaleProbs(_cardProbs([rarity], false, true), totalProb));
        }
        results.addAll(randomSummon(_probs, n));
      }

      void _gSvt5() {
        _guarantee({5: 100}, {}, 1);
      }

      void _gSvt4() {
        _guarantee({5: 1, 4: 99}, {}, 1);
      }

      void _gSvt3() {
        _guarantee({5: 1, 4: 3, 3: 96}, {}, 1);
      }

      void _gCard4() {
        _guarantee({5: 1, 4: 3}, {5: 4, 4: 92}, 1);
      }

      if (summon.isLuckyBag) {
        if (summon.isDestiny) {
          final destinyProbs = <Servant, double>{
            for (final svt in selectedDestinyOrderServants.values)
              svt: data.svts.firstWhere((e) => e.rarity == 5 && e.ids.contains(svt.collectionNo)).singleWeight,
          };
          results.addAll(randomSummon(destinyProbs, 1));
          _gCard4();
          _gSvt3();
        } else if (summon.type == SummonType.gssr) {
          _gSvt5();
          _gCard4();
          _gSvt3();
        } else if (summon.type == SummonType.gssrsr) {
          _gSvt5();
          _gSvt4();
          _gCard4();
          _gSvt3();
        }
      } else {
        _gCard4();
        _gSvt3();
      }
      // 剩余7抽：五星从1：四星从3：五星礼5.71（40/7）：四星礼12：三星礼40：三星从38.29
      // 五星礼4%*（总抽数-可以保底金礼装抽数）/（保底外的剩余抽数）
      final leftPulls = times - results.length;
      final ce5Prob = 4 * (times - hasCe5Count) / leftPulls;
      _guarantee({5: 1, 4: 3, 3: 44 - ce5Prob}, {5: ce5Prob, 4: 12, 3: 40}, leftPulls);
    } else {
      results.addAll(randomSummon(_cardProbs([], true, true), times));
    }

    results.shuffle(random);
    return results;
  }

  final random = Random(DateTime.now().microsecondsSinceEpoch);

  /// 无任何保底，纯随机
  List<GameCardMixin> randomSummon(Map<GameCardMixin, double> probMap, int times) {
    if (probMap.isEmpty) return [];
    final probList = probMap.entries.toList();
    probList.shuffle();
    List<GameCardMixin> result = [];
    double totalProb = 0;
    for (final element in probList) {
      totalProb += element.value;
    }
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

  Map<GameCardMixin, double> _cardProbs(List<int> rarities, bool svt, bool ce) {
    Map<GameCardMixin, double> probs = {};
    for (final block in data.probs) {
      if (rarities.isNotEmpty && !rarities.contains(block.rarity)) continue;
      if (!(block.isSvt ? svt : ce)) continue;
      _addProbMap(result: probs, ids: block.ids, totalWeight: block.weight, isSvt: block.isSvt);
    }
    return probs;
  }

  // ignore: unused_element
  void _printMap(Map<GameCardMixin, double> probs) {
    // Map s = {};
    // probs.forEach((key, value) {
    //   s[key] = value.toStringAsFixed(3).trimCharRight('0');
    // });
    // print(s);
  }

  Servant? svtFromId(int id) => db.gameData.servantsNoDup[id];

  CraftEssence? craftFromId(int id) => db.gameData.craftEssences[id];

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
      var key = (isSvt ? db.gameData.servantsNoDup : db.gameData.craftEssences)[id];
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
