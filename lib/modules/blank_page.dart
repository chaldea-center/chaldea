import 'package:flutter/material.dart';

class BlankPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Image(image:AssetImage("res/img/chaldea.png")),
      ),
    );
  }

}