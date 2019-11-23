import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    db.checkNetwork();
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
            child: CraftDetailBasePage(ce: ce, useLangJp: useLangJp),
          ),
          ButtonBar(alignment: MainAxisAlignment.center, children: [
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
            for (var i = 0; i < 2; i++)
              RaisedButton(
                onPressed: () {
                  int nextNo = ce.no + [-1, 1][i];
                  if (db.gameData.crafts.containsKey(nextNo)) {
                    setState(() {
                      ce = db.gameData.crafts[nextNo];
                      print('move to craft No.${ce.no}-${ce.name}');
                    });
                  } else {
                    Fluttertoast.showToast(
                        msg: '已经是${['第', '最后'][i]}一张',
                        gravity: ToastGravity.BOTTOM,
                        toastLength: Toast.LENGTH_SHORT);
                  }
                },
                child: Text(['上一张', '下一张'][i]),
                color: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 20),
              ),
          ])
        ],
      ),
    );
  }
}

class CraftDetailBasePage extends StatelessWidget {
  final CraftEssential ce;
  final bool useLangJp;

  const CraftDetailBasePage({Key key, this.ce, this.useLangJp = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
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
              child: LayoutBuilder(builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: constraints.biggest.width, maxHeight: 90),
                  child: Image(image: db.getIconFile(ce.icon)),
                );
              }),
            ),
            Flexible(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InfoRow.fromText(texts: ['No. ${ce.no}']),
                  InfoRow(
                    children: <Widget>[
                      InfoCell.header(text: '画师'),
                      InfoCell(text: ce.illustrator.join(' & '), flex: 3)
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
                      InfoCell(
                          child: AutoSizeText(
                        '${ce.atkMin}/${ce.atkMax}',
                        maxLines: 1,
                      )),
                      InfoCell.header(text: 'HP'),
                      InfoCell(
                          child: AutoSizeText(
                        '${ce.hpMin}/${ce.hpMax}',
                        maxLines: 1,
                      )),
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
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => FullScreenImageSlider(
                          imgUrls: [ce.illust],
                          enableDownload: db.runtimeData.enableDownload,
                        ),
                    fullscreenDialog: true));
              },
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
                child: Image(image: db.getIconFile(ce.skillIcon), height: 40),
              ),
            ),
            InfoCell(
                flex: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(ce.skill),
                    if (ce.skillMax?.isNotEmpty == true) ...[
                      Divider(height: 2),
                      Text(ce.skillMax),
                    ]
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
                      image: db.getIconFile(ce.eventIcons[i]), height: 40),
                ),
              ),
              InfoCell(flex: 5, text: ce.eventSkills[i]),
            ],
          ),
        InfoRow.fromText(texts: ['解说'], color: InfoCell.headerColor),
        InfoRow(
          children: <Widget>[
            InfoCell(
              text: useLangJp ? ce.descriptionJp : ce.description,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            )
          ],
        )
      ],
    );
  }
}
