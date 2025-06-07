import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'equip_bond_bonus.dart';
import 'formation_bond.dart';

class BondBonusHomePage extends StatelessWidget {
  final FormationBondOption? option;
  const BondBonusHomePage({super.key, this.option});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: option == null ? 0 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.current.bond_bonus),
          bottom: FixedHeight.tabBar(
            TabBar(
              tabs: [
                Tab(text: S.current.craft_essence),
                Tab(text: S.current.team),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            KeepAliveBuilder(builder: (_) => EquipBondBonusTab()),
            KeepAliveBuilder(builder: (_) => FormationBondTab(option: option)),
          ],
        ),
      ),
    );
  }
}
