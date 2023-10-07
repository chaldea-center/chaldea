import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/master_mission/solver/solver.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../api/atlas.dart';
import 'scheme.dart';

class _MissionSolverOptions {
  List<CustomMission> missions = [];
  int warId = 0;
  int advancedEventId = 0;
  bool _isRegionNA = false;
  bool get isRegionNA => warId < 1000 ? false : _isRegionNA;
  set isRegionNA(bool v) => _isRegionNA = v;
  bool addNotBasedOnSvtForTraum = false;

  MasterMissionOptions get preset => db.settings.masterMissionOptions;
}

class MissionInputTab extends StatefulWidget {
  final List<CustomMission> initMissions;
  final int? initWarId;
  final ValueChanged<MissionSolution> onSolved;

  const MissionInputTab({
    super.key,
    this.initMissions = const [],
    this.initWarId,
    required this.onSolved,
  });

  @override
  State<MissionInputTab> createState() => _MissionInputTabState();
}

class _MissionInputTabState extends State<MissionInputTab> {
  late ScrollController _scrollController;
  final options = _MissionSolverOptions();
  // List<CustomMission> missions = [];
  final solver = MissionSolver();
  final Map<int, (Event, List<Quest>)> advancedQuests = {};
  // int warId = 0;
  // int advancedEventId = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    options.missions = List.of(widget.initMissions);
    options.warId = widget.initWarId ??
        Maths.max([
          for (final war in db.gameData.mainStories.values)
            if (war.quests.any((q) => q.isMainStoryFree)) war.id
        ], 0);

