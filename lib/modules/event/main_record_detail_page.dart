import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/common_builders.dart';
import 'package:url_launcher/url_launcher.dart';

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

  MainRecordPlan get plan =>
      db.curUser.events.mainRecordOf(widget.record.indexKey);
  final List<Summon> _associatedSummons = [];

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
    children.addAll(buildHeaders(context: context, event: record));
    children.addAll(buildQuests(context: context, event: record));
    children.addAll([
      const SizedBox(height: 8),
      db.streamBuilder(
        (context) => SwitchListTile.adaptive(
          title: Text(
            S.current.main_record_fixed_drop,
            textScaleFactor: 0.95,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          value: plan.drop,
          onChanged: (v) {
            plan.drop = v;
            db.itemStat.updateEventItems();
          },
        ),
      ),
      buildClassifiedItemList(context: context, data: widget.record.drops),
      const SizedBox(height: 8),
      db.streamBuilder(
        (context) => SwitchListTile.adaptive(
          title: Text(
            S.current.main_record_bonus,
            textScaleFactor: 0.95,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          value: plan.reward,
          onChanged: (v) {
            plan.reward = v;
            db.itemStat.updateEventItems();
          },
        ),
      ),
      buildClassifiedItemList(
          context: context, data: widget.record.rewardsWithRare),
    ]);

    children
        .addAll(buildSummons(context: context, summons: _associatedSummons));

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
                  launch(WikiUtil.mcFullLink(widget.record.indexKey));
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
      child: const Icon(Icons.archive_outlined),
      tooltip: S.of(context).event_collect_items,
      onPressed: () {
        final plan = db.curUser.events.mainRecordOf(widget.record.indexKey);
        if (!plan.enabled) {
          showInformDialog(context, content: S.of(context).event_not_planned);
        } else {
          SimpleCancelOkDialog(
            title: Text(S.of(context).confirm),
            content: Text(S.of(context).event_collect_item_confirm),
            onTapOk: () {
              Maths.sumDict([db.curUser.items, widget.record.getItems(plan)],
                  inPlace: true);
              plan
                ..drop = false
                ..reward = false;
              db.itemStat.updateEventItems();
              setState(() {});
            },
          ).showDialog(context);
        }
      },
    );
  }
}
