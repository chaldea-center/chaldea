import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class DiscordPage extends StatelessWidget {
  const DiscordPage({super.key});
  // the rendered color is different 0xff586be1
  static const discordThemeColor = Color(0xff5768e9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discord'),
        backgroundColor: Theme.of(context).isDarkMode ? null : discordThemeColor,
        // leading: const BackButton(),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.discord,
                size: 80,
                color: Theme.of(context).isDarkMode ? null : discordThemeColor,
              ),
              Text(kAppName, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              urlWithCopy(context, 'https://chaldea.center/discord'),
              Text(S.current.logic_type_or, style: Theme.of(context).textTheme.bodySmall),
              urlWithCopy(context, 'https://discord.com/invite/5M6w5faqjP'),
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }

  Widget urlWithCopy(BuildContext context, String url) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: InkWell(
            onTap: () {
              launch(url);
            },
            child: Text(
              url,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            copyToClipboard(url);
            EasyLoading.showToast(S.current.copied);
          },
          icon: const Icon(Icons.copy),
          iconSize: 16,
          tooltip: S.current.copy,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
