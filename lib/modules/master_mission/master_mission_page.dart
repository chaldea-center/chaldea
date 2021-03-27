import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';
import 'package:flutter/services.dart';

class MasterMissionPage extends StatefulWidget {
  @override
  _MasterMissionPageState createState() => _MasterMissionPageState();
}

class _MasterMissionPageState extends State<MasterMissionPage>
    with SingleTickerProviderStateMixin {
  List<WeeklyMissionQuest> get srcData => db.gameData.glpk.weeklyMissionData;

  List<String> tabNames = const [
    '一般特性',
    '从者职阶',
    '从者特性',
    '小怪职阶',
    '小怪特性',
    '场地特性'
  ];
  List<String> classTypes = const ['剑阶', '弓阶', '枪阶', '骑阶', '术阶', '杀阶', '狂阶'];
  late TabController _tabController;
  int _curTab = 0;
  bool _showFilters = true;

  // data
  late WeeklyFilterData filterData;
  List<WeeklyFilterData> missions = [];
  Map<WeeklyMissionQuest, num> solution = {};

  // solver
  QjsEngine engine = QjsEngine();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabNames.length, vsync: this);
    filterData = WeeklyFilterData.fromQuests(srcData);
    engine.init(() async {
      await engine.eval(await rootBundle.loadString('res/js/glpk.min.js'),
          name: '<glpk.min.js>');
      await engine.eval(await rootBundle.loadString('res/js/glpk_solver.js'),
          name: 'glpk_solver.js');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(S.of(context).master_mission),
        centerTitle: true,
        actions: [popupMenu],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabNames.map((e) => Tab(text: e)).toList(),
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
          taskList,
          solutionList,
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
    return AnimatedCrossFade(
      firstChild: Container(height: 0.0),
      secondChild: _buildTraits(keys, isChecked, onTap),
      firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
      secondCurve: const Interval(0.4, 1, curve: Curves.fastOutSlowIn),
      sizeCurve: Curves.fastOutSlowIn,
      crossFadeState:
          _showFilters ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
    );
  }

  Widget _buildTraits(Set<String> keys, bool isChecked(String key)?,
      void onTap(String key, bool checked)?) {
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
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(_removePrefix(key)),
      );
      if (checked) {
        children.add(ElevatedButton(
          onPressed: onPressed,
          child: child,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(48, 24),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.symmetric(),
          ),
        ));
      } else {
        children.add(OutlinedButton(
          onPressed: onPressed,
          child: child,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(48, 24),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.symmetric(),
          ),
        ));
      }
    });
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      color: Colors.grey[100],
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
              title: Text('清空所有任务'),
              onTapOk: () {
                setState(() {
                  filterData.reset();
                  missions.clear();
                  solution.clear();
                });
              },
            ).show(context);
          },
          child: Text(
            S.of(context).clear,
            style: TextStyle(color: Colors.redAccent),
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
          child: Text('添加'),
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
        PopupMenuItem(value: 0, child: Text('日服本周')),
        PopupMenuItem(value: 1, child: Text('国服本周')),
      ],
      onSelected: (v) async {
        EasyLoading.show();
        String wikitext;
        try {
          wikitext = await MooncellUtil.pageContent('首页/御主任务数据');
        } catch (e) {
          EasyLoading.showError(e.toString());
          return;
        }
        EasyLoading.showSuccess('success');
        String prefix = ['jp', 'cn'][v];
        missions.clear();
        String? _getContent(String key) {
          final splits = wikitext.split(key);
          if (splits.length >= 2) {
            String? result =
                RegExp(r'(?<=>)[^<>]*(?=<)').firstMatch(splits[1])?.group(0);
            // print(result);
            return result?.trim();
          }
        }

        for (int i = 1; i < 7; i++) {
          final targets = _getContent('${prefix}target$i');
          final count = _getContent('${prefix}count$i');
          if (targets?.isNotEmpty == true && count?.isNotEmpty == true) {
            final mission = WeeklyFilterData.from(filterData)..reset();
            for (var trait in targets!.split(',')) {
              trait = trait.trim();
              if (mission.checked.containsKey(trait)) {
                mission.checked[trait] = true;
                mission.controller = TextEditingController(text: count);
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

  Widget get taskList {
    List<Widget> children = [];
    for (var mission in missions) {
      children.add(ListTile(
        leading: IconButton(
          constraints: BoxConstraints(minHeight: 48, minWidth: 36),
          onPressed: () {
            setState(() {
              missions.remove(mission);
            });
          },
          icon: Icon(Icons.clear),
          color: Colors.redAccent,
        ),
        horizontalTitleGap: 0,
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
        title: AutoSizeText(
          mission.getTargets().join(' or '),
          maxLines: 2,
          maxFontSize: 14,
        ),
        trailing: _InputGroup(
          controller: mission.controller!,
          minVal: 0,
        ),
      ));
    }
    return SimpleAccordion(
      expanded: true,
      headerBuilder: (context, _) => ListTile(
        leading: Icon(Icons.list),
        title: Text('任务列表'),
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
      Quest? quest;
      quest = db.gameData.getFreeQuest(weeklyQuest.place);
      Map<String, int> counts = {};
      weeklyQuest.allTraits.forEach((key, value) {
        if (missions.any((element) => element.checked[key] == true)) {
          counts[key] = value;
        }
      });
      String countsString =
          counts.entries.map((e) => '${e.key}×${e.value}').join(', ');
      final child = ValueStatefulBuilder<bool>(
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
                  trailing: Text('${weeklyQuest.ap}AP×$value'),
                  onTap: quest == null
                      ? null
                      : () => state.setState(() => state.value = !state.value),
                ),
                if (state.value && quest != null) QuestCard(quest: quest)
              ],
            );
          });
      children.add(child);
    });
    double totalAP = 0;
    solution.forEach((key, value) {
      totalAP += key.ap * value;
    });
    return SimpleAccordion(
      expanded: true,
      headerBuilder: (context, _) => ListTile(
        leading: Icon(Icons.list_alt),
        title: Text('Solution'),
        trailing: Text('$totalAP AP'),
        horizontalTitleGap: 0,
      ),
      contentBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: divideTiles(children),
      ),
    );
  }

  void solve() async {
    final params = BasicGLPKParams();
    params.colNames
        .addAll(db.gameData.glpk.weeklyMissionData.map((e) => e.place));
    params.cVec.addAll(db.gameData.glpk.weeklyMissionData.map((e) => e.ap));
    params.integer = true;
    for (var mission in missions) {
      var row = mission.rowOfA;
      if (row.any((e) => e > 0)) {
        params.addRow(mission.getTargets().join(','), row, mission.count);
      }
    }
    for (int i = params.colNames.length - 1; i >= 0; i--) {
      if (params.AMat.map((row) => row[i]).every((e) => e == 0)) {
        params.removeCol(i);
      }
    }
    // call js
    final result = await engine.eval('''glpk_solver(`${jsonEncode(params)}`)''',
        name: 'solver_caller');
    setState(() {
      solution.clear();
      Map.from(jsonDecode(result)).forEach((key, value) {
        solution[srcData.firstWhere((e) => e.place == key)] = value;
      });
    });
    print(result);
  }
}

class WeeklyFilterData {
  Map<String, bool> checked = {};

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
  }

  WeeklyFilterData.from(WeeklyFilterData other)
      : checked = Map.from(other.checked),
        servantTraits = Set.from(other.servantTraits),
        enemyTraits = Set.from(other.enemyTraits),
        battlefields = Set.from(other.battlefields),
        generalTraits = Set.from(other.generalTraits);

  List<String> getTargets() {
    return checked.keys.where((key) => checked[key] == true).toList();
  }

  List<num> get rowOfA {
    List<num> row = [];
    for (var quest in db.gameData.glpk.weeklyMissionData) {
      int count = 0;
      final questTraits = quest.allTraits;
      checked.forEach((key, value) {
        if (value) count += questTraits[key] ?? 0;
      });
      row.add(count);
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
          constraints: BoxConstraints(minWidth: 24, minHeight: 24),
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
            decoration: InputDecoration(
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
          constraints: BoxConstraints(minWidth: 24, minHeight: 24),
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
