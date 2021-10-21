import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

class EnemyFilterData {
  FilterGroupData display;
  FilterGroupData attribute;
  FilterGroupData traits;

  bool get useGrid => display.isRadioVal('Grid');

  EnemyFilterData({
    FilterGroupData? display,
    FilterGroupData? attribute,
    FilterGroupData? traits,
  })  : display = display ?? FilterGroupData(options: {'List': true}),
        attribute = attribute ?? FilterGroupData(),
        traits = traits ?? FilterGroupData();

  List<FilterGroupData> get groupValues => [attribute, traits];

  void reset() {
    for (var group in groupValues) {
      group.reset();
    }
  }

  static const List<String> attributeData = SvtFilterData.attributeData;
  static const List<String> traitData = [
    //
    '人型', '人类', '女性', '男性', '恶', '魔性', '神性',
    '猛兽', '龙', '野兽', '恶魔', '死灵', '鬼',
    '王', '超巨大', '机械', '希腊神话系男性', '巨人', '罗马', '妖精', '人类的威胁',
  ];
// static const List<String> categoryData = ['0', '1', '2', '3'];
}

class EnemyFilterPage extends FilterPage<EnemyFilterData> {
  const EnemyFilterPage({
    Key? key,
    required EnemyFilterData filterData,
    ValueChanged<EnemyFilterData>? onChanged,
  }) : super(key: key, onChanged: onChanged, filterData: filterData);

  @override
  _EnemyFilterPageState createState() => _EnemyFilterPageState();
}

class _EnemyFilterPageState extends FilterPageState<EnemyFilterData> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        getGroup(header: S.current.filter_shown_type, children: [
          FilterGroup(
            useRadio: true,
            padding: const EdgeInsets.only(right: 12),
            options: const ['List', 'Grid'],
            values: filterData.display,
            combined: true,
            onFilterChanged: (v) {
              update();
            },
          ),
        ]),
        FilterGroup(
          title: Text(S.current.filter_attribute),
          options: EnemyFilterData.attributeData,
          values: filterData.attribute,
          optionBuilder: (v) => Text(Localized.svtFilter.of(v)),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup(
          title: Text(S.current.info_trait),
          options: EnemyFilterData.traitData,
          values: filterData.traits,
          showMatchAll: true,
          showInvert: true,
          optionBuilder: (v) => Text(Localized.svtFilter.of(v)),
          onFilterChanged: (value) {
            update();
          },
        ),
      ]),
    );
  }
}
