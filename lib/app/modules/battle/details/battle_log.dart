import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/userdata/filter_data.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class BattleLogPage extends StatefulWidget {
  final BattleLogger logger;
  const BattleLogPage({super.key, required this.logger});

  @override
  State<BattleLogPage> createState() => _BattleLogPageState();
}

class _BattleLogPageState extends State<BattleLogPage> {
  BattleLogType shownType = BattleLogType.action;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (final log in widget.logger.logs) {
      if (log.type.index < shownType.index) continue;
      Widget icon;
      switch (log.type) {
        case BattleLogType.debug:
          icon = const Icon(Icons.circle, size: 8, color: Colors.green);
          break;
        case BattleLogType.function:
          icon = const Icon(Icons.circle, size: 8, color: Colors.yellow);
          break;
        case BattleLogType.action:
          icon = const Icon(Icons.circle, size: 8, color: Colors.red);
          break;
        case BattleLogType.error:
          icon = Icon(Icons.error_outline, size: 8, color: Colors.red.shade900);
          break;
      }
      children.add(ListTile(
        dense: true,
        title: Text(log.log),
        subtitle: Text(log.type.name),
        horizontalTitleGap: 16,
        minLeadingWidth: 0,
        leading: icon,
      ));
    }

    return Scaffold(
      appBar: AppBar(title: Text(S.current.battle_battle_log)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: divideTiles(children),
            ),
          ),
          kDefaultDivider,
          SafeArea(
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                FilterGroup<BattleLogType>(
                  combined: true,
                  options: BattleLogType.values,
                  values: FilterRadioData.nonnull(shownType),
                  optionBuilder: (value) => Text(value.name.toTitle()),
                  onFilterChanged: (v, _) {
                    shownType = v.radioValue!;
                    if (mounted) setState(() {});
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
