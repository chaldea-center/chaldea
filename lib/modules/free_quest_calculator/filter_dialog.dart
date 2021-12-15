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
    if (!params.dropRatesData.freeCounts.values.contains(params.maxColNum)) {
      params.maxColNum = -1;
    }
    return SimpleDialog(
      title: Text(S.of(context).settings_tab_name),
      children: [
        SwitchListTile.adaptive(
          value: params.use6th,
          title: Text(LocalizedText.of(
              chs: '新掉落数据', jpn: '改善されたドロップ', eng: 'New DropRate Data', kor: '새로운 드롭률 데이터')),
          subtitle: Text(LocalizedText.of(
              chs: '6周年(截至2.5.5)',
              jpn: '6周年(2.5.5まで)',
              eng: '6th Anniversary(as of 2.5.5)',
              kor: '6주년(페그오 2.5.5버전 이후)')),
          controlAffinity: ListTileControlAffinity.trailing,
          onChanged: (v) {
            setState(() {
              params.use6th = v;
            });
          },
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
        ListTile(
          title: Text(S.of(context).free_progress),
          trailing: DropdownButton<int>(
            value: params.maxColNum,
            items: [
              DropdownMenuItem(
                  value: -1, child: Text(S.of(context).free_progress_newest)),
              for (var entry
                  in params.dropRatesData.freeCounts.entries.toList()
                    ..sort((a, b) => b.value - a.value))
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
                  db.gameData.getFreeQuest(key)?.localizedKey ?? key;
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
