import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/datatypes/effect_type/effect_type.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

class BuffFuncFilterData {
  FilterGroupData display;
  FilterGroupData effectScope;
  FilterGroupData funcType;
  FilterGroupData buffType;

  BuffFuncFilterData({
    FilterGroupData? display,
    FilterGroupData? effectScope,
    FilterGroupData? funcType,
    FilterGroupData? buffType,
  })  : display = display ?? FilterGroupData(options: {'List': true}),
        effectScope = effectScope ?? FilterGroupData(),
        funcType = funcType ?? FilterGroupData(),
        buffType = buffType ?? FilterGroupData();

  bool get useGrid => display.isRadioVal('Grid');

  void reset() {
    effectScope.reset();
    funcType.reset();
    buffType.reset();
  }
}

class BuffFuncFilter extends FilterPage<BuffFuncFilterData> {
  const BuffFuncFilter({
    Key? key,
    required BuffFuncFilterData filterData,
    ValueChanged<BuffFuncFilterData>? onChanged,
  }) : super(key: key, onChanged: onChanged, filterData: filterData);

  @override
  _BuffFuncFilterState createState() => _BuffFuncFilterState();
}

class _BuffFuncFilterState extends FilterPageState<BuffFuncFilterData> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.of(context).filter),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        getGroup(header: S.of(context).filter_sort, children: [
          FilterGroup(
            useRadio: true,
            padding: const EdgeInsets.only(right: 12),
            options: const ['List', 'Grid'],
            values: filterData.display,
            combined: true,
            onFilterChanged: (v) {
              filterData.display = v;
              update();
            },
          ),
        ]),
        FilterGroup(
          title: Text(LocalizedText.of(
              chs: '效果范围(从者)',
              jpn: '効果の範囲(サーヴァント)',
              eng: 'Scope of Effects(Servant)')),
          options: SvtFilterData.buffScope,
          values: filterData.effectScope,
          optionBuilder: (v) => Text([
            S.current.active_skill,
            S.current.noble_phantasm,
            S.current.passive_skill
          ][int.parse(v)]),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup(
          options: FuncType.all.keys.toList(),
          values: filterData.funcType,
          optionBuilder: (s) => Text(FuncType.all[s]!.shownName),
          title: const Text('FuncType'),
          showMatchAll: true,
          showInvert: true,
          showCollapse: true,
          onFilterChanged: (v) {
            filterData.funcType = v;
            update();
          },
        ),
        FilterGroup(
          options: BuffType.all.keys.toList(),
          values: filterData.buffType,
          optionBuilder: (s) => Text(BuffType.all[s]!.shownName),
          title: const Text('BuffType'),
          showMatchAll: true,
          showInvert: true,
          showCollapse: true,
          onFilterChanged: (v) {
            filterData.buffType = v;
            update();
          },
        ), //end
      ]),
    );
  }
}
