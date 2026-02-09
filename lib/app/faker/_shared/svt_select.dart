import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/app/routes/delegate.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../modules/servant/filter.dart';
import '../runtime.dart';

class SelectUserSvtPage extends StatefulWidget {
  final FakerRuntime runtime;
  final String? Function(UserServantEntity userSvt, MasterDataManager mstData, List<int>? inUseUserSvtIds)? getStatus;
  final List<int>? inUseUserSvtIds;
  final ValueChanged<UserServantEntity>? onSelected;

  const SelectUserSvtPage({
    super.key,
    required this.runtime,
    this.getStatus = defaultGetStatus,
    this.inUseUserSvtIds,
    this.onSelected,
  });

  static String defaultGetStatus(UserServantEntity userSvt, MasterDataManager mstData, List<int>? inUseUserSvtIds) {
    final collection = mstData.userSvtCollection[userSvt.svtId];
    return [
      [
        if (inUseUserSvtIds != null && inUseUserSvtIds.contains(userSvt.id)) '🟢 ',
        if (userSvt.isChoice()) '✴️ ', // ⭐ 🌟
        // if(userSvt.isLocked()) '🔐 ',
      ].join(''),
      ' NP${userSvt.treasureDeviceLv1} B${collection?.friendshipRank ?? ""}/${collection?.maxFriendshipRank ?? ""} ',
      ' Lv${userSvt.lv}/${userSvt.maxLv}  ${userSvt.limitCount}',
      ' ${userSvt.skillLv1}/${userSvt.skillLv2}/${userSvt.skillLv3} ',
      ' ${mstData.getSvtAppendSkillLvs(userSvt).map((e) => e == 0 ? "-" : e).join("/")} ',
    ].join('\n');
  }

  @override
  State<SelectUserSvtPage> createState() => _SelectUserSvtPageState();
}

class _SelectUserSvtPageState extends State<SelectUserSvtPage> {
  late final runtime = widget.runtime;
  late final mstData = runtime.mstData;

  static final _svtFilters = RouterValues<SvtFilterData>(
    () => SvtFilterData(sortKeys: [SvtCompare.bondLv, ...SvtCompare.kRarityFirstKeys], sortReversed: [false]),
  );
  static final _userSvtFilters = RouterValues(() => _UserSvtFilterData());

  late final SvtFilterData filterData = _svtFilters.of(context);
  late final _UserSvtFilterData userSvtFilterData = _userSvtFilters.of(context);

  Map<int, ({Event event, Set<int> svtIds})> eventSvtIds = {};

  @override
  void initState() {
    super.initState();
    const useSvtIdCampaignTypes = {
      CombineAdjustTarget.largeSuccess: 87,
      CombineAdjustTarget.superSuccess: 87,
      // CombineAdjustTarget.questFp: 47,
      CombineAdjustTarget.combineExp: 79,
      CombineAdjustTarget.questFriendship: 28,
      // CombineAdjustTarget.exchangeSvt: 2,
    };
    final now = DateTime.now().timestamp;
    for (final event in runtime.gameData.timerData.events.values) {
      if (event.startedAt > now || event.endedAt <= now) continue;
      // skip if ended in 1y+?
      final svtIds = <int>{
        if (event.type == EventType.eventQuest)
          for (final svt in db.gameData.servantsNoDup.values)
            if (svt.eventSkills(eventId: event.id, includeZero: false).isNotEmpty) svt.id,
        for (final campaign in event.campaigns)
          if (useSvtIdCampaignTypes.containsKey(campaign.target)) ...campaign.targetIds,
      };
      if (svtIds.isNotEmpty) {
        eventSvtIds[event.id] = (event: event, svtIds: svtIds);
      }
    }
  }

