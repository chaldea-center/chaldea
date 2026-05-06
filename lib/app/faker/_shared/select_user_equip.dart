import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/app/modules/mystic_code/filter.dart';
import 'package:chaldea/app/routes/delegate.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../runtime.dart';

class SelectUserEquipPage extends StatefulWidget {
  final FakerRuntime runtime;
  final int? inUseUserEquipId;
  final ValueChanged<UserEquipEntity>? onSelected;

  const SelectUserEquipPage({super.key, required this.runtime, this.inUseUserEquipId, this.onSelected});

  @override
  State<SelectUserEquipPage> createState() => _SelectUserEquipPageState();
}

class _SelectUserEquipPageState extends State<SelectUserEquipPage> {
  late final runtime = widget.runtime;
  late final mstData = runtime.mstData;

  static final _svtFilters = RouterValues(() => MysticCodeFilterData(ascending: false));

  late final filterData = _svtFilters.of(context);
  final maxLeveledFilter = FilterRadioData<bool>();

  @override
  void initState() {
    super.initState();
  }

  bool filter(UserEquipEntity userEquip) {
    final equip = db.gameData.mysticCodes[userEquip.equipId];
    if (equip == null) return false;
    if (!maxLeveledFilter.matchOne(userEquip.lv >= 10)) return false;
    if (!filterData.filter(equip)) return false;
    return true;
  }

  int compareUserEquip(UserEquipEntity a, UserEquipEntity b) {
    return ListX.compareByList(
      a,
      b,
      (v) => <int>[widget.inUseUserEquipId == v.id ? 0 : 1, filterData.ascending ? v.equipId : -v.equipId],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userEquips = mstData.userEquip.where(filter).toList();
    userEquips.sort(compareUserEquip);
    return Scaffold(
      appBar: AppBar(
        title: Text('Select User CE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => MysticCodeFilterPage(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (context, index) {
                final userEquip = userEquips[index];
                final equip = db.gameData.mysticCodes[userEquip.equipId];
                final nextLvExp = equip?.expRequired.getOrNull(userEquip.lv - 1);
                return ListTile(
                  selected: widget.inUseUserEquipId == userEquip.id,
                  leading: equip?.iconBuilder(context: context, width: 32) ?? const SizedBox(width: 32),
                  title: Text(equip?.lName.l ?? 'No.${userEquip.equipId}'),
                  subtitle: equip == null ? null : Text('No.${userEquip.equipId}'),
                  trailing: Column(
                    crossAxisAlignment: .end,
                    mainAxisSize: .min,
                    children: [
                      Text('Lv.${userEquip.lv}'),
                      if (nextLvExp != null)
                        Text(
                          '-${(nextLvExp - userEquip.exp).formatSep()}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onSelected?.call(userEquip);
                  },
                  onLongPress: () {
                    router.push(url: Routes.mysticCodeI(userEquip.equipId));
                  },
                );
              },
              itemCount: userEquips.length,
            ),
          ),
          kDefaultDivider,
          SafeArea(child: buttonBar),
        ],
      ),
    );
  }

  Widget get buttonBar {
    return Wrap(
      alignment: .center,
      children: [
        FilterGroup<bool>(
          options: const [false, true],
          values: maxLeveledFilter,
          combined: true,
          padding: .zero,
          optionBuilder: (value) => Text(value ? '=Lv10' : '<Lv10'),
          onFilterChanged: (v, _) {
            if (mounted) setState(() {});
          },
        ),
      ],
    );
  }
}
