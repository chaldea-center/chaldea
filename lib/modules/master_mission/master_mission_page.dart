import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:catcher/catcher.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';
import 'package:chaldea/packages/js_engine/js_engine.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';

final localized = Localized.masterMission;

List<WeeklyMissionQuest> get _missionData =>
    db.gameData.planningData.weeklyMissions;

String _convertLocalized(String key) {
  return key.split('_').map((e) => localized.of(e)).join('_');
}

class MasterMissionPage extends StatefulWidget {
  MasterMissionPage({Key? key}) : super(key: key);

  @override
  _MasterMissionPageState createState() => _MasterMissionPageState();
}

class _MasterMissionPageState extends State<MasterMissionPage>
    with SingleTickerProviderStateMixin {
  List<LocalizedText> tabNames = const [
    LocalizedText(chs: '一般特性', jpn: '共有特性', eng: 'General Trait', kor: '일반 특성'),
    LocalizedText(
        chs: '从者职阶', jpn: 'サーヴァントクラス', eng: 'Servant Class', kor: '서번트 클래스'),
    LocalizedText(
        chs: '从者特性', jpn: 'サーヴァント特性', eng: 'Servant Trait', kor: '서번트 속성'),
    LocalizedText(
        chs: '小怪职阶', jpn: 'エネミークラス', eng: 'Enemy Class', kor: '적 클래스'),
    LocalizedText(chs: '小怪特性', jpn: 'エネミー特性', eng: 'Enemy Trait', kor: '적 속성'),
    LocalizedText(chs: '场地特性', jpn: 'フィールド', eng: 'Battle Field', kor: '필드'),
  ];
  List<String> classTypes = const ['剑阶', '弓阶', '枪阶', '骑阶', '术阶', '杀阶', '狂阶'];
  late TabController _tabController;
  int _curTab = 0;
  bool _showFilters = true;

  // search
  String _searchString = '';
  bool _showSearch = false;
  late TextEditingController _searchController;

  // data
  late WeeklyFilterData filterData;
  List<WeeklyFilterData> missions = [];
  Map<WeeklyMissionQuest, num> solution = {};

  // solver
  JsEngine engine = JsEngine();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabNames.length, vsync: this);
    _searchController = TextEditingController();
    filterData = WeeklyFilterData.fromQuests(_missionData);
    engine.init(() async {
      await engine.eval(await rootBundle.loadString('res/js/glpk.min.js'),
          name: '<glpk.min.js>');
      await engine.eval(await rootBundle.loadString('res/js/glpk_solver.js'),
          name: 'glpk_solver.js');
      print('js engine initiated');
    }).catchError((e, s) async {
      logger.e('initiate js libs error', e, s);
      Catcher.reportCheckedError(e, s);
      if (mounted) {
        SimpleCancelOkDialog(
          title: const Text('Init Error'),
          content: Text('$e\n\n$s'),
        ).showDialog(context);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    gapPadding: 0,
                  ),
                  hintText: 'Search',
                  isDense: true,
                  contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  filled: true,
                  fillColor: Theme.of(context).secondaryHeaderColor,
                  focusColor: Theme.of(context).secondaryHeaderColor,
                ),
                onChanged: (s) {
                  setState(() {
                    _searchString = s.trim();
                  });
                },
              )
            : Text(S.current.master_mission),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _searchString = '';
                _showSearch = !_showSearch;
              });
            },
            icon: const Icon(Icons.search),
            tooltip: S.current.search,
          ),
          if (!_showSearch) popupMenu,
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabNames.map((e) => Tab(text: e.localized)).toList(),
          onTap: (index) {
            setState(() {
              _showFilters =
                  _tabController.index == _curTab ? !_showFilters : true;
              _curTab = _tabController.index;
            });
          },
        ),
      ),
      body: ListView(
        children: divideTiles([
          filters,
          actionBar,
          missionListView,
          solutionList,
          relatedQuests,
        ]),
      ),
    );
  }

  Widget get filters {
    Set<String> keys;
    bool Function(String)? isChecked;
    void Function(String, bool)? onTap;

    if (_curTab == 0) {
      keys = filterData.generalTraits;
      isChecked = (key) =>
          (filterData.checked['从者_$key'] ?? false) &&
          (filterData.checked['小怪_$key'] ?? false);
      onTap = (key, checked) {
        filterData.checked['从者_$key'] = !checked;
        filterData.checked['小怪_$key'] = !checked;
      };
    } else if (_curTab == 1) {
      keys = classTypes.map((e) => '从者_$e').toSet();
    } else if (_curTab == 2) {
      keys = filterData.servantTraits
          .where((e) => !classTypes.contains(_removePrefix(e)))
          .toSet();
    } else if (_curTab == 3) {
      keys = classTypes.map((e) => '小怪_$e').toSet();
    } else if (_curTab == 4) {
      keys = filterData.enemyTraits
          .where((e) => !classTypes.contains(_removePrefix(e)))
          .toSet();
    } else {
      keys = filterData.battlefields;
    }
    List<String> sortedKeys = keys.toList();
    sortedKeys = sortedKeys.where((key) {
      if (!_showSearch || _searchString.isEmpty) return true;
      return _getLocalizedKey(key)
          .toLowerCase()
          .contains(_searchString.toLowerCase());
    }).toList();
    if (_curTab != 1 && _curTab != 3) {
      sortedKeys.sort((a, b) => _getLocalizedKey(a, alphabetical: true)
          .compareTo(_getLocalizedKey(b, alphabetical: true)));
    }
    return AnimatedCrossFade(
      firstChild: Container(height: 0.0),
      secondChild: _buildTraits(sortedKeys, isChecked, onTap),
      firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
      secondCurve: const Interval(0.4, 1, curve: Curves.fastOutSlowIn),
      sizeCurve: Curves.fastOutSlowIn,
      crossFadeState:
          _showFilters ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
    );
  }

  final Map<String, String> _shownTexts = {};

  String _getLocalizedKey(String key, {bool alphabetical = false}) {
    String text = _shownTexts[key] ??= localized.of(_removePrefix(key));
    if (alphabetical) {
      if (Language.isCN) {
        text = PinyinHelper.getPinyin(text);
      } else if (Language.isJP) {
        text = Utils.kanaKit.toRomaji(text);
      }
    }
    return text;
  }

  Widget _buildTraits(List<String> keys, bool Function(String key)? isChecked,
      void Function(String key, bool checked)? onTap) {
    List<Widget> children = [];
    keys.forEach((key) {
      bool checked = isChecked == null
          ? (filterData.checked[key] ?? false)
          : isChecked(key);
      final onPressed = onTap == null
          ? () {
              setState(() {
                filterData.checked[key] = !(filterData.checked[key] ?? false);
              });
            }
          : () {
              setState(() {
                onTap(key, checked);
              });
            };
      Widget child = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(_getLocalizedKey(key)),
      );
      if (checked) {
        children.add(ElevatedButton(
          onPressed: onPressed,
          child: child,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(48, 24),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(),
          ),
        ));
      } else {
        children.add(OutlinedButton(
          onPressed: onPressed,
          child: child,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 24),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(),
          ),
        ));
      }
    });
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: children,
      ),
    );
  }

  Widget get actionBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            SimpleCancelOkDialog(
              title: Text(LocalizedText.of(
                  chs: '清空所有任务',
                  jpn: 'ミッションをクリア',
                  eng: 'Clear all missions',
                  kor: '모든 미션을 클리어합니다')),
              onTapOk: () {
                setState(() {
                  filterData.reset();
                  missions.clear();
                  solution.clear();
                });
              },
            ).showDialog(context);
          },
          child: Text(
            S.of(context).clear,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        TextButton(
          onPressed: filterData.isNotEmpty
              ? () {
                  setState(() {
                    missions.add(WeeklyFilterData.from(filterData)
                      ..controller = TextEditingController(text: '0'));
                    filterData.reset();
                  });
                }
              : null,
          child: Text(S.current.add),
        ),
        ElevatedButton(
          onPressed: missions.isNotEmpty ? solve : null,
          child: Text(S.of(context).drop_calc_solve),
        ),
      ],
    );
  }

  Widget get popupMenu {
    return PopupMenuButton<int>(
      itemBuilder: (context) => [
        PopupMenuItem(
            value: 0,
            child: Text(LocalizedText.of(
                chs: '日服本周',
                jpn: '今週(JP)',
                eng: 'This Week(JP)',
                kor: '이번주(JP)'))),
        PopupMenuItem(
            value: 1,
            child: Text(LocalizedText.of(
                chs: '国服本周',
                jpn: '今週(CN)',
                eng: 'This Week(CN)',
                kor: '이번주(CN)'))),
        PopupMenuItem(
          value: 2,
          child: Text(S.current.help),
        ),
      ],
      onSelected: (v) async {
        if (v == 2) {
          SplitRoute.push(
            context,
            const MarkdownHelpPage.localized(asset: 'master_mission.md'),
          );
          return;
        }
        String wikitext;
        try {
          EasyLoading.show();
          wikitext = await WikiUtil.pageContent('首页/御主任务数据');
          EasyLoading.showSuccess('success');
        } catch (e) {
          EasyLoading.showError(e.toString());
          return;
        } finally {
          EasyLoadingUtil.dismiss();
        }
        String prefix = ['jp', 'cn'][v];
        missions.clear();
        String? _getContent(String key) {
          final splits = wikitext.split(key);
          if (splits.length >= 2) {
            String? result =
                RegExp(r'(?<=\>)[^<>]*(?=\<)').firstMatch(splits[1])?.group(0);
            // print(result);
            return result?.trim();
          }
        }

        String _removeBrackets(String s) {
          return s.replaceAll(RegExp(r'[「」『』]'), '');
        }

        for (int i = 1; i < 7; i++) {
          final targets = _getContent('${prefix}target$i');
          final count = _getContent('${prefix}count$i');
          if (targets?.isNotEmpty == true && count?.isNotEmpty == true) {
            final mission = WeeklyFilterData.from(filterData)..reset();
            for (var trait in targets!.split(',')) {
              trait = trait.trim();
              for (var key in mission.checked.keys) {
                if (_removeBrackets(key) == _removeBrackets(trait)) {
                  mission.checked[key] = true;
                  mission.controller = TextEditingController(text: count);
                }
              }
            }
            if (mission.isNotEmpty) {
              missions.add(mission);
            }
          }
        }
        if (mounted) setState(() {});
      },
    );
  }

  Widget get missionListView {
    List<Widget> children = [];
    for (var mission in missions) {
      void _onPressAddAll() {
        setState(() {
          mission.useAnd = !mission.useAnd;
        });
      }

      children.add(ListTile(
        leading: IconButton(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 36),
          onPressed: () {
            setState(() {
              missions.remove(mission);
            });
          },
          icon: const Icon(Icons.clear),
          color: Colors.redAccent,
        ),
        horizontalTitleGap: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: AutoSizeText(
          mission.getLocalizedTargets().join(', '),
          maxFontSize: 12,
          style: TextStyle(color: mission.valid ? null : Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mission.useAnd)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(36, 24),
                  minimumSize: const Size(36, 24),
                  padding: const EdgeInsets.all(2),
                ),
                onPressed: _onPressAddAll,
                child: Text(const LocalizedText(
                        chs: '且', eng: 'AND', jpn: 'AND', kor: 'AND')
                    .localized),
              ),
            if (!mission.useAnd)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  fixedSize: const Size(36, 24),
                  minimumSize: const Size(36, 24),
                  padding: const EdgeInsets.all(2),
                ),
                onPressed: _onPressAddAll,
                child: Text(const LocalizedText(
                        chs: '或', eng: 'OR', jpn: 'OR', kor: 'OR')
                    .localized),
              ),
            _InputGroup(
              controller: mission.controller!,
              minVal: 0,
            )
          ],
        ),
      ));
    }
    return SimpleAccordion(
      expanded: true,
      headerBuilder: (context, _) => ListTile(
        leading: const Icon(Icons.list),
        title: Text(S.current.master_mission_tasklist),
        horizontalTitleGap: 0,
      ),
      contentBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: divideTiles(children),
      ),
    );
  }

  Widget get solutionList {
    List<Widget> children = [];
    solution.forEach((weeklyQuest, value) {
      final child = _oneQuest(weeklyQuest: weeklyQuest, questTimes: value);
      children.add(child);
    });
    double totalAP = 0;
    solution.forEach((key, value) {
      totalAP += key.ap * value;
    });
    return SimpleAccordion(
      expanded: true,
      headerBuilder: (context, _) => ListTile(
        leading: const Icon(Icons.list_alt),
        title: Text(S.current.master_mission_solution),
        trailing: Text('$totalAP AP'),
        horizontalTitleGap: 0,
      ),
      contentBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: divideTiles(children),
      ),
    );
  }

  Widget get relatedQuests {
    List<Widget> children = [];
    Map<String, double> allCounts = {};
    for (int col = 0; col < params.colNames.length; col++) {
      num count = sum(params.getCol(col));
      if (count > 0) allCounts[params.colNames[col]] = count / params.cVec[col];
    }
    List<String> cols = allCounts.keys.toList();
    cols.sort((a, b) => (allCounts[b]! - allCounts[a]!).sign.toInt());
    for (var colName in cols) {
      children.add(_oneQuest(
        weeklyQuest: _missionData.firstWhere((e) => e.place == colName),
        eff: allCounts[colName],
      ));
    }
    return SimpleAccordion(
      expanded: true,
      headerBuilder: (context, _) => ListTile(
        leading: const Icon(Icons.list_alt),
        title: Text(S.current.master_mission_related_quest),
        horizontalTitleGap: 0,
      ),
      contentBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: divideTiles(children),
      ),
    );
  }

  Widget _oneQuest({
    required WeeklyMissionQuest weeklyQuest,
    num? questTimes,
    num? eff,
  }) {
    Quest? quest;
    quest = db.gameData.getFreeQuest(weeklyQuest.place);
    Map<String, int> counts = {};
    weeklyQuest.allTraits.forEach((key, value) {
      if (missions.any((element) => element.checked[key] == true)) {
        counts[key] = value;
      }
    });
    String countsString = counts.entries
        .map((e) => '${_convertLocalized(e.key)}×${e.value}')
        .join(', ');
    String trailingString = '${weeklyQuest.ap}AP';
    if (questTimes != null) trailingString += '×$questTimes';
    return ValueStatefulBuilder<bool>(
      initValue: false,
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CustomTile(
              title: Text(quest?.localizedKey ?? weeklyQuest.place),
              subtitle: AutoSizeText(
                countsString,
                maxFontSize: 14,
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(trailingString),
                  if (eff != null)
                    Text(
                      eff.toStringAsFixed(2) + '/AP',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    )
                ],
              ),
              onTap: quest == null
                  ? null
                  : () => state.setState(() => state.value = !state.value),
            ),
            if (state.value && quest != null) QuestCard(quest: quest)
          ],
        );
      },
    );
  }

  BasicGLPKParams params = BasicGLPKParams();

  void solve() async {
    FocusScope.of(context).unfocus();
    params = BasicGLPKParams();
    params.colNames.addAll(_missionData.map((e) => e.place));
    params.cVec.addAll(_missionData.map((e) => e.ap));
    params.integer = true;
    for (var mission in missions) {
      var row = mission.rowOfA;
      mission.valid = row.any((e) => e > 0);
      if (mission.valid) {
        params.addRow(mission.getTargets().join(','), row, mission.count);
      }
    }
    for (int i = params.colNames.length - 1; i >= 0; i--) {
      if (params.AMat.map((row) => row[i]).every((e) => e == 0)) {
        params.removeCol(i);
      }
    }
    if (params.rowNames.isEmpty || params.colNames.isEmpty) {
      EasyLoading.showError('No quest');
      setState(() {
        solution.clear();
      });
      return;
    }
    // call js
    await engine.ensureInitiated();
    final result = await engine.eval('''glpk_solver(`${jsonEncode(params)}`)''',
        name: 'solver_caller');
    setState(() {
      solution.clear();
      Map.from(jsonDecode(result ?? '{}')).forEach((key, value) {
        solution[_missionData.firstWhere((e) => e.place == key)] = value;
      });
    });
    print(result);
    MobStat.logEvent('master_mission');
  }

  void showHelp() {
    SimpleCancelOkDialog(
      scrollable: true,
      title: Text(S.current.help),
      content: Text(LocalizedText.of(
          chs: """注意：无法得知一个关卡X既有属性A又有属性B的敌人数目。只能知晓关卡X共有a个属性A，b个属性B。
例：关卡X共有2个属性A，4个属性B，9个属性C
“或”：2+4+9=15, 几乎都有关卡可以满足
“且”：min(2,4,9)=2, 此时极大可能将没有关卡可以满足条件而忽略，相应任务会变灰
""", jpn: """ """, eng: """""")),
    ).showDialog(context);
  }
}

