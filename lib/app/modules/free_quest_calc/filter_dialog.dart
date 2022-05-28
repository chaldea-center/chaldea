import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class FreeCalcFilterDialog extends StatefulWidget {
  final FreeLPParams params;

  const FreeCalcFilterDialog({Key? key, required this.params})
      : super(key: key);

  @override
  _FreeCalcFilterDialogState createState() => _FreeCalcFilterDialogState();
}

class _FreeCalcFilterDialogState extends State<FreeCalcFilterDialog> {
  @override
  Widget build(BuildContext context) {
    final params = widget.params;
    params.minCost = params.minCost.clamp2(0, 19);
    final wars = db.gameData.mainStories.values
        .where((e) => e.quests.any((q) => q.isMainStoryFree))
        .toList();
    wars.sort2((e) => -e.id);
    NiceWar? progress =
        wars.firstWhereOrNull((war) => war.id == params.progress);
    return SimpleDialog(
      title: Text(S.of(context).settings_tab_name),
      children: [
        SwitchListTile.adaptive(
          value: params.use6th,
          title: const Text('New Drop Data'),
          subtitle: const Text('6th Anniversary(~2.5.5)'),
          controlAffinity: ListTileControlAffinity.trailing,
          onChanged: (v) {
            setState(() {
              params.use6th = v;
            });
          },
        ),
        ListTile(
          title: Text(S.of(context).free_progress),
          trailing: DropdownButton<NiceWar?>(
            value: progress,
            items: [
              DropdownMenuItem(
                value: null,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Text(S.current.free_progress_newest, maxLines: 1),
                ),
              ),
              for (final war in wars)
                DropdownMenuItem(
                  value: war,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(war.lShortName, maxLines: 1),
                  ),
                )
            ],
            onChanged: (v) => setState(() => params.progress = v?.id ?? -1),
          ),
        ),
        ListTile(
          title: Text(S.of(context).drop_calc_min_ap),
          trailing: DropdownButton<int>(
            value: params.minCost,
            items: List.generate(20,
                (i) => DropdownMenuItem(value: i, child: Text(i.toString()))),
            onChanged: (v) =>
                setState(() => params.minCost = v ?? params.minCost),
          ),
        ),
        // ListTile(
        //   title: Text(S.of(context).free_progress),
        //   trailing: DropdownButton<int>(
        //     value: params.maxColNum,
        //     items: [
        //       DropdownMenuItem(
        //           value: -1, child: Text(S.of(context).free_progress_newest)),
        //       for (var entry
        //           in params.sheet.freeCounts.entries.toList()
        //             ..sort((a, b) => b.value - a.value))
        //         DropdownMenuItem(value: entry.value, child: Text(entry.key)),
        //     ],
        //     onChanged: (v) =>
        //         setState(() => params.maxColNum = v ?? params.maxColNum),
        //   ),
        // ),
        ListTile(
          title: Text(S.of(context).plan_objective),
          trailing: DropdownButton<bool>(
            value: params.costMinimize,
            items: [
              DropdownMenuItem(value: true, child: Text(S.of(context).ap)),
              DropdownMenuItem(value: false, child: Text(S.of(context).counts))
            ],
            onChanged: (v) =>
                setState(() => params.costMinimize = v ?? params.costMinimize),
          ),
        ),
        ListTile(
          title: Text(S.of(context).efficiency_type),
          trailing: DropdownButton<bool>(
            value: params.useAP20,
            items: [
              DropdownMenuItem(
                  value: true, child: Text(S.of(context).efficiency_type_ap)),
              DropdownMenuItem(
                  value: false, child: Text(S.of(context).efficiency_type_drop))
            ],
            onChanged: (v) =>
                setState(() => params.useAP20 = v ?? params.useAP20),
          ),
        ),
        SimpleAccordion(
          headerBuilder: (context, _) => ListTile(
            title: Text(S.of(context).blacklist),
            trailing: Text(params.blacklist.length.toString()),
          ),
          contentBuilder: (context) => Column(
            children: divideTiles(params.blacklist.map((key) {
              String shownName =
                  db.gameData.getQuestPhase(key)?.lName.l ?? 'Quest $key';
              return ListTile(
                title: Text(shownName),
                dense: true,
                trailing: IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: S.of(context).remove_from_blacklist,
                  onPressed: () {
                    setState(() {
                      params.blacklist.remove(key);
                    });
                  },
                ),
              );
            })),
          ),
        ),
        Center(
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        )
      ],
    );
  }
}
