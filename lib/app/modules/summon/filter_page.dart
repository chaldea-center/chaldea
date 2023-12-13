import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/raw.dart';
import 'package:chaldea/models/models.dart';
import '../common/filter_group.dart';

class SummonFilterPage extends FilterPage<SummonFilterData> {
  final bool isRawGacha;
  const SummonFilterPage({
    super.key,
    required super.filterData,
    required this.isRawGacha,
    super.onChanged,
  });

  @override
  _CmdCodeFilterPageState createState() => _CmdCodeFilterPageState();
}

class _CmdCodeFilterPageState extends FilterPageState<SummonFilterData, SummonFilterPage> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaler: const TextScaler.linear(0.8)),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        SwitchListTile.adaptive(
          value: filterData.showBanner,
          title: Text(S.current.summon_show_banner),
          onChanged: (v) {
            filterData.showBanner = v;
            update();
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        SwitchListTile.adaptive(
          value: filterData.showOutdated,
          title: Text(S.current.show_outdated),
          onChanged: (v) {
            filterData.showOutdated = v;
            update();
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        widget.isRawGacha
            ? FilterGroup<GachaType>(
                title: Text(S.current.filter_category),
                options: const [GachaType.freeGacha, GachaType.payGacha, GachaType.chargeStone],
                values: filterData.gachaType,
                optionBuilder: (v) => Text(v.shownName),
                onFilterChanged: (value, _) {
                  update();
                },
              )
            : FilterGroup<SummonType>(
                title: Text(S.current.filter_category),
                options: List.of(SummonType.values),
                values: filterData.category,
                optionBuilder: (v) => Text(Transl.enums(v, (enums) => enums.summonType).l),
                onFilterChanged: (value, _) {
                  update();
                },
              ),
        FilterGroup<bool>(
          title: Text('${S.current.sort_order} (${S.current.time})'),
          options: const [false, true],
          values: FilterRadioData.nonnull(filterData.sortByClosed),
          optionBuilder: (v) => Text(v ? S.current.time_close : S.current.time_start),
          onFilterChanged: (value, _) {
            filterData.sortByClosed = value.radioValue!;
            update();
          },
        ),
      ]),
    );
  }
}
