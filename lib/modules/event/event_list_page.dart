import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/event/event_detail_page.dart';
import 'package:flutter/cupertino.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage>
    with SingleTickerProviderStateMixin {
  final tabNames = ['Events', 'Main Records'];
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabNames.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        leading: BackButton(),
        bottom: TabBar(
            controller: _tabController,
            tabs: tabNames.map((name) => Tab(text: name)).toList()),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          EventListTab(),
          MainRecordTab(),
        ],
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    db.saveData();
  }
}

class EventListTab extends StatefulWidget {
  @override
  _EventListTabState createState() => _EventListTabState();
}

class _EventListTabState extends State<EventListTab>
    with AutomaticKeepAliveClientMixin {
  Map<String, bool> eventConfig = {};

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final eventNames = db.gameData.events.keys.toList();
    return ListView.separated(
      itemCount: eventNames.length,
      separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
      itemBuilder: (context, index) {
        final event = db.gameData.events[eventNames[index]];
        return CustomTile(
          title: AutoSizeText(event.name, maxLines: 1),
          trailing: CupertinoSwitch(
              value: eventConfig[event.name] ?? false,
              onChanged: (v) => setState(() => eventConfig[event.name] = v)),
          onTap: () {
            SplitRoute.popAndPush(context,
                builder: (context) => EventDetailPage(name: event.name));
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MainRecordTab extends StatefulWidget {
  @override
  _MainRecordTabState createState() => _MainRecordTabState();
}

class _MainRecordTabState extends State<MainRecordTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Text('TODO: Main Records'),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
