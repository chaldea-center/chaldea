import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class FreeCalcFilterDialog extends StatefulWidget {
  final FreeLPParams params;

  const FreeCalcFilterDialog({super.key, required this.params});

  @override
  _FreeCalcFilterDialogState createState() => _FreeCalcFilterDialogState();
}

class _FreeCalcFilterDialogState extends State<FreeCalcFilterDialog> {
  @override
  Widget build(BuildContext context) {
    final params = widget.params;
    params.minCost = params.minCost.clamp2(0, 19);
    final wars = db.gameData.mainStories.values.where((e) => e.quests.any((q) => q.isMainStoryFree)).toList();
    wars.sort2((e) => -e.id);
    NiceWar? progress = wars.firstWhereOrNull((war) => war.id == params.progress);
    return SimpleDialog(
      title: Text(S.current.settings_tab_name),
      children: [
        SwitchListTile.adaptive(
          dense: true,
          value: true, // params.use6th,
          title: Text(S.current.new_drop_data_6th),
          subtitle: const Text('6th Anniversary(~2.5.5)'),
          controlAffinity: ListTileControlAffinity.trailing,
          onChanged: null,
          // onChanged: (v) {
          //   setState(() {
          //     params.use6th = v;
          //   });
          // },
        ),
        ListTile(
          dense: true,
          title: Text(S.current.free_progress),
          trailing: DropdownButton<NiceWar?>(
            isDense: true,
            value: progress,
            alignment: AlignmentDirectional.centerEnd,
            items: [
              DropdownMenuItem(
                value: null,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(S.current.free_progress_newest, textScaleFactor: 0.8),
                ),
              ),
              for (final war in wars)
                DropdownMenuItem(
                  value: war,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(war.lShortName, textScaleFactor: 0.8),
                  ),
                )
            ],
            onChanged: (v) => setState(() => params.progress = v?.id ?? -1),
          ),
        ),
        ListTile(
          dense: true,
          title: Text(S.current.drop_calc_min_ap),
          trailing: DropdownButton<int>(
            isDense: true,
            value: params.minCost,
            items: List.generate(20, (i) => DropdownMenuItem(value: i, child: Text(i.toString()))),
            onChanged: (v) => setState(() => params.minCost = v ?? params.minCost),
          ),
        ),
        ListTile(
          dense: true,
          title: Text(S.current.plan_objective),
          trailing: DropdownButton<bool>(
            isDense: true,
            value: params.costMinimize,
            items: [
              DropdownMenuItem(value: true, child: Text(S.current.ap, textScaleFactor: 0.9)),
              DropdownMenuItem(value: false, child: Text(S.current.counts, textScaleFactor: 0.9))
            ],
            onChanged: (v) => setState(() => params.costMinimize = v ?? params.costMinimize),
          ),
        ),
        ListTile(
          dense: true,
          title: Text(S.current.efficiency_type),
          trailing: DropdownButton<bool>(
            isDense: true,
            value: params.useAP20,
            items: [
              DropdownMenuItem(value: true, child: Text(S.current.efficiency_type_ap, textScaleFactor: 0.9)),
              DropdownMenuItem(value: false, child: Text(S.current.efficiency_type_drop, textScaleFactor: 0.9))
            ],
            onChanged: (v) => setState(() => params.useAP20 = v ?? params.useAP20),
          ),
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: params.dailyCostHalf,
          title: Text(S.current.event_ap_cost_half),
          subtitle: Text(Transl.warNames('曜日クエスト').l),
          controlAffinity: ListTileControlAffinity.trailing,
          onChanged: (v) {
            setState(() {
              params.dailyCostHalf = v;
            });
          },
        ),
        SimpleAccordion(
          headerBuilder: (context, _) => ListTile(
            dense: true,
            title: Text(S.current.blacklist),
            trailing: Text(params.blacklist.length.toString()),
          ),
          contentBuilder: (context) => Column(
            children: divideTiles(params.blacklist.map((key) {
              String shownName = db.gameData.quests[key]?.lDispName ?? 'Quest $key';
              return ListTile(
                title: Text(shownName),
                dense: true,
                trailing: IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  tooltip: S.current.remove_from_blacklist,
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
