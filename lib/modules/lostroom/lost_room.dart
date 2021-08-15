import 'package:chaldea/components/components.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LostRoomPage extends StatelessWidget {
  const LostRoomPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LOST ROOM')),
      body: ListView(
        children: [
          ListTile(
            subtitle: Center(
              child: Text(
                LocalizedText.of(chs: '试验性功能\n若有问题请反馈', jpn: '', eng: ''),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          kDefaultDivider,
          ListTile(
            leading: FaIcon(FontAwesomeIcons.userFriends),
            title: Text(S.current.support_party),
          )
        ],
      ),
    );
  }
}
