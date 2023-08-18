import 'dart:math';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/recognizer.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SkillResultTab extends StatefulWidget {
  final bool isAppend;
  final SkillResult? result;
  final bool viewMode;

  const SkillResultTab({super.key, required this.isAppend, required this.result, this.viewMode = false});

  @override
  State<SkillResultTab> createState() => _SkillResultTabState();
}

class _SkillResultTabState extends State<SkillResultTab> with ScrollControllerMixin {
  SkillResult get result => widget.result!;

  @override
  Widget build(BuildContext context) {
    if (widget.result == null) return const SizedBox();

    List<Widget> children = [];
    int countUnknown = 0, countDup = 0, countSelected = 0, countValid = 0;
    Map<int, List<SkillDetail>> items = {};
    for (final detail in result.details) {
      items.putIfAbsent(detail.svtId, () => []).add(detail);
    }
    items.values.forEach((itemList) {
      itemList.sort2((e) => -e.score);
      final selected = itemList.firstWhereOrNull((e) => e.checked);
      if (selected != null) {
        itemList.forEach((e) {
          e.checked = e == selected;
        });
      }
    });
    final keys = items.keys.toList();
    keys.sort();
    countUnknown = items[-1]?.length ?? 0;
    countValid = keys.where((e) => e > 0).length;
    countSelected = items.values.where((itemList) => itemList.any((e) => e.valid && e.checked)).length;
    countDup = result.details.length - countUnknown - countValid;

    for (final itemId in keys) {
      final itemList = items[itemId]!;
      for (final item in itemList) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: _buildDetailRow(item),
        ));
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

  Widget _buildDetailRow(SkillDetail item) {
    final svt = db.gameData.servantsNoDup[item.svtId];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        item.imgThumb == null
            ? const SizedBox(width: 56, height: 56)
            : InkWell(
                child: Image.memory(item.imgThumb!, width: 56, height: 56),
                onTap: () {
                  SimpleCancelOkDialog(
                    content: Image.memory(item.imgThumb!, width: 200),
                    hideCancel: true,
                  ).showDialog(context);
                },
              ),
        const SizedBox(width: 8),
        svt?.iconBuilder(context: context, width: 48) ?? db.getIconImage(null, width: 48),
        Expanded(
          child: TextButton(
            onPressed: () {
              if (widget.viewMode) return;
              router.pushPage(ServantListPage(
                onSelected: (v) {
                  item.svtId = v.collectionNo;
                  if (result.details.any((e) => e != item && e.svtId == item.svtId)) {
                    item.checked = false;
                  }
                  if (mounted) setState(() {});
                },
              ), detail: false);
            },
            child: Text(
              '${item.svtId} - ${svt == null ? S.current.unknown : svt.lName.l}',
              style: TextStyle(
                color: item.valid && item.checked ? null : Theme.of(context).colorScheme.error,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ...divideTiles(
          [
            for (int index = 0; index < 3; index++)
              DropdownButton<int>(
                icon: const SizedBox(),
                value: item.skills[index],
                items: List.generate(12, (lv) {
                  return DropdownMenuItem(
                    value: lv - 1,
                    child: Text((lv - 1).toString()),
                  );
                }),
                onChanged: widget.viewMode
                    ? null
                    : (v) {
                        setState(() {
                          if (v != null && v >= 0) item.setSkill(index, v);
                        });
                      },
              ),
          ],
          divider: const Text(' / '),
        ),
        Checkbox(
          value: item.checked,
          onChanged: item.valid
              ? (v) {
                  if (v == true) {
                    result.details.forEach((e) {
                      if (e.svtId == item.svtId && e.valid) {
                        e.checked = e == item;
                      }
                    });
                  } else if (v == false) {
                    item.checked = false;
                  }
                  setState(() {});
                }
              : null,
        )
      ],
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: result.details.isNotEmpty ? _doImportResult : null,
          child: Text(S.current.update),
        ),
      ],
    );
  }

  void _doImportResult() {
    SimpleCancelOkDialog(
      title: Text(S.current.import_screenshot_update_items),
      content: Text(S.current.import_screenshot_hint),
      confirmText: S.current.update,
      onTapOk: () {
        for (final detail in result.details) {
          if (detail.valid && detail.checked) {
            final status = db.curUser.svtStatusOf(detail.svtId);
            // status.cur.ascension = 0;
            status.cur.favorite = true;
            if (widget.isAppend) {
              status.cur.appendSkills = List.of(detail.skills, growable: false);
            } else {
              status.cur.skills = List.of(detail.skills.map((e) => max(1, e)), growable: false);
            }
          }
        }
        db.itemCenter.updateSvts(all: true);
        db.saveUserData();
        EasyLoading.showSuccess(S.current.import_data_success);
      },
    ).showDialog(context);
  }
}