class WeeklyFilterData {
  /// if no quest satisfies the mission, then this mission is invalid
  bool valid = true;
  Map<String, bool> checked = {};
  bool useAnd = false;

  // 从者_trait: trait
  Set<String> servantTraits = {};
  Set<String> enemyTraits = {};
  Set<String> battlefields = {};
  Set<String> generalTraits = {};

  TextEditingController? controller;

  WeeklyFilterData.fromQuests(List<WeeklyMissionQuest> quests) {
    for (var quest in quests) {
      quest.servantTraits.forEach((key, value) {
        checked['从者_$key'] = false;
        servantTraits.add('从者_$key');
      });
      quest.enemyTraits.forEach((key, value) {
        checked['小怪_$key'] = false;
        enemyTraits.add('小怪_$key');
      });
      quest.battlefields.forEach((key) {
        checked['场地_$key'] = false;
        battlefields.add('场地_$key');
      });
    }
    generalTraits = servantTraits
        .map((e) => _removePrefix(e))
        .where((e) => enemyTraits.contains('小怪_$e'))
        .toSet();
  }

  bool get isNotEmpty {
    return checked.containsValue(true);
  }

  int get count => int.tryParse(controller?.text ?? '') ?? 0;

  void reset() {
    checked.updateAll((key, value) => false);
    useAnd = false;
  }

