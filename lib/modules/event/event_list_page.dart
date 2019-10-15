import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/event/event_detail_page.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage>
    with SingleTickerProviderStateMixin {
  final tabNames = ['Events', 'Main Records','Exchange Tickets'];
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
        children: <Widget>[
          EventListTab(),
          MainRecordTab(),
          ExchangeTicketTab()
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
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final eventNames = db.gameData.events.keys.toList();
    return ListView.separated(
      itemCount: eventNames.length,
      separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
      itemBuilder: (context, index) {
        final event = db.gameData.events[eventNames[index]];
        final plan =
            db.curPlan.events.putIfAbsent(event.name, () => EventPlan());
        return CustomTile(
          title: AutoSizeText(event.name, maxLines: 1),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (event.hunting != null || event.lottery != null)
                Icon(
                  Icons.star,
                  color: Colors.yellow[700],
                ),
              Switch.adaptive(
                  value: db.curPlan.events[event.name]?.enable ?? false,
                  onChanged: (v) => setState(() {
                        db.curPlan.events
                            .putIfAbsent(event.name, () => EventPlan())
                            .enable = v;
                      }))
            ],
          ),
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

class ExchangeTicketTab extends StatefulWidget {
  @override
  _ExchangeTicketTabState createState() => _ExchangeTicketTabState();
}

class _ExchangeTicketTabState extends State<ExchangeTicketTab> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Exchange Tickets Tab'));
  }
}
