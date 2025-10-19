import 'package:flutter/gestures.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/mission_conds.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/master_mission/master_mission.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../state.dart';

class UserEventMissionReceivePage extends StatefulWidget {
  final FakerRuntime runtime;
  final int? initId;
  const UserEventMissionReceivePage({super.key, required this.runtime, this.initId});

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
      if (mm.id == widget.initId) return true;
      if (const [MissionType.event, MissionType.random].contains(mm.type)) return false;
      if (mm.startedAt > now || mm.closedAt < now) return false;
      if (mm.type == MissionType.daily) {
        if (mm.endedAt < now - kSecsPerDay * 40) return false;
      }
      return true;
    });

    for (final event in runtime.gameData.timerData.events) {
      if (!(event.startedAt <= now && event.endedAt > now && event.missions.isNotEmpty)) continue;
      List<EventMission> eventMissions = [], randomMissions = [];
      for (final mission in event.missions) {
        if (mission.type == MissionType.random) {
          if (runtime.mstData.userEventRandomMission[mission.id]?.isInProgress == true) {
            randomMissions.add(mission);
          }
        } else {
          eventMissions.add(mission);
        }
      }
      if (eventMissions.isNotEmpty) {
        mms.add(
          MasterMission(
            id: event.id,
            startedAt: event.startedAt,
            endedAt: event.endedAt,
            closedAt: event.endedAt,
            missions: eventMissions,
            script: {MstMasterMission.kMissionIconDetailText: event.lShortName.l.setMaxLines(1)},
          ),
        );
      }
      if (randomMissions.isNotEmpty) {
        mms.add(
          MasterMission(
            id: event.id * 100 + 1,
            startedAt: event.startedAt,
            endedAt: event.endedAt,
            closedAt: event.endedAt,
            missions: randomMissions,
            script: {
              MstMasterMission.kMissionIconDetailText:
                  '[${S.current.random_mission}] ${event.lShortName.l.setMaxLines(1)}',
            },
          ),
        );
      }
    }

    // mms.removeWhere((mm) => mm.type == MissionType.daily && mm.endedAt - mm.startedAt > kSecsPerDay * 40);
    mms.sortByList((e) => [e.endedAt, e.closedAt, e.id]);
    if (mms.isNotEmpty) {
      MasterMission? mm;
      if (widget.initId != null) {
        mm = mms.firstWhereOrNull((e) => e.id == widget.initId);
      }
      mm ??= mms.firstWhere(
        (mm) => mm.missions.any((e) => getMissionProgress(e.id) != MissionProgressType.achieve),
        orElse: () => mms.first,
      );
      onSelectMM(mm);
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
    final missions = (_mm?.missions ?? const []).where((mission) {
      final gifts = mission.gifts.map((e) => e.objectId).toSet();
      if (havingGifts.isNotEmpty && !havingGifts.matchAny(gifts)) return false;
      if (notHavingGifts.isNotEmpty && notHavingGifts.matchAny(gifts)) return false;
      if (!progressFilter.matchOne(getMissionProgress(mission.id))) return false;
      return true;
    }).toList();
    missions.sort2((e) => e.dispNo);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.master_mission),
        actions: [
          if (_mm != null)
            IconButton(
              onPressed: () {
                router.push(
                  url: Routes.masterMissionI(_mm!.id),
                  child: MasterMissionPage(masterMission: _mm, region: runtime.region),
                );
              },
              icon: Icon(Icons.info_outline),
            ),
          runtime.buildHistoryButton(context),
          runtime.buildMenuButton(context),
        ],
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
                  return buildEventMission(missions[index], missions);
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
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textScaler: const TextScaler.linear(0.9),
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

  Widget buildEventMission(EventMission mission, List<EventMission> missions) {
    Widget title = Text.rich(
      TextSpan(
        text: '${mission.dispNo}. ${mission.name}',
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            SimpleConfirmDialog(
              title: Text('No.${mission.dispNo} (${mission.id})'),
              scrollable: true,
              showCancel: false,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mission.name, style: Theme.of(context).textTheme.bodySmall),
                  const Divider(),
                  MissionCondsDescriptor(mission: mission, missions: missions),
                ],
              ),
            ).showDialog(context);
          },
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    Widget subtitle = Wrap(
      spacing: 1,
      runSpacing: 1,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [for (final gift in mission.gifts) gift.iconBuilder(context: context, width: 32)],
    );
    // random mission not checked
    final progressType = getMissionProgress(mission.id);

    Widget trailing;
    if (progressType == MissionProgressType.clear) {
      trailing = Checkbox(
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        value: selectedMissions.contains(mission.id),
        onChanged: (v) {
          setState(() {
            if (v!) {
              selectedMissions.add(mission.id);
            } else {
              selectedMissions.remove(mission.id);
            }
          });
        },
      );
    } else {
      int? progressNum, targetNum;
      final eventMissionFix = runtime.mstData.userEventMissionFix[mission.id];
      if (eventMissionFix != null) {
        // progressType=eventMissionFix.progressType;
        progressNum = eventMissionFix.num;
      }
      for (final cond in mission.conds) {
        if (cond.missionProgressType != MissionProgressType.clear) continue;
        if (cond.condType == CondType.missionConditionDetail) {
          final condDetailId = cond.targetIds.firstOrNull;
          if (condDetailId == null) continue;
          progressNum ??= runtime.mstData.userEventMissionCondDetail[condDetailId]?.progressNum;
        } else if (cond.condType == CondType.eventMissionClear) {
          progressNum ??= cond.targetIds.where((mid) {
            final progressType = runtime.mstData.userEventMission[mid]?.missionProgressType;
            return progressType == MissionProgressType.clear.value || progressType == MissionProgressType.achieve.value;
          }).length;
        } else if (cond.condType == CondType.eventMissionAchieve) {
          progressNum ??= cond.targetIds.where((mid) {
            final progressType = runtime.mstData.userEventMission[mid]?.missionProgressType;
            return progressType == MissionProgressType.achieve.value;
          }).length;
        } else if (cond.condType == CondType.questClear) {
          progressNum ??= cond.targetIds.where((questId) {
            return (runtime.mstData.userQuest[questId]?.clearNum ?? 0) > 0;
          }).length;
        } else {
          // don't set targetNum
          continue;
        }
        targetNum = cond.targetNum;
      }

      trailing = Text(
        [
          progressType.name,
          if (progressNum != null || targetNum != null) '${progressNum ?? "?"}/${targetNum ?? "?"}',
        ].join('\n'),
        textAlign: TextAlign.end,
      );
    }
    return ListTileTheme.merge(
      key: ObjectKey(mission),
      dense: true,
      minLeadingWidth: 16,
      child: ListTile(
        title: title,
        subtitle: subtitle,
        enabled: progressType == MissionProgressType.clear || progressType == MissionProgressType.achieve,
        trailing: trailing,
        onTap: () {
          setState(() {
            selectedMissions.toggle(mission.id);
          });
        },
      ),
    );
  }

  Widget buildButtonBar() {
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
        FilterGroup<MissionProgressType>(
          options: const [MissionProgressType.none, MissionProgressType.clear, MissionProgressType.achieve],
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
