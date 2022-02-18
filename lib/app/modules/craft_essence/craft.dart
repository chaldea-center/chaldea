import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/utils/wiki.dart';
import 'package:chaldea/widgets/custom_table.dart';
import 'package:chaldea/widgets/custom_tile.dart';
import 'package:chaldea/widgets/image/fullscreen_image_viewer.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:chaldea/modules/shared/lang_switch.dart';
// import 'package:chaldea/modules/summon/summon_detail_page.dart';
// import 'package:chaldea/widgets/charts/growth_curve_page.dart';

class CraftDetailPage extends StatefulWidget {
  final CraftEssence ce;
  final CraftEssence? Function(CraftEssence current, bool reversed)? onSwitch;

  const CraftDetailPage({Key? key, required this.ce, this.onSwitch})
      : super(key: key);

  @override
  _CraftDetailPageState createState() => _CraftDetailPageState();
}

class _CraftDetailPageState extends State<CraftDetailPage> {
  Language? lang;

  late CraftEssence ce;

  @override
  void initState() {
    super.initState();
    ce = widget.ce;
  }

  @override
  Widget build(BuildContext context) {
    final status =
        db2.curUser.craftEssences[ce.collectionNo] ?? CraftStatus.notMet;
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(ce.lName.l, maxLines: 1),
        titleSpacing: 0,
        actions: [
          IconButton(
            // tooltip:
            //     Localized.craftFilter.of(CraftFilterData.statusTexts[status]),
            onPressed: () {
              setState(() {
                db2.curUser.craftEssences[ce.collectionNo] = CraftStatus
                    .values[(status.index + 1) % CraftStatus.values.length];
              });
              db2.notifyUserdata();
            },
            icon: status == CraftStatus.owned
                ? const Icon(Icons.favorite, color: Colors.redAccent)
                : status == CraftStatus.met
                    ? const Icon(Icons.favorite)
                    : const Icon(Icons.favorite_outline),
          ),
          _popupButton,
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: CraftDetailBasePage(ce: ce, lang: lang, showSummon: true),
            ),
          ),
          ButtonBar(alignment: MainAxisAlignment.center, children: [
            // ProfileLangSwitch(
            //   primary: lang,
            //   onChanged: (v) {
            //     setState(() {
            //       lang = v;
            //     });
            //   },
            // ),
            for (var i = 0; i < 2; i++)
              ElevatedButton(
                onPressed: () {
                  CraftEssence? nextCe;
                  if (widget.onSwitch != null) {
                    // if navigated from filter list, let filter list decide which is the next one
                    nextCe = widget.onSwitch!(ce, i == 0);
                  } else {
                    nextCe = db2
                        .gameData.craftEssences[ce.collectionNo + [-1, 1][i]];
                  }
                  if (nextCe == null) {
                    EasyLoading.showToast(S.current.list_end_hint(i == 0));
                  } else {
                    setState(() {
                      ce = nextCe!;
                    });
                  }
                },
                child: Text([S.current.previous_card, S.current.next_card][i]),
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontWeight: FontWeight.normal)),
              ),
          ])
        ],
      ),
    );
  }

  Widget get _popupButton {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          if (ce.extra.mcLink != null)
            PopupMenuItem<String>(
              child: Text(S.current.jump_to('Mooncell')),
              onTap: () {
                launch(WikiTool.mcFullLink(ce.extra.mcLink!));
              },
            ),
          if (ce.extra.fandomLink != null)
            PopupMenuItem<String>(
              child: Text(S.current.jump_to('Fandom')),
              onTap: () {
                launch(WikiTool.fandomFullLink(ce.extra.fandomLink!));
              },
            ),
        ];
      },
    );
  }
}

class CraftDetailBasePage extends StatelessWidget {
  final CraftEssence ce;
  final Language? lang;
  final bool showSummon;