  List<UserServantEntity> getShownUserSvts() {
    final userData = User();
    SvtStatus getSvtStatus(UserServantEntity userSvt) {
      final collectionNo = userSvt.dbSvt?.collectionNo ?? 0;
      if (collectionNo == 0) return mstData.getSvtStatus(userSvt);
      return userData.servants[collectionNo] ??= mstData.getSvtStatus(userSvt);
    }

    bool filter(UserServantEntity userSvt) {
      final svt = db.gameData.servantsById[userSvt.svtId];
      if (svt == null || svt.collectionNo <= 0) return false;
      if (!userSvt.isLocked()) return false;
      if (eventSvtIds[userSvtFilterData.eventId]?.svtIds.contains(userSvt.svtId) == false) return false;
      final coinNum = mstData.userSvtCoin[userSvt.svtId]?.num ?? 0;
      final combineTypes = userSvtFilterData.availableCombines.options.where((combineType) {
        switch (combineType) {
          case _CombineType.level:
            return userSvt.lv < (userSvt.maxLv ?? svt.lvMax);
          case _CombineType.fou3:
            return userSvt.adjustAtk < 100 || userSvt.adjustHp < 100;
          case _CombineType.ascension:
            return userSvt.limitCount < Maths.max<int>(svt.limits.keys, 0);
          case _CombineType.grail:
            return userSvt.lv >= 100 && userSvt.lv < 120 && coinNum >= 30;
          case _CombineType.skill:
            return userSvt.skillLvs.any((e) => e < 9);
          case _CombineType.append2:
            final appendLv = mstData.getSvtAppendSkillLvs(userSvt)[1];
            return appendLv == 0 && coinNum >= 120 || (appendLv > 0 && appendLv < 9);
          case _CombineType.appendAny:
            return mstData
                .getSvtAppendSkillLvs(userSvt)
                .any((appendLv) => appendLv == 0 && coinNum >= 120 || (appendLv > 0 && appendLv < 9));
          case _CombineType.bondLimit:
            final collection = mstData.userSvtCollection[userSvt.svtId];
            return collection != null &&
                collection.friendshipRank < 15 &&
                collection.friendshipRank == collection.maxFriendshipRank;
          case _CombineType.bondLessThan10:
            final collection = mstData.userSvtCollection[userSvt.svtId];
            return collection != null && collection.friendshipRank < 10;
          case _CombineType.ccUnlock:
            return mstData.userSvtCommandCard[userSvt.svtId]?.commandCardParam.any((e) => e == -1) ?? true;
        }
      }).toList();
      if (!userSvtFilterData.availableCombines.matchAny(combineTypes)) return false;

      if (!ServantFilterPage.filter(filterData, svt, svtStat: getSvtStatus(userSvt))) return false;

      return true;
    }

    int compareUserSvt(UserServantEntity a, UserServantEntity b) {
      final r = ListX.compareByList(
        a,
        b,
        (v) => <int>[widget.inUseUserSvtIds?.contains(v.id) == true ? 0 : 1, v.isChoice() ? 0 : 1],
      );
      if (r != 0) return r;
      return SvtFilterData.compareId(
        a.svtId,
        b.svtId,
        keys: filterData.sortKeys,
        reversed: filterData.sortReversed,
        user: userData,
      );
    }

    final userSvts = mstData.userSvt.where(filter).toList();
    userSvts.sort(compareUserSvt);
    return userSvts;
  }

  @override
  Widget build(BuildContext context) {
    final userSvts = getShownUserSvts();
    return Scaffold(
      appBar: AppBar(
        title: Text('Select User Svt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => ServantFilterPage(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) {
                    setState(() {});
                  }
                },
                planMode: false,
                customFilters: (_, update) => [
                  FilterGroup<_CombineType>(
                    title: Text('Available Combine Type'),
                    showMatchAll: true,
                    showInvert: true,
                    options: _CombineType.values,
                    values: userSvtFilterData.availableCombines,
                    optionBuilder: (v) => Text(switch (v) {
                      _CombineType.bondLessThan10 => 'bond<10',
                      _ => v.name,
                    }),
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
                final svt = db.gameData.servantsById[userSvt.svtId];
                final status = widget.getStatus?.call(userSvt, mstData, widget.inUseUserSvtIds);
                Widget child;
                if (svt == null) {
                  child = Text(['${userSvt.svtId}', ?status].join('\n'));
                } else {
                  child = svt.iconBuilder(
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
                    router.push(url: Routes.servantI(userSvt.svtId));
                  },
                );
                return child;
              },
              itemCount: userSvts.length,
            ),
          ),
          if (eventSvtIds.isNotEmpty) ...[kDefaultDivider, SafeArea(child: buttonBar)],
        ],
      ),
    );
  }

  Widget get buttonBar {
    final events = eventSvtIds.values.toList();
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
        value: eventSvtIds.containsKey(userSvtFilterData.eventId) ? userSvtFilterData.eventId : 0,
        items: [buildItem(null), for (final (svtIds: _, :event) in events) buildItem(event)],
        onChanged: (v) {
          if (v != null) userSvtFilterData.eventId = v;
          if (mounted) setState(() {});
        },
      ),
    );
  }
}

class _UserSvtFilterData with FilterDataMixin {
  final availableCombines = FilterGroupData<_CombineType>();
  int eventId = 0;
  @override
  List<FilterGroupData> get groups => [availableCombines];

  @override
  void reset() {
    super.reset();
    eventId = 0;
  }
}

enum _CombineType { level, fou3, ascension, grail, skill, append2, appendAny, bondLimit, bondLessThan10, ccUnlock }
