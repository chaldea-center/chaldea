import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../state.dart';

class UserEventMissionReceivePage extends StatefulWidget {
  final FakerRuntime runtime;
  const UserEventMissionReceivePage({super.key, required this.runtime});

  @override
  State<UserEventMissionReceivePage> createState() => _UserEventMissionReceivePageState();
}

class _UserEventMissionReceivePageState extends State<UserEventMissionReceivePage> {
  late final runtime = widget.runtime;
  late final userEventMissions = runtime.mstData.userEventMission;
  final thisYear = DateTime.now().year;
  List<MasterMission> mms = [];
  // late final mms = runtime.gameData.masterMissions.values.toList();

  MasterMission? _mm;

  Set<int> selectedMissions = {};

  List<int> giftObjectIds = [];
  final havingGifts = FilterGroupData<int>();
  final notHavingGifts = FilterGroupData<int>();
  final progressFilter = FilterGroupData<MissionProgressType>();

  late final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    mms = runtime.gameData.timerData.masterMissions.toList();
    final now = DateTime.now().timestamp;

    mms.retainWhere((mm) {
      if (const [MissionType.event, MissionType.random].contains(mm.type)) return false;
      if (mm.startedAt > now || mm.closedAt < now) return false;
      if (mm.type == MissionType.daily) {
        if (mm.endedAt < now - kSecsPerDay * 40) return false;
      }
      return true;
    });

