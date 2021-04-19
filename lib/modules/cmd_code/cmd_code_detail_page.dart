import 'package:chaldea/components/components.dart';
import 'package:url_launcher/url_launcher.dart';

class CmdCodeDetailPage extends StatefulWidget {
  final CommandCode code;
  final CommandCode? Function(CommandCode, bool)? onSwitch;

  const CmdCodeDetailPage({Key? key, required this.code, this.onSwitch})
      : super(key: key);

  @override
  _CmdCodeDetailPageState createState() => _CmdCodeDetailPageState();
}

class _CmdCodeDetailPageState extends State<CmdCodeDetailPage> {
  bool useLangCn = false;
  late CommandCode code;

  @override
  void initState() {
    super.initState();
    code = widget.code;
    useLangCn = Language.isCN;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(code.localizedName),
        actions: [
          IconButton(
            icon: Icon(Icons.link),
            tooltip: S.of(context).jump_to('Mooncell'),
            onPressed: () {
              launch(MooncellUtil.fullLink(code.mcLink, encode: true));
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: CmdCodeDetailBasePage(code: code, useLangCn: useLangCn),
          ),
          ButtonBar(alignment: MainAxisAlignment.center, children: [
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
            for (var i = 0; i < 2; i++)
              ElevatedButton(
                onPressed: () {
                  CommandCode? nextCode;
                  if (widget.onSwitch != null) {
                    // if navigated from filter list, let filter list decide which is the next one
                    nextCode = widget.onSwitch!(code, i == 1);
                  } else {
                    nextCode = db.gameData.cmdCodes[code.no + [-1, 1][i]];
                  }
                  if (nextCode == null) {
                    EasyLoading.showToast(S.of(context).list_end_hint(i == 0));
                  } else {
                    setState(() {
                      code = nextCode!;
                    });
                  }
                },
                child: Text(
                    [S.of(context).previous_card, S.of(context).next_card][i]),
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
  final bool useLangCn;

  const CmdCodeDetailBasePage(
      {Key? key, required this.code, this.useLangCn = false})
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
                child: db.getIconImage(code.icon, height: 90),
                flex: 1,
                padding: EdgeInsets.all(3),
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
                      TableCellData(
                          text: S.of(context).illustrator, isHeader: true),
                      TableCellData(text: code.localizedIllustrators, flex: 3)
                    ]),
                    CustomTableRow(children: [
                      TableCellData(text: S.of(context).rarity, isHeader: true),
                      TableCellData(text: code.rarity.toString(), flex: 3),
                    ]),
                    CustomTableRow(
                      children: [
                        TableCellData(
                          child: CustomTile(
                            title: Center(
                                child: Text(S.of(context).view_illustration)),
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  opaque: false,
                                  fullscreenDialog: true,
                                  pageBuilder: (context, _, __) =>
                                      FullScreenImageSlider(
                                        imgUrls: [code.illustration],
                                    connectivity: db.connectivity,
                                    placeholder: placeholder,
                                  ),
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
          CustomTableRow(children: [
            TableCellData(text: S.of(context).obtain_methods, isHeader: true)
          ]),
          CustomTableRow(children: [
            TableCellData(child: Text(code.obtain, textAlign: TextAlign.center))
          ]),
          CustomTableRow(children: [
            TableCellData(text: S.of(context).skill, isHeader: true)
          ]),
          CustomTableRow(
            children: [
              TableCellData(
                padding: EdgeInsets.all(6),
                flex: 1,
                child: db.getIconImage(code.skillIcon, height: 45),
              ),
              TableCellData(flex: 5, text: code.skill)
            ],
          ),
          CustomTableRow(children: [
            TableCellData(text: S.current.characters_in_card, isHeader: true)
          ]),
          CustomTableRow(children: [
            TableCellData(
              child: Text(
                code.characters.isNotEmpty == true
                    ? code.characters.join(', ')
                    : '-',
                textAlign: TextAlign.center,
              ),
            )
          ]),
          CustomTableRow(children: [
            TableCellData(text: S.of(context).card_description, isHeader: true)
          ]),
          CustomTableRow(
            children: [
              TableCellData(
                text: (useLangCn ? code.description : code.descriptionJp) ??
                    '???',
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget placeholder(BuildContext context, String? url) {
    String color;
    switch (code.rarity) {
      case 5:
      case 4:
        color = '金';
        break;
      case 1:
      case 2:
        color = '铜';
        break;
      default:
        color = '银';
    }
    return db.getIconImage('礼装$color卡背');
  }
}
