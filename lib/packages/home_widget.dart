import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import 'package:chaldea/models/models.dart';
import 'platform/platform.dart';

class HomeWidgetX {
  const HomeWidgetX._();

  static final bool isSupported = PlatformU.isIOS;

  static Future<bool?> init() async {
    if (isSupported) {
      return HomeWidget.setAppGroupId('group.cc.narumi.chaldea.shared');
    }
    return null;
  }

  static Future<bool?> saveJsonData(String key, dynamic data) async {
    if (!isSupported) return null;
    return HomeWidget.saveWidgetData('accountsData', jsonEncode(data));
  }

  static Future<bool?> saveFakerStatus() async {
    if (!isSupported) return null;
    List<WidgetAccountInfo> accounts = [];
    for (final account in db.settings.fakerSettings.allAccounts) {
      final userGame = account.userGame;
      if (userGame == null) continue;
      accounts.add(
        WidgetAccountInfo(
          id: '${account.region.upper}-${userGame.friendCode}',
          name: userGame.name.replaceAll(RegExp(r'\[(o|g)\]'), ''),
          gameServer: account.region,
          biliServer: account.serverName,
          actMax: userGame.actMax,
          actRecoverAt: userGame.actRecoverAt,
          carryOverActPoint: userGame.carryOverActPoint,
        ),
      );
    }
    return HomeWidget.saveWidgetData('accountsData', jsonEncode(accounts));
  }

  static Future<bool?> updateFakerStatus() async {
    if (!isSupported) return null;
    return HomeWidget.updateWidget(name: 'FakerStatusWidget', iOSName: 'FakerStatusWidget');
  }
}
