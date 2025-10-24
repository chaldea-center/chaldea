import 'dart:math';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class RecoverSelectDialog extends StatelessWidget {
  final List<RecoverEntity> recovers;
  final MasterDataManager? mstData;
  const RecoverSelectDialog({super.key, required this.recovers, this.mstData});

  @override
  Widget build(BuildContext context) {
    final recovers = this.recovers.toList();
    recovers.sort2((e) => -e.priority);
    return ListTileTheme.merge(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      minLeadingWidth: 32,
      child: SimpleDialog(
        title: const Text("Recover AP"),
        children: [for (final recover in recovers) buildRecoverItem(context, recover)],
      ),
    );
  }

  Widget buildRecoverItem(BuildContext context, RecoverEntity recover) {
    final userGame = mstData?.user;
    if (mstData != null && userGame == null) {
      return const SimpleConfirmDialog(title: Text("No user data"));
    }
    switch (recover.recoverType) {
      case RecoverType.commandSpell:
        return const ListTile(title: Text('command spell not supported'), enabled: false);
      case RecoverType.stone:
        final ownCount = userGame?.stone ?? 0;
        bool enabled =
            mstData == null ||
            (userGame != null && userGame.stone > 0 && userGame.calCurAp() < userGame.actMax && ownCount > 0);
        return ListTile(
          leading: Item.iconBuilder(context: context, item: null, itemId: Items.stoneId),
          title: Text(Items.stone?.lName.l ?? "Saint Quartz"),
          subtitle: mstData == null ? null : Text("${S.current.item_own}: $ownCount"),
          enabled: enabled,
          onTap: enabled ? () => Navigator.pop(context, recover) : null,
        );
      case RecoverType.item:
        final item = db.gameData.items[recover.targetId];
        final ownCount = mstData?.getItemOrSvtNum(recover.targetId) ?? 0;
        bool enabled = mstData == null || (userGame != null && ownCount > 0);
        return ListTile(
          leading: Item.iconBuilder(context: context, item: item, itemId: recover.targetId),
          title: Text(item?.lName.l ?? "No.${recover.targetId}"),
          subtitle: mstData == null ? null : Text("${S.current.item_own}: $ownCount"),
          enabled: enabled,
          onTap: enabled ? () => Navigator.pop(context, recover) : null,
        );
    }
  }
}

class ApSeedExchangeCountDialog extends StatefulWidget {
  final MasterDataManager mstData;
  const ApSeedExchangeCountDialog({super.key, required this.mstData});

  @override
  State<ApSeedExchangeCountDialog> createState() => _ApSeedExchangeCountDialogState();
}

class _ApSeedExchangeCountDialogState extends State<ApSeedExchangeCountDialog> {
  int buyCount = 1;

  @override
  Widget build(BuildContext context) {
    const int apUnit = 40, seedUnit = 1;
    final apCount = widget.mstData.user?.calCurAp() ?? 0;
    final seedCount = widget.mstData.getItemOrSvtNum(Items.blueSaplingId);
    final int maxBuyCount = min(apCount ~/ apUnit, seedCount ~/ seedUnit);
    return AlertDialog(
      title: const Text('Exchange Count'),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'AP×$apCount  '),
                CenterWidgetSpan(
                  child: Item.iconBuilder(context: context, item: null, itemId: Items.blueSaplingId, width: 24),
                ),
                TextSpan(text: '×$seedCount'),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'AP×${apUnit * buyCount}  '),
                CenterWidgetSpan(
                  child: Item.iconBuilder(context: context, item: null, itemId: Items.blueSaplingId, width: 24),
                ),
                TextSpan(text: '×${seedUnit * buyCount} → '),
                CenterWidgetSpan(
                  child: Item.iconBuilder(context: context, item: null, itemId: Items.blueAppleId, width: 24),
                ),
                TextSpan(text: '×$buyCount'),
              ],
            ),
          ),
          if (maxBuyCount >= 1)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('1'),
                Expanded(
                  child: Slider(
                    value: buyCount.toDouble(),
                    onChanged: (v) {
                      setState(() {
                        buyCount = v.round().clamp(1, maxBuyCount);
                      });
                    },
                    min: 1.0,
                    max: maxBuyCount.toDouble(),
                    divisions: maxBuyCount > 1 ? maxBuyCount - 1 : null,
                    label: buyCount.toString(),
                  ),
                ),
                Text(maxBuyCount.toString()),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(S.current.cancel),
        ),
        TextButton(
          onPressed: maxBuyCount > 0 && buyCount <= maxBuyCount
              ? () {
                  Navigator.pop(context, buyCount);
                }
              : null,
          child: Text(S.current.confirm),
        ),
      ],
    );
  }
}
