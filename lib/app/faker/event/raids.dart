import 'package:chaldea/app/modules/battle/formation/formation_card.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/faker/shared/agent.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../runtime.dart';

class RaidsPage extends StatefulWidget {
  final int eventId;
  final FakerRuntime runtime;
  final int? day;
  const RaidsPage({super.key, required this.runtime, required this.eventId, this.day});

  @override
  State<RaidsPage> createState() => _RaidsPageState();
}

class _RaidsPageState extends State<RaidsPage> with SingleTickerProviderStateMixin {
  late final runtime = widget.runtime;

  @override
  Widget build(BuildContext context) {
    final raids = runtime.agentData.raidRecords[widget.eventId]?.values.toList() ?? [];
    // raids.sort2((e) => e.eventRaid?.day ?? 0);
    raids.sortByList((raid) {
      final raidInfo = raid.history.lastOrNull?.raidInfo;
      return <num>[
        widget.day != null && widget.day == raid.eventRaid?.day ? 0 : 1,
        raidInfo == null
            ? -999
            : raidInfo.totalDamage >= raidInfo.maxHp
            ? 2
            : -raidInfo.totalDamage / raidInfo.maxHp,
        raid.eventRaid?.day ?? 0,
      ];
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.event_raid),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: Icon(Icons.replay),
            tooltip: S.current.refresh,
          ),
        ],
      ),
      body: ListView.builder(itemBuilder: (context, index) => buildRaid(raids[index]), itemCount: raids.length),
    );
  }

  Widget buildRaid(EventRaidInfoRecord raid) {
    final mstRaid = raid.eventRaid;
    final totalRaid = raid.totalRaid;
    final record = raid.history.lastOrNull;
    String _fmt(int? v) => v?.format(compact: false, groupSeparator: ',') ?? v.toString();
    String _time(int v) => v.sec2date().toCustomString(year: false, second: false);
    List<(String, String)> extraInfos = [
      if (totalRaid != null && totalRaid.defeatedAt != 0) ('Defeated', _time(totalRaid.defeatedAt)),
      if (mstRaid != null) ('Start ~ End', [mstRaid.startedAt, mstRaid.endedAt].map(_time).join(' ~ ')),
      if (mstRaid != null)
        for (final (name, value) in [
          ('timeLimitAt', mstRaid.timeLimitAt),
          ('defeatBaseAt', mstRaid.defeatBaseAt),
          ('defeatNormaAt', mstRaid.defeatNormaAt),
          ('correctStartTime', mstRaid.correctStartTime),
        ])
          if (value != 0) (name, _time(value)),
    ];

    return TileGroup(
      header: 'Day ${mstRaid?.day}: ${mstRaid?.name ?? ""}',
      children: [
        ListTile(
          dense: true,
          selected: widget.day != null && widget.day == mstRaid?.day,
          title: Text('${S.current.progress} ${_fmt(record?.raidInfo.totalDamage)} / ${_fmt(record?.raidInfo.maxHp)}'),
          trailing: record == null ? null : Text(record.raidInfo.rate.format(percent: true)),
        ),
        if (record != null)
          Padding(
            padding: .symmetric(horizontal: 16),
            child: BondProgress(value: record.raidInfo.totalDamage, total: record.raidInfo.maxHp, minHeight: 4),
          ),
        if (mstRaid != null) ...[
          if (extraInfos.isNotEmpty)
            ListTile(
              dense: true,
              title: Text(extraInfos.map((e) => e.$1).join('\n')),
              trailing: Text(
                extraInfos.map((e) => e.$2).join('\n'),
                textAlign: .end,
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
              ),
            ),
        ],
      ],
    );
  }
}
