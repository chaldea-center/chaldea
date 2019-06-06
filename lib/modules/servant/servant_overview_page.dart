import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaldea/components/CustomTile.dart';
import 'package:chaldea/components/datatype/all_datatype.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/components/components.dart';

class ServantPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ServantPageState();
}

class _ServantPageState extends State<ServantPage> {
  List<Servant> svtData = [];
  String filter = '';
  Map<int, Widget> widgetMap = {};
  TextEditingController controller = new TextEditingController();

  void loadSvtData() {
    db.loadAsset('res/data/svt_list.json').then((jsonData) {
      List decoded = jsonDecode(jsonData);
      decoded.forEach((svt) {
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
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
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
    StringFilter filter =StringFilter(filterString);
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

      if(filter.match(string)){
        tiles.add(widgetMap[svt.no]);
      }
    });

    print('building listView: filter="$filterString", length=${tiles.length}');
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
    // TODO: implement initState
    super.initState();
    loadSvtData();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    this.controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Servant'),
        leading: BackButton(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                print('refresh state');
              });
            },
          )
        ],
      ),
      body: svtData.length == 0
          ? Center(child: Text('no data'))
          : Column(
              children: <Widget>[
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                      hintText: 'Seach',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            controller.text='';
                            filter='';
                          });
                        },
                      )),
                  onChanged: (s) {
                    setState(() {
                      filter = s;
                    });
                  },
                ),
                Expanded(
                  child: buildListView(filter),
                )
              ],
            ),
    );
  }
}
