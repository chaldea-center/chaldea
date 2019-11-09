import 'package:flutter/material.dart';

class BlankPage extends StatelessWidget {
  final bool showProgress;

  const BlankPage({Key key, this.showProgress = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: constraints.biggest.width * 0.5,
                  maxHeight: constraints.biggest.height * 0.5),
              child: Image(image: AssetImage("res/img/chaldea.png")),
            ),
            if (showProgress) CircularProgressIndicator()
          ],
        ),
      );
    });
  }
}
