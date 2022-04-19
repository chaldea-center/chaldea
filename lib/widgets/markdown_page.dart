import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../models/models.dart';

class MyMarkdownWidget extends StatefulWidget {
  final String? data;
  final String? assetKey;
  final bool selectable;
  final bool scrollable;
  final md.ExtensionSet? extensionSet;

  const MyMarkdownWidget({
    Key? key,
    this.data,
    this.assetKey,
    this.selectable = false,
    this.scrollable = true,
    this.extensionSet,
  })  : assert(
            (data != null || assetKey != null) &&
                (data == null || assetKey == null),
            'Must provide data or assetKey'),
        super(key: key);

  @override
  _MyMarkdownWidgetState createState() => _MyMarkdownWidgetState();
}

class _MyMarkdownWidgetState extends State<MyMarkdownWidget> {
  String? assetData;

  @override
  void initState() {
    super.initState();
    if (widget.assetKey != null) {
      rootBundle
          .loadString(widget.assetKey!, cache: false)
          .then((value) => assetData = value)
          .catchError((e, s) async {
        logger.e('error loading markdown asset ${widget.assetKey}', e, s);
        return 'Loading error';
      }).whenComplete(
        () {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
            if (mounted) setState(() {});
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data ?? assetData;
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.scrollable) {
      return Markdown(
        data: data,
        selectable: widget.selectable,
        imageBuilder: imageBuilder,
        onTapLink: onTapLink,
        extensionSet: widget.extensionSet,
      );
    } else {
      return MarkdownBody(
        data: data,
        selectable: widget.selectable,
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
      cachedOption: CachedImageOption(
          errorWidget: (ctx, url, e) => Text("[${title ?? alt ?? ''}]")),
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

class MarkdownHelpPage extends StatefulWidget {
  final String dir;

  final String? data;

  final String? asset;
  final String? assetJp;
  final String? assetEn;

  final Widget? leading;
  final Widget? title;
  final List<Widget> actions;

  const MarkdownHelpPage({
    Key? key,
    this.dir = 'doc/help',
    this.data,
    this.asset,
    this.assetJp,
    this.assetEn,
    this.leading = const BackButton(),
    this.title,
    this.actions = const [],
  })  : assert(data != null ||
            asset != null ||
            assetJp != null ||
            assetEn != null),
        super(key: key);

  const MarkdownHelpPage.localized({
    Key? key,
    this.dir = 'doc/help',
    required this.asset,
    this.leading = const BackButton(),
    this.title,
    this.actions = const [],
  })  : data = null,
        assetJp = 'jp/$asset',
        assetEn = 'en/$asset',
        super(key: key);

  static Future<String?> loadHelpAsset({
    String dir = 'doc/help',
    required String? asset,
    String? assetJp,
    String? assetEn,
    Duration? lapse,
  }) async {
    String? content;
    for (final region in db.settings.resolvedPreferredRegions) {
      switch (region) {
        case Region.jp:
          content = await _loadAsset(
              joinPaths(dir, assetJp ?? joinPaths('jp', asset)));
          break;
        case Region.cn:
          content = await _loadAsset(joinPaths(dir, asset));
          break;
        case Region.na:
          content = await _loadAsset(
              joinPaths(dir, assetEn ?? joinPaths('en', asset)));
          break;
        default:
          break;
      }
      if (content != null) {
        break;
      }
    }

    if (lapse != null) {
      await Future.delayed(lapse);
    }
    return content;
  }

  static Future<String?> _loadAsset(String? assetKey) async {
    if (assetKey == null) return null;
    assetKey = assetKey.replaceAll('\\', '/');
    String? content;
    try {
      content = await rootBundle.loadString(assetKey);
      print('load $assetKey');
    } catch (e) {
      content = null;
    }
    if (content?.trim().isNotEmpty == true) {
      return content;
    }
    return null;
  }

  static Widget buildHelpBtn(BuildContext context, String asset) {
    return IconButton(
      onPressed: () {
        router.pushPage(MarkdownHelpPage.localized(asset: asset));
      },
      icon: const Icon(Icons.help_outline),
      tooltip: S.current.help,
    );
  }

  @override
  _MarkdownHelpPageState createState() => _MarkdownHelpPageState();
}

class _MarkdownHelpPageState extends State<MarkdownHelpPage> {
  String? _resolvedData;

  void _parse() async {
    if (widget.data != null) {
      _resolvedData = widget.data;
    } else {
      _resolvedData = await MarkdownHelpPage.loadHelpAsset(
            dir: widget.dir,
            asset: widget.asset,
            assetJp: widget.assetJp,
            assetEn: widget.assetEn,
          ) ??
          'Load failed';
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(kSplitRouteDuration, _parse).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant MarkdownHelpPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data ||
        widget.dir != oldWidget.dir ||
        widget.asset != oldWidget.asset ||
        widget.assetJp != oldWidget.assetJp ||
        widget.assetEn != oldWidget.assetEn) {
      _parse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.leading,
        title: widget.title ?? Text(S.current.help),
        actions: widget.actions,
      ),
      body: _resolvedData == null
          ? const Center(child: CircularProgressIndicator())
          : MyMarkdownWidget(data: _resolvedData, selectable: true),
    );
  }
}
