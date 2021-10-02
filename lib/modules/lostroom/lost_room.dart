import 'package:chaldea/components/components.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'bond_farming.dart';
import 'support_party/support_party.dart';

class LostRoomPage extends StatelessWidget {
  LostRoomPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LOST ROOM')),
      body: ListView(
        children: [
          ListTile(
            subtitle: Center(
              child: Text(
                LocalizedText.of(
                    chs: '还在开发中，仅供预览\n欢迎提意见~',
                    jpn: '進行中の開発作業。\nプレビューのみ。',
                    eng:
                        'Work In Progress. Preview only.\n Suggestion welcomed.'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          kDefaultDivider,
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.userFriends),
            title: Text(S.current.support_party),
            subtitle: Text(
                LocalizedText.of(chs: '暂停', jpn: '一時停止', eng: 'Suspended')),
            onTap: () {
              SplitRoute.push(context, SupportPartyPage(), detail: null);
            },
          ),
          if (kDebugMode)
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.userFriends),
              title: const Text('Bond Farming'),
              onTap: () {
                SplitRoute.push(context, const BondFarmingPage());
              },
            ),
        ],
      ),
    );
  }
}
