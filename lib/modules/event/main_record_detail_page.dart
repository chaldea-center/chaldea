import 'package:auto_size_text/auto_size_text.dart';
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
    final _onTap =
        (String itemKey) => SplitRoute.push(context, builder: (context) => ItemDetailPage(itemKey));
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: Text(widget.name)),
      body: ListView(
        children: <Widget>[
          CustomTile(
            subtitle: AutoSizeText(
              '*通关奖励于"主线关卡通关声援活动"实装（白情之后）',
              maxLines: 1,
            ),
          ),
          Divider(
            height: 1,
          ),
          ListTile(title: Text('固定掉落')),
          buildClassifiedItemList(data: record.drops, onTap: _onTap),
          ListTile(title: Text('通关奖励')),
          buildClassifiedItemList(data: record.rewards, onTap: _onTap)
        ],
      ),
    );
  }
}
