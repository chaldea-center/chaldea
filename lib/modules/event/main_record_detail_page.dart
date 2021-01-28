import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        title: AutoSizeText(record.localizedName, maxLines: 1),
        actions: [
          IconButton(
            icon: Icon(Icons.archive_outlined),
            tooltip: S.of(context).event_collect_items,
            onPressed: () {
              final plan = db.curUser.events.mainRecords[widget.name];
              final record = db.gameData.events.mainRecords[widget.name];
              if (plan == null || !plan.contains(true)) {
                showInformDialog(context,
                    content: S.of(context).event_not_planned);
              } else {
                SimpleCancelOkDialog(
                  title: Text(S.of(context).confirm),
                  content: Text(S.of(context).event_collect_item_confirm),
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
          if (record.bannerUrl?.isNotEmpty == true)
            GestureDetector(
              onTap: () => jumpToExternalLinkAlert(
                  url: mooncellFullLink(widget.name), name: 'Mooncell'),
              child: CachedNetworkImage(imageUrl: record.bannerUrl),
            ),
          ListTile(title: Text(S.of(context).main_record_fixed_drop)),
          buildClassifiedItemList(
              context: context, data: record.drops, onTap: _onTap),
          ListTile(title: Text(S.of(context).main_record_bonus)),
          buildClassifiedItemList(
              context: context, data: record.rewardsWithRare, onTap: _onTap)
        ],
      ),
    );
  }
}
