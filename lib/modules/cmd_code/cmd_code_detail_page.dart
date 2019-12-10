import 'package:chaldea/components/components.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CmdCodeDetailPage extends StatefulWidget {
  final CommandCode code;

  const CmdCodeDetailPage({Key key, this.code}) : super(key: key);

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
                        child: Text(['中文', '日本語'][i]),
                      )),
              isSelected: List.generate(2, (i) => useLangJp == (i == 1)),
            ),
            for (var i = 0; i < 2; i++)
              RaisedButton(
                onPressed: () {
                  int nextNo = code.no + [-1, 1][i];
                  if (db.gameData.cmdCodes.containsKey(nextNo)) {
                    setState(() {
                      code = db.gameData.cmdCodes[nextNo];
                      print('move to cmd code No.${code.no}-${code.name}');
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

class CmdCodeDetailBasePage extends StatelessWidget {
  final CommandCode code;
  final bool useLangJp;

  const CmdCodeDetailBasePage({Key key, this.code, this.useLangJp = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        InfoRow.fromChild(
          children: [
            Text(code.name, style: TextStyle(fontWeight: FontWeight.bold))
          ],
          color: InfoCell.headerColor,
        ),
        InfoRow.fromText(texts: [code.nameJp]),
        InfoRow(
          children: <Widget>[
            InfoCell(
              child: LayoutBuilder(builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: constraints.biggest.width, maxHeight: 90),
                  child: Image(image: db.getIconFile(code.icon)),
                );
              }),
            ),
            Flexible(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InfoRow.fromText(texts: ['No. ${code.no}']),
                  InfoRow(
                    children: <Widget>[
                      InfoCell.header(text: '画师'),
                      InfoCell(text: code.illustrators.join(' & '), flex: 3)
                    ],
                  ),
                  InfoRow(
                    children: <Widget>[
                      InfoCell.header(text: '稀有度'),
                      InfoCell(text: code.rarity.toString(), flex: 3),
                    ],
                  ),
                  InfoRow.fromChild(
                    children: <Widget>[
                      CustomTile(
                        title: Center(child: Text('查看卡面')),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => FullScreenImageSlider(
                                    imgUrls: [code.illust],
                                    enableDownload:
                                        db.runtimeData.enableDownload,
                                  ),
                              fullscreenDialog: true));
                        },
                        contentPadding: EdgeInsets.zero,
                      )
                    ],
                    color: InfoCell.headerColor,
                  ),
                ],
              ),
            )
          ],
        ),
        InfoRow.fromText(texts: ['获取方式'], color: InfoCell.headerColor),
        InfoRow.fromChild(children: [
          Text(
            code.obtain,
            textAlign: TextAlign.center,
          )
        ]),
        InfoRow.fromText(texts: ['持有技能'], color: InfoCell.headerColor),
        InfoRow(
          children: <Widget>[
            InfoCell(
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Image(image: db.getIconFile(code.skillIcon), height: 40),
              ),
            ),
            InfoCell(flex: 5, child: Text(code.skill)),
          ],
        ),
        InfoRow.fromText(texts: ['解说'], color: InfoCell.headerColor),
        InfoRow(
          children: <Widget>[
            InfoCell(
              text: useLangJp ? code.descriptionJp : code.description,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            )
          ],
        )
      ],
    );
  }
}
