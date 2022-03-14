import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../tools/glpk_solver.dart';
import 'filter_dialog.dart';

class DropCalcInputTab extends StatefulWidget {
  final Map<int, int>? objectiveCounts;
  final ValueChanged<LPSolution>? onSolved;

  DropCalcInputTab({Key? key, this.objectiveCounts, this.onSolved})
      : super(key: key);

  @override
  _DropCalcInputTabState createState() => _DropCalcInputTabState();
}

class _DropCalcInputTabState extends State<DropCalcInputTab> {
  late ScrollController _scrollController;

  FreeLPParams get params => db2.curUser.freeLPParams;

  // category - itemKey
  final FreeLPSolver solver = FreeLPSolver();
  bool running = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    if (widget.objectiveCounts != null) {
      params.rows.clear();
      widget.objectiveCounts!.forEach((key, count) {
        if (!params.rows.contains(key)) {
          params.rows.add(key);
          params.planItemCounts[key] = count;
        }
      });
    } else {
      if (params.rows.isEmpty) {
        addAnItemNotInList();
        addAnItemNotInList();
      }
    }
    params.sortByItem();
    // update userdata at last
    solver.ensureEngine();
  }

  @override
  void dispose() {
    solver.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          child: ListTile(
            title: Text(S.of(context).item),
            contentPadding: const EdgeInsets.only(left: 18, right: 8),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 65,
                  child: Center(
                    child: Text(planOrEff
                        ? S.of(context).counts
                        : S.of(context).calc_weight),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    SimpleCancelOkDialog(
                      title: Text(S.current.clear),
                      onTapOk: () {
                        setState(() {
                          params.rows.clear();
                        });
                      },
                    ).showDialog(context);
                  },
                )
              ],
            ),
          ),
          elevation: 1,
        ),
        if (params.rows.isEmpty)
          ListTile(
              title: Center(child: Text(S.of(context).drop_calc_empty_hint))),
        Expanded(child: _buildInputRows()),
        kDefaultDivider,
        SafeArea(child: _buildButtonBar())
      ],
    );
  }

  Widget _buildInputRows() {
    return ListView.separated(
      controller: _scrollController,
      separatorBuilder: (context, index) => kDefaultDivider,
      itemCount: params.rows.length,
      itemBuilder: (context, index) {
        final itemId = params.rows[index];
        final item = db2.gameData.items[itemId];
        Widget leading = GestureDetector(
          onTap: () {
            if (item != null) {
              router.push(url: item.route);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: db2.getIconImage(
              itemId == Items.bondPointId
                  ? Items.lantern.icon
                  : itemId == Items.expPointId
                      ? null
                      : item?.borderedIcon,
              height: 48,
            ),
          ),
        );
        Widget title = TextButton(
          style: TextButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const Size(48, 28),
            padding: PlatformU.isMobile
                ? const EdgeInsets.symmetric(horizontal: 8)
                : null,
          ),
          child: Text(_getItemName(itemId, item)),
          onPressed: () {
            SplitRoute.push(context, _ItemSelectPage(
              onSelected: (v) {
                if (params.rows.contains(v)) {
                  EasyLoading.showInfo(
                      S.current.item_already_exist_hint(_getItemName(v)));
                } else {
                  params.rows[index] = v;
                }
                if (mounted) setState(() {});
              },
            ));
          },
        );
        Widget subtitle = Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            planOrEff
                ? S.current.words_separate(
                    S.current.calc_weight, params.getPlanItemWeight(itemId))
                : S.current.words_separate(
                    S.current.counts, params.getPlanItemCount(itemId)),
          ),
        );
        return CustomTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          titlePadding: const EdgeInsets.only(right: 6),
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 65,
                child: TextField(
                  key: Key('calc_input_$itemId'),
                  controller: TextEditingController(
                      text: planOrEff
                          ? params.getPlanItemCount(itemId).toString()
                          : params.getPlanItemWeight(itemId).toString()),
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  textAlign: TextAlign.center,
                  // textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(isDense: true),
                  // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (s) {
                    if (planOrEff) {
                      int? v = int.tryParse(s);
                      if (v != null) params.planItemCounts[itemId] = v;
                    } else {
                      double? v = double.tryParse(s);
                      if (v != null) params.planItemWeights[itemId] = v;
                    }
                  },
                ),
              ),
              IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  focusNode: FocusNode(skipTraversal: true),
                  onPressed: () {
                    setState(() {
                      params.rows.remove(itemId);
                    });
                  })
            ],
          ),
        );
      },
    );
  }

  Widget _buildButtonBar() {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: <Widget>[
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: <Widget>[
                DropdownButton<bool>(
                  value: planOrEff,
                  isDense: true,
                  items: [
                    DropdownMenuItem(
                        value: true, child: Text(S.of(context).plan)),
                    DropdownMenuItem(
                        value: false, child: Text(S.of(context).efficiency))
                  ],
                  onChanged: (v) => setState(() => planOrEff = v ?? planOrEff),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              color: params.minCost > 0 ||
                      params.maxColNum > 0 ||
                      params.blacklist.isNotEmpty ||
                      !params.use6th
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
              tooltip: S.of(context).settings_tab_name,
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) => FreeCalcFilterDialog(params: params));
                setState(() {});
              },
            ),
            //TODO: add extra event quests button
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: S.of(context).filter_sort,
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {
                setState(() {
                  params.sortByItem();
                });
              },
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  tooltip: 'Add',
                  onPressed: () {
                    SplitRoute.push(context, _ItemSelectPage(
                      onSelected: (v) {
                        if (params.rows.contains(v)) {
                          EasyLoading.showInfo(S.current
                              .item_already_exist_hint(_getItemName(v)));
                        } else {
                          params.rows.add(v);
                        }
                        if (mounted) setState(() {});
                      },
                    ));
                  },
                ),
                ElevatedButton(
                  onPressed: running ? null : solve,
                  child: Text(S.of(context).drop_calc_solve),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  void addAnItemNotInList() {
    final itemId =
        params.sheet.itemIds.firstWhereOrNull((e) => !params.rows.contains(e));
    if (itemId != null) params.rows.add(itemId);
  }

  bool planOrEff = true;

  void solve() async {
    FocusScope.of(context).unfocus();
    if (Maths.max(params.counts, 0) > 0) {
      setState(() {
        running = true;
      });
      final solution = await solver.calculate(params: params);
      running = false;
      solution.destination = planOrEff ? 1 : 2;
      solution.params = params;
      if (widget.onSolved != null) {
        widget.onSolved!(solution);
      }
    } else {
      EasyLoading.showToast(S.of(context).input_invalid_hint);
    }
  }
}

