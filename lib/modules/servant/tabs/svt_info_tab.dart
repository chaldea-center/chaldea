//@dart=2.12
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/craft/craft_detail_page.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtInfoTab extends SvtTabBaseWidget {
  SvtInfoTab({
    Key? key,
    ServantDetailPageState? parent,
    Servant? svt,
    ServantStatus? status,
  }) : super(key: key, parent: parent, svt: svt, status: status);

  @override
  _SvtInfoTabState createState() =>
      _SvtInfoTabState(parent: parent, svt: svt, plan: status);
}

class _SvtInfoTabState extends SvtTabBaseState<SvtInfoTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  _SvtInfoTabState(
      {ServantDetailPageState? parent, Servant? svt, ServantStatus? plan})
      : super(parent: parent, svt: svt, status: plan);
  bool useLangCn = false;

  @override
  void initState() {
    super.initState();
    useLangCn = Language.isCN;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  S.of(context).svt_info_tab_base,
                  S.of(context).svt_info_tab_bond_story,
                  S.of(context).bond_craft,
                  S.of(context).valentine_craft
                ]
                    .map((tabName) => Tab(
                            child: Text(
                          tabName,
                          style: TextStyle(color: Colors.black87),
                        )))
                    .toList(),
              ),
            ),
            ToggleButtons(
              constraints: BoxConstraints(),
              selectedColor: Colors.white,
              fillColor: Theme.of(context).primaryColor,
              onPressed: (i) {
                setState(() {
                  useLangCn = i == 0;
                });
              },
              children: List.generate(
                  2,
                  (i) => Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(['中', '日'][i]),
                      )),
              isSelected: List.generate(2, (i) => useLangCn == (i == 0)),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(controller: _tabController, children: [
            buildBaseInfoTab(),
            buildProfileTab(),
            buildBondCraftTab(),
            buildValentineCraftTab()
          ]),
        ),
      ],
    );
  }

  Widget buildBaseInfoTab() {
    final headerData = TableCellData(isHeader: true, maxLines: 1);
    final contentData = TableCellData(textAlign: TextAlign.center);
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 10),
      child: CustomTable(
        children: <Widget>[
          CustomTableRow.fromChildren(
            children: [
              Text(svt.info.name, style: TextStyle(fontWeight: FontWeight.bold))
            ],
            defaults: headerData,
          ),
          CustomTableRow.fromTexts(
              texts: [svt.info.nameJp], defaults: contentData),
          CustomTableRow.fromTexts(
              texts: [svt.info.nameEn], defaults: contentData),
          CustomTableRow.fromTexts(
              texts: ['No.${svt.no}', svt.info.className],
              defaults: contentData),
          CustomTableRow.fromTexts(
              texts: [S.current.illustrator, S.current.info_cv],
              defaults: headerData),
          CustomTableRow.fromTexts(
              texts: [svt.info.illustrator, svt.info.cv.join(', ')],
              defaults: contentData),
          CustomTableRow.fromTexts(texts: [
            S.current.info_gender,
            S.current.info_height,
            S.current.info_weight
          ], defaults: headerData),
          CustomTableRow.fromTexts(
              texts: [svt.info.gender, svt.info.height, svt.info.weight],
              defaults: contentData),
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
              texts: [svt.info.traits.join(', ')], defaults: contentData),
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
                text: svt.info.alignments.join('·'),
                flex: 2,
                textAlign: TextAlign.center),
            TableCellData(text: svt.info.attribute, flex: 1),
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
              TableCellData(text: 'ATK', isHeader: true),
              TableCellData(text: svt.info.atkMin.toString()),
              TableCellData(text: svt.info.atkMax.toString()),
              TableCellData(text: svt.info.atk90.toString()),
              TableCellData(text: svt.info.atk100.toString()),
              TableCellData(text: (svt.info.atk100 + 2000).toString()),
            ]),
            CustomTableRow(children: [
              TableCellData(text: 'HP', isHeader: true),
              TableCellData(text: svt.info.hpMin.toString()),
              TableCellData(text: svt.info.hpMax.toString()),
              TableCellData(text: svt.info.hp90.toString()),
              TableCellData(text: svt.info.hp100.toString()),
              TableCellData(text: (svt.info.hp100 + 2000).toString()),
            ]),
            CustomTableRow.fromTexts(
                texts: [S.current.info_cards], defaults: headerData),
            CustomTableRow(children: [
              TableCellData(
                child:
                    db.getIconImage(svt.nobelPhantasm.first.color, height: 55),
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
            CustomTableRow.fromTexts(texts: ['Hits'], defaults: headerData),
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
            CustomTableRow.fromTexts(texts: svt.info.npRate.values.toList()),
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
            ),
            if (svt.bondPoints != null && svt.bondPoints.length > 0) ...[
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
                      color: TableCellData.headerColor.withOpacity(0.5)),
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
    return ListView(
      children: List.generate(svt.profiles.length, (index) {
        final profile = svt.profiles[index];
        String description =
            (useLangCn ? profile.description : profile.descriptionJp) ?? '???';
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: Theme.of(context).cardColor.withOpacity(0.975),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomTile(
                title: Text(profile.title),
                subtitle:
                    profile.condition == null ? null : Text(profile.condition),
              ),
              CustomTile(subtitle: Text(description)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildBondCraftTab() {
    if (svt.bondCraft != null && svt.bondCraft > 0) {
      final ce = db.gameData.crafts[svt.bondCraft];
      if (ce == null) {
        return Container();
      } else {
        return CraftDetailBasePage(ce: ce, useLangCn: useLangCn);
      }
    } else {
      return Center(child: Text(S.of(context).hint_no_bond_craft));
    }
  }

  Widget buildValentineCraftTab() {
    if (svt.valentineCraft?.isNotEmpty == true) {
      // mash has two valentine crafts
      return ListView.separated(
        itemBuilder: (context, index) {
          final ce = db.gameData.crafts[svt.valentineCraft[index]];
          if (ce == null) return Container();
          return CraftDetailBasePage(ce: ce, useLangCn: useLangCn);
        },
        separatorBuilder: (context, index) => Divider(height: 20),
        itemCount: svt.valentineCraft.length,
      );
    } else {
      return Center(child: Text(S.of(context).hint_no_valentine_craft));
    }
  }
}
