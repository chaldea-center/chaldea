import 'package:flutter/material.dart';

class BlankPage extends StatelessWidget {
  const BlankPage();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: constraints.biggest.width * 0.5,
                maxHeight: constraints.biggest.height * 0.5),
            child: Image(image: AssetImage("res/img/chaldea.png")),
          ),
        ),
      );
    });
  }
}
