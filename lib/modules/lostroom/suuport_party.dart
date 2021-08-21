import 'package:chaldea/components/components.dart';
import 'package:flutter/gestures.dart';

class SupportPartyPage extends StatefulWidget {
  const SupportPartyPage({Key? key}) : super(key: key);

  @override
  _SupportPartyPageState createState() => _SupportPartyPageState();
}

class _SupportPartyPageState extends State<SupportPartyPage> {
  List<SupportSetUp> setUps = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    for (int index = 0; index < allClasses.length; index++) {}
    setUps = List.generate(
      allClasses.length,
      (index) => SupportSetUp(
        svtNo: index + 1,
        imgPath: db.gameData.servants[index + 1]?.info.illustrations.values
            .toList()
            .getOrNull(0),
        cached: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.support_party),
      ),
      body: Column(
        children: [
          // SizedBox(height: h * 0.8, child: partyCanvas),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: min(MediaQuery.of(context).size.height * 0.5, 400)),
            child: ScrollConfiguration(
              behavior: UndraggableScrollBehavior(),
              child: partyCanvas,
            ),
          ),
          Expanded(
            flex: 10,
            child: Text('haha'),
          ),
        ],
      ),
    );
  }

  final List<String> allClasses = [
    'ALl',
    ...SvtFilterData.regularClassesData,
    'Extra',
  ];

  Widget get partyCanvas {
    return Scrollbar(
      controller: _scrollController,
      isAlwaysShown: true,
      thickness: 10,
      radius: Radius.circular(5),
      interactive: true,
      child: ListView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: 15),
        children: [
          for (final setUp in setUps)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: FittedBox(
                    child: ClipPath(
                      clipper: _SupportCornerClipper(),
                      child: oneSupport(setUp),
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
                Radio(value: 1, groupValue: 2, onChanged: (v) {}),
              ],
            )
        ],
      ),
    );
  }

  final double w = 314;
  final double h = 690;

  Widget oneSupport(SupportSetUp setUp) {
    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          located(
            child: CachedImage(
              imageUrl: 'flame_bg_gold.png',
              isMCFile: true,
              cachedOption: CachedImageOption(fit: BoxFit.fill),
            ),
          ),
          Positioned(
            top: 7,
            bottom: 100,
            child: _OneSupportWithGesture(setUp: setUp),
          ),
          // _OneSupportWithGesture(setUp: setUp),
          located(
            child: IgnorePointer(
              child: CachedImage(
                imageUrl: 'flame_gold.png',
                isMCFile: true,
                cachedOption: CachedImageOption(fit: BoxFit.fill),
              ),
            ),
          ),
          Positioned(
            left: 5,
            top: 5,
            width: 90,
            height: 90,
            child: CachedImage(
              imageUrl: '金卡Saber.png',
              cachedOption: CachedImageOption(fit: BoxFit.contain),
            ),
          ),
          // Positioned.fromRect(
          //   rect: Rect.fromCenter(
          //       center: Offset(w * 0.85, 40), width: 50, height: 50),
          //   child: CachedImage(
          //     imageUrl: '圣杯.png',
          //     cachedOption: CachedImageOption(fit: BoxFit.contain),
          //   ),
          // ),
          Positioned(
            left: 68,
            top: 548,
            child: ImageWithText.paintOutline(
              text: '90',
              shadowSize: 8,
              shadowColor: Colors.black54,
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 34,
              ),
            ),
          ),
          Positioned(
            right: 25,
            top: 548,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                db.getIconImage('宝具强化', width: 36),
                SizedBox(width: 5),
                ImageWithText.paintOutline(
                  text: '5',
                  shadowSize: 8,
                  shadowColor: Colors.black54,
                  textStyle: TextStyle(
                    color: Color.fromARGB(255, 240, 240, 240),
                    fontWeight: FontWeight.bold,
                    fontSize: 34,
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 588,
            right: 25,
            child: ImageWithText.paintOutline(
              text: '10 / 10 / 10',
              shadowSize: 6,
              shadowColor: Colors.black38,
              textStyle: TextStyle(
                color: Color.fromARGB(255, 240, 240, 240),
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ),
          // if(false)
          Positioned(
            top: 621,
            right: 25,
            child: ImageWithText.paintOutline(
              text: '10 / 10 / 10',
              shadowSize: 6,
              shadowColor: Colors.black38,
              textStyle: TextStyle(
                color: Color.fromARGB(255, 240, 240, 240),
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget located({required Widget child}) {
    return SizedBox(
      width: w,
      height: h,
      child: child,
    );
  }
}

class SupportSetUp {
  int? svtNo;
  String? imgPath;
  bool cached;
  double scale;
  double dx;
  double dy;

  SupportSetUp({
    this.svtNo,
    this.imgPath,
    this.cached = true,
    this.scale = 1,
    this.dx = 0,
    this.dy = 0,
  });

  Offset get offset => Offset(dx, dy);

  set offset(Offset offset) {
    dx = offset.dx;
    dy = offset.dy;
  }
}

class _OneSupportWithGesture extends StatefulWidget {
  final SupportSetUp setUp;

  const _OneSupportWithGesture({
    Key? key,
    required this.setUp,
  }) : super(key: key);

  @override
  __OneSupportWithGestureState createState() => __OneSupportWithGestureState();
}

class __OneSupportWithGestureState extends State<_OneSupportWithGesture> {
  SupportSetUp get setUp => widget.setUp;

  Offset offset = Offset.zero;
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        print('tap here');
      },
      // onPanUpdate: (detail) {
      //   print(detail);
      //   setUp.offset += detail.delta;
      //   setState(() {});
      // },
      onScaleStart: (detail) {
        offset = setUp.offset;
        scale = setUp.scale;
      },
      onScaleUpdate: (detail) {
        // print(detail);
        setUp.scale = scale * detail.scale;
        setUp.offset = offset + detail.delta;
        setState(() {});
      },
      child: setUp.imgPath == null
          ? Container()
          : Transform.translate(
              offset: setUp.offset,
              child: Transform.scale(
                scale: setUp.scale,
                child: setUp.cached
                    ? CachedImage(
                        imageUrl: setUp.imgPath,
                        cachedOption: CachedImageOption(fit: BoxFit.cover),
                      )
                    : Image.file(
                        File(setUp.imgPath!),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
    );
  }
}

class _SupportCornerClipper extends CustomClipper<Path> {
  final double w = 314;
  final double h = 690;

  _SupportCornerClipper();

  @override
  Path getClip(Size size) {
    /// (4,36)->(35，5)->(279,5)->(310,36)->(310,659)->(280,690)->(35,690)->(4,659)
    final path = Path();
    void moveTo(double x, double y) {
      path.moveTo(x / w * size.width, y / h * size.height);
    }

    void lineTo(double x, double y) {
      path.lineTo(x / w * size.width, y / h * size.height);
    }

    moveTo(4, 36);
    lineTo(35, 5);
    lineTo(279, 5);
    lineTo(310, 36);
    lineTo(310, 659);
    lineTo(280, 690);
    lineTo(35, 690);
    lineTo(4, 659);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class UndraggableScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        // PointerDeviceKind.touch,
        // PointerDeviceKind.mouse,
      };
}
