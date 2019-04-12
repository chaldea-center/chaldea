import 'package:flutter/material.dart';
import 'package:chaldea/components/master_detail_utils.dart';
import 'package:chaldea/components/detail_route.dart';

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
            onTap: (){
              Navigator.of(context).push(DetailRoute(builder: (context)=>SecondDetailPage(item)));
            },
            child: Card(
              elevation: 10,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Text("Detail Page : $item "),
              )
          ),)
        ),
      ),
    );
  }
}

class SecondDetailPage extends StatefulWidget {
  final item;
  SecondDetailPage(this.item);

  @override
  State<StatefulWidget> createState() =>_SecondDetailPageState();
}

class _SecondDetailPageState extends State<SecondDetailPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("A second page"),leading: BackButton(),),
      body: Center(
        child: Text('Route from ${widget.item}',style: TextStyle(fontSize: 40),),
      ),
    );
  }
}