    // mms.removeWhere((mm) => mm.type == MissionType.daily && mm.endedAt - mm.startedAt > kSecsPerDay * 40);
    mms.sortByList((e) => [e.endedAt, e.closedAt, e.id]);
    if (mms.isNotEmpty) {
      onSelectMM(
        mms.firstWhere(
          (mm) => mm.missions.any((e) => getMissionProgress(e.id) != MissionProgressType.achieve),
          orElse: () => mms.first,
        ),
      );
    }
    if (mounted) setState(() {});
  }

  MissionProgressType getMissionProgress(int eventMissionId) {
    final progress = userEventMissions[eventMissionId]?.missionProgressType;
    if (progress == null) return MissionProgressType.none;
    return MissionProgressType.fromValue(progress);
  }

  bool isMissionClear(int eventMissionId) => getMissionProgress(eventMissionId) == MissionProgressType.clear;

  void onSelectMM(MasterMission mm) {
    if (_mm != mm) {
      selectedMissions.clear();
    }
    _mm = mm;
    giftObjectIds = mm.missions.expand((e) => e.gifts).map((e) => e.objectId).toSet().toList();
    if (mm.id == MasterMission.kExtraMasterMissionId) {
      final clearGifts = mm.missions
          .where((e) => isMissionClear(e.id))
          .expand((e) => e.gifts)
          .map((e) => e.objectId)
          .toSet();
      giftObjectIds.sortByList((e) => [clearGifts.contains(e) ? 0 : 1, e]);
      giftObjectIds.sort((a, b) {
        final r = (clearGifts.contains(a) ? 0 : 1).compareTo((clearGifts.contains(b) ? 0 : 1));
        if (r != 0) return r;
        return Item.compare2(a, b);
      });
    } else {
      giftObjectIds.sort(Item.compare2);
    }
    havingGifts.options.retainAll(giftObjectIds);
    notHavingGifts.options.retainAll(giftObjectIds);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    selectedMissions.retainWhere(isMissionClear);
    final missions = _mm?.missions.toList() ?? [];
    missions.retainWhere((mission) {
      final gifts = mission.gifts.map((e) => e.objectId).toSet();
      if (havingGifts.isNotEmpty && !havingGifts.matchAny(gifts)) return false;
      if (notHavingGifts.isNotEmpty && notHavingGifts.matchAny(gifts)) return false;
      if (!progressFilter.matchOne(getMissionProgress(mission.id))) return false;
      return true;
    });
    missions.sort2((e) => e.dispNo);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.master_mission),
        actions: [runtime.buildHistoryButton(context), runtime.buildMenuButton(context)],
      ),
      body: Column(
        children: [
          buildHeader(),
          Expanded(
            child: Scrollbar(
              trackVisibility: PlatformU.isDesktopOrWeb,
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                itemCount: missions.length,
                itemBuilder: (context, index) {
                  return buildEventMission(missions[index]);
                },
              ),
            ),
          ),
          SafeArea(child: buildButtonBar()),
        ],
      ),
    );
  }

  Widget buildHeader() {
    Widget child = DropdownButton<MasterMission>(
      isExpanded: true,
      value: _mm,
      items: [for (final mm in mms) DropdownMenuItem(value: mm, child: buildMasterMission(mm))],
      onChanged: (v) {
        setState(() {
          if (v != null) onSelectMM(v);
        });
      },
    );
    return Container(
      color: Theme.of(context).highlightColor,
      padding: EdgeInsets.only(bottom: 8),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  Widget buildMasterMission(MasterMission mm) {
    int clearNum = mm.missions.where((e) => getMissionProgress(e.id) == MissionProgressType.clear).length;
    int achieveNum = mm.missions.where((e) => getMissionProgress(e.id) == MissionProgressType.achieve).length;
    int notClearNum = mm.missions.length - clearNum - achieveNum;
    final now = DateTime.now().timestamp;
    return ListTile(
      dense: true,
      selected: (clearNum > 0 || notClearNum > 0) && mm.startedAt < now && mm.endedAt > now,
      enabled: !(notClearNum == 0 && clearNum == 0),
      title: Text(
        '[${mm.missions.length} ${Transl.enums(mm.type, (v) => v.missionType).l}] ID ${mm.id} ${mm.lMissionIconDetailText ?? ""}',
      ),
      subtitle: Text(
        [mm.startedAt, mm.endedAt, if (mm.closedAt != mm.endedAt) mm.closedAt]
            .map((e) {
              final date = e.sec2date();
              return mm.id == MasterMission.kExtraMasterMissionId
                  ? date.toDateString()
                  : date.toCustomString(year: date.year != thisYear, second: false);
            })
            .join(' ~ '),
      ),
      trailing: Text('$notClearNum/$clearNum/$achieveNum'),
    );
  }

  Widget buildEventMission(EventMission mission) {
    Widget title = Text('${mission.dispNo}. ${mission.name}', maxLines: 2, overflow: TextOverflow.ellipsis);
    Widget subtitle = SharedBuilder.giftGrid(context: context, gifts: mission.gifts, width: 32);
    Widget child;
    if (isMissionClear(mission.id)) {
      child = CheckboxListTile(
        title: title,
        subtitle: subtitle,
        value: selectedMissions.contains(mission.id),
        onChanged: isMissionClear(mission.id)
            ? (v) {
                setState(() {
                  if (v!) {
                    selectedMissions.add(mission.id);
                  } else {
                    selectedMissions.remove(mission.id);
                  }
                });
              }
            : null,
      );
    } else {
      int? progressNum, targetNum;
      final eventMissionFix = runtime.mstData.userEventMissionFix[mission.id];
      if (eventMissionFix != null) {
        // progressType=eventMissionFix.progressType;
        progressNum = eventMissionFix.num;
      }
      for (final cond in mission.conds.where((e) => e.missionProgressType == MissionProgressType.clear)) {
        if (cond.condType == CondType.missionConditionDetail) {
          final condDetailId = cond.targetIds.firstOrNull;
          if (condDetailId == null) continue;
          progressNum ??= runtime.mstData.userEventMissionCondDetail[condDetailId]?.progressNum;
          targetNum = cond.targetNum;
        } else if (cond.condType == CondType.eventMissionClear) {
          progressNum ??= cond.targetIds.where((mid) {
            final progressType = runtime.mstData.userEventMission[mid]?.missionProgressType;
            return progressType == MissionProgressType.clear.value || progressType == MissionProgressType.achieve.value;
          }).length;
          targetNum = cond.targetNum;
        }
      }

      final progressType = getMissionProgress(mission.id);
      child = ListTile(
        title: title,
        subtitle: subtitle,
        enabled: progressType == MissionProgressType.achieve,
        trailing: Text(
          [
            progressType.name,
            if (progressNum != null || targetNum != null) '${progressNum ?? "?"}/${targetNum ?? "?"}',
          ].join('\n'),
          textAlign: TextAlign.end,
        ),
      );
    }
    return ListTileTheme.merge(dense: true, minLeadingWidth: 16, child: child);
  }

  Widget buildButtonBar() {
    final progresses = _mm?.missions.map((e) => getMissionProgress(e.id)).toSet().toList() ?? [];
    progresses.sort2((e) => e.index);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (title, filterData) in [(S.current.show, havingGifts), (S.current.hide, notHavingGifts)])
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 16),
              ConstrainedBox(constraints: BoxConstraints(minWidth: 48), child: Text(title)),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: FilterGroup<int>(
                    options: giftObjectIds,
                    values: filterData,
                    padding: EdgeInsets.zero,
                    combined: true,
                    shrinkWrap: true,
                    optionBuilder: (v) {
                      return GameCardMixin.anyCardItemBuilder(
                        context: context,
                        id: v,
                        height: 36,
                        padding: EdgeInsets.all(2),
                        jumpToDetail: false,
                      );
                    },
                    onFilterChanged: (_, _) {
                      setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 4),
        if (progresses.isNotEmpty)
          FilterGroup<MissionProgressType>(
            options: progresses,
            values: progressFilter,
            padding: EdgeInsets.only(bottom: 4),
            combined: true,
            optionBuilder: (v) => Text(v.name),
            onFilterChanged: (v, _) {
              setState(() {});
            },
          ),
        Center(
          child: FilledButton(
            onPressed: selectedMissions.isEmpty ? null : receiveMissions,
            child: Text('Mission Receive ×${selectedMissions.length}'),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Future<void> receiveMissions() async {
    final missions = {
      if (_mm != null)
        for (final m in _mm!.missions) m.id: m,
    };
    final gifts = <int, int>{};
    if (selectedMissions.isEmpty || !selectedMissions.every((e) => missions.containsKey(e))) {
      EasyLoading.showError('Another mm mission is selected');
      return;
    }
    if (!selectedMissions.every(isMissionClear)) {
      EasyLoading.showError('Contain non-clear progress mission');
      return;
    }
    for (final id in selectedMissions) {
      for (final gift in missions[id]!.gifts) {
        gifts.addNum(gift.objectId, gift.num);
      }
    }
    if (runtime.runningTask.value) return;
    SimpleConfirmDialog(
      title: Text('Receive ${selectedMissions.length} missions'),
      scrollable: true,
      content: SharedBuilder.itemGrid(context: context, items: gifts.entries.toList(), height: 36),
      onTapOk: () async {
        await runtime.runTask(() => runtime.agent.eventMissionClearReward(missionIds: selectedMissions.toList()));
        selectedMissions.retainWhere(isMissionClear);
        if (mounted) setState(() {});
      },
    ).showDialog(context);
  }
}
