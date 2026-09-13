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
    return DefaultTabController(
      length: 4,
      initialIndex: option == null ? 0 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.current.bond_bonus),
          bottom: FixedHeight.tabBar(
            TabBar(
              tabs: [
                Tab(text: S.current.craft_essence),
                Tab(text: S.current.servant),
                Tab(text: S.current.team),
                Tab(text: S.current.bond_solver),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            KeepAliveBuilder(builder: (_) => EquipBondBonusTab()),
            KeepAliveBuilder(builder: (_) => ServantBondCETableTab()),
            KeepAliveBuilder(builder: (_) => FormationBondTab(option: option)),
            KeepAliveBuilder(builder: (_) => const BondSolverTab()),
          ],
        ),
      ),
    );
  }
}
