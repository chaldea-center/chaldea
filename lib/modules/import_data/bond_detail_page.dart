import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

class SvtBondDetailPage extends StatefulWidget {
  // key=game id
  final Map<int, Servant> svtIdMap;
  final Map<int, UserSvtCollection> cardCollections;

  SvtBondDetailPage(
      {Key? key, required this.svtIdMap, required this.cardCollections})
      : super(key: key);

  @override
  _SvtBondDetailPageState createState() => _SvtBondDetailPageState();
}

enum _SortType {
  no,
  cls,
  rarity,
  bondRank,
  bondNext,
  bondTotal,
}

class _SvtBondDetailPageState extends State<SvtBondDetailPage> {
  _SortType sortType = _SortType.no;
  bool reversed = false;

  List<MapEntry<Servant, UserSvtCollection>> collections = [];

  @override
  void initState() {
    super.initState();
    widget.cardCollections.forEach((key, collection) {
      final svt = widget.svtIdMap[collection.svtId];
      if (collection.isOwned && svt != null) {
        collections.add(MapEntry(svt, collection));
      }
    });
    sort();
  }

  void sort() {
    switch (sortType) {
      case _SortType.no:
        collections.sort((a, b) {
          return a.key.no - b.key.no;
        });
        break;
      case _SortType.cls:
        collections.sort((a, b) {
          return Servant.compare(a.key, b.key,
              keys: [SvtCompare.className, SvtCompare.rarity, SvtCompare.no],
              reversed: [false, true, false]);
        });
        break;
      case _SortType.rarity:
        collections.sort((a, b) {
          return Servant.compare(a.key, b.key,
              keys: [SvtCompare.rarity, SvtCompare.className, SvtCompare.no],
              reversed: [false, false, false]);
        });
        break;
      case _SortType.bondRank:
        collections.sort((a, b) {
          if (a.value.friendshipRank != b.value.friendshipRank) {
            return b.value.friendshipRank - a.value.friendshipRank;
          }
          return a.key.no - b.key.no;
        });
        break;
      case _SortType.bondNext:
        collections.sort((a, b) {
          int v = _getBondNext(a.key, a.value) - _getBondNext(b.key, b.value);
          if (v != 0) return v;
          return a.key.no - b.key.no;
        });
        break;
      case _SortType.bondTotal:
        collections.sort((a, b) {
          return a.value.friendship - b.value.friendship;
        });
        break;
    }
    if (reversed) {
      collections = collections.reversed.toList();
    }
  }

  int _getBondNext(Servant svt, UserSvtCollection collection) {
    int x = collection.friendship;
    for (int v in svt.bondPoints) {
      x -= v;
      if (x < 0) {
        break;
      }
    }
    return -x;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('羁绊详情'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: db.getIconImage(null,
                aspectRatio: 132 / 144,
                padding: EdgeInsets.symmetric(vertical: 4)),
            tileColor: Theme.of(context).cardColor,
            title: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        child: Text('Rank'),
                        onPressed: () => onTouch(_SortType.bondRank),
                      ),
                    )),
                Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        child: Text('Total'),
                        onPressed: () => onTouch(_SortType.bondTotal),
                      ),
                    )),
                Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        child: Text('Next'),
                        onPressed: () => onTouch(_SortType.bondNext),
                      ),
                    )),
              ],
            ),
          ),
          kDefaultDivider,
          Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  final svt = collections[index].key;
                  final collection = collections[index].value;
                  return ListTile(
                    leading: svt.iconBuilder(context: context),
                    title: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.center,
                              child: AutoSizeText(
                                'Lv.${collection.friendshipRank}/${10 + collection.friendshipExceedCount}',
                                maxLines: 1,
                                maxFontSize: 14,
                                minFontSize: 6,
                                style: TextStyle(fontFamily: kMonoFont),
                              ),
                            )),
                        Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                color: Theme.of(context).highlightColor,
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: AutoSizeText(
                                  formatNumber(collection.friendship),
                                  maxLines: 1,
                                  maxFontSize: 14,
                                  minFontSize: 6,
                                  style: TextStyle(
                                      fontFamily: kMonoFont,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                        Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: AutoSizeText(
                                formatNumber(_getBondNext(svt, collection)),
                                maxLines: 1,
                                maxFontSize: 14,
                                minFontSize: 6,
                                style: TextStyle(fontFamily: kMonoFont),
                              ),
                            )),
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, __) => kDefaultDivider,
                itemCount: collections.length),
          ),
          ButtonBar(
            children: [
              Text(S.current.filter_sort),
              DropdownButton<_SortType>(
                value: sortType,
                items: [
                  DropdownMenuItem(
                    child: Text('No.'),
                    value: _SortType.no,
                  ),
                  DropdownMenuItem(
                    child: Text(S.current.filter_sort_class),
                    value: _SortType.cls,
                  ),
                  DropdownMenuItem(
                    child: Text(S.current.filter_sort_rarity),
                    value: _SortType.rarity,
                  ),
                  DropdownMenuItem(
                    child: Text('羁绊等级'),
                    value: _SortType.bondRank,
                  ),
                  DropdownMenuItem(
                    child: Text('总羁绊值'),
                    value: _SortType.bondTotal,
                  ),
                  DropdownMenuItem(
                    child: Text('升级所需羁绊值'),
                    value: _SortType.bondNext,
                  ),
                ],
                onChanged: (v) {
                  if (v != null)
                    setState(() {
                      sortType = v;
                      sort();
                    });
                },
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    reversed = !reversed;
                    sort();
                  });
                },
                tooltip: 'Reversed',
                icon: Icon(
                    reversed ? Icons.arrow_circle_down : Icons.arrow_circle_up),
              )
            ],
          )
        ],
      ),
    );
  }

  void onTouch(_SortType _sortType) {
    setState(() {
      if (_sortType == sortType) {
        reversed = !reversed;
      } else {
        sortType = _sortType;
      }
      sort();
    });
  }
}
