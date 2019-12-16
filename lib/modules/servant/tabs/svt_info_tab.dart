import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/craft/craft_detail_page.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtInfoTab extends SvtTabBaseWidget {
  SvtInfoTab(
      {Key key, ServantDetailPageState parent, Servant svt, ServantStatus plan})
      : super(key: key, parent: parent, svt: svt, status: plan);

  @override
  _SvtInfoTabState createState() =>
      _SvtInfoTabState(parent: parent, svt: svt, plan: status);
}

class _SvtInfoTabState extends SvtTabBaseState<SvtInfoTab>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
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
    return ListView(
      children: <Widget>[
        InfoRow.fromChild(
          children: [
            Text(svt.info.name, style: TextStyle(fontWeight: FontWeight.bold))
          ],
          color: InfoCell.headerColor,
        ),
        InfoRow.fromText(texts: [svt.info.nameJp]),
        InfoRow.fromText(texts: [svt.info.nameEn]),
        InfoRow.fromText(texts: ['No.${svt.no}', svt.info.className]),
        InfoRow.fromText(texts: ['画师', '声优'], color: InfoCell.headerColor),
        InfoRow.fromText(texts: [svt.info.illustrator, svt.info.cv.join(', ')]),
        InfoRow.fromText(
            texts: ['性别', '身高', '体重'], color: InfoCell.headerColor),
        InfoRow.fromText(
            texts: [svt.info.gender, svt.info.height, svt.info.weight]),
        InfoRow.fromText(
          texts: ['筋力', '耐久', '敏捷', '魔力', '幸运', '宝具'],
          color: InfoCell.headerColor,
        ),
        InfoRow.fromText(
            texts: ['strength', 'endurance', 'agility', 'mana', 'luck', 'np']
                .map((e) => svt.info.ability[e])
                .toList()),
        InfoRow.fromText(texts: ['特性'], color: InfoCell.headerColor),
        InfoRow.fromText(texts: [svt.info.traits.join(', ')]),
        InfoRow(
          children: <Widget>[
            InfoCell(text: '人形', color: InfoCell.headerColor, flex: 1),
            InfoCell(text: '被EA特攻', color: InfoCell.headerColor, flex: 2),
            InfoCell(text: '属性', color: InfoCell.headerColor, flex: 3)
          ],
        ),
        InfoRow(
          children: <Widget>[
            InfoCell(text: svt.info.isHumanoid ? '是' : '否', flex: 1),
            InfoCell(text: svt.info.isWeakToEA ? '是' : '否', flex: 2),
            InfoCell(text: svt.info.alignments.join('·'), flex: 2),
            InfoCell(text: svt.info.attribute, flex: 1),
          ],
        ),
        if (!Servant.unavailable.contains(svt.no)) ...[
          InfoRow.fromText(
            texts: ['数值', '1级', '满级', '90级', '100级', 'MAX'],
            color: InfoCell.headerColor,
          ),
          InfoRow(
            children: [
              InfoCell.header(
                text: 'ATK',
              ),
              InfoCell(text: svt.info.atkMin.toString()),
              InfoCell(text: svt.info.atkMax.toString()),
              InfoCell(text: svt.info.atk90.toString()),
              InfoCell(text: svt.info.atk100.toString()),
              InfoCell(text: (svt.info.atk100 + 2000).toString()),
            ],
          ),
          InfoRow(
            children: [
              InfoCell.header(text: 'HP'),
              InfoCell(text: svt.info.hpMin.toString()),
              InfoCell(text: svt.info.hpMax.toString()),
              InfoCell(text: svt.info.hp90.toString()),
              InfoCell(text: svt.info.hp100.toString()),
              InfoCell(text: (svt.info.hp100 + 2000).toString()),
            ],
          ),
          InfoRow.fromText(texts: ['配卡'], color: InfoCell.headerColor),
          InfoRow(
            children: <Widget>[
              InfoCell(
                  child: Image(
                      image: db.getIconFile(svt.treasureDevice.first.color),
                      height: 110 * 0.5),
                  flex: 2),
              InfoCell(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: svt.info.cards
                          .map((e) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: Image(
                                  image: db.getIconFile(e),
                                  height: 110 * 0.4,
                                ),
                              ))
                          .toList()),
                  flex: 6)
            ],
          ),
          InfoRow.fromText(texts: ['Hits信息'], color: InfoCell.headerColor),
          for (String card in (svt.info.cardHits.keys))
            InfoRow(
              children: <Widget>[
                InfoCell(text: card, color: InfoCell.headerColor, flex: 1),
                InfoCell(
                  text: svt.info.cardHits[card] == 0
                      ? '   -'
                      : '   ${svt.info.cardHits[card]} Hits '
                          '(${svt.info.cardHitsDamage[card].join(', ')})',
                  flex: 5,
                  alignment: Alignment.centerLeft,
                )
              ],
            ),
          InfoRow.fromText(texts: ['NP获得率'], color: InfoCell.headerColor),
          InfoRow.fromText(
              texts: svt.info.npRate.keys.toList(),
              color: InfoCell.headerColor),
          InfoRow.fromText(
              texts: svt.info.npRate.values.map((v) => '${v / 100}%').toList()),
          InfoRow.fromText(
              texts: ['出星率', '被即死率', '暴击权重'], color: InfoCell.headerColor),
          InfoRow.fromText(
            texts: [
              svt.info.starRate,
              svt.info.deathRate,
              svt.info.criticalRate
            ].map((v) => '${v / 100}%').toList(),
          ),
        ],
        Container(height: 20)
      ],
    );
  }

  Widget buildProfileTab() {
    bool hasCharaInfo = svt.profiles.first.profile.isNotEmpty;
    return ListView(
      children: List.generate(7, (i) {
        final lore = svt.profiles[hasCharaInfo ? i : i + 1];
        String label =
            hasCharaInfo ? i == 0 ? '角色详情' : '个人资料$i' : '个人资料${i + 1}';
        String text = useLangJp ? lore.profileJp : lore.profile;
        if (text.isEmpty) {
          text = '???';
        }
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomTile(title: Text(label)),
              CustomTile(
                subtitle: Text(text),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildBondCraftTab() {
    if (svt.bondCraft != null) {
      return CraftDetailBasePage(
          ce: db.gameData.crafts[svt.bondCraft], useLangJp: useLangJp);
    } else {
      return Center(child: Text('无羁绊礼装'));
    }
  }

  Widget buildValentineCraftTab() {
    if (svt.valentineCraft != null) {
      return CraftDetailBasePage(
          ce: db.gameData.crafts[svt.valentineCraft], useLangJp: useLangJp);
    } else {
      return Center(child: Text('无情人节礼装'));
    }
  }

  @override
  bool get wantKeepAlive => true;
}
