import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:csv/csv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/app/modules/servant/filter.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/packages/sharex.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SvtBondDetailPage extends StatefulWidget {
  final String? friendCode;
  // key=game id
  final List<UserServantCollectionEntity> userSvtCollections;
  final List<UserServantEntity> userSvts;

  const SvtBondDetailPage({super.key, this.friendCode, required this.userSvtCollections, required this.userSvts});

  @override
  _SvtBondDetailPageState createState() => _SvtBondDetailPageState();
}

enum _SvtSortType { no, cls, rarity, bondRank, bondNext, bondTotal }

enum _CESortType { no, cls, rarity, time }

class _SvtBondDetailPageState extends State<SvtBondDetailPage> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);
  _SvtSortType svtSortType = _SvtSortType.bondRank;
  _CESortType ceSortType = _CESortType.time;
  bool ceGrid = false;
  bool reversed = false;
  final svtFilter = SvtFilterData();

  Map<int, UserServantCollectionEntity> userSvtCollections = {};

  List<({Servant svt, UserServantCollectionEntity collection})> collections = [];
  List<({Servant svt, UserServantCollectionEntity collection})> shownCollections = [];
  List<({CraftEssence ce, UserServantEntity? userCe, UserServantCollectionEntity collection})> bondCEs = [];

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    userSvtCollections = {for (final svt in widget.userSvtCollections) svt.svtId: svt};

    final userCEs = <int, UserServantEntity>{};
    for (final userSvt in widget.userSvts) {
      final ce = db.gameData.craftEssencesById[userSvt.svtId];
      if (ce != null && ce.flags.contains(SvtFlag.svtEquipFriendShip)) {
        userCEs[userSvt.svtId] = userSvt;
      }
    }

    for (final collection in widget.userSvtCollections) {
      if (!collection.isOwned) continue;
      final svt = db.gameData.servantsById[collection.svtId];
      if (svt != null) {
        collections.add((svt: svt, collection: collection));
      }
      final ce = db.gameData.craftEssencesById[collection.svtId];
      if (ce != null && ce.flags.contains(SvtFlag.svtEquipFriendShip)) {
        bondCEs.add((ce: ce, userCe: userCEs[collection.svtId], collection: collection));
      }
    }

    update();
  }

  void update() {
    final bondValue = svtFilter.bondValue.radioValue;
    svtFilter.bondValue.reset();
    shownCollections = collections.where((e) {
      if (bondValue != null && svtFilter.bondCompare.options.isNotEmpty) {
        if (svtFilter.bondCompare.options.every((c) => !c.test(e.collection.friendshipRank, bondValue))) {
          return false;
        }
      }
      return ServantFilterPage.filter(svtFilter, e.svt);
    }).toList();
    if (bondValue != null) svtFilter.bondValue.set(bondValue);

    switch (ceSortType) {
      case _CESortType.no:
        bondCEs.sort2((e) => e.ce.collectionNo);
        break;
      case _CESortType.cls:
        bondCEs.sort((a, b) {
          return SvtFilterData.compare(
            db.gameData.servantsById[a.ce.bondEquipOwner],
            db.gameData.servantsById[b.ce.bondEquipOwner],
            keys: SvtCompare.kClassFirstKeys,
          );
        });
        break;
      case _CESortType.rarity:
        bondCEs.sort((a, b) {
          return SvtFilterData.compare(
            db.gameData.servantsById[a.ce.bondEquipOwner],
            db.gameData.servantsById[b.ce.bondEquipOwner],
            keys: SvtCompare.kRarityFirstKeys,
          );
        });
        break;
      case _CESortType.time:
        bondCEs.sort2((e) => e.userCe?.createdAt ?? e.collection.updatedAt, reversed: true);
        break;
    }
    switch (svtSortType) {
      case _SvtSortType.no:
        shownCollections.sort2((e) => e.svt.collectionNo);
        break;
      case _SvtSortType.cls:
        shownCollections.sort((a, b) {
          return SvtFilterData.compare(a.svt, b.svt, keys: SvtCompare.kClassFirstKeys);
        });
        break;
      case _SvtSortType.rarity:
        shownCollections.sort((a, b) {
          return SvtFilterData.compare(a.svt, b.svt, keys: SvtCompare.kRarityFirstKeys);
        });
        break;
      case _SvtSortType.bondRank:
        shownCollections.sortByList(
          (e) => <int>[
            -e.collection.friendshipRank,
            -e.collection.maxFriendshipRank,
            _getBondNext(e.svt, e.collection),
            e.svt.collectionNo,
          ],
        );
        break;
      case _SvtSortType.bondNext:
        shownCollections.sort2((e) => _getBondNext(e.svt, e.collection));
        break;
      case _SvtSortType.bondTotal:
        shownCollections.sort2((e) => e.collection.friendship);
        break;
    }
    if (reversed) {
      shownCollections = shownCollections.reversed.toList();
      bondCEs = bondCEs.reversed.toList();
    }
    if (mounted) setState(() {});
  }

  int _getBondNext(Servant svt, UserServantCollectionEntity collection) {
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
          ),
        ],
        bottom: FixedHeight.tabBar(
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: S.current.bond),
              Tab(text: S.current.bond_craft),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(controller: _tabController, children: [bondTab, bondCETab]),
          ),
          SafeArea(child: buttonBar),
        ],
      ),
    );
  }

  Widget get bondCETab {
    if (ceGrid) {
      return GridView.extent(
        maxCrossAxisExtent: 60,
        childAspectRatio: 132 / 144,
        children: bondCEs.map((entry) {
          final (:ce, :userCe, :collection) = entry;
          final t = DateTime.fromMillisecondsSinceEpoch(
            (userCe?.createdAt ?? collection.updatedAt) * 1000,
          ).toDateString().substring(2);
          String text;
          if (userCe != null) {
            text = ' $t ';
          } else {
            text = ' $t? ';
          }
          final svt = db.gameData.servantsById[ce.bondEquipOwner];
          text += '\nLv.${userSvtCollections[ce.bondEquipOwner]?.friendshipRank} ';
          return svt?.iconBuilder(context: context, onTap: ce.routeTo, text: text) ??
              ce.iconBuilder(context: context, text: text);
        }).toList(),
      );
    }
    return ListView.separated(
      itemBuilder: (context, index) {
        final (:ce, :userCe, :collection) = bondCEs[index];
        final svt = db.gameData.servantsById[ce.bondEquipOwner];
        String subtitle;
        if (userCe != null) {
          subtitle = userCe.createdAt.sec2date().toStringShort(omitSec: true);
        } else {
          subtitle = '??? (${collection.createdAt.sec2date().toStringShort(omitSec: true)}?)';
        }
        subtitle += '  Lv.${userSvtCollections[ce.bondEquipOwner]?.friendshipRank}';
        return ListTile(
          dense: true,
          leading: ce.iconBuilder(context: context),
          title: Text.rich(
            TextSpan(
              text: ce.lName.l,
              children: [
                TextSpan(text: ' (${svt?.lName.l ?? S.current.unknown})', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          subtitle: Text(subtitle),
          trailing: svt?.iconBuilder(context: context),
          onTap: ce.routeTo,
        );
      },
      separatorBuilder: (_, _) => kDefaultDivider,
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
                  child: TextButton(child: const Text('Rank'), onPressed: () => onSort(_SvtSortType.bondRank)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(child: const Text("Total"), onPressed: () => onSort(_SvtSortType.bondTotal)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(child: const Text('Next'), onPressed: () => onSort(_SvtSortType.bondNext)),
                ),
              ),
            ],
          ),
        ),
        kDefaultDivider,
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) {
              final (:svt, :collection) = shownCollections[index];
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
                          '${collection.maxFriendshipRank}',
                          maxLines: 1,
                          maxFontSize: 14,
                          minFontSize: 6,
                          style: kMonoStyle,
                        ),
                      ),
                    ),
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
                      ),
                    ),
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
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, _) => kDefaultDivider,
            itemCount: shownCollections.length,
          ),
        ),
      ],
    );
  }

  Widget get buttonBar {
    final soldCECount = bondCEs.where((e) => e.userCe == null).length;
    String ceSummary = '${S.current.bond_craft}: ${bondCEs.length}';
    if (soldCECount > 0) {
      ceSummary += '($soldCECount sold?)';
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_tabController.index == 1)
          IconButton(
            onPressed: () {
              setState(() {
                ceGrid = !ceGrid;
              });
            },
            icon: Icon(ceGrid ? Icons.grid_view : Icons.list),
          ),
        Expanded(
          child: Text(ceSummary, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(' ${S.current.filter_sort} '),
        _tabController.index == 0
            ? DropdownButton<_SvtSortType>(
                value: svtSortType,
                items: [
                  const DropdownMenuItem(value: _SvtSortType.no, child: Text('No.')),
                  DropdownMenuItem(value: _SvtSortType.cls, child: Text(S.current.svt_class)),
                  DropdownMenuItem(value: _SvtSortType.rarity, child: Text(S.current.filter_sort_rarity)),
                  const DropdownMenuItem(value: _SvtSortType.bondRank, child: Text('Rank')),
                  const DropdownMenuItem(value: _SvtSortType.bondTotal, child: Text('Total')),
                  const DropdownMenuItem(value: _SvtSortType.bondNext, child: Text('Next')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    svtSortType = v;
                    update();
                  }
                },
              )
            : DropdownButton<_CESortType>(
                value: ceSortType,
                items: [
                  DropdownMenuItem(value: _CESortType.time, child: Text(S.current.time)),
                  const DropdownMenuItem(value: _CESortType.no, child: Text('No.')),
                  DropdownMenuItem(value: _CESortType.cls, child: Text(S.current.svt_class)),
                  DropdownMenuItem(value: _CESortType.rarity, child: Text(S.current.filter_sort_rarity)),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ceSortType = v;
                    update();
                  }
                },
              ),
        IconButton(
          onPressed: () {
            reversed = !reversed;
            update();
          },
          tooltip: S.current.sort_order,
          icon: FaIcon(reversed ? FontAwesomeIcons.arrowUpZA : FontAwesomeIcons.arrowDownZA),
        ),
        IconButton(
          icon: const Icon(Icons.filter_alt),
          tooltip: '${S.current.filter} (${S.current.servant})',
          onPressed: () => FilterPage.show(
            context: context,
            builder: (context) => ServantFilterPage(
              filterData: svtFilter,
              onChanged: (_) {
                svtFilter
                  ..planCompletion.reset()
                  ..curStatus.reset()
                  ..svtDuplicated.reset()
                  ..favorite = FavoriteState.all;
                update();
              },
              planMode: false,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void onSort(_SvtSortType _sortType) {
    if (_sortType == svtSortType) {
      reversed = !reversed;
    } else {
      svtSortType = _sortType;
    }
    update();
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
      for (int bond = 4; bond < 15; bond++) 'Total(Lv${bond + 1})',
    ]);
    for (final (:svt, :collection) in collections) {
      // final svt = entry.key, status = entry.value;
      table.add([
        svt.id,
        svt.collectionNo,
        svt.lName.l,
        svt.rarity,
        collection.friendshipRank,
        collection.maxFriendshipRank,
        collection.friendship,
        _getBondNext(svt, collection),
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
