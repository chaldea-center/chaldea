import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'summon_util.dart';

class LuckyBagExpectation extends StatefulWidget {
  final LimitedSummon summon;

  const LuckyBagExpectation({Key? key, required this.summon}) : super(key: key);

  @override
  _LuckyBagExpectationState createState() => _LuckyBagExpectationState();
}

class _LuckyBagExpectationState extends State<LuckyBagExpectation>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController1;
  late ScrollController _scrollController2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
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
        title: AutoSizeText(widget.summon.lName, maxLines: 1),
        bottom: FixedHeight.tabBar(TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: S.current.lucky_bag_rating),
            Tab(text: S.current.lucky_bag_expectation)
          ],
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

  Map<int, int> get _svtScores =>
      db.curUser.luckyBagSvtScores.putIfAbsent(widget.summon.id, () => {});

  int scoreOf(int id) {
    return _svtScores[id] ?? (db.curUser.svtStatusOf(id).favorite ? 1 : 5);
  }

  Widget get inputTab {
    List<Widget> children = [];
    for (final data in widget.summon.subSummons) {
      for (final block in data.svts) {
        if (block.rarity == 5 /*|| (block.rarity == 4 && showSR)*/) {
          children.add(SHeader(SummonUtil.summonNameLocalize(data.title)));
          for (final svtId in block.ids) {
            final svt = db.gameData.servants[svtId];
            if (svt == null) continue;
            children.add(ListTile(
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: SummonUtil.svtAvatar(
                    context: context,
                    card: svt,
                    category: false,
                    favorite: svt.status.favorite),
              ),
              horizontalTitleGap: 0,
              title: Row(
                children: List.generate(
                  5,
                  (index) => Expanded(
                    child: Radio<int>(
                      value: index + 1,
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          title: Row(
            children: List.generate(
              5,
              (index) => Expanded(
                child: Center(
                    child: Tooltip(
                        message: _scoreTooltip(index + 1),
                        child: Text('${index + 1}'))),
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
      case 1:
        return S.current.lucky_bag_tooltip_unwanted;
      // case 2:
      // case 3:
      // case 4:
      case 5:
        return S.current.lucky_bag_tooltip_wanted;
      default:
        return score.toString();
    }
  }

  _ExpSort _sortType = _ExpSort.exp;
  int minScore = 4;
  int maxScore = 2;

  Widget get resultTab {
    List<_ExpResult> results = [];
    for (final data in widget.summon.subSummons) {
      final block = data.svts.firstWhereOrNull((e) => e.rarity == 5);
      if (block == null || block.ids.isEmpty) continue;
      _ExpResult _result = _ExpResult(data, block);
      _result.exp =
          Maths.sum(block.ids.map((id) => scoreOf(id))) / block.ids.length;
      _result.best5 = block.ids.where((id) => scoreOf(id) == 5).length;
      _result.worst1 = block.ids.where((id) => scoreOf(id) == 1).length;
      _result.moreThan =
          block.ids.where((id) => scoreOf(id) >= minScore).length;
      _result.lessThan =
          block.ids.where((id) => scoreOf(id) <= maxScore).length;
      results.add(_result);
    }
    switch (_sortType) {
      case _ExpSort.exp:
        results.sort((a, b) => b.exp.compareTo(a.exp));
        break;
      case _ExpSort.best5:
        results.sort((a, b) => b.pBest5.compareTo(a.pBest5));
        break;
      case _ExpSort.worst1:
        results.sort((a, b) => b.pWorst1.compareTo(a.pWorst1));
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
      children.add(SHeader(SummonUtil.summonNameLocalize(_result.data.title)));
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
        child: Wrap(
          spacing: 2,
          runSpacing: 2,
          children: _result.block.ids.map((id) {
            final svt = db.gameData.servants[id];
            if (svt == null) return Text('ID $id');
            return SummonUtil.svtAvatar(
              context: context,
              card: svt,
              favorite: svt.status.favorite,
              npLv: true,
              width: 48,
            );
          }).toList(),
        ),
      ));
      int n = _result.block.ids.length;
      String _toPercent(double number) {
        return number.format(percent: true, precision: 1);
      }

      children.add(ListTile(
        // tileColor: Theme.of(context).highlightColor,
        dense: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))),
        title: DefaultTextStyle(
          style: TextStyle(
              // fontSize: 14,
              color: Theme.of(context).textTheme.bodyText2?.color),
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible,
          child: Row(
            children: [
              Expanded(child: Text(_result.exp.toStringAsFixed(2))),
              Expanded(
                child: Text(
                  '${_toPercent(_result.pBest5)}\n${_result.best5}/$n',
                ),
              ),
              Expanded(
                child: Text(
                  '${_toPercent(_result.pWorst1)}\n${_result.worst1}/$n',
                ),
              ),
              Expanded(
                child: Text(
                  '${_toPercent(_result.pMoreThan)}\n${_result.moreThan}/$n',
                ),
              ),
              Expanded(
                child: Text(
                  '${_toPercent(_result.pLessThan)}\n${_result.lessThan}/$n',
                ),
              ),
            ],
          ),
        ),
      ));
      children.add(kIndentDivider);
    }

    Widget _underline(Widget child, bool underline) {
      if (!underline) return child;
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        child: child,
      );
    }

    return Column(
      children: [
        ListTile(
          tileColor: Theme.of(context).highlightColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          title: Row(
            children: [
              Expanded(
                child: _underline(
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _sortType = _ExpSort.exp;
                      });
                    },
                    child: Text(
                      S.current.lucky_bag_expectation_short,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  _sortType == _ExpSort.exp,
                ),
              ),
              Expanded(
                child: _underline(
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _sortType = _ExpSort.best5;
                      });
                    },
                    child: const Text(
                      'Best/5',
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  _sortType == _ExpSort.best5,
                ),
              ),
              Expanded(
                child: _underline(
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _sortType = _ExpSort.worst1;
                      });
                    },
                    child: const Text(
                      'Worst/1',
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  _sortType == _ExpSort.worst1,
                ),
              ),
              Expanded(
                child: _underline(
                  Center(
                    child: DropdownButton<int>(
                      value: minScore,
                      items: [
                        for (int score in [2, 3, 4])
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
                        for (int score in [2, 3, 4])
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
  worst1,
  moreThan,
  lessThan,
}

class _ExpResult {
  SubSummon data;
  ProbGroup block;
  double exp = 0;
  int best5 = 0;
  int worst1 = 0;
  int moreThan = 0;
  int lessThan = 0;

  _ExpResult(this.data, this.block);

  double get pBest5 => best5 / block.ids.length;

  double get pWorst1 => worst1 / block.ids.length;

  double get pMoreThan => moreThan / block.ids.length;

  double get pLessThan => lessThan / block.ids.length;
}
