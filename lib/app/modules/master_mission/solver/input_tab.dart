import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/master_mission/solver/solver.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../api/atlas.dart';
import 'scheme.dart';

class MissionInputTab extends StatefulWidget {
  final List<CustomMission> initMissions;
  final int? initWarId;
  final ValueChanged<MissionSolution> onSolved;

  const MissionInputTab({
    Key? key,
    this.initMissions = const [],
    this.initWarId,
    required this.onSolved,
  }) : super(key: key);

  @override
  State<MissionInputTab> createState() => _MissionInputTabState();
}

class _MissionInputTabState extends State<MissionInputTab> {
  late ScrollController _scrollController;
  List<CustomMission> missions = [];
  int warId = 0;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    missions = List.of(widget.initMissions);
    warId = widget.initWarId ??
        Maths.max(
            db2.gameData.mainStories.values
                .where(
                    (war) => war.quests.any((quest) => quest.isMainStoryFree))
                .map((e) => e.id),
            0);
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
          child: missions.isEmpty
              ? const Center(child: Text('No mission, click + to add mission'))
              : ListView.separated(
                  controller: _scrollController,
                  itemBuilder: (context, index) => _oneMission(index),
                  separatorBuilder: (_, __) => kDefaultDivider,
                  itemCount: missions.length,
                ),
        ),
        kDefaultDivider,
        eventSelector,
        buttonBar,
      ],
    );
  }

  Widget _oneMission(int index) {
    CustomMission mission = missions[index];
    return SimpleAccordion(
      key: Key('mission_input_${mission.hashCode}'),
      headerBuilder: (context, collapsed) => ListTile(
        leading: Text(
          (index + 1).toString(),
          textAlign: TextAlign.center,
        ),
        horizontalTitleGap: 0,
        title: mission.buildDescriptor(context),
      ),
      contentBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mission.originDetail?.isNotEmpty == true)
            ListTile(
              title: const Text('OriginMsg'),
              subtitle: Text(mission.originDetail!),
            ),
          ListTile(
            leading: const Text('Type'),
            trailing: DropdownButton<MissionTargetType>(
              value: mission.type,
              items: [
                for (final type in MissionTargetType.values)
                  DropdownMenuItem(
                    value: type,
                    child: Text(_getTargetTypeName(type)),
                  ),
              ],
              onChanged: (v) {
                setState(() {
                  if (v != null) mission.type = v;
                });
              },
            ),
          ),
          ListTile(
            leading: Text(S.current.counts),
            trailing: SizedBox(
              width: 72,
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  isDense: true,
                  hintText: mission.count.toString(),
                ),
                textAlign: TextAlign.center,
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
          ListTile(
            leading: const Text('IDs'),
            title: Wrap(
              spacing: 2,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final id in mission.ids)
                  InkWell(
                    onTap: () {
                      setState(() {
                        mission.ids.remove(id);
                      });
                    },
                    onLongPress: () {
                      // enter trait detail
                    },
                    child: AbsorbPointer(
                      child: FilterOption(
                        selected: false,
                        value: id,
                        child: Text(_idDescriptor(mission.type, id)),
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: () async {
                    final result = await SplitRoute.push<int?>(
                        context, _SearchView(targetType: mission.type));
                    if (result != null) {
                      if (mission.ids.contains(result)) {
                        EasyLoading.showInfo(S.current
                            .item_already_exist_hint(result.toString()));
                      } else {
                        mission.ids.add(result);
                      }
                    }
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
          Center(
            child: IconButton(
              onPressed: () {
                setState(() {
                  missions.remove(mission);
                });
              },
              icon: const Icon(Icons.clear),
            ),
          )
        ],
      ),
    );
  }

  String _getTargetTypeName(MissionTargetType type) {
    return {
      MissionTargetType.trait: "Enemy Trait",
      MissionTargetType.questTrait: "Field Trait",
      MissionTargetType.quest: "Specific Quests",
      MissionTargetType.enemy: "Specific Enemies",
      MissionTargetType.servantClass: "Servant Classes",
      MissionTargetType.enemyClass: "Enemy Classes",
      MissionTargetType.enemyNotServantClass: "Enemy Classes\n(Not Servant)"
    }[type]!;
  }

  String _idDescriptor(MissionTargetType type, int id) {
    switch (type) {
      case MissionTargetType.trait:
      case MissionTargetType.questTrait:
        return Transl.trait(id).l;
      case MissionTargetType.quest:
        return db2.gameData.quests[id]?.lName.l ?? id.toString();
      case MissionTargetType.enemy:
        return db2.gameData.servantsById[id]?.lName.l ??
            db2.gameData.entities[id]?.lName.l ??
            id.toString();
      case MissionTargetType.servantClass:
      case MissionTargetType.enemyClass:
      case MissionTargetType.enemyNotServantClass:
        return Transl.svtClassId(id).l;
    }
  }

  Widget get eventSelector {
    final war = db2.gameData.wars[warId];
    String title;
    String leading = S.current.event_title;
    if (war == null) {
      title = 'Invalid Choice';
    } else if (war.isMainStory) {
      leading = 'Free ~ ';
      title = Transl.warNames(
              war.name.trimChar('-').isEmpty ? war.longName : war.name)
          .l;
    } else {
      title = Transl.eventNames(war.eventName).l;
    }
    title = '[$warId] $title';
    void _onTap() async {
      final result = await SplitRoute.push<int?>(
          context, EventChooser(initTab: warId < 1000 ? 0 : 1));
      if (result != null) {
        warId = result;
      }
      setState(() {});
    }

    return ListTile(
      leading: Text(leading),
      title: TextButton(onPressed: _onTap, child: Text(title)),
      trailing: IconButton(
        onPressed: _onTap,
        icon: const Icon(Icons.change_circle_outlined),
      ),
    );
  }

  bool _isRegionNA = false;
  bool get isRegionNA => warId < 1000 ? false : _isRegionNA;

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        DropdownButton<bool>(
          value: isRegionNA,
          items: [
            for (final isNA in [false, true])
              DropdownMenuItem(
                child: Text(isNA ? 'NA' : 'JP'),
                value: isNA,
              ),
          ],
          onChanged: (warId < 1000)
              ? null
              : (v) {
                  setState(() {
                    if (v != null) _isRegionNA = v;
                  });
                },
        ),
        IconButton(
          onPressed: () {
            SimpleCancelOkDialog(
              title: Text(S.current.clear),
              onTapOk: () {
                missions.clear();
                if (mounted) setState(() {});
              },
            ).showDialog(context);
          },
          icon: const Icon(Icons.clear_all),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              missions.add(CustomMission(
                  type: MissionTargetType.trait, count: 0, ids: []));
            });
          },
          icon: const Icon(Icons.add_circle_outline),
        ),
        ElevatedButton(
          onPressed: _solveProblem,
          child: Text(S.current.drop_calc_solve),
        )
      ],
    );
  }

  final solver = MissionSolver();
  Future<void> _solveProblem() async {
    if (!missions
        .any((mission) => mission.ids.isNotEmpty && mission.count > 0)) {
      EasyLoading.showError('No valid missions');
      return;
    }
    final region = isRegionNA ? Region.na : Region.jp;
    void _showHint(String hint) =>
        EasyLoading.show(status: hint, maskType: EasyLoadingMaskType.clear);
    _showHint('Solving.');
    try {
      // TODO: add success/no enemy data/failed count
      List<QuestPhase> quests = [];
      List<Future> futures = [];
      Map<int, int> phases = {};

      int countSuccess = 0, countError = 0, countNoEnemy = 0;
      if (warId < 1000) {
        for (final war in db2.gameData.wars.values) {
          if (!war.isMainStory || war.id > warId) continue;
          for (final quest in war.quests) {
            if (!quest.isMainStoryFree) continue;
            phases[quest.id] = quest.phases.last;
          }
        }
        // door quest 10AP
        phases[94061636] = 1;
      } else {
        NiceWar? war = isRegionNA
            ? await AtlasApi.war(warId, region: Region.na)
            : db2.gameData.wars[warId];
        if (war == null) {
          EasyLoading.showError('War $warId not found');
          return;
        }
        for (final quest in war.quests) {
          if (!quest.isAnyFree) continue;
          if (quest.phasesWithEnemies.contains(quest.phases.last)) {
            phases[quest.id] = quest.phases.last;
          } else {
            // no enemy data
            countNoEnemy += 1;
          }
        }
      }
      for (final entry in phases.entries) {
        futures.add(AtlasApi.questPhase(
          entry.key,
          entry.value,
          region: region,
        ).then((quest) async {
          if (quest == null) {
            countError += 1;
          } else if (quest.allEnemies.isNotEmpty) {
            quests.add(quest);
            countSuccess += 1;
          } else {
            countNoEnemy += 1;
          }
          _showHint('Resolve Quests: total ${phases.length + countNoEnemy},'
              ' $countSuccess success, $countError error, $countNoEnemy no data');
        }));
      }

      await Future.wait(futures);
      if (countError + countNoEnemy > 0) {
        EasyLoading.dismiss();
        final _continue = await showDialog(
          context: context,
          builder: (context) => SimpleCancelOkDialog(
            title: Text(S.current.warning),
            content: Text(
                'Resolve Quests: total ${phases.length + countNoEnemy},'
                ' $countSuccess success, $countError error, $countNoEnemy no data\n'
                'Still Continue?'),
          ),
        );
        if (_continue != true) {
          EasyLoading.dismiss();
          return;
        }
      }
      final validQuests = quests.whereType<QuestPhase>().toList();
      if (validQuests.isEmpty) {
        EasyLoading.showError('No Valid Quests');
        return;
      }
      final missionsCopy = missions.map((e) => e.copy()).toList();
      final result = await solver.solve(
        quests: validQuests,
        missions: missionsCopy,
      );
      final solution = MissionSolution(
        result: result,
        missions: missionsCopy,
        quests: validQuests,
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

class _SearchView extends StatefulWidget {
  final MissionTargetType targetType;
  const _SearchView({Key? key, required this.targetType}) : super(key: key);

  @override
  State<_SearchView> createState() => __SearchViewState();
}

class __SearchViewState extends State<_SearchView> {
  late TextEditingController _textEditingController;
  String get query => _textEditingController.text.trim().toLowerCase();

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(
      text: widget.targetType == MissionTargetType.questTrait ? 'field' : null,
    );
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
    if ([MissionTargetType.trait, MissionTargetType.questTrait]
        .contains(widget.targetType)) {
      ids = _searchTraits();
      tileBuilder = _buildTraitTile;
    } else if ([
      MissionTargetType.servantClass,
      MissionTargetType.enemyClass,
      MissionTargetType.enemyNotServantClass
    ].contains(widget.targetType)) {
      ids = _searchSvtClasses();
      tileBuilder = _buildClassTile;
    } else {
      int? queryId = int.tryParse(query);
      if (queryId != null) ids.add(queryId);
      tileBuilder = (id) => ListTile(
            title: Text(id.toString()),
            onTap: () => Navigator.pop(context, id),
          );
    }
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _textEditingController,
          decoration: InputDecoration(hintText: S.current.search),
          onChanged: (s) {
            EasyDebounce.debounce('search_${widget.targetType}',
                const Duration(milliseconds: 500), () {
              if (mounted) setState(() {});
            });
          },
        ),
      ),
      body: ListView(children: ids.map(tileBuilder).toList()),
    );
  }

  List<int> _searchTraits() {
    List<int> ids = [];
    int? queryId = int.tryParse(query);
    if (queryId != null) {
      ids = kTraitIdMapping.keys
          .where((e) => e.toString().contains(query))
          .toList();
      if (!ids.contains(queryId)) ids.add(queryId);
      return ids;
    }
    for (final id in kTraitIdMapping.keys) {
      for (final key in _getTraitStrings(id)) {
        if (key.contains(query)) {
          ids.add(id);
          break;
        }
      }
    }
    return ids;
  }

  Iterable<String> _getTraitStrings(int id) sync* {
    final trait = kTraitIdMapping[id];
    if (trait != null) yield trait.name.toLowerCase();
    final mapping = Transl.trait(id);
    yield mapping.l;
    yield mapping.jp;
  }

  Widget _buildTraitTile(int id) {
    final names = {Transl.trait(id).l, Transl.trait(id).jp};
    return ListTile(
      title: Text('$id - ${names.join("/")}'),
      subtitle: Text(kTraitIdMapping[id]?.name ?? 'Unknown'),
      onTap: () {
        Navigator.pop(context, id);
      },
    );
  }

  List<int> _searchSvtClasses() {
    List<int> ids = [];
    int? queryId = int.tryParse(query);
    if (queryId != null) {
      ids = kSvtClassIds.keys
          .where((e) => e < 97 && e.toString().contains(query))
          .toList();
      if (!ids.contains(queryId)) ids.add(queryId);
      return ids;
    }
    for (final id in kSvtClassIds.keys) {
      if (id >= 97) continue;
      for (final key in _getClassStrings(id)) {
        if (key.contains(query)) {
          ids.add(id);
          break;
        }
      }
    }
    return ids;
  }

  Iterable<String> _getClassStrings(int id) sync* {
    final svtClass = kSvtClassIds[id];
    if (svtClass != null) yield svtClass.name.toLowerCase();
    final mapping = Transl.svtClass(svtClass!);
    yield mapping.l;
    yield mapping.jp;
  }

  Widget _buildClassTile(int id) {
    final names = {Transl.svtClassId(id).l, Transl.svtClassId(id).jp};
    return ListTile(
      title: Text('$id - ${names.join("/")}'),
      subtitle: Text(kSvtClassIds[id]?.name ?? 'Unknown'),
      onTap: () {
        Navigator.pop(context, id);
      },
    );
  }
}

class EventChooser extends StatelessWidget {
  final int initTab;
  const EventChooser({Key? key, this.initTab = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mainStories = db2.gameData.mainStories.values
        .where((war) => war.quests.any((quest) => quest.isMainStoryFree))
        .toList();
    mainStories.sort2((e) => -e.id);
    final eventWars = db2.gameData.wars.values
        .where((war) =>
            !war.isMainStory && war.quests.any((quest) => quest.isAnyFree))
        .toList();
    eventWars.sort2(
        (war) => -(db2.gameData.events[war.eventId]?.startedAt ?? war.id));
    return DefaultTabController(
      length: 2,
      initialIndex: initTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Free Progress or an Event War'),
          bottom: TabBar(tabs: [
            Tab(text: S.current.main_record),
            Tab(text: S.current.event_title),
          ]),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: [
                for (final war in mainStories)
                  ListTile(
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
                    title: Text(Transl.eventNames(war.eventName).l),
                    subtitle: Text(
                        'War id ${war.id}: ${war.event?.startedAt.sec2date().toDateString()} (JP)'),
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
