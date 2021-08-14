import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/event/campaign_detail_page.dart';
import 'package:chaldea/modules/event/limit_event_detail_page.dart';
import 'package:chaldea/modules/event/main_record_detail_page.dart';
import 'package:chaldea/modules/summon/summon_simulator_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SummonDetailPage extends StatefulWidget {
  final Summon summon;
  final List<Summon>? summonList;

  const SummonDetailPage({Key? key, required this.summon, this.summonList})
      : super(key: key);

  @override
  _SummonDetailPageState createState() => _SummonDetailPageState();
}

class _SummonDetailPageState extends State<SummonDetailPage> {
  late Summon summon;
  int curIndex = 0;

  @override
  void initState() {
    super.initState();
    summon = widget.summon;
    init();
  }

  void init() {
    curIndex = showOverview ? -1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: AutoSizeText(
          summon.lName,
          maxLines: 1,
          overflow: TextOverflow.fade,
        ),
        titleSpacing: 0,
        actions: [
          db.streamBuilder(
            (context) {
              bool planned =
                  db.curUser.plannedSummons.contains(summon.indexKey);
              return IconButton(
                icon: Icon(planned ? Icons.favorite : Icons.favorite_outline),
                tooltip: S.current.favorite,
                onPressed: () {
                  if (planned) {
                    db.curUser.plannedSummons.remove(summon.indexKey);
                  } else {
                    db.curUser.plannedSummons.add(summon.indexKey);
                  }
                  db.notifyDbUpdate();
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: listView),
          kDefaultDivider,
          buttonBar,
        ],
      ),
    );
  }

  Widget get listView {
    List<Widget> banners = [];
    for (String? url in [summon.bannerUrl, summon.bannerUrlJp]) {
      if (url?.isNotEmpty == true) {
        banners.add(CachedImage(
          imageUrl: url,
          cachedOption: CachedImageOption(
              imageBuilder: (context, image) =>
                  FittedBox(child: Image(image: image))),
          isMCFile: true,
          placeholder: (_, __) => Container(),
        ));
      }
    }
    List<Widget> children = [
      if (banners.isNotEmpty)
        GestureDetector(
          onTap: () =>
              jumpToExternalLinkAlert(url: WikiUtil.mcFullLink(summon.mcLink)),
          child: CarouselSlider(
            items: banners,
            options: CarouselOptions(
              autoPlay: false,
              aspectRatio: 8 / 3,
              viewportFraction: 1.0,
              enableInfiniteScroll: banners.length > 1,
            ),
          ),
        ),
      SHeader(LocalizedText.of(chs: '卡池详情', jpn: '詳細', eng: 'Information')),
      if (!summon.isStory)
        ListTile(
          title: AutoSizeText(
            'JP: ${summon.startTimeJp ?? "?"} ~ ${summon.endTimeJp ?? "?"}\n'
            'CN: ${summon.startTimeCn ?? "?"} ~ ${summon.endTimeCn ?? "?"}',
            maxLines: 2,
          ),
        ),
      if (summon.dataList.length > 1) dropdownButton,
      if (summon.dataList.isNotEmpty) gachaDetails,
      if (summon.dataList.isNotEmpty)
        Padding(
          padding: EdgeInsets.only(bottom: 8, left: 16),
          child: Row(
            children: [
              Text(
                '★ ',
                style: Theme.of(context)
                    .textTheme
                    .caption
                    ?.copyWith(color: Colors.yellow),
              ),
              Text(
                LocalizedText.of(
                    chs: '单up', jpn: 'ピックアップ', eng: 'Individual Pick Up'),
                style: Theme.of(context).textTheme.caption,
              )
            ],
          ),
        ),
      if (summon.associatedEvents.isNotEmpty) ...[
        SHeader(LocalizedText.of(
            chs: '关联活动', jpn: '関連イベント', eng: 'Associated Events')),
        for (String event in summon.associatedEvents) associateEvent(event)
      ],
      if (summon.associatedSummons.isNotEmpty) ...[
        SHeader(LocalizedText.of(
            chs: '关联卡池', jpn: '関連ガチャ', eng: 'Associated Summons')),
        for (String _summon in summon.associatedSummons)
          associateSummon(_summon)
      ],
    ];
    return ListView.separated(
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (context, _) => kDefaultDivider,
      itemCount: children.length,
    );
  }

  Widget associateEvent(String name) {
    name = name.replaceAll('_', ' ');
    EventBase? event;
    Widget? page;
    if (db.gameData.events.limitEvents.containsKey(name)) {
      event = db.gameData.events.limitEvents[name]!;
      page = LimitEventDetailPage(event: event as LimitEvent);
    } else if (db.gameData.events.mainRecords.containsKey(name)) {
      event = db.gameData.events.mainRecords[name]!;
      page = MainRecordDetailPage(record: event as MainRecord);
    } else if (db.gameData.events.campaigns.containsKey(name)) {
      event = db.gameData.events.campaigns[name]!;
      page = CampaignDetailPage(event: event as CampaignEvent);
    }

    return ListTile(
      leading: Icon(
        Icons.flag,
        color: page == null ? null : Theme.of(context).colorScheme.primary,
      ),
      title: Text(event?.localizedName ?? name),
      horizontalTitleGap: 0,
      dense: true,
      onTap: page == null ? null : () => SplitRoute.push(context, page!),
    );
  }

  Widget associateSummon(String name) {
    name = name.replaceAll('_', ' ');
    Summon? _summon = db.gameData.summons[name];
    return ListTile(
      leading: FaIcon(
        FontAwesomeIcons.dice,
        size: 20,
        color: _summon == null ? null : Theme.of(context).colorScheme.primary,
      ),
      dense: true,
      title: Text(_summon?.lName ?? name),
      horizontalTitleGap: 0,
      onTap: _summon == null
          ? null
          : () => SplitRoute.push(context, SummonDetailPage(summon: _summon)),
    );
  }

  bool get showOverview {
    return summon.dataList.length > 1 &&
        !summon.classPickUp &&
        summon.isLimited;
  }

  Widget get dropdownButton {
    List<DropdownMenuItem<int>> items = [];
    if (showOverview) {
      items.add(DropdownMenuItem(
        child: Text(
          LocalizedText.of(chs: '概览', jpn: '概要', eng: 'Overview'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        value: -1,
      ));
    }
    items.addAll(summon.dataList.map((e) => DropdownMenuItem(
          child: AutoSizeText(
            summonNameLocalize(e.name),
            maxLines: 2,
            maxFontSize: 14,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          value: summon.dataList.indexOf(e),
        )));
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(LocalizedText.of(chs: '日替: ', jpn: '日替: ', eng: 'Daily: ')),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                  border: Border(bottom: Divider.createBorderSide(context))),
              child: DropdownButton<int>(
                value: curIndex,
                items: items,
                underline: Container(),
                onChanged: (v) {
                  setState(() {
                    curIndex = v ?? curIndex;
                  });
                },
                isExpanded: true,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget get gachaDetails {
    if (curIndex < 0) {
      return gachaOverview;
    }
    final data = summon.dataList[curIndex];

    List<Widget> children = [];
    [...data.svts, if (summon.isStory) ...data.crafts].forEach((block) {
      if (!block.display && summon.isLimited && !summon.classPickUp) return;
      children.add(Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: _cardGrid(
          ids: block.ids,
          header: '${block.rarity}☆',
          childBuilder: (id) {
            final card =
                block.isSvt ? db.gameData.servants[id] : db.gameData.crafts[id];
            if (card == null) return Text('No.$id');
            return _svtAvatar(
                card, block.weight / block.ids.length, block.ids.length == 1);
          },
        ),
      ));
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: divideTiles(children),
    );
  }

  Widget get gachaOverview {
    Map<int, Set<int>> svts = {5: {}, 4: {}, 3: {}};
    for (var data in summon.dataList) {
      for (var blockData in data.svts) {
        if (!blockData.display) continue;
        svts[blockData.rarity]?.addAll(blockData.ids);
      }
    }
    List<Widget> children = [];
    for (int rarity in [5, 4, 3]) {
      if (svts[rarity]!.isEmpty) continue;
      children.add(Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: _cardGrid(
          ids: svts[rarity]!,
          header: '$rarity☆  ',
          childBuilder: (id) {
            final svt = db.gameData.servants[id];
            if (svt == null) return Text('No.$id');
            return _svtAvatar(svt, null, summon.hasSinglePickupSvt(id));
          },
        ),
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: divideTiles(children),
    );
  }

  Widget _cardGrid({
    required Iterable<int> ids,
    required String header,
    required Widget childBuilder(int id),
  }) {
    final grid = LayoutBuilder(
      builder: (context, constraints) {
        int count = max(constraints.maxWidth ~/ 72, 4);
        double childWidth = constraints.maxWidth / count;
        return GridView.count(
          crossAxisCount: count,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          childAspectRatio: childWidth / min(72, childWidth * 144 / 132),
          children: ids.map((id) {
            return childBuilder(id);
          }).toList(),
        );
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header),
        grid,
      ],
    );
  }

  Widget _svtAvatar(GameCardMixin card, double? weight, [bool star = false]) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2, right: 2),
          child: buildSummonCard(
              context: context, card: card, weight: weight, showCategory: true),
        ),
        if (star) ...[
          Icon(Icons.star, color: Colors.yellow, size: 18),
          Icon(Icons.star_outline, color: Colors.redAccent, size: 18),
        ]
      ],
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: FaIcon(FontAwesomeIcons.chevronCircleLeft),
          color: Theme.of(context).colorScheme.primary,
          tooltip: S.current.previous_card,
          onPressed: () => moveNext(true),
        ),
        ElevatedButton(
          onPressed: summon.dataList.isEmpty
              ? null
              : () => SplitRoute.push(context,
                  SummonSimulatorPage(summon: summon, initIndex: curIndex)),
          child: Text(S.current.summon_simulator),
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.chevronCircleRight),
          color: Theme.of(context).colorScheme.primary,
          tooltip: S.current.next_card,
          onPressed: () => moveNext(),
        )
      ],
    );
  }

  void moveNext([reversed = false]) {
    final list = widget.summonList ?? db.gameData.summons.values.toList();
    int index = list.indexOf(summon);
    if (index >= 0) {
      int nextIndex = index + (reversed ? -1 : 1);
      if (nextIndex >= 0 && nextIndex < list.length) {
        setState(() {
          summon = list[nextIndex];
          init();
        });
      }
    }
  }
}
