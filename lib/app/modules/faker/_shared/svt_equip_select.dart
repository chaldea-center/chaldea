import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/app/modules/craft_essence/filter.dart';
import 'package:chaldea/app/modules/faker/state.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/widgets/widgets.dart';

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
      if (inUseUserSvtIds != null && inUseUserSvtIds.contains(userSvt.id)) '⚠️ ',
      'Lv${userSvt.lv}/${userSvt.maxLv} ',
      ' ${userSvt.limitCount}/4 ${userSvt.limitCount == 4 ? kStarChar2 : ""} ',
    ].join('\n');
  }

  @override
  State<SelectUserSvtEquipPage> createState() => _SelectUserSvtEquipPageState();
}

class _SelectUserSvtEquipPageState extends State<SelectUserSvtEquipPage> {
  late final runtime = widget.runtime;
  late final mstData = runtime.mstData;

  static CraftFilterData filterData = CraftFilterData();
  static _UserSvtFilterData userSvtFilterData = _UserSvtFilterData();

  bool filter(UserServantEntity userSvt) {
    final equip = db.gameData.craftEssencesById[userSvt.svtId];
    if (equip == null || equip.collectionNo <= 0) return false;
    if (!userSvtFilterData.locked.matchOne(userSvt.isLocked())) return false;
    if (!userSvtFilterData.maxLimitBreak.matchOne(userSvt.limitCount == 4)) return false;
    if (!CraftFilterPage.filter(filterData, equip)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final userSvts = mstData.userSvt.where(filter).toList();
    userSvts.sort(
      (a, b) => CraftFilterData.compare(
        db.gameData.craftEssencesById[a.svtId],
        db.gameData.craftEssencesById[b.svtId],
        keys: filterData.sortKeys,
        reversed: filterData.sortReversed,
      ),
    );
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
                    showMatchAll: true,
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
      body: GridView.builder(
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
              option: ImageWithTextOption(padding: EdgeInsets.fromLTRB(4, 0, 4, 2)),
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
    );
  }
}

class _UserSvtFilterData with FilterDataMixin {
  final maxLimitBreak = FilterGroupData<bool>();
  final locked = FilterGroupData<bool>(options: {true});
  @override
  List<FilterGroupData> get groups => [maxLimitBreak, locked];
}
