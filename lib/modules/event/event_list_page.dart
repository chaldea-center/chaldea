import 'package:chaldea/components/components.dart';

import 'tabs/limit_event_tab.dart';
import 'tabs/exchange_ticket_tab.dart';
import 'tabs/main_record_tab.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage>
    with SingleTickerProviderStateMixin {
  final tabNames = ['Events', 'Main Records', 'Exchange Tickets'];
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
        leading: SplitViewBackButton(),
        bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: tabNames.map((name) => Tab(text: name)).toList()),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[LimitEventTab(), MainRecordTab(), ExchangeTicketTab()],
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    db.saveData();
  }
}
