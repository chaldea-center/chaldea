import 'package:flutter/material.dart';

class BlankPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image(
          image: AssetImage("res/img/chaldea.png"),
          width: MediaQuery
              .of(context)
              .size
              .width * 0.4,
        ),
      ),
    );
  }
}
