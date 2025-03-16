import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/item/item_select.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/recognizer.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class ItemResultTab extends StatefulWidget {
  final ItemResult? result;
  final bool viewMode;

  const ItemResultTab({super.key, required this.result, this.viewMode = false});

  @override
  State<ItemResultTab> createState() => _ItemResultTabState();
}

class _ItemResultTabState extends State<ItemResultTab> with ScrollControllerMixin {
  final Map<int, TextEditingController> _controllers = {};
  ItemResult get result => widget.result!;
  @override
  Widget build(BuildContext context) {
    if (widget.result == null) return const SizedBox();

    List<Widget> children = [];
    int countUnknown = 0, countDup = 0, countSelected = 0, countValid = 0;
    Map<int, List<ItemDetail>> items = {};
    for (final detail in result.details) {
      items.putIfAbsent(detail.itemId, () => []).add(detail);
    }
    for (final itemList in items.values) {
      itemList.sort2((e) => -e.score);
      final selected = itemList.firstWhereOrNull((e) => e.checked);
      if (selected != null) {
        for (final itemDetail in itemList) {
          itemDetail.checked = itemDetail == selected;
        }
      }
    }
    final keys = items.keys.toList();
    keys.sort2((e) => db.gameData.items[e]?.priority ?? -1);
    countUnknown = items[-1]?.length ?? 0;
    countValid = keys.where((e) => e > 0).length;
    countSelected = items.values.where((itemList) => itemList.any((e) => e.checked && e.itemId > 0)).length;
    countDup = result.details.length - countUnknown - countValid;

    for (final itemId in keys) {
      final itemList = items[itemId]!;
      for (final item in itemList) {
        children.add(
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: _buildDetailRow(item)),
        );
      }
    }

    return Column(
      children: [
        ListTile(
          title: Text(
            S.current.recognizer_result_count(countUnknown, countDup, countValid, result.details.length, countSelected),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          ),
        ),
        if (!widget.viewMode) SafeArea(child: buttonBar),
      ],
    );
  }

  Widget _buildDetailRow(ItemDetail item) {
    final _ctrl = _controllers.putIfAbsent(item.hashCode, () => TextEditingController());
    if (_ctrl.text != item.count.toString()) {
      _ctrl.text = item.count.toString();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        item.imgThumb == null
            ? const SizedBox(width: 56, height: 56)
            : Image.memory(item.imgThumb!, width: 56, height: 48),
        const SizedBox(width: 8),
        Item.iconBuilder(context: context, item: null, itemId: item.itemId, width: 48),
        Expanded(
          child: TextButton(
            onPressed: () {
              if (widget.viewMode) return;
              router.push(
                child: ItemSelectPage(
                  onSelected: (v) {
                    item.itemId = v;
                    if (result.details.any((e) => e != item && e.itemId == v)) {
                      item.checked = false;
                    }
                    if (mounted) setState(() {});
                  },
                ),
              );
            },
            child: Text(
              Item.getName(item.itemId),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(color: item.valid && item.checked ? null : Theme.of(context).colorScheme.error),
            ),
          ),
        ),
        const SizedBox(width: 8),
        item.imgNum == null ? const SizedBox(width: 56) : Image.memory(item.imgNum!, width: 56),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: TextFormField(
            controller: _ctrl,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) {
              final count = int.tryParse(v);
              if (count != null) item.count = count;
              setState(() {});
            },
          ),
        ),
        Checkbox(
          value: item.checked,
          onChanged:
              item.valid
                  ? (v) {
                    if (v == true) {
                      for (final itemDetail in result.details) {
                        if (itemDetail.itemId == item.itemId && itemDetail.valid) {
                          itemDetail.checked = itemDetail == item;
                        }
                      }
                    } else if (v == false) {
                      item.checked = false;
                    }
                    setState(() {});
                  }
                  : null,
        ),
      ],
    );
  }

  Widget get buttonBar {
    return OverflowBar(
      alignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: widget.result?.details.isNotEmpty == true ? _doImportResult : null,
          child: Text(S.current.update),
        ),
      ],
    );
  }

  void _doImportResult() {
    SimpleConfirmDialog(
      title: Text(S.current.import_screenshot_update_items),
      content: Text(S.current.import_screenshot_hint),
      confirmText: S.current.update,
      onTapOk: () {
        for (final detail in result.details) {
          if (detail.checked) {
            db.curUser.items[detail.itemId] = detail.count;
          }
        }
        db.itemCenter.updateLeftItems();
        db.saveUserData();
        EasyLoading.showSuccess(S.current.import_data_success);
      },
    ).showDialog(context);
  }
}
