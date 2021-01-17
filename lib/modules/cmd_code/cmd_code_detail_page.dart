import 'package:chaldea/components/components.dart';

class CmdCodeDetailPage extends StatefulWidget {
  final CommandCode code;
  final CommandCode Function(int, bool) onSwitch;

  const CmdCodeDetailPage({Key key, this.code, this.onSwitch})
      : super(key: key);

  @override
  _CmdCodeDetailPageState createState() => _CmdCodeDetailPageState();
}

class _CmdCodeDetailPageState extends State<CmdCodeDetailPage> {
  bool useLangJp = false;
  CommandCode code;

  @override
  void initState() {
    super.initState();
    code = widget.code;
    db.checkNetwork();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(code.name),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: CmdCodeDetailBasePage(code: code, useLangJp: useLangJp),
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
                  CommandCode nextCode;
                  if (widget.onSwitch != null) {
                    // if navigated from filter list, let filter list decide which is the next one
                    nextCode = widget.onSwitch(code.no, i == 1);
                  } else {
                    nextCode = db.gameData.cmdCodes[code.no + [-1, 1][i]];
                  }
                  if (nextCode == null) {
                    EasyLoading.showToast('已经是${['第', '最后'][i]}一张');
                  } else {
                    setState(() {
                      code = nextCode;
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

class CmdCodeDetailBasePage extends StatelessWidget {
  final CommandCode code;
  final bool useLangJp;

  const CmdCodeDetailBasePage({Key key, this.code, this.useLangJp = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: CustomTable(
        children: <Widget>[
          CustomTableRow(children: [
            TableCellData(
              child: Text(code.name,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              isHeader: true,
            )
          ]),
          CustomTableRow(children: [TableCellData(text: code.nameJp)]),
          CustomTableRow(
            children: [
              TableCellData(
                child: Image(image: db.getIconImage(code.icon)),
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
                        children: [TableCellData(text: 'No. ${code.no}')]),
                    CustomTableRow(children: [
                      TableCellData(text: '画师', isHeader: true),
                      TableCellData(
                          text: code.illustrators.join(' & '), flex: 3)
                    ]),
                    CustomTableRow(children: [
                      TableCellData(text: '稀有度', isHeader: true),
                      TableCellData(text: code.rarity.toString(), flex: 3),
                    ]),
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
                                    imgUrls: [
                                      db.getIconResource(code.illustration).url
                                    ],
                                    enableDownload:
                                        db.runtimeData.enableDownload,
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
                  ],
                ),
              ),
            ],
          ),
          CustomTableRow(
              children: [TableCellData(text: '获取方式', isHeader: true)]),
          CustomTableRow(children: [
            TableCellData(child: Text(code.obtain, textAlign: TextAlign.center))
          ]),
          CustomTableRow(
              children: [TableCellData(text: '持有技能', isHeader: true)]),
          CustomTableRow(
            children: [
              TableCellData(
                padding: EdgeInsets.all(6),
                flex: 1,
                child:
                    Image(image: db.getIconImage(code.skillIcon), height: 40),
              ),
              TableCellData(flex: 5, text: code.skill)
            ],
          ),
          CustomTableRow(children: [TableCellData(text: '解说', isHeader: true)]),
          CustomTableRow(
            children: [
              TableCellData(
                text: useLangJp ? code.descriptionJp : code.description,
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
