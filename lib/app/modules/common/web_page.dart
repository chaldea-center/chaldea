import 'package:webview_flutter/webview_flutter.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

Future<void> openInAppWebView(BuildContext context, String url, {String? title}) {
  if (!PlatformU.isMobile && !PlatformU.isMacOS) return launch(url);
  final page = WebViewPage(url: url, title: title);
  return Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key, required this.url, this.title});

  final String url;
  final String? title;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (mounted && p != _progress) setState(() => _progress = p);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? Uri.parse(widget.url).host),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: S.current.open_in_browser,
            onPressed: () => launch(widget.url, external: true),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_progress < 100) LinearProgressIndicator(value: _progress / 100),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}
