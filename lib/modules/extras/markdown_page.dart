import 'package:chaldea/components/image_viewer.dart';
import 'package:chaldea/components/logger.dart';
import 'package:chaldea/components/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

class MyMarkdownPage extends StatefulWidget {
  final String? data;
  final String? assetKey;
  final bool scrollable;
  final md.ExtensionSet? extensionSet;

  const MyMarkdownPage({
    Key? key,
    this.data,
    this.assetKey,
    this.scrollable = true,
    this.extensionSet,
  })  : assert(
            (data != null || assetKey != null) &&
                (data == null || assetKey == null),
            'Must provide data or assetKey'),
        super(key: key);

  @override
  _MyMarkdownPageState createState() => _MyMarkdownPageState();
}

class _MyMarkdownPageState extends State<MyMarkdownPage> {
  String? assetData;

  @override
  void initState() {
    super.initState();
    if (widget.assetKey != null) {
      rootBundle
          .loadString(widget.assetKey!)
          .then((value) => assetData = value)
          .catchError((e, s) {
        logger.e('error loading markdown asset ${widget.assetKey}', e, s);
        return 'Loading error';
      }).whenComplete(
        () => Utils.scheduleFrameCallback(() {
          if (mounted) this.setState(() {});
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data ?? assetData;
    if (data == null) {
      return Center(child: CircularProgressIndicator());
    }
    if (widget.scrollable) {
      return Markdown(
        data: data,
        imageBuilder: imageBuilder,
        onTapLink: onTapLink,
        extensionSet: widget.extensionSet,
      );
    } else {
      return MarkdownBody(
        data: data,
        imageBuilder: imageBuilder,
        onTapLink: onTapLink,
        extensionSet: widget.extensionSet,
      );
    }
  }

  Widget imageBuilder(Uri uri, String? title, String? alt) {
    return CachedImage(
      imageUrl: uri.toString(),
      placeholder: (_, __) => Container(),
      errorWidget: (ctx, url, e) => Text("[${title ?? alt ?? ''}]"),
    );
  }

  void onTapLink(String text, String? href, String title) async {
    // print('text=$text,href=$href,title=$title');
    if (href?.isNotEmpty != true) return;
    try {
      await launch(href!);
    } catch (e) {
      logger.e(
          'Markdown link: cannot launch "$href", text="$text", title="$title"',
          e);
      EasyLoading.showError('Cannot launch url:\n$href');
    }
  }
}