class _ItemSelectPage extends StatelessWidget {
  final ValueChanged<int> onSelected;

  const _ItemSelectPage({Key? key, required this.onSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<int, List<Item>> groupedItems = {};
    for (final item in db2.gameData.items.values) {
      final key = item.skillUpItemType.index * 10 + item.background.index;
      groupedItems.putIfAbsent(key, () => []).add(item);
    }
    int normal = SkillUpItemType.normal.index,
        gem = SkillUpItemType.skill.index,
        ascension = SkillUpItemType.ascension.index;
    int bronze = ItemBGType.bronze.index,
        silver = ItemBGType.silver.index,
        gold = ItemBGType.gold.index;
    Map<int, String?> titles = {
      0: S.current.item_category_special,
      normal * 10 + bronze: S.current.item_category_bronze,
      normal * 10 + silver: S.current.item_category_silver,
      normal * 10 + gold: S.current.item_category_gold,
      gem * 10 + bronze: null, // S.current.item_category_gem,
      gem * 10 + silver: null, // S.current.item_category_magic_gem,
      gem * 10 + gold: null, // S.current.item_category_secret_gem,
      ascension * 10 + silver: null, // S.current.item_category_piece,
      ascension * 10 + gold: null, // S.current.item_category_monument,
    };
    List<Widget> children = [];
    for (int key in titles.keys) {
      if (key == 0) {
        children.add(TileGroup(
          header: titles[key],
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 2,
                runSpacing: 2,
                children: [
                  _oneItem(context, Items.bondPointId, Items.lantern.icon,
                      S.current.bond),
                  _oneItem(context, Items.expPointId, '', 'EXP'),
                ],
              ),
            )
          ],
        ));
      } else {
        final items = groupedItems[key];
        if (items == null || items.isEmpty) continue;
        items.sort2((e) => e.priority);
        children.add(TileGroup(
          header: titles[key],
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: GridView.extent(
                maxCrossAxisExtent: 50,
                childAspectRatio: 132 / 144,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  for (final item in items)
                    _oneItem(context, item.id, item.borderedIcon, item.lName.l)
                ],
              ),
            )
          ],
        ));
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Select One Item')),
      body: ListView(children: children),
    );
  }

  Widget _oneItem(BuildContext context, int id, String icon, String name) {
    return Item.iconBuilder(
      context: context,
      item: null,
      icon: icon,
      width: 48,
      onTap: () {
        onSelected(id);
        Navigator.pop(context);
      },
    );
    // return InkWell(
    //   onTap: () {
    //     onSelected(id);
    //     Navigator.pop(context);
    //   },
    //   child: Row(
    //     mainAxisSize: MainAxisSize.min,
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
    //       Item.iconBuilder(
    //         context: context,
    //         item: null,
    //         icon: icon,
    //         width: 36,
    //         jumpToDetail: false,
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 4),
    //         child: SizedBox(
    //           height: 32,
    //           width: 36,
    //           child: AutoSizeText(
    //             name,
    //             maxLines: 2,
    //           ),
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }
}

String _getItemName(int itemId, [Item? item]) {
  return item?.lName.l ??
      db2.gameData.items[itemId]?.lName.l ??
      (itemId == Items.bondPointId
          ? S.current.bond
          : itemId == Items.expPointId
              ? 'EXP'
              : 'Item $itemId');
}