    final allAdvancedQuests = <Quest>[];
    for (final event in db.gameData.events.values) {
      if (event.isAdvancedQuestEvent) {
        final questIds = db.gameData.others.eventQuestGroups[event.id] ?? [];
        for (final questId in questIds) {
          final quest = db.gameData.quests[questId];
          if (quest != null &&
              quest.afterClear == QuestAfterClearType.repeatLast &&
              quest.closedAt > kNeverClosedTimestamp) {
            allAdvancedQuests.add(quest);
          }
        }
        advancedQuests[event.id] = (event, []);
      }
    }
    sortDict(advancedQuests, inPlace: true, compare: (a, b) => b.value.$1.startedAt - a.value.$1.startedAt);
    for (final quest in allAdvancedQuests) {
      for (final (event, quests) in advancedQuests.values) {
        if (event.startedAt == quest.openedAt) {
          quests.add(quest);
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: options.missions.isEmpty
              ? Center(child: Text(S.current.custom_mission_nothing_hint))
              : ListView.separated(
                  controller: _scrollController,
                  itemBuilder: (context, index) => _oneMission(index, options.missions[index]),
                  separatorBuilder: (_, __) => kDefaultDivider,
                  itemCount: options.missions.length,
                ),
        ),
        kDefaultDivider,
        eventSelector,
        advancedQuestSelector,
        SafeArea(child: buttonBar),
      ],
    );
  }

  Widget _oneMission(int index, CustomMission mission) {
    return SimpleAccordion(
      key: Key('mission_input_${mission.hashCode}'),
      headerBuilder: (context, collapsed) => ListTile(
        leading: Text(
          (index + 1).toString(),
          textAlign: TextAlign.center,
        ),
        horizontalTitleGap: 0,
        title: mission.buildDescriptor(context, textScaleFactor: 0.8),
        minLeadingWidth: 32,
        contentPadding: const EdgeInsetsDirectional.only(start: 16),
      ),
      contentBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mission.originDetail?.isNotEmpty == true)
            ListTile(
              dense: true,
              title: Text(S.current.custom_mission_source_mission),
              subtitle: Text(mission.originDetail!),
            ),
          ListTile(
            dense: true,
            leading: Text(S.current.counts),
            trailing: SizedBox(
              width: 72,
              child: TextFormField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  isDense: true,
                  hintText: mission.count.toString(),
                  contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                ),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  setState(() {
                    final count = v.isEmpty ? 0 : int.tryParse(v);
                    if (count != null) mission.count = count;
                  });
                },
              ),
            ),
          ),
          if (mission.conds.length > 1)
            ListTile(
              dense: true,
              leading: Text(S.current.logic_type),
              trailing: FilterGroup<bool>(
                options: const [true, false],
                values: FilterRadioData.nonnull(mission.condAnd),
                optionBuilder: (v) => Text(v ? S.current.logic_type_and : S.current.logic_type_or),
                combined: true,
                padding: EdgeInsets.zero,
                onFilterChanged: (v, _) {
                  setState(() {
                    mission.condAnd = v.radioValue!;
                  });
                },
              ),
            ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            // spacing: 8,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    options.missions.remove(mission);
                  });
                },
                child: Text(
                  S.current.remove_mission,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              // const SizedBox(width: 48),
              TextButton(
                onPressed: () {
                  setState(() {
                    final prev = mission.conds.getOrNull(0);
                    mission.conds.add(CustomMissionCond(
                      type: prev?.type ?? CustomMissionType.trait,
                      targetIds: [],
                      useAnd: prev?.useAnd ?? false,
                    ));
                  });
                },
                child: Text(S.current.add_condition),
              ),
            ],
          ),
          for (final cond in mission.conds) ...[
            DividerWithTitle(
              indent: 12,
              titleWidget: Text.rich(
                TextSpan(text: '${S.current.condition} ${mission.conds.indexOf(cond) + 1}', children: [
                  if (mission.conds.length > 1)
                    TextSpan(
                      text: '(${S.current.delete})',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          setState(() {
                            mission.conds.remove(cond);
                          });
                        },
                    )
                ]),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            ListTile(
              dense: true,
              leading: Text(S.current.general_type),
              trailing: DropdownButton<CustomMissionType>(
                value: cond.type,
                items: [
                  for (final type in CustomMissionType.values)
                    DropdownMenuItem(
                      value: type,
                      child: Text(
                        Transl.enums(type, (enums) => enums.customMissionType).l,
                        textScaleFactor: 0.8,
                      ),
                    ),
                ],
                onChanged: (v) {
                  setState(() {
                    if (v == null) return;
                    if (mission.conds.length > 1) {
                      final types = <bool>{
                        v.isEnemyType,
                        ...mission.conds.where((e) => e != cond).map((e) => e.type.isEnemyType)
                      };
                      bool mixed = types.length > 1;
                      if (mixed) {
                        EasyLoading.showError(S.current.custom_mission_mixed_type_hint);
                        return;
                      }
                    }
                    cond.type = v;
                  });
                },
              ),
            ),
            ListTile(
              dense: true,
              leading: Text(S.current.logic_type),
              trailing: FilterGroup<bool>(
                options: const [true, false],
                values: FilterRadioData.nonnull(cond.useAnd),
                enabled: cond.fixedLogicType == null,
                optionBuilder: (v) => Text(v ? S.current.logic_type_and : S.current.logic_type_or),
                combined: true,
                padding: EdgeInsets.zero,
                onFilterChanged: (v, _) {
                  setState(() {
                    cond.useAnd = v.radioValue!;
                  });
                },
              ),
            ),
            ListTile(
              title: Wrap(
                spacing: 2,
                runSpacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('IDs   '),
                  for (final id in cond.targetIds)
                    InkWell(
                      onTap: () {
                        setState(() {
                          cond.targetIds.remove(id);
                        });
                      },
                      child: AbsorbPointer(
                        child: FilterOption(
                          selected: false,
                          value: id,
                          child: Text(_idDescriptor(cond.type, id)),
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: () async {
                      await SplitRoute.push(
                        context,
                        _SearchView(
                          targetType: cond.type,
                          selected: cond.targetIds,
                          onChanged: (v) {
                            cond.targetIds = v.toList();
                            if (mounted) setState(() {});
                          },
                        ),
                      );
                      if (mounted) setState(() {});
                    },
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minHeight: 36),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget get eventSelector {
    final war = db.gameData.wars[options.warId];
    String title;
    String leading = S.current.event;
    if (war == null) {
      title = 'Invalid Choice';
    } else if (war.isMainStory) {
      leading = S.current.progress;
      title = war.lShortName;
    } else {
      title = Transl.eventNames(war.eventName).l;
    }
    title = '[${options.warId}] $title';
    void _onTap() async {
      final result = await SplitRoute.push<int?>(context, EventChooser(initTab: options.warId < 1000 ? 0 : 1));
      if (result != null) {
        options.warId = result;
      }
      if (mounted) setState(() {});
    }

    return ListTile(
      leading: Text(leading),
      title: TextButton(onPressed: _onTap, child: Text(title)),
      dense: true,
    );
  }

  Widget get advancedQuestSelector {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButton<int>(
        value: options.advancedEventId,
        isExpanded: true,
        isDense: true,
        alignment: Alignment.center,
        items: [
          DropdownMenuItem(
            value: 0,
            child: Text('${Transl.eventNames("アドバンスドクエスト").l} ${S.current.disabled}',
                style: const TextStyle(fontSize: 14)),
          ),
          for (final (event, _) in advancedQuests.values)
            DropdownMenuItem(
              value: event.id,
              child: Text(
                '${event.lShortName.l}(JP ${event.startedAt.sec2date().toDateString()})',
                style: const TextStyle(fontSize: 14),
              ),
            ),
        ],
        onChanged: (v) {
          setState(() {
            if (v != null) options.advancedEventId = v;
          });
        },
      ),
    );
  }

  Widget get buttonBar {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DropdownButton<bool>(
            isDense: true,
            value: options.isRegionNA,
            items: [
              for (final isNA in [false, true])
                DropdownMenuItem(
                  value: isNA,
                  child: Text(isNA ? 'NA' : 'JP'),
                ),
            ],
            onChanged: (options.warId < 1000)
                ? null
                : (v) {
                    setState(() {
                      if (v != null) options.isRegionNA = v;
                    });
                  },
          ),
          IconButton(
            onPressed: options.missions.isEmpty
                ? null
                : () {
                    SimpleCancelOkDialog(
                      title: Text(S.current.clear),
                      onTapOk: () {
                        options.missions.clear();
                        if (mounted) setState(() {});
                      },
                    ).showDialog(context);
                  },
            icon: const Icon(Icons.delete_outline),
            tooltip: S.current.clear,
          ),
          IconButton(
            onPressed: () async {
              await _OptionsDialog(options: options).showDialog(context);
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.settings),
            tooltip: S.current.options,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                options.missions.add(CustomMission(
                  count: 0,
                  conds: [
                    CustomMissionCond(
                      type: CustomMissionType.trait,
                      targetIds: [],
                      useAnd: true,
                    )
                  ],
                  condAnd: false,
                  enemyDeckOnly: true,
                ));
              });
            },
            icon: const Icon(Icons.add_circle_outline),
            tooltip: S.current.add_mission,
          ),
          ElevatedButton(
            onPressed: options.missions.isEmpty ? null : _solveProblem,
            child: Text(S.current.drop_calc_solve),
          )
        ],
      ),
    );
  }

  Future<void> _solveProblem() async {
    if (!options.missions.every((mission) {
      if (mission.count <= 0) return false;
      if (mission.conds.isEmpty) return false;
      for (final cond in mission.conds) {
        if (cond.targetIds.isEmpty) return false;
      }
      return true;
    })) {
      EasyLoading.showError(S.current.invalid_input);
      return;
    }
    final region = options.isRegionNA ? Region.na : Region.jp;
    void _showHint(String hint) => EasyLoading.show(status: hint);
    _showHint('Solving...');
    try {
      List<QuestPhase> quests = [];
      List<Future> futures = [];
      Map<int, int> phases = {};

      int countSuccess = 0, countError = 0, countNoEnemy = 0;
      if (options.warId < 1000) {
        for (final war in db.gameData.wars.values) {
          if (!war.isMainStory || war.id > options.warId) continue;
          for (final quest in war.quests) {
            if (!quest.isMainStoryFree) continue;
            phases[quest.id] = quest.phases.last;
          }
        }
        phases[94061636] = 1;
        // phases[94061640] = 1;
        // door/QP quest 初級 - 極級
        // for (int id = 94061636; id <= 94061640; id++) {
        //   phases[id] = 1;
        // }
      } else {
        NiceWar? war =
            options.isRegionNA ? await AtlasApi.war(options.warId, region: Region.na) : db.gameData.wars[options.warId];
        if (war == null) {
          EasyLoading.showError('War ${options.warId} not found');
          return;
        }
        for (final quest in war.quests) {
          if (!quest.isAnyFree && !quest.isRepeatRaid) continue;
          if (quest.phases.isNotEmpty) phases[quest.id] = quest.phases.last;
        }
      }
      final lastAdvancedEventTime = advancedQuests[options.advancedEventId]?.$1.startedAt;
      if (lastAdvancedEventTime != null) {
        for (final (event, quests) in advancedQuests.values) {
          if (event.startedAt <= lastAdvancedEventTime) {
            for (final quest in quests) {
              if (quest.phases.isNotEmpty) phases[quest.id] = quest.phases.last;
            }
          }
        }
      }
      phases.removeWhere((questId, _) => options.preset.blacklist.contains(questId));
      if (options.preset.excludeRandomEnemyQuests) {
        phases.removeWhere((questId, _) => ConstData.randomEnemyQuests.contains(questId));
      }
      for (final entry in phases.entries) {
        futures.add(AtlasApi.questPhase(
          entry.key,
          entry.value,
          region: region,
          expireAfter: db.gameData.quests[entry.key]?.warId == WarId.advanced ? const Duration(days: 7) : null,
        ).then((quest) async {
          if (quest == null) {
            countError += 1;
          } else if (quest.allEnemies.isNotEmpty) {
            quests.add(quest);
            countSuccess += 1;
          } else {
            countNoEnemy += 1;
          }
          await Future.delayed(const Duration(milliseconds: 100));
          _showHint('Resolve Quests: total ${phases.length + countNoEnemy},'
              ' $countSuccess success, $countError error, $countNoEnemy no data');
          await Future.delayed(const Duration(milliseconds: 100));
        }));
      }

      await Future.wait(futures);
      EasyLoading.dismiss();
      if (!mounted) return;

      if (countError + countNoEnemy > 0) {
        final _continue = await showDialog(
          context: context,
          builder: (context) => SimpleCancelOkDialog(
            title: Text(S.current.warning),
            content: Text('Resolved Quests: total ${phases.length + countNoEnemy},'
                ' $countSuccess success, $countError error, $countNoEnemy no data\n'
                'Still Continue?'),
          ),
        );
        if (_continue != true) {
          return;
        }
      }
      final validQuests = quests.toList();
      if (validQuests.isEmpty) {
        EasyLoading.showError('No Valid Quests');
        return;
      }
      final missionsCopy = options.missions.map((e) => e.copy()).toList();
      final solverOptions = MissionSolverOptions(
        addNotBasedOnSvtForTraum: options.addNotBasedOnSvtForTraum,
      );
      final result = await solver.solve(
        quests: validQuests,
        missions: missionsCopy,
        options: solverOptions,
      );
      final solution = MissionSolution(
        result: result,
        missions: missionsCopy,
        quests: validQuests,
        options: solverOptions,
        region: region,
      );
      widget.onSolved(solution);
      EasyLoading.dismiss();
    } catch (e, s) {
      logger.e('solve custom mission failed', e, s);
      EasyLoading.showError(e.toString());
    }
  }
}

