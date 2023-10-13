import 'package:flutter/foundation.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../descriptors/cond_target_num.dart';
import '../../descriptors/mission_conds.dart';
import 'solver/custom_mission.dart';
import 'solver/scheme.dart';

class MasterMissionPage extends StatefulWidget {
  final int? id;
  final MasterMission? masterMission;
  final Region? region;

  MasterMissionPage({super.key, this.id, this.masterMission, this.region})
      : assert(id != null || masterMission != null);

  @override
  _MasterMissionPageState createState() => _MasterMissionPageState();
}

class _MasterMissionPageState extends State<MasterMissionPage> with RegionBasedState<MasterMission, MasterMissionPage> {
  int get id => widget.masterMission?.id ?? widget.id ?? data?.id ?? -1;
  MasterMission get masterMission => data!;
  @override
  void initState() {
    super.initState();
    region = widget.region ?? (widget.masterMission == null ? Region.jp : null);
    doFetchData();
  }

  @override
  Future<MasterMission?> fetchData(Region? r) async {
    MasterMission? v;
    if (r == null || r == widget.region) v = widget.masterMission;
    v ??= await AtlasApi.masterMission(id, region: r ?? Region.jp);
    return v;
  }

  @override
  Widget build(BuildContext context) {
    return InheritSelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('${S.current.master_mission} $id'),
          actions: [
            dropdownRegion(shownNone: widget.masterMission != null),
            PopupMenuButton(
              itemBuilder: (context) => SharedBuilder.websitesPopupMenuItems(
                atlas: Atlas.dbMasterMission(id, region ?? Region.jp),
              ),
            )
          ],
        ),
        body: buildBody(context),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, MasterMission mm) {
    return Column(
      children: [
        Expanded(child: missionList()),
        kDefaultDivider,
        SafeArea(child: buttonBar),
      ],
    );
  }

  Widget missionList() {
    masterMission.missions.sort2((e) => e.dispNo);
    Map<MissionType, int> categorized = {};
    for (final mission in masterMission.missions) {
      categorized.addNum(mission.type, 1);
    }
    return ListView(
      children: [
        ListTile(
          dense: true,
          title: Text(S.current.time_start),
          trailing: Text(masterMission.startedAt.toDateTimeString()),
        ),
        ListTile(
          dense: true,
          title: Text(S.current.time_end),
          trailing: Text(masterMission.endedAt.toDateTimeString()),
        ),
        ListTile(
          dense: true,
          title: Text(S.current.time_close),
          trailing: Text(masterMission.closedAt.toDateTimeString()),
        ),
        ListTile(
          dense: true,
          title: Text(S.current.mission),
          trailing: Text(categorized.entries
              .map((e) => '${e.value} ${Transl.enums(e.key, (enums) => enums.missionType).l}')
              .join('\n')),
        ),
        const Divider(thickness: 1),
        SwitchListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          value: db.settings.display.describeEventMission,
          title: Text(S.current.describe_mission),
          onChanged: (v) {
            setState(() {
              db.settings.display.describeEventMission = v;
            });
          },
        ),
        const Divider(thickness: 1),
        for (final mission in masterMission.missions) _oneEventMission(mission)
      ],
    );
  }

  Widget _oneEventMission(EventMission mission) {
    final customMission = CustomMission.fromEventMission(mission);
    final clearConds = mission.conds.where((e) => e.missionProgressType == MissionProgressType.clear).toList();
    final clearCond = db.settings.display.describeEventMission && clearConds.length == 1 ? clearConds.single : null;

    return SimpleAccordion(
      headerBuilder: (context, _) => ListTile(
        title: clearCond != null
            ? CondTargetNumDescriptor(
                condType: clearCond.condType,
                targetNum: clearCond.targetNum,
                targetIds: clearCond.targetIds,
                details: clearCond.details,
                missions: masterMission.missions,
                textScaleFactor: 0.8,
                unknownMsg: mission.name,
                leading: TextSpan(text: '${mission.dispNo}. '),
              )
            : Text('${mission.dispNo}. ${mission.name}', textScaleFactor: 0.8),
        contentPadding: const EdgeInsetsDirectional.only(start: 16),
        trailing: customMission == null
            ? null
            : IconButton(
                onPressed: () {
                  router.push(child: CustomMissionPage(initMissions: [customMission]));
                },
                icon: const Icon(Icons.search),
                color: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                constraints: const BoxConstraints(minWidth: 24),
              ),
      ),
      contentBuilder: (context) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 24, end: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (kDebugMode) Text('No.${mission.id}', style: Theme.of(context).textTheme.bodySmall),
            if (clearCond != null) Text(mission.name, style: Theme.of(context).textTheme.bodySmall),
            MissionCondsDescriptor(mission: mission, missions: masterMission.missions),
          ],
        ),
      ),
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            final customMissions = masterMission.missions
                .map((e) => CustomMission.fromEventMission(e))
                .whereType<CustomMission>()
                .toList();
            int? warId;
            final region = widget.region ?? Region.jp;
            if (region != Region.jp) {
              final wars = db.gameData.mappingData.warRelease.ofRegion(region)?.where((e) => e < 1000).toList();
              if (wars != null && wars.isNotEmpty) {
                warId = Maths.max(wars);
              }
            }
            router.push(
              child: CustomMissionPage(
                initMissions: customMissions,
                initWarId: warId,
              ),
            );
          },
          icon: const Icon(Icons.search),
          label: Text(S.current.drop_calc_solve),
        )
      ],
    );
  }
}
