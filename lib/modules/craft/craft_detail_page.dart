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
    return SingleChildScrollView(
      child: CustomTable(
        children: <Widget>[
          CustomTableRow(children: [
            TableCellData(
              child:
                  Text(ce.name, style: TextStyle(fontWeight: FontWeight.bold)),
              isHeader: true,
            )
          ]),
          CustomTableRow(children: [TableCellData(text: ce.nameJp)]),
          CustomTableRow(
            children: [
              TableCellData(
                child: Image(image: db.getIconImage(ce.icon)),
                flex: 1,
                padding: EdgeInsets.all(8),
                fitHeight: true,
              ),
              TableCellData(
                flex: 3,
                padding: EdgeInsets.zero,
                child: CustomTable(
                  hideOutline: true,
                  children: <Widget>[
                    CustomTableRow(
                        children: [TableCellData(text: 'No. ${ce.no}')]),
                    CustomTableRow(children: [
                      TableCellData(text: '画师', isHeader: true),
                      TableCellData(
                          text: ce.illustrators.join(' & '),
                          flex: 3,
                          maxLines: 1)
                    ]),
                    CustomTableRow(children: [
                      TableCellData(text: '稀有度', isHeader: true),
                      TableCellData(text: ce.rarity.toString()),
                      TableCellData(text: 'COST', isHeader: true),
                      TableCellData(text: ce.cost.toString()),
                    ]),
                    CustomTableRow(children: [
                      TableCellData(text: 'ATK', isHeader: true),
                      TableCellData(
                          text: '${ce.atkMin}/${ce.atkMax}', maxLines: 1),
                      TableCellData(text: 'HP', isHeader: true),
                      TableCellData(
                          text: '${ce.hpMin}/${ce.hpMax}', maxLines: 1),
                    ])
                  ],
                ),
              ),
            ],
          ),
          CustomTableRow(
            children: [
              TableCellData(
                child: CustomTile(
                  title: Center(child: Text('查看卡面')),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => FullScreenImageSlider(
                            imgUrls: [ce.illust],
                            enableDownload: db.runtimeData.enableDownload),
                        fullscreenDialog: true));
                  },
                ),
                isHeader: true,
              ),
            ],
          ),
          CustomTableRow(
              children: [TableCellData(text: '持有技能', isHeader: true)]),
          CustomTableRow(
            children: [
              TableCellData(
                padding: EdgeInsets.all(10),
                flex: 1,
                child: Image(image: db.getIconImage(ce.skillIcon), height: 40),
              ),
              TableCellData(
                flex: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(ce.skill),
                    if (ce.skillMax?.isNotEmpty == true) ...[
                      Divider(height: 2),
                      Text(ce.skillMax),
                    ]
                  ],
                ),
              )
            ],
          ),
          for (var i = 0; i < ce.eventIcons.length; i++)
            CustomTableRow(
              children: [
                TableCellData(
                  padding: EdgeInsets.all(10),
                  flex: 1,
                  child: Image(
                    image: db.getIconImage(ce.eventIcons[i]),
                    height: 40,
                  ),
                  fitHeight: true,
                ),
                TableCellData(flex: 5, text: ce.eventSkills[i])
              ],
            ),
          CustomTableRow(children: [TableCellData(text: '解说', isHeader: true)]),
          CustomTableRow(
            children: [
              TableCellData(
                text: useLangJp ? ce.descriptionJp : ce.description,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              )
            ],
          ),
        ],
      ),
    );
  }
}
