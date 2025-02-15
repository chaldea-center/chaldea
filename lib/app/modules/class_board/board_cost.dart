import 'package:chaldea/app/tools/item_center.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class ClassBoardItemCostPage extends StatefulWidget {
  const ClassBoardItemCostPage({super.key});

  @override
  State<ClassBoardItemCostPage> createState() => _ClassBoardItemCostPageState();
}

class _ClassBoardItemCostPageState extends State<ClassBoardItemCostPage> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 3, vsync: this);

  static List<SvtMatCostDetailType> types = [
    SvtMatCostDetailType.full,
    SvtMatCostDetailType.demands,
    SvtMatCostDetailType.consumed,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${S.current.class_board} - ${S.current.statistics_title}'),
        bottom: FixedHeight.tabBar(
          TabBar(
            controller: _tabController,
            tabs: [Tab(text: S.current.general_all), Tab(text: S.current.plan), Tab(text: S.current.consumed)],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [for (final type in types) _ClassBoardCostDetail(type: type)],
      ),
    );
  }
}

class _ClassBoardCostDetail extends StatelessWidget {
  final SvtMatCostDetailType type;
  const _ClassBoardCostDetail({required this.type});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    Map<int, int> totalCosts = {};
    for (final board in db.gameData.classBoards.values) {
      final items = db.itemCenter.calcOneClassBoardCost(board, type);
      totalCosts.addDict(items);
      children.add(buildRow(context, board.btnIcon, items, board.routeTo));
    }
    children.add(buildRow(context, SvtClass.ALL.icon(3), totalCosts, null));
    return ListView.separated(
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (context, index) => kDefaultDivider,
      itemCount: children.length,
    );
  }

  Widget buildRow(BuildContext context, String icon, Map<int, int> items, VoidCallback? onTap) {
    final entries = items.entries.toList();
    entries.sort((a, b) => Item.compare2(a.key, b.key));
    return ListTile(
      leading: db.getIconImage(icon, width: 32, onTap: onTap),
      horizontalTitleGap: 8,
      title: Wrap(
        children: [
          for (final entry in entries)
            Item.iconBuilder(context: context, item: null, itemId: entry.key, text: entry.value.format()),
        ],
      ),
    );
  }
}
