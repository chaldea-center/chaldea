import 'package:chaldea/components/components.dart';
import 'package:flutter/cupertino.dart';

class MysticCodePage extends StatefulWidget {
  @override
  _MysticCodePageState createState() => _MysticCodePageState();
}

class _MysticCodePageState extends State<MysticCodePage> {
  List<String> codes = db.gameData.mysticCodes.keys.toList();
  int _curIndex = 0;

  String get _curCodeName => codes[_curIndex];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    if (db.gameData.mysticCodes.isEmpty) return Container();
    final MysticCode mysticCode = db.gameData.mysticCodes[_curCodeName]!;
    final int _level = db.curUser.mysticCodes[_curCodeName] ?? 10;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(S.of(context).mystic_code),
        actions: [
          TextButton(
            onPressed: () => setState(
                () => db.curUser.isMasterGirl = !db.curUser.isMasterGirl),
            child: Text(
              db.curUser.isMasterGirl ? '♀' : '♂',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          buildScrollHeader(),
          Expanded(
              child: SingleChildScrollView(child: buildDetails(mysticCode))),
          Row(
            children: [
              Padding(
                  padding: EdgeInsets.only(left: 16, right: 2),
                  child: Text(S.of(context).level)),
              SizedBox(
                  width: 20, child: Center(child: Text(_level.toString()))),
              Expanded(
                child: Slider(
                  value: _level.toDouble(),
                  onChanged: (v) => setState(
                      () => db.curUser.mysticCodes[_curCodeName] = v.toInt()),
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
              children: List.generate(codes.length, (index) {
                final code = db.gameData.mysticCodes[codes[index]]!;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: _curIndex == index
                                ? Colors.blue
                                : Colors.transparent)),
                    child: GestureDetector(
                      onTap: () => setState(() => _curIndex = index),
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
    _curIndex = fixValidRange(_curIndex + dx, 0, codes.length - 1);
    setState(() {});
    if (codes.length > 1) {
      final length = _scrollController.position.maxScrollExtent -
          _scrollController.position.minScrollExtent;
      final offset = length / (codes.length - 1) * _curIndex +
          _scrollController.position.minScrollExtent;
      _scrollController.animateTo(offset,
          duration: Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  Widget buildDetails2(MysticCode mysticCode) {
    return CustomTable(
      children: <Widget>[
        CustomTableRow(children: [
          TableCellData(
            child: Text(mysticCode.name,
                style: TextStyle(fontWeight: FontWeight.bold)),
            isHeader: true,
          )
        ]),
        CustomTableRow(children: [TableCellData(text: mysticCode.nameJp)]),
        CustomTableRow(children: [
          TableCellData(
            text: mysticCode.description,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ]),
        CustomTableRow(
          children: [
            TableCellData(
              text: mysticCode.descriptionJp,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              // isHeader: true
            ),
          ],
        ),
        CustomTableRow(children: [
          TableCellData(text: S.of(context).obtain_methods, isHeader: false)
        ]),
        // CustomTableRow(children: [
        //   TableCellData(child: Text(mysticCode.obtains.join('\n')))
        // ]),
        // CustomTableRow(children: [
        //   TableCellData(text: S.of(context).skill, isHeader: true)
        // ]),
        // CustomTableRow(children: [
        //   TableCellData(
        //     child: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: mysticCode.skills.map((e) => buildSkill(e)).toList(),
        //     ),
        //   )
        // ]),
        // CustomTableRow(children: [
        //   TableCellData(text: S.of(context).illustration, isHeader: true)
        // ]),
        // CustomTableRow(
        //   children: [TableCellData(child: buildCodeImages(mysticCode))],
        // )
      ],
    );
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
        CustomTableRow(children: [TableCellData(text: mysticCode.nameJp)]),
        CustomTableRow(children: [
          TableCellData(
            text: mysticCode.description,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ]),
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
          TableCellData(text: S.of(context).obtain_methods, isHeader: true)
        ]),
        CustomTableRow(children: [
          TableCellData(child: Text(mysticCode.obtains.join('\n')))
        ]),
        CustomTableRow(children: [
          TableCellData(text: S.of(context).skill, isHeader: true)
        ]),
        CustomTableRow(children: [
          TableCellData(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: mysticCode.skills.map((e) => buildSkill(e)).toList(),
            ),
          )
        ]),
        CustomTableRow(children: [
          TableCellData(text: S.of(context).illustration, isHeader: true)
        ]),
        CustomTableRow(
          children: [TableCellData(child: buildCodeImages(mysticCode))],
        )
      ],
    );
  }

  List<String> getImageUrl(List<String> filenames) {
    final List<String?> urls =
        filenames.map((e) => db.prefs.getRealUrl(e)).toList();
    Future<void> _resolve() async {
      for (var fn in filenames) {
        if (db.prefs.getRealUrl(fn) == null) {
          //use await to ensure every image only resolve once
          await MooncellUtil.resolveFileUrl(fn);
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
                  Navigator.of(context).push(PageRouteBuilder(
                    fullscreenDialog: true,
                    opaque: false,
                    pageBuilder: (context, _, __) => FullScreenImageSlider(
                      imgUrls: urls,
                      initialPage: i,
                      connectivity: db.connectivity,
                    ),
                  ));
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: CachedImage(
                    imageUrl: urls[i],
                    connectivity: db.connectivity,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSkill(Skill skill) {
    String nameCn = skill.name;
    return TileGroup(
      children: <Widget>[
        CustomTile(
            contentPadding: EdgeInsets.fromLTRB(16, 6, 22, 6),
            leading: db.getIconImage(skill.icon, height: 32, width: 32),
            title: Text(nameCn),
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
          subtitle: Text(effect.description),
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
