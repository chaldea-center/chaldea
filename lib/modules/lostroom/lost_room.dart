import 'package:chaldea/components/components.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
            onTap: () {
              SplitRoute.push(context, SupportPartyPage());
            },
          ),
        ],
      ),
    );
  }
}
