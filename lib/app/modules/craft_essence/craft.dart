import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ruby_text/ruby_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/extra_assets_page.dart';
import 'package:chaldea/app/modules/creator/chara_detail.dart';
import 'package:chaldea/app/modules/creator/creator_detail.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/charts/growth_curve_page.dart';
import 'package:chaldea/widgets/custom_table.dart';
import 'package:chaldea/widgets/custom_tile.dart';
import 'package:chaldea/widgets/image/fullscreen_image_viewer.dart';
import 'package:chaldea/widgets/tile_items.dart';
import '../common/not_found.dart';

class CraftDetailPage extends StatefulWidget {
  final int? id;
  final CraftEssence? ce;
  final CraftEssence? Function(CraftEssence current, bool reversed)? onSwitch;

  const CraftDetailPage({super.key, this.id, this.ce, this.onSwitch});

  @override
  _CraftDetailPageState createState() => _CraftDetailPageState();
}

class _CraftDetailPageState extends State<CraftDetailPage> {
  CraftEssence? _ce;

  CraftEssence get ce => _ce!;

  @override
  void initState() {
    super.initState();
    _ce = widget.ce ??
        db.gameData.craftEssences[widget.id] ??
        db.gameData.craftEssencesById[widget.id];
  }

  @override
  void didUpdateWidget(covariant CraftDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ce = widget.ce ??
        db.gameData.craftEssences[widget.id] ??
        db.gameData.craftEssencesById[widget.id];
  }

  @override
  Widget build(BuildContext context) {
    if (_ce == null) {
      return NotFoundPage(
          title: S.current.craft_essence,
          url: Routes.craftEssenceI(widget.id ?? 0));
    }
    final status =
        db.curUser.craftEssences[ce.collectionNo] ?? CraftStatus.notMet;
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
                db.curUser.craftEssences[ce.collectionNo] = (status + 1) % 3;
              });
              db.notifyUserdata();
            },
            icon: status == CraftStatus.owned
                ? const Icon(Icons.favorite, color: Colors.redAccent)
                : status == CraftStatus.met
                    ? const Icon(Icons.favorite)
                    : const Icon(Icons.favorite_outline),
            tooltip: CraftStatus.shownText(status),
          ),
          _popupButton,
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: CraftDetailBasePage(ce: ce, showExtra: true),
            ),
          ),
          SafeArea(
            child: ButtonBar(alignment: MainAxisAlignment.center, children: [
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
                      nextCe = db
                          .gameData.craftEssences[ce.collectionNo + [-1, 1][i]];
                    }
                    if (nextCe == null) {
                      EasyLoading.showToast(S.current.list_end_hint(i == 0));
                    } else {
                      setState(() {
                        _ce = nextCe!;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      textStyle:
                          const TextStyle(fontWeight: FontWeight.normal)),
                  child:
                      Text([S.current.previous_card, S.current.next_card][i]),
                ),
            ]),
          )
        ],
      ),
    );
  }

  Widget get _popupButton {
    return PopupMenuButton(
      itemBuilder: (context) {
        return SharedBuilder.websitesPopupMenuItems(
          atlas: Atlas.dbCraftEssence(ce.id),
          mooncell: ce.extra.mcLink,
          fandom: ce.extra.fandomLink,
        );
      },
    );
  }
}

class CraftDetailBasePage extends StatelessWidget {
  final CraftEssence ce;
  final bool showExtra;
  final bool enableLink;

  const CraftDetailBasePage({
    super.key,
    required this.ce,
    this.showExtra = false,
    this.enableLink = false,
  });

