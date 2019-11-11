import 'package:chaldea/components/components.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtInfoTab extends SvtTabBaseWidget {
  SvtInfoTab(
      {Key key, ServantDetailPageState parent, Servant svt, ServantPlan plan})
      : super(key: key, parent: parent, svt: svt, plan: plan);

  @override
  _SvtInfoTabState createState() =>
      _SvtInfoTabState(parent: parent, svt: svt, plan: plan);
}

class _SvtInfoTabState extends SvtTabBaseState<SvtInfoTab>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  TabController _tabController;

  _SvtInfoTabState(
      {ServantDetailPageState parent, Servant svt, ServantPlan plan})
      : super(parent: parent, svt: svt, plan: plan);
  bool useLangCN = true;

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
                  useLangCN = i == 0;
                });
              },
              children: List.generate(
                  2,
                  (i) => Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(['中文', '日本語'][i]),
                      )),
              isSelected: List.generate(2, (i) => useLangCN == (i == 0)),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(controller: _tabController, children: [
            buildBaseInfoTab(),
            buildProfileTab(),
            buildBondCraftEssenceTab(),
            buildBondCraftEssenceTab()
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
                  child: Image.file(
                      db.getIconFile(svt.treasureDevice.first.color),
                      height: 110 * 0.5),
                  flex: 2),
              InfoCell(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: svt.info.cards
                          .map((e) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: Image.file(
                                  db.getIconFile(e),
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
    bool hasCharaInfo = svt.profiles.first.loreText.isNotEmpty;
    return ListView(
      children: List.generate(7, (i) {
        final lore = svt.profiles[hasCharaInfo ? i : i + 1];
        String label =
            hasCharaInfo ? i == 0 ? '角色详情' : '个人资料$i' : '个人资料${i + 1}';
        String text = useLangCN ? lore.loreText : lore.loreTextJp;
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

  Widget buildBondCraftEssenceTab() {
    return Center(
      child: Text('礼装'),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class InfoRow extends StatelessWidget {
  final List<Widget> children;
  final Color color;

  const InfoRow({Key key, this.children, this.color}) : super(key: key);

  InfoRow.fromText({List<String> texts, this.color})
      : children = texts.map((e) => InfoCell(text: e, color: color)).toList();

  InfoRow.fromChild({List<Widget> children, this.color})
      : children =
            children.map((e) => InfoCell(child: e, color: color)).toList();

  @override
  Widget build(BuildContext context) {
    //TODO: fix bgColor not all filled
    return Container(
      decoration: BoxDecoration(
          color: color,
          border: Border(
            top: InfoCell.borderSide,
            bottom: InfoCell.borderSide,
          )),
      child: Row(
        children: children,
      ),
    );
  }
}

class InfoCell extends StatelessWidget {
  final Color color;
  final String text;
  final Widget child;
  final int flex;
  final Alignment alignment;

  static const borderSide =
      BorderSide(color: Color.fromRGBO(162, 169, 177, 1), width: 0.3);
  static const headerColor = Color.fromRGBO(234, 235, 238, 1);

  const InfoCell({
    Key key,
    this.text,
    this.child,
    this.flex = 1,
    this.color,
    this.alignment = Alignment.center,
  })  : assert(text == null || child == null),
        super(key: key);

  const InfoCell.header({
    Key key,
    this.text,
    this.child,
    this.flex = 1,
    this.alignment = Alignment.center,
  })  : color = headerColor,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _child;
    if (child != null) {
      _child = child;
    } else {
      _child = Text(
        text,
        textAlign: TextAlign.center,
      );
    }
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border(left: borderSide, right: borderSide),
        ),
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: _child,
          ),
        ),
      ),
    );
  }
}
