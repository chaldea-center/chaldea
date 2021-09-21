import 'dart:math';
import 'dart:typed_data';

import 'package:chaldea/components/components.dart';
import 'package:photo_view/photo_view.dart';

class SupportResultPreview extends StatefulWidget {
  final Uint8List data;

  const SupportResultPreview({Key? key, required this.data}) : super(key: key);

  @override
  _SupportResultPreviewState createState() => _SupportResultPreviewState();
}

class _SupportResultPreviewState extends State<SupportResultPreview> {
  int? width;
  int? height;

  final PhotoViewController _controller = PhotoViewController();

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant SupportResultPreview oldWidget) {
    if (oldWidget.data != widget.data) _resolve();
    super.didUpdateWidget(oldWidget);
  }

  void _resolve() {
    width = null;
    height = null;
    final stream = MemoryImage(widget.data).resolve(ImageConfiguration.empty);
    stream.addListener(ImageStreamListener(
      (ImageInfo image, bool synchronousCall) {
        width = image.image.width;
        height = image.image.height;
        if (mounted) setState(() {});
      },
      onError: (e, s) {
        print(e);
        print(s);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.preview)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final t = DateTime.now().toString().replaceAll(RegExp(r'[^\d]'), '_');
          ImageActions.showSaveShare(
            context: context,
            data: widget.data,
            destFp: join(db.paths.downloadDir, 'support_setup_$t.png'),
            shareText: S.current.support_party,
          );
        },
        child: const Icon(Icons.save),
        tooltip: S.current.save,
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              width != null || height != null
                  ? 'Resolution: $width×$height'
                  : '???',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ClipRect(
              child: PhotoView(
                controller: _controller,
                backgroundDecoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor),
                loadingBuilder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                imageProvider: MemoryImage(widget.data),
                // maxScale: PhotoViewComputedScale.contained * 2.0,
                minScale: PhotoViewComputedScale.contained * 0.5,
                initialScale: PhotoViewComputedScale.contained,
                // tightMode: true,
              ),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  if (_controller.scale != null) {
                    _controller.scale = _controller.scale! * 1.25;
                  }
                },
                icon: const Icon(Icons.zoom_in),
                tooltip: 'Zoom In',
              ),
              IconButton(
                onPressed: () {
                  if (_controller.scale != null) {
                    _controller.scale = max(0.01, _controller.scale! * 0.8);
                  }
                },
                icon: const Icon(Icons.zoom_out),
                tooltip: 'Zoom Out',
              ),
              IconButton(
                onPressed: () {
                  _controller.rotation =
                      (_controller.rotation ~/ (pi / 2) - 1) % 4 * pi / 2;
                },
                icon: const Icon(Icons.rotate_left),
                tooltip: 'Rotate',
              ),
            ],
          )
        ],
      ),
    );
  }
}
