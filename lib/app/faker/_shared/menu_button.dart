import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../modules/import_data/import_https_page.dart';
import '../combine/svt_combine.dart';
import '../combine/svt_equip_combine.dart';
import '../details/box_gacha.dart';
import '../details/trade.dart';
import '../event/random_mission_loop.dart';
import '../gacha/gacha_draw.dart';
import '../mission/mission_receive.dart';
import '../runtime.dart';
import '../shop/shop_event_list.dart';
import 'history.dart';

class _ButtonData {
  final IconData icon;
  final String name;
  final bool enabled;
  final VoidCallback? onTap;

  const _ButtonData({required this.icon, required this.name, this.enabled = true, required this.onTap});
}

class FakerMenuButton extends StatefulWidget {
  final FakerRuntime runtime;
  const FakerMenuButton({super.key, required this.runtime});

  @override
  State<FakerMenuButton> createState() => _FakerMenuButtonState();
}

class _FakerMenuButtonState extends State<FakerMenuButton> with FakerRuntimeStateMixin {
  @override
  late final runtime = widget.runtime;

  @override
  Widget build(BuildContext context) {
    final gameTop = runtime.agent.network.gameTop;
    final timerData = runtime.gameData.timerData;

    final bool isLoggedIn = mstData.isLoggedIn;

    return AlertDialog(
      title: const Text('Fake/Grand Order'),
      titleTextStyle: const TextStyle(fontSize: 18),
      titlePadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: EdgeInsets.fromLTRB(24, 4, 24, 20),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              [
                '[${runtime.agent.user.serverName}] ${runtime.agent.user.userGame?.friendCode}',
                if ((gameTop.hash, gameTop.timestamp) == (timerData.hash, timerData.timestamp))
                  fmtVer('data: ', gameTop.hash, gameTop.timestamp)
                else ...[
                  fmtVer('top = ', gameTop.hash, gameTop.timestamp),
                  fmtVer('timer=', timerData.hash ?? "", timerData.timestamp),
                ],
              ].join('\n'),
              style: Theme.of(context).textTheme.bodySmall?.merge(kMonoStyle),
            ),
          ),
          buildGroup(
            title: 'Data',
            buttons: [
              _ButtonData(
                icon: Icons.history,
                name: S.current.history,
                onTap: () {
                  router.pushPage(FakerHistoryViewer(agent: runtime.agent));
                },
              ),
              _ButtonData(
                icon: Icons.refresh,
                name: S.current.refresh,
                onTap: () {
                  runtime.runTask(() async {
                    await runtime.agent.network.updateGameTop();
                    await runtime.gameData.init(refresh: true);
                  });
                },
              ),
              _ButtonData(
                icon: Icons.cloud_download,
                name: S.current.import_data,
                enabled: isLoggedIn,
                onTap: () {
                  router.pushPage(ImportHttpPage(mstData: mstData));
                },
              ),
              _ButtonData(
                icon: Icons.content_copy,
                name: S.current.copy,
                enabled: isLoggedIn,
                onTap: () {
                  db.runtimeData.clipBoard.mstData = mstData;
                  EasyLoading.showToast('${S.current.copied} (In-app)');
                },
              ),
            ],
          ),
          buildGroup(
            title: S.current.enhance,
            buttons: [
              _ButtonData(
                icon: FontAwesomeIcons.dice,
                name: S.current.gacha,
                enabled: isLoggedIn,
                onTap: () {
                  router.pushPage(GachaDrawPage(runtime: runtime));
                },
              ),
              _ButtonData(
                icon: FontAwesomeIcons.listCheck,
                name: S.current.master_mission,
                enabled: isLoggedIn,
                onTap: () {
                  router.pushPage(UserEventMissionReceivePage(runtime: runtime));
                },
              ),
              _ButtonData(
                icon: FontAwesomeIcons.users,
                name: '从者强化',
                enabled: isLoggedIn,
                onTap: () {
                  router.pushPage(SvtCombinePage(runtime: runtime));
                },
              ),
              _ButtonData(
                icon: FontAwesomeIcons.streetView,
                name: '礼装强化',
                enabled: isLoggedIn,
                onTap: () {
                  router.pushPage(SvtEquipCombinePage(runtime: runtime));
                },
              ),
            ],
          ),
          buildGroup(
            title: S.current.event,
            buttons: [
              _ButtonData(
                icon: Icons.shop,
                name: S.current.shop,
                enabled: isLoggedIn,
                onTap: () {
                  router.pushPage(ShopEventListPage(runtime: runtime));
                },
              ),
              if (mstData.userEventTrade.isNotEmpty)
                _ButtonData(
                  icon: Icons.event,
                  name: S.current.event_trade,
                  onTap: () {
                    router.pushPage(UserEventTradePage(runtime: runtime));
                  },
                ),
              if (mstData.userBoxGacha.isNotEmpty)
                _ButtonData(
                  icon: Icons.event,
                  name: S.current.event_lottery,
                  onTap: () {
                    router.pushPage(BoxGachaDrawPage(runtime: runtime));
                  },
                ),
              if (mstData.userEventRandomMission.isNotEmpty)
                _ButtonData(
                  icon: Icons.event,
                  name: S.current.random_mission,
                  onTap: () {
                    router.pushPage(RandomMissionLoopPage(runtime: runtime));
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildGroup({required String title, required List<_ButtonData> buttons}) {
    if (buttons.isEmpty) return const SizedBox.shrink();
    const int x = 56, y1 = 42, y2 = 32;
    List<Widget> children = [];
    final disabledColor = Theme.of(context).disabledColor;
    for (final button in buttons) {
      final color = button.enabled ? null : disabledColor;
      Widget child = SizedBox(
        width: x.toDouble(),
        height: (y1 + y2).toDouble(),
        child: Column(
          children: [
            Expanded(
              flex: x,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: button.icon.isFontAwesome
                      ? FaIcon(button.icon, size: (y1 - 4) * 0.8, color: color)
                      : Icon(button.icon, size: y1 - 4, color: color),
                ),
              ),
            ),
            Expanded(
              flex: y2,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
                  child: Text(
                    button.name,
                    maxLines: 2,
                    style: TextStyle(fontSize: 11),
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      if (button.onTap != null && button.enabled) {
        child = InkWell(
          onTap: () {
            Navigator.pop(context);
            button.onTap!();
          },
          child: child,
        );
      }
      children.add(child);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        kDefaultDivider,
        SHeader(title, padding: const EdgeInsetsDirectional.only(top: 8.0, bottom: 4.0)),
        Wrap(spacing: 2, runSpacing: 2, children: children),
        const SizedBox(height: 8),
      ],
    );
  }

  String fmtVer(String? prefix, String hash, int timestamp) {
    return '${prefix ?? ""}$hash, ${timestamp.sec2date().toCustomString(year: false, second: false)}';
  }
}
