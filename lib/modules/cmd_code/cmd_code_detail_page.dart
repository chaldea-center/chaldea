import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/lang_switch.dart';
import 'package:url_launcher/url_launcher.dart';

class CmdCodeDetailPage extends StatefulWidget {
  final CommandCode code;
  final CommandCode? Function(CommandCode current, bool reversed)? onSwitch;

  const CmdCodeDetailPage({Key? key, required this.code, this.onSwitch})
      : super(key: key);

  @override
  _CmdCodeDetailPageState createState() => _CmdCodeDetailPageState();
}

class _CmdCodeDetailPageState extends State<CmdCodeDetailPage> {
  late Language lang;
  late CommandCode code;

  @override
  void initState() {
    super.initState();
    code = widget.code;
    lang = Language.current;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: AutoSizeText(code.localizedName, maxLines: 1),
        titleSpacing: 0,
        actions: [_popupButton],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: CmdCodeDetailBasePage(code: code, lang: lang),
          ),
          _buttonBar,
        ],
      ),
    );
  }

  Widget get _popupButton {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            child: Text(S.of(context).jump_to('Mooncell')),
            onTap: () {
              launch(WikiUtil.mcFullLink(code.mcLink));
            },
          ),
          PopupMenuItem<String>(
            child: Text(S.of(context).jump_to('Fandom')),
            onTap: () {
              launch(WikiUtil.fandomFullLink(code.nameEn));
            },
          ),
        ];
      },
    );
  }

  Widget get _buttonBar {
    return ButtonBar(alignment: MainAxisAlignment.center, children: [
      ProfileLangSwitch(
        primary: lang,
        onChanged: (v) {
          setState(() {
            lang = v;
          });
        },
      ),
      for (var i = 0; i < 2; i++)
        ElevatedButton(
          onPressed: () {
            CommandCode? nextCode;
            if (widget.onSwitch != null) {
              // if navigated from filter list, let filter list decide which is the next one
              nextCode = widget.onSwitch!(code, i == 0);
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
          child:
              Text([S.of(context).previous_card, S.of(context).next_card][i]),
          style: ElevatedButton.styleFrom(
              textStyle: TextStyle(fontWeight: FontWeight.normal)),
        ),
    ]);
  }
}

class CmdCodeDetailBasePage extends StatelessWidget {
  final CommandCode code;
  final Language? lang;

  const CmdCodeDetailBasePage({Key? key, required this.code, this.lang})
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
          CustomTableRow(children: [TableCellData(text: code.nameEn)]),
          CustomTableRow(
            children: [
              TableCellData(
                child: InkWell(
                  child: db.getIconImage(code.icon, height: 90),
                  onTap: () {
                    FullscreenImageViewer.show(
                      context: context,
                      urls: [code.illustration],
                      placeholder: placeholder,
                    );
                  },
                ),
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
                      TableCellData(text: code.lIllustrators, flex: 3)
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
                              FullscreenImageViewer.show(
                                context: context,
                                urls: [code.illustration],
                                placeholder: placeholder,
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
              TableCellData(flex: 5, text: code.lSkill)
            ],
          ),
          CustomTableRow(children: [
            TableCellData(text: S.current.characters_in_card, isHeader: true)
          ]),
          CustomTableRow(children: [
            TableCellData(child: localizeCharacters(context, code.characters))
          ]),
          CustomTableRow(children: [
            TableCellData(text: S.of(context).card_description, isHeader: true)
          ]),
          CustomTableRow(
            children: [
              TableCellData(
                text: localizeNoun(
                    code.description, code.descriptionJp, code.descriptionEn,
                    k: () => '???', primary: lang),
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

  // String localizeCharacters(List<String> characters) {
  //   if (characters.isEmpty) return '-';
  //   return characters.map((e) {
  //     final svt =
  //         db.gameData.servants.values.firstWhereOrNull((s) => s.mcLink == e);
  //     return svt?.info.localizedName ?? e;
  //   }).join(', ');
  // }

  Widget localizeCharacters(BuildContext context, List<String> characters) {
    if (characters.isEmpty) return Text('-');
    List<Widget> children = [];
    for (final name in characters) {
      final svt =
          db.gameData.servants.values.firstWhereOrNull((s) => s.mcLink == name);
      if (svt == null) {
        children.add(Text(name));
      } else {
        children.add(InkWell(
          child: Text(
            svt.info.localizedName,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: () => svt.pushDetail(context),
        ));
      }
    }
    children = divideTiles(children, divider: Text('/'));
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}
