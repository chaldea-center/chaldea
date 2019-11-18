import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/tile_items.dart';

class CraftDetailPage extends StatefulWidget {
  final CraftEssential ce;

  const CraftDetailPage({Key key, this.ce}) : super(key: key);

  @override
  _CraftDetailPageState createState() => _CraftDetailPageState();
}

class _CraftDetailPageState extends State<CraftDetailPage> {
  bool useLangJp = false;
  CraftEssential ce;

  @override
  void initState() {
    super.initState();
    ce = widget.ce;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(ce.name),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                InfoRow.fromChild(
                  children: [
                    Text(ce.name, style: TextStyle(fontWeight: FontWeight.bold))
                  ],
                  color: InfoCell.headerColor,
                ),
                InfoRow.fromText(texts: [ce.nameJp]),
                InfoRow(
                  children: <Widget>[
                    InfoCell(
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: Image(
                          image: db.getIconFile(ce.icon),
                          height: 90,
                        ),
                      ),
                    ),
                    InfoCell(
                      flex: 3,
                      padding: EdgeInsets.zero,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          InfoRow.fromText(texts: ['No. ${ce.no}']),
                          InfoRow(
                            children: <Widget>[
                              InfoCell.header(text: '画师'),
                              InfoCell(
                                  text: ce.illustrator.join(' & '), flex: 3)
                            ],
                          ),
                          InfoRow(
                            children: <Widget>[
                              InfoCell.header(text: '稀有度'),
                              InfoCell(text: ce.rarity.toString()),
                              InfoCell.header(text: 'COST'),
                              InfoCell(text: ce.cost.toString())
                            ],
                          ),
                          InfoRow(
                            children: <Widget>[
                              InfoCell.header(text: 'ATK'),
                              InfoCell(text: '${ce.atkMin}/${ce.atkMax}'),
                              InfoCell.header(text: 'HP'),
                              InfoCell(text: '${ce.hpMin}/${ce.hpMax}')
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                InfoRow.fromChild(
                  children: <Widget>[
                    CustomTile(
                      title: Center(child: Text('查看卡面')),
                      onTap: () {},
                      contentPadding: EdgeInsets.zero,
                    )
                  ],
                  color: InfoCell.headerColor,
                ),
                InfoRow.fromText(texts: ['持有技能'], color: InfoCell.headerColor),
                InfoRow(
                  children: <Widget>[
                    InfoCell(
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: Image(
                            image: db.getIconFile(ce.skillIcon), height: 40),
                      ),
                    ),
                    InfoCell(
                        flex: 3,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(ce.skill),
                            Divider(height: 2),
                            Text(ce.skillMax ?? '---'),
                          ],
                        )),
                  ],
                ),
                for (var i = 0; i < ce.eventIcons.length; i++)
                  InfoRow(
                    children: <Widget>[
                      InfoCell(
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Image(
                              image: db.getIconFile(ce.eventIcons[i]),
                              height: 40),
                        ),
                      ),
                      InfoCell(flex: 3, text: ce.eventSkills[i]),
                    ],
                  ),
                InfoRow.fromChild(children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: Center(child: Text('解说'))),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            useLangJp = !useLangJp;
                          });
                        },
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Text('日文'),
                            Icon(
                              useLangJp
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 18,
                            )
                          ],
                        ),
                      ),
                      Container(width: 20)
                    ],
                  )
                ], color: InfoCell.headerColor),
                InfoRow.fromText(
                  texts: [useLangJp ? ce.descriptionJp : ce.description],
                )
              ],
            ),
          ),
          ButtonBar(
              alignment: MainAxisAlignment.center,
              children: List.generate(2, (i) {
                return RaisedButton(
                  onPressed: () {
                    int nextNo = ce.no + [-1, 1][i];
                    if (db.gameData.crafts.containsKey(nextNo)) {
                      setState(() {
                        ce = db.gameData.crafts[nextNo];
                        print('move to craft No.${ce.no}-${ce.name}');
                      });
                    } else {
//                      Scaffold.of(context).showSnackBar(SnackBar(
//                        content: Text('已经是${['第', '最后'][i]}一张'),
//                        duration: Duration(milliseconds: 500),
//                      ));
                    }
                  },
                  child: Text(['上一张', '下一张'][i]),
                  color: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 40),
                );
              }))
        ],
      ),
    );
  }
}
