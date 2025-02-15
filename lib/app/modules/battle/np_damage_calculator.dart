import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/widgets/widgets.dart';

class NpDamageCalculator extends StatelessWidget {
  const NpDamageCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const AutoSizeText('NP Damage Calculator', maxLines: 1),
        centerTitle: false,
      ),
      body: const Center(child: Column(children: [])),
    );
  }
}
