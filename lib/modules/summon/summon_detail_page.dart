import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/event/limit_event_detail_page.dart';
import 'package:chaldea/modules/event/main_record_detail_page.dart';
import 'package:chaldea/modules/servant/servant_detail_page.dart';
import 'package:chaldea/modules/summon/summon_simulator_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/getwidget.dart';

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
        title: AutoSizeText(summon.localizedName, maxLines: 1),
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
          imageBuilder: (context, image) =>
              FittedBox(child: Image(image: image)),
          isMCFile: true,
          placeholder: (_, __) => Container(),
        ));
      }
    }
    List<Widget> children = [
      if (banners.isNotEmpty)
        GestureDetector(
          onTap: () => jumpToExternalLinkAlert(
              url: MooncellUtil.fullLink(summon.mcLink)),
          child: GFCarousel(
            items: banners,
            autoPlay: false,
            aspectRatio: 8 / 3,
            viewportFraction: 1.0,
            enableInfiniteScroll: banners.length > 1,
          ),
        ),
      SHeader('卡池详情'),
      ListTile(
        title: Text(
            '日服: ${summon.startTimeJp ?? "?"} ~ ${summon.endTimeJp ?? "?"}\n'
            '国服: ${summon.startTimeCn ?? "?"} ~ ${summon.endTimeCn ?? "?"}'),
      ),
      if (summon.dataList.length > 1) dropdownButton,
      if (summon.dataList.isNotEmpty) gachaDetails,
      if (summon.associatedEvents.isNotEmpty) ...[
        SHeader('关联活动'),
        for (String event in summon.associatedEvents) associateEvent(event)
      ],
      if (summon.associatedSummons.isNotEmpty) ...[
        SHeader('关联卡池'),
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
    SplitLayoutBuilder? builder;
    if (db.gameData.events.limitEvents.containsKey(name)) {
      event = db.gameData.events.limitEvents[name]!;
      builder = (_, __) => LimitEventDetailPage(event: event as LimitEvent);
    } else if (db.gameData.events.mainRecords.containsKey(name)) {
      event = db.gameData.events.mainRecords[name]!;
      builder = (_, __) => MainRecordDetailPage(record: event as MainRecord);
    }

    return ListTile(
      leading: Icon(
        Icons.event,
        color: builder == null ? null : Colors.blue,
      ),
      title: Text(event?.localizedName ?? name),
      horizontalTitleGap: 0,
      dense: true,
      onTap: builder == null
          ? null
          : () => SplitRoute.push(context: context, builder: builder!),
    );
  }

  Widget associateSummon(String name) {
    name = name.replaceAll('_', ' ');
    Summon? _summon = db.gameData.summons[name];
    return ListTile(
      leading: FaIcon(
        FontAwesomeIcons.chessQueen,
        color: _summon == null ? null : Colors.blue,
      ),
      dense: true,
      title: Text(_summon?.localizedName ?? name),
      horizontalTitleGap: 0,
      onTap: _summon == null
          ? null
          : () => SplitRoute.push(
                context: context,
                builder: (context, _) => SummonDetailPage(summon: _summon),
              ),
    );
  }

  bool get showOverview {
    return summon.dataList.length > 1 &&
        !summon.classPickUp &&
        summon.luckyBag == 0;
  }

  Widget get dropdownButton {
    List<DropdownMenuItem<int>> items = [];
    if (showOverview) {
      items.add(DropdownMenuItem(
        child: Text('概览'),
        value: -1,
      ));
    }
    items.addAll(summon.dataList.map((e) => DropdownMenuItem(
          child: AutoSizeText(e.name, maxLines: 2, maxFontSize: 14),
          value: summon.dataList.indexOf(e),
        )));
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('日替 '),
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
    data.svts.forEach((block) {
      if (!block.display && summon.luckyBag == 0 && !summon.classPickUp) return;
      final row = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${block.rarity}星  '),
          Flexible(
            child: Wrap(
              spacing: 3,
              runSpacing: 3,
              children: block.ids.map((id) {
                final svt = db.gameData.servants[id];
                if (svt == null) return Text('No.$id');
                return _svtAvatar(svt, block.ids.length == 1);
              }).toList(),
            ),
          )
        ],
      );
      children.add(Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: row,
      ));
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
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
      final row = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$rarity星  '),
          Flexible(
            child: Wrap(
              spacing: 3,
              runSpacing: 3,
              children: svts[rarity]!.map((id) {
                final svt = db.gameData.servants[id];
                if (svt == null) return Text('No.$id');
                return _svtAvatar(svt, summon.hasSinglePickupSvt(id));
              }).toList(),
            ),
          )
        ],
      );
      children.add(Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: row,
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: divideTiles(children),
    );
  }

  Widget _svtAvatar(Servant svt, [bool star = false]) {
    return InkWell(
      onTap: () {
        SplitRoute.push(
          context: context,
          builder: (context, _) => ServantDetailPage(svt),
        );
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6, right: 6),
            child: ImageWithText(
              image: db.getIconImage(svt.icon, height: 64),
              text: svt.info.obtain.replaceAll('常驻', ''),
            ),
          ),
          if (star) ...[
            Icon(Icons.star, color: Colors.yellow, size: 18),
            Icon(Icons.star_outline, color: Colors.redAccent, size: 18),
          ]
        ],
      ),
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: FaIcon(FontAwesomeIcons.chevronCircleLeft),
          color: Colors.blueAccent,
          tooltip: '上一个',
          onPressed: () => moveNext(true),
        ),
        ElevatedButton(
          onPressed: summon.dataList.isEmpty
              ? null
              : () {
                  SplitRoute.push(
                    context: context,
                    builder: (context, _) => SummonSimulatorPage(
                      summon: summon,
                      initIndex: curIndex,
                    ),
                  );
                },
          child: Text('抽卡模拟器'),
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.chevronCircleRight),
          color: Colors.blueAccent,
          tooltip: '下一个',
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
