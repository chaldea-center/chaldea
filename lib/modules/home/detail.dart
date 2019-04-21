import 'dart:ui' as prefix0;

import 'package:flutter/material.dart';
import 'package:chaldea/components/split_route.dart';

class DetailPage extends StatelessWidget {
  DetailPage({Key key, @required this.item}) : super(key: key);

  final String item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Page"),
//        leading: isTablet(context) ? null : BackButton(
//          color: Colors.white,
//        ),
        leading: BackButton(),
      ),
      body: Container(
        child: Center(
            child: GestureDetector(
          onTap: () {
            Navigator.popUntil(context, (Route route){
              print('name=${route.settings.name}');
              return route.navigator==Navigator.of(context);
            });
            Navigator.of(context).push(SplitRoute(
                builder: (context) => Scaffold(
                      appBar: AppBar(
                        leading: BackButton(),
                        title: Text("Second $item"),
                      ),
                      body: Center(
                        child: Text("New App $item"),
                      ),
                    )));
          },
          child: Card(
              elevation: 10,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Text("Detail Page : $item "),
              )),
        )),
      ),
    );
  }
}

class SecondDetailPage extends StatefulWidget {
  final item;
  SecondDetailPage(this.item);

  @override
  State<StatefulWidget> createState() => _SecondDetailPageState();
}

class _SecondDetailPageState extends State<SecondDetailPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("A second page"),
        leading: BackButton(),
      ),
      body: Center(
        child: Text(
          'Route from ${widget.item}',
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
