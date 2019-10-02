import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/custom_tile.dart';
import 'package:chaldea/components/tile_items.dart';
import 'package:chaldea/modules/servant/servant_detail.dart';
import 'package:flutter/material.dart';

class ServantListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ServantListPageState();
}

class _ServantListPageState extends State<ServantListPage> {
  String filterString = '';
  TextEditingController controller = new TextEditingController();
  Map<String, int> filters = new Map();

  //filters
  bool favorite = false;

  Widget buildListView(String filterString) {
    // List Style
    // img size=132*144
    List<String> noList = [];
    TextFilter filter = TextFilter(filterString);

    if (favorite) {
      db.userData.servants.forEach((no, plan) {
        if (plan.favorite) {
          noList.add(no);
        }
      });
    } else {
      noList = db.gameData.servants.keys.toList();
    }
    if (filterString != '') {
      noList.retainWhere((no) {
        final svt = db.gameData.servants[no];
        String string = [
          svt.no,
          svt.info.cv,
          svt.mcLink,
          svt.info.name,
          svt.info.illustName,
          svt.info.nicknames.join('\t')
        ].join('\t');
        return filter.match(string);
      });
    }
    noList.sort((a, b) => int.parse(a) - int.parse(b));
//    print('building listView: filter="$filterString", length=${noList.length}');
    return ListView.separated(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemBuilder: (context, index) {
          final svt = db.gameData.servants[noList[index]];
          final plan = db.userData.servants[noList[index]];
          final lvs = plan?.favorite == true
              ? [
            plan.ascensionLv[0],
            plan.skillLv[0][0],
            plan.skillLv[1][0],
            plan.skillLv[2][0]
          ]
              : null;
          return CustomTile(
            leading: SizedBox(
              width: 132 * 0.45,
              height: 144 * 0.45,
              child: Image.file(db.getIconFile(svt.icon)),
            ),
            title: Text('${svt.mcLink}'),
            subtitle: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Text(svt.info.className),
                ),
                Expanded(
                  flex: 1,
                  child: Text(plan?.favorite == true
                      ? '${lvs[0]}-${lvs[1]}/${lvs[2]}/${lvs[3]}'
                      : ''),
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              print('Tap No.${svt.no} - ${svt.info.nicknames}');
              SplitRoute.popAndPush(context,
                  builder: (context) => ServantDetailPage(svt));
//              Navigator.push(context,
//                  SplitRoute(builder: (context) => ServantDetailPage(svt)));
            },
          );
        },
        separatorBuilder: (context, index) =>
            Divider(height: 1.0, indent: 16.0),
        itemCount: noList.length);

    //TODO: Grid style vs List style
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
                            WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => controller.clear());
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
//                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                )),
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                favorite = !favorite;
                setState(() {});
              }),
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
    final headerStyle = TextStyle(fontSize: 16);
    List<String> traits = [];
    db.gameData.servants.forEach((no, svt) {
      traits.addAll(svt.info.traits);
    });
    traits = traits.toSet().toList();
    traits.sort();

    showSheet(context,
        builder: (sheetContext, setSheetState) =>
            Scaffold(
              appBar: AppBar(
                leading: BackButton(),
                title: Text('筛选'),
                centerTitle: true,
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        setSheetState(() {});
                      })
                ],
              ),
              body: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  SHeader('Class', style: headerStyle),
                  Row(
                    children: <Widget>[
                      Expanded(
                          flex: 3,
                          child: GridView.count(
                            crossAxisCount: 1,
                            childAspectRatio: 1.3,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: List.generate(2, (index) {
                              final name =
                                  ['金卡', '铜卡'][index] + ClassName.all.name;
                              return GestureDetector(
                                child: Image.file(
                                  db.getIconFile(name),
                                ),
                                onTap: () {
                                  setSheetState(() {
                                    filters['all'] = index;
                                  });
                                },
                              );
                            }),
                          )),
                      Expanded(
                          flex: 21,
                          child: GridView.count(
                            crossAxisCount: 7,
                            shrinkWrap: true,
                            childAspectRatio: 1.3,
                            physics: NeverScrollableScrollPhysics(),
                            children:
                            List.generate(ClassName.values.length, (index) {
                              final className = ClassName.values[index];
                              final color = filters['all'] == 0 ? '金卡' : '铜卡';
                              return GestureDetector(
                                child: Image.file(
                                  db.getIconFile('$color${className.name}'),
                                ),
                                onTap: () {},
                              );
                            }),
                          ))
                    ],
                  ),
                  SHeader('Rarity', style: headerStyle),
                  FilterButtonGroup(
                      data: List.generate(6, (i) => i),
                      labels: List.generate(6, (i) => Text('$i星')),
                      onChanged: (values) {
                        print('outside: $values');
                      }),
                  SHeader('获取方式', style: headerStyle),
                  FilterButtonGroup(
                      data: ['剧情', '活动', '无法召唤', '常驻', '限定', '友情点召唤'],
                      onChanged: (values) {
                        print('outside: $values');
                      }),
                  SHeader('宝具'),
                  FilterButtonGroup(
                      data: ['Quick', 'Arts', 'Buster'],
                      onChanged: (values) {
                        print('outside: $values');
                      }),
                  FilterButtonGroup(
                      data: ['单体', '全体', '辅助'],
                      onChanged: (values) {
                        print('outside: $values');
                      }),
                  SHeader('阵营&属性&性别'),
                  FilterButtonGroup(
                      data: ['天', '地', '人', '星', '兽'],
                      onChanged: (values) {
                        print('outside: $values');
                      }),
                  FilterButtonGroup(
                      data: ['秩序', '混沌', '中立'],
                      onChanged: (values) {
                        print('outside: $values');
                      }),
                  FilterButtonGroup(
                      data: ['善', '恶', '中庸', '新娘', '狂', '夏'],
                      onChanged: (values) {
                        print('outside: $values');
                      }),
                  FilterButtonGroup(
                      data: ['天', '地', '人', '星', '兽'],
                      onChanged: (values) {
                        print('outside: $values');
                      }),
                  FilterButtonGroup(
                      data: ['男', '女', '其他'],
                      onChanged: (values) {
                        print('outside: $values');
                      }),
                  Row(children: [
                    SHeader('特性'),
                    ToggleButtons(
                      children: [Text('同时匹配'), Text('反向筛选')],
                      isSelected: [false, false],
                      onPressed: (i) => print("$i pressed."),
                    )
                  ]),
                  FilterButtonGroup(
                    data: traits.toList(),
                    onChanged: (values) {
                      print('outside: $values');
                    },
                  )
                ],
              ),
            ));
  }
}
