//@dart=2.9
import 'package:chaldea/components/components.dart';
import 'package:url_launcher/url_launcher.dart';

class CraftDetailPage extends StatefulWidget {
  final CraftEssence ce;
  final CraftEssence Function(int, bool) onSwitch;

  const CraftDetailPage({Key key, this.ce, this.onSwitch}) : super(key: key);

  @override
  _CraftDetailPageState createState() => _CraftDetailPageState();
}

class _CraftDetailPageState extends State<CraftDetailPage> {
  bool useLangCn = false;
  CraftEssence ce;

  @override
  void initState() {
    super.initState();
    ce = widget.ce;
    useLangCn = Language.isCN;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(ce.localizedName),
        actions: [
          IconButton(
            icon: Icon(Icons.link),
            tooltip: S.of(context).jump_to('Mooncell'),
            onPressed: () {
              launch(mooncellFullLink(ce.mcLink, encode: true));
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: CraftDetailBasePage(ce: ce, useLangCn: useLangCn)),
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
                  CraftEssence nextCe;
                  if (widget.onSwitch != null) {
                    // if navigated from filter list, let filter list decide which is the next one
                    nextCe = widget.onSwitch(ce.no, i == 1);
                  } else {
                    nextCe = db.gameData.crafts[ce.no + [-1, 1][i]];
                  }
                  if (nextCe == null) {
                    EasyLoading.showToast(S.of(context).list_end_hint(i == 0));
                  } else {
                    setState(() {
                      ce = nextCe;
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

class CraftDetailBasePage extends StatelessWidget {
  final CraftEssence ce;
  final bool useLangCn;

  const CraftDetailBasePage({Key key, this.ce, this.useLangCn = false})
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
                child: db.getIconImage(ce.icon, height: 90),
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
                        children: [TableCellData(text: 'No. ${ce.no}')]),
                    CustomTableRow(children: [
                      TableCellData(
                          text: S.of(context).illustrator, isHeader: true),
                      TableCellData(
                          text: ce.illustrators.join(' & '),
                          flex: 3,
                          maxLines: 1)
                    ]),
                    CustomTableRow(children: [
                      TableCellData(text: S.of(context).rarity, isHeader: true),
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
                  title: Center(child: Text(S.of(context).view_illustration)),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        fullscreenDialog: true,
                        pageBuilder: (context, _, __) => FullScreenImageSlider(
                          imgUrls: [db.getIconResource(ce.illustration).url],
                          downloadEnabled: db.userData.downloadEnabled,
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
          CustomTableRow(children: [
            TableCellData(text: S.of(context).filter_category, isHeader: true)
          ]),
          CustomTableRow(children: [
            TableCellData(
              child: Text(ce.category + ' - ' + ce.categoryText,
                  textAlign: TextAlign.center),
            )
          ]),
          CustomTableRow(children: [
            TableCellData(text: S.of(context).skill, isHeader: true)
          ]),
          CustomTableRow(
            children: [
              TableCellData(
                padding: EdgeInsets.all(6),
                flex: 1,
                child: db.getIconImage(ce.skillIcon, height: 40),
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
                  child: db.getIconImage(ce.eventIcons[i], height: 40),
                ),
                TableCellData(
                  flex: 5,
                  text: ce.eventSkills[i],
                  alignment: Alignment.centerLeft,
                )
              ],
            ),
          CustomTableRow(children: [
            TableCellData(text: S.of(context).card_description, isHeader: true)
          ]),
          CustomTableRow(
            children: [
              TableCellData(
                text: (useLangCn ? ce.description : ce.descriptionJp) ?? '???',
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget placeholder(BuildContext context, String url) {
    String color;
    switch (ce?.rarity) {
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
