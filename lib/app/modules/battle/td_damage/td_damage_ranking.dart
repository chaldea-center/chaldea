import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/userdata/local_settings.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../servant/filter.dart';
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

  late final TabController _tabController;
  final svtFilterData = SvtFilterData();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pages = [
          TdDmgOptionsTab(
            options: solver.options,
            onStart: () async {
              EasyLoading.show();
              await solver.calculate();
              EasyLoading.dismiss();
              if (mounted) {
                setState(() {
                  _tabController.index = 1;
                });
              }
            },
          ),
          TdDmgRankingTab(
            options: solver.options,
            results: solver.results,
            errors: solver.errors,
            svtFilterData: svtFilterData,
          ),
        ];

        final useTabView = constraints.maxWidth < 600;
        Widget body;
        if (useTabView) {
          body = TabBarView(
            controller: _tabController,
            children: [
              for (final page in pages) KeepAliveBuilder(builder: (_) => page),
            ],
          );
        } else {
          body = Row(
            children: divideList(
              [for (final page in pages) Expanded(child: page)],
              kVerticalDivider,
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(S.current.np_damage),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_alt),
                tooltip: S.current.filter,
                onPressed: () => FilterPage.show(
                  context: context,
                  builder: (context) => ServantFilterPage(
                    filterData: svtFilterData,
                    onChanged: (_) {
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    planMode: false,
                    showSort: false,
                  ),
                ),
              ),
            ],
            bottom: useTabView
                ? FixedHeight.tabBar(TabBar(
                    controller: _tabController,
                    tabs: const [Tab(text: 'Options'), Tab(text: 'Ranking')],
                  ))
                : null,
          ),
          body: body,
        );
      },
    );
  }
}
