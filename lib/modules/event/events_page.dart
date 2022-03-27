import 'package:chaldea/components/components.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'tabs/campaign_event_tab.dart';
import 'tabs/exchange_ticket_tab.dart';
import 'tabs/limit_event_tab.dart';
import 'tabs/main_record_tab.dart';

class EventListPage extends StatefulWidget {
  EventListPage({Key? key}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool reversed = false;
  bool showOutdated = false;
  bool showSpecialRewards = false;

  List<String> get tabNames => [
        S.current.limited_event,
        S.current.main_record,
        S.current.exchange_ticket,
        S.current.campaign_event
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabNames.length, vsync: this);
    db.itemStat.update(lapse: const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.event_title),
        titleSpacing: 0,
        leading: const MasterBackButton(),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                showOutdated = !showOutdated;
              });
            },
            tooltip: 'Outdated',
            icon: Icon(showOutdated ? Icons.timer_off : Icons.timer),
          ),
          IconButton(
            icon: FaIcon(
              reversed
                  ? FontAwesomeIcons.arrowDownWideShort
                  : FontAwesomeIcons.arrowUpWideShort,
              size: 20,
            ),
            tooltip: 'Reversed',
            onPressed: () => setState(() => reversed = !reversed),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(
                  showSpecialRewards
                      ? LocalizedText.of(
                          chs: '隐藏特殊报酬',
                          jpn: '特別報酬を非表示',
                          eng: 'Hide Special Rewards',
                          kor: '스페셜 보상 숨기기')
                      : LocalizedText.of(
                          chs: '显示特殊报酬',
                          jpn: '特別報酬を表示',
                          eng: 'Show Special Rewards',
                          kor: '스페셜 보상 보기'),
                ),
                onTap: () {
                  setState(() {
                    showSpecialRewards = !showSpecialRewards;
                  });
                },
              )
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabNames.map((name) => Tab(text: name)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          KeepAliveBuilder(
            builder: (_) => LimitEventTab(
              reverse: reversed,
              showOutdated: showOutdated,
              showSpecialRewards: showSpecialRewards,
            ),
          ),
          KeepAliveBuilder(
            builder: (_) => MainRecordTab(
              reversed: reversed,
              showOutdated: showOutdated,
              showSpecialRewards: showSpecialRewards,
            ),
          ),
          KeepAliveBuilder(
              builder: (_) => ExchangeTicketTab(
                  reverse: reversed, showOutdated: showOutdated)),
          KeepAliveBuilder(
            builder: (_) => CampaignEventTab(
              reverse: reversed,
              showOutdated: showOutdated,
              showSpecialRewards: showSpecialRewards,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}
