import 'dart:typed_data';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class ScreenshotsTab extends StatefulWidget {
  final Set<Uint8List> images;
  final VoidCallback onUpload;
  final String? debugServerRoot;
  const ScreenshotsTab({super.key, required this.images, required this.onUpload, this.debugServerRoot});

  @override
  State<ScreenshotsTab> createState() => _ScreenshotsTabState();
}

class _ScreenshotsTabState extends State<ScreenshotsTab> with ScrollControllerMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: getImageView()),
        kDefaultDivider,
        if (widget.debugServerRoot != null) Center(child: Text(widget.debugServerRoot!)),
        SafeArea(child: buttonBar),
      ],
    );
  }

  Widget getImageView() {
    final images = widget.images.toList();
    if (images.isEmpty) {
      return const SizedBox();
    }
    return ListView.separated(
      controller: scrollController,
      itemCount: images.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final image = images[index];
        return InkWell(
          child: Image.memory(image, fit: BoxFit.fitWidth),
          onTap: () {
            SimpleCancelOkDialog(
              title: Text(S.current.clear),
              onTapOk: () {
                widget.images.remove(image);
                if (mounted) setState(() {});
              },
            ).showDialog(context);
          },
        );
      },
    );
  }

  Widget get buttonBar {
    return OverflowBar(
      alignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            SimpleCancelOkDialog(
              title: Text(S.current.clear),
              onTapOk: () {
                if (mounted) {
                  widget.images.clear();
                  setState(() {});
                }
              },
            ).showDialog(context);
          },
          icon: const Icon(Icons.clear_all),
          tooltip: S.current.clear,
          constraints: const BoxConstraints(minWidth: 36, maxHeight: 24),
          padding: EdgeInsets.zero,
        ),
        IconButton(
          onPressed: importImages,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          tooltip: S.current.import_screenshot,
        ),
        ElevatedButton.icon(
          onPressed: widget.images.isEmpty ? null : widget.onUpload,
          icon: const Icon(Icons.upload),
          label: Text(S.current.upload),
        ),
      ],
    );
  }

  void importImages() {
    SharedBuilder.pickImageOrFiles(context: context)
        .then((result) {
          final files = result?.files;
          if (files != null) {
            for (final file in files) {
              if (file.bytes != null) {
                widget.images.add(file.bytes!);
              }
            }
          }
          if (mounted) {
            setState(() {});
          }
        })
        .catchError((e, s) {
          logger.e('import images error', e, s);
          EasyLoading.showError(e.toString());
        });
  }
}
