import 'package:chaldea/components/localized/localized_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:share_plus/share_plus.dart';

class ShareAppDialog extends StatefulWidget {
  ShareAppDialog({Key? key}) : super(key: key);

  @override
  _ShareAppDialogState createState() => _ShareAppDialogState();
}

class _ShareAppDialogState extends State<ShareAppDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    String msg = LocalizedText.of(
        chs:
            "Chaldea——一款跨平台的Fate/GO素材规划客户端，支持游戏信息浏览、从者练度/活动/素材规划、周常规划、抽卡模拟器等功能。\n"
            "\n详情请见: \n$kProjectDocRoot/zh/\n",
        jpn:
            "Chaldea - クロスプラットフォームのFate/GOアイテム計画アプリ。ゲーム情報の閲覧、サーヴァント/イベント/アイテム計画、マスターミッション計画、ガチャシミュレーターなどの機能をサポートします。\n"
            "\n詳細はこちら: \n$kProjectDocRoot\n",
        eng:
            "Chaldea - A cross-platform utility for Fate/GO. Supporting game data review, servant/event/item planning, master mission planning, summon simulator and so on.\n"
            "\nSee for details: \n$kProjectDocRoot\n",
        kor:
            "Chaldea - 멀티 플랫폼의 Fate/GO 아이템 계획 어플. 게임정보의 열람 및 서번트/이벤트/아이템 계획, 마스터 미션 계획, 가챠 시뮬레이터 등의 기능을 서포트합니다.\n"
            "\n자세히 보기: \n$kProjectDocRoot\n");
    _controller = TextEditingController(text: msg);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleCancelOkDialog(
      title: Text(S.current.share),
      contentPadding:
          const EdgeInsetsDirectional.fromSTEB(24.0, 10.0, 24.0, 12.0),
      content: TextField(
        controller: _controller,
        maxLines: null,
        minLines: 5,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).highlightColor,
          focusColor: Theme.of(context).highlightColor,
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).dialogBackgroundColor)),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).dialogBackgroundColor)),
        ),
      ),
      hideOk: true,
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _controller.text)).then((_) {
              EasyLoading.showSuccess(S.current.copied);
            }).catchError((e, s) async {
              logger.e('copy share msg failed', e, s);
              EasyLoading.showError('Copy failed');
            });
          },
          child: Text(MaterialLocalizations.of(context).copyButtonLabel),
        ),
        if (!PlatformU.isWindows)
          TextButton(
            onPressed: () {
              Share.share(_controller.text).catchError((e, s) async {
                logger.e('Share text failed', e, s);
              });
            },
            child: Text(S.current.share),
          ),
      ],
    );
  }
}
