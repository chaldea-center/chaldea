import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'network_settings.dart';

class ChaldeaServerPage extends StatefulWidget {
  const ChaldeaServerPage({super.key});

  @override
  _ChaldeaServerPageState createState() => _ChaldeaServerPageState();
}

class _ChaldeaServerPageState extends State<ChaldeaServerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.chaldea_server),
      ),
      body: ListView(children: [
        TileGroup(
          footer: Language.isCHS ? '对于大陆用户，若海外路线可正常使用，请尽量使用海外路线以节约流量费！' : null,
          children: [
            for (final useProxy in [false, true])
              RadioListTile<bool>(
                value: useProxy,
                groupValue: db.settings.proxyServer,
                title: Text(useProxy
                    ? S.current.chaldea_server_cn
                    : S.current.chaldea_server_global),
                // subtitle: Text(region.toLanguage().name),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) {
                  setState(() {
                    if (v != null) {
                      db.settings.proxyServer = v;
                    }
                    if (kIsWeb) {
                      kPlatformMethods.setLocalStorage(
                          'useProxy', v.toString());
                    }
                    db.saveSettings();
                  });
                  db.notifySettings();
                },
              )
          ],
        ),
        TextButton(
          onPressed: () {
            router.push(child: const NetworkSettingsPage());
          },
          child: Text(S.current.network_settings),
        ),
      ]),
    );
  }
}