  WeeklyFilterData.from(WeeklyFilterData other)
      : checked = Map.from(other.checked),
        useAnd = other.useAnd,
        servantTraits = Set.from(other.servantTraits),
        enemyTraits = Set.from(other.enemyTraits),
        battlefields = Set.from(other.battlefields),
        generalTraits = Set.from(other.generalTraits);

  List<String> getTargets() {
    return checked.keys.where((key) => checked[key] == true).toList();
  }

  List<String> getLocalizedTargets() {
    return checked.keys
        .where((key) => checked[key] == true)
        .map((e) => _convertLocalized(e))
        .toList();
  }

  List<num> get rowOfA {
    List<num> row = [];
    for (var quest in _missionData) {
      int? count;
      final questTraits = quest.allTraits;
      checked.forEach((key, value) {
        if (value) {
          if (useAnd) {
            count ??= questTraits[key] ?? 0;
            count = min(count!, questTraits[key] ?? 0);
          } else {
            count ??= 0;
            count = count! + (questTraits[key] ?? 0);
          }
        }
      });
      row.add(count!);
    }
    return row;
  }
}

String _removePrefix(String key) {
  return key.split('_').last;
}

class _InputGroup extends StatefulWidget {
  final TextEditingController controller;
  final int? minVal;
  final int? maxVal;

