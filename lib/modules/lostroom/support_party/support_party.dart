import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:screenshot/screenshot.dart';

import 'illust_select_page.dart';
import 'support_result_preview.dart';

class SupportPartyPage extends StatefulWidget {
  SupportPartyPage({Key? key}) : super(key: key);

  @override
  _SupportPartyPageState createState() => _SupportPartyPageState();
}

class _SupportPartyPageState extends State<SupportPartyPage> {
  List<SupportSetup> get settings => db.curUser.supportSetups;
  late ScrollController _horizontalController;
  late ScrollController _verticalController;
  int selected = 0;
  double? pixelRatio;
  bool hideRadio = false;

  SupportSetup get cur => settings[selected];
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _horizontalController = ScrollController();
    _verticalController = ScrollController();
    db.curUser.supportSetups =
        List.generate(SupportSetup.allClasses.length, (index) {
      final v = settings.getOrNull(index) ?? SupportSetup();
      v.index = index;
      return v;
    });
  }

  @override
  Widget build(BuildContext context) {
    pixelRatio ??= MediaQuery.of(context).devicePixelRatio;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.support_party),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: S.current.preview,
        onPressed: () {
          setState(() {
            hideRadio = true;
          });
          SchedulerBinding.instance!.addPostFrameCallback((timeStamp) async {
            if (!mounted) return;
            EasyLoading.show(
                status: 'Rendering...', maskType: EasyLoadingMaskType.clear);
            try {
              final data =
                  await _screenshotController.capture(pixelRatio: pixelRatio);
              if (data == null) {
                EasyLoading.showError('Failed');
                return;
              }
              EasyLoading.dismiss();
              SplitRoute.push(context, SupportResultPreview(data: data));
            } finally {
              EasyLoadingUtil.dismiss();
            }
          });
        },
        child: const Icon(Icons.image),
      ),
      body: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: min(MediaQuery.of(context).size.height * 0.5, 400)),
            child: Theme(
              data: Theme.of(context).copyWith(brightness: Brightness.light),
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Screenshot(
          controller: _screenshotController,
          child: Container(
            decoration: BoxDecoration(
              color: hideRadio ? null : Colors.white,
            ),
            padding: const EdgeInsets.fromLTRB(36, 8, 36, 8),
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
                    Opacity(
                      opacity: hideRadio ? 0 : 1,
                      child: Radio(
                        value: index,
                        groupValue: selected,
                        onChanged: (v) {
                          setState(() {
                            selected = index;
                          });
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
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
      padding: const EdgeInsets.only(bottom: 48),
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
            }).catchError((e, s) => Future.value(null));
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
        const Divider(height: 16, thickness: 0.5, indent: 16, endIndent: 16),
        SHeader('Resolution: ${pixelRatio!.toStringAsFixed(2)}'),
        Slider(
          value: pixelRatio!,
          onChanged: (v) {
            setState(() {
              pixelRatio = v;
            });
          },
          min: MediaQuery.of(context).devicePixelRatio * 0.5,
          max: MediaQuery.of(context).devicePixelRatio * 2,
          divisions:
              MediaQuery.of(context).devicePixelRatio * (2 - 0.5) ~/ 0.01 + 1,
          label: pixelRatio!.toStringAsFixed(2),
        ),
        SwitchListTile.adaptive(
          value: hideRadio,
          title: const Text('Hide Radio'),
          onChanged: (v) {
            setState(
              () {
                hideRadio = v;
              },
            );
          },
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

class _OneSupportWithGesture extends StatefulWidget {
  final SupportSetup setting;

  const _OneSupportWithGesture({
    Key? key,
    required this.setting,
  }) : super(key: key);

  @override
  __OneSupportWithGestureState createState() => __OneSupportWithGestureState();
}

class __OneSupportWithGestureState extends State<_OneSupportWithGesture> {
  SupportSetup get setting => widget.setting;

  Offset offset = Offset.zero;
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: (detail) {
        offset = setting.offset;
        scale = setting.scale;
      },
      onScaleUpdate: (detail) {
        // print(detail);
        setting.scale = scale * detail.scale;
        setting.offset = offset + detail.focalPointDelta;
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
