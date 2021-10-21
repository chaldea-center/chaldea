import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

class SummonFilterPage extends FilterPage<SummonFilterData> {
  const SummonFilterPage({
    Key? key,
    required SummonFilterData filterData,
    ValueChanged<SummonFilterData>? onChanged,
  }) : super(key: key, onChanged: onChanged, filterData: filterData);

  @override
  _CmdCodeFilterPageState createState() => _CmdCodeFilterPageState();
}

class _CmdCodeFilterPageState extends FilterPageState<SummonFilterData> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        SwitchListTile.adaptive(
          value: filterData.showBanner,
          title: Text(
            LocalizedText.of(chs: '显示封面', jpn: '画像を表示', eng: 'Show Banner'),
            style: const TextStyle(fontSize: 16),
          ),
          onChanged: (v) {
            filterData.showBanner = v;
            update();
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        SwitchListTile.adaptive(
          value: filterData.showOutdated,
          title: Text(
            S.current.show_outdated,
            style: const TextStyle(fontSize: 16),
          ),
          onChanged: (v) {
            filterData.showOutdated = v;
            update();
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        FilterGroup(
          title: Text(S.of(context).filter_category),
          options: SummonFilterData.categoryData,
          values: filterData.category,
          optionBuilder: (v) {
            switch (v) {
              case '0':
                return Text(
                    LocalizedText.of(chs: '剧情', jpn: 'ストーリー', eng: 'Story'));
              case '1':
                return Text(
                    LocalizedText.of(chs: '普通', jpn: '普通', eng: 'Usual'));
              case '2':
                return Text(S.current.lucky_bag + '(SSR)');
              case '3':
                return Text(S.current.lucky_bag + '(SSR+SR)');
              default:
                return Text(v);
            }
          },
          onFilterChanged: (value) {
            // filterData.category = value;
            update();
          },
        ),
      ]),
    );
  }
}
