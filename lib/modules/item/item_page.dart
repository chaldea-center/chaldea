import 'package:flutter/material.dart';
import 'package:chaldea/components/components.dart';

class ItemPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() =>_ItemPageState();

}

class _ItemPageState extends State<ItemPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).item_title),leading: BackButton(),),
      body: Center(
        child: Text(S.of(context).item_title),
      ),
    );
  }
}