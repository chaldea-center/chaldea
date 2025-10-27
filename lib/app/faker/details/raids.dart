import 'package:chaldea/app/modules/battle/formation/formation_card.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/faker/shared/agent.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../runtime.dart';

class RaidsPage extends StatefulWidget {
  final int eventId;
  final FakerRuntime runtime;
  const RaidsPage({super.key, required this.runtime, required this.eventId});

  @override
  State<RaidsPage> createState() => _RaidsPageState();
}

class _RaidsPageState extends State<RaidsPage> with SingleTickerProviderStateMixin {
  late final runtime = widget.runtime;

  @override
  Widget build(BuildContext context) {
    final raids = runtime.agent.data.raidRecords[widget.eventId]?.values.toList() ?? [];
    raids.sort2((e) => e.eventRaid?.day ?? 0);

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
      body: ListView.separated(
        itemBuilder: (context, index) => buildRaid(raids[index]),
        itemCount: raids.length,
        separatorBuilder: (context, index) => const Divider(height: 16, indent: 16, endIndent: 16),
      ),
    );
  }

  Widget buildRaid(EventRaidInfoRecord raid) {
    final mstRaid = raid.eventRaid;
    final record = raid.history.lastOrNull;
    String _fmt(int? v) => v?.format(compact: false, groupSeparator: ',') ?? v.toString();
    String _time(int v) => v.sec2date().toCustomString(year: false, second: false);

    return TileGroup(
      header: 'Day ${mstRaid?.day} ${mstRaid?.name ?? ""}',
      children: [
        ListTile(
          dense: true,
          title: Text('${S.current.progress} ${_fmt(record?.raidInfo.totalDamage)}/${_fmt(record?.raidInfo.maxHp)}'),
          trailing: record == null ? null : Text(record.raidInfo.rate.format(percent: true)),
          subtitle: record == null
              ? null
              : BondProgress(value: record.raidInfo.totalDamage, total: record.raidInfo.maxHp, minHeight: 4),
        ),
        if (mstRaid != null) ...[
          ListTile(
            dense: true,
            title: Text('Start ~ End'),
            trailing: Text([mstRaid.startedAt, mstRaid.endedAt].map(_time).join(' ~ ')),
          ),
          for (final (name, value) in [
            ('timeLimitAt', mstRaid.timeLimitAt),
            ('defeatBaseAt', mstRaid.defeatBaseAt),
            ('defeatNormaAt', mstRaid.defeatNormaAt),
            ('correctStartTime', mstRaid.correctStartTime),
          ])
            if (value != 0) ListTile(dense: true, title: Text(name), trailing: Text(_time(value))),
        ],
      ],
    );
  }
}
