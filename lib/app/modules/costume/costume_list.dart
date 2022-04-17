import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'costume_detail.dart';

class CostumeListPage extends StatefulWidget {
  CostumeListPage({Key? key}) : super(key: key);

  @override
  _CostumeListPageState createState() => _CostumeListPageState();
}

class _CostumeListPageState extends State<CostumeListPage>
    with SearchableListState<NiceCostume, CostumeListPage> {
  bool reversed = false;

  @override
  Iterable<NiceCostume> get wholeData => [
        for (final svt in db2.gameData.servants.values)
          ...svt.profile.costume.values
      ];

  bool useGrid = false;

  @override
  Widget build(BuildContext context) {
    filterShownList(
      compare: (a, b) =>
          a.costumeCollectionNo.compareTo(b.costumeCollectionNo) *
          (reversed ? -1 : 1),
    );
    return scrollListener(
      useGrid: useGrid,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: AutoSizeText(
          S.current.costume,
          maxLines: 1,
          overflow: TextOverflow.fade,
        ),
        bottom: showSearchBar ? searchBar : null,
        actions: [
          IconButton(
            icon: FaIcon(
              reversed
                  ? FontAwesomeIcons.arrowDownWideShort
                  : FontAwesomeIcons.arrowUpWideShort,
              size: 20,
            ),
            tooltip: S.current.sort_order,
            onPressed: () => setState(() => reversed = !reversed),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                useGrid = !useGrid;
              });
            },
            icon: Icon(useGrid ? Icons.grid_on : Icons.view_list),
            tooltip: 'List/Grid',
          ),
          searchIcon,
        ],
      ),
    );
  }

  @override
  Iterable<String?> getSummary(NiceCostume costume) sync* {
    final svt = costume.owner;
    yield costume.costumeCollectionNo.toString();
    yield costume.battleCharaId.toString();
    yield* SearchUtil.getAllKeys(costume.lName);
    if (svt != null) {
      yield* SearchUtil.getAllKeys(svt.lName);
    }
  }

  @override
  bool filter(NiceCostume costume) => true;

  @override
  Widget gridItemBuilder(NiceCostume costume) {
    return ImageWithText(
      image: db2.getIconImage(costume.icon, aspectRatio: 132 / 144),
      onTap: () {
        router.push(url: costume.route);
      },
    );
  }

  @override
  Widget listItemBuilder(NiceCostume costume) {
    return ListTile(
      leading: db2.getIconImage(
        costume.icon,
        aspectRatio: 132 / 144,
        // padding: const EdgeInsets.symmetric(vertical: 0),
      ),
      title: Text(costume.lName.l),
      subtitle:
          Text('No.${costume.costumeCollectionNo} / ${costume.owner?.lName.l}'),
      onTap: () {
        router.push(child: CostumeDetailPage(costume: costume));
      },
    );
  }
}
