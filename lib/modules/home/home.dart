import 'package:chaldea/components/components.dart';
import 'package:chaldea/generated/i18n.dart';
import 'package:chaldea/modules/home/gallery.dart';
import 'package:chaldea/modules/home/settings_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SplitRoute.createMasterPage(
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
        ));
  }
}
