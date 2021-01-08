import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/craft/craft_detail_page.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtInfoTab extends SvtTabBaseWidget {
  SvtInfoTab(
      {Key key,
      ServantDetailPageState parent,
      Servant svt,
      ServantStatus status})
      : super(key: key, parent: parent, svt: svt, status: status);

  @override
  _SvtInfoTabState createState() =>
      _SvtInfoTabState(parent: parent, svt: svt, plan: status);
}

class _SvtInfoTabState extends SvtTabBaseState<SvtInfoTab>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  _SvtInfoTabState(
      {ServantDetailPageState parent, Servant svt, ServantStatus plan})
      : super(parent: parent, svt: svt, status: plan);
  bool useLangJp = false;

  @override
  void initState() {
    super.initState();
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
                tabs: ['基础资料', '羁绊故事', '羁绊礼装', '情人节礼装']
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
                  useLangJp = i == 1;
                });
              },
              children: List.generate(
                  2,
                  (i) => Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(['中文', '日本語'][i]),
                      )),
              isSelected: List.generate(2, (i) => useLangJp == (i == 1)),
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
    final headerData = TableCellData(isHeader: true);
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
          CustomTableRow.fromTexts(texts: ['画师', '声优'], defaults: headerData),
          CustomTableRow.fromTexts(
              texts: [svt.info.illustrator, svt.info.cv.join(', ')],
              defaults: contentData),
          CustomTableRow.fromTexts(
              texts: ['性别', '身高', '体重'], defaults: headerData),
          CustomTableRow.fromTexts(
              texts: [svt.info.gender, svt.info.height, svt.info.weight],
              defaults: contentData),
          CustomTableRow.fromTexts(
              texts: ['筋力', '耐久', '敏捷', '魔力', '幸运', '宝具'],
              defaults: headerData),
          CustomTableRow.fromTexts(
              texts: ['strength', 'endurance', 'agility', 'mana', 'luck', 'np']
                  .map((e) => svt.info.ability[e])
                  .toList(),
              defaults: contentData),
          CustomTableRow.fromTexts(texts: ['特性'], defaults: headerData),
          CustomTableRow.fromTexts(
              texts: [svt.info.traits.join(', ')], defaults: contentData),
          CustomTableRow(children: [
            TableCellData(text: '人形', isHeader: true, flex: 1),
            TableCellData(text: '被EA特攻', isHeader: true, flex: 2),
            TableCellData(text: '属性', isHeader: true, flex: 3),
          ]),
          CustomTableRow(children: [
            TableCellData(text: svt.info.isHumanoid ? '是' : '否', flex: 1),
            TableCellData(text: svt.info.isWeakToEA ? '是' : '否', flex: 2),
            TableCellData(
                text: svt.info.alignments.join('·'),
                flex: 2,
                textAlign: TextAlign.center),
            TableCellData(text: svt.info.attribute, flex: 1),
          ]),
          if (!Servant.unavailable.contains(svt.no)) ...[
            CustomTableRow.fromTexts(
                texts: ['数值', '1级', '满级', '90级', '100级', 'MAX'],
                defaults: headerData),
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
            CustomTableRow.fromTexts(texts: ['配卡'], defaults: headerData),
            CustomTableRow(children: [
              TableCellData(
                child: Image(
                  image: db.getIconImage(svt.treasureDevice.first.color),
                  height: 110 * 0.5,
                ),
                flex: 1,
              ),
              TableCellData(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: svt.info.cards
                      .map((e) =>
                          Image(image: db.getIconImage(e), height: 110 * 0.4))
                      .toList(),
                ),
                flex: 3,
              )
            ]),
            CustomTableRow.fromTexts(texts: ['Hits信息'], defaults: headerData),
            for (String card in svt.info.cardHits.keys)
              CustomTableRow(children: [
                TableCellData(text: card, isHeader: true),
                TableCellData(
                  text: svt.info.cardHits[card] == 0
                      ? '   -'
                      : '   ${svt.info.cardHits[card]} Hits '
                          '(${svt.info.cardHitsDamage[card].join(', ')})',
                  flex: 5,
                  alignment: Alignment.centerLeft,
                )
              ]),
            CustomTableRow.fromTexts(texts: ['NP获得率'], defaults: headerData),
            CustomTableRow.fromTexts(
                texts: svt.info.npRate.keys.toList(),
                defaults: TableCellData(isHeader: true, maxLines: 1)),
            CustomTableRow.fromTexts(texts: svt.info.npRate.values.toList()),
            CustomTableRow.fromTexts(
                texts: ['出星率', '被即死率', '暴击权重'], defaults: headerData),
            CustomTableRow.fromTexts(
              texts: [
                svt.info.starRate,
                svt.info.deathRate,
                svt.info.criticalRate
              ],
            ),
            if (svt.bondPoints != null) ...[
              CustomTableRow.fromTexts(texts: ['羁绊点数'], defaults: headerData),
              CustomTableRow.fromTexts(
                texts: ['Lv.', '1', '2', '3', '4', '5'],
                defaults: TableCellData(
                    color: TableCellData.headerColor.withOpacity(0.3)),
              ),
              CustomTableRow.fromTexts(
                texts: [
                  '点数',
                  for (var i = 0; i < 5; i++) svt.bondPoints[i].toString()
                ],
                defaults: TableCellData(maxLines: 1),
              ),
              CustomTableRow.fromTexts(
                texts: [
                  '累计',
                  for (var i = 0; i < 5; i++)
                    sum(svt.bondPoints.sublist(0, i + 1)).toString()
                ],
                defaults: TableCellData(maxLines: 1),
              ),
              CustomTableRow.fromTexts(
                texts: ['Lv.', '6', '7', '8', '9', '10'],
                defaults: TableCellData(
                    color: TableCellData.headerColor.withOpacity(0.3)),
              ),
              CustomTableRow.fromTexts(
                texts: [
                  '点数',
                  for (var i = 5; i < 10; i++) svt.bondPoints[i].toString()
                ],
                defaults: TableCellData(maxLines: 1),
              ),
              CustomTableRow.fromTexts(
                texts: [
                  '累计',
                  for (var i = 5; i < 10; i++)
                    sum(svt.bondPoints.sublist(0, i + 1)).toString()
                ],
                defaults: TableCellData(maxLines: 1),
              ),
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
            useLangJp ? profile.descriptionJp : profile.description;
        if (description == null || description.isEmpty) {
          description = '???';
        }
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: Theme.of(context).cardColor.withOpacity(0.975),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomTile(title: Text(profile.title)),
              CustomTile(subtitle: Text(description)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildBondCraftTab() {
    if (svt.bondCraft != null && svt.bondCraft > 0) {
      return CraftDetailBasePage(
          ce: db.gameData.crafts[svt.bondCraft], useLangJp: useLangJp);
    } else {
      return Center(child: Text('无羁绊礼装'));
    }
  }

  Widget buildValentineCraftTab() {
    if (svt.valentineCraft?.isNotEmpty == true) {
      // mash has two valentine crafts
      return ListView.separated(
        itemBuilder: (context, index) => CraftDetailBasePage(
            ce: db.gameData.crafts[svt.valentineCraft[index]],
            useLangJp: useLangJp),
        separatorBuilder: (context, index) => Divider(height: 20),
        itemCount: svt.valentineCraft.length,
      );
    } else {
      return Center(child: Text('无情人节礼装'));
    }
  }
}
