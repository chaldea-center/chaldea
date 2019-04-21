import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  final List<TabData> tabs;

  const BottomNavigation({Key key, @required this.tabs}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _curIndex = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: widget.tabs[_curIndex].tab,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            //set background color of BottomNavigatorBar
            canvasColor: Color(0xFFEEEEEF)),
        child: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              _curIndex = index;
            });
          },
          currentIndex: _curIndex,
          items: widget.tabs.map((TabData tab) {
            return BottomNavigationBarItem(
                icon: Icon(tab.iconData), title: Text(tab.tabName));
          }).toList(),
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

class TabData {
  final String tabName;
  final IconData iconData;
  final Widget tab;

  TabData({@required this.tab, this.tabName, this.iconData});
}
