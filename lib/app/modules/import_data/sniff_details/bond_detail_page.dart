import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:csv/csv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/packages/sharex.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SvtBondDetailPage extends StatefulWidget {
  final String? friendCode;
  // key=game id
  final List<UserSvtCollection> userSvtCollections;
  final List<UserSvt> userSvts;

  const SvtBondDetailPage({super.key, this.friendCode, required this.userSvtCollections, required this.userSvts});

  @override
  _SvtBondDetailPageState createState() => _SvtBondDetailPageState();
}

enum _SvtSortType {
  no,
  cls,
  rarity,
  bondRank,
  bondNext,
  bondTotal,
}

enum _CESortType {
  no,
  cls,
  rarity,
  time,
}

class _SvtBondDetailPageState extends State<SvtBondDetailPage> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);
  _SvtSortType svtSortType = _SvtSortType.no;
  _CESortType ceSortType = _CESortType.time;
  bool reversed = false;

  List<MapEntry<Servant, UserSvtCollection>> collections = [];
  List<(CraftEssence, UserSvt?, UserSvtCollection)> bondCEs = [];

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    final userCEs = <int, UserSvt>{};
    for (final userSvt in widget.userSvts) {
      final ce = db.gameData.craftEssencesById[userSvt.svtId];
      if (ce != null && ce.flag == SvtFlag.svtEquipFriendShip) {
        userCEs[userSvt.svtId] = userSvt;
      }
    }

    for (final collection in widget.userSvtCollections) {
      if (!collection.isOwned) continue;
      final svt = db.gameData.servantsById[collection.svtId];
      if (svt != null) {
        collections.add(MapEntry(svt, collection));
      }
      final ce = db.gameData.craftEssencesById[collection.svtId];
      if (ce != null && ce.flag == SvtFlag.svtEquipFriendShip) {
        bondCEs.add((ce, userCEs[collection.svtId], collection));
      }
    }

    sort();
  }

  void sort() {
    switch (ceSortType) {
      case _CESortType.no:
        bondCEs.sort2((e) => e.$1.collectionNo);
        break;
      case _CESortType.cls:
        bondCEs.sort((a, b) {
          return SvtFilterData.compare(
              db.gameData.servantsById[a.$1.bondEquipOwner], db.gameData.servantsById[b.$1.bondEquipOwner],
              keys: [SvtCompare.className, SvtCompare.rarity, SvtCompare.no], reversed: [false, true, false]);
        });
        break;
      case _CESortType.rarity:
        bondCEs.sort((a, b) {
          return SvtFilterData.compare(
              db.gameData.servantsById[a.$1.bondEquipOwner], db.gameData.servantsById[b.$1.bondEquipOwner],
              keys: [SvtCompare.rarity, SvtCompare.className, SvtCompare.no], reversed: [false, false, false]);
        });
        break;
      case _CESortType.time:
        bondCEs.sort2((e) => e.$2?.createdAt ?? e.$3.updatedAt, reversed: true);
        break;
    }
    switch (svtSortType) {
      case _SvtSortType.no:
        collections.sort2((e) => e.key.collectionNo);
        break;
      case _SvtSortType.cls:
        collections.sort((a, b) {
          return SvtFilterData.compare(a.key, b.key,
              keys: [SvtCompare.className, SvtCompare.rarity, SvtCompare.no], reversed: [false, true, false]);
        });
        break;
      case _SvtSortType.rarity:
        collections.sort((a, b) {
          return SvtFilterData.compare(a.key, b.key,
              keys: [SvtCompare.rarity, SvtCompare.className, SvtCompare.no], reversed: [false, false, false]);
        });
        break;
      case _SvtSortType.bondRank:
        collections.sort((a, b) {
          if (a.value.friendshipRank != b.value.friendshipRank) {
            return b.value.friendshipRank - a.value.friendshipRank;
          }
          if (a.value.friendshipExceedCount != b.value.friendshipExceedCount) {
            return b.value.friendshipExceedCount - a.value.friendshipExceedCount;
          }
          return a.key.collectionNo - b.key.collectionNo;
        });
        break;
      case _SvtSortType.bondNext:
        collections.sort((a, b) {
          int v = _getBondNext(a.key, a.value) - _getBondNext(b.key, b.value);
          if (v != 0) return v;
          return a.key.collectionNo - b.key.collectionNo;
        });
        break;
      case _SvtSortType.bondTotal:
        collections.sort((a, b) {
          return a.value.friendship - b.value.friendship;
        });
        break;
    }
    if (reversed) {
      collections = collections.reversed.toList();
      bondCEs = bondCEs.reversed.toList();
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
      appBar: AppBar(
        title: Text(S.current.bond),
        actions: [
          IconButton(
            onPressed: () {
              exportCSV().catchError((e, s) {
                logger.e('export bond csv failed', e, s);
                EasyLoading.showError(e.toString());
              });
            },
            icon: const Icon(Icons.save_alt),
            tooltip: '${S.current.save_as} CSV',
          )
        ],
        bottom: FixedHeight.tabBar(
            TabBar(controller: _tabController, tabs: [Tab(text: S.current.bond), Tab(text: S.current.bond_craft)])),
      ),
      body: Column(
        children: [
          Expanded(child: TabBarView(controller: _tabController, children: [bondTab, bondCETab])),
          buttonBar,
        ],
      ),
    );
  }

  Widget get bondCETab {
    return ListView.separated(
      itemBuilder: (context, index) {
        final (ce, userSvt, collection) = bondCEs[index];
        final svt = db.gameData.servantsById[ce.bondEquipOwner];
        String subtitle;
        if (userSvt != null) {
          subtitle = userSvt.createdAt.sec2date().toStringShort(omitSec: true);
        } else {
          subtitle = '???  (${collection.createdAt.sec2date().toStringShort(omitSec: true)}?)';
        }
        return ListTile(
          dense: true,
          leading: ce.iconBuilder(context: context),
          title: Text.rich(
            TextSpan(text: ce.lName.l, children: [
              TextSpan(
                text: ' (${svt?.lName.l ?? S.current.unknown})',
                style: Theme.of(context).textTheme.bodySmall,
              )
            ]),
          ),
          subtitle: Text(subtitle),
          trailing: svt?.iconBuilder(context: context),
          onTap: ce.routeTo,
        );
      },
      separatorBuilder: (_, __) => kDefaultDivider,
      itemCount: bondCEs.length,
    );
  }

  Widget get bondTab {
    return Column(
      children: [
        ListTile(
          leading: db.getIconImage(null, aspectRatio: 132 / 144, padding: const EdgeInsets.symmetric(vertical: 4)),
          tileColor: Theme.of(context).cardColor,
          title: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      child: const Text('Rank'),
                      onPressed: () => onSort(_SvtSortType.bondRank),
                    ),
                  )),
              Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: const Text("Total"),
                      onPressed: () => onSort(_SvtSortType.bondTotal),
                    ),
                  )),
              Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: const Text('Next'),
                      onPressed: () => onSort(_SvtSortType.bondNext),
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
                              'Lv.${collection.friendshipRank}/'
                              '${(svt.collectionNo == 1 ? 5 : 10) + collection.friendshipExceedCount}',
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
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: AutoSizeText(
                                collection.friendship.format(),
                                maxLines: 1,
                                maxFontSize: 14,
                                minFontSize: 6,
                                style: const TextStyle(fontFamily: kMonoFont, fontWeight: FontWeight.bold),
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
      ],
    );
  }

  Widget get buttonBar {
    final soldCECount = bondCEs.where((e) => e.$2 == null).length;
    String ceSummary = '${S.current.bond_craft}: ${bondCEs.length}';
    if (soldCECount > 0) {
      ceSummary += '($soldCECount sold?)';
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            ceSummary,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Text('  ${S.current.filter_sort} '),
        _tabController.index == 0
            ? DropdownButton<_SvtSortType>(
                value: svtSortType,
                items: [
                  const DropdownMenuItem(
                    value: _SvtSortType.no,
                    child: Text('No.'),
                  ),
                  DropdownMenuItem(
                    value: _SvtSortType.cls,
                    child: Text(S.current.svt_class),
                  ),
                  DropdownMenuItem(
                    value: _SvtSortType.rarity,
                    child: Text(S.current.filter_sort_rarity),
                  ),
                  const DropdownMenuItem(
                    value: _SvtSortType.bondRank,
                    child: Text('Rank'),
                  ),
                  const DropdownMenuItem(
                    value: _SvtSortType.bondTotal,
                    child: Text('Total'),
                  ),
                  const DropdownMenuItem(
                    value: _SvtSortType.bondNext,
                    child: Text('Next'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      svtSortType = v;
                      sort();
                    });
                  }
                },
              )
            : DropdownButton<_CESortType>(
                value: ceSortType,
                items: [
                  DropdownMenuItem(
                    value: _CESortType.time,
                    child: Text(S.current.time),
                  ),
                  const DropdownMenuItem(
                    value: _CESortType.no,
                    child: Text('No.'),
                  ),
                  DropdownMenuItem(
                    value: _CESortType.cls,
                    child: Text(S.current.svt_class),
                  ),
                  DropdownMenuItem(
                    value: _CESortType.rarity,
                    child: Text(S.current.filter_sort_rarity),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      ceSortType = v;
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
          icon: FaIcon(reversed ? FontAwesomeIcons.arrowUpZA : FontAwesomeIcons.arrowDownZA),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void onSort(_SvtSortType _sortType) {
    setState(() {
      if (_sortType == svtSortType) {
        reversed = !reversed;
      } else {
        svtSortType = _sortType;
      }
      sort();
    });
  }

  Future<void> exportCSV() async {
    List<List> table = [];
    table.add([
      'svtId',
      'ID',
      'Name',
      'Rarity',
      'Rank',
      'RankMax',
      'Total',
      'Next',
      for (int bond = 4; bond < 15; bond++) 'Total(Lv${bond + 1})'
    ]);
    for (final entry in collections) {
      final svt = entry.key, status = entry.value;
      table.add([
        svt.id,
        svt.collectionNo,
        svt.lName.l,
        svt.rarity,
        status.friendshipRank,
        (svt.collectionNo == 1 ? 5 : 10) + status.friendshipExceedCount,
        status.friendship,
        _getBondNext(svt, status),
        for (int bond = 4; bond < 15; bond++) svt.bondGrowth.getOrNull(bond) ?? "",
      ]);
    }
    final content = const ListToCsvConverter().convert(table);

    final fn = 'bond-detail-${widget.friendCode ?? ""}-${DateTime.now().toDateString()}.csv';
    if (kIsWeb) {
      kPlatformMethods.downloadString(content, fn);
    } else {
      final file = File(joinPaths(db.paths.downloadDir, fn));
      await file.writeAsString(content);
      if (PlatformU.isDesktop) {
        openFile(db.paths.downloadDir);
      } else {
        ShareX.shareFile(file.path);
      }
    }
  }
}
