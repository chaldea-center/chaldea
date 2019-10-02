import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/generated/i18n.dart';
import 'package:chaldea/modules/home/gallery.dart';
import 'package:chaldea/modules/home/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatelessWidget {
  final _androidAppRetain = const MethodChannel("cc.narumi.chaldea");

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () {
      if (Platform.isAndroid) {
        if (Navigator.of(context).canPop()) {
          return Future.value(true);
        } else {
          _androidAppRetain.invokeMethod("sendBackground");
          print('sendBackground?');
          return Future.value(false);
        }
      } else {
        return Future.value(true);
      }
    }, child: SplitRoute.createMasterPage(
        context,
        BottomNavigation(
          tabs: [
            TabData(
                tab: Gallery(),
                tabName: S.of(context).gallery_tab_name,
                iconData: Icons.layers),
            TabData(
                tab: SettingsPage(),
                tabName: S.of(context).settings_tab_name,
                iconData: Icons.settings)
          ],
        )),);
  }
}
