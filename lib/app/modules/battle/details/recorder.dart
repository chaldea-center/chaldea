import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/widgets/widgets.dart';

class BattleRecorderPanel extends StatelessWidget {
  final BattleRecordManager recorder;
  const BattleRecorderPanel({super.key, required this.recorder});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final record in recorder.records) Text(record.toString()),
      ],
    );
  }
}
