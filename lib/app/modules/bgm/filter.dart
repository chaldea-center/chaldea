import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../models/models.dart';
import '../common/filter_group.dart';
import '../common/filter_page_base.dart';

class BgmFilterData {
  bool reversed = false;
  final favorite = FilterGroupData<bool>();
  final sortByPriority = FilterRadioData<bool>.nonnull(true);
  final released = FilterRadioData<bool>();
  final needItem = FilterRadioData<bool>();

  void reset() {
    reversed = false;
    favorite.reset();
    sortByPriority.reset();
    released.reset();
    needItem.reset();
  }
}

class BgmFilterPage extends FilterPage<BgmFilterData> {
  const BgmFilterPage({
    super.key,
    required super.filterData,
    super.onChanged,
  });

  @override
  _NpChargeFilterPageState createState() => _NpChargeFilterPageState();
}

class _NpChargeFilterPageState
    extends FilterPageState<BgmFilterData, BgmFilterPage> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        FilterGroup<bool>(
          title: Text(S.current.filter_sort, style: textStyle),
          options: const [true, false],
          values: filterData.sortByPriority,
          optionBuilder: (v) => Text(v ? 'Priority' : 'ID'),
          combined: true,
          onFilterChanged: (v, _) {
            update();
          },
        ),
        FilterGroup<bool>(
          title: Text('Released (My Room)', style: textStyle),
          options: const [true, false],
          values: filterData.released,
          combined: true,
          optionBuilder: (v) => Text(v ? 'Released' : 'Not Released'),
          onFilterChanged: (v, _) {
            update();
          },
        ),
        FilterGroup<bool>(
          title: const Text('Buyable'),
          options: const [true, false],
          values: filterData.needItem,
          combined: true,
          optionBuilder: (v) => Text(v ? 'Buyable' : 'Free/Unavailable'),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<bool>(
          title: Text(S.current.favorite),
          options: const [true, false],
          values: filterData.favorite,
          combined: true,
          optionBuilder: (v) =>
              Text(v ? S.current.favorite : S.current.general_others),
          onFilterChanged: (value, _) {
            update();
          },
        ),
      ]),
    );
  }
}
