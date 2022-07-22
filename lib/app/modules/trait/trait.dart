import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'tabs/buff_tab.dart';
import 'tabs/enemy_tab.dart';
import 'tabs/func_tab.dart';
import 'tabs/sp_dmg.dart';
import 'tabs/svt_tab.dart';

class TraitDetailPage extends StatefulWidget {
  final int id;
  const TraitDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  State<TraitDetailPage> createState() => _TraitDetailPageState();
}

class _TraitDetailPageState extends State<TraitDetailPage>
    with SingleTickerProviderStateMixin {
  int get id => widget.id;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String name = Transl.trait(id).l;
    String title = '${S.current.info_trait} $id';
    if (name != id.toString()) {
      title += ' - $name';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          overflow: TextOverflow.fade,
        ),
        bottom: FixedHeight.tabBar(
            TabBar(isScrollable: true, controller: _tabController, tabs: [
          Tab(text: S.current.servant),
          Tab(text: S.current.enemy),
          Tab(text: S.current.super_effective_damage),
          const Tab(text: "Func"),
          const Tab(text: "Buff"),
        ])),
      ),
      body: ListTileTheme(
        data: const ListTileThemeData(horizontalTitleGap: 8),
        child: TabBarView(
          controller: _tabController,
          children: [
            TraitServantTab(id),
            TraitEnemyTab(id),
            TraitSPDMGTab(id),
            TraitFuncTab(id),
            TraitBuffTab(id),
          ],
        ),
      ),
    );
  }
}
