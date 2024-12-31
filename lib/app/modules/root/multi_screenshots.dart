import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image/image.dart' as img_lib;
import 'package:screenshot/screenshot.dart';

import 'package:chaldea/app/routes/delegate.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../routes/root_delegate.dart';
import 'window_manager.dart';

// https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications
class ScreenSpec {
  final String name;
  final int width;
  final int height;
  final double deviceRatio;

  const ScreenSpec({
    required this.name,
    required this.width,
    required this.height,
    required this.deviceRatio,
  });

  static ScreenSpec get iphone6i7 =>
      const ScreenSpec(name: "iphone_6.7", width: 1290, height: 2796, deviceRatio: 3); // optional
  static ScreenSpec get iphone6i5 => const ScreenSpec(name: "iphone_6.5", width: 1284, height: 2778, deviceRatio: 3);
  static ScreenSpec get iphone5i5 => const ScreenSpec(name: "iphone_5.5", width: 1242, height: 2208, deviceRatio: 3);
  static ScreenSpec get ipad_6th_12i9 =>
      const ScreenSpec(name: "ipad_6th_12.9", width: 2732, height: 2048, deviceRatio: 3);
  static ScreenSpec get mac => const ScreenSpec(name: "mac", width: 2569, height: 1600, deviceRatio: 2);
  // static const ipad_2th_12i9 = ScreenSpec(name: "ipad_2th_12.9", width: 2048, height: 2732);

  static List<ScreenSpec> get allDevices => [
        iphone6i7,
        iphone6i5,
        iphone5i5,
        ipad_6th_12i9,
        mac,
      ];
}

class MultiScreenshots extends StatefulWidget {
  final RootAppRouterDelegate root;

  const MultiScreenshots({super.key, required this.root});

  @override
  _MultiScreenshotsState createState() => _MultiScreenshotsState();
}

class _MultiScreenshotsState extends State<MultiScreenshots> {
  RootAppRouterDelegate get root => widget.root;

  bool showTitle = true;
  int crossCount = 4;
  ScreenSpec curSpec = ScreenSpec.iphone6i5;
  final List<ScreenshotController> _screenshotControllers = [];

  ScreenshotController getController(int index) {
    if (index >= _screenshotControllers.length) {
      _screenshotControllers
          .addAll(List.generate((index + 1) - _screenshotControllers.length, (index) => ScreenshotController()));
    }
    return _screenshotControllers[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor.withAlpha(204),
      appBar: AppBar(
        toolbarHeight: 42,
        centerTitle: true,
        title: const Text(kAppName),
        actions: [
          IconButton(
            onPressed: takeScreenshot,
            icon: const Icon(Icons.screenshot_monitor),
          ),
          PopupMenuButton<dynamic>(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text("Show/Hide Title"),
                onTap: () {
                  setState(() {
                    showTitle = !showTitle;
                  });
                },
              ),
              const PopupMenuDivider(),
              for (final count in <int>[2, 3, 4, 5, 6, 8])
                PopupMenuItem(
                  height: 30,
                  child: Text('Cross count $count'),
                  onTap: () {
                    setState(() {
                      crossCount = count;
                    });
                  },
                ),
              const PopupMenuDivider(),
              for (final spec in ScreenSpec.allDevices)
                PopupMenuItem(
                  child: Text(
                    spec.name,
                    style: spec == curSpec ? TextStyle(color: Theme.of(context).colorScheme.primary) : null,
                  ),
                  onTap: () {
                    setState(() {
                      curSpec = spec;
                    });
                  },
                ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          cacheExtent: 2000,
          crossAxisCount: crossCount,
          childAspectRatio: curSpec.width / curSpec.height,
          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 72),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: List.generate(
            root.appState.children.length,
            (index) => buildOne(index, root.appState.children[index]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          root.appState.addWindow();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildOne(int index, AppRouterDelegate childDelegate) {
    return DecoratedBox(
      key: ObjectKey(childDelegate),
      decoration: BoxDecoration(boxShadow: [
        if (index == root.appState.activeIndex)
          BoxShadow(
            offset: const Offset(0, 0),
            spreadRadius: 4,
            blurRadius: 8,
            color: Colors.blue.withAlpha(204),
          ),
      ]),
      child: Screenshot(
        controller: getController(index),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: Size(curSpec.width / curSpec.deviceRatio, curSpec.height / curSpec.deviceRatio),
          ),
          child: WindowThumb(
            root: root,
            index: index,
            absorbPointer: false,
            gesture: false,
            showTitle: showTitle,
          ),
        ),
      ),
    );
  }

  Future<void> takeScreenshot() async {
    final spec = curSpec;
    try {
      if (kIsWeb) {
        EasyLoading.showInfo('Not support web');
        return;
      }
      EasyLoading.show();
      final folder =
          Directory(joinPaths(db.paths.assetsDir, 'screenshots', [spec.name, Language.current.code].join('_')));
      folder.createSync(recursive: true);
      final uiImage = await _screenshotControllers[0].captureAsUiImage(pixelRatio: 1);
      final ratio = spec.width / uiImage!.width;
      for (int index = 0; index < widget.root.appState.children.length; index++) {
        EasyLoading.show(status: 'Capture ${index + 1}...');
        final data = await _screenshotControllers[index].capture(
          pixelRatio: ratio,
          delay: const Duration(milliseconds: 200),
        );

        img_lib.Image img = img_lib.decodePng(data!)!;
        img = img_lib.copyResize(img, width: spec.width, height: spec.height);
        img_lib.encodePngFile(joinPaths(folder.path, '${spec.name}-${index + 1}.png'), img);
        img_lib.encodeJpgFile(joinPaths(folder.path, '${spec.name}-${index + 1}.jpg'), img, quality: 70);
      }
      EasyLoading.showSuccess('Done');
      print('Done: ${spec.name}');
    } catch (e, s) {
      EasyLoading.showError(e.toString());
      logger.e('screenshot failed: ${spec.name}', e, s);
    }
  }
}
