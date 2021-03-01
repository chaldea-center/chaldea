//@dart=2.9
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/shared/item_related_builder.dart';

class MainRecordDetailPage extends StatefulWidget {
  final String name;

  const MainRecordDetailPage({Key key, @required this.name}) : super(key: key);

  @override
  _MainRecordDetailPageState createState() => _MainRecordDetailPageState();
}

class _MainRecordDetailPageState extends State<MainRecordDetailPage> {
  List<bool> plan;

  @override
  void initState() {
    super.initState();
    plan = db.curUser.events.mainRecordOf(widget.name);
  }

  @override
  Widget build(BuildContext context) {
    final record = db.gameData.events.mainRecords[widget.name];
    final _onTap = (String itemKey) => SplitRoute.push(
        context: context, builder: (context, _) => ItemDetailPage(itemKey));
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: AutoSizeText(record.localizedName, maxLines: 1),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.archive_outlined),
            tooltip: S.of(context).event_collect_items,
            onPressed: () {
              final plan = db.curUser.events.mainRecordOf(widget.name);
              final record = db.gameData.events.mainRecords[widget.name];
              if (!plan.contains(true)) {
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
              child: CachedImage(
                imageUrl: record.bannerUrl,
                connectivity: db.connectivity,
                downloadEnabled: db.userData.downloadEnabled,
                placeholder: (_, __) => Container(),
              ),
            ),
          SwitchListTile.adaptive(
            title: Text(S.of(context).main_record_fixed_drop),
            value: plan[0],
            onChanged: (v) {
              setState(() {
                plan[0] = v;
              });
              db.itemStat.updateEventItems();
            },
          ),
          buildClassifiedItemList(
              context: context, data: record.drops, onTap: _onTap),
          SwitchListTile.adaptive(
            title: Text(S.of(context).main_record_bonus),
            value: plan[1],
            onChanged: (v) {
              setState(() {
                plan[1] = v;
              });
              db.itemStat.updateEventItems();
            },
          ),
          buildClassifiedItemList(
              context: context, data: record.rewardsWithRare, onTap: _onTap)
        ],
      ),
    );
  }
}
