//@dart=2.12
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaldea/components/components.dart';

class MysticCodePage extends StatefulWidget {
  @override
  _MysticCodePageState createState() => _MysticCodePageState();
}

class _MysticCodePageState extends State<MysticCodePage> {
  Map<String, MysticCode> get mysticCodes => db.gameData.mysticCodes;
  String selected = db.gameData.mysticCodes.keys.first;

  // bool useGirl = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MysticCode mysticCode = mysticCodes[selected]!;
    final int _level = db.curUser.mysticCodes[selected] ?? 10;
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
          Wrap(
            children: mysticCodes.entries.map((entry) {
              final code = entry.value;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: selected == entry.key
                              ? Colors.blue
                              : Colors.transparent)),
                  child: GestureDetector(
                    onTap: () => setState(() => selected = entry.key),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Image(
                        image: db.getIconImage(
                            db.curUser.isMasterGirl ? code.icon2 : code.icon1),
                        height: 50,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
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
                      () => db.curUser.mysticCodes[selected] = v.toInt()),
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

  Widget buildDetails(MysticCode mysticCode) {
    final urls = getImageUrl([mysticCode.image1, mysticCode.image2]);
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
            text: mysticCode.description ?? '???',
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ]),
        CustomTableRow(
          children: [
            TableCellData(
              text: mysticCode.descriptionJp ?? '???',
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
          children: [
            TableCellData(
              child: FittedBox(
                child: SizedBox(
                  height: 300,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (urls[0] != null)
                        CachedNetworkImage(imageUrl: urls[0]),
                      Container(width: 50),
                      if (urls[1] != null) CachedNetworkImage(imageUrl: urls[1])
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  List<String?> getImageUrl(List<String> filenames) {
    final urls = filenames.map((e) => db.prefs.getString(e)).toList();
    Future<void> _resolve() async {
      for (var fn in filenames) {
        if (db.prefs.getString(fn) == null) {
          //use await to ensure every image only resolve once
          await resolveWikiFileUrl(fn);
        }
      }
    }

    if (urls.contains(null)) {
      _resolve().then((value) => setState(() {}));
    }
    return urls;
  }

  Widget buildSkill(Skill skill) {
    String nameCn = skill.name;
    return TileGroup(
      children: <Widget>[
        CustomTile(
            contentPadding: EdgeInsets.fromLTRB(16, 6, 22, 6),
            leading:
                Image(image: db.getIconImage(skill.icon), height: 110 * 0.3),
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
}
