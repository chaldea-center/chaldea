import 'package:chaldea/app/app.dart';
import 'package:chaldea/widgets/widgets.dart';

import 'np_damage_calculator.dart';

class BattleHomePage extends StatelessWidget {
  BattleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        toolbarHeight: kToolbarHeight,
        title: const Text('Chaldeas'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('NP Damage'),
            onTap: () {
              router.pushPage(const NpDamageCalculator());
            },
          ),
          ListTile(
            title: const Text('Card Damage'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('NP Gain'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Simulation'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
