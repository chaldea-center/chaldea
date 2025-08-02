import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/app/modules/faker/state.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../servant/filter.dart';

class SelectUserSvtPage extends StatefulWidget {
  final FakerRuntime runtime;
  final String? Function(UserServantEntity userSvt)? getStatus;
  final ValueChanged<UserServantEntity>? onSelected;

  const SelectUserSvtPage({super.key, required this.runtime, this.getStatus, this.onSelected});

  @override
  State<SelectUserSvtPage> createState() => _SelectUserSvtPageState();
}

class _SelectUserSvtPageState extends State<SelectUserSvtPage> {
  late final runtime = widget.runtime;
  late final mstData = runtime.mstData;

  static SvtFilterData filterData = SvtFilterData();
  static _UserSvtFilterData userSvtFilterData = _UserSvtFilterData();

  bool filter(UserServantEntity userSvt) {
    final svt = db.gameData.servantsById[userSvt.svtId];
    if (svt == null || svt.collectionNo <= 0) return false;
    if (!userSvt.locked) return false;
    if (!ServantFilterPage.filter(filterData, svt)) return false;
    final coinNum = mstData.userSvtCoin[userSvt.svtId]?.num ?? 0;
    final combineTypes = userSvtFilterData.availableCombines.options.where((combineType) {
      switch (combineType) {
        case _CombineType.level:
          return userSvt.lv < (userSvt.maxLv ?? svt.lvMax);
        case _CombineType.ascension:
          return userSvt.limitCount < Maths.max<int>(svt.limits.keys, 0);
        case _CombineType.grail:
          return userSvt.lv >= 100 && userSvt.lv < 120 && coinNum >= 30;
        case _CombineType.bondLimit:
          final collection = mstData.userSvtCollection[userSvt.svtId];
          return collection != null &&
              collection.friendshipRank < 15 &&
              collection.friendshipRank == collection.maxFriendshipRank;
        case _CombineType.skill:
          return userSvt.skillLvs.any((e) => e < 9);
        case _CombineType.append2:
          final appendLv = mstData.getSvtAppendSkillLv(userSvt)[1];
          return appendLv == 0 && coinNum >= 120 || (appendLv > 0 && appendLv < 9);
        case _CombineType.appendAny:
          return mstData
              .getSvtAppendSkillLv(userSvt)
              .any((appendLv) => appendLv == 0 && coinNum >= 120 || (appendLv > 0 && appendLv < 9));
      }
    }).toList();
    if (!userSvtFilterData.availableCombines.matchAny(combineTypes)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final userSvts = mstData.userSvt.where(filter).toList();
    userSvts.sort(
      (a, b) => SvtFilterData.compareId(a.svtId, b.svtId, keys: filterData.sortKeys, reversed: filterData.sortReversed),
    );
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
                    options: _CombineType.values,
                    values: userSvtFilterData.availableCombines,
                    optionBuilder: (v) => Text(v.name),
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
          final svt = db.gameData.servantsById[userSvt.svtId];
          final status = widget.getStatus?.call(userSvt);
          Widget child;
          if (svt == null) {
            child = Text(['${userSvt.svtId}', if (status != null) status].join('\n'));
          } else {
            child = svt.iconBuilder(
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
              router.push(url: Routes.servantI(userSvt.svtId));
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
  final availableCombines = FilterGroupData<_CombineType>();
  @override
  List<FilterGroupData> get groups => [availableCombines];
}

enum _CombineType { level, ascension, grail, bondLimit, skill, append2, appendAny }
