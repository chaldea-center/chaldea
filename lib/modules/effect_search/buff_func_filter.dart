import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/datatypes/effect_type/effect_type.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

class BuffFuncFilterData {
  FilterGroupData display;
  FilterGroupData effectScope;
  FilterGroupData funcBuff;

  BuffFuncFilterData({
    FilterGroupData? display,
    FilterGroupData? effectScope,
    FilterGroupData? funcBuff,
  })  : display = display ?? FilterGroupData(options: {'List': true}),
        effectScope = effectScope ?? FilterGroupData(),
        funcBuff = funcBuff ?? FilterGroupData();

  bool get useGrid => display.isRadioVal('Grid');

  void reset() {
    effectScope.reset();
    funcBuff.reset();
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
        const Divider(height: 16),
        FilterGroup(
          options: const [],
          values: filterData.funcBuff,
          title: const Text('FuncType & BuffType'),
          showMatchAll: true,
          showInvert: true,
          onFilterChanged: (v) {
            update();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            LocalizedText.of(
                chs: '组合筛选', jpn: '組み合わせフィルター', eng: 'Combined filter'),
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        FilterGroup(
          options: FuncTypes.withoutAddState.keys.toList(),
          values: filterData.funcBuff,
          optionBuilder: (s) => Text(FuncTypes.all[s]!.shownName),
          title: const Text('FuncType'),
          showCollapse: true,
          onFilterChanged: (v) {
            update();
          },
        ),
        FilterGroup(
          options: BuffType.all.keys.toList(),
          values: filterData.funcBuff,
          optionBuilder: (s) => Text(BuffType.all[s]!.shownName),
          title: const Text('BuffType'),
          showCollapse: true,
          onFilterChanged: (v) {
            update();
          },
        ), //end
      ]),
    );
  }
}
