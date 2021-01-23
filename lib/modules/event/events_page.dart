import 'package:chaldea/components/components.dart';

import 'tabs/exchange_ticket_tab.dart';
import 'tabs/limit_event_tab.dart';
import 'tabs/main_record_tab.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool reverse = true;

  List<String> get tabNames => [
        S.current.limited_event,
        S.current.main_record,
        S.current.exchange_ticket
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabNames.length, vsync: this);
    db.itemStat.update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).event_title),
        leading: MasterBackButton(),
        actions: <Widget>[
          IconButton(
              icon: Icon(reverse
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down),
              onPressed: () => setState(() => reverse = !reverse))
        ],
        bottom: TabBar(
            controller: _tabController,
            isScrollable: false,
            tabs: tabNames.map((name) => Tab(text: name)).toList()),
      ),
      body: TabBarView(
        controller: _tabController,
        // desktop: direction of drag may be confused
        physics: AppInfo.isMobile ? null : NeverScrollableScrollPhysics(),
        children: <Widget>[
          KeepAliveBuilder(builder: (_) => LimitEventTab(reverse: reverse)),
          KeepAliveBuilder(builder: (_) => MainRecordTab(reverse: reverse)),
          KeepAliveBuilder(builder: (_) => ExchangeTicketTab(reverse: reverse)),
        ],
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    db.saveUserData();
  }
}
