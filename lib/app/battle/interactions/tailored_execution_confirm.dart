import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/widgets/widgets.dart';
import '_dialog.dart';

class TailoredExecutionConfirm extends StatelessWidget {
  final String description;
  final String details;
  const TailoredExecutionConfirm({super.key, required this.description, required this.details});

  static Future<bool> show({
    required BuildContext context,
    required String description,
    required String details,
  }) {
    return showUserConfirm<bool>(
      context: context,
      builder: (context) => TailoredExecutionConfirm(description: description, details: details),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleCancelOkDialog(
      title: Text(S.current.battle_select_effect),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: divideTiles(
          [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(description, textScaleFactor: 0.85),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(details, textScaleFactor: 0.85),
            ),
            Row(
              children: [
                Text('${S.current.battle_should_activate}: '),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('No'),
                ),
              ],
            )
          ],
        ),
      ),
      hideOk: true,
      hideCancel: true,
    );
  }
}
