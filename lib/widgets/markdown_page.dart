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
  final String? dir;

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

  static Widget buildHelpBtn(BuildContext context, String asset) {
    return IconButton(
      onPressed: () {
        SplitRoute.push2(
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

  int get _dataHash {
    return hashValues(dir, data, asset, assetJp, assetEn);
  }
}

class _MarkdownHelpPageState extends State<MarkdownHelpPage> {
  int? _cachedDataHash;
  String? _resolvedData;

  void _parse() async {
    final _dataHash = widget._dataHash;
    if (_dataHash == _cachedDataHash) return;
    _cachedDataHash = _dataHash;
    if (widget.data != null) {
      _resolvedData = widget.data;
    } else {
      _resolvedData = LocalizedText.of(
          chs: await _loadAsset(widget.asset) ?? '',
          jpn: await _loadAsset(widget.assetJp),
          eng: await _loadAsset(widget.assetEn));
    }
    if (mounted) setState(() {});
  }

  Future<String?> _loadAsset(String? assetKey) async {
    if (assetKey == null) return null;
    assetKey = join(widget.dir ?? '', assetKey);
    String? content;
    try {
      content = await rootBundle.loadString(assetKey);
    } catch (e) {}
    if (content?.trim().isNotEmpty == true) {
      return content;
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
