import 'package:chaldea/components/components.dart';

class FreeCalcFilterDialog extends StatefulWidget {
  final GLPKParams params;

  const FreeCalcFilterDialog({Key? key, required this.params})
      : super(key: key);

  @override
  _FreeCalcFilterDialogState createState() => _FreeCalcFilterDialogState();
}

class _FreeCalcFilterDialogState extends State<FreeCalcFilterDialog> {
  @override
  Widget build(BuildContext context) {
    final params = widget.params;
    params.minCost = fixValidRange(params.minCost, 0, 19);
    if (!db.gameData.glpk.freeCounts.values.contains(params.maxColNum)) {
      params.maxColNum = -1;
    }
    return SimpleDialog(
      title: Text(S.of(context).settings_tab_name),
      children: [
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
        ListTile(
          title: Text(S.of(context).free_progress),
          trailing: DropdownButton<int>(
            value: params.maxColNum,
            items: [
              DropdownMenuItem(
                  value: -1, child: Text(S.of(context).free_progress_newest)),
              for (var entry in db.gameData.glpk.freeCounts.entries)
                DropdownMenuItem(value: entry.value, child: Text(entry.key)),
            ],
            onChanged: (v) =>
                setState(() => params.maxColNum = v ?? params.maxColNum),
          ),
        ),
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
                  db.gameData.freeQuests[key]?.localizedKey ?? key;
              return ListTile(
                title: Text(shownName),
                dense: true,
                trailing: IconButton(
                  icon: Icon(Icons.clear),
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
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        )
      ],
    );
  }
}
