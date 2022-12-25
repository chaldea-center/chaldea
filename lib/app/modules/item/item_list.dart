import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/free_quest_calc/free_calculator_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

enum _ItemSortType {
  default_,
  id,
  owned,
  left,
}

extension _ItemSortTypeX on _ItemSortType {
  String get shownName {
    switch (this) {
      case _ItemSortType.default_:
        return S.current.general_default;
      case _ItemSortType.id:
        return 'ID';
      case _ItemSortType.owned:
        return S.current.item_own;
      case _ItemSortType.left:
        return S.current.item_left;
    }
  }
}

class ItemListPage extends StatefulWidget {
  ItemListPage({super.key});

  @override
  State<StatefulWidget> createState() => ItemListPageState();
}

class ItemListPageState extends State<ItemListPage>
    with SingleTickerProviderStateMixin {
  bool filtered = false;
  _ItemSortType sortType = _ItemSortType.default_;

  late TabController _tabController;
  late List<TextEditingController> _itemRedundantControllers;

  Map<ItemCategory, List<int>> categorized = {};
  final shownCategories = [
    ItemCategory.normal,
    ItemCategory.special,
    ItemCategory.skill,
    ItemCategory.ascension,
    ItemCategory.eventAscension,
    ItemCategory.coin,
    ItemCategory.event,
    ItemCategory.other,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: shownCategories.length, vsync: this);
    _itemRedundantControllers = List.generate(
        3,
        (index) => TextEditingController(
            text: db.userData.itemAbundantValue[index].toString()));
    for (final item in db.gameData.items.values) {
      categorized.putIfAbsent(item.category, () => []).add(item.id);
    }
    categorized[ItemCategory.special] = <int>{
      ...categorized[ItemCategory.special] ?? [],
      ...Items.specialSvtMat
    }.toList();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.item_title),
        leading: const MasterBackButton(),
        titleSpacing: 0,
        actions: <Widget>[
          SharedBuilder.buildSwitchPlanButton(
            context: context,
            onChange: (index) async {
              db.curUser.curSvtPlanNo = index;
              db.itemCenter.calculate();
              if (mounted) setState(() {});
            },
          ),
          SharedBuilder.priorityIcon(context: context),
          IconButton(
            onPressed: () {
              setState(() {
                sortType = _ItemSortType
                    .values[(sortType.index + 1) % _ItemSortType.values.length];
              });
              EasyLoading.showToast(
                  '${S.current.sort_order} - ${sortType.shownName}');
            },
            icon: const Icon(Icons.sort),
            tooltip: '${S.current.sort_order} - ${sortType.shownName}',
          ),
          IconButton(
            icon: Icon(
                filtered ? Icons.check_circle : Icons.check_circle_outline),
            tooltip: S.current.item_only_show_lack,
            onPressed: () {
              FocusScope.of(context).unfocus();
              setState(() {
                filtered = !filtered;
              });
            },
          ),
        ],
        bottom: FixedHeight.tabBar(TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            for (final category in shownCategories)
              Tab(
                text: Transl.enums(category, (enums) => enums.itemCategory).l,
              ),
          ],
          onTap: (_) {
            FocusScope.of(context).unfocus();
          },
        )),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                for (final category in shownCategories)
                  db.onUserData(
                    (context, snapshot) => ItemListTab(
                      category: category,
                      items: categorized[category] ?? [],
                      onNavToCalculator: navToDropCalculator,
                      filtered: filtered,
                      showSet999: true,
                      editable: ![ItemCategory.event, ItemCategory.other]
                          .contains(category),
                      sortType: [ItemCategory.event, ItemCategory.other]
                              .contains(category)
                          ? _ItemSortType.id
                          : sortType,
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void navToDropCalculator() {
    Map<int, int> _getObjective() {
      Map<int, int> objective = {};
      final itemIds = db.gameData.dropRate.getSheet(true).itemIds;
      db.itemCenter.itemLeft.forEach((itemId, value) {
        final rarity = db.gameData.items[itemId]?.rarity ?? -1;
        if (rarity > 0 && rarity <= 3) {
          value -= db.userData.itemAbundantValue[rarity - 1];
        }
        if (itemIds.contains(itemId) && value < 0) {
          objective[itemId] = -value;
        }
      });
      return objective;
    }

    SimpleCancelOkDialog(
      title: Text(
        S.current.item_exceed_hint,
        style: const TextStyle(fontSize: 16),
      ),
      confirmText: S.current.plan,
      content: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (int index = 0; index < 3; index++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text([
                  S.current.bronze,
                  S.current.silver,
                  S.current.gold
                ][index]),
                SizedBox(
                  width: 40,
                  child: TextFormField(
                    controller: _itemRedundantControllers[index],
                    keyboardType:
                        const TextInputType.numberWithOptions(signed: true),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(isDense: true),
                    onChanged: (s) {
                      if (s == '-') {
                        db.userData.itemAbundantValue[index] = 0;
                      } else {
                        db.userData.itemAbundantValue[index] =
                            int.tryParse(s) ??
                                db.userData.itemAbundantValue[index];
                      }
                    },
                  ),
                )
              ],
            )
        ],
      ),
      onTapOk: () {
        Future.delayed(const Duration(milliseconds: 500), () {
          router.push(
            url: Routes.freeCalc,
            child: FreeQuestCalcPage(objectiveCounts: _getObjective()),
          );
        });
      },
      actions: [
        TextButton(
          onPressed: () {
            _itemRedundantControllers.forEach((e) => e.text = '0');
            db.userData.itemAbundantValue
                .fillRange(0, db.userData.itemAbundantValue.length, 0);
          },
          child: Text(S.current.clear),
        )
      ],
    ).showDialog(context);
  }
}

