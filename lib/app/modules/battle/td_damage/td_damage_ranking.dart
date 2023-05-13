import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'model.dart';
import 'options_tab.dart';
import 'ranking_tab.dart';

class TdDamageRanking extends StatefulWidget {
  const TdDamageRanking({super.key});

  @override
  State<TdDamageRanking> createState() => _TdDamageRankingState();
}

class _TdDamageRankingState extends State<TdDamageRanking> with SingleTickerProviderStateMixin {
  static TdDmgSolver solver = TdDmgSolver();

  late final _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.np_damage),
        bottom: FixedHeight.tabBar(TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Options'), Tab(text: 'Ranking')],
        )),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TdDmgOptionsTab(
            options: solver.options,
            onStart: () async {
              EasyLoading.show();
              await solver.calculate();
              EasyLoading.dismiss();
              if (mounted) {
                _tabController.index = 1;
              }
            },
          ),
          TdDmgRankingTab(options: solver.options, results: solver.results, errors: solver.errors),
        ],
      ),
    );
  }
}
