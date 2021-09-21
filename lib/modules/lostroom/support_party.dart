import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/lostroom/illust_select_page.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:screenshot/screenshot.dart';

const List<String> _allClasses = [
  'All',
  ...SvtFilterData.regularClassesData,
  'Extra',
];

class SupportPartyPage extends StatefulWidget {
  SupportPartyPage({Key? key}) : super(key: key);

  @override
  _SupportPartyPageState createState() => _SupportPartyPageState();
}

class _SupportPartyPageState extends State<SupportPartyPage> {
  List<SupportSetUp> settings = [];
  late ScrollController _horizontalController;
  late ScrollController _verticalController;
  int selected = 0;
  double? pixelRatio;

  SupportSetUp get cur => settings[selected];
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _horizontalController = ScrollController();
    _verticalController = ScrollController();
    for (int index = 0; index < _allClasses.length; index++) {}
    settings = List.generate(
      _allClasses.length,
      (index) => SupportSetUp(index: index),
    );
  }

  @override
  Widget build(BuildContext context) {
    pixelRatio ??= MediaQuery.of(context).devicePixelRatio;
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
              child: Scrollbar(
                controller: _horizontalController,
                isAlwaysShown: true,
                thickness: 10,
                radius: const Radius.circular(5),
                interactive: true,
                child: partyCanvas,
              ),
            ),
          ),
          Expanded(child: settingArea),
        ],
      ),
    );
  }

  Widget get partyCanvas {
    return SingleChildScrollView(
      controller: _horizontalController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Screenshot(
        child: Row(
          children: List.generate(settings.length, (index) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return ClipPath(
                      clipper: _SupportCornerClipper(),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selected = index;
                          });
                        },
                        child: oneSupport(index, constraints.maxHeight),
                      ),
                    );
                  }),
                ),
                Radio(
                  value: index,
                  groupValue: selected,
                  onChanged: (v) {
                    setState(() {
                      selected = index;
                    });
                  },
                ),
              ],
            );
          }),
        ),
        controller: _screenshotController,
      ),
    );
  }

  // design size
  static const double canvasWidth = 314;
  static const double canvasHeight = 690;

  Widget oneSupport(int index, double height) {
    final setting = settings[index];
    double r = height / canvasHeight;
    return SizedBox(
      width: canvasWidth * r,
      height: canvasHeight * r,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          const Positioned.fill(
            child: CachedImage(
              imageUrl: 'flame_bg_gold.png',
              isMCFile: true,
              cachedOption: CachedImageOption(fit: BoxFit.fill),
            ),
          ),
          Positioned(
            top: 7 * r,
            bottom: 100 * r,
            child: _OneSupportWithGesture(setting: setting),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: CachedImage(
                imageUrl: 'flame_gold.png',
                isMCFile: true,
                cachedOption: CachedImageOption(fit: BoxFit.fill),
              ),
            ),
          ),
          if (setting.clsName != null)
            Positioned(
              left: 5 * r,
              top: 5 * r,
              width: 90 * r,
              height: 90 * r,
              child:
                  db.getIconImage('金卡${setting.clsName}', fit: BoxFit.contain),
            ),
          // Positioned.fromRect(
          //   rect: Rect.fromCenter(
          //       center: Offset(w * 0.85, 40), width: 50, height: 50),
          //   child: CachedImage(
          //     imageUrl: '圣杯.png',
          //     cachedOption: CachedImageOption(fit: BoxFit.contain),
          //   ),
          // ),
          if (setting.servant != null && setting.resolvedLv != null)
            Positioned(
              left: 68 * r,
              top: 548 * r,
              child: ImageWithText.paintOutline(
                text: setting.resolvedLv.toString(),
                shadowSize: 8 * r,
                shadowColor: Colors.black54,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 34 * r,
                ),
              ),
            ),
          Positioned(
            right: 25 * r,
            top: 548 * r,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                db.getIconImage('宝具强化', width: 36 * r),
                SizedBox(width: 5 * r),
                SizedBox(
                  width: 20 * r,
                  child: ImageWithText.paintOutline(
                    text: setting.status?.npLv.toString() ?? '',
                    shadowSize: 8 * r,
                    shadowColor: Colors.black54,
                    textStyle: TextStyle(
                      color: const Color.fromARGB(255, 240, 240, 240),
                      fontWeight: FontWeight.bold,
                      fontSize: 34 * r,
                    ),
                  ),
                )
              ],
            ),
          ),
          if (setting.servant != null && setting.showActiveSkill)
            Positioned(
              top: 588 * r,
              right: 25 * r,
              child: ImageWithText.paintOutline(
                text: setting.status?.curVal.skills.join(' / ') ?? '',
                shadowSize: 6 * r,
                shadowColor: Colors.black38,
                textStyle: TextStyle(
                  color: const Color.fromARGB(255, 240, 240, 240),
                  fontWeight: FontWeight.bold,
                  fontSize: 26 * r,
                ),
              ),
            ),
          if (setting.servant != null && setting.showAppendSkill)
            Positioned(
              top: 621 * r,
              right: 25 * r,
              child: ImageWithText.paintOutline(
                text: setting.status?.curVal.appendSkills
                        .map((e) => e == 0 ? '-' : e)
                        .join(' / ') ??
                    '',
                shadowSize: 6 * r,
                shadowColor: Colors.black38,
                textStyle: TextStyle(
                  color: const Color.fromARGB(255, 240, 240, 240),
                  fontWeight: FontWeight.bold,
                  fontSize: 26 * r,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget get settingArea {
    return ListView(
      controller: _verticalController,
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListTile(
                leading: cur.servant?.iconBuilder(
                      context: context,
                      height: 36,
                      onTap: () async {
                        await SplitRoute.push(
                            context, cur.servant!.resolveDetailPage());
                        if (mounted) setState(() {});
                      },
                    ) ??
                    db.getIconImage(null, height: 36),
                title: Text(cur.servant?.lName ?? S.current.servant),
              ),
            ),
            IconButton(
              onPressed: () {
                SplitRoute.push(
                  context,
                  ServantListPage(
                    onSelected: (s) {
                      if (mounted) {
                        Navigator.of(context).pop();
                        setState(() {
                          if (cur.svtNo != s.no) {
                            cur.reset();
                            cur.imgPath = _svtIllusts(s).getOrNull(0);
                          }
                          cur.svtNo = s.no;
                        });
                      }
                    },
                  ),
                  detail: false,
                  popDetail: false,
                );
              },
              icon: const FaIcon(FontAwesomeIcons.exchangeAlt, size: 18),
              tooltip: 'Change Servant',
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  cur.reset();
                });
              },
              icon: const Icon(Icons.clear),
              tooltip: S.current.clear,
            )
          ],
        ),
        ListTile(
          title: const Text('Choose Illustration'),
          enabled: cur.servant != null,
          onTap: cur.servant == null
              ? null
              : () async {
                  final illust = await SplitRoute.push(
                      context, IllustSelectPage(svt: cur.servant!));
                  if (illust != null && illust is String && mounted) {
                    setState(() {
                      cur.imgPath = illust;
                      cur.cached = true;
                    });
                  }
                },
        ),
        ListTile(
          title: const Text('Choose Custom Image'),
          enabled: cur.servant != null,
          onTap: () {
            FilePickerCross.importFromStorage(type: FileTypeCross.image)
                .then((result) {
              cur.imgPath = result.path;
              cur.cached = false;
              if (mounted) {
                setState(() {});
              }
            }).catchError((e, s) async {});
          },
        ),
        SwitchListTile.adaptive(
          value: cur.showActiveSkill,
          title: Text(S.current.active_skill),
          onChanged: (v) {
            setState(() {
              cur.showActiveSkill = v;
            });
          },
        ),
        SwitchListTile.adaptive(
          value: cur.showAppendSkill,
          title: Text(S.current.append_skill),
          onChanged: (v) {
            setState(() {
              cur.showAppendSkill = v;
            });
          },
        ),
        SHeader('Resolution: ${pixelRatio!.toStringAsFixed(2)}'),
        Slider(
          value: pixelRatio!,
          onChanged: (v) {
            setState(() {
              pixelRatio = v;
            });
          },
          min: MediaQuery.of(context).devicePixelRatio * 0.25,
          max: MediaQuery.of(context).devicePixelRatio * 4,
          divisions:
              MediaQuery.of(context).devicePixelRatio * (4 - 0.25) ~/ 0.01 + 1,
          label: pixelRatio!.toStringAsFixed(2),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              final data =
                  await _screenshotController.capture(pixelRatio: pixelRatio);
              SimpleCancelOkDialog(
                title: const Text('Export'),
                content: Image.memory(data!),
                hideOk: true,
                actions: [
                  TextButton(
                    onPressed: () {
                      ImageActions.showSaveShare(
                          context: context,
                          data: data,
                          destFp: join(db.paths.downloadDir,
                              'support_setup_${DateTime.now().millisecondsSinceEpoch}.png'),
                          shareText: S.current.support_party);
                    },
                    child: Text(S.current.save),
                  )
                ],
              ).showDialog(context);
            },
            child: Text(S.current.preview),
          ),
        )
      ],
    );
  }

  List<String> _svtIllusts(Servant svt) {
    return [
      ...svt.info.illustrations.values,
      for (final icons in svt.icons) ...icons.valueList,
      for (final spirits in svt.sprites) ...spirits.valueList,
    ].whereType<String>().toList();
  }
}

