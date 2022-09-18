import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class SvtBondDetailPage extends StatefulWidget {
  // key=game id
  final Map<int, UserSvtCollection> cardCollections;

  const SvtBondDetailPage({super.key, required this.cardCollections});

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
      final svt = db.gameData.servantsById[collection.svtId];
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
          return a.key.collectionNo - b.key.collectionNo;
        });
        break;
      case _SortType.cls:
        collections.sort((a, b) {
          return SvtFilterData.compare(a.key, b.key,
              keys: [SvtCompare.className, SvtCompare.rarity, SvtCompare.no],
              reversed: [false, true, false]);
        });
        break;
      case _SortType.rarity:
        collections.sort((a, b) {
          return SvtFilterData.compare(a.key, b.key,
              keys: [SvtCompare.rarity, SvtCompare.className, SvtCompare.no],
              reversed: [false, false, false]);
        });
        break;
      case _SortType.bondRank:
        collections.sort((a, b) {
          if (a.value.friendshipRank != b.value.friendshipRank) {
            return b.value.friendshipRank - a.value.friendshipRank;
          }
          if (a.value.friendshipExceedCount != b.value.friendshipExceedCount) {
            return b.value.friendshipExceedCount -
                a.value.friendshipExceedCount;
          }
          return a.key.collectionNo - b.key.collectionNo;
        });
        break;
      case _SortType.bondNext:
        collections.sort((a, b) {
          int v = _getBondNext(a.key, a.value) - _getBondNext(b.key, b.value);
          if (v != 0) return v;
          return a.key.collectionNo - b.key.collectionNo;
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
    for (int v in svt.bondGrowth) {
      if (x < v) {
        return v - x;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.bond)),
      body: Column(
        children: [
          ListTile(
            leading: db.getIconImage(null,
                aspectRatio: 132 / 144,
                padding: const EdgeInsets.symmetric(vertical: 4)),
            tileColor: Theme.of(context).cardColor,
            title: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        child: const Text('Rank'),
                        onPressed: () => onTouch(_SortType.bondRank),
                      ),
                    )),
                Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        child: const Text("Total"),
                        onPressed: () => onTouch(_SortType.bondTotal),
                      ),
                    )),
                Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        child: const Text('Next'),
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
                                style: kMonoStyle,
                              ),
                            )),
                        Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                color: Theme.of(context).highlightColor,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: AutoSizeText(
                                  collection.friendship.format(),
                                  maxLines: 1,
                                  maxFontSize: 14,
                                  minFontSize: 6,
                                  style: const TextStyle(
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
                                _getBondNext(svt, collection).format(),
                                maxLines: 1,
                                maxFontSize: 14,
                                minFontSize: 6,
                                style: const TextStyle(fontFamily: kMonoFont),
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
                  const DropdownMenuItem(
                    value: _SortType.no,
                    child: Text('No.'),
                  ),
                  DropdownMenuItem(
                    value: _SortType.cls,
                    child: Text(S.current.filter_sort_class),
                  ),
                  DropdownMenuItem(
                    value: _SortType.rarity,
                    child: Text(S.current.filter_sort_rarity),
                  ),
                  const DropdownMenuItem(
                    value: _SortType.bondRank,
                    child: Text('Rank'),
                  ),
                  const DropdownMenuItem(
                    value: _SortType.bondTotal,
                    child: Text('Total'),
                  ),
                  const DropdownMenuItem(
                    value: _SortType.bondNext,
                    child: Text('Next'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      sortType = v;
                      sort();
                    });
                  }
                },
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    reversed = !reversed;
                    sort();
                  });
                },
                tooltip: S.current.sort_order,
                icon: FaIcon(reversed
                    ? FontAwesomeIcons.arrowUpZA
                    : FontAwesomeIcons.arrowDownZA),
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
