import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

class _BgmListPageState extends State<BgmListPage>
    with SearchableListState<BgmEntity, BgmListPage> {
  final filterData = BgmFilterData();
  final player = MyAudioPlayer<String>();

  @override
  Iterable<BgmEntity> get wholeData => db.gameData.bgms.values;

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: (a, b) {
      int r = ListX.compareByList<BgmEntity, int>(
          a,
          b,
          (v) => filterData.sortByPriority.radioValue!
              ? [v.priority, v.id]
              : [v.id, v.priority]);
      return r * (filterData.reversed ? -1 : 1);
    });
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: const Text('BGM'),
        bottom: showSearchBar ? searchBar : null,
        actions: [
          IconButton(
            icon: FaIcon(
              filterData.reversed
                  ? FontAwesomeIcons.arrowDownWideShort
                  : FontAwesomeIcons.arrowUpWideShort,
              size: 20,
            ),
            tooltip: S.current.sort_order,
            onPressed: () =>
                setState(() => filterData.reversed = !filterData.reversed),
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
    return true;
  }

  @override
  Widget gridItemBuilder(BgmEntity bgm) {
    throw UnimplementedError('GridView not designed');
  }

  @override
  Widget listItemBuilder(BgmEntity bgm) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsetsDirectional.fromSTEB(4, 0, 16, 0),
      leading: db.getIconImage(
        bgm.logo,
        aspectRatio: 124 / 60,
      ),
      trailing: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (bgm.shop != null)
            Item.iconBuilder(
              context: context,
              item: bgm.shop!.cost.item,
              text: bgm.shop!.cost.amount.format(),
            ),
          SoundPlayButton(url: bgm.audioAsset, player: player)
        ],
      ),
      horizontalTitleGap: 8,
      title: Text(bgm.lName.l, textScaleFactor: 1),
      subtitle: Text('No.${bgm.id} ${bgm.fileName}', textScaleFactor: 1),
      onTap: () {
        bgm.routeTo();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    player.stop();
  }
}
