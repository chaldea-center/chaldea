//@dart=2.12
import 'package:chaldea/components/components.dart';

class DropCalcFilterDialog extends StatefulWidget {
  final GLPKParams params;

  const DropCalcFilterDialog({Key? key, required this.params})
      : super(key: key);

  @override
  _DropCalcFilterDialogState createState() => _DropCalcFilterDialogState();
}

class _DropCalcFilterDialogState extends State<DropCalcFilterDialog> {
  @override
  Widget build(BuildContext context) {
    final params = widget.params;
    if (!db.gameData.glpk.freeCounts.values.contains(params.maxColNum)) {
      params.maxColNum = -1;
    }
    return SimpleDialog(
      title: Text(S.of(context).filter),
      children: [
        ListTile(
          title: Text(S.of(context).drop_calc_min_ap),
          trailing: DropdownButton<int>(
            value: params.minCost,
            items: List.generate(20,
                (i) => DropdownMenuItem(value: i, child: Text(i.toString()))),
            onChanged: (v) => setState(() => params.minCost = v),
          ),
        ),
        ListTile(
          title: Text('Free进度'),
          trailing: DropdownButton<int>(
            value: params.maxColNum,
            items: [
              DropdownMenuItem(value: -1, child: Text('日服')),
              for (var entry in db.gameData.glpk.freeCounts.entries)
                DropdownMenuItem(value: entry.value, child: Text(entry.key)),
            ],
            onChanged: (v) =>
                setState(() => params.maxColNum = v ?? params.maxColNum),
          ),
        ),
        ListTile(
          title: Text('规划目标'),
          trailing: DropdownButton<bool>(
            value: params.costMinimize,
            items: [
              DropdownMenuItem(value: true, child: Text(S.of(context).ap)),
              DropdownMenuItem(value: false, child: Text(S.of(context).counts))
            ],
            onChanged: (v) => setState(() => params.costMinimize = v),
          ),
        ),
        ListTile(
          title: Text('效率类型'),
          trailing: DropdownButton<bool>(
            value: params.useAP20,
            items: [
              DropdownMenuItem(value: true, child: Text('20AP效率')),
              DropdownMenuItem(value: false, child: Text('每场掉率'))
            ],
            onChanged: (v) => setState(() => params.useAP20 = v),
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
