import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import './april_fool_page.dart';
import 'filter.dart';

class AprilFoolSvtListPage extends StatefulWidget {
  final List<AprilFoolSvtData> servants;
  final ValueChanged<AprilFoolSvtData> onSelected;

  AprilFoolSvtListPage({super.key, required this.servants, required this.onSelected});

  @override
  State<StatefulWidget> createState() => AprilFoolSvtListPageState();
}

class AprilFoolSvtListPageState extends State<AprilFoolSvtListPage>
    with SearchableListState<AprilFoolSvtData, AprilFoolSvtListPage> {
  @override
  Iterable<AprilFoolSvtData> get wholeData => widget.servants;

  static AprilFoolSvtFilterData filterData = AprilFoolSvtFilterData();

  @override
  final bool prototypeExtent = true;

  @override
  String get scrollRestorationId => 'af_svt_list';

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: (a, b) => b.id - a.id);
    return scrollListener(
      useGrid: filterData.useGrid,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: Text('[${S.current.april_fool}] ${S.current.servant}', maxLines: 1),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => AprilFoolSvtFilterPage(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ),
          ),
          searchIcon,
        ],
      ),
    );
  }

  @override
  Widget listItemBuilder(AprilFoolSvtData svt) {
    return ListTile(
      leading: db.getIconImage(svt.icon, width: 40),
      title: Text(svt.name),
      subtitle: Text('No.${svt.id}'),
      trailing: svt.svt?.iconBuilder(context: context, width: 40),
      onTap: () => _onTap(svt),
    );
  }

  @override
  Widget gridItemBuilder(AprilFoolSvtData svt) {
    return db.getIconImage(
      svt.icon,
      width: 72,
      onTap: () => _onTap(svt),
    );
  }

  void _onTap(AprilFoolSvtData svt) {
    Navigator.pop(context);
    widget.onSelected.call(svt);
  }

  @override
  bool filter(AprilFoolSvtData svtData) {
    final svt = svtData.svt;
    if (svt != null && !filterData.rarity.matchOne(svt.rarity)) {
      return false;
    }
    if (!filterData.classType.matchOne(svt?.className ?? SvtClass.unknown)) {
      return false;
    }
    return true;
  }

  @override
  Iterable<String?> getSummary(AprilFoolSvtData svtData) sync* {
    yield svtData.id.toString();
    final svt = svtData.svt;
    if (svt != null) {
      yield* SearchUtil.getAllKeys(Transl.svtNames(svt.name));
    }
  }
}
