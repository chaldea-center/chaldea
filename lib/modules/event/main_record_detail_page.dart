import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/shared/item_related_builder.dart';

class MainRecordDetailPage extends StatefulWidget {
  final String name;

  const MainRecordDetailPage({Key key, this.name}) : super(key: key);

  @override
  _MainRecordDetailPageState createState() => _MainRecordDetailPageState();
}

class _MainRecordDetailPageState extends State<MainRecordDetailPage> {
  @override
  Widget build(BuildContext context) {
    final record = db.gameData.events.mainRecords[widget.name];
    final _onTap = (String itemKey) => SplitRoute.push(
        context: context, builder: (context, _) => ItemDetailPage(itemKey));
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: Icon(Icons.archive_outlined),
            tooltip: '收取素材',
            onPressed: () {
              final plan = db.curUser.events.mainRecords[widget.name];
              final record = db.gameData.events.mainRecords[widget.name];
              if (plan == null || !plan.contains(true)) {
                showInformDialog(context, content: '活动未列入规划');
              } else {
                SimpleCancelOkDialog(
                  title: Text('确定收取素材'),
                  content: Text('所有素材添加到素材仓库，并将该活动移出规划'),
                  onTapOk: () {
                    sumDict([db.curUser.items, record.getItems(plan)],
                        inPlace: true);
                    plan.fillRange(0, plan.length, false);
                    db.itemStat.updateEventItems();
                    setState(() {});
                  },
                ).show(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Divider(height: 1),
          ListTile(title: Text('固定掉落')),
          buildClassifiedItemList(
              context: context, data: record.drops, onTap: _onTap),
          ListTile(title: Text('通关奖励')),
          buildClassifiedItemList(
              context: context, data: record.rewards, onTap: _onTap)
        ],
      ),
    );
  }
}
