import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/costume_detail_page.dart';

class CostumeListPage extends StatefulWidget {
  const CostumeListPage({Key? key}) : super(key: key);

  @override
  _CostumeListPageState createState() => _CostumeListPageState();
}

class _CostumeListPageState
    extends SearchableListState<Costume, CostumeListPage> {
  Query __textFilter = Query();

  bool useGrid = false;

  @override
  Widget build(BuildContext context) {
    filterShownList(
      data: db.gameData.costumes.values,
      compare: (a, b) => a.no.compareTo(b.no),
    );
    return scrollListener(
      useGrid: useGrid,
      appBar: AppBar(
        leading: MasterBackButton(),
        title: Text(S.current.costume),
        bottom: showSearchBar ? searchBar : null,
        actions: [
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

  Map<Costume, String> searchMap = {};

  @override
  bool filter(String keyword, Costume costume) {
    __textFilter.parse(keyword);
    if (keyword.isNotEmpty && searchMap[costume] == null) {
      final svt = db.gameData.servants[costume.svtNo];
      List<String> searchStrings = [
        costume.no.toString(),
        ...Utils.getSearchAlphabets(
            costume.name, costume.nameJp, costume.nameEn),
        if (svt != null) ...[
          ...Utils.getSearchAlphabets(
              svt.info.name, svt.info.nameJp, svt.info.nameEn),
          ...Utils.getSearchAlphabetsForList(svt.info.namesOther,
              svt.info.namesJpOther, svt.info.namesEnOther),
          ...Utils.getSearchAlphabetsForList(svt.info.nicknames),
        ]
      ];
      searchMap[costume] = searchStrings.toSet().join('\t');
    }
    if (keyword.isNotEmpty) {
      if (!__textFilter.match(searchMap[costume]!)) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget gridItemBuilder(Costume costume) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: ImageWithText(
        image: db.getIconImage(costume.icon, aspectRatio: 132 / 144),
        onTap: () {
          SplitRoute.push(
            context: context,
            builder: (context, _) => CostumeDetailPage(costume: costume),
          );
        },
      ),
    );
  }

  @override
  Widget listItemBuilder(Costume costume) {
    return ListTile(
      leading: db.getIconImage(
        costume.icon,
        aspectRatio: 132 / 144,
        // padding: EdgeInsets.symmetric(vertical: 0),
      ),
      title: Text(costume.lName),
      subtitle: Text(
          'No.${costume.no} / ${db.gameData.servants[costume.svtNo]?.info.localizedName}'),
      onTap: () {
        SplitRoute.push(
          context: context,
          builder: (context, _) => CostumeDetailPage(costume: costume),
        );
      },
    );
  }
}
