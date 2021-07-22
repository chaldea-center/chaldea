import 'package:chaldea/components/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

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
    required String asset,
    this.leading = const BackButton(),
    this.title,
    this.actions = const [],
  })  : data = null,
        asset = asset,
        assetJp = 'jp/$asset',
        assetEn = 'en/$asset',
        super(key: key);

  static Future<String?> loadHelpAsset({
    String dir = 'doc/help',
    required String? asset,
    String? assetJp,
    String? assetEn,
  }) async {
    return LocalizedText.of(
      chs: await _loadAsset(join(dir, asset)) ?? '',
      jpn: await _loadAsset(assetJp ?? join(dir, 'jp', asset)),
      eng: await _loadAsset(assetEn ?? join(dir, 'en', asset)),
    );
  }

  static Future<String?> _loadAsset(String? assetKey) async {
    if (assetKey == null) return null;
    String? content;
    try {
      content = await rootBundle.loadString(assetKey);
    } catch (e) {}
    if (content?.trim().isNotEmpty == true) {
      return content;
    }
  }

  static Widget buildHelpBtn(BuildContext context, String asset) {
    return IconButton(
      onPressed: () {
        SplitRoute.push(
          context,
          MarkdownHelpPage.localized(asset: asset),
        );
      },
      icon: Icon(Icons.help_outline),
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
      );
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _parse();
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
    _parse();
    return Scaffold(
      appBar: AppBar(
        leading: widget.leading,
        title: widget.title ?? Text(S.current.help),
        actions: widget.actions,
      ),
      body: _resolvedData == null
          ? Center(child: CircularProgressIndicator())
          : MyMarkdownWidget(data: _resolvedData, selectable: true),
    );
  }
}
