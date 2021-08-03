import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/item_related_builder.dart';

import 'event_base_page.dart';

class MainRecordDetailPage extends StatefulWidget {
  final MainRecord record;

  const MainRecordDetailPage({Key? key, required this.record})
      : super(key: key);

  @override
  _MainRecordDetailPageState createState() => _MainRecordDetailPageState();
}

class _MainRecordDetailPageState extends State<MainRecordDetailPage>
    with EventBasePage {
  MainRecord get record => widget.record;

  List<bool> get plan => db.curUser.events.mainRecordOf(widget.record.indexKey);
  List<Summon> _associatedSummons = [];

  @override
  void initState() {
    super.initState();
    db.gameData.summons.values.forEach((summon) {
      for (var eventName in summon.associatedEvents) {
        if (record.isSameEvent(eventName)) {
          _associatedSummons.add(summon);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.addAll(this.buildHeaders(context: context, event: record));

    children.addAll([
      kDefaultDivider,
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
      buildClassifiedItemList(context: context, data: widget.record.drops),
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
          context: context, data: widget.record.rewardsWithRare),
    ]);

    children.addAll(
        this.buildSummons(context: context, summons: _associatedSummons));
    children.add(SizedBox(
      height: 72,
      child: Center(
        child: Text(
          '.',
          style: Theme.of(context).textTheme.caption,
        ),
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: AutoSizeText(
          widget.record.localizedName,
          maxLines: 1,
          overflow: TextOverflow.fade,
        ),
        titleSpacing: 0,
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(S.current.jump_to('Mooncell')),
                onTap: () {
                  jumpToExternalLinkAlert(
                    url: WikiUtil.mcFullLink(widget.record.indexKey),
                    name: 'Mooncell',
                  );
                },
              )
            ],
          )
        ],
      ),
      body: ListView(children: children),
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
