import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class DailyBonusTab extends StatefulWidget {
  DailyBonusTab({super.key});

  @override
  State<DailyBonusTab> createState() => DailyBonusTabState();
}

class DailyBonusTabState extends State<DailyBonusTab> {
  DailyBonusData? get _dailyBonusData => db.runtimeData.dailyBonusData;
  bool showDaily = false;
  bool showExtra = true;
  final fromTypeFilter = FilterGroupData<int>();

  @override
  void initState() {
    super.initState();
    if (_dailyBonusData == null) {
      db.runtimeData.loadDailyBonusData().then((v) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<UserPresentBoxEntity>> groups = {};
    final userPresents = _dailyBonusData?.userPresentBox ?? [];
    final startTime = _dailyBonusData?.info.start ?? 0;
    for (final present in userPresents) {
      if (present.createdAt < startTime) continue;
      final t = present.createdAt.sec2date().toUtc().add(const Duration(hours: 9 - 4));
      groups.putIfAbsent(t.toDateString(), () => []).add(present);
    }
    List<String> keys = groups.keys.toList()..sort();
    keys = keys.reversed.toList();

    final fromTypes = <int>{for (final present in userPresents) present.fromType}.toList();
    fromTypes.sort();
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) => buildGroup(context, keys[index], groups[keys[index]]!),
            // separatorBuilder: (context, index) => const Divider(),
            itemCount: keys.length,
          ),
        ),
        kDefaultDivider,
        SafeArea(
          child: OverflowBar(
            alignment: MainAxisAlignment.center,
            children: [
              FilterGroup(
                padding: EdgeInsets.zero,
                combined: true,
                options: fromTypes,
                values: fromTypeFilter,
                optionBuilder: (v) => Text(Transl.enumsInt(v, (e) => e.presentFromType).l),
                onFilterChanged: (v, _) {
                  setState(() {});
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildGroup(BuildContext context, String key, List<UserPresentBoxEntity> presents) {
    return TileGroup(
      header: key,
      children: [
        for (final present in presents)
          if (fromTypeFilter.matchOne(present.fromType))
            buildPresent(
              context: context,
              present: present,
              tileColor: present.fromType <= 2 ? Theme.of(context).disabledColor.withAlpha(26) : null,
            ),
      ],
    );
  }

  static Widget buildPresent({required BuildContext context, required UserPresentBoxEntity present, Color? tileColor}) {
    final flags = present.flags;
    return ListTile(
      dense: true,
      tileColor: tileColor,
      leading: Gift(
        id: 0,
        type: GiftType.fromId(present.giftType),
        objectId: present.objectId,
        num: present.num,
      ).iconBuilder(context: context, width: 32),
      title: Text('${GameCardMixin.anyCardItemName(present.objectId).l} ×${present.num}'),
      subtitle: Text.rich(TextSpan(children: [
        if (flags.isNotEmpty)
          TextSpan(children: [
            ...divideList(
              [
                for (final flag in flags)
                  TextSpan(text: flag.name, style: TextStyle(color: Theme.of(context).colorScheme.error))
              ],
              const TextSpan(text: ' / '),
            ),
            const TextSpan(text: '\n'),
          ]),
        TextSpan(text: present.message)
      ])),
    );
  }
}
