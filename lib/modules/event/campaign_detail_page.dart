import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/shared/item_related_builder.dart';
import 'package:chaldea/modules/summon/summon_detail_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CampaignDetailPage extends StatefulWidget {
  final CampaignEvent event;

  const CampaignDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  _CampaignDetailPageState createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage>
    with TickerProviderStateMixin {
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
    List<Widget> children = [];
    if (event.lBannerUrl != null)
      children.add(GestureDetector(
        onTap: () => jumpToExternalLinkAlert(
          url: WikiUtil.mcFullLink(widget.event.indexKey),
          name: 'Mooncell',
        ),
        child: CachedImage(
          imageUrl: event.lBannerUrl,
          isMCFile: true,
          placeholder: (_, __) => AspectRatio(aspectRatio: 8 / 3),
        ),
      ));
    children.add(ListTile(
      title: AutoSizeText(
        'JP: ${event.startTimeJp ?? '?'} ~ ${event.endTimeJp ?? '?'}\n'
        'CN: ${event.startTimeCn ?? '?'} ~ ${event.endTimeCn ?? '?'}',
        maxLines: 2,
      ),
    ));
    if (event.couldPlan) {
      children.add(db.streamBuilder(
        (context) => SwitchListTile.adaptive(
          title: Text(S.of(context).plan),
          value: plan.enable,
          onChanged: (v) {
            plan.enable = v;
            db.itemStat.updateEventItems();
          },
        ),
      ));
    }

    // 复刻
    if (event.grail2crystal > 0) {
      children.add(db.streamBuilder(
        (context) => SwitchListTile.adaptive(
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
      ));
    }

    final svt = db.gameData.servants[event.welfareServant];
    if (svt != null) {
      children.add(ListTile(
        title: Text(LocalizedText.of(
            chs: '活动从者', jpn: '配布サーヴァント', eng: 'Welfare Servant')),
        trailing: svt.iconBuilder(context: context),
      ));
    }

    final Map<String, int> items = event.itemsWithRare(plan);
    if (items.isNotEmpty) {
      children
        ..add(ListTile(
          leading: Icon(Icons.double_arrow),
          horizontalTitleGap: 0,
          title: Text(S.current.item),
        ))
        ..add(buildClassifiedItemList(
          context: context,
          data: items,
          onTap: (v) => SplitRoute.push(context, ItemDetailPage(itemKey: v)),
        ));
    }

    // summons
    if (_associatedSummons.isNotEmpty) {
      children
        ..add(ListTile(
          leading: Icon(Icons.double_arrow),
          horizontalTitleGap: 0,
          title: Text(S.of(context).summon),
        ))
        ..add(TileGroup(
          children: _associatedSummons
              .map((e) => ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.chessQueen,
                    color: Colors.blue,
                  ),
                  title: Text(e.localizedName),
                  horizontalTitleGap: 0,
                  onTap: () {
                    SplitRoute.push(context, SummonDetailPage(summon: e));
                  }))
              .toList(),
        ));
    }

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
                value: 'jump_mc',
                child: Text(S.current.jump_to('Mooncell')),
              )
            ],
            onSelected: (v) {
              if (v == 'jump_mc') {
                jumpToExternalLinkAlert(
                  url: WikiUtil.mcFullLink(widget.event.indexKey),
                  name: 'Mooncell',
                );
              }
            },
          )
        ],
      ),
      body: ListView(
        children: divideTiles(children),
        // padding: EdgeInsets.only(bottom: 72),
      ),
      floatingActionButton: event.couldPlan ? floatingActionButton : null,
    );
  }

  Widget get floatingActionButton {
    return FloatingActionButton(
      child: Icon(Icons.archive_outlined),
      tooltip: S.of(context).event_collect_items,
      onPressed: () {
        if (!plan.enable) {
          showInformDialog(context, content: S.of(context).event_not_planned);
        } else {
          SimpleCancelOkDialog(
            title: Text(S.of(context).confirm),
            content: Text(S.of(context).event_collect_item_confirm),
            onTapOk: () {
              sumDict([db.curUser.items, event.getItems(plan)], inPlace: true);
              plan.enable = false;
              db.itemStat.updateEventItems();
              setState(() {});
            },
          ).showDialog(context);
        }
      },
    );
  }
}
