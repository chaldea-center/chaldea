import 'dart:typed_data';

import 'package:chaldea/components/components.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

mixin ImageActionMixin {
  Future showSaveShare({
    required BuildContext context,
    Uint8List? data,
    String? srcFp,
    //
    bool gallery = true,
    String? destFp,
    bool share = true,
    String? shareText,
  }) {
    assert(srcFp != null || data != null);
    if (srcFp == null && data == null) return Future.value();
    return showMaterialModalBottomSheet(
      context: context,
      duration: const Duration(milliseconds: 250),
      builder: (context) {
        List<Widget> children = [];
        if (gallery && AppInfo.isMobile) {
          children.add(ListTile(
            leading: Icon(Icons.photo_library),
            title: Text(S.current.save_to_photos),
            onTap: () async {
              Navigator.pop(context);
              if (data != null) {
                await ImageGallerySaver.saveImage(data);
              } else if (srcFp != null) {
                await ImageGallerySaver.saveFile(srcFp);
              }
              EasyLoading.showSuccess(S.current.saved);
            },
          ));
        }
        if (destFp != null) {
          children.add(ListTile(
            leading: Icon(Icons.save),
            title: Text(S.current.save),
            onTap: () {
              Navigator.pop(context);
              final bytes = data ?? File(srcFp!).readAsBytesSync();
              File(destFp)
                ..createSync(recursive: true)
                ..writeAsBytesSync(bytes);
              SimpleCancelOkDialog(
                hideCancel: true,
                title: Text(S.current.saved),
                content: Text(db.paths.convertIosPath(destFp)),
                actions: [
                  if (AppInfo.isDesktop)
                    TextButton(
                      onPressed: () {
                        OpenFile.open(path.dirname(destFp));
                      },
                      child: Text(S.current.open),
                    ),
                ],
              ).showDialog(context);
            },
          ));
        }
        if (share && AppInfo.isMobile) {
          children.add(ListTile(
            leading: Icon(Icons.share),
            title: Text(S.current.share),
            onTap: () async {
              Navigator.pop(context);
              if (srcFp != null) {
                await Share.shareFiles([srcFp], text: shareText);
              } else if (data != null) {
                // Although, it may not be PNG
                String fn =
                    Uuid().v5(Uuid.NAMESPACE_URL, data.hashCode.toString()) +
                        '.png';
                String tmpFp = join(db.paths.tempDir, fn);
                File(tmpFp)
                  ..createSync(recursive: true)
                  ..writeAsBytesSync(data);
                await Share.shareFiles([tmpFp], text: shareText);
              }
            },
          ));
        }
        children.addAll([
          Material(
            color: Colors.grey.withOpacity(0.2),
            child: const SizedBox(height: 6),
          ),
          ListTile(
            leading: Icon(Icons.close),
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
          separatorBuilder: (_, __) => Divider(height: 0.5, thickness: 0.5),
          itemCount: children.length,
        );
      },
    );
  }
}
