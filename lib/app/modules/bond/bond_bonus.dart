import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';

import 'equip_bond_bonus.dart';
import 'servant_bond_ce_table.dart';

class BondBonusHomePage extends StatelessWidget {
  final List<Servant> svts;
  final int initialIndex;

  const BondBonusHomePage({super.key, this.svts = const [], this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (Tab(text: S.current.craft_essence), KeepAliveBuilder(builder: (_) => EquipBondBonusTab(targetSvts: svts))),
      (Tab(text: S.current.servant), KeepAliveBuilder(builder: (_) => ServantBondCETableTab(initialSvts: svts))),
    ];
    return DefaultTabController(
      length: tabs.length,
      initialIndex: initialIndex,
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