class _OptionsDialog extends StatefulWidget {
  final _MissionSolverOptions options;
  const _OptionsDialog({required this.options});

  @override
  State<_OptionsDialog> createState() => __OptionsDialogState();
}

class __OptionsDialogState extends State<_OptionsDialog> {
  _MissionSolverOptions get options => widget.options;
  @override
  Widget build(BuildContext context) {
    return SimpleCancelOkDialog(
      title: Text(S.current.options),
      scrollable: true,
      hideCancel: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            dense: true,
            title: Text(S.current.add_not_svt_trait_to_traum_enemy),
            value: options.addNotBasedOnSvtForTraum,
            onChanged: (v) {
              setState(() {
                options.addNotBasedOnSvtForTraum = v;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            dense: true,
            title: Text(S.current.exclude_random_enemy_quests),
            subtitle: Text.rich(
              TextSpan(
                text: "${ConstData.randomEnemyQuests.length} ${S.current.quest}: ",
                children: divideList(
                  [
                    for (final questId in ConstData.randomEnemyQuests)
                      SharedBuilder.textButtonSpan(
                        context: context,
                        text: questId.toString(),
                        onTap: () => router.push(url: Routes.questI(questId)),
                      ),
                  ],
                  const TextSpan(text: ', '),
                ),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            value: options.preset.excludeRandomEnemyQuests,
            onChanged: (v) {
              setState(() {
                options.preset.excludeRandomEnemyQuests = v;
              });
            },
          ),
          SimpleAccordion(
            headerBuilder: (context, _) => ListTile(
              dense: true,
              title: Text(S.current.blacklist),
              trailing: Text(options.preset.blacklist.length.toString()),
            ),
            contentBuilder: (context) => Column(
              children: divideTiles(options.preset.blacklist.map((questId) {
                String shownName = db.gameData.quests[questId]?.lDispName ?? 'Quest $questId';
                return ListTile(
                  title: Text(shownName),
                  dense: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    tooltip: S.current.remove_from_blacklist,
                    onPressed: () {
                      setState(() {
                        options.preset.blacklist.remove(questId);
                      });
                    },
                  ),
                );
              })),
            ),
          ),
          SFooter.rich(TextSpan(
            text: 'See ',
            children: [
              SharedBuilder.textButtonSpan(
                context: context,
                text: 'document',
                onTap: () => launch(ChaldeaUrl.doc('master_mission')),
              ),
              const TextSpan(text: '. '),
            ],
          ))
        ],
      ),
    );
  }
}

class _SearchView extends StatefulWidget {
  final CustomMissionType targetType;
  final List<int> selected;
  final ValueChanged<List<int>> onChanged;
  const _SearchView({
    required this.targetType,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<_SearchView> createState() => __SearchViewState();
}

class __SearchViewState extends State<_SearchView> {
  late TextEditingController _textEditingController;
  String get query => _textEditingController.text.trim().toLowerCase();
  Set<int> selected = {};

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(
      text: widget.targetType == CustomMissionType.questTrait ? 'field' : null,
    );
    selected = widget.selected.toSet();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<int> ids = [];
    Widget Function(int id) tileBuilder;
    if ([CustomMissionType.trait, CustomMissionType.questTrait].contains(widget.targetType)) {
      ids = _searchTraits();
      tileBuilder = (id) {
        final names = {Transl.trait(id).l, Transl.trait(id).jp};
        return _buildTile(id, '$id - ${names.join("/")}', kTraitIdMapping[id]?.name ?? S.current.unknown);
      };
    } else if ([CustomMissionType.servantClass, CustomMissionType.enemyClass, CustomMissionType.enemyNotServantClass]
        .contains(widget.targetType)) {
      ids = _searchSvtClasses();
      tileBuilder = (id) {
        final names = {Transl.svtClassId(id).l, Transl.svtClassId(id).jp};
        return _buildTile(id, '$id - ${names.join("/")}', kSvtClassIds[id]?.name ?? S.current.unknown);
      };
    } else {
      int? queryId = int.tryParse(query);
      if (queryId != null) ids.add(queryId);
      tileBuilder = (id) {
        return _buildTile(id, id.toString(), null);
      };
    }
    final searchTextStyle =
        Theme.of(context).isDarkMode ? null : TextStyle(color: Theme.of(context).colorScheme.onPrimary);
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: _textEditingController,
          decoration: InputDecoration(
            hintText: S.current.search,
            hintStyle: searchTextStyle?.copyWith(color: searchTextStyle.color?.withOpacity(0.8)),
          ),
          style: searchTextStyle,
          onChanged: (s) {
            EasyDebounce.debounce('search_${widget.targetType}', const Duration(milliseconds: 500), () {
              if (mounted) setState(() {});
            });
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(child: ListView(children: ids.map(tileBuilder).toList())),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: FilterGroup<int>(
                      options: selected.toList(),
                      values: FilterGroupData(),
                      optionBuilder: (v) => Text(_idDescriptor(widget.targetType, v, prefixId: true)),
                      onFilterChanged: (_, last) {
                        if (last != null) onChanged(last);
                      },
                      // combined: true,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.done),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  List<int> _searchTraits() {
    List<int> ids = [];
    int? queryId = int.tryParse(query);
    if (queryId != null) {
      ids = kTraitIdMapping.keys.where((e) => e.toString().contains(query)).toList();
      if (!ids.contains(queryId)) ids.insert(0, queryId);
    } else {
      for (final id in kTraitIdMapping.keys) {
        for (final key in _getTraitStrings(id)) {
          if (key.contains(query)) {
            ids.add(id);
            break;
          }
        }
      }
    }
    if (ids.length > 5) {
      ids.insertAll(0, _preferredTraits.where((e) => ids.contains(e.id)).map((e) => e.id));
    }
    ids.remove(Trait.unknown.id);

    return ids;
  }

  Iterable<String> _getTraitStrings(int id) sync* {
    final trait = kTraitIdMapping[id];
    if (trait != null) yield trait.name.toLowerCase();
    yield* SearchUtil.getAllKeys(Transl.trait(id)).whereType();
  }

  List<int> _searchSvtClasses() {
    List<int> ids = [];
    int? queryId = int.tryParse(query);
    if (queryId != null) {
      ids = SvtClass.values.where((e) => e.id < 97 && e.id.toString().contains(query)).map((e) => e.id).toList();
      if (!ids.contains(queryId)) ids.insert(0, queryId);
      return ids;
    }
    for (final cls in SvtClass.values) {
      if (cls.id >= 97) continue;
      for (final key in _getClassStrings(cls)) {
        if (key.contains(query)) {
          ids.add(cls.id);
          break;
        }
      }
    }
    return ids;
  }

  Iterable<String> _getClassStrings(SvtClass cls) sync* {
    yield cls.name.toLowerCase();
    yield* SearchUtil.getAllKeys(Transl.svtClassId(cls.id)).whereType();
  }

  Widget _buildTile(int id, String title, String? subtitle) {
    return CheckboxListTile(
      value: selected.contains(id),
      title: Text(title),
      // subtitle: subtitle == null ? null : Text(subtitle),
      dense: true,
      onChanged: (_) => onChanged(id),
    );
  }

  void onChanged(int id) {
    setState(() {
      selected.toggle(id);
    });
    widget.onChanged(selected.toList());
  }
}

const _preferredTraits = <Trait>[
  Trait.servant,
  Trait.notBasedOnServant,
  Trait.humanoid,
  Trait.attributeEarth,
  Trait.attributeSky,
  Trait.attributeHuman,
  Trait.alignmentChaotic,
  Trait.alignmentLawful,
  Trait.alignmentNeutral,
  Trait.alignmentGood,
  Trait.alignmentEvil,
  Trait.alignmentBalanced,
  Trait.demonic,
  Trait.wildbeast,
  Trait.divine,
  Trait.undead,
  Trait.dragon,
  Trait.superGiant,
];

class EventChooser extends StatelessWidget {
  final int initTab;
  const EventChooser({super.key, this.initTab = 0});

  @override
  Widget build(BuildContext context) {
    final mainStories =
        db.gameData.mainStories.values.where((war) => war.quests.any((quest) => quest.isMainStoryFree)).toList();
    mainStories.sort2((e) => -e.id);
    final eventWars =
        db.gameData.wars.values.where((war) => !war.isMainStory && war.quests.any((quest) => quest.isAnyFree)).toList();
    eventWars.sort2((war) => -(db.gameData.events[war.eventId]?.startedAt ?? war.id));
    return DefaultTabController(
      length: 2,
      initialIndex: initTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Free Progress or an Event War'),
          bottom: FixedHeight.tabBar(TabBar(tabs: [
            Tab(text: S.current.main_story),
            Tab(text: S.current.event),
          ])),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: [
                for (final war in mainStories)
                  ListTile(
                    dense: true,
                    title: Text(war.lLongName.l),
                    subtitle: Text('ID ${war.id}'),
                    onTap: () {
                      Navigator.pop(context, war.id);
                    },
                  ),
              ],
            ),
            ListView(
              children: [
                for (final war in eventWars)
                  ListTile(
                    dense: true,
                    title: Text(Transl.eventNames(war.eventName).l),
                    subtitle: Text('War ${war.id}: ${war.event?.startedAt.sec2date().toDateString()} (JP)'),
                    onTap: () {
                      Navigator.pop(context, war.id);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _idDescriptor(CustomMissionType type, int id, {bool prefixId = false}) {
  String text;
  switch (type) {
    case CustomMissionType.trait:
    case CustomMissionType.questTrait:
      text = Transl.trait(id).l;
      break;
    case CustomMissionType.quest:
      text = db.gameData.quests[id]?.lName.l ?? id.toString();
      break;
    case CustomMissionType.enemy:
      text = db.gameData.servantsById[id]?.lName.l ?? db.gameData.entities[id]?.lName.l ?? id.toString();
      break;
    case CustomMissionType.servantClass:
    case CustomMissionType.enemyClass:
    case CustomMissionType.enemyNotServantClass:
      text = Transl.svtClassId(id).l;
      break;
  }
  if (prefixId && text != id.toString()) {
    text = '$id-$text';
  }
  return text;
}
