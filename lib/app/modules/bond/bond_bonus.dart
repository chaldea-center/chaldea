import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'equip_bond_bonus.dart';
import 'formation_bond.dart';
import 'servant_bond_ce_table.dart';

class BondBonusHomePage extends StatelessWidget {
  final FormationBondOption? option;
  const BondBonusHomePage({super.key, this.option});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            KeepAliveBuilder(builder: (_) => EquipBondBonusTab()),
            KeepAliveBuilder(builder: (_) => ServantBondCETableTab()),
            KeepAliveBuilder(builder: (_) => FormationBondTab(option: option)),
          ],
        ),
      ),
    );
  }
}
