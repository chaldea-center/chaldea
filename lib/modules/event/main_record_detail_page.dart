import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/shared/item_related_builder.dart';
import 'package:chaldea/modules/summon/summon_detail_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainRecordDetailPage extends StatefulWidget {
  final MainRecord record;

  const MainRecordDetailPage({Key? key, required this.record})
      : super(key: key);

  @override
  _MainRecordDetailPageState createState() => _MainRecordDetailPageState();
}

class _MainRecordDetailPageState extends State<MainRecordDetailPage> {
  List<bool> get plan => db.curUser.events.mainRecordOf(widget.record.indexKey);
  List<Summon> _associatedSummons = [];

  @override
  void initState() {
    super.initState();
    db.gameData.summons.values.forEach((summon) {
      for (var eventName in summon.associatedEvents) {
        if (widget.record.isSameEvent(eventName)) {
          _associatedSummons.add(summon);
        }
      }
    });
  }

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
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'jump_mc',
                child: Text(S.current.jump_to('Mooncell')),
              )
            ],
            onSelected: (v) {
              if (v == 'jump_mc') {
                jumpToExternalLinkAlert(
                  url: MooncellUtil.fullLink(widget.record.indexKey),
                  name: 'Mooncell',
                );
              }
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          if (widget.record.lBannerUrl != null)
            GestureDetector(
              onTap: () => jumpToExternalLinkAlert(
                url: MooncellUtil.fullLink(widget.record.indexKey),
                name: 'Mooncell',
              ),
              child: CachedImage(
                imageUrl: widget.record.lBannerUrl,
                isMCFile: true,
                connectivity: db.connectivity,
                placeholder: (_, __) => AspectRatio(aspectRatio: 8 / 3),
              ),
            ),
          db.streamBuilder(
            (context) => SwitchListTile.adaptive(
              title: Text(S.of(context).main_record_fixed_drop),
              value: plan[0],
              onChanged: (v) {
                plan[0] = v;
                db.itemStat.updateEventItems();
              },
            ),
          ),
          kDefaultDivider,
          buildClassifiedItemList(
              context: context, data: widget.record.drops, onTap: _onTap),
          db.streamBuilder(
            (context) => SwitchListTile.adaptive(
              title: Text(S.of(context).main_record_bonus),
              value: plan[1],
              onChanged: (v) {
                plan[1] = v;
                db.itemStat.updateEventItems();
              },
            ),
          ),
          kDefaultDivider,
          buildClassifiedItemList(
            context: context,
            data: widget.record.rewardsWithRare,
            onTap: _onTap,
          ),
          if (_associatedSummons.isNotEmpty) ...[
            ListTile(
              // leading: Icon(Icons.double_arrow),
              // horizontalTitleGap: 0,
              title: Text(S.of(context).summon),
            ),
            TileGroup(
              children: _associatedSummons
                  .map((e) => ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.chessQueen,
                        color: Colors.blue,
                      ),
                      title: Text(e.localizedName),
                      horizontalTitleGap: 0,
                      onTap: () {
                        SplitRoute.push(
                          context: context,
                          builder: (_, __) => SummonDetailPage(summon: e),
                        );
                      }))
                  .toList(),
            ),
          ],
          SizedBox(
            height: 72,
            child: Center(
              child: Text(
                '.',
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget get floatingActionButton {
    return FloatingActionButton(
      // backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(160),
      child: Icon(Icons.archive_outlined),
      tooltip: S.of(context).event_collect_items,
      onPressed: () {
        final plan = db.curUser.events.mainRecordOf(widget.record.indexKey);
        if (!plan.contains(true)) {
          showInformDialog(context, content: S.of(context).event_not_planned);
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
          ).showDialog(context);
        }
      },
    );
  }
}
