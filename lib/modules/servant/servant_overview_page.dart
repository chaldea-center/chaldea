import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaldea/components/custom_tile.dart';
import 'package:chaldea/components/datatypes/datatypes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/components/components.dart';

class ServantPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ServantPageState();
}

class _ServantPageState extends State<ServantPage> {
  List<Servant> svtData = [];
  String filterString = '';
  Map<int, Widget> widgetMap = {};
  TextEditingController controller = new TextEditingController();
  FocusNode focusNode = FocusNode();
  Map<String, int> filters = new Map();

  void loadSvtData() {
    db.loadAsset('res/data/svt_list.json').then((jsonData) {
      Map<String, dynamic> decoded = jsonDecode(jsonData);
      decoded.forEach((no, svt) {
        svtData.add(Servant.fromJson(svt));
      });
      print(svtData[1].info.toJson());
      svtData.forEach((svt) {
        widgetMap[svt.no] = CustomTile(
          leading: SizedBox(
            width: 13.2 * 4.5,
            height: 14.4 * 4.5,
            child: CachedNetworkImage(
              imageUrl: svt.icon,
              placeholder: (context, url) => Center(),
              errorWidget: (context, url, error) => Text(svt.info.name),
            ),
          ),
          title: Text('${svt.mcLink}'),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(svt.info.className),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Text(
                  '${Random().nextInt(9) + 1}/${Random().nextInt(10) + 1}/${Random().nextInt(10) + 1} ${Random().nextInt(5) + 1}      '),
            ],
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          contentPadding: null,
          //EdgeInsets.symmetric(vertical: 3.0,horizontal: 8.0),
          titlePadding: null,
          //EdgeInsets.symmetric(horizontal: 6.0),
          onTap: () {
            print('Tap No.${svt.no} - ${svt.info.nicknames}');
//            Navigator.of(context).push(SplitRoute(builde))
          },
        );
      });
      print('loaded svtData:length=${svtData.length}.');
      setState(() {});
    });
  }

  Widget buildListView(String filterString) {
    // List Style
    // img size=132*144
    List<Widget> tiles = [];
    StringFilter filter = StringFilter(filterString);
//    List<String> words = filter.split(RegExp(r'\s+'));
//    words.removeWhere((item) => item == '');

    svtData.forEach((svt) {
      String string = [
        svt.no,
        svt.info.cv,
        svt.mcLink,
        svt.info.name,
        svt.info.illustName,
        svt.info.nicknames.join('\t')
      ].join('\t');

      if (filter.match(string)) {
        tiles.add(widgetMap[svt.no]);
      }
    });

//    print('building listView: filter="$filterString", length=${tiles.length}');
    return ListView.separated(
        padding: EdgeInsets.only(top: 6.0),
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemBuilder: (context, index) => tiles[index],
        separatorBuilder: (context, index) => Divider(),
        itemCount: tiles.length);

    //TODO: Grid style
  }

  @override
  void initState() {
    super.initState();
    loadSvtData();
  }

  @override
  void dispose() {
    this.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = buildListView(filterString);
    return Scaffold(
      appBar: AppBar(
        title: Text('Servant'),
        leading: BackButton(),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.grey),
            child: Container(
                height: 45.0,
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                child: TextField(
                  controller: controller,
                  style: TextStyle(fontSize: 13.0),
                  decoration: InputDecoration(
                      filled: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              width: 0.0, style: BorderStyle.none),
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      fillColor: Colors.white,
                      hintText: 'Seach',
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20.0,
                      ),
                      suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.clear,
                          size: 20.0,
                        ),
                        onPressed: () {
                          setState(() {
                            controller.text = '';
                            filterString = '';
                          });
                        },
                      )),
                  onChanged: (s) {
                    setState(() {
                      filterString = s;
                    });
                  },
                  onSubmitted: (s) {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                )),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              buildFilterSheet(context);
            },
          )
        ],
      ),
      body: body,
    );
  }

  void buildFilterSheet(BuildContext context) {
    //@formatter:off
    final classNames = [
      'Saber',
      'Archer',
      'Lancer',
      'Rider',
      'Caster',
      'Assassin',
      'Berserker',
      'Shielder',
      'Ruler',
      'Avenger',
      'MoonCancer',
      'Alterego',
      'Foreigner',
      'Beast'
    ];
    //@formatter:on

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext sheetContext, setSheetState) {
              List<Widget> classWidgets = [];
              filters['class'] = filters['class'] ?? 0;
              for (int index = 0; index < classNames.length; index++) {
                final flag = (filters['class'] & 1 << index) != 0;
//        print('flag=$flag');
                classWidgets.add(GestureDetector(
                  onTap: () {
                    filters['class'] = filters['class'] ^ (1 << index);
                    print(
                        'changed! [class]=${filters['class'].toRadixString(2)}');
                    setState(() {});
                    setSheetState(() {});
                  },
                  child: CachedNetworkImage(
                      width: 30.0,
                      imageUrl:
                          "https://fgo.wiki/images${flag ? '/4/41/金卡Saber.png' : '/5/5e/铜卡Saber.png'}"),
                ));
              }
              return Scaffold(
                body: Builder(
                  builder: (context) => GestureDetector(
                      onTap: () {},
                      child: ListView(
                        children: <Widget>[
                          ListTile(
                            leading: Padding(
                              padding: EdgeInsets.symmetric(vertical: 0.0),
                              child: Text('Class'),
                            ),
                            title: Padding(
                              padding: EdgeInsets.symmetric(vertical: 0.0),
                              child: Row(
                                children: <Widget>[
                                  Flexible(
                                    flex: 2,
                                    fit: FlexFit.tight,
                                    child: GridView.count(
                                      crossAxisSpacing: 5.0,
                                      mainAxisSpacing: 2.5,
                                      shrinkWrap: true,
                                      crossAxisCount: 1,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            filters['class'] =
                                                (1 << classNames.length) - 1;
                                            print('select all');
                                            setState(() {});
                                            setSheetState(() {});
                                          },
                                          child: CachedNetworkImage(
                                              imageUrl:
                                                  'https://fgo.wiki/images${filters['class'] == (1 << classNames.length) - 1 ? '/4/41/金卡Saber.png' : '/5/5e/铜卡Saber.png'}'),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            filters['class'] = 0;
                                            print('clear all');
                                            setState(() {});
                                            setSheetState(() {});
                                          },
                                          child: CachedNetworkImage(
                                              width: 30.0,
                                              imageUrl:
                                                  'https://fgo.wiki/images${filters['class'] == 0 ? '/4/41/金卡Saber.png' : '/5/5e/铜卡Saber.png'}'),
                                        )
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Container(),
                                  ),
                                  Flexible(
                                    flex: 14,
                                    fit: FlexFit.tight,
                                    child: GridView.count(
                                      crossAxisSpacing: 5.0,
                                      mainAxisSpacing: 2.5,
                                      shrinkWrap: true,
                                      crossAxisCount: 7,
                                      children: classWidgets,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: Text('Class'),
                              ),
                              Flexible(
                                flex: 5,
                                fit: FlexFit.tight,
                                child: Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      fit: FlexFit.tight,
                                      child: Wrap(
                                        runSpacing: 5.0,
                                        spacing: 5.0,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              filters['class'] =
                                                  (1 << classNames.length) - 1;
                                              print('select all');
                                              setState(() {});
                                              setSheetState(() {});
                                            },
                                            child: CachedNetworkImage(
                                                width: 30.0,
                                                imageUrl:
                                                    'https://fgo.wiki/images${filters['class'] == (1 << classNames.length) - 1 ? '/4/41/金卡Saber.png' : '/5/5e/铜卡Saber.png'}'),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              filters['class'] = 0;
                                              print('clear all');
                                              setState(() {});
                                              setSheetState(() {});
                                            },
                                            child: CachedNetworkImage(
                                                width: 30.0,
                                                imageUrl:
                                                    'https://fgo.wiki/images${filters['class'] == 0 ? '/4/41/金卡Saber.png' : '/5/5e/铜卡Saber.png'}'),
                                          )
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      flex: 6,
                                      fit: FlexFit.tight,
                                      child: Wrap(
                                        spacing: 5.0,
                                        runSpacing: 5.0,
                                        children: classWidgets,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      )),
                ),
              );
            },
          );
        });
  }
}
