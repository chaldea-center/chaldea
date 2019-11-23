import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:flutter/services.dart';

import 'gallery_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _androidAppRetain = const MethodChannel("cc.narumi.chaldea");
  int _curIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (Platform.isAndroid) {
          if (Navigator.of(context).canPop()) {
            return Future.value(true);
          } else {
            _androidAppRetain.invokeMethod("sendBackground");
            print('sendBackground');
            return Future.value(false);
          }
        } else {
          return Future.value(true);
        }
      },
      child: SplitRoute.createMasterPage(
          context,
          Scaffold(
            body: IndexedStack(
              index: _curIndex,
              children: <Widget>[GalleryPage(), SettingsPage()],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _curIndex,
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.layers),
                    title: Text(S.of(context).gallery_tab_name)),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    title: Text(S.of(context).settings_tab_name)),
              ],
              onTap: (index) => setState(() => _curIndex = index),
            ),
          )),
    );
  }
}
