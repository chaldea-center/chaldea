import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/modules/common/not_found.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/carousel_util.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../app.dart';
import '../common/builders.dart';
import '../mc/mc_multi_gacha.dart';
import '../mc/mc_prob_edit.dart';
import 'gacha/gacha_banner.dart';
import 'lucky_bag_expectation.dart';
import 'summon_simulator_page.dart';
import 'summon_util.dart';

class SummonDetailPage extends StatefulWidget {
  final String? id;
  final LimitedSummon? summon;
  final List<LimitedSummon>? summonList;

  const SummonDetailPage({super.key, this.id, this.summon, this.summonList});

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
          summon.lName.l,
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
          PopupMenuButton(
            itemBuilder: (context) => [
              ...SharedBuilder.websitesPopupMenuItems(
                mooncell: summon.mcLink,
                fandom: summon.fandomLink,
              ),
              ...SharedBuilder.noticeLinkPopupMenuItems(noticeLink: summon.noticeLink),
            ],
          )
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
    final relatedEvents =
        db.gameData.events.values.where((event) => event.extra.relatedSummons.contains(summon.id)).toList();
    List<Widget> children = [
      CarouselUtil.limitHeightWidget(
        context: context,
        imageUrls: summon.resolvedBanner.values.toList(),
      ),
      CustomTable(selectable: true, children: [
        CustomTableRow(children: [
          TableCellData(
            text: summon.lName.l,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            color: TableCellData.resolveHeaderColor(context),
          )
        ]),
        if (!Transl.isJP && summon.lName.jp != summon.lName.l)
          CustomTableRow(children: [
            TableCellData(
              text: summon.lName.jp,
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
            // alignment: Alignment.centerLeft,
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
              // alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
            )
          ]),
        if (summon.isLuckyBag)
          CustomTableRow.fromTexts(
              texts: ['${S.current.lucky_bag}(${summon.type == SummonType.gssrsr ? 'SSR+SR' : 'SSR'})'])
      ]),
      if (summon.subSummons.isEmpty && (summon.puSvt.isNotEmpty || summon.puCE.isNotEmpty)) pickupOverviewOnDetail,
      if (summon.subSummons.isNotEmpty) ...[
        if (summon.subSummons.length > 1) dropdownButton,
        gachaDetails,
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 16),
          child: Row(
            children: [
              Text(
                '$kStarChar ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.yellow),
              ),
              Text(
                'PickUp',
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          ),
        ),
        if (curIndex >= 0)
          Center(
            child: ExpandIcon(
              isExpanded: _expanded,
              onPressed: (v) {
                setState(() {
                  _expanded = !v;
                });
              },
              padding: EdgeInsets.zero,
            ),
          ),
      ],
      if (relatedEvents.isNotEmpty)
        TileGroup(
          header: S.current.event,
          children: [for (Event event in relatedEvents) associateEvent(event)],
        ),
      SFooter(S.current.summon_info_hint),
    ];

