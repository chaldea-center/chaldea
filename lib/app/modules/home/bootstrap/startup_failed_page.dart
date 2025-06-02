import 'package:flutter/foundation.dart';

import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class StartupFailedPage extends StatelessWidget {
  final dynamic error;
  final StackTrace? stackTrace;
  final bool wrapApp;
  const StartupFailedPage({super.key, required this.error, this.stackTrace, this.wrapApp = false});

  @override
  Widget build(BuildContext context) {
    if (wrapApp) {
      return MaterialApp(
        title: kAppName,
        themeMode: ThemeMode.light,
        home: Scaffold(body: buildContent(context)),
      );
    }
    return buildContent(context);
  }

  Widget buildContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsetsDirectional.all(24),
      children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: ImageUtil.getChaldeaBackground(context)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                launch('$kProjectDocRoot/guide/faq', external: true);
              },
              child: const Text('FAQ(English)'),
            ),
            TextButton(
              onPressed: () {
                launch('$kProjectDocRoot/zh/guide/faq', external: true);
              },
              child: const Text('FAQ(中文)'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (kIsWeb)
          const Text(
            'Web? InPrivate or "Clear history when close" in some browsers (e.g. FireFox) may block IndexedDB which app needed.\n'
            '部分浏览器如FireFox在无痕模式下或开启退出时清除历史记录时会禁用IndexedDB而使app无法启动\n',
          ),
        Text('Error: $error', style: Theme.of(context).textTheme.titleMedium),
        if (stackTrace != null) Text('\n\n$stackTrace', style: Theme.of(context).textTheme.bodySmall),
        const SafeArea(child: SizedBox()),
      ],
    );
  }
}
