import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/item_related_builder.dart';
import 'package:url_launcher/url_launcher.dart';

import 'event_base_page.dart';

class CampaignDetailPage extends StatefulWidget {
  final CampaignEvent event;

  const CampaignDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  _CampaignDetailPageState createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage>
    with EventBasePage {
  CampaignEvent get event => widget.event;

  CampaignPlan get plan =>
      db.curUser.events.campaignEventPlanOf(event.indexKey);

  List<Summon> _associatedSummons = [];

  @override
  void initState() {
    super.initState();
    db.gameData.summons.values.forEach((summon) {
      for (var eventName in summon.associatedEvents) {
        if (event.isSameEvent(eventName)) {
          _associatedSummons.add(summon);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final svt = db.gameData.servants[event.welfareServant];

    List<Widget> children = [];
    children.addAll(this.buildHeaders(context: context, event: event));
    children.add(db.streamBuilder((context) => TileGroup(children: [
          if (event.couldPlan)
            SwitchListTile.adaptive(
              title: Text(S.of(context).plan),
              value: plan.enabled,
              onChanged: (v) {
                plan.enabled = v;
                db.itemStat.updateEventItems();
              },
            ),
          if (event.grail2crystal > 0)
            SwitchListTile.adaptive(
              title: Text(S.of(context).rerun_event),
              subtitle: Text(
                  S.of(context).event_rerun_replace_grail(event.grail2crystal)),
              value: plan.rerun,
              onChanged: (v) {
                plan.rerun = v;
                db.notifyDbUpdate();
                setState(() {
                  // update grail and crystal num
                });
              },
            ),
          if (svt != null)
            ListTile(
              title: Text(LocalizedText.of(
                  chs: '活动从者', jpn: '配布サーヴァント', eng: 'Welfare Servant')),
              trailing: svt.iconBuilder(context: context),
            )
        ])));

    final Map<String, int> items = event.itemsWithRare(plan);
    if (items.isNotEmpty) {
      children.addAll([
        ListTile(title: Center(child: Text(S.current.item))),
        kDefaultDivider,
        buildClassifiedItemList(context: context, data: items)
      ]);
    }

    // summons
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
          event.localizedName,
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
                  launch(WikiUtil.mcFullLink(widget.event.indexKey));
                },
              )
            ],
          )
        ],
      ),
      body: ListView(children: children),
      floatingActionButton: event.couldPlan ? floatingActionButton : null,
    );
  }

  Widget get floatingActionButton {
    return FloatingActionButton(
      child: Icon(Icons.archive_outlined),
      tooltip: S.of(context).event_collect_items,
      onPressed: () {
        if (!plan.enabled) {
          showInformDialog(context, content: S.of(context).event_not_planned);
        } else {
          SimpleCancelOkDialog(
            title: Text(S.of(context).confirm),
            content: Text(S.of(context).event_collect_item_confirm),
            onTapOk: () {
              sumDict([db.curUser.items, event.getItems(plan)], inPlace: true);
              plan.enabled = false;
              db.itemStat.updateEventItems();
              setState(() {});
            },
          ).showDialog(context);
        }
      },
    );
  }
}
