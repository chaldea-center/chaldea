import 'package:flutter/cupertino.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/master_mission/solver/solver.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../master_mission/solver/scheme.dart';

class MissionTraitFilterData {
  final cond = FilterGroupData<CustomMissionCond>();
  bool hasRare = false;
  bool rareEnemy = true;
}

class EventMissionTablePage extends StatefulWidget {
  final Event event;
  const EventMissionTablePage({super.key, required this.event});

  @override
  State<EventMissionTablePage> createState() => _EventMissionTablePageState();
}

class _EventMissionTablePageState extends State<EventMissionTablePage> {
  Set<CustomMissionCond> conds = {};
  List<Quest> freeQuests = [];
  List<QuestPhase> questPhases = [];
  bool _loading = false;

  final filterData = MissionTraitFilterData();
  Region? region = Region.jp;

  @override
  void initState() {
    super.initState();
    final missions = widget.event.missions.toList();
    missions.sort2((e) => e.dispNo);
    for (final eventMission in missions) {
      final mission = CustomMission.fromEventMission(eventMission);
      if (mission == null) continue;
      for (final cond in mission.conds) {
        if (cond.type.isTraitType || cond.type.isClassType) conds.add(cond);
      }
    }

    for (final warId in widget.event.warIds) {
      final war = db.gameData.wars[warId];
      if (war == null) continue;
      for (final quest in war.quests) {
        if (quest.isAnyFree) freeQuests.add(quest);
      }
    }
    fetchData(region);
  }

  Future<void> fetchData(Region? region) async {
    // List<QuestPhase> phases = [];
    setState(() {
      questPhases.clear();
      _loading = true;
      filterData.hasRare = false;
    });
    await Future.wait(freeQuests.map((e) async {
      if (region == null) return null;
      final q = await AtlasApi.questPhase(e.id, e.phases.last, region: region);
      if (q != null) {
        questPhases.add(q);
        if (!filterData.hasRare && q.allEnemies.any((e) => e.enemyScript.isRare)) {
          filterData.hasRare = true;
        }
      }
      if (mounted) setState(() {});
    }).toList());
    questPhases.sort2((e) => -e.priority);
    _loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          dense: true,
          title: Text(S.current.switch_region),
          subtitle:
              Text.rich(TextSpan(text: '${S.current.quest}: ${questPhases.length}/${freeQuests.length}', children: [
            if (_loading) const CenterWidgetSpan(child: CupertinoActivityIndicator()),
          ])),
          trailing: FilterGroup<Region>(
            options: [
              Region.jp,
              if (widget.event.extra.startTime.na != null) Region.na,
            ],
            values: FilterRadioData(region),
            combined: true,
            optionBuilder: (v) => Text(v.localName),
            onFilterChanged: (optionData, lastChanged) {
              if (lastChanged == Region.na && widget.event.extra.startTime.na == null) {
                EasyLoading.showError('Event not released in NA');
                return;
              }
              if (_loading) {
                EasyLoading.showInfo('Still in loading');
                return;
              }
              region = lastChanged;
              setState(() {});
              fetchData(region);
            },
          ),
        ),
        table(),
        if (filterData.hasRare)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              children: [
                CheckboxWithLabel(
                  value: filterData.rareEnemy,
                  label: Text(S.current.count_rare_enemy),
                  onChanged: (v) {
                    if (v != null) filterData.rareEnemy = v;
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        FilterGroup<CustomMissionCond>(
          title: Text(S.current.filter),
          options: conds.toList(),
          values: filterData.cond,
          optionBuilder: (cond) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: Text(describeCond(cond), textScaleFactor: 0.95),
          ),
          onFilterChanged: (value, _) {
            setState(() {});
          },
          shrinkWrap: true,
        )
      ],
    );
  }

  String describeCond(CustomMissionCond cond) {
    switch (cond.type) {
      case CustomMissionType.trait:
      case CustomMissionType.questTrait:
        return _describeTraits(cond);
      case CustomMissionType.enemyClass:
        return _describeClasses(cond);
      case CustomMissionType.servantClass:
        return '${_describeClasses(cond)}(${S.current.servant})';
      case CustomMissionType.enemyNotServantClass:
        return '${_describeClasses(cond)}(${S.current.enemy_not_servant})';
      default:
        return 'NotSupport: ${cond.type}';
    }
  }

  String _describeTraits(CustomMissionCond cond) {
    return cond.targetIds.map((e) => Transl.trait(e).l.trimChar('"')).join(cond.useAnd ? '&' : '/');
  }

  String _describeClasses(CustomMissionCond cond) {
    return cond.targetIds.map((e) => Transl.svtClassId(e).l).join(cond.useAnd ? '&' : '/');
  }

  Widget table() {
    List<TableRow> children = [];
    Map<int, int> spotQuestsCount = {};
    for (final quest in questPhases) {
      spotQuestsCount.addNum(quest.spotId, 1);
    }
    for (final quest in questPhases) {
      final spotImg = quest.spot?.shownImage;
      String name;
      if (spotQuestsCount[quest.spotId]! > 1) {
        name = quest.lName.l;
      } else {
        name = quest.lSpot.l;
      }
      Map<CustomMissionCond, int> counts = {};
      for (final cond in filterData.cond.options.isEmpty ? conds : filterData.cond.options) {
        int count = MissionSolver.countMissionTarget(CustomMission(count: 1, conds: [cond]), quest,
            includeRare: filterData.rareEnemy);
        if (count > 0) counts[cond] = count;
      }

      final rowCells = [
        InkWell(
          onTap: quest.routeTo,
          child: Text.rich(
            TextSpan(children: [
              if (spotImg != null) CenterWidgetSpan(child: db.getIconImage(spotImg, width: 28)),
              TextSpan(text: name),
            ]),
            textScaleFactor: 0.9,
          ),
        ),
        Wrap(
          spacing: 3,
          children: [
            if (quest.allEnemies.isEmpty)
              const Text(
                'No enemy data.',
                textScaleFactor: 0.85,
              ),
            for (final entry in counts.entries)
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: describeCond(entry.key),
                    style: const TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.w300),
                  ),
                  TextSpan(text: '×${entry.value}'),
                ]),
                textScaleFactor: 0.85,
              ),
          ],
        )
      ];

      children.add(
          TableRow(children: [for (final cell in rowCells) Padding(padding: const EdgeInsets.all(6), child: cell)]));
    }
    return Table(
      columnWidths: const {0: MinColumnWidth(FractionColumnWidth(0.35), FixedColumnWidth(150))},
      border: TableBorder.all(color: Divider.createBorderSide(context).color),
      children: children,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    );
  }
}
