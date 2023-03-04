import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:screenshot/screenshot.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/command_code/cmd_code_list.dart';
import 'package:chaldea/app/modules/craft_essence/craft_list.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/extra_assets_page.dart';

class CombineImagePage extends StatefulWidget {
  const CombineImagePage({super.key});

  @override
  State<CombineImagePage> createState() => _CombineImagePageState();
}

class _LayoutOption {
  String? title;
  CrossAxisAlignment titleAlign = CrossAxisAlignment.start;
  int titleSize = 18;
  BoxFit imgFit = BoxFit.scaleDown;
  CrossAxisAlignment imgAlign = CrossAxisAlignment.center;
  int? imgHeight;
  bool transparent = false;
}

class _CombineImagePageState extends State<CombineImagePage> {
  // url or file
  List<Uri> urls = [];
  final option = _LayoutOption();
  int _selected = -1;

  bool get isSelected => _selected >= 0 && _selected < urls.length;

  final _controller = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height / 2;
    option.imgHeight ??= (MediaQuery.of(context).devicePixelRatio * height).toInt();
    return Scaffold(
      appBar: AppBar(title: const Text('Combine Images')),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: height,
            child: getCanvas(),
          ),
          const Divider(height: 16),
          Expanded(child: buildOptions(height))
        ],
      ),
    );
  }

  Widget getCanvas() {
    List<Widget> images = [];
    for (int index = 0; index < urls.length; index++) {
      final uri = urls[index];
      Widget image = uri.scheme.toLowerCase().startsWith('http')
          ? CachedImage(
              imageUrl: urls[index].toString(),
              cachedOption: CachedImageOption(
                fit: option.imgFit,
                errorWidget: (context, url, error) => db.getIconImage(null),
              ),
            )
          : CachedImage.fromProvider(
              imageProvider: FileImage(File(urls[index].toFilePath())),
              cachedOption: CachedImageOption(
                fit: option.imgFit,
                errorWidget: (context, url, error) => db.getIconImage(null),
              ),
            );

      image = GestureDetector(
        key: Key('$index'),
        onTap: () {
          setState(() {
            _selected = _selected == index ? -1 : index;
          });
        },
        child: Container(
          color: _selected == index ? Theme.of(context).colorScheme.primaryContainer : null,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: image,
          ),
        ),
      );
      images.add(image);
    }
    if (images.isEmpty) {
      images.add(
        const AspectRatio(key: Key('NONE'), aspectRatio: 512 / 724),
      );
    }
    Widget canvas = ReorderableListView(
      buildDefaultDragHandles: true,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = urls.removeAt(oldIndex);
          urls.insert(newIndex, item);
          if (_selected == oldIndex) _selected = newIndex;
        });
      },
      children: images,
    );
    // by default, an reorder icon on trailing will be added on descktop
    canvas = Theme(
      data: Theme.of(context).copyWith(platform: TargetPlatform.iOS),
      child: canvas,
    );

    if (option.title != null) {
      canvas = Column(
        crossAxisAlignment: option.titleAlign,
        children: [
          if (option.title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              child: Text(
                option.title!,
                style: TextStyle(
                  fontSize: option.titleSize.toDouble(),
                  color: Colors.black,
                ),
              ),
            ),
          Expanded(child: canvas),
        ],
      );
    }
    canvas = Container(
      color: option.transparent ? null : Colors.white,
      padding: const EdgeInsets.all(8),
      child: canvas,
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        color: Colors.white,
        child: Screenshot(
          controller: _controller,
          child: canvas,
        ),
      ),
    );
  }

  Widget buildOptions(double height) {
    final maxFontSize = max(24, height / 6) ~/ 2 * 2;
    return ListView(
      children: [
        if (kIsWeb && !kPlatformMethods.rendererCanvasKit)
          const Text('Web html mode doesn\'t support exporting image!'),
        Text(
          '${urls.length} Images | Selected: ${isSelected ? _selected + 1 : '-'}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Text(isSelected ? 'Insert Image' : 'Add image', textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            ElevatedButton(
              onPressed: () {
                router.pushPage(ServantListPage(
                  onSelected: (svt) {
                    router.pushPage(fromSvt(svt));
                  },
                ));
              },
              child: Text(S.current.servant),
            ),
            ElevatedButton(
              onPressed: () {
                router.pushPage(CraftListPage(
                  onSelected: (ce) {
                    router.pushPage(fromCE(ce));
                  },
                ));
              },
              child: Text(S.current.craft_essence),
            ),
            ElevatedButton(
              onPressed: () {
                router.pushPage(CmdCodeListPage(
                  onSelected: (cc) {
                    router.pushPage(fromCC(cc));
                  },
                ));
              },
              child: Text(S.current.command_code),
            ),
            ElevatedButton(
              onPressed: () {
                InputCancelOkDialog(
                  title: 'http(s) URL',
                  validate: (s) {
                    final uri = Uri.tryParse(s);
                    return uri != null && uri.scheme.toLowerCase().startsWith('http');
                  },
                  onSubmit: (s) {
                    _onChangeUrl(Uri.tryParse(s));
                  },
                ).showDialog(context);
              },
              child: const Text('URL'),
            ),
            ElevatedButton(
              onPressed: kIsWeb
                  ? null
                  : () async {
                      final result = await FilePicker.platform.pickFiles(type: FileType.image);
                      final fp = result?.files.getOrNull(0)?.path;
                      if (fp != null) {
                        _onChangeUrl(Uri.file(fp));
                      }
                    },
              child: const Text('File'),
            ),
            TextButton(
              onPressed: isSelected
                  ? () {
                      setState(() {
                        urls.removeAt(_selected);
                      });
                    }
                  : null,
              child: Text(S.current.delete),
            ),
          ],
        ),
        const SFooter(
            'Click to insert new image before the selected one or add to the end.\nLong press then drag to reorder.'),
        Center(
          child: ElevatedButton(
            onPressed: kIsWeb && !kPlatformMethods.rendererCanvasKit
                ? null
                : () {
                    double? ratio;
                    if (option.imgHeight != null) {
                      ratio = option.imgHeight! / height;
                    }
                    if (isSelected) {
                      // _selected = -1;
                      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                        exportImage(ratio);
                      });
                    } else {
                      exportImage(ratio);
                    }
                  },
            child: Text(S.current.save),
          ),
        ),
        TileGroup(
          header: 'Save Option',
          children: [
            SwitchListTile.adaptive(
              dense: true,
              value: option.transparent,
              title: const Text('Transparent'),
              onChanged: (v) {
                setState(() {
                  option.transparent = v;
                });
              },
            ),
            ListTile(
              dense: true,
              title: const Text('Exported Image Height'),
              trailing: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [Text(option.imgHeight.toString()), const Icon(Icons.edit)],
              ),
              onTap: () {
                InputCancelOkDialog(
                  title: 'Image Height',
                  text: option.imgHeight?.toString(),
                  validate: (s) {
                    final v = int.tryParse(s);
                    return v != null && v > 100 && v < 2000;
                  },
                  onSubmit: (s) {
                    final v = int.tryParse(s);
                    setState(() {
                      if (v != null && v > 0) option.imgHeight = v;
                    });
                  },
                ).showDialog(context);
              },
            ),
          ],
        ),
        TileGroup(
          header: 'Title',
          children: [
            ListTile(
              dense: true,
              title: const Text('Title'),
              subtitle: Text(option.title ?? 'Not set'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                InputCancelOkDialog(
                  title: 'Title',
                  text: option.title,
                  onSubmit: (s) {
                    option.title = s.isEmpty ? null : s;
                    if (mounted) setState(() {});
                  },
                ).showDialog(context);
              },
            ),
            ListTile(
              dense: true,
              title: const Text('Font Size'),
              trailing: DropdownButton<int>(
                value: option.titleSize.clamp(8, maxFontSize),
                items: [
                  for (int size = 8; size <= maxFontSize; size = size + 2)
                    DropdownMenuItem(
                      value: size,
                      child: Text(size.toString()),
                    ),
                ],
                onChanged: (v) {
                  setState(() {
                    if (v != null) option.titleSize = v;
                  });
                },
              ),
            ),
            ListTile(
              dense: true,
              title: const Text('Alignment(Horizontal)'),
              trailing: DropdownButton<CrossAxisAlignment>(
                value: option.titleAlign,
                items: [
                  for (final align in [CrossAxisAlignment.start, CrossAxisAlignment.center, CrossAxisAlignment.end])
                    DropdownMenuItem(
                      value: align,
                      child: Text(align.name),
                    ),
                ],
                onChanged: (v) {
                  setState(() {
                    if (v != null) option.titleAlign = v;
                  });
                },
              ),
            ),
          ],
        ),
        TileGroup(
          header: 'Image',
          children: [
            ListTile(
              dense: true,
              title: const Text('Image Fit'),
              trailing: DropdownButton<BoxFit>(
                value: option.imgFit,
                items: [
                  for (final fit in [BoxFit.none, BoxFit.fitHeight, BoxFit.scaleDown, BoxFit.cover])
                    DropdownMenuItem(
                      value: fit,
                      child: Text(fit.name),
                    ),
                ],
                onChanged: (v) {
                  setState(() {
                    if (v != null) option.imgFit = v;
                  });
                },
              ),
            ),
            ListTile(
              dense: true,
              title: const Text('Alignment(Vertical)'),
              trailing: DropdownButton<CrossAxisAlignment>(
                value: option.titleAlign,
                items: [
                  for (final align in [CrossAxisAlignment.start, CrossAxisAlignment.center, CrossAxisAlignment.end])
                    DropdownMenuItem(
                      value: align,
                      child: Text(align.name),
                    ),
                ],
                onChanged: (v) {
                  setState(() {
                    if (v != null) option.imgAlign = v;
                  });
                },
              ),
            ),
          ],
        ),
        const SafeArea(child: SizedBox(height: 8)),
      ],
    );
  }

  void exportImage(double? ratio) async {
    if (!mounted) return;
    EasyLoading.show(status: 'exporting...');
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      final data = await _controller.capture(pixelRatio: ratio);
      if (data == null) {
        await EasyLoading.showError(S.current.failed);
        return;
      }
      EasyLoading.dismiss();
      ImageActions.showSaveShare(
        context: kAppKey.currentContext,
        data: data,
        destFp: joinPaths(db.paths.downloadDir, 'Combined-${DateTime.now().toSafeFileName()}.png'),
      );
    } catch (e, s) {
      logger.e('Generate image failed', e, s);
      await EasyLoading.showError(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _onChangeUrl(Uri? uri) {
    if (uri != null) {
      if (isSelected) {
        urls.insert(_selected, uri);
      } else {
        urls.add(uri);
      }
    }
    if (mounted) setState(() {});
  }

  Widget fromSvt(Servant svt) {
    return _SelectImageFromAssets((context) {
      return ExtraAssetsPage(
        scrollable: false,
        assets: svt.extraAssets,
        aprilFoolAssets: svt.extra.aprilFoolAssets,
        mcSprites: svt.extra.mcSprites,
        fandomSprites: svt.extra.fandomSprites,
        charaGraphPlaceholder: (_, __) => db.getIconImage(svt.classCard),
        onTapImage: (url) {
          Navigator.of(context).pop();
          _onChangeUrl(Uri.tryParse(url));
        },
      );
    });
  }

  Widget fromCE(CraftEssence ce) {
    return _SelectImageFromAssets((context) {
      return ExtraAssetsPage(
        scrollable: false,
        assets: ce.extraAssets,
        charaGraphPlaceholder: (_, __) => db.getIconImage(ce.cardBack),
        onTapImage: (url) {
          Navigator.of(context).pop();
          _onChangeUrl(Uri.tryParse(url));
        },
      );
    });
  }

  Widget fromCC(CommandCode cc) {
    return _SelectImageFromAssets((context) {
      return ExtraAssetsPage(
        scrollable: false,
        assets: cc.extraAssets,
        onTapImage: (url) {
          Navigator.of(context).pop();
          _onChangeUrl(Uri.tryParse(url));
        },
      );
    });
  }
}

class _SelectImageFromAssets extends StatelessWidget {
  final WidgetBuilder builder;
  const _SelectImageFromAssets(this.builder);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select one Image'),
      ),
      body: SingleChildScrollView(
        child: builder(context),
      ),
    );
  }
}
