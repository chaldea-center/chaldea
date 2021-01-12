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
      appBar: AppBar(leading: BackButton(), title: Text(widget.name)),
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
