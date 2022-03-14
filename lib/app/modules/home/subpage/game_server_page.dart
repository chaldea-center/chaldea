import 'package:chaldea/components/localized/localized_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'package:flutter/material.dart';

class GameServerPage extends StatefulWidget {
  GameServerPage({Key? key}) : super(key: key);

  @override
  _GameServerPageState createState() => _GameServerPageState();
}

class _GameServerPageState extends State<GameServerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.game_server),
      ),
      body: SingleChildScrollView(
        child: TileGroup(
          children: [
            for (var server in Region.values) radioOf(server),
          ],
          footer: LocalizedText.of(
            chs: '当前与之关联的有：\n'
                ' - 素材交换券月份与每月兑换数量',
            jpn: '現在関連付けられている：\n'
                ' - 素材交換券の月の設定と交換回数',
            eng: 'Current related: \n'
                ' - Exchange Tickets\' month setting and limit per month',
            kor: '현재 관련되어 있음: \n'
                ' - 소재 교환권의 월 설정 및 교환 횟수',
          ),
        ),
      ),
    );
  }

  Widget radioOf(Region server) {
    return RadioListTile<Region>(
      value: server,
      groupValue: db2.curUser.region,
      title: Text(EnumUtil.upperCase(server)),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (v) {
        setState(() {
          if (v != null) db2.curUser.region = v;
        });
        db2.notifyUserdata();
      },
    );
  }
}