    final startJp = summon.startTime.jp, endJp = summon.endTime.jp;
    if (startJp != null && endJp != null) {
      final gachaGroup = db.gameData.others.gachaGroups.values.firstWhereOrNull((group) {
        if (group.isEmpty) return false;
        return (Maths.min(group.map((e) => e.openedAt)) - startJp).abs() < 3601 &&
            (Maths.max(group.map((e) => e.closedAt)) - endJp).abs() < 3601;
      });
      if (gachaGroup != null && gachaGroup.isNotEmpty) {
        children.add(const Divider(height: 16));
        children.add(TileGroup(
          header: S.current.raw_gacha_data,
          children: [
            for (final gacha in gachaGroup)
              ListTile(
                dense: true,
                title: Text(gacha.lName),
                subtitle: Text([
                  // gacha.detailUrl,
                  [gacha.openedAt, gacha.closedAt].map((e) => e.sec2date().toStringShort(omitSec: true)).join(' ~ '),
                ].join('\n')),
                trailing: GachaBanner(
                  imageId: gacha.imageId,
                  region: Region.jp,
                  background: false,
                ),
                onTap: () {
                  router.pushPage(MCGachaProbEditPage(gacha: gacha, region: Region.jp));
                },
              ),
          ],
        ));
        if (Language.isZH && summon.subSummons.length != gachaGroup.length) {
          children.add(Center(
            child: ElevatedButton(
              onPressed: () {
                router.pushPage(MCSummonCreatePage(gachas: gachaGroup.toList()));
              },
              child: Text("创建Mooncell卡池(${gachaGroup.length})"),
            ),
          ));
        }
      }
    }
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
        value: -1,
        child: Text(
          S.current.overview,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textScaler: const TextScaler.linear(0.9),
        ),
      ));
    }
    items.addAll(summon.subSummons.map((e) => DropdownMenuItem(
          value: summon.subSummons.indexOf(e),
          child: AutoSizeText(
            SummonUtil.summonNameLocalize(e.title),
            maxLines: 2,
            maxFontSize: 14,
            textScaleFactor: 0.9,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        )));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('${S.current.summon_daily}: '),
          Flexible(
            child: Container(
              decoration: BoxDecoration(border: Border(bottom: Divider.createBorderSide(context))),
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

  bool _expanded = false;
  Widget get gachaDetails {
    if (curIndex < 0) {
      return gachaOverview;
    }
    final data = summon.subSummons[curIndex];

    List<Widget> children = [];
    for (final block in data.probs) {
      if (!_expanded && !block.display) continue;
      children.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SummonUtil.buildBlock(
          context: context,
          block: block,
        ),
      ));
    }
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
        for (final id in ids) {
          map[id] = false;
        }
      }
    }

    if (!summon.isLuckyBag) {
      children.add(SHeader(S.current.overview));
      for (int rarity in [5, 4, 3]) {
        Set<int> pickups = {};
        for (final data in summon.subSummons) {
          for (final block in data.svts) {
            if (block.display && block.rarity == rarity) {
              pickups.addAll(block.ids);
            }
          }
        }
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: pickups
                .map((id) => SummonUtil.svtAvatar(
                      context: context,
                      card: db.gameData.servantsNoDup[id],
                      star: summon.hasSinglePickupSvt(id),
                      favorite: db.curUser.svtStatusOf(id).favorite,
                    ))
                .toList(),
          ),
        ));
      }
      children.add(const Divider(thickness: 0.5, height: 16, indent: 16, endIndent: 16));
    }

    for (final data in summon.subSummons) {
      children.add(SHeader(SummonUtil.summonNameLocalize(data.title)));
      Map<int, bool> svtIds = {};
      if (summon.isLuckyBag) {
        for (final block in data.svts.where((block) => block.rarity == 5)) {
          _addTo(svtIds, block.ids);
        }
      } else {
        for (final block in data.probs.where((block) => block.display && block.isSvt)) {
          _addTo(svtIds, block.ids);
        }
      }
      children.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: svtIds.entries
              .map((entry) => SummonUtil.svtAvatar(
                  context: context,
                  card: db.gameData.servantsNoDup[entry.key],
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

  Widget get pickupOverviewOnDetail {
    List<Widget> children = [];
    if (summon.puSvt.isNotEmpty) {
      children.add(SHeader(S.current.servant));
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final id in summon.puSvt)
              SummonUtil.svtAvatar(
                context: context,
                card: db.gameData.servantsNoDup[id],
                star: summon.hasSinglePickupSvt(id),
                favorite: db.curUser.svtStatusOf(id).favorite,
              )
          ],
        ),
      ));
    }
    if (summon.puCE.isNotEmpty) {
      children.add(SHeader(S.current.craft_essence));
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final id in summon.puCE)
              SummonUtil.svtAvatar(
                context: context,
                card: db.gameData.craftEssences[id],
                favorite: db.curUser.ceStatusOf(id).favorite,
              )
          ],
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
          : () => router.push(child: SummonSimulatorPage(summon: summon, initIndex: curIndex)),
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
              onPressed: () => router.push(child: LuckyBagExpectation(summon: summon)),
              child: Text(S.current.summon_expectation_btn),
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
