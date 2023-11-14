import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/summon/summon_simulator_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'summon_util.dart';

const int _kScoreMin = 0, _kScoreMax = 5;

class LuckyBagExpectation extends StatefulWidget {
  final LimitedSummon summon;

  const LuckyBagExpectation({super.key, required this.summon});

  @override
  _LuckyBagExpectationState createState() => _LuckyBagExpectationState();
}

class _LuckyBagExpectationState extends State<LuckyBagExpectation> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ScrollController _scrollController1 = ScrollController();
  late final ScrollController _scrollController2 = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _scrollController1.dispose();
    _scrollController2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(widget.summon.lName.l, maxLines: 1),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) {
                  return SimpleDialog(
                    title: Text(S.current.reset),
                    children: [
                      SimpleDialogOption(
                        onPressed: () => reset(context, _kScoreMin),
                        child: const Text('All $_kScoreMin'),
                      ),
                      SimpleDialogOption(
                        onPressed: () => reset(context, _kScoreMax),
                        child: const Text('All $_kScoreMax'),
                      ),
                      SimpleDialogOption(
                        onPressed: () => reset(context, null),
                        child: Text('${FavoriteState.owned.shownName}→$_kScoreMin,'
                            ' ${FavoriteState.other.shownName}→$_kScoreMax'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.replay),
            tooltip: S.current.reset,
          ),
        ],
        bottom: FixedHeight.tabBar(TabBar(
          controller: _tabController,
          tabs: [Tab(text: S.current.lucky_bag_rating), Tab(text: S.current.lucky_bag_expectation)],
        )),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveBuilder(builder: (context) => inputTab),
          KeepAliveBuilder(builder: (context) => resultTab),
        ],
      ),
    );
  }

  Map<int, int> get _svtScores => db.curUser.luckyBagSvtScores.putIfAbsent(widget.summon.id, () => {});

  int scoreOf(int id) {
    return _svtScores[id] ?? (db.curUser.svtStatusOf(id).favorite ? _kScoreMin : _kScoreMax);
  }

  Widget get inputTab {
    List<Widget> children = [];
    for (final data in widget.summon.subSummons) {
      for (final block in data.svts) {
        if (block.rarity == 5 /*|| (block.rarity == 4 && showSR)*/) {
          children.add(SHeader(SummonUtil.summonNameLocalize(data.title)));
          for (final svtId in block.ids) {
            final svt = db.gameData.servantsNoDup[svtId];
            if (svt == null) continue;
            children.add(ListTile(
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child:
                    SummonUtil.svtAvatar(context: context, card: svt, category: false, favorite: svt.status.favorite),
              ),
              horizontalTitleGap: 0,
              title: Row(
                children: List.generate(
                  _kScoreMax - _kScoreMin + 1,
                  (index) => Expanded(
                    child: Radio<int>(
                      value: index,
                      groupValue: scoreOf(svtId),
                      onChanged: (v) {
                        setState(() {
                          if (v != null) _svtScores[svtId] = v;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ));
          }
        }
      }
    }
    return Column(
      children: [
        ListTile(
          leading: db.getIconImage(null, width: 40),
          tileColor: Theme.of(context).highlightColor,
          horizontalTitleGap: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          title: Row(
            children: List.generate(
              _kScoreMax - _kScoreMin + 1,
              (index) => Expanded(
                child: Center(child: Tooltip(message: _scoreTooltip(index), child: Text('$index'))),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            controller: _scrollController1,
            padding: const EdgeInsets.only(bottom: 16),
            children: children,
          ),
        )
      ],
    );
  }

  String _scoreTooltip(int score) {
    switch (score) {
      case _kScoreMin:
        return S.current.lucky_bag_tooltip_unwanted;
      // case 1:
      // case 2:
      // case 3:
      // case 4:
      case _kScoreMax:
        return S.current.lucky_bag_tooltip_wanted;
      default:
        return score.toString();
    }
  }

  void reset(BuildContext context, int? v) {
    final scores = _svtScores;
    scores.clear();
    if (v != null) {
      for (final data in widget.summon.subSummons) {
        final block = data.svts.firstWhereOrNull((e) => e.rarity == 5);
        if (block == null) continue;
        for (final id in block.ids) {
          scores[id] = v;
        }
      }
    }
    Navigator.pop(context);
    if (mounted) setState(() {});
  }

  _ExpSort _sortType = _ExpSort.exp;
  int minScore = _kScoreMax - 1;
  int maxScore = _kScoreMin + 1;

  Widget get resultTab {
    List<_ExpResult> results = [];
    for (final data in widget.summon.subSummons) {
      final block = data.svts.firstWhereOrNull((e) => e.rarity == 5);
      if (block == null || block.ids.isEmpty) continue;
      _ExpResult _result = _ExpResult(data, block);
      _result.exp = Maths.sum(block.ids.map((id) => scoreOf(id))) / block.ids.length;
      if (block.ids.length < 2) {
        _result.sd = 0;
      } else {
        final scores = block.ids.map((e) => scoreOf(e)).toList();
        double meanA = Maths.sum(scores) / scores.length;
        double variance = 0.0;
        for (var el in scores) {
          variance += (el - meanA) * (el - meanA);
        }
        variance /= scores.length - 1;
        _result.sd = sqrt(variance);
      }

      // return temp / (a.length - 1);
      _result.best5 = block.ids.where((id) => scoreOf(id) == _kScoreMax).length;
      _result.worst0 = block.ids.where((id) => scoreOf(id) == _kScoreMin).length;
      _result.moreThan = block.ids.where((id) => scoreOf(id) >= minScore).length;
      _result.lessThan = block.ids.where((id) => scoreOf(id) <= maxScore).length;
      results.add(_result);
    }

    switch (_sortType) {
      case _ExpSort.exp:
        results.sort((a, b) => b.exp.compareTo(a.exp));
        break;
      case _ExpSort.best5:
        results.sort((a, b) => b.pBest5.compareTo(a.pBest5));
        break;
      case _ExpSort.worst0:
        results.sort((a, b) => b.pWorst0.compareTo(a.pWorst0));
        break;
      case _ExpSort.moreThan:
        results.sort((a, b) => b.pMoreThan.compareTo(a.pMoreThan));
        break;
      case _ExpSort.lessThan:
        results.sort((a, b) => b.pLessThan.compareTo(a.pLessThan));
        break;
    }
    List<Widget> children = [];
    for (final _result in results) {
      children.add(InkWell(
        onTap: () {
          router.pushPage(SummonSimulatorPage(
            summon: widget.summon,
            initIndex: widget.summon.subSummons.indexOf(_result.data),
          ));
        },
        child: SHeader(SummonUtil.summonNameLocalize(_result.data.title)),
      ));

      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
        child: Wrap(
          spacing: 2,
          runSpacing: 2,
          children: _result.block.ids.map((id) {
            final svt = db.gameData.servantsNoDup[id];
            if (svt == null) return Text('ID $id');
            return SummonUtil.svtAvatar(
              context: context,
              card: svt,
              favorite: svt.status.favorite,
              npLv: true,
              width: 48,
              extraText: scoreOf(svt.collectionNo).toString(),
            );
          }).toList(),
        ),
      ));
      int n = _result.block.ids.length;
      String _toPercent(double number) {
        return number.format(percent: true, precision: 1);
      }

      final textCells = [
        '${_result.exp.toStringAsFixed(2)}\n±${_result.sd.toStringAsFixed(2)}',
        '${_toPercent(_result.pBest5)}\n${_result.best5}/$n',
        '${_toPercent(_result.pWorst0)}\n${_result.worst0}/$n',
        '${_toPercent(_result.pMoreThan)}\n${_result.moreThan}/$n',
        '${_toPercent(_result.pLessThan)}\n${_result.lessThan}/$n',
      ];
      children.add(ListTile(
        dense: true,
        // shape: const RoundedRectangleBorder(
        //     borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))),
        title: Row(
          children: [
            for (int index = 0; index < textCells.length; index++)
              Expanded(
                child: Text(
                  textCells[index],
                  style: TextStyle(
                      color: _sortType.index == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.bodyMedium?.color),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                ),
              ),
          ],
        ),
      ));
      children.add(kIndentDivider);
    }

    Widget _underline(Widget child, bool underline) {
      // if (!underline) return child;
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: underline ? Theme.of(context).colorScheme.secondary : Colors.transparent,
            ),
          ),
        ),
        child: child,
      );
    }

    return Column(
      children: [
        ListTile(
          tileColor: Theme.of(context).highlightColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          title: Row(
            children: [
              for (final entry in {
                _ExpSort.exp: S.current.lucky_bag_expectation_short,
                _ExpSort.best5: '${S.current.lucky_bag_best}=$_kScoreMax',
                _ExpSort.worst0: '${S.current.lucky_bag_worst}=$_kScoreMin'
              }.entries)
                Expanded(
                  child: _underline(
                    InkWell(
                      onTap: () {
                        setState(() {
                          _sortType = entry.key;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: AutoSizeText(
                          entry.value,
                          minFontSize: 6,
                          maxFontSize: 14,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    _sortType == entry.key,
                  ),
                ),
              Expanded(
                child: _underline(
                  Center(
                    child: DropdownButton<int>(
                      value: minScore,
                      items: [
                        for (int score = _kScoreMin + 1; score <= _kScoreMax - 1; score++)
                          DropdownMenuItem(value: score, child: Text('≥$score'))
                      ],
                      onChanged: (v) {
                        setState(() {
                          if (v != null) minScore = v;
                          _sortType = _ExpSort.moreThan;
                        });
                      },
                      isDense: true,
                      underline: Container(),
                    ),
                  ),
                  _sortType == _ExpSort.moreThan,
                ),
              ),
              Expanded(
                child: _underline(
                  Center(
                    child: DropdownButton<int>(
                      value: maxScore,
                      items: [
                        for (int score = _kScoreMin + 1; score <= _kScoreMax - 1; score++)
                          DropdownMenuItem(value: score, child: Text('≤$score'))
                      ],
                      onChanged: (v) {
                        setState(() {
                          if (v != null) maxScore = v;
                          _sortType = _ExpSort.lessThan;
                        });
                      },
                      isDense: true,
                      underline: Container(),
                    ),
                  ),
                  _sortType == _ExpSort.lessThan,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: _scrollController2,
            padding: const EdgeInsets.only(bottom: 16),
            children: children,
          ),
        )
      ],
    );
  }
}

enum _ExpSort {
  exp,
  best5,
  worst0,
  moreThan,
  lessThan,
}

class _ExpResult {
  SubSummon data;
  ProbGroup block;
  double exp = 0;
  double sd = 0;
  int best5 = 0;
  int worst0 = 0;
  int moreThan = 0;
  int lessThan = 0;

  _ExpResult(this.data, this.block);

  double get pBest5 => best5 / block.ids.length;

  double get pWorst0 => worst0 / block.ids.length;

  double get pMoreThan => moreThan / block.ids.length;

  double get pLessThan => lessThan / block.ids.length;
}
