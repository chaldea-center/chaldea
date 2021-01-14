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
  final tabNames = ['限时活动', '主线记录', '素材交换券'];
  TabController _tabController;
  bool reverse = true;

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
        leading: SplitMasterBackButton(),
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
        // physics: NeverScrollableScrollPhysics(),
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
