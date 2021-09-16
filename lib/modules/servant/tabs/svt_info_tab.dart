import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/cmd_code/cmd_code_detail_page.dart';
import 'package:chaldea/modules/craft/craft_detail_page.dart';
import 'package:chaldea/modules/shared/lang_switch.dart';
import 'package:flutter/foundation.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtInfoTab extends SvtTabBaseWidget {
  const SvtInfoTab({
    Key? key,
    ServantDetailPageState? parent,
    Servant? svt,
    ServantStatus? status,
  }) : super(key: key, parent: parent, svt: svt, status: status);

  @override
  _SvtInfoTabState createState() => _SvtInfoTabState();
}

class _SvtInfoTabState extends SvtTabBaseState<SvtInfoTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Language? lang;

  bool get hasBondCraft => svt.bondCraft > 0;

  bool get hasValentineCraft => svt.valentineCraft.isNotEmpty;

  bool get hasRelatedCards =>
      _relatedCrafts.isNotEmpty || _relatedCodes.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _relatedCrafts = db.gameData.crafts.values
        .where((e) => e.characters.contains(svt.mcLink))
        .toList();
    _relatedCodes = db.gameData.cmdCodes.values
        .where((e) => e.characters.contains(svt.mcLink))
        .toList();

    int count = 2 +
        (hasBondCraft ? 1 : 0) +
        (hasValentineCraft ? 1 : 0) +
        (hasRelatedCards ? 1 : 0);
    _tabController = TabController(length: count, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: 36,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: [
                    S.of(context).svt_info_tab_base,
                    S.of(context).svt_info_tab_bond_story,
                    if (hasBondCraft) S.of(context).bond_craft,
                    if (hasValentineCraft) S.of(context).valentine_craft,
                    if (hasRelatedCards) S.of(context).svt_related_cards,
                  ].map((tabName) => getTab(tabName)).toList(),
                ),
              ),
            ),
            ProfileLangSwitch(
              primary: lang,
              onChanged: (v) {
                setState(() {
                  lang = v;
                });
              },
            ),
          ],
        ),
        Expanded(
          child: TabBarView(controller: _tabController, children: [
            buildBaseInfoTab(),
            buildProfileTab(),
            if (hasBondCraft) buildBondCraftTab(),
            if (hasValentineCraft) buildValentineCraftTab(),
            if (hasRelatedCards) buildRelatedCards(),
          ]),
        ),
      ],
    );
  }

  Widget buildBaseInfoTab() {
    final headerData = TableCellData(isHeader: true, maxLines: 1);
    final contentData = TableCellData(textAlign: TextAlign.center, maxLines: 1);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomTable(
        children: <Widget>[
          CustomTableRow.fromChildren(
            children: [
              Text(svt.info.name,
                  style: const TextStyle(fontWeight: FontWeight.bold))
            ],
            defaults: headerData,
          ),
          CustomTableRow.fromTexts(
              texts: [svt.info.nameJp], defaults: contentData),
          CustomTableRow.fromTexts(
              texts: [svt.info.nameEn], defaults: contentData),
          if (!kReleaseMode)
            CustomTableRow.fromTexts(
                texts: ['No.${svt.svtId}'], defaults: contentData),
          CustomTableRow.fromTexts(
              texts: ['No.${svt.originNo}', svt.info.className],
              defaults: contentData),
          CustomTableRow.fromTexts(
              texts: [S.current.illustrator, S.current.info_cv],
              defaults: headerData),
          CustomTableRow.fromTexts(
              texts: [svt.info.lIllustrator, svt.info.lCV.join(', ')],
              defaults: contentData),
          CustomTableRow.fromTexts(texts: [
            S.current.info_gender,
            S.current.info_height,
            S.current.info_weight
          ], defaults: headerData),
          CustomTableRow.fromTexts(texts: [
            Localized.gender.of(svt.info.gender),
            svt.info.height,
            svt.info.weight
          ], defaults: contentData),
          CustomTableRow.fromTexts(texts: [
            S.current.info_strength,
            S.current.info_endurance,
            S.current.info_agility,
            S.current.info_mana,
            S.current.info_luck,
            S.current.info_np
          ], defaults: headerData),
          CustomTableRow.fromTexts(
              texts: ['strength', 'endurance', 'agility', 'mana', 'luck', 'np']
                  .map((e) => svt.info.ability[e] ?? '?')
                  .toList(),
              defaults: contentData),
          CustomTableRow.fromTexts(
              texts: [S.current.info_trait], defaults: headerData),
          CustomTableRow.fromTexts(
            texts: [
              svt.info.traits.map((e) => Localized.svtFilter.of(e)).join(', ')
            ],
            defaults: TableCellData(textAlign: TextAlign.center),
          ),
          CustomTableRow(children: [
            TableCellData(text: S.current.info_human, isHeader: true, flex: 1),
            TableCellData(
                text: S.current.info_weak_to_ea, isHeader: true, flex: 2),
            TableCellData(
                text: S.current.info_alignment, isHeader: true, flex: 3),
          ]),
          CustomTableRow(children: [
            TableCellData(
                text: svt.info.isHumanoid ? S.current.yes : S.current.no,
                flex: 1),
            TableCellData(
                text: svt.info.isWeakToEA ? S.current.yes : S.current.no,
                flex: 2),
            TableCellData(
                text: svt.info.alignments
                    .map((e) => Localized.svtFilter.of(e))
                    .join('·'),
                flex: 2,
                textAlign: TextAlign.center),
            TableCellData(
                text: Localized.svtFilter.of(svt.info.attribute), flex: 1),
          ]),
          if (!Servant.unavailable.contains(svt.no)) ...[
            CustomTableRow.fromTexts(texts: [
              S.current.info_value,
              'Lv.1',
              'Lv.Max',
              'Lv.90',
              'Lv.100',
              'MAX'
            ], defaults: headerData),
            CustomTableRow(children: [
              TableCellData(text: 'ATK', isHeader: true, maxLines: 1),
              TableCellData(text: svt.info.atkMin.toString(), maxLines: 1),
              TableCellData(text: svt.info.atkMax.toString(), maxLines: 1),
              TableCellData(text: svt.info.atk90.toString(), maxLines: 1),
              TableCellData(text: svt.info.atk100.toString(), maxLines: 1),
              TableCellData(
                  text: (svt.info.atk100 + 2000).toString(), maxLines: 1),
            ]),
            CustomTableRow(children: [
              TableCellData(text: 'HP', isHeader: true, maxLines: 1),
              TableCellData(text: svt.info.hpMin.toString(), maxLines: 1),
              TableCellData(text: svt.info.hpMax.toString(), maxLines: 1),
              TableCellData(text: svt.info.hp90.toString(), maxLines: 1),
              TableCellData(text: svt.info.hp100.toString(), maxLines: 1),
              TableCellData(
                  text: (svt.info.hp100 + 2000).toString(), maxLines: 1),
            ]),
            CustomTableRow.fromTexts(
                texts: [S.current.info_cards], defaults: headerData),
            CustomTableRow(children: [
              TableCellData(
                child:
                    db.getIconImage(svt.noblePhantasm.first.color, height: 55),
                flex: 1,
              ),
              TableCellData(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: svt.info.cards
                      .map((e) => db.getIconImage(e, height: 44))
                      .toList(),
                ),
                flex: 3,
              )
            ]),
            CustomTableRow.fromTexts(
                texts: const ['Hits'], defaults: headerData),
            for (String card in svt.info.cardHits.keys)
              CustomTableRow(children: [
                TableCellData(text: card, isHeader: true),
                TableCellData(
                  text: svt.info.cardHits[card] == 0
                      ? '   -'
                      : '   ${svt.info.cardHits[card]} Hits '
                          '(${svt.info.cardHitsDamage[card]?.join(', ')})',
                  flex: 5,
                  alignment: Alignment.centerLeft,
                )
              ]),
            CustomTableRow.fromTexts(
                texts: [S.current.info_np_rate], defaults: headerData),
            CustomTableRow.fromTexts(
                texts: svt.info.npRate.keys.toList(),
                defaults: TableCellData(isHeader: true, maxLines: 1)),
            CustomTableRow.fromTexts(
                texts: svt.info.npRate.values.toList(), defaults: contentData),
            CustomTableRow.fromTexts(texts: [
              S.current.info_star_rate,
              S.current.info_death_rate,
              S.current.info_critical_rate
            ], defaults: headerData),
            CustomTableRow.fromTexts(
              texts: [
                svt.info.starRate,
                svt.info.deathRate,
                svt.info.criticalRate
              ],
              defaults: contentData,
            ),
            if (svt.bondPoints.isNotEmpty) ...[
              CustomTableRow.fromTexts(
                  texts: [S.current.info_bond_points], defaults: headerData),
              for (int row = 0; row < svt.bondPoints.length / 5; row++) ...[
                CustomTableRow.fromTexts(
                  texts: [
                    'Lv.',
                    for (int i = row * 5; i < row * 5 + 5; i++)
                      (i + 1).toString()
                  ],
                  defaults: TableCellData(
                      color: TableCellData.resolveHeaderColor(context)
                          .withOpacity(0.5)),
                ),
                CustomTableRow.fromTexts(
                  texts: [
                    S.of(context).info_bond_points_single,
                    for (int i = row * 5; i < row * 5 + 5; i++)
                      i >= svt.bondPoints.length
                          ? '-'
                          : svt.bondPoints[i].toString()
                  ],
                  defaults: TableCellData(maxLines: 1),
                ),
                CustomTableRow.fromTexts(
                  texts: [
                    S.of(context).info_bond_points_sum,
                    for (int i = row * 5; i < row * 5 + 5; i++)
                      i >= svt.bondPoints.length
                          ? '-'
                          : sum(svt.bondPoints.sublist(0, i + 1)).toString()
                  ],
                  defaults: TableCellData(maxLines: 1),
                ),
              ],
            ]
          ] //end available svts
        ],
      ),
    );
  }

  Widget buildProfileTab() {
    List<Widget> children = [];
    for (int index = 0; index < svt.profiles.length; index++) {
      final profile = svt.profiles[index];
      if (profile.description?.isNotEmpty != true &&
          profile.descriptionJp?.isNotEmpty != true &&
          profile.descriptionEn?.isNotEmpty != true) {
        continue;
      }
      String title;
      if (profile.title == 'aprilfool') {
        title = title = LocalizedText.of(
            chs: '愚人节资料', jpn: 'エイプリルフール', eng: "April Fools' Day");
      } else if (profile.title == '0') {
        title = LocalizedText.of(
            chs: '角色详情', jpn: 'キャラクター詳細', eng: 'Character Profile');
      } else {
        title = LocalizedText.of(chs: '个人资料', jpn: 'プロフィール', eng: 'Profile ') +
            profile.title.toString();
      }

      String condition = LocalizedText(
              chs: profile.condition, jpn: null, eng: profile.conditionEn)
          .ofPrimary(lang ?? Language.current);
      children.add(Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: Theme.of(context).cardColor.withOpacity(0.975),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomTile(
              title: Text(title),
              subtitle: condition.isEmpty ? null : Text(condition),
            ),
            CustomTile(
              subtitle: Text(LocalizedText(
                      chs: profile.description,
                      jpn: profile.descriptionJp,
                      eng: profile.descriptionEn)
                  .ofPrimary(lang ?? Language.current)),
            ),
          ],
        ),
      ));
    }
    return ListView(children: children);
  }

  Widget buildBondCraftTab() {
    if (svt.bondCraft > 0) {
      final ce = db.gameData.crafts[svt.bondCraft];
      if (ce == null) {
        return Container();
      } else {
        return CraftDetailBasePage(ce: ce, lang: lang);
      }
    } else {
      return Center(child: Text(S.of(context).hint_no_bond_craft));
    }
  }

  Widget buildValentineCraftTab() {
    if (svt.valentineCraft.isNotEmpty) {
      // mash has two valentine crafts
      return ListView.separated(
        itemBuilder: (context, index) {
          final ce = db.gameData.crafts[svt.valentineCraft[index]];
          if (ce == null) return Container();
          return CraftDetailBasePage(ce: ce, lang: lang);
        },
        separatorBuilder: (context, index) => const Divider(height: 20),
        itemCount: svt.valentineCraft.length,
      );
    } else {
      return Center(child: Text(S.of(context).hint_no_valentine_craft));
    }
  }

  List<CraftEssence> _relatedCrafts = [];
  List<CommandCode> _relatedCodes = [];

  Widget buildRelatedCards() {
    List<Widget> craftChildren = [];
    _relatedCrafts.forEach((ce) {
      if (ce.characters.contains(svt.mcLink)) {
        craftChildren.add(ListTile(
          leading: ImageWithText(
              image:
                  db.getIconImage(ce.icon, height: 45, width: 45 / 144 * 132)),
          title: Text(ce.lName),
          onTap: () {
            SplitRoute.push(
              context,
              CraftDetailPage(
                ce: ce,
                onSwitch: (cur, next) => Utils.findNextOrPrevious<CraftEssence>(
                    list: _relatedCrafts, cur: cur, reversed: next),
              ),
            );
          },
        ));
      }
    });
    List<Widget> codeChildren = [];
    _relatedCodes.forEach((code) {
      if (code.characters.contains(svt.mcLink)) {
        codeChildren.add(ListTile(
          leading: ImageWithText(
              image: db.getIconImage(code.icon,
                  height: 45, width: 45 / 144 * 132)),
          title: Text(code.lName),
          onTap: () {
            SplitRoute.push(
              context,
              CmdCodeDetailPage(
                code: code,
                onSwitch: (cur, next) => Utils.findNextOrPrevious<CommandCode>(
                    list: _relatedCodes, cur: cur, reversed: next),
              ),
            );
          },
        ));
      }
    });
    return ListView(
      children: [
        if (craftChildren.isEmpty && codeChildren.isEmpty)
          const ListTile(
            title: Text('No related craft essence or command code'),
          ),
        if (craftChildren.isNotEmpty)
          TileGroup(
            header: S.current.craft_essence,
            children: craftChildren,
          ),
        if (codeChildren.isNotEmpty)
          TileGroup(
            header: S.current.command_code,
            children: codeChildren,
          )
      ],
    );
  }
}
