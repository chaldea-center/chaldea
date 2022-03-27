import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/costume_detail_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CostumeListPage extends StatefulWidget {
  CostumeListPage({Key? key}) : super(key: key);

  @override
  _CostumeListPageState createState() => _CostumeListPageState();
}

class _CostumeListPageState extends State<CostumeListPage>
    with SearchableListState<Costume, CostumeListPage> {
  bool reversed = false;

  @override
  Iterable<Costume> get wholeData => db.gameData.costumes.values;

  bool useGrid = false;

  @override
  Widget build(BuildContext context) {
    filterShownList(
      compare: (a, b) => a.no.compareTo(b.no) * (reversed ? -1 : 1),
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
            tooltip: 'Reversed',
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
  String getSummary(Costume costume) {
    final svt = db.gameData.servants[costume.svtNo];
    List<String> searchStrings = [
      costume.no.toString(),
      ...Utils.getSearchAlphabets(costume.name, costume.nameJp, costume.nameEn),
      if (svt != null) ...[
        ...Utils.getSearchAlphabets(
            svt.info.name, svt.info.nameJp, svt.info.nameEn),
        ...Utils.getSearchAlphabetsForList(
            svt.info.namesOther, svt.info.namesJpOther, svt.info.namesEnOther),
        ...Utils.getSearchAlphabetsForList(svt.info.nicknames),
      ]
    ];
    return searchStrings.toSet().join('\t');
  }

  @override
  bool filter(Costume costume) => true;

  @override
  Widget gridItemBuilder(Costume costume) {
    return ImageWithText(
      image: db.getIconImage(costume.icon, aspectRatio: 132 / 144),
      onTap: () {
        SplitRoute.push(context, CostumeDetailPage(costume: costume));
      },
    );
  }

  @override
  Widget listItemBuilder(Costume costume) {
    return ListTile(
      leading: db.getIconImage(
        costume.icon,
        aspectRatio: 132 / 144,
        // padding: const EdgeInsets.symmetric(vertical: 0),
      ),
      title: Text(costume.lName),
      subtitle: Text(
          'No.${costume.no} / ${db.gameData.servants[costume.svtNo]?.info.localizedName}'),
      onTap: () {
        SplitRoute.push(context, CostumeDetailPage(costume: costume),
            popDetail: true);
      },
    );
  }
}
