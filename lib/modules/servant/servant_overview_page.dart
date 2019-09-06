import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaldea/components/custom_tile.dart';
import 'package:chaldea/components/datatypes/datatypes.dart';
import 'package:chaldea/modules/servant/servant_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/components/components.dart';

class ServantPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ServantPageState();
}

class _ServantPageState extends State<ServantPage> {
  String filterString = '';
  TextEditingController controller = new TextEditingController();
  FocusNode focusNode = FocusNode();
  Map<String, int> filters = new Map();

  Widget buildListView(String filterString) {
    // List Style
    // img size=132*144
    List<String> noList = [];
    StringFilter filter = StringFilter(filterString);

    if(filterString!=''){
      db.gameData.servants.forEach((no,svt) {
        String string = [
          svt.no,
          svt.info.cv,
          svt.mcLink,
          svt.info.name,
          svt.info.illustName,
          svt.info.nicknames.join('\t')
        ].join('\t');

        if (filter.match(string)) {
          noList.add(svt.no.toString());
        }
      });
    }else{
      noList=db.gameData.servants.keys.toList();
    }

    print('building listView: filter="$filterString", length=${noList.length}');
    return ListView.separated(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemBuilder: (context, index){
          final svt=db.gameData.servants[noList[index]];
          final plan=db.userData.servants[noList[index]];
          return CustomTile(
            leading: SizedBox(
              width: 132 * 0.45,
              height: 144 * 0.45,
              child: Image.file(db.getLocalFile(svt.icon,rel: 'icons')),
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
                Text(plan ==null?'-':plan.curAscensionLv.toString()),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            contentPadding: null,
            //EdgeInsets.symmetric(vertical: 3.0,horizontal: 8.0),
            titlePadding: null,
            //EdgeInsets.symmetric(horizontal: 6.0),
            onTap: () {
              print('Tap No.${svt.no} - ${svt.info.nicknames}');
              Navigator.push(context,
                  SplitRoute(builder: (context) => ServantDetailPage(svt)));
            },
          );
        },
        separatorBuilder: (context, index) =>
            Divider(height: 1.0, indent: 16.0),
        itemCount: noList.length);

    //TODO: Grid style
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    this.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: buildListView(filterString),
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