  @override
  Widget build(BuildContext context) {
    final summons = getPickupSummons();
    final name = RubyText(
      [RubyTextData(ce.name, ruby: ce.ruby)],
      style: const TextStyle(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );

    return CustomTable(
      children: <Widget>[
        CustomTableRow(children: [
          TableCellData(
            child: enableLink
                ? TextButton(
                    onPressed: () {
                      ce.routeTo();
                    },
                    style: kTextButtonDenseStyle,
                    child: name,
                  )
                : name,
            isHeader: true,
            padding: enableLink ? EdgeInsets.zero : const EdgeInsets.all(4),
          )
        ]),
        if (!Transl.isJP)
          CustomTableRow(children: [
            TableCellData(text: ce.lName.l, textAlign: TextAlign.center)
          ]),
        if (!Transl.isEN)
          CustomTableRow(children: [
            TableCellData(text: ce.lName.na, textAlign: TextAlign.center)
          ]),
        CustomTableRow(
          children: [
            TableCellData(
              child: InkWell(
                child: db.getIconImage(ce.borderedIcon, height: 90),
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
                      child: Text.rich(SharedBuilder.textButtonSpan(
                        context: context,
                        text: Transl.illustratorNames(ce.profile.illustrator).l,
                        onTap: () {
                          router.pushPage(CreatorDetail.illust(
                              name: ce.profile.illustrator));
                        },
                      )),
                      flex: 3,
                    )
                  ]),
                  if (ce.profile.cv.isNotEmpty)
                    CustomTableRow(children: [
                      TableCellData(
                        text: S.current.info_cv,
                        isHeader: true,
                        textAlign: TextAlign.center,
                      ),
                      TableCellData(
                        child: Text.rich(SharedBuilder.textButtonSpan(
                          context: context,
                          text: Transl.cvNames(ce.profile.cv).l,
                          onTap: () {
                            router.pushPage(
                                CreatorDetail.cv(name: ce.profile.cv));
                          },
                        )),
                        flex: 3,
                        textAlign: TextAlign.center,
                      )
                    ]),
                  CustomTableRow(children: [
                    TableCellData(text: S.current.rarity, isHeader: true),
                    TableCellData(text: ce.rarity.toString()),
                    TableCellData(text: 'COST', isHeader: true),
                    TableCellData(text: ce.cost.toString()),
                  ]),
                  InkWell(
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
            child:
                Text(Transl.ceObtain(ce.obtain).l, textAlign: TextAlign.center),
          )
        ]),
        ..._relatedSvt(context),
        CustomTableRow(
            children: [TableCellData(text: S.current.skill, isHeader: true)]),
        for (final skill in ce.skills..sort2((e) => e.num * 100 + e.priority))
          SkillDescriptor(skill: skill),
        CustomTableRow(children: [
          TableCellData(text: S.current.characters_in_card, isHeader: true)
        ]),
        CustomTableRow(
            children: [TableCellData(child: localizeCharacters(context))]),
        CustomTableRow(children: [
          TableCellData(text: S.current.card_description, isHeader: true)
        ]),
        if (!Transl.isJP && ce.extra.profile.ofRegion(Transl.current) != null)
          CustomTableRow(
            children: [
              TableCellData(
                child: SelectableText(
                    ce.extra.profile.ofRegion(Transl.current) ?? '???'),
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              )
            ],
          ),
        if (ce.extra.profile.ofRegion(Region.jp) != null)
          CustomTableRow(
            children: [
              TableCellData(
                child: SelectableText(
                    ce.extra.profile.ofRegion(Region.jp) ?? '???'),
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              )
            ],
          ),
        CustomTableRow.fromTexts(
          texts: [S.current.illustration],
          isHeader: true,
        ),
        ExtraAssetsPage(assets: ce.extraAssets, scrollable: false),
        if (showExtra && summons.isNotEmpty) ...[
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
                      router.push(url: summon.route);
                    },
                  )
              ],
            ))
          ])
        ],
      ],
    );
  }

  Widget localizeCharacters(BuildContext context) {
    List<Widget> children = [];
    for (final svtId in ce.extra.characters) {
      final svt = db.gameData.servantsNoDup[svtId];
      if (svt == null) {
        children.add(Text('SVT $svtId'));
      } else {
        children.add(InkWell(
          child: Text(
            svt.lName.l,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: () => router.push(url: svt.route),
        ));
      }
    }
    for (final name in ce.extra.unknownCharacters) {
      children.add(InkWell(
        child: Text(
          Transl.charaNames(name).l,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        onTap: () => router.pushPage(CharaDetail(name: name)),
      ));
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
    db.gameData.wiki.summons.forEach((key, summon) {
      if (summon.allCards(ce: true).contains(ce.collectionNo)) {
        summons.add(summon);
      }
    });
    return summons;
  }

  Widget placeholder(BuildContext context, String? url) {
    // class_b_103, class_s_103, class_g_103
    final color = ['n', 'b', 's', 'g'][GameCardMixin.bsgColor(ce.rarity)];
    return db.getIconImage(Atlas.asset('ClassCard/class_${color}_103.png'));
  }

  List<Widget> _relatedSvt(BuildContext context) {
    List<Widget> children = [];
    final bondSvt = db.gameData.servantsById[ce.bondEquipOwner];
    final valentineSvt = db.gameData.servantsById[ce.valentineEquipOwner];
    for (var svt in [bondSvt, valentineSvt]) {
      if (svt == null) continue;
      children.add(TextButton(
        onPressed: () {
          router.push(url: svt.route);
        },
        style: TextButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        child: Text(
          svt.lName.l,
          textAlign: TextAlign.center,
        ),
      ));
    }
    return children;
  }

  bool get hasGrowth => ce.hpMax > ce.hpBase || ce.atkMax > ce.atkBase;

  void showGrowthCurves(BuildContext context) {
    router.push(
      child: GrowthCurvePage.fromCard(
        title: '${S.current.growth_curve} - ${ce.lName.l}',
        atks: List.generate(
            ce.lvMax,
            (index) =>
                (ce.atkBase + (ce.atkMax - ce.atkBase) / (ce.lvMax - 1) * index)
                    .round()),
        hps: List.generate(
            ce.lvMax,
            (index) =>
                (ce.hpBase + (ce.hpMax - ce.hpBase) / (ce.lvMax - 1) * index)
                    .round()),
        avatar: ce.iconBuilder(
          context: context,
          height: 56,
          jumpToDetail: false,
        ),
      ),
    );
  }
}
