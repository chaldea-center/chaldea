import 'package:flutter/foundation.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/userdata/battle.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'bond_solver.dart';
import 'equip_bond_bonus.dart';
import 'formation_bond.dart';
import 'servant_bond_ce_table.dart';

class BondBonusHomePage extends StatelessWidget {
  final FormationBondOption? option;
  const BondBonusHomePage({super.key, this.option});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (Tab(text: S.current.craft_essence), KeepAliveBuilder(builder: (_) => EquipBondBonusTab())),
      (Tab(text: S.current.servant), KeepAliveBuilder(builder: (_) => ServantBondCETableTab())),
      (Tab(text: S.current.team), KeepAliveBuilder(builder: (_) => FormationBondTab(option: option))),
      if (kDebugMode) (Tab(text: S.current.bond_solver), KeepAliveBuilder(builder: (_) => const BondSolverTab())),
    ];
    return DefaultTabController(
      length: tabs.length,
      initialIndex: option == null ? 0 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.current.bond_bonus),
          bottom: FixedHeight.tabBar(TabBar(tabs: tabs.map((e) => e.$1).toList())),
        ),
        body: TabBarView(children: tabs.map((e) => e.$2).toList()),
      ),
    );
  }
}
