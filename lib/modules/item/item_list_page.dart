import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/drop_calculator/drop_calculator_page.dart';
import 'package:chaldea/modules/shared/list_page_share.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'item_detail_page.dart';

class ItemListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ItemListPageState();
}

class ItemListPageState extends State<ItemListPage>
    with SingleTickerProviderStateMixin {
  bool filtered = false;
  final List<int> categories = [1, 2, 3];
  late TabController _tabController;
  late List<TextEditingController> _itemRedundantControllers;

  @override
  void deactivate() {
    super.deactivate();
    _tabController.dispose();
    db.saveUserData();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _itemRedundantControllers = List.generate(
        3,
        (index) => TextEditingController(
            text: db.userData.itemAbundantValue[index].toString()));
    db.itemStat.update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).item_title),
        leading: MasterBackButton(),
        titleSpacing: 0,
        actions: <Widget>[
          buildSwitchPlanButton(
            context: context,
            onChange: (index) {
              db.curUser.curSvtPlanNo = index;
              db.itemStat.update();
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(Icons.low_priority),
            tooltip: S.of(context).priority,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ItemFilterDialog(),
              );
            },
          ),
          IconButton(
            icon: Icon(
                filtered ? Icons.check_circle : Icons.check_circle_outline),
            tooltip: S.of(context).item_only_show_lack,
            onPressed: () {
              FocusScope.of(context).unfocus();
              setState(() {
                filtered = !filtered;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.calculate),
            tooltip: S.of(context).drop_calculator,
            onPressed: () {
              FocusScope.of(context).unfocus();
              navToDropCalculator();
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: categories
              .map((category) => Tab(
                      text: [
                    'Unknown',
                    S.of(context).item_category_usual,
                    S.of(context).item_category_gems,
                    S.of(context).item_category_ascension
                  ][category]))
              .toList(),
          onTap: (_) {
            FocusScope.of(context).unfocus();
          },
        ),
      ),
      body: TabBarView(
        // mostly, we focus on category 1 tab
        physics: AppInfo.isMobile ? null : NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: List.generate(
          categories.length,
          (index) => ItemListTab(
            category: categories[index],
            filtered: filtered,
            showSet999: true,
          ),
        ),
      ),
    );
  }

  void navToDropCalculator() {
    Map<String, int> _getObjective() {
      Map<String, int> objective = {};
      db.itemStat.leftItems.forEach((itemKey, value) {
        final rarity = db.gameData.items[itemKey]?.rarity ?? -1;
        if (rarity > 0 && rarity <= 3) {
          value -= db.userData.itemAbundantValue[rarity - 1];
        }
        if (db.gameData.glpk.rowNames.contains(itemKey) && value < 0) {
          objective[itemKey] = -value;
        }
      });
      return objective;
    }

    SimpleCancelOkDialog(
      title: Text(S.of(context).item_exceed),
      content: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (int index = 0; index < 3; index++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text([
                  S.current.copper,
                  S.current.silver,
                  S.current.gold
                ][index]),
                SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _itemRedundantControllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(isDense: true),
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
        Timer(Duration(milliseconds: 500), () {
          SplitRoute.push(
            context: context,
            popDetail: true,
            builder: (context, _) =>
                DropCalculatorPage(objectiveCounts: _getObjective()),
          );
        });
      },
      actions: [
        TextButton(
          onPressed: () {
            _itemRedundantControllers.forEach((e) => e.text = '');
            db.userData.itemAbundantValue
                .fillRange(0, db.userData.itemAbundantValue.length, 0);
          },
          child: Text(S.of(context).clear),
        )
      ],
    ).show(context);
  }
}

class ItemFilterDialog extends StatefulWidget {
  @override
  _ItemFilterDialogState createState() => _ItemFilterDialogState();
}

class _ItemFilterDialogState extends State<ItemFilterDialog> {
  @override
  Widget build(BuildContext context) {
    final priorityFilter = db.userData.svtFilter.priority;
    return AlertDialog(
      title: Text(S.of(context).priority),
      actions: [
        TextButton(
            onPressed: () {
              setState(() {
                priorityFilter.reset();
              });
              db.itemStat.updateSvtItems();
            },
            child: Text(S.of(context).clear.toUpperCase())),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(S.of(context).confirm.toUpperCase()),
        )
      ],
      contentPadding: EdgeInsets.symmetric(horizontal: 6),
      content: Container(
        // constraints: BoxConstraints(maxWidth: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            int priority = 5 - index;
            bool checked = priorityFilter.options[priority.toString()] ?? false;
            return CheckboxListTile(
              value: checked,
              title: Text('${S.current.priority} $priority'),
              controlAffinity: ListTileControlAffinity.leading,
              // dense: true,
              onChanged: (v) {
                setState(() {
                  priorityFilter.options[priority.toString()] = v!;
                });
                db.itemStat.updateSvtItems();
              },
            );
          }),
        ),
      ),
    );
  }
}