  const _InputGroup(
      {Key? key, required this.controller, this.minVal, this.maxVal})
      : super(key: key);

  @override
  __InputGroupState createState() => __InputGroupState();
}

class __InputGroupState extends State<_InputGroup> {
  @override
  void initState() {
    super.initState();
  }

  int get curVal => int.tryParse(widget.controller.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    bool minusEnabled = widget.minVal == null || curVal > widget.minVal!;
    bool plusEnabled = widget.maxVal == null || curVal < widget.maxVal!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          icon: Icon(
            Icons.indeterminate_check_box,
            color: minusEnabled ? Colors.blueAccent : null,
          ),
          onPressed: minusEnabled
              ? () {
                  int newVal = curVal - 1;
                  widget.controller.value =
                      widget.controller.value.copyWith(text: newVal.toString());
                  setState(() {});
                }
              : null,
        ),
        SizedBox(
          width: 40,
          child: TextField(
            controller: widget.controller,
            decoration: const InputDecoration(
              isDense: true,
              // enabledBorder: OutlineInputBorder(),
              // focusedBorder: OutlineInputBorder(
              //     borderSide: BorderSide(color: Colors.blueAccent)),
              contentPadding: EdgeInsets.symmetric(vertical: 4),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: (v) {
              setState(() {});
            },
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          icon: Icon(
            Icons.add_box,
            color: plusEnabled ? Colors.blueAccent : null,
          ),
          onPressed: plusEnabled
              ? () {
                  int newVal = curVal + 1;
                  widget.controller.value =
                      widget.controller.value.copyWith(text: newVal.toString());
                  setState(() {});
                }
              : null,
        ),
      ],
    );
  }
}
