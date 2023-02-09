import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class WarsPage extends StatefulWidget {
  const WarsPage({super.key});

  @override
  State<WarsPage> createState() => _WarsPageState();
}

class _WarsPageState extends State<WarsPage>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 3, vsync: this);
  bool reversed = true;

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<NiceWar> mainStories = [], chaldeaGates = [], eventWars = [];
    for (final war in db.gameData.wars.values) {
      if (war.isMainStory) {
        mainStories.add(war);
        continue;
      }
      if (war.eventId != 0) {
        eventWars.add(war);
        continue;
      }
      chaldeaGates.add(war);
    }
    return Scaffold(
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: Text(S.current.war),
        actions: [
          IconButton(
            icon: FaIcon(
              reversed
                  ? FontAwesomeIcons.arrowDownWideShort
                  : FontAwesomeIcons.arrowUpWideShort,
              size: 20,
            ),
            tooltip: S.current.sort_order,
            onPressed: () {
              setState(() {
                reversed = !reversed;
              });
            },
          ),
        ],
        bottom: FixedHeight.tabBar(TabBar(
          isScrollable: true,
          controller: _tabController,
          tabs: [
            Tab(text: S.current.main_story),
            Tab(text: S.current.chaldea_gate),
            Tab(text: S.current.event),
          ],
        )),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          WarListPage(wars: mainStories, reversed: reversed),
          WarListPage(wars: chaldeaGates, reversed: reversed),
          WarListPage(wars: eventWars, reversed: reversed),
        ],
      ),
    );
  }
}

class WarListPage extends StatelessWidget {
  final List<NiceWar> wars;
  final bool reversed;
  const WarListPage({super.key, required this.wars, this.reversed = true});

  @override
  Widget build(BuildContext context) {
    final wars = this.wars.toList();
    wars.sort2((e) => e.priority, reversed: reversed);
    return ListView.builder(
      itemBuilder: (context, index) {
        final war = wars[index];
        return ListTile(
          leading: war.shownBanner == null
              ? null
              : db.getIconImage(war.shownBanner, width: 150),
          title: AutoSizeText(
            war.lLongName.l.setMaxLines(2),
            maxLines: 2,
            minFontSize: 12,
            maxFontSize: 16,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: 0.9,
          ),
          horizontalTitleGap: 8,
          onTap: () {
            war.routeTo(popDetails: true);
          },
        );
      },
      itemCount: wars.length,
    );
  }
}
