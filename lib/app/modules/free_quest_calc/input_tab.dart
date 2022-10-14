import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../tools/glpk_solver.dart';
import '../item/item_select.dart';
import 'filter_dialog.dart';

class DropCalcInputTab extends StatefulWidget {
  final Map<int, int>? objectiveCounts;
  final ValueChanged<LPSolution>? onSolved;

  DropCalcInputTab({super.key, this.objectiveCounts, this.onSolved});

  @override
  _DropCalcInputTabState createState() => _DropCalcInputTabState();
}

class _DropCalcInputTabState extends State<DropCalcInputTab> {
  late ScrollController _scrollController;

  FreeLPParams get params => db.curUser.freeLPParams;

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
          elevation: 1,
          child: ListTile(
            title: Text(S.current.item),
            contentPadding: const EdgeInsetsDirectional.only(start: 18, end: 8),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 65,
                  child: Center(
                    child: Text(
                        planOrEff ? S.current.counts : S.current.calc_weight),
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
        ),
        if (params.rows.isEmpty)
          ListTile(title: Center(child: Text(S.current.drop_calc_empty_hint))),
        Expanded(child: _buildInputRows()),
        kDefaultDivider,
        SafeArea(child: _buildButtonBar())
      ],
    );
  }

  Widget _buildInputRows() {
    final itemIds = List.of(params.rows);
    return ListView.separated(
      controller: _scrollController,
      separatorBuilder: (context, index) => kDefaultDivider,
      itemCount: itemIds.length,
      itemBuilder: (context, index) {
        final itemId = itemIds[index];
        final item = db.gameData.items[itemId];
        Widget leading = InkWell(
          onTap: () {
            if (item != null) {
              router.push(url: item.route);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: db.getIconImage(
              itemId == Items.bondPointId
                  ? Items.lantern?.icon
                  : itemId == Items.expPointId
                      ? null
                      : item?.borderedIcon,
              width: 36,
              aspectRatio: 132 / 144,
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
            router.push(
              child: ItemSelectPage(
                includeSpecial: true,
                onSelected: (v) {
                  if (params.rows.contains(v)) {
                    EasyLoading.showInfo(
                        S.current.item_already_exist_hint(_getItemName(v)));
                  } else if (index < params.rows.length) {
                    params.rows[index] = v;
                  }
                  if (mounted) setState(() {});
                },
              ),
            );
          },
        );
        Widget subtitle = Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
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
          titlePadding: const EdgeInsetsDirectional.only(end: 6),
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 65,
                child: TextFormField(
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
                    DropdownMenuItem(value: true, child: Text(S.current.plan)),
                    DropdownMenuItem(
                        value: false, child: Text(S.current.efficiency))
                  ],
                  onChanged: (v) => setState(() => planOrEff = v ?? planOrEff),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              color: params.minCost > 0 ||
                      db.gameData.mainStories[params.progress] != null ||
                      params.blacklist.isNotEmpty ||
                      !params.use6th ||
                      params.dailyCostHalf
                  ? Theme.of(context).errorColor
                  : Theme.of(context).colorScheme.primary,
              tooltip: S.current.settings_tab_name,
              onPressed: () async {
                await showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) => FreeCalcFilterDialog(params: params),
                );
                setState(() {});
              },
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: S.current.filter_sort,
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
                    router.push(
                        child: ItemSelectPage(
                      includeSpecial: true,
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
                  child: Text(S.current.drop_calc_solve),
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
    if (Maths.max(params.counts, 0) <= 0) {
      EasyLoading.showToast(S.current.input_invalid_hint);
      return;
    }
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
  }
}

String _getItemName(int itemId, [Item? item]) {
  return item?.lName.l ??
      db.gameData.items[itemId]?.lName.l ??
      (itemId == Items.bondPointId
          ? S.current.bond
          : itemId == Items.expPointId
              ? 'EXP'
              : 'Item $itemId');
}
