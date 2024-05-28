import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/models/gamedata/daily_bonus.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class DailyBonusTab extends StatefulWidget {
  DailyBonusTab({super.key});

  @override
  State<DailyBonusTab> createState() => _DailyBonusTabState();
}

class _DailyBonusTabState extends State<DailyBonusTab> {
  DailyBonusData? _dailyBonusData;
  bool showDaily = false;
  bool showExtra = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    _dailyBonusData = await CachedApi.cacheManager.getModel(
      HostsX.proxyWorker("https://github.com/chaldea-center/daily-login-data/raw/main/JP_119238492/_stats/data.json"),
      (data) => DailyBonusData.fromJson(data),
    );
    if (mounted) setState(() {});
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
            child: ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            CheckboxWithLabel(
              value: showDaily,
              label: const Text("Daily"),
              onChanged: (v) {
                setState(() {
                  showDaily = v ?? showDaily;
                });
              },
            ),
            CheckboxWithLabel(
              value: showExtra,
              label: const Text("Extra"),
              onChanged: (v) {
                setState(() {
                  showExtra = v ?? showExtra;
                });
              },
            ),
          ],
        ))
      ],
    );
  }

  Widget buildGroup(BuildContext context, String key, List<UserPresentBoxEntity> presents) {
    final List<UserPresentBoxEntity> dailyLogins = [], extraBonus = [];
    for (final present in presents) {
      if (present.fromType == PresentFromType.totalLogin.value || present.fromType == PresentFromType.seqLogin.value) {
        dailyLogins.add(present);
      } else {
        extraBonus.add(present);
      }
    }
    return TileGroup(
      header: key,
      children: [
        if (showDaily)
          for (final present in dailyLogins) buildPresent(present, true),
        if (showExtra)
          for (final present in extraBonus) buildPresent(present, false),
      ],
    );
  }

  Widget buildPresent(UserPresentBoxEntity present, bool isDaily) {
    final flags = present.flags;
    return ListTile(
      dense: true,
      tileColor: isDaily ? Theme.of(context).disabledColor.withOpacity(0.1) : null,
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