class SupportSetUp {
  int index;
  int? svtNo;
  int? lv;
  String? imgPath;
  bool cached;
  double scale;
  double dx;
  double dy;
  bool showActiveSkill;
  bool showAppendSkill;

  SupportSetUp({
    required this.index,
    this.svtNo,
    this.lv,
    this.imgPath,
    this.cached = true,
    this.scale = 1,
    this.dx = 0,
    this.dy = 0,
    this.showActiveSkill = true,
    this.showAppendSkill = false,
  }) : assert(index >= 0 && index < _allClasses.length);

  Offset get offset => Offset(dx, dy);

  set offset(Offset offset) {
    dx = offset.dx;
    dy = offset.dy;
  }

  Servant? get servant => db.gameData.servants[svtNo];

  ServantStatus? get status =>
      svtNo == null ? null : db.curUser.svtStatusOf(svtNo!);

  String? get clsName {
    index = fixValidRange(index, 0, _allClasses.length);
    return servant?.stdClassName ?? _allClasses[index];
  }

  int? get resolvedLv => lv ?? defaultLv();

  int? defaultLv() {
    if (servant == null) return null;
    final curVal = status!.curVal;
    if (curVal.grail > 0) {
      return Grail.grailToLvMax(servant!.rarity, curVal.grail);
    } else {
      return Grail.maxAscensionGrailLvs(
          rarity: servant!.rarity)[curVal.ascension + 1];
    }
  }

