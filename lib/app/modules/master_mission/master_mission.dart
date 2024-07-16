import 'package:flutter/foundation.dart';

import 'package:just_audio/just_audio.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/audio.dart';
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
  final _audioPlayer = MyAudioPlayer<String>();
  @override
  void initState() {
    super.initState();
    region = widget.region ?? (widget.masterMission == null ? Region.jp : null);
    _audioPlayer.player.setLoopMode(LoopMode.all);
    _audioPlayer.player.setVolume(0.5);
    doFetchData().then((value) {
      final bgmUrl = value?.completeMission?.bgm?.audioAsset;
      if (bgmUrl != null) _audioPlayer.playUri(bgmUrl);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.stop();
  }

  @override
  Future<MasterMission?> fetchData(Region? r, {Duration? expireAfter}) async {
    MasterMission? v;
    if (r == null || r == widget.region) v = widget.masterMission;
    v ??= await AtlasApi.masterMission(id, region: r ?? Region.jp, expireAfter: expireAfter);
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
    final missions = masterMission.missions.toList();
    missions.sort2((e) => e.dispNo);
    Map<MissionType, int> categorized = {};
    Map<int, int> gifts = {};
    for (final mission in missions) {
      categorized.addNum(mission.type, 1);
      Gift.checkAddGifts(gifts, mission.gifts);
    }

    return ListView(
      children: [
        DividerWithTitle(title: "${S.current.master_mission} ${masterMission.id}"),
        if (masterMission.missionIconDetailText != null)
          ListTile(
            dense: true,
            title: Text(
              masterMission.missionIconDetailText!,
              textAlign: TextAlign.center,
            ),
          ),
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
          trailing: Text(
            masterMission.closedAt.toDateTimeString(),
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ),
        ListTile(
          dense: true,
          title: Text(S.current.mission),
          trailing: Text(categorized.entries
              .map((e) => '${e.value} ${Transl.enums(e.key, (enums) => enums.missionType).l}')
              .join('\n')),
        ),
        if (masterMission.completeMission != null) ...[
          ListTile(
            dense: true,
            title: Text(masterMission.completeMission?.bgm?.tooltip ?? S.current.bgm),
            trailing: SoundPlayButton(
              player: _audioPlayer,
              url: masterMission.completeMission!.bgm?.audioAsset,
            ),
            onTap: masterMission.completeMission?.bgm?.routeTo,
          ),
          buildPanel(masterMission.completeMission!),
        ],
        DividerWithTitle(title: S.current.game_rewards),
        ListTile(
          dense: true,
          title: Center(
            child: SharedBuilder.itemGrid(
              context: context,
              items: gifts.entries,
              sort: true,
              height: 36,
            ),
          ),
        ),
        if (masterMission.completeMission?.gifts.isNotEmpty == true)
          ListTile(
            dense: true,
            title: Center(
              child: SharedBuilder.giftGrid(
                context: context,
                gifts: masterMission.completeMission!.gifts,
                height: 36,
              ),
            ),
          ),
        DividerWithTitle(title: S.current.mission),
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
        const Divider(thickness: 1, indent: 16, endIndent: 16),
        for (final mission in missions) _oneEventMission(mission)
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
            : Text('${mission.dispNo}. ${mission.name}', textScaler: const TextScaler.linear(0.8)),
        contentPadding: const EdgeInsetsDirectional.only(start: 16),
        trailing: customMission == null
            ? null
            : IconButton(
                onPressed: () {
                  router.push(child: CustomMissionPage(initMissions: [customMission]));
                },
                icon: const Icon(Icons.search),
                color: AppTheme(context).tertiary,
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

  Widget buildPanel(CompleteMission completeMission) {
    final assets = AssetURL(region ?? Region.jp);
    final eventId = masterMission.id;
    const center = Offset(1344 / 2, 576 / 2 + 45);
    const double a = 108.3;
    Widget child = Stack(
      children: [
        Positioned.fill(
          child: db.getIconImage(
            assets.eventUi("Prefabs/$eventId/mission_bg_$eventId"),
            fit: BoxFit.fill,
          ),
        ),
        Positioned.fromRect(
          rect: Rect.fromCenter(
            center: center + const Offset(1.5, -1.5),
            width: 470,
            height: 470,
          ),
          child: db.getIconImage(
            assets.eventUi("Prefabs/$eventId/img_flame_$eventId"),
            width: 470,
            height: 470,
          ),
        ),
        Positioned(
          left: 32,
          top: 150,
          child: buildOneGrid(
            idx: -999,
            on: (context) => const SizedBox(width: 132, height: 138),
            off: (context) => db.getIconImage(
              assets.eventUi("Prefabs/$eventId/button_mission_$eventId"),
              width: 132,
              height: 138,
            ),
          ),
        ),
        for (int index = 0; index < 16; index++)
          Positioned.fromRect(
            rect: Rect.fromCenter(
              center: center + Offset((index % 4 - 2 + 0.5) * 108, (index ~/ 4 - 2 + 0.5) * 108),
              width: a,
              height: a,
            ),
            child: buildOneGrid(
              idx: index,
              on: (context) => db.getIconImage(
                assets.extract("CompleteMission/${completeMission.objectId}/$index/$index.png"),
                errorWidget: (context, url, error) => Container(color: Colors.white),
                fit: BoxFit.fill,
                width: a,
                height: a,
              ),
              off: (context) => db.getIconImage(
                assets.eventUi("Prefabs/$eventId/mission_on_${eventId * 100 + index + 1}"),
                fit: BoxFit.fill,
                width: a,
                height: a,
              ),
            ),
          ),
      ],
    );
    return Center(
      child: AspectRatio(
        aspectRatio: 1344 / 576,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 1344,
              height: 576,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  final Map<int, bool> _completeMissionStates = {};
  Widget buildOneGrid({required int idx, required WidgetBuilder on, required WidgetBuilder off}) {
    final state = _completeMissionStates[idx] ?? false;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        key: Key('complete_item_${idx}_$state'),
        onTap: () {
          setState(() {
            _completeMissionStates[idx] = !state;
          });
        },
        onLongPress: idx >= 0
            ? () async {
                final value = !(_completeMissionStates.values.where((e) => e).length > 8);
                for (int index = 0; index < 16; index++) {
                  if ((_completeMissionStates[index] ?? false) == value) continue;
                  _completeMissionStates[index] = value;
                  if (mounted) setState(() {});
                  await Future.delayed(const Duration(milliseconds: 150));
                }
              }
            : null,
        child: state ? on(context) : off(context),
      ),
    );
  }
}
