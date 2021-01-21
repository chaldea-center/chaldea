import 'package:chaldea/components/components.dart';

class CraftDetailPage extends StatefulWidget {
  final CraftEssential ce;
  final CraftEssential Function(int, bool) onSwitch;

  const CraftDetailPage({Key key, this.ce, this.onSwitch}) : super(key: key);

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
                        child: Text(['中', '日'][i]),
                      )),
              isSelected: List.generate(2, (i) => useLangJp == (i == 1)),
            ),
            for (var i = 0; i < 2; i++)
              ElevatedButton(
                onPressed: () {
                  CraftEssential nextCe;
                  if (widget.onSwitch != null) {
                    // if navigated from filter list, let filter list decide which is the next one
                    nextCe = widget.onSwitch(ce.no, i == 1);
                  } else {
                    nextCe = db.gameData.crafts[ce.no + [-1, 1][i]];
                  }
                  if (nextCe == null) {
                    EasyLoading.showToast('已经是${['第', '最后'][i]}一张');
                  } else {
                    setState(() {
                      ce = nextCe;
                    });
                  }
                },
                child: Text(['上一张', '下一张'][i]),
                style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(fontWeight: FontWeight.normal)),
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
//    final ce = widget.ce, useLangJp = widget.useLangJp;
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageSlider(
                          imgUrls: [db.getIconResource(ce.illustration).url],
                          enableDownload: db.runtimeData.enableDownload,
                        ),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                ),
                isHeader: true,
              ),
            ],
          ),
          CustomTableRow(
              children: [TableCellData(text: '礼装类别', isHeader: true)]),
          CustomTableRow(children: [
            TableCellData(
              child: Text(ce.category + ' - ' + ce.categoryText,
                  textAlign: TextAlign.center),
            )
          ]),
          CustomTableRow(
              children: [TableCellData(text: '持有技能', isHeader: true)]),
          CustomTableRow(
            children: [
              TableCellData(
                padding: EdgeInsets.all(6),
                flex: 1,
                child: Image(image: db.getIconImage(ce.skillIcon), height: 40),
              ),
              TableCellData(
                flex: 5,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(ce.skill),
                    if (ce.skillMax?.isNotEmpty == true) ...[
                      Divider(height: 6),
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
                  padding: EdgeInsets.all(6),
                  flex: 1,
                  child: Image(
                      image: db.getIconImage(ce.eventIcons[i]), height: 40),
                ),
                TableCellData(
                    flex: 5,
                    text: ce.eventSkills[i],
                    alignment: Alignment.centerLeft)
              ],
            ),
          CustomTableRow(children: [TableCellData(text: '解说', isHeader: true)]),
          CustomTableRow(
            children: [
              TableCellData(
                text: (useLangJp ? ce.descriptionJp : ce.description) ?? ''
                    '',
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
