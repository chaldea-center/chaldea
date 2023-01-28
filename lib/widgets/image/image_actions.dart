import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'package:chaldea/app/tools/icon_cache_manager.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import '../../packages/packages.dart';
import '../custom_dialogs.dart';

class ImageActions {
  static Future showSaveShare({
    required BuildContext context,
    Uint8List? data,
    String? srcFp,
    String? url,
    bool gallery = true,
    String? destFp,
    bool share = true,
    String? shareText,
    List<Widget> extraHeaders = const [],
    Future<void> Function()? onClearCache,
  }) {
    assert(srcFp != null || data != null);
    if (srcFp == null && data == null) return Future.value();
    return showMaterialModalBottomSheet(
      context: context,
      duration: const Duration(milliseconds: 250),
      builder: (context) {
        List<Widget> children = [
          ...extraHeaders,
          if (url != null)
            ListTile(
              dense: true,
              title: Text(url, style: Theme.of(context).textTheme.bodySmall),
              onLongPress: () {
                copyToClipboard(url);
                EasyLoading.showToast(S.current.copied);
              },
            )
        ];
        if (kIsWeb && srcFp != null && !srcFp.startsWith(kStaticHostRoot)) {
          children.add(ListTile(
            leading: const Icon(Icons.download),
            title: Text(S.current.download),
            onTap: () async {
              if (await canLaunch(srcFp)) {
                launch(srcFp);
              }
            },
          ));
        }
        if (gallery && PlatformU.isMobile) {
          children.add(ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(S.current.save_to_photos),
            onTap: () async {
              Navigator.pop(context);
              if (PlatformU.isAndroid && await Permission.storage.isDenied) {
                await Permission.storage.request();
              }
              dynamic result;
              if (data != null) {
                result = await ImageGallerySaver.saveImage(data);
              } else if (srcFp != null) {
                result = await ImageGallerySaver.saveFile(srcFp);
              }
              if (result is Map && result['isSuccess'] == true) {
                EasyLoading.showSuccess(S.current.saved);
              } else {
                String? msg;
                if (result is Map) {
                  msg = result['errorMessage'];
                }
                EasyLoading.showError((msg ?? result).toString());
              }
            },
          ));
        }
        if (!PlatformU.isWeb && destFp != null) {
          children.add(ListTile(
            leading: const Icon(Icons.save),
            title: Text(S.current.save),
            onTap: () {
              Navigator.pop(context);
              final bytes = data ?? File(srcFp!).readAsBytesSync();
              File(destFp).parent.createSync(recursive: true);
              File(destFp).writeAsBytesSync(bytes);
              SimpleCancelOkDialog(
                hideCancel: true,
                title: Text(S.current.saved),
                content: Text(db.paths.convertIosPath(destFp)),
                actions: [
                  if (PlatformU.isDesktop)
                    TextButton(
                      onPressed: () {
                        openFile(dirname(destFp));
                      },
                      child: Text(S.current.open),
                    ),
                ],
              ).showDialog(context);
            },
          ));
        }
        if (kIsWeb && data != null) {
          children.add(ListTile(
            leading: const Icon(Icons.save),
            title: Text(S.current.save),
            onTap: () {
              Navigator.pop(context);
              kPlatformMethods.downloadFile(
                  data, pathlib.basename(destFp ?? 'downloadimage.png'));
            },
          ));
        }
        if (share && PlatformU.isMobile) {
          children.add(ListTile(
            leading: const Icon(Icons.share),
            title: Text(S.current.share),
            onTap: () async {
              Navigator.pop(context);
              if (srcFp != null) {
                await ShareX.shareFile(srcFp,
                    text: shareText, context: context);
              } else if (data != null) {
                // Although, it may not be PNG
                String fn =
                    '${const Uuid().v5(Uuid.NAMESPACE_URL, data.hashCode.toString())}.png';
                String tmpFp = join(db.paths.tempDir, fn);
                File(tmpFp)
                  ..createSync(recursive: true)
                  ..writeAsBytesSync(data);
                await ShareX.shareFile(tmpFp,
                    text: shareText, context: context);
              }
            },
          ));
        }
        if (onClearCache != null) {
          children.add(ListTile(
            leading: const Icon(Icons.cached),
            title: Text(S.current.clear_cache),
            onTap: () {
              Navigator.pop(context);
              onClearCache();
            },
          ));
        }
        children.addAll([
          Material(
            color: Colors.grey.withOpacity(0.1),
            child: const SizedBox(height: 6),
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: Text(S.current.cancel),
            onTap: () {
              Navigator.pop(context);
            },
          )
        ]);
        return ListView.separated(
          shrinkWrap: true,
          controller: ModalScrollController.of(context),
          itemBuilder: (context, index) => children[index],
          separatorBuilder: (_, __) =>
              const Divider(height: 0.5, thickness: 0.5),
          itemCount: children.length,
        );
      },
    );
  }

  static Future<ui.Image?> resolveImageUrl(String url,
      {BuildContext? context}) async {
    ImageProvider provider;
    if (AtlasIconLoader.i.shouldCacheImage(url)) {
      final fp = await AtlasIconLoader.i.get(url);
      if (fp == null) {
        return null;
      }
      provider = FileImage(File(fp));
    } else {
      provider = CachedNetworkImageProvider(url);
    }
    if (context != null && context.mounted) {
      return resolveImage(provider, context: context);
    }
    return resolveImage(provider);
  }

  // resolve one frame
  static Future<ui.Image?> resolveImage(ImageProvider provider,
      {BuildContext? context}) async {
    final completer = Completer<ui.Image?>();
    // context ??= kAppKey.currentContext;
    final stream = provider.resolve(context != null && context.mounted
        ? createLocalImageConfiguration(context)
        : ImageConfiguration.empty);
    ImageStreamListener? listener;
    listener = ImageStreamListener(
      (image, synchronousCall) {
        if (completer.isCompleted) {
          return;
        }
        completer.complete(image.image);
        if (listener != null) stream.removeListener(listener);
      },
      onError: (e, s) {
        if (completer.isCompleted) {
          logger.e('onError why completed!', e, s);
          return;
        }
        print('resolve image provider failed $e');
        // FlutterError.dumpErrorToConsole(
        //     FlutterErrorDetails(exception: e, stack: s));
        completer.complete(null);
        if (listener != null) stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }
}
