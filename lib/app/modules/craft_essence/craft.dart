import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
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
import 'package:chaldea/widgets/widgets.dart';
import '../common/not_found.dart';
import '../servant/tabs/profile_tab.dart';

class CraftDetailPage extends StatefulWidget {
  final int? id;
  final CraftEssence? ce;
  final CraftEssence? Function(CraftEssence current, bool reversed)? onSwitch;

  const CraftDetailPage({super.key, this.id, this.ce, this.onSwitch});

  @override
  _CraftDetailPageState createState() => _CraftDetailPageState();
}

class _CraftDetailPageState extends State<CraftDetailPage> {
  bool _loading = false;
  CraftEssence? _ce;
  CraftEssence get ce => _ce!;

  @override
  void initState() {
    super.initState();
    fetchData();
    _ce = widget.ce ?? db.gameData.craftEssences[widget.id] ?? db.gameData.craftEssencesById[widget.id];
  }

  Future<void> fetchData() async {
    _loading = true;
    if (mounted) setState(() {});
    _ce = widget.ce ?? db.gameData.craftEssences[widget.id] ?? db.gameData.craftEssencesById[widget.id];
    final id = widget.ce?.id ?? widget.id;
    if (id == null || _ce != null) return;
    _ce = await AtlasApi.ce(id);
    _loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_ce == null) {
      return NotFoundPage(
        title: S.current.craft_essence,
        url: Routes.craftEssenceI(widget.id ?? 0),
        loading: _loading,
      );
    }
    final status = ce.status;
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(ce.lName.l, maxLines: 1),
        titleSpacing: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                status.status = (status.status + 1) % 3;
              });
              db.notifyUserdata();
              EasyLoading.showToast(status.statusText);
            },
            icon: status.status == CraftStatus.owned
                ? const Icon(Icons.favorite, color: Colors.redAccent)
                : status.status == CraftStatus.met
                    ? const Icon(Icons.favorite)
                    : const Icon(Icons.favorite_outline),
            tooltip: status.statusText,
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
          if (status.status == CraftStatus.owned)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${status.statusText}: '),
                const SizedBox(width: 8),
                Text(S.current.ascension),
                const SizedBox(width: 4),
                DropdownButton<int>(
                  isDense: true,
                  value: status.limitCount,
                  items: [
                    for (int asc = 0; asc <= 4; asc++) DropdownMenuItem(value: asc, child: Text(asc.toString())),
                  ],
                  onChanged: (v) {
                    setState(() {
                      if (v != null) status.limitCount = v;
                    });
                  },
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return InputCancelOkDialog(
                          title: 'Lv (1~${ce.lvMax})',
                          text: status.lv.toString(),
                          validate: (s) {
                            final v = int.tryParse(s);
                            if (v == null) return false;
                            return v > 0 && v <= ce.lvMax;
                          },
                          onSubmit: (v) {
                            status.lv = int.tryParse(v) ?? status.lv;
                            if (mounted) setState(() {});
                          },
                        );
                      },
                    );
                  },
                  child: Text('Lv. ${status.lv}'),
                ),
              ],
            ),
          SafeArea(
            child: OverflowBar(
              alignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 2; i++)
                  ElevatedButton(
                    onPressed: () {
                      CraftEssence? nextCe;
                      if (widget.onSwitch != null) {
                        // if navigated from filter list, let filter list decide which is the next one
                        nextCe = widget.onSwitch!(ce, i == 0);
                      } else {
                        nextCe = db.gameData.craftEssences[ce.collectionNo + [-1, 1][i]];
                      }
                      if (nextCe == null) {
                        EasyLoading.showToast(S.current.list_end_hint(i == 0));
                      } else {
                        setState(() {
                          _ce = nextCe!;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontWeight: FontWeight.normal)),
                    child: Text([S.current.previous_card, S.current.next_card][i]),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget get _popupButton {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          if (ce.collectionNo > 0)
            PopupMenuItem(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CheckboxWithLabel(
                ink: false,
                value: db.curUser.battleSim.pingedCEs.contains(ce.collectionNo),
                label: Text('Laplace: ${S.current.pin_to_top}'),
                onChanged: (v) {
                  db.curUser.battleSim.pingedCEs.toggle(ce.collectionNo);
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                db.curUser.battleSim.pingedCEs.toggle(ce.collectionNo);
              },
            ),
          ...SharedBuilder.websitesPopupMenuItems(
            atlas: Atlas.dbCraftEssence(ce.id),
            mooncell: ce.extra.mcLink,
            fandom: ce.extra.fandomLink,
          ),
        ];
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
      [RubyTextData(ce.lName.jp, ruby: ce.ruby)],
      style: const TextStyle(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );

    return CustomTable(
      selectable: true,
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
        if (!Transl.isJP) CustomTableRow(children: [TableCellData(text: ce.lName.l, textAlign: TextAlign.center)]),
        if (!Transl.isEN) CustomTableRow(children: [TableCellData(text: ce.lName.na, textAlign: TextAlign.center)]),
        CustomTableRow(
          children: [
            TableCellData(
              child: InkWell(
                child: db.getIconImage(ce.borderedIcon, height: 90),
                onTap: () {
                  FullscreenImageViewer.show(
                    context: context,
                    urls: [ce.charaGraph],
                    placeholder: cardBackPlaceholder,
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
                  CustomTableRow.fromTexts(texts: ['No. ${ce.collectionNo}', 'No. ${ce.id}']),
                  CustomTableRow(children: [
                    TableCellData(text: S.current.illustrator, isHeader: true),
                    TableCellData(
                      child: Text.rich(SharedBuilder.textButtonSpan(
                        context: context,
                        text: Transl.illustratorNames(ce.profile.illustrator).l,
                        onTap: () {
                          router.pushPage(CreatorDetail.illust(name: ce.profile.illustrator));
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
                            router.pushPage(CreatorDetail.cv(name: ce.profile.cv));
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
                          color: hasGrowth ? Theme.of(context).colorScheme.primary : null,
                        ),
                      ),
                      TableCellData(text: 'HP', isHeader: true),
                      TableCellData(
                        text: '${ce.hpBase}/${ce.hpMax}',
                        style: TextStyle(
                          color: hasGrowth ? Theme.of(context).colorScheme.primary : null,
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
        // TextButton(
        //   onPressed: () {
        //     FullscreenImageViewer.show(
        //       context: context,
        //       urls: [ce.charaGraph],
        //       placeholder: cardBackPlaceholder,
        //     );
        //   },
        //   style: kTextButtonDenseStyle,
        //   child: Text(S.current.view_illustration),
        // ),
        if (ce.profile.cv.isNotEmpty)
          TextButton(
            onPressed: () {
              router.push(url: Routes.servantI(ce.id));
            },
            style: kTextButtonDenseStyle,
            child: Text(S.current.voice),
          ),
        CustomTableRow(children: [TableCellData(text: S.current.filter_category, isHeader: true)]),
        CustomTableRow(children: [
          TableCellData(
            child: Text(
              [
                Transl.ceObtain(ce.obtain).l,
                ce.flags.isEmpty ? '-' : ce.flags.map((e) => e.name).join(' / '),
                // ce.extra.obtain.name,
              ].join('\n'),
              textAlign: TextAlign.center,
            ),
          ),
        ]),
        ..._relatedSvt(context),
        if (ce.valentineScript.isNotEmpty) ...[
          CustomTableRow.fromTexts(
            texts: [S.current.valentine_script],
            isHeader: true,
          ),
          for (final script in ce.valentineScript)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) {
                    List<Widget> children = [];
                    for (final region in Region.values) {
                      final ceRelease = db.gameData.mappingData.entityRelease.ofRegion(region);
                      final released = region == Region.jp || ceRelease?.contains(ce.id) == true;
                      children.add(SimpleDialogOption(
                        onPressed: released
                            ? () {
                                Navigator.pop(context);
                                script.routeTo(region: region);
                              }
                            : null,
                        child: Text(
                          region.localName,
                          style: released
                              ? null
                              : TextStyle(
                                  color: Theme.of(context).disabledColor,
                                ),
                        ),
                      ));
                    }
                    return SimpleDialog(children: children);
                  },
                );
              },
              style: kTextButtonDenseStyle,
              child: Text(
                '${script.scriptId} ${Transl.ceNames(script.scriptName).l}',
                textAlign: TextAlign.center,
              ),
            )
        ],
        CustomTableRow(children: [TableCellData(text: S.current.skill, isHeader: true)]),
        for (final skill in ce.skills..sort2((e) => e.svt.num * 100 + e.svt.priority)) SkillDescriptor(skill: skill),
        CustomTableRow(children: [TableCellData(text: S.current.characters_in_card, isHeader: true)]),
        CustomTableRow(children: [TableCellData(child: localizeCharacters(context))]),
        CustomTableRow(children: [TableCellData(text: S.current.card_description, isHeader: true)]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: getProfiles().toList(),
          ),
        ),
        CustomTableRow.fromTexts(
          texts: [
            ce.script?.maleImage != null
                ? '${S.current.illustration} (${S.current.guda_female})'
                : S.current.illustration,
          ],
          isHeader: true,
        ),
        ExtraAssetsPage(
          assets: ce.extraAssets,
          scrollable: false,
          charaGraphPlaceholder: (_, __) => db.getIconImage(ce.cardBack),
        ),
        if (ce.script?.maleImage != null) ...[
          CustomTableRow.fromTexts(texts: [S.current.guda_male], isHeader: true),
          ExtraAssetsPage(
            assets: ce.script!.maleImage!,
            scrollable: false,
            charaGraphPlaceholder: (_, __) => db.getIconImage(ce.cardBack),
          ),
        ],
        if (showExtra && summons.isNotEmpty) ...[
          CustomTableRow(children: [TableCellData(text: S.current.summon_banner, isHeader: true)]),
          CustomTableRow(children: [
            TableCellData(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var summon in summons)
                  ListTile(
                    title: Text(summon.lName.l, maxLines: 1),
                    trailing: summon.startTime.jp == null
                        ? null
                        : Text(
                            'JP: ${summon.startTime.jp!.sec2date().toDateString()}',
                            style: const TextStyle(fontSize: 12),
                          ),
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

  Iterable<Widget> getProfiles() sync* {
    final profiles = <String?>{
      for (final comment in ce.profile.comments) comment.comment,
      if (!Transl.isJP) ce.extra.profile.l,
      ce.extra.profile.ofRegion(Region.jp),
    };
    for (final profile in profiles.whereType<String>()) {
      yield ProfileCommentCard(
        title: Text(S.current.card_description),
        comment: profile,
      );
    }
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
            style: TextStyle(color: AppTheme(context).tertiary),
          ),
          onTap: () => router.push(url: svt.route),
        ));
      }
    }
    for (final name in ce.extra.unknownCharacters) {
      children.add(InkWell(
        child: Text(
          Transl.charaNames(name).l,
          style: TextStyle(color: AppTheme(context).tertiary, decoration: TextDecoration.underline),
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
    List<LimitedSummon> summons =
        db.gameData.wiki.summons.values.where((summon) => summon.hasPickupCE(ce.collectionNo)).toList();
    summons.sort2((e) => e.startTime.jp ?? 0, reversed: true);
    return summons;
  }

  Widget cardBackPlaceholder(BuildContext context, String? url) {
    final color = Atlas.classColor(ce.rarity);
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
        style: kTextButtonDenseStyle,
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
        lvs: ce.curveData.lv,
        atks: ce.atkGrowth,
        hps: ce.hpGrowth,
        maxX: ce.lvMax,
        avatar: ce.iconBuilder(
          context: context,
          height: 56,
          jumpToDetail: false,
        ),
      ),
    );
  }
}
