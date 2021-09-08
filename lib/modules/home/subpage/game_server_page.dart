import 'package:chaldea/components/components.dart';

class GameServerPage extends StatefulWidget {
  const GameServerPage({Key? key}) : super(key: key);

  @override
  _GameServerPageState createState() => _GameServerPageState();
}

class _GameServerPageState extends State<GameServerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(S.current.server),
      ),
      body: SingleChildScrollView(
        child: TileGroup(
          children: [
            for (var server in GameServer.values) radioOf(server),
          ],
          footer: LocalizedText.of(
              chs: '当前与之关联的有：\n'
                  ' - 素材交换券月份与每月兑换数量',
              jpn: '現在関連付けられている：\n'
                  ' - 素材交換券の月の設定と交換回数',
              eng: 'Current related: \n'
                  ' - Exchange Tickets\' month setting and limit per month'),
        ),
      ),
    );
  }

  Widget radioOf(GameServer server) {
    return RadioListTile<GameServer>(
      value: server,
      groupValue: db.curUser.server,
      title: Text(server.localized),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (v) {
        setState(() {
          if (v != null) db.curUser.server = v;
        });
        db.notifyDbUpdate();
      },
    );
  }
}
