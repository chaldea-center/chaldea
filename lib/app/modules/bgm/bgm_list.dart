import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/filter_page_base.dart';
import 'filter.dart';

class BgmListPage extends StatefulWidget {
  BgmListPage({super.key});

  @override
  _BgmListPageState createState() => _BgmListPageState();
}

class _BgmListPageState extends State<BgmListPage> with SearchableListState<BgmEntity, BgmListPage> {
  final filterData = BgmFilterData();
  final player = MyAudioPlayer<String>();

  @override
  Iterable<BgmEntity> get wholeData => db.gameData.bgms.values;

  @override
  bool get showOddBg => true;

  @override
  Widget build(BuildContext context) {
    filterShownList(
      compare: (a, b) {
        int r = ListX.compareByList<BgmEntity, int>(
          a,
          b,
          (v) => filterData.sortByPriority.radioValue! ? [v.priority, v.id] : [v.id, v.priority],
        );
        return r * (filterData.reversed ? -1 : 1);
      },
    );
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: Text(S.current.bgm),
        bottom: showSearchBar ? searchBar : null,
        actions: [
          IconButton(
            onPressed: () {
              Map<int, int> cost = {};
              for (final id in db.curUser.myRoomMusic) {
                final shop = db.gameData.bgms[id]?.shop;
                if (shop == null) continue;
                if (shop.cost != null && shop.cost!.itemId != 0) {
                  cost.addNum(shop.cost!.itemId, shop.cost!.amount);
                }
                for (final consume in shop.consumes) {
                  if (consume.type == CommonConsumeType.item) {
                    cost.addNum(consume.objectId, consume.num);
                  }
                }
              }
              showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) {
                  return SimpleConfirmDialog(
                    title: Text(S.current.statistics_title),
                    content: SharedBuilder.itemGrid(context: context, items: cost.entries, width: 40, sort: true),
                    showCancel: false,
                    scrollable: true,
                  );
                },
              );
            },
            icon: const Icon(Icons.analytics),
            tooltip: S.current.statistics_title,
          ),
          IconButton(
            icon: FaIcon(
              filterData.reversed ? FontAwesomeIcons.arrowDownWideShort : FontAwesomeIcons.arrowUpWideShort,
              size: 20,
            ),
            tooltip: S.current.sort_order,
            onPressed: () => setState(() => filterData.reversed = !filterData.reversed),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => BgmFilterPage(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),
          searchIcon,
        ],
      ),
    );
  }

  @override
  Iterable<String?> getSummary(BgmEntity bgm) sync* {
    yield bgm.id.toString();
    yield* SearchUtil.getAllKeys(bgm.lName);
    yield bgm.fileName;
  }

  @override
  bool filter(BgmEntity bgm) {
    if (!filterData.released.matchOne(!bgm.notReleased)) return false;
    if (!filterData.needItem.matchOne(bgm.shop != null)) return false;
    if (!filterData.favorite.matchOne(db.curUser.myRoomMusic.contains(bgm.id))) {
      return false;
    }
    return true;
  }

  @override
  Widget gridItemBuilder(BgmEntity bgm) {
    throw UnimplementedError('GridView not designed');
  }

  @override
  Widget listItemBuilder(BgmEntity bgm) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
            leading: db.getIconImage(bgm.logo, aspectRatio: 124 / 60, width: 56),
            horizontalTitleGap: 8,
            title: Text(bgm.lName.l, textScaler: const TextScaler.linear(1)),
            subtitle: Text('No.${bgm.id} ${bgm.fileName}', textScaler: const TextScaler.linear(1)),
            onTap: () {
              bgm.routeTo();
            },
          ),
        ),
        if (bgm.shop?.cost != null)
          Item.iconBuilder(context: context, item: bgm.shop!.cost!.item, text: bgm.shop!.cost!.amount.format()),
        if (bgm.shop != null)
          for (final consume in bgm.shop!.consumes)
            if (consume.type == CommonConsumeType.item)
              Item.iconBuilder(context: context, item: null, itemId: consume.objectId, text: consume.num.format()),
        if (bgm.shop != null)
          Checkbox(
            value: db.curUser.myRoomMusic.contains(bgm.id),
            onChanged: (v) {
              setState(() {
                db.curUser.myRoomMusic.toggle(bgm.id);
              });
            },
          ),
        SoundPlayButton(url: bgm.audioAsset, player: player),
        const SizedBox(width: 12),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    player.stop();
  }
}