  const CraftDetailBasePage(
      {Key? key, required this.ce, this.lang, this.showSummon = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final summons = getPickupSummons();
    // final summons = <LimitedSummon>[];
    return CustomTable(
      children: <Widget>[
        CustomTableRow(children: [
          TableCellData(
            child: Text(ce.lName.l,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            isHeader: true,
          )
        ]),
        CustomTableRow(children: [
          TableCellData(text: ce.lName.jp, textAlign: TextAlign.center)
        ]),
        CustomTableRow(children: [
          TableCellData(text: ce.lName.na, textAlign: TextAlign.center)
        ]),
        CustomTableRow(
          children: [
            TableCellData(
              child: InkWell(
                child: db2.getIconImage(ce.borderedIcon, height: 90),
                onTap: () {
                  FullscreenImageViewer.show(
                    context: context,
                    urls: [ce.charaGraph],
                    placeholder: placeholder,
                  );
                },
              ),
              flex: 1,
              padding: const EdgeInsets.all(3),
            ),
            TableCellData(
              flex: 3,
              padding: EdgeInsets.zero,
              child: CustomTable(
                hideOutline: true,
                children: <Widget>[
                  CustomTableRow.fromTexts(
                      texts: ['No. ${ce.collectionNo}', 'No. ${ce.id}']),
                  CustomTableRow(children: [
                    TableCellData(text: S.current.illustrator, isHeader: true),
                    TableCellData(
                        text:
                            Transl.illustratorNames(ce.profile!.illustrator).l,
                        flex: 3,
                        maxLines: 1)
                  ]),
                  CustomTableRow(children: [
                    TableCellData(text: S.current.rarity, isHeader: true),
                    TableCellData(text: ce.rarity.toString()),
                    TableCellData(text: 'COST', isHeader: true),
                    TableCellData(text: ce.cost.toString()),
                  ]),
                  GestureDetector(
                    onTap: hasGrowth ? () => showGrowthCurves(context) : null,
                    child: CustomTableRow(children: [
                      TableCellData(text: 'ATK', isHeader: true),
                      TableCellData(
                        text: '${ce.atkBase}/${ce.atkMax}',
                        maxLines: 1,
                        style: TextStyle(
                          color: hasGrowth
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                      TableCellData(text: 'HP', isHeader: true),
                      TableCellData(
                        text: '${ce.hpBase}/${ce.hpMax}',
                        style: TextStyle(
                          color: hasGrowth
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        maxLines: 1,
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
        CustomTableRow(
          children: [
            TableCellData(
              child: CustomTile(
                title: Center(child: Text(S.current.view_illustration)),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  FullscreenImageViewer.show(
                    context: context,
                    urls: [ce.charaGraph],
                    placeholder: placeholder,
                  );
                },
              ),
              isHeader: true,
            ),
          ],
        ),
        CustomTableRow(children: [
          TableCellData(text: S.current.filter_category, isHeader: true)
        ]),
        CustomTableRow(children: [
          TableCellData(
            child: Text(EnumUtil.titled(ce.extra.obtain),
                textAlign: TextAlign.center),
          )
        ]),
        ..._relatedSvt(context),
        CustomTableRow(
            children: [TableCellData(text: S.current.skill, isHeader: true)]),
        for (final skill in ce.skills..sort2((e) => e.num * 100 + e.priority))
          CustomTableRow(
            children: [
              TableCellData(
                padding: const EdgeInsets.all(6),
                flex: 1,
                child: db2.getIconImage(skill.icon, height: 40),
              ),
              TableCellData(
                flex: 5,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Transl.skillNames(skill.name).l,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(Transl.skillDetail(skill.unmodifiedDetail ?? '???').l)
                  ],
                ),
              )
            ],
          ),
        CustomTableRow(children: [
          TableCellData(text: S.current.characters_in_card, isHeader: true)
        ]),
        CustomTableRow(
            children: [TableCellData(child: localizeCharacters(context))]),
        // CustomTableRow(children: [
        //   TableCellData(text: S.current.card_description, isHeader: true)
        // ]),
        // CustomTableRow(
        //   children: [
        //     TableCellData(
        //       text: ce.profile!.comments.first.comment,
        //       alignment: Alignment.centerLeft,
        //       padding:
        //           const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        //     )
        //   ],
        // ),
        if (showSummon && summons.isNotEmpty) ...[
          CustomTableRow(children: [
            TableCellData(text: S.current.summon, isHeader: true)
          ]),
          CustomTableRow(children: [
            TableCellData(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var summon in summons)
                  ListTile(
                    title: Text(summon.name.l ?? '???', maxLines: 1),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    onTap: () {
                      // SplitRoute.push(
                      //     context, SummonDetailPage(summon: summon));
                    },
                  )
              ],
            ))
          ])
        ]
      ],
    );
  }

  Widget localizeCharacters(BuildContext context) {
    List<Widget> children = [];
    for (final svtId in ce.extra.characters) {
      final svt = db2.gameData.servants[svtId];
      if (svt == null) {
        children.add(Text('SVT $svtId'));
      } else {
        children.add(InkWell(
          child: Text(
            svt.lName.l,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          // onTap: () => svt.pushDetail(context),
        ));
      }
    }
    for (final name in ce.extra.unknownCharacters) {
      children.add(Text(Transl.charaNames(name).l));
    }
    if (children.isEmpty) {
      return const Text('-');
    }
    children = divideTiles(children, divider: const Text('/'));
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }

  List<LimitedSummon> getPickupSummons() {
    List<LimitedSummon> summons = [];
    db2.gameData.summons.forEach((key, summon) {
      if (summon.allCards(ce: true).contains(ce.collectionNo)) {
        summons.add(summon);
      }
    });
    return summons;
  }

  Widget placeholder(BuildContext context, String? url) {
    return const SizedBox();
    // String color;
    // switch (ce.rarity) {
    //   case 5:
    //   case 4:
    //     color = '金';
    //     break;
    //   case 1:
    //   case 2:
    //     color = '铜';
    //     break;
    //   default:
    //     color = '银';
    // }
    // return db2.getIconImage('礼装$color卡背');
  }

  List<Widget> _relatedSvt(BuildContext context) {
    List<Widget> children = [];
    final bondSvt = db2.gameData.servants[ce.bondEquipOwner];
    final valentineSvt = db2.gameData.servants[ce.valentineEquipOwner];
    for (var svt in [bondSvt, valentineSvt]) {
      if (svt == null) continue;
      children.add(TextButton(
        onPressed: () {
          // TODO
        },
        child: Text(
          svt.lName.l,
          textAlign: TextAlign.center,
        ),
        style: TextButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.all(1),
        ),
      ));
    }
    return children;
  }

  bool get hasGrowth => ce.hpMax > ce.hpBase || ce.atkMax > ce.atkBase;

  void showGrowthCurves(BuildContext context) {
    // SplitRoute.push(
    //   context,
    //   GrowthCurvePage.fromCard(
    //     title: '${S.current.growth_curve} - ${ce.lName}',
    //     atks: List.generate(
    //         ce.lvMax,
    //         (index) =>
    //             (ce.atkMin + (ce.atkMax - ce.atkMin) / (ce.lvMax - 1) * index)
    //                 .round()),
    //     hps: List.generate(
    //         ce.lvMax,
    //         (index) =>
    //             (ce.hpMin + (ce.hpMax - ce.hpMin) / (ce.lvMax - 1) * index)
    //                 .round()),
    //     avatar: ce.iconBuilder(
    //       context: context,
    //       height: 56,
    //       jumpToDetail: false,
    //     ),
    //   ),
    // );
  }
}
