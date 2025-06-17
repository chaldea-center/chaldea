import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widgets.dart';

class ItemWeightEditPage extends StatefulWidget {
  final MasterDataManager mstData;
  final List<int> itemIds;
  final RandomMissionOption option;
  const ItemWeightEditPage({super.key, required this.mstData, required this.itemIds, required this.option});

  @override
  State<ItemWeightEditPage> createState() => _ItemWeightEditPageState();
}

class _ItemWeightEditPageState extends State<ItemWeightEditPage> {
  @override
  Widget build(BuildContext context) {
    final allItemIds = {...widget.itemIds, ...widget.option.itemWeights.keys};
    return Scaffold(
      appBar: AppBar(title: Text('Item Weight')),
      body: ListView(
        children: [
          for (final itemId in allItemIds) buildOne(itemId),
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                """权重:
w≤0: 可被取消任务
0<w<2: 常规权重，可有可无
2≤w: 重点素材，优先获取该部分素材的任务
默认权重：
QP/友情点/魔力棱镜: 0
常规素材: 1
"""
                    .trim(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOne(int itemId) {
    return ListTile(
      leading: Item.iconBuilder(
        context: context,
        item: null,
        itemId: itemId,
        text: [
          widget.mstData.getItemOrSvtNum(itemId).format(),
          (db.itemCenter.itemLeft[itemId] ?? 0).format(),
        ].join('\n'),
      ),
      title: Text(Item.getName(itemId)),
      trailing: TextButton(
        onPressed: () {
          widget.option.itemWeights[itemId];
          InputCancelOkDialog(
            title: Item.getName(itemId),
            initValue: widget.option.getItemWeight(itemId).format(),
            keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
            validate: (s) => double.parse(s).isFinite,
            onSubmit: (s) {
              widget.option.itemWeights[itemId] = double.parse(s);
              if (mounted) setState(() {});
            },
          ).showDialog(context);
        },
        child: Text(widget.option.getItemWeight(itemId).toStringAsFixed(2)),
      ),
    );
  }
}
