import 'package:chaldea/components/components.dart';

class BlankPage extends StatelessWidget {
  final bool showIndicator;
  final WidgetBuilder indicatorBuilder;

  const BlankPage({
    Key? key,
    this.showIndicator = false,
    this.indicatorBuilder = _defaultIndicatorBuilder,
  }) : super(key: key);

  static Widget _defaultIndicatorBuilder(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double w = min(50, min(constraints.maxHeight, constraints.maxWidth) - 40);
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: w, maxHeight: w),
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double imgWidth = min(270, constraints.biggest.width * 0.5);
      double imgHeight = min(270, constraints.biggest.height * 0.5);
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
              if (showIndicator) indicatorBuilder(context),
            ],
          ),
        ),
      );
    });
  }
}