class InputComponents<T> {
  T data;
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
  final int category;
  final bool filtered;
  final bool showSet999;

  const ItemListTab({
    Key? key,
    required this.category,
    this.filtered = false,
    this.showSet999 = false,
  }) : super(key: key);

  @override
  _ItemListTabState createState() => _ItemListTabState();
}

class _ItemListTabState extends State<ItemListTab> {
  Map<Item, InputComponents<Item>> _allGroups = {};
  List<InputComponents<Item>> _shownGroups = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    db.gameData.items.forEach((key, item) {
      if (item.category == widget.category && key != Item.qp) {
        _allGroups[item] = InputComponents(
          data: item,
          focusNode: FocusNode(
              debugLabel: 'FocusNode_$item',
              onKey: (node, event) {
                if (event.character == '\n' || event.character == '\t') {
                  print('${jsonEncode(event.character)} - ${node.debugLabel}');
                  moveToNext(node);
                  return true;
                }
                return false;
              }),
          controller: TextEditingController(),
        );
      }
    });
    // sort by item id
    final sortedEntries = _allGroups.entries.toList()
      ..sort((a, b) => a.key.id - b.key.id);
    // always show QP at top
    sortedEntries.insert(
        0,
        MapEntry(
          db.gameData.items[Item.qp]!,
          InputComponents(
              data: db.gameData.items[Item.qp]!,
              focusNode: FocusNode(),
              controller: TextEditingController()),
        ));
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
    db.saveUserData();
    super.deactivate();
  }

  void setAll999() {
    SimpleCancelOkDialog(
      content: Text('本页所有素材均设为999'),
      onTapOk: () {
        _shownGroups.forEach((group) {
          if (group.data.name != Item.qp)
            db.curUser.items[group.data.name] = 999;
        });
        db.itemStat.updateLeftItems();
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget listView = db.streamBuilder((context) {
      setTextController();
      List<Widget> children = [];
      _shownGroups.clear();
      for (var group in _allGroups.values) {
        if (!widget.filtered ||
            group.data.name == Item.qp ||
            (db.itemStat.leftItems[group.data.name] ?? 0) < 0) {
          _shownGroups.add(group);
          children.add(buildItemTile(group));
        }
      }
      if (widget.showSet999) {
        children.add(Center(
          child: TextButton(
            onPressed: setAll999,
            child: Text('  >>> SET ALL 999 <<<  '),
          ),
        ));
      }
      Widget _listView = ListView.separated(
        controller: _scrollController,
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
        itemCount: children.length,
      );
      return Scrollbar(controller: _scrollController, child: _listView);
    });
    Widget? actionBar;
    // TODO: not shown actually
    // keyboard is shown and mobile view, cannot detect floating keyboard
    if (MediaQuery.of(context).viewInsets.bottom > 20 &&
        (Platform.isIOS || Platform.isAndroid)) {
      actionBar = Row(
        children: [
          IconButton(
            onPressed: () {
              int focused =
                  _shownGroups.indexWhere((e) => e.focusNode.hasFocus);
              if (focused >= 0) {
                moveToNext(_shownGroups[focused].focusNode, true);
              }
            },
            icon: Icon(Icons.keyboard_arrow_up, color: Colors.grey),
          ),
          IconButton(
            onPressed: () {
              int focused =
                  _shownGroups.indexWhere((e) => e.focusNode.hasFocus);
              if (focused >= 0) {
                moveToNext(_shownGroups[focused].focusNode);
              }
            },
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          )
        ],
      );
    }
    return actionBar == null
        ? listView
        : Column(children: [Expanded(child: listView), actionBar]);
  }

  void setTextController() {
    _allGroups.forEach((item, group) {
      // when will controller be null? should never
      if (group.controller != null) {
        final text = formatNumber(db.curUser.items[item.name] ?? 0,
            groupSeparator: item.name == Item.qp ? ',' : null);
        if (text == '0' &&
            group.focusNode.hasFocus &&
            (group.controller!.text == '-' || group.controller!.text == '')) {
          // don't set '-' to '0'
        } else {
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
    final itemKey = group.data.name;
    bool isQp = itemKey == Item.qp;

    // update when text input
    bool enough = (db.itemStat.leftItems[itemKey] ?? 0) >= 0;
    final highlightStyle = TextStyle(color: enough ? null : Colors.redAccent);
    Widget textField = TextField(
      maxLength: isQp ? 20 : 5,
      controller: group.controller,
      focusNode: group.focusNode,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.numberWithOptions(signed: true),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(counterText: ''),
      // inputFormatters: [
      // FilteringTextInputFormatter.allow(RegExp(r'-?[\d,]*')),
      // if (itemKey == Item.qp) NumberInputFormatter(),
      // ],
      onChanged: (v) {
        if (v == '-' || v == '') {
          /// don't change '-' to '0' in [setTextController]
          db.curUser.items[itemKey] = 0;
        } else {
          db.curUser.items[itemKey] = int.tryParse(v.replaceAll(',', '')) ??
              db.curUser.items[itemKey] ??
              0;
        }
        db.itemStat.updateLeftItems();
        // setState2(() {});
      },
      onTap: () {
        // select all text at first tap
        if (!group.focusNode.hasFocus && group.controller != null) {
          group.controller!.selection = TextSelection(
              baseOffset: 0, extentOffset: group.controller!.text.length);
        }
      },
      onSubmitted: (s) {
        print('onSubmit: ${group.focusNode.debugLabel}');
      },
      onEditingComplete: () {
        print('onComplete: ${group.focusNode.debugLabel}');
        moveToNext(group.focusNode);
      },
    );
    Widget title, subtitle;
    if (isQp) {
      title = Row(
        children: <Widget>[Text(itemKey + '  '), Expanded(child: textField)],
      );
      subtitle = Row(
        children: <Widget>[
          Expanded(
              flex: 1,
              child: AutoSizeText(
                '${S.current.item_total_demand}'
                ' ${formatNumber(db.itemStat.svtItems[itemKey])}',
                maxLines: 1,
              )),
          Expanded(
              flex: 1,
              child: AutoSizeText(
                '${S.current.item_left} ${formatNumber(db.itemStat.leftItems[itemKey])}',
                maxLines: 1,
                style: highlightStyle,
                minFontSize: 10,
              ))
        ],
      );
    } else {
      title = Row(
        children: <Widget>[
          Expanded(
            child: AutoSizeText(
              Item.localizedNameOf(itemKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(S.of(context).item_left, style: TextStyle(fontSize: 14)),
          SizedBox(
              width: 36,
              child: Align(
                alignment: Alignment.centerRight,
                child: AutoSizeText(db.itemStat.leftItems[itemKey].toString(),
                    minFontSize: 6,
                    maxFontSize: 14,
                    style: highlightStyle,
                    maxLines: 1),
              )),
        ],
      );
      List<int> _countsInSubTitle = db.itemStat.svtItemDetail.planItemCounts
          .valuesIfGrail(itemKey)
          .map((e) => e[itemKey] ?? 0)
          .toList();
      subtitle = Row(
        children: <Widget>[
          Expanded(
            child: AutoSizeText(
              '${db.itemStat.svtItems[itemKey]}'
              '(${_countsInSubTitle.join("/")})',
              maxLines: 1,
            ),
          ),
          Text(S.of(context).event_title, style: TextStyle(fontSize: 14)),
          SizedBox(
              width: 36,
              child: Align(
                alignment: Alignment.centerRight,
                child: AutoSizeText(
                    (db.itemStat.eventItems[itemKey] ?? 0).toString(),
                    minFontSize: 6,
                    maxFontSize: 14,
                    maxLines: 1),
              )),
        ],
      );
    }

    return ListTile(
      onTap: () {
        FocusScope.of(context).unfocus();
        SplitRoute.push(
          context: context,
          builder: (context, _) => ItemDetailPage(itemKey: itemKey),
          popDetail: true,
        );
      },
      horizontalTitleGap: 8,
      contentPadding: EdgeInsets.symmetric(horizontal: 6),
      leading: db.getIconImage(itemKey, width: 55),
      title: title,
      focusNode: FocusNode(canRequestFocus: true, skipTraversal: true),
      subtitle: subtitle,
      trailing: isQp ? null : SizedBox(width: 50, child: textField),
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
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      // next frame, the next node is primary focus
      nextGroup.controller!.selection = TextSelection(
          baseOffset: 0, extentOffset: nextGroup.controller!.text.length);
    });
  }
}
