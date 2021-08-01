import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/method_channel_chaldea.dart';

import 'gallery_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _curIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        db.saveUserData();
        if (Platform.isAndroid) {
          if (Navigator.of(context).canPop()) {
            return Future.value(true);
          } else {
            MethodChannelChaldea.sendBackground();
            print('sendBackground');
            return Future.value(false);
          }
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _curIndex,
          children: <Widget>[GalleryPage(), SettingsPage()],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _curIndex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.layers),
                label: S.of(context).gallery_tab_name),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: S.of(context).settings_tab_name),
          ],
          onTap: (index) {
            if (_curIndex != index) db.saveUserData();
            setState(() => _curIndex = index);
          },
        ),
      ),
    );
  }
}
