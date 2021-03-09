//@dart=2.12
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/shared/item_related_builder.dart';

class MainRecordDetailPage extends StatefulWidget {
  final MainRecord record;

  const MainRecordDetailPage({Key? key, required this.record})
      : super(key: key);

  @override
  _MainRecordDetailPageState createState() => _MainRecordDetailPageState();
}

class _MainRecordDetailPageState extends State<MainRecordDetailPage> {
  List<bool> get plan => db.curUser.events.mainRecordOf(widget.record.indexKey);

  @override
  Widget build(BuildContext context) {
    final _onTap = (String itemKey) => SplitRoute.push(
        context: context,
        builder: (context, _) => ItemDetailPage(itemKey: itemKey));
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: AutoSizeText(widget.record.localizedName, maxLines: 1),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.archive_outlined),
            tooltip: S.of(context).event_collect_items,
            onPressed: () {
              final plan =
                  db.curUser.events.mainRecordOf(widget.record.indexKey);
              if (!plan.contains(true)) {
                showInformDialog(context,
                    content: S.of(context).event_not_planned);
              } else {
                SimpleCancelOkDialog(
                  title: Text(S.of(context).confirm),
                  content: Text(S.of(context).event_collect_item_confirm),
                  onTapOk: () {
                    sumDict([db.curUser.items, widget.record.getItems(plan)],
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
          if (widget.record.bannerUrl?.isNotEmpty == true)
            GestureDetector(
              onTap: () => jumpToExternalLinkAlert(
                  url: MooncellUtil.fullLink(widget.record.indexKey),
                  name: 'Mooncell'),
              child: CachedImage(
                imageUrl: widget.record.bannerUrl,
                connectivity: db.connectivity,
                downloadEnabled: db.userData.downloadEnabled,
                placeholder: (_, __) => Container(),
              ),
            ),
          db.streamBuilder(
            (context) => SwitchListTile.adaptive(
              title: Text(S.of(context).main_record_fixed_drop),
              value: plan[0],
              onChanged: (v) {
                setState(() {
                  plan[0] = v;
                });
                db.itemStat.updateEventItems();
              },
            ),
          ),
          buildClassifiedItemList(
              context: context, data: widget.record.drops, onTap: _onTap),
          db.streamBuilder(
            (context) => SwitchListTile.adaptive(
              title: Text(S.of(context).main_record_bonus),
              value: plan[1],
              onChanged: (v) {
                setState(() {
                  plan[1] = v;
                });
                db.itemStat.updateEventItems();
              },
            ),
          ),
          buildClassifiedItemList(
            context: context,
            data: widget.record.rewardsWithRare,
            onTap: _onTap,
          )
        ],
      ),
    );
  }
}
