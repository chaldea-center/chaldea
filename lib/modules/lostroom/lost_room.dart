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
                  chs: '准备v2版本ing\n暂停新功能开发',
                  jpn: 'v2バージョンを準備する\n新機能の開発を一時停止する',
                  eng:
                      'Preparing v2 version\nSuspend the development of new features',
                  kor: 'v2버전 준비중\n새 기능 개발 일시 중단',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          kDefaultDivider,
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.userFriends),
            title: Text(S.current.support_party),
            subtitle: Text(LocalizedText.of(
                chs: '暂停', jpn: '一時停止', eng: 'Suspended', kor: '일시중단')),
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
