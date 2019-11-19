import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import 'craft_detail_page.dart';
import 'craft_filter_page.dart';

class CraftListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CraftListPageState();
}

class CraftListPageState extends State<CraftListPage> {
  CraftFilterData filterData;
  TextEditingController _inputController;
  ScrollController _scrollController;

  //temp, calculate once build() called.
  int __binCategory, __binAtkHpType;
  TextFilter __textFilter;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _scrollController = ScrollController();
    filterData = db.userData.craftFilter;
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void beforeFiltrate() {
    filterData.filterString = filterData.filterString.trim();
    __textFilter = TextFilter(filterData.filterString);
    __binCategory = 0;
    for (int i = 0; i < CraftFilterData.categoryData.length; i++) {
      if (filterData.category.options[CraftFilterData.categoryData[i]] ==
          true) {
        __binCategory += 1 << i;
      }
    }
    __binAtkHpType = 0;
    for (int i = 0; i < CraftFilterData.atkHpTypeData.length; i++) {
      if (filterData.atkHpType.options[CraftFilterData.atkHpTypeData[i]] ==
          true) {
        __binAtkHpType += 1 << i;
      }
    }
  }

  bool filtrateCraft(CraftEssential ce) {
    if (filterData.filterString.isNotEmpty) {
      String srcString = [
        ce.no,
        ce.name,
        ce.nameJp,
        ce.mcLink,
        ce.illustrator.join('\t'),
        ce.characters.join('\t'),
        ce.skill,
        ce.eventSkills.join('\t')
      ].join('\t');
      if (!__textFilter.match(srcString)) {
        return false;
      }
    }
    if (!filterData.rarity.singleValueFilter(ce.rarity.toString())) {
      return false;
    }
    if (__binCategory > 0 && ce.category & __binCategory == 0) {
      return false;
    }
    if (__binAtkHpType > 0 &&
        ((1 << ((ce.hpMax > 0 ? 1 : 0) + (ce.atkMax > 0 ? 2 : 0))) &
                __binAtkHpType) ==
            0) {
      return false;
    }
    return true;
  }

  void onFilterChanged(CraftFilterData data) {
    setState(() {
      filterData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).craft_essential),
        leading: SplitViewBackButton(),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.grey),
            child: Container(
                height: 45,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: TextField(
                  controller: _inputController,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      fillColor: Colors.white,
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search, size: 20),
                      suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _inputController.clear());
                            filterData.filterString = '';
                          });
                        },
                      )),
                  onChanged: (s) {
                    setState(() {
                      filterData.filterString = s;
                    });
                  },
                  onSubmitted: (s) {
                    FocusScope.of(context).unfocus();
                  },
                )),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => buildFilterSheet(context),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_upward),
          onPressed: () => _scrollController.jumpTo(0)),
      body: buildOverview(),
    );
  }

  Widget buildOverview() {
    List<CraftEssential> shownList = [];
    beforeFiltrate();
    db.gameData.crafts.forEach((no, ce) {
      if (filtrateCraft(ce)) {
        shownList.add(ce);
      }
    });
    //sort
    final _getSortValue = (CraftEssential ce, String key) {
      switch (key) {
        case '序号':
          return ce.no;
        case '星级':
          return ce.rarity;
        case 'ATK':
          return ce.atkMax;
        case 'HP':
          return ce.hpMax;
        default:
          return 0;
      }
    };

    shownList.sort((a, b) {
      int r = 0;
      for (var i = 0; i < filterData.sortKeys.length; i++) {
        final sortKey = filterData.sortKeys[i];
        r = r * 1000 +
            (_getSortValue(a, sortKey) - _getSortValue(b, sortKey)) *
                (filterData.sortDirections[i] ? 1000 : -1000);
      }
      return r;
    });
    return filterData.useGrid
        ? _buildGridView(shownList)
        : _buildListView(shownList);
  }

  Widget _buildListView(List<CraftEssential> shownList) {
    return ListView.separated(
        physics: ScrollPhysics(),
        controller: _scrollController,
        separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
        itemCount: shownList.length,
        itemBuilder: (context, index) {
          final ce = shownList[index];
          return CustomTile(
            leading: SizedBox(
              width: 132 * 0.45,
              height: 144 * 0.45,
              child: Image(image: db.getIconFile(ce.icon)),
            ),
            title: AutoSizeText(ce.name, maxLines: 1),
            subtitle: AutoSizeText('No.${ce.no}\n${ce.nameJp ?? ce.name}',
                maxLines: 2),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              SplitRoute.popAndPush(context,
                  builder: (context) => CraftDetailPage(ce: ce));
            },
          );
        });
  }

  Widget _buildGridView(List<CraftEssential> shownList) {
    return GridView.count(
        crossAxisCount: 5,
        childAspectRatio: 1,
        controller: _scrollController,
        children: shownList.map((ce) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1),
              child: ImageWithText(
                image: Image(image: db.getIconFile(ce.icon)),
                alignment: AlignmentDirectional.bottomStart,
                onTap: () {
                  SplitRoute.popAndPush(context,
                      builder: (context) => CraftDetailPage(ce: ce));
                },
              ),
            ),
          );
        }).toList());
  }

  void buildFilterSheet(BuildContext context) {
    showSheet(
      context,
      builder: (sheetContext, setSheetState) =>
          CraftFilterPage(parent: this, filterData: filterData),
    );
  }
}
