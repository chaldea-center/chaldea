import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

import 'craft_detail_page.dart';
import 'craft_filter_page.dart';

class CraftListPage extends StatefulWidget {
  CraftListPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CraftListPageState();
}

class CraftListPageState extends State<CraftListPage>
    with DefaultScrollBarMixin {
  CraftFilterData filterData;
  List<CraftEssence> shownList = [];
  TextEditingController _inputController = TextEditingController();
  FocusNode _inputFocusNode = FocusNode();
  ScrollController _scrollController;

  //temp, calculate once build() called.
  int __binAtkHpType;
  Query __textFilter = Query();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    filterData = db.userData.craftFilter;
    filterData.filterString = '';
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void beforeFiltrate() {
    filterData.filterString = filterData.filterString.trim();
    __textFilter.parse(filterData.filterString);

    __binAtkHpType = 0;
    for (int i = 0; i < CraftFilterData.atkHpTypeData.length; i++) {
      if (filterData.atkHpType.options[CraftFilterData.atkHpTypeData[i]] ==
          true) {
        __binAtkHpType += 1 << i;
      }
    }
  }

  bool filtrateCraft(CraftEssence ce) {
    if (filterData.filterString.isNotEmpty) {
      List<String> searchStrings = [
        ce.no.toString(),
        ce.name,
        ce.nameJp,
        ce.mcLink,
        ...ce.illustrators,
        ...ce.characters,
        ce.skill,
        ce.skillMax,
        ...ce.eventSkills,
        ...ce.characters
      ];
      if (!__textFilter.match(searchStrings.join('\t'))) {
        return false;
      }
    }
    if (!filterData.rarity.singleValueFilter(ce.rarity.toString())) {
      return false;
    }

    if (!filterData.category
        .singleValueFilter(ce.category, compare: (o, v) => v.contains(o))) {
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

  bool onFilterChanged(CraftFilterData data) {
    if (mounted) {
      setState(() {
        filterData = data;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).craft_essence),
        leading: MasterBackButton(),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.grey),
            child: Container(
                height: 45,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: TextField(
                  focusNode: _inputFocusNode,
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
            icon: Icon(Icons.filter_alt),
            tooltip: S.of(context).filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => CraftFilterPage(
                  filterData: filterData, onChanged: onFilterChanged),
            ),
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
    shownList.clear();
    beforeFiltrate();
    db.gameData.crafts.forEach((no, ce) {
      if (filtrateCraft(ce)) {
        shownList.add(ce);
      }
    });
    shownList.sort((a, b) => CraftEssence.compare(
        a, b, filterData.sortKeys, filterData.sortReversed));

    return wrapDefaultScrollBar(
      controller: _scrollController,
      child: filterData.useGrid ? _buildGridView() : _buildListView(),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
        controller: _scrollController,
        separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
        itemCount: shownList.length + (shownList.isEmpty ? 1 : 2),
        itemBuilder: (context, index) {
          if (index == 0 || index == shownList.length + 1) {
            return CustomTile(
              contentPadding:
                  index == 0 ? null : EdgeInsets.only(top: 8, bottom: 50),
              subtitle: Center(
                child: Text(
                  S.of(context).search_result_count(shownList.length),
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            );
          }
          final ce = shownList[index - 1];
          String additionalText = '';
          switch (filterData.sortKeys.first) {
            case CraftCompare.atk:
              additionalText = '  ATK ${ce.atkMax}';
              break;
            case CraftCompare.hp:
              additionalText = '  HP ${ce.hpMax}';
              break;
            default:
              break;
          }
          return CustomTile(
            leading: db.getIconImage(ce.icon, width: 60),
            title: AutoSizeText(ce.localizedName, maxLines: 1),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (!Language.isJP)
                  AutoSizeText(ce.nameJp ?? ce.name, maxLines: 1),
                Text('No.${ce.no.toString().padRight(4)}  $additionalText'),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              SplitRoute.push(
                context: context,
                builder: (context, _) =>
                    CraftDetailPage(ce: ce, onSwitch: switchNext),
                popDetail: true,
              );
            },
          );
        });
  }

  Widget _buildGridView() {
    if (shownList.length % 5 == 0) {
      shownList.add(null);
    }
    return GridView.count(
        crossAxisCount: 5,
        childAspectRatio: 1,
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        children: shownList.map((ce) {
          if (ce == null) {
            return Container();
          }
          return Center(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: GestureDetector(
                  child: db.getIconImage(ce.icon),
                  onTap: () {
                    SplitRoute.push(
                      context: context,
                      builder: (context, _) =>
                          CraftDetailPage(ce: ce, onSwitch: switchNext),
                      popDetail: true,
                    );
                  },
                )),
          );
        }).toList());
  }

  CraftEssence switchNext(int cur, bool next) {
    if (shownList.length <= 0) return null;
    for (int i = 0; i < shownList.length; i++) {
      if (shownList[i].no == cur) {
        int nextIndex = i + (next ? 1 : -1);
        if (nextIndex < shownList.length && nextIndex >= 0) {
          return shownList[nextIndex];
        } else {
          // if reach the end/head of list, return null
          return null;
        }
      }
    }
    // if not found in list, return the first one
    return shownList[0];
  }
}
