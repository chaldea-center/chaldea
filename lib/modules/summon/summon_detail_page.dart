import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/event/campaign_detail_page.dart';
import 'package:chaldea/modules/event/limit_event_detail_page.dart';
import 'package:chaldea/modules/event/main_record_detail_page.dart';
import 'package:chaldea/modules/summon/summon_simulator_page.dart';
import 'package:chaldea/widgets/carousel_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'lucky_bag_expectation.dart';
import 'summon_util.dart';

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
    curIndex = shouldShowOverview ? -1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
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
    List<Widget> children = [
      GestureDetector(
        onTap: () =>
            jumpToExternalLinkAlert(url: WikiUtil.mcFullLink(summon.mcLink)),
        child: CarouselUtil.limitHeightWidget(
          context: context,
          imageUrls: [summon.bannerUrlJp, summon.bannerUrl],
        ),
      ),
      CustomTable(children: [
        CustomTableRow(children: [
          TableCellData(
            text: summon.lName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            color: TableCellData.resolveHeaderColor(context),
          )
        ]),
        if (!Language.isJP && summon.nameJp != null)
          CustomTableRow(children: [
            TableCellData(
              text: summon.nameJp!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              color: TableCellData.resolveHeaderColor(context).withOpacity(0.5),
            )
          ]),
        if (!summon.isStory)
          CustomTableRow(children: [
            TableCellData(
              text:
                  'JP: ${summon.startTimeJp ?? '?'} ~ ${summon.endTimeJp ?? '?'}',
              maxLines: 1,
              style: const TextStyle(fontSize: 14),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
            )
          ]),
        if (!summon.isStory &&
            summon.startTimeCn != null &&
            summon.endTimeCn != null)
          CustomTableRow(children: [
            TableCellData(
              text:
                  'CN: ${summon.startTimeCn ?? '?'} ~ ${summon.endTimeCn ?? '?'}',
              maxLines: 1,
              style: const TextStyle(fontSize: 14),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
            )
          ]),
        if (summon.isLuckyBag)
          CustomTableRow.fromTexts(texts: [
            S.current.lucky_bag +
                '(' +
                (summon.isLuckyBagWithSR ? 'SSR+SR' : 'SSR') +
                ')'
          ])
      ]),
      if (summon.dataList.length > 1) dropdownButton,
      if (summon.dataList.isNotEmpty) gachaDetails,
      if (summon.dataList.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 16),
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
    return ListView(children: children);
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

  bool get shouldShowOverview {
    return summon.dataList.length > 1 && !summon.isStory;
  }

  Widget get dropdownButton {
    List<DropdownMenuItem<int>> items = [];
    if (shouldShowOverview) {
      items.add(DropdownMenuItem(
        child: Text(
          S.current.overview,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        value: -1,
      ));
    }
    items.addAll(summon.dataList.map((e) => DropdownMenuItem(
          child: AutoSizeText(
            SummonUtil.summonNameLocalize(e.name),
            maxLines: 2,
            maxFontSize: 14,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          value: summon.dataList.indexOf(e),
        )));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
    [...data.svts, ...data.crafts].forEach((block) {
      if (!block.display && summon.isLimited && !summon.classPickUp) return;
      children.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SummonUtil.buildBlock(
          context: context,
          block: block,
        ),
      ));
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget get gachaOverview {
    List<Widget> children = [];
    void _addTo(Map<int, bool> map, List<int> ids) {
      if (ids.length == 1) {
        map[ids.single] = true;
      } else {
        ids.forEach((id) {
          map[id] = false;
        });
      }
    }

    if (!summon.isLuckyBag && !summon.classPickUp) {
      children.add(SHeader(S.current.overview));
      for (int rarity in [5, 4, 3]) {
        Set<int> pickups = {};
        summon.dataList.forEach((data) {
          data.svts.forEach((block) {
            if (block.display && block.rarity == rarity) {
              pickups.addAll(block.ids);
            }
          });
        });
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: pickups
                .map((id) => SummonUtil.svtAvatar(
                      context: context,
                      card: db.gameData.servants[id],
                      star: summon.hasSinglePickupSvt(id),
                      favorite: db.curUser.svtStatusOf(id).favorite,
                    ))
                .toList(),
          ),
        ));
      }
      children.add(
          const Divider(thickness: 0.5, height: 16, indent: 16, endIndent: 16));
    }

    for (final data in summon.dataList) {
      children.add(SHeader(SummonUtil.summonNameLocalize(data.name)));
      Map<int, bool> svtIds = {};
      if (summon.isLuckyBag) {
        data.svts.where((block) => block.rarity == 5).forEach((block) {
          _addTo(svtIds, block.ids);
        });
      } else if (summon.classPickUp) {
        data.svts.where((block) => block.rarity == 5).forEach((block) {
          _addTo(svtIds, block.ids);
        });
      } else {
        data.allBlocks
            .where((block) => block.display && block.isSvt)
            .forEach((block) {
          _addTo(svtIds, block.ids);
        });
      }
      children.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: svtIds.entries
              .map((entry) => SummonUtil.svtAvatar(
                  context: context,
                  card: db.gameData.servants[entry.key],
                  star: entry.value,
                  favorite: db.curUser.svtStatusOf(entry.key).favorite))
              .toList(),
        ),
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget get buttonBar {
    Widget centerBtn = ElevatedButton(
      onPressed: summon.dataList.isEmpty
          ? null
          : () => SplitRoute.push(context,
              SummonSimulatorPage(summon: summon, initIndex: curIndex)),
      child: Text(S.current.simulator),
    );
    if (summon.isLuckyBag && summon.dataList.isNotEmpty) {
      centerBtn = Flexible(
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            centerBtn,
            ElevatedButton(
              onPressed: () =>
                  SplitRoute.push(context, LuckyBagExpectation(summon: summon)),
              child: Text(LocalizedText.of(
                  chs: '期望计算', jpn: '期待値計算', eng: 'Expectation')),
            ),
          ],
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronCircleLeft),
          color: Theme.of(context).colorScheme.primary,
          tooltip: S.current.previous_card,
          onPressed: () => moveNext(true),
        ),
        centerBtn,
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronCircleRight),
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
