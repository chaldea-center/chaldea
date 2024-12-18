import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';

class UserPresentBoxFilterPage extends FilterPage<PresentBoxFilterData> {
  const UserPresentBoxFilterPage({
    super.key,
    required super.filterData,
    super.onChanged,
  });

  @override
  _ShopFilterState createState() => _ShopFilterState();
}

class _ShopFilterState extends FilterPageState<PresentBoxFilterData, UserPresentBoxFilterPage> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaler: const TextScaler.linear(0.8)),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(restorationId: 'present_box_filter', children: [
        FilterGroup<PresentType>(
          title: Text(S.current.general_type),
          options: PresentType.values,
          values: filterData.presentType,
          optionBuilder: (v) => Text(v.shownName),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<int>(
          title: Text(S.current.rarity),
          options: const [1, 2, 3, 4, 5],
          values: filterData.rarity,
          onFilterChanged: (value, _) {
            update();
          },
        ),
        ListTile(
          dense: true,
          title: Text('Max num'),
          trailing: TextButton(
            onPressed: () {
              InputCancelOkDialog(
                title: 'Max num',
                keyboardType: TextInputType.number,
                validate: (s) => s.isEmpty || (int.tryParse(s) ?? -1) >= 0,
                onSubmit: (s) {
                  if (s.trim().isEmpty) {
                    filterData.maxNum = 0;
                  } else {
                    filterData.maxNum = int.parse(s);
                  }
                  update();
                },
              ).showDialog(context);
            },
            child: Text(filterData.maxNum.toString()),
          ),
        )
      ]),
    );
  }
}

class PresentBoxFilterData with FilterDataMixin {
  bool reversed = false;
  bool showSelectedOnly = false;

  int maxNum = 0;
  final presentType = FilterGroupData<PresentType>();
  final rarity = FilterGroupData<int>();

  @override
  List<FilterGroupData> get groups => [presentType, rarity];

  @override
  void reset() {
    super.reset();
    maxNum = 0;
  }
}

enum PresentType {
  servant,
  servantExp,
  statusUp,
  svtEquip,
  svtEquipExp,
  commandCode,
  fruit,
  summonTicket,
  itemSelect,
  stone,
  manaPrism,
  eventItem,
  others,
  ;

  String get shownName {
    return switch (this) {
          PresentType.servant => S.current.servant,
          PresentType.servantExp => '${S.current.servant}(EXP)',
          PresentType.statusUp => S.current.foukun,
          PresentType.svtEquip => S.current.craft_essence,
          PresentType.svtEquipExp => '${S.current.craft_essence}(EXP)',
          PresentType.commandCode => S.current.command_code,
          PresentType.fruit => S.current.item_apple,
          PresentType.summonTicket => Items.summonTicket?.lName.l,
          PresentType.itemSelect => S.current.exchange_ticket,
          PresentType.stone => Items.stone?.lName.l,
          PresentType.manaPrism => Items.manaPrism?.lName.l,
          PresentType.eventItem => Transl.enums(ItemCategory.event, (e) => e.itemCategory).l,
          PresentType.others => S.current.general_others,
        } ??
        name;
  }
}
