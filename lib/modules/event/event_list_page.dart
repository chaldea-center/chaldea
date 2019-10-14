import 'package:chaldea/components/components.dart';

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
          Center(child: Text('Event list')),
          Center(child: Text('Main Record list')),
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