class ItemFilterDialog extends StatefulWidget {
  ItemFilterDialog({super.key});

  @override
  _ItemFilterDialogState createState() => _ItemFilterDialogState();
}

class _ItemFilterDialogState extends State<ItemFilterDialog> {
  @override
  Widget build(BuildContext context) {
    final priorityFilter = db.settings.svtFilterData.priority;
    return AlertDialog(
      title: Text(S.current.priority),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              priorityFilter.reset();
            });
            db.itemCenter.updateSvts(all: true);
          },
          child: Text(S.current.clear.toUpperCase()),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(S.current.confirm.toUpperCase()),
        )
      ],
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          int priority = 5 - index;
          bool checked = priorityFilter.options.contains(priority);
          String text = '${S.current.priority} $priority ';
          final tag = db.settings.priorityTags[priority] ?? "";
          return CheckboxListTile(
            value: checked,
            title: Text(text + tag),
            controlAffinity: ListTileControlAffinity.leading,
            // dense: true,
            onChanged: (v) {
              setState(() {
                priorityFilter.toggle(priority);
              });
              db.itemCenter.updateSvts(all: true);
            },
          );
        }),
      ),
    );
  }
}

class InputComponents {
  int data;
  FocusNode focusNode;
  TextEditingController? controller;

  InputComponents(
      {required this.data, required this.focusNode, required this.controller});

  void dispose() {
    focusNode.dispose();
    controller?.dispose();
  }
}

class ItemListTab extends StatefulWidget {
  final ItemCategory category;
  final List<int> items;
  final VoidCallback onNavToCalculator;
  final bool filtered;
  final bool showSet999;
  final bool editable;
  final _ItemSortType sortType;

  const ItemListTab({
    super.key,
    required this.category,
    required this.items,
    required this.onNavToCalculator,
    this.filtered = false,
    this.showSet999 = false,
    this.editable = true,
    this.sortType = _ItemSortType.default_,
  });

  @override
  _ItemListTabState createState() => _ItemListTabState();
}

