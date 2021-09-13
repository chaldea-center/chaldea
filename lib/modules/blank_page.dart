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
      Widget img = const Image(
        image: AssetImage("res/img/chaldea.png"),
        filterQuality: FilterQuality.high,
      );
      if (Utils.isDarkMode(context)) {
        // assume r=g=b
        int b = Theme.of(context).scaffoldBackgroundColor.blue;
        double v = (255 - b) / 255;
        if (!PlatformU.isWeb) {
          img = ColorFiltered(
            colorFilter: ColorFilter.matrix([
              //R G  B  A  Const
              -v, 0, 0, 0, 255,
              0, -v, 0, 0, 255,
              0, 0, -v, 0, 255,
              0, 0, 0, 0.8, 0,
            ]),
            child: img,
          );
        }
      }
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
                child: img,
              ),

              /// If show progress
              if (reserveProgressSpace || showProgress)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: progressSize,
                    height: progressSize,
                    child:
                        showProgress ? const CircularProgressIndicator() : null,
                  ),
                )
            ],
          ),
        ),
      );
    });
  }
}
