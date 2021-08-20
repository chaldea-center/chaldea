import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/lang_switch.dart';
import 'package:chaldea/modules/summon/summon_detail_page.dart';
import 'package:url_launcher/url_launcher.dart';

class CraftDetailPage extends StatefulWidget {
  final CraftEssence ce;
  final CraftEssence? Function(CraftEssence current, bool reversed)? onSwitch;

  const CraftDetailPage({Key? key, required this.ce, this.onSwitch})
      : super(key: key);

  @override
  _CraftDetailPageState createState() => _CraftDetailPageState();
}

class _CraftDetailPageState extends State<CraftDetailPage> {
  Language? lang;

  late CraftEssence ce;

  @override
  void initState() {
    super.initState();
    ce = widget.ce;
  }

  @override
  Widget build(BuildContext context) {
    int status = db.curUser.crafts[ce.no] ?? 0;
    status = fixValidRange(status, 0, 2);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: AutoSizeText(ce.lName, maxLines: 1),
        titleSpacing: 0,
        actions: [
          IconButton(
            tooltip:
                Localized.craftFilter.of(CraftFilterData.statusTexts[status]),
            onPressed: () {
              setState(() {
                db.curUser.crafts[ce.no] = (status + 1) % 3;
              });
              db.notifyDbUpdate();
            },
            icon: status == 1
                ? Icon(Icons.favorite)
                : status == 2
                    ? Icon(Icons.favorite, color: Colors.redAccent)
                    : Icon(Icons.favorite_outline),
          ),
          _popupButton,
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: CraftDetailBasePage(ce: ce, lang: lang, showSummon: true)),
          ButtonBar(alignment: MainAxisAlignment.center, children: [
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
                  CraftEssence? nextCe;
                  if (widget.onSwitch != null) {
                    // if navigated from filter list, let filter list decide which is the next one
                    nextCe = widget.onSwitch!(ce, i == 0);
                  } else {
                    nextCe = db.gameData.crafts[ce.no + [-1, 1][i]];
                  }
                  if (nextCe == null) {
                    EasyLoading.showToast(S.of(context).list_end_hint(i == 0));
                  } else {
                    setState(() {
                      ce = nextCe!;
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

  Widget get _popupButton {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            child: Text(S.of(context).jump_to('Mooncell')),
            onTap: () {
              launch(WikiUtil.mcFullLink(ce.mcLink));
            },
          ),
          PopupMenuItem<String>(
            child: Text(S.of(context).jump_to('Fandom')),
            onTap: () {
              launch(WikiUtil.fandomFullLink(ce.nameEn));
            },
          ),
        ];
      },
    );
  }
}

class CraftDetailBasePage extends StatelessWidget {
  final CraftEssence ce;
  final Language? lang;
  final bool showSummon;

  const CraftDetailBasePage(
      {Key? key, required this.ce, this.lang, this.showSummon = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final summons = getPickupSummons();
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
          CustomTableRow(children: [
            TableCellData(text: ce.nameJp, textAlign: TextAlign.center)
          ]),
          CustomTableRow(children: [
            TableCellData(text: ce.nameEn, textAlign: TextAlign.center)
          ]),
          CustomTableRow(
            children: [
              TableCellData(
                child: InkWell(
                  child: db.getIconImage(ce.icon, height: 90),
                  onTap: () {
                    FullscreenImageViewer.show(
                      context: context,
                      urls: [ce.illustration],
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
                        children: [TableCellData(text: 'No. ${ce.no}')]),
                    CustomTableRow(children: [
                      TableCellData(
                          text: S.of(context).illustrator, isHeader: true),
                      TableCellData(
                          text: ce.lIllustrators, flex: 3, maxLines: 1)
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
                    FullscreenImageViewer.show(
                      context: context,
                      urls: [ce.illustration],
                      placeholder: placeholder,
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
              child: Text(Localized.craftFilter.of(ce.category),
                  textAlign: TextAlign.center),
            )
          ]),
          ..._relatedSvt(context),
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
                    Text(ce.lSkill),
                    if (ce.lSkillMax.isNotEmpty) ...[
                      Divider(height: 6),
                      Text(ce.lSkillMax),
                    ]
                  ],
                ),
              )
            ],
          ),
          // Only CN is supported
          if (Language.isCN)
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
            TableCellData(text: S.current.characters_in_card, isHeader: true)
          ]),
          CustomTableRow(children: [
            TableCellData(child: localizeCharacters(context, ce.characters))
          ]),
          CustomTableRow(children: [
            TableCellData(text: S.of(context).card_description, isHeader: true)
          ]),
          CustomTableRow(
            children: [
              TableCellData(
                text: LocalizedText(
                        chs: ce.description ?? '???',
                        jpn: ce.descriptionJp,
                        eng: ce.descriptionEn)
                    .ofPrimary(lang ?? Language.current),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              )
            ],
          ),
          if (showSummon && summons.isNotEmpty) ...[
            CustomTableRow(children: [
              TableCellData(text: S.current.summon, isHeader: true)
            ]),
            CustomTableRow(children: [
              TableCellData(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var summon in summons)
                    ListTile(
                      title: Text(summon.lName, maxLines: 1),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      onTap: () {
                        SplitRoute.push(
                            context, SummonDetailPage(summon: summon));
                      },
                    )
                ],
              ))
            ])
          ]
        ],
      ),
    );
  }

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

  List<Summon> getPickupSummons() {
    List<Summon> summons = [];
    db.gameData.summons.forEach((key, summon) {
      if (summon.allCrafts().contains(ce.no)) {
        summons.add(summon);
      }
    });
    return summons;
  }

  Widget placeholder(BuildContext context, String? url) {
    String color;
    switch (ce.rarity) {
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

  List<Widget> _relatedSvt(BuildContext context) {
    List<Widget> children = [];
    final bondSvt = db.gameData.servants[ce.bond];
    final valentineSvt = db.gameData.servants[ce.valentine];
    for (var svt in [bondSvt, valentineSvt]) {
      if (svt != null) {
        children.add(TextButton(
          onPressed: () => svt.pushDetail(context),
          child: Text(
            svt.info.localizedName,
            textAlign: TextAlign.center,
          ),
          style: TextButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.all(1),
          ),
        ));
      }
    }
    return children;
  }
}
