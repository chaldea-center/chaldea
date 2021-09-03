import 'package:chaldea/components/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MysticCodePage extends StatefulWidget {
  @override
  _MysticCodePageState createState() => _MysticCodePageState();
}

class _MysticCodePageState extends State<MysticCodePage> {
  Map<String, MysticCode> get codes => db.gameData.mysticCodes;

  String? _curCodeName;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    if (codes.isEmpty) return Container();
    _curCodeName ??= codes.keys.first;
    final MysticCode? mysticCode = db.gameData.mysticCodes[_curCodeName];
    final int _level = db.curUser.mysticCodes[_curCodeName] ?? 10;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.mystic_code),
        actions: [
          TextButton(
            onPressed: () => setState(
                () => db.curUser.isMasterGirl = !db.curUser.isMasterGirl),
            child: FaIcon(
              db.curUser.isMasterGirl
                  ? FontAwesomeIcons.venus
                  : FontAwesomeIcons.mars,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: mysticCode == null
          ? Container()
          : Column(
              children: [
                buildScrollHeader(),
                Expanded(
                    child:
                        SingleChildScrollView(child: buildDetails(mysticCode))),
                Row(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(left: 16, right: 2),
                        child: Text(S.current.level)),
                    SizedBox(
                        width: 20,
                        child: Center(child: Text(_level.toString()))),
                    Expanded(
                      child: Slider(
                        value: _level.toDouble(),
                        onChanged: (v) => setState(() =>
                            db.curUser.mysticCodes[_curCodeName!] = v.toInt()),
                        min: 1.0,
                        max: 10.0,
                        divisions: 9,
                        label: _level.toString(),
                      ),
                    )
                  ],
                ),
              ],
            ),
    );
  }

  Widget buildScrollHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => _scrollTo(-1),
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.grey),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            height: 50,
            child: ListView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              children: codes.entries.map((e) {
                final code = e.value;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: _curCodeName == e.key
                                ? Colors.blue
                                : Colors.transparent)),
                    child: GestureDetector(
                      onTap: () => setState(() => _curCodeName = e.key),
                      child: db.getIconImage(
                          db.curUser.isMasterGirl ? code.icon2 : code.icon1,
                          width: 50,
                          height: 50),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        IconButton(
          onPressed: () => _scrollTo(1),
          icon: Icon(Icons.keyboard_arrow_right, color: Colors.grey),
        ),
      ],
    );
  }

  void _scrollTo(int dx) {
    List<String> keys = codes.keys.toList();
    int _curIndex = codes.keys.toList().indexOf(_curCodeName ?? '');
    _curIndex = fixValidRange(_curIndex + dx, 0, codes.length - 1);
    setState(() {
      _curCodeName = keys[_curIndex];
    });
    if (codes.length > 1) {
      final length = _scrollController.position.maxScrollExtent -
          _scrollController.position.minScrollExtent;
      final offset = length / (codes.length - 1) * _curIndex +
          _scrollController.position.minScrollExtent;
      _scrollController.animateTo(offset,
          duration: Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  Widget buildDetails(MysticCode mysticCode) {
    return CustomTable(
      children: <Widget>[
        CustomTableRow(children: [
          TableCellData(
            child: Text(mysticCode.name,
                style: TextStyle(fontWeight: FontWeight.bold)),
            isHeader: true,
          )
        ]),
        CustomTableRow(
          children: [
            TableCellData(
              child: Text(mysticCode.nameJp,
                  style: TextStyle(fontWeight: FontWeight.w500)),
            )
          ],
        ),
        CustomTableRow(
          children: [
            TableCellData(
              child: Text(mysticCode.nameEn ?? '???',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            )
          ],
          // color: TableCellData.headerColor.withAlpha(120),
        ),
        CustomTableRow(children: [
          TableCellData(
            text: mysticCode.lDescription,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ]),
        if (!Language.isJP)
          CustomTableRow(
            children: [
              TableCellData(
                text: mysticCode.descriptionJp,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ],
          ),
        CustomTableRow(children: [
          TableCellData(text: S.current.obtain_methods, isHeader: true)
        ]),
        CustomTableRow(children: [
          TableCellData(child: Text(mysticCode.lObtains.join('\n')))
        ]),
        CustomTableRow(
            children: [TableCellData(text: S.current.skill, isHeader: true)]),
        CustomTableRow(children: [
          TableCellData(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: mysticCode.skills.map((e) => buildSkill(e)).toList(),
            ),
          )
        ]),
        CustomTableRow(children: [
          TableCellData(text: S.current.game_experience, isHeader: true)
        ]),
        for (int row = 0; row < mysticCode.expPoints.length / 5; row++) ...[
          CustomTableRow.fromTexts(
            texts: [
              'Lv.',
              for (int i = row * 5; i < row * 5 + 5; i++)
                i == 9 ? '-' : '${i + 1}->${i + 2}'
            ],
            defaults: TableCellData(
                color:
                    TableCellData.resolveHeaderColor(context).withOpacity(0.5)),
          ),
          CustomTableRow.fromTexts(
            texts: [
              S.current.info_bond_points_single,
              for (int i = row * 5; i < row * 5 + 5; i++)
                i >= mysticCode.expPoints.length
                    ? '-'
                    : formatNumber((mysticCode.expPoints.getOrNull(i) ?? 0) -
                        (mysticCode.expPoints.getOrNull(i - 1) ?? 0)),
            ],
            defaults: TableCellData(maxLines: 1),
          ),
          CustomTableRow.fromTexts(
            texts: [
              S.current.info_bond_points_sum,
              for (int i = row * 5; i < row * 5 + 5; i++)
                i >= mysticCode.expPoints.length
                    ? '-'
                    : formatNumber(mysticCode.expPoints[i]),
            ],
            defaults: TableCellData(maxLines: 1),
          ),
        ],
        CustomTableRow(children: [
          TableCellData(text: S.current.illustration, isHeader: true)
        ]),
        CustomTableRow(
          children: [TableCellData(child: buildCodeImages(mysticCode))],
        ),
      ],
    );
  }

  List<String> getImageUrl(List<String> filenames) {
    final List<String?> urls =
        filenames.map((e) => WikiUtil.getCachedUrl(e)).toList();
    Future<void> _resolve() async {
      for (var fn in filenames) {
        if (WikiUtil.getCachedUrl(fn) == null) {
          //use await to ensure every image only resolve once
          await WikiUtil.resolveFileUrl(fn);
        }
      }
    }

    if (urls.contains(null)) {
      _resolve().then((value) {
        if (mounted) {
          setState(() {});
        }
      });
    }
    return urls.where((e) => e != null).toList() as List<String>;
  }

  Widget buildCodeImages(MysticCode mysticCode) {
    final urls = getImageUrl([mysticCode.image1, mysticCode.image2]);
    if (urls.isEmpty) return Container(height: 300);
    return FittedBox(
      child: SizedBox(
        height: 300,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            for (int i = 0; i < urls.length; i++)
              GestureDetector(
                onTap: () {
                  FullscreenImageViewer.show(
                    context: context,
                    urls: urls,
                    initialPage: i,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: CachedImage(imageUrl: urls[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSkill(Skill skill) {
    return TileGroup(
      children: <Widget>[
        CustomTile(
            contentPadding: EdgeInsets.fromLTRB(16, 6, 22, 6),
            leading: db.getIconImage(skill.icon, height: 32, width: 32),
            title: Text(skill.localizedName),
            trailing: Text('   CD: ${skill.cd}→${skill.cd - 2}')),
        for (Effect effect in skill.effects) ...buildEffect(effect)
      ],
    );
  }

  List<Widget> buildEffect(Effect effect) {
    assert([1, 10].contains(effect.lvData.length));
    int lines =
        effect.lvData.length == 1 ? (effect.lvData[0].length < 10 ? 0 : 1) : 2;
    int crossCount =
        effect.lvData.length == 1 ? (effect.lvData[0].length < 10 ? 0 : 1) : 5;

    return <Widget>[
      CustomTile(
          contentPadding: EdgeInsets.fromLTRB(16, 6, 22, 6),
          subtitle: Text(effect.lDescription),
          trailing: crossCount == 0 ? Text(effect.lvData[0]) : null),
      if (lines > 0)
        Padding(
          padding: EdgeInsets.only(right: 24),
          child: Table(
            children: [
              for (int row = 0; row < effect.lvData.length / crossCount; row++)
                TableRow(
                  children: List.generate(crossCount, (col) {
                    int index = row * crossCount + col;
                    if (index >= effect.lvData.length) return Container();
                    return Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          effect.lvData[index],
                          style: TextStyle(
                            fontSize: 14,
                            color: index == 5 || index == 9
                                ? Colors.redAccent
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                )
            ],
          ),
        ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}
