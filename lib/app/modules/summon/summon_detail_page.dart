import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/modules/common/not_found.dart';
import 'package:chaldea/app/tools/localized_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/utils/wiki.dart';
import 'package:chaldea/widgets/carousel_util.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../app.dart';
import 'lucky_bag_expectation.dart';
import 'summon_simulator_page.dart';
import 'summon_util.dart';

class SummonDetailPage extends StatefulWidget {
  final String? id;
  final LimitedSummon? summon;
  final List<LimitedSummon>? summonList;

  const SummonDetailPage({Key? key, this.id, this.summon, this.summonList})
      : super(key: key);

  @override
  _SummonDetailPageState createState() => _SummonDetailPageState();
}

class _SummonDetailPageState extends State<SummonDetailPage> {
  LimitedSummon? _summon;
  LimitedSummon get summon => _summon!;
  int curIndex = 0;

  @override
  void initState() {
    super.initState();
    _summon = widget.summon ?? db.gameData.wiki.summons[widget.id];
    init();
  }

  void init() {
    curIndex = shouldShowOverview ? -1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_summon == null) {
      return NotFoundPage(
        url: Routes.summonI(widget.id ?? '0'),
        title: S.current.summon,
      );
    }
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
          db.onUserData(
            (context, _) {
              bool planned = db.curUser.summons.contains(summon.id);
              return IconButton(
                icon: Icon(planned ? Icons.favorite : Icons.favorite_outline),
                tooltip: S.current.favorite,
                onPressed: () {
                  db.curUser.summons.toggle(summon.id);
                  db.notifyUserdata();
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
          SafeArea(child: buttonBar),
        ],
      ),
    );
  }

  Widget get listView {
    final relatedEvents = db.gameData.events.values
        .where((event) => event.extra.relatedSummons.contains(summon.id))
        .toList();
    List<Widget> children = [
      GestureDetector(
        onTap: summon.mcLink == null
            ? null
            : () => jumpToExternalLinkAlert(
                url: WikiTool.mcFullLink(summon.mcLink!)),
        child: CarouselUtil.limitHeightWidget(
          context: context,
          imageUrls: [summon.banner.jp, summon.banner.cn],
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
        if (!Transl.isJP && summon.name.jp != null)
          CustomTableRow(children: [
            TableCellData(
              text: summon.name.jp!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              color: TableCellData.resolveHeaderColor(context).withOpacity(0.5),
            )
          ]),
        // if (!summon.isStory)
        CustomTableRow(children: [
          TableCellData(
            text:
                'JP: ${summon.startTime.jp?.toDateTimeString() ?? '?'} ~ ${summon.endTime.jp?.toDateTimeString() ?? '?'}',
            maxLines: 1,
            style: const TextStyle(fontSize: 14),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
          )
        ]),
        if (summon.startTime.cn != null && summon.endTime.cn != null)
          CustomTableRow(children: [
            TableCellData(
              text:
                  'CN: ${summon.startTime.cn?.toDateTimeString() ?? '?'} ~ ${summon.endTime.cn?.toDateTimeString() ?? '?'}',
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
                (summon.type == SummonType.gssrsr ? 'SSR+SR' : 'SSR') +
                ')'
          ])
      ]),
      if (summon.subSummons.length > 1) dropdownButton,
      if (summon.subSummons.isNotEmpty) gachaDetails,
      if (summon.subSummons.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 16),
          child: Row(
            children: [
              Text(
                '$kStarChar ',
                style: Theme.of(context)
                    .textTheme
                    .caption
                    ?.copyWith(color: Colors.yellow),
              ),
              Text(
                'PickUp',
                style: Theme.of(context).textTheme.caption,
              )
            ],
          ),
        ),
      if (relatedEvents.isNotEmpty) ...[
        const SHeader('Related Event'),
        for (Event event in relatedEvents) associateEvent(event)
      ],
    ];
    return ListView(children: children);
  }

  Widget associateEvent(Event event) {
    return ListTile(
      leading: Icon(
        Icons.flag,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(event.shownName),
      horizontalTitleGap: 0,
      dense: true,
      onTap: () => router.push(url: event.route),
    );
  }

  bool get shouldShowOverview {
    return _summon != null && summon.subSummons.length > 1;
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
    items.addAll(summon.subSummons.map((e) => DropdownMenuItem(
          child: AutoSizeText(
            SummonUtil.summonNameLocalize(e.title),
            maxLines: 2,
            maxFontSize: 14,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          value: summon.subSummons.indexOf(e),
        )));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(S.current.summon_daily + ': '),
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
    final data = summon.subSummons[curIndex];

    List<Widget> children = [];
    data.probs.forEach((block) {
      if (!block.display) return;
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

    if (!summon.isLuckyBag) {
      children.add(SHeader(S.current.overview));
      for (int rarity in [5, 4, 3]) {
        Set<int> pickups = {};
        summon.subSummons.forEach((data) {
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

    for (final data in summon.subSummons) {
      children.add(SHeader(SummonUtil.summonNameLocalize(data.title)));
      Map<int, bool> svtIds = {};
      if (summon.isLuckyBag) {
        data.svts.where((block) => block.rarity == 5).forEach((block) {
          _addTo(svtIds, block.ids);
        });
      } else {
        data.probs
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
      onPressed: summon.subSummons.isEmpty
          ? null
          : () => router.push(
              child: SummonSimulatorPage(summon: summon, initIndex: curIndex)),
      child: Text(S.current.simulator),
    );
    if (summon.isLuckyBag && summon.subSummons.isNotEmpty) {
      centerBtn = Flexible(
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            centerBtn,
            ElevatedButton(
              onPressed: () =>
                  router.push(child: LuckyBagExpectation(summon: summon)),
              child: Text(LocalizedText.of(
                  chs: '期望计算',
                  jpn: '期待値計算',
                  eng: 'Expectation',
                  kor: '기대치 계산')),
            ),
          ],
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.circleChevronLeft),
          color: Theme.of(context).colorScheme.primary,
          tooltip: S.current.previous_card,
          onPressed: () => moveNext(true),
        ),
        centerBtn,
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.circleChevronRight),
          color: Theme.of(context).colorScheme.primary,
          tooltip: S.current.next_card,
          onPressed: () => moveNext(),
        )
      ],
    );
  }

  void moveNext([reversed = false]) {
    final list = widget.summonList ?? db.gameData.wiki.summons.values.toList();
    int index = list.indexOf(summon);
    if (index >= 0) {
      int nextIndex = index + (reversed ? -1 : 1);
      if (nextIndex >= 0 && nextIndex < list.length) {
        setState(() {
          _summon = list[nextIndex];
          init();
        });
      }
    }
  }
}