class _ItemListTabState extends State<ItemListTab> {
  Map<int, InputComponents> _allGroups = {};
  final List<InputComponents> _shownGroups = [];
  late ScrollController _scrollController;
  final Map<int, Servant> _coinSvtMap = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    for (final id in [Items.qpId, ...widget.items]) {
      _allGroups[id] = InputComponents(
        data: id,
        focusNode: FocusNode(
          debugLabel: 'FocusNode_$id',
          onKey: (node, event) {
            if (event.character == '\n' || event.character == '\t') {
              print('${jsonEncode(event.character)} - ${node.debugLabel}');
              moveToNext(node);
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
        ),
        controller: TextEditingController(),
      )..focusNode.attach(context);
    }

    // sort by item id
    for (final svt in db.gameData.servantsNoDup.values) {
      final coinId = svt.coin?.item.id;
      if (coinId != null) _coinSvtMap[coinId] = svt;
    }
  }

  void sort() {
    final sortedEntries = _allGroups.entries.toList();
    switch (widget.sortType) {
      case _ItemSortType.default_:
        if (widget.category == ItemCategory.coin) {
          sortedEntries.sort2((e) => _coinSvtMap[e.key]?.collectionNo ?? -1);
        } else if (widget.category == ItemCategory.other) {
          sortedEntries.sort2((e) => e.key);
        } else {
          sortedEntries.sort2((e) => e.key == Items.qpId
              ? -1
              : db.gameData.items[e.key]?.priority ?? e.key);
        }
        break;
      case _ItemSortType.id:
        sortedEntries.sort2((e) => e.key);
        break;
      case _ItemSortType.owned:
        sortedEntries.sort2((e) => e.key == Items.qpId
            ? double.negativeInfinity
            : db.curUser.items[e.key] ?? 0);
        break;
      case _ItemSortType.left:
        sortedEntries.sort2((e) => e.key == Items.qpId
            ? double.negativeInfinity
            : db.itemCenter.itemLeft[e.key] ?? 0);
        break;
    }
    _allGroups = Map.fromEntries(sortedEntries);
  }

  @override
  void dispose() {
    _allGroups.values.forEach((group) => group.dispose());
    _scrollController.dispose();
    super.dispose();
  }

  void unfocusAll() {
    _allGroups.values.forEach((group) => group.focusNode.unfocus());
  }

  @override
  void deactivate() {
    unfocusAll();
    super.deactivate();
  }

  void setAll999() {
    SimpleCancelOkDialog(
      content: const Text('Set All 999'),
      onTapOk: () {
        _shownGroups.forEach((group) {
          if (group.data != Items.qpId) {
            db.curUser.items[group.data] = 999;
          }
        });
        db.itemCenter.updateLeftItems();
      },
    ).showDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    sort();
    setTextController();
    List<WidgetBuilder> children = [];
    _shownGroups.clear();
    for (var group in _allGroups.values) {
      if (widget.editable) {
        if (!widget.filtered ||
            group.data == Items.qpId ||
            (db.itemCenter.itemLeft[group.data] ?? 0) < 0 ||
            group.focusNode.hasFocus) {
          _shownGroups.add(group);
          children.add((context) => buildItemTile(group));
        }
      } else {
        _shownGroups.add(group);
        children.add((context) => buildItemTileNonEdit(group));
      }
    }
    if (widget.showSet999 && widget.editable) {
      children.add((context) => Center(
            child: TextButton(
              onPressed: setAll999,
              child: const Text('  >>> SET ALL 999 <<<  '),
            ),
          ));
    }
    Widget listView = ListView.builder(
      controller: _scrollController,
      itemCount: children.length,
      itemBuilder: (context, index) => children[index](context),
    );
    return Column(children: [
      Expanded(child: listView),
      kDefaultDivider,
      SafeArea(child: buttonBar),
    ]);
  }

  Widget get buttonBar {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (PlatformU.isMobile)
            IconButton(
              onPressed: () {
                if (_shownGroups.isEmpty) return;
                int focused =
                    _shownGroups.indexWhere((e) => e.focusNode.hasFocus);
                if (focused >= 0) {
                  moveToNext(_shownGroups[focused].focusNode, true);
                } else {
                  FocusScope.of(context)
                      .requestFocus(_shownGroups.last.focusNode);
                }
              },
              icon: const Icon(Icons.keyboard_arrow_up),
              tooltip: 'Previous',
            ),
          if (PlatformU.isMobile)
            IconButton(
              onPressed: () {
                if (_shownGroups.isEmpty) return;
                int focused =
                    _shownGroups.indexWhere((e) => e.focusNode.hasFocus);
                if (focused >= 0) {
                  moveToNext(_shownGroups[focused].focusNode);
                } else {
                  FocusScope.of(context)
                      .requestFocus(_shownGroups.first.focusNode);
                }
              },
              icon: const Icon(Icons.keyboard_arrow_down),
              tooltip: 'Next',
            ),
          Flexible(
            child: Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calculate_outlined),
                label: Text(S.current.planning_free_quest_btn),
                style: ElevatedButton.styleFrom(),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  widget.onNavToCalculator();
                },
              ),
            ),
          ),
          CheckboxWithLabel(
            value: db.itemCenter.includingEvents,
            label: Text(S.current.event_title),
            onChanged: (v) {
              setState(() {
                // reset to true in initState or not?
                db.itemCenter.includingEvents =
                    v ?? db.itemCenter.includingEvents;
                db.itemCenter.updateLeftItems();
                setState(() {});
              });
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  void setTextController() {
    _allGroups.forEach((itemId, group) {
      // when will controller be null? should never
      if (group.controller != null) {
        if (group.focusNode.hasPrimaryFocus) {
          return;
        }
        final isQp = itemId == Items.qpId;
        final text = (db.curUser.items[itemId] ?? 0)
            .format(groupSeparator: isQp ? ',' : null, compact: false);
        final selection = group.controller!.value.selection;
        TextSelection? newSelection;
        if (selection.isValid) {
          newSelection = selection.copyWith(
            baseOffset: min(selection.baseOffset, text.length),
            extentOffset: min(selection.extentOffset, text.length),
          );
        }
        group.controller!.value = group.controller!.value
            .copyWith(text: text, selection: newSelection);
      }
    });
  }

  /// TextField behaves different from platforms
  ///
  /// Android: next call complete
  /// Android Emulator: catch "\n"&"\t", no complete or submit
  /// iOS: only move among the nodes already in viewport,
  ///       not the updated viewport by auto scroll
  /// Windows: catch "\t", enter = click listTile
  /// macOS: catch "\t", enter to complete and submit
  Widget buildItemTile(InputComponents group) {
    final itemId = group.data;
    bool isQp = itemId == Items.qpId;
    final coinOwner = _coinSvtMap[itemId];
    // update when text input
    bool enough = (db.itemCenter.itemLeft[itemId] ?? 0) >= 0;
    final highlightStyle =
        TextStyle(color: enough ? null : Theme.of(context).colorScheme.error);
    Widget textField = TextFormField(
      maxLength: isQp ? 20 : 5,
      controller: group.controller,
      focusNode: group.focusNode,
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(counterText: ''),
      // inputFormatters: [
      // FilteringTextInputFormatter.allow(RegExp(r'-?[\d,]*')),
      // if (itemKey == Item.qp) NumberInputFormatter(),
      // ],
      onChanged: (v) {
        if (v == '-' || v == '') {
          /// don't change '-' to '0' in [setTextController]
          db.curUser.items[itemId] = 0;
        } else {
          db.curUser.items[itemId] = int.tryParse(v.replaceAll(',', '')) ??
              db.curUser.items[itemId] ??
              0;
        }
        EasyDebounce.debounce(
          'item_list_edit',
          const Duration(milliseconds: 500),
          () {
            db.itemCenter.updateLeftItems();
            if (mounted) setState(() {});
          },
        );
      },
      onTap: () {
        // select all text at first tap
        if (!group.focusNode.hasFocus && group.controller != null) {
          group.controller!.selection = TextSelection(
              baseOffset: 0, extentOffset: group.controller!.text.length);
        }
      },
      onFieldSubmitted: (s) {
        print('onSubmit: ${group.focusNode.debugLabel}');
        // move scrollbar for ios
        if (PlatformU.isIOS) {
          final index = _shownGroups.indexOf(group);
          if (index < 0) return;
          final start = _scrollController.position.minScrollExtent,
              end = _scrollController.position.maxScrollExtent;
          final newOffset =
              _scrollController.offset + (end - start) / _shownGroups.length;
          _scrollController.animateTo(min(end, newOffset),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut);
        }
      },
      onEditingComplete: () {
        print('onComplete: ${group.focusNode.debugLabel}');
        moveToNext(group.focusNode);
      },
    );
    Widget title, subtitle;
    if (isQp) {
      title = Row(
        children: <Widget>[const Text('QP  '), Expanded(child: textField)],
      );
      final demand = (db.itemCenter.statSvtDemands[itemId] ?? 0)
              .format(compact: false, groupSeparator: ','),
          left = (db.itemCenter.itemLeft[itemId] ?? 0)
              .format(compact: false, groupSeparator: ',');
      subtitle = Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: AutoSizeText(
              '${S.current.item_total_demand}'
              ' $demand',
              maxLines: 1,
              minFontSize: 1,
              overflow: TextOverflow.visible,
            ),
          ),
          Expanded(
            flex: 1,
            child: AutoSizeText(
              '${S.current.item_left} $left',
              maxLines: 1,
              style: highlightStyle,
              minFontSize: 1,
              overflow: TextOverflow.visible,
            ),
          )
        ],
      );
    } else {
      int demandCount = db.itemCenter.statSvtDemands[itemId] ?? 0;
      int leftCount = db.itemCenter.itemLeft[itemId] ?? 0;
      if (coinOwner != null) {
        final mats = db.itemCenter
            .calcOneSvt(coinOwner, coinOwner.status.cur, coinOwner.curPlan)
            .all;
        demandCount = mats[itemId] ?? 0;
        leftCount = (db.curUser.items[itemId] ?? 0) - demandCount;
      }

      title = Row(
        children: <Widget>[
          Expanded(
            child: AutoSizeText(
              _coinSvtMap[itemId]?.lName.l ?? Item.getName(itemId),
              maxLines: 1,
            ),
          ),
          Text('  ${S.current.item_left}',
              style: const TextStyle(fontSize: 14)),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 36),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '  $leftCount',
                style: highlightStyle.copyWith(fontSize: 14),
                maxLines: 1,
              ),
            ),
          ),
        ],
      );
      subtitle = Row(
        children: <Widget>[
          Expanded(
            child: AutoSizeText(
              '${S.current.item_total_demand}  $demandCount',
              maxLines: 1,
            ),
          ),
          if (coinOwner == null) ...[
            Text(S.current.event_title, style: const TextStyle(fontSize: 14)),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 36),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '  ${db.itemCenter.statObtain[itemId] ?? 0}',
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ],
      );
    }
    if (kDebugMode && itemId != Items.qpId) {
      subtitle = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          subtitle,
          Text(itemId.toString(), textScaleFactor: 0.85),
        ],
      );
    }

    return ListTile(
      horizontalTitleGap: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      leading: Item.iconBuilder(
          context: context, item: null, icon: Item.getIcon(itemId), width: 48),
      title: title,
      focusNode: FocusNode(canRequestFocus: true, skipTraversal: true),
      subtitle: subtitle,
      trailing: isQp ? null : SizedBox(width: 64, child: textField),
      onTap: () {
        FocusScope.of(context).unfocus();
        router.popDetailAndPush(url: Routes.itemI(itemId));
      },
    );
  }

  Widget buildItemTileNonEdit(InputComponents group) {
    final itemId = group.data;
    return ListTile(
      horizontalTitleGap: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      leading: Item.iconBuilder(
          context: context, item: null, icon: Item.getIcon(itemId), width: 48),
      title: Text(Item.getName(itemId)),
      subtitle: Text('No. $itemId'),
      onTap: () {
        FocusScope.of(context).unfocus();
        router.popDetailAndPush(url: Routes.itemI(itemId));
      },
    );
  }

  void moveToNext(FocusNode node, [bool reversed = false]) {
    int dx = reversed ? -1 : 1;
    int curIndex = _shownGroups.indexWhere((group) => group.focusNode == node);
    int nextIndex = curIndex + dx;
    if (curIndex < 0 || nextIndex < 0 || nextIndex >= _shownGroups.length) {
      FocusScope.of(context).unfocus();
      return;
    }
    final nextGroup = _shownGroups[nextIndex];
    FocusScope.of(context).requestFocus(nextGroup.focusNode);
    // set selection at next frame, so that auto scroll to make focus visible
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      // next frame, the next node is primary focus
      nextGroup.controller!.selection = TextSelection(
          baseOffset: 0, extentOffset: nextGroup.controller!.text.length);
    });
  }
}
