//@dart=2.12
import 'dart:math';

import 'package:chaldea/components/components.dart';

class BlankPage extends StatelessWidget {
  final bool showProgress;
  final bool reserveProgressSpace;

  const BlankPage(
      {Key? key, this.showProgress = false, this.reserveProgressSpace = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double imgWidth = min(270, constraints.biggest.width * 0.5);
      double imgHeight = min(270, constraints.biggest.height * 0.5);
      double progressSize = 50;
      progressSize = min(100, progressSize);
      return Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: imgWidth,
                  maxHeight: imgHeight,
                ),
                child: Image(
                  image: AssetImage("res/img/chaldea.png"),
                  filterQuality: FilterQuality.high,
                ),
              ),

              /// If show progress
              if (reserveProgressSpace || showProgress)
                Padding(
                  padding: EdgeInsets.all(20),
                  child: SizedBox(
                    width: progressSize,
                    height: progressSize,
                    child: showProgress ? CircularProgressIndicator() : null,
                  ),
                )
            ],
          ),
        ),
      );
    });
  }
}