  void reset() {
    svtNo = null;
    lv = null;
    scale = 1;
    dx = dy = 0;
    imgPath = null;
    cached = true;
  }
}

class _OneSupportWithGesture extends StatefulWidget {
  final SupportSetUp setting;

  const _OneSupportWithGesture({
    Key? key,
    required this.setting,
  }) : super(key: key);

  @override
  __OneSupportWithGestureState createState() => __OneSupportWithGestureState();
}

class __OneSupportWithGestureState extends State<_OneSupportWithGesture> {
  SupportSetUp get setting => widget.setting;

  Offset offset = Offset.zero;
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onScaleStart: (detail) {
        offset = setting.offset;
        scale = setting.scale;
      },
      onScaleUpdate: (detail) {
        // print(detail);
        setting.scale = scale * detail.scale;
        setting.offset = offset + detail.delta;
        setState(() {});
        Transform(
          transform: Matrix4.identity()
            ..translate(setting.offset.dx, setting.offset.dy)
            ..scale(setting.scale, setting.scale),
          child: setting.cached
              ? CachedImage(
                  imageUrl: setting.imgPath,
                  cachedOption: const CachedImageOption(fit: BoxFit.cover),
                )
              : Image.file(
                  File(setting.imgPath!),
                  fit: BoxFit.cover,
                ),
        );
      },
      child: setting.imgPath == null
          ? Container()
          : Transform(
              transform: Matrix4.identity()
                ..translate(setting.offset.dx, setting.offset.dy)
                ..scale(setting.scale, setting.scale),
              child: setting.cached
                  ? CachedImage(
                      imageUrl: setting.imgPath,
                      cachedOption: const CachedImageOption(fit: BoxFit.cover),
                    )
                  : Image.file(
                      File(setting.imgPath!),
                      fit: BoxFit.cover,
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
