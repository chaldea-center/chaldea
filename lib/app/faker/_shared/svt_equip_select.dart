import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/app/modules/craft_essence/filter.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../runtime.dart';

class SelectUserSvtEquipPage extends StatefulWidget {
  final FakerRuntime runtime;
  final String? Function(UserServantEntity userSvt, MasterDataManager mstData, List<int>? inUseUserSvtIds)? getStatus;
  final List<int>? inUseUserSvtIds;
  final ValueChanged<UserServantEntity>? onSelected;

  const SelectUserSvtEquipPage({
    super.key,
    required this.runtime,
    this.getStatus = defaultGetStatus,
    this.inUseUserSvtIds,
    this.onSelected,
  });

  static String defaultGetStatus(UserServantEntity userSvt, MasterDataManager mstData, List<int>? inUseUserSvtIds) {
    return [
      [
        if (inUseUserSvtIds != null && inUseUserSvtIds.contains(userSvt.id)) '🟢 ',
        if (userSvt.isChoice()) '✴️ ', // ⭐ 🌟
        if (userSvt.isLocked()) '🔐 ',
      ].join(''),
      'Lv${userSvt.lv}/${userSvt.maxLv} ',
      ' ${userSvt.limitCount}/4 ${userSvt.limitCount == 4 ? kStarChar2 : ""} ',
    ].map((e) => e.padLeft(9)).join('\n');
  }

  @override
  State<SelectUserSvtEquipPage> createState() => _SelectUserSvtEquipPageState();
}

class _SelectUserSvtEquipPageState extends State<SelectUserSvtEquipPage> {
  late final runtime = widget.runtime;
  late final mstData = runtime.mstData;

  static CraftFilterData filterData = CraftFilterData(sortKeys: CraftCompare.kRarityFirstKeys);
  static _UserSvtFilterData userSvtFilterData = _UserSvtFilterData();

  Map<int, ({Event event, Set<int> ceIds})> eventCeIds = {};

  @override
  void initState() {
    super.initState();

    final now = DateTime.now().timestamp;
    for (final event in runtime.gameData.timerData.events.values) {
      if (event.startedAt > now || event.endedAt <= now) continue;
      final ceIds = <int>{
        if (event.type == EventType.eventQuest)
          for (final ce in db.gameData.craftEssencesById.values)
            if (ce.eventSkills(event.id).isNotEmpty) ce.id,
      };
      if (ceIds.isNotEmpty) {
        eventCeIds[event.id] = (event: event, ceIds: ceIds);
      }
    }
  }

  bool filter(UserServantEntity userSvt) {
    final equip = db.gameData.craftEssencesById[userSvt.svtId];
    if (equip == null || equip.collectionNo <= 0) return false;
    if (!userSvtFilterData.locked.matchOne(userSvt.isLocked())) return false;
    if (!userSvtFilterData.maxLimitBreak.matchOne(userSvt.limitCount == 4)) return false;
    if (eventCeIds[userSvtFilterData.eventId]?.ceIds.contains(userSvt.svtId) == false) return false;
    if (!CraftFilterPage.filter(filterData, equip, status: mstData.getSvtEquipStatus(userSvt))) return false;
    return true;
  }

  int compareUserSvt(UserServantEntity a, UserServantEntity b) {
    final r = ListX.compareByList(
      a,
      b,
      (v) => <int>[widget.inUseUserSvtIds?.contains(v.id) == true ? 0 : 1, v.isChoice() ? 0 : 1],
    );
    if (r != 0) return r;
    return CraftFilterData.compare(
      db.gameData.craftEssencesById[a.svtId],
      db.gameData.craftEssencesById[b.svtId],
      keys: filterData.sortKeys,
      reversed: filterData.sortReversed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userSvts = mstData.userSvt.where(filter).toList();
    userSvts.sort(compareUserSvt);
    return Scaffold(
      appBar: AppBar(
        title: Text('Select User CE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => CraftFilterPage(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) {
                    setState(() {});
                  }
                },
                customFilters: (_, update) => [
                  FilterGroup<bool>(
                    title: Text('Lock status'),
                    options: const [false, true],
                    values: userSvtFilterData.locked,
                    optionBuilder: (v) => Text(v ? '🔐 Locked' : 'Unlocked'),
                    onFilterChanged: (value, _) {
                      if (mounted) setState(() {});
                      update();
                    },
                  ),
                  FilterGroup<bool>(
                    title: Text(S.current.max_limit_break),
                    showMatchAll: true,
                    options: const [false, true],
                    values: userSvtFilterData.maxLimitBreak,
                    optionBuilder: (v) => Text(v ? 'YES' : 'NO'),
                    onFilterChanged: (value, _) {
                      if (mounted) setState(() {});
                      update();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 64,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 132 / 144,
              ),
              itemBuilder: (context, index) {
                final userSvt = userSvts[index];
                final ce = db.gameData.craftEssencesById[userSvt.svtId];
                final status = widget.getStatus?.call(userSvt, mstData, widget.inUseUserSvtIds);
                Widget child;
                if (ce == null) {
                  child = Text(['${userSvt.svtId}', if (status != null) status].join('\n'));
                } else {
                  child = ce.iconBuilder(
                    context: context,
                    text: status,
                    jumpToDetail: false,
                    option: ImageWithTextOption(padding: EdgeInsets.fromLTRB(4, 0, 4, 2), fontSize: 12),
                  );
                }
                child = GestureDetector(
                  child: child,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onSelected?.call(userSvt);
                  },
                  onLongPress: () {
                    router.push(url: Routes.craftEssenceI(userSvt.svtId));
                  },
                );
                return child;
              },
              itemCount: userSvts.length,
            ),
          ),
          if (eventCeIds.isNotEmpty) ...[kDefaultDivider, SafeArea(child: buttonBar)],
        ],
      ),
    );
  }

  Widget get buttonBar {
    final events = eventCeIds.values.toList();
    events.sortByList((e) => [e.event.startedAt, -e.event.id]);

    DropdownMenuItem<int?> buildItem(Event? event) {
      return DropdownMenuItem(
        value: event?.id ?? 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event?.lShortName.l ?? S.current.general_all,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaler: const TextScaler.linear(0.8),
            ),
            if (event != null)
              Text(
                [
                  event.startedAt,
                  event.endedAt,
                ].map((e) => e.sec2date().toCustomString(year: false, second: false)).join(' ~ '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      );
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<int?>(
        isExpanded: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        value: eventCeIds.containsKey(userSvtFilterData.eventId) ? userSvtFilterData.eventId : 0,
        items: [buildItem(null), for (final (ceIds: _, :event) in events) buildItem(event)],
        onChanged: (v) {
          if (v != null) userSvtFilterData.eventId = v;
          if (mounted) setState(() {});
        },
      ),
    );
  }
}

class _UserSvtFilterData with FilterDataMixin {
  final maxLimitBreak = FilterGroupData<bool>();
  final locked = FilterGroupData<bool>(options: {true});
  int eventId = 0;
  @override
  List<FilterGroupData> get groups => [maxLimitBreak, locked];

  @override
  void reset() {
    super.reset();
    eventId = 0;
  }
}
