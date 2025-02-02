import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/widgets/widgets.dart';

class AprilFoolSvtFilterData with FilterDataMixin {
  bool useGrid = false;
  final rarity = FilterGroupData<int?>();
  final classType = FilterGroupData<SvtClass>();

  @override
  List<FilterGroupData> get groups => [rarity, classType];
}

class AprilFoolSvtFilterPage extends FilterPage<AprilFoolSvtFilterData> {
  const AprilFoolSvtFilterPage({
    super.key,
    required super.filterData,
    super.onChanged,
  });

  @override
  _AprilFoolSvtFilterPageState createState() => _AprilFoolSvtFilterPageState();
}

class _AprilFoolSvtFilterPageState extends FilterPageState<AprilFoolSvtFilterData, AprilFoolSvtFilterPage> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaler: const TextScaler.linear(0.8)),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        getGroup(header: S.current.filter_sort, children: [
          FilterGroup.display(
            useGrid: filterData.useGrid,
            onChanged: (v) {
              if (v != null) filterData.useGrid = v;
              update();
            },
          ),
        ]),
        buildClassFilter(filterData.classType, showUnknown: true, onChanged: update),
        FilterGroup<int?>(
          title: Text(S.current.rarity),
          options: const [1, 2, 3, 4, 5, null],
          values: filterData.rarity,
          optionBuilder: (v) => Text(v == null ? S.current.unknown : '$v$kStarChar'),
          onFilterChanged: (value, _) {
            update();
          },
        ),
      ]),
    );
  }
}
