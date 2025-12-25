import 'dart:math';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/mystic_code/mystic_code_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';

class ReportDisplayOptions {
  bool isGirl = true;
  int masterEquipId = 0;
  bool showFriendCode = false;

  ReportDisplayOptions();

  int getDefaultMasterEquip({required Region region}) {
    const summerEquips = [70, 120, 330];
    const christmasEquips = [340, 410];
    const newYearEquips = [260, 130, 260, 410];

    final today = DateTime.now();
    final rnd = Random();

    int _getRandom(List<int> ids) {
      return ids[rnd.nextInt(ids.length)];
    }

    if (today.month == 7 || today.month == 8) {
      return _getRandom(summerEquips);
    }
    if (today.month == 12) {
      if (today.day > 25) {
        return _getRandom([...christmasEquips, ...newYearEquips]);
      } else if (today.day > 20) {
        return _getRandom(christmasEquips);
      } else {
        return _getRandom(christmasEquips);
      }
    }
    if (today.month == 1 || (Region.cn == region && today.month == 2)) {
      return _getRandom(newYearEquips);
    }
    if (db.gameData.mysticCodes.isNotEmpty) {
      return _getRandom(db.gameData.mysticCodes.keys.toList());
    }
    return 210;
  }

  String getMasterEquipImageUrl() {
    final equip = db.gameData.mysticCodes[masterEquipId] ?? db.gameData.mysticCodes[210];
    String? url;
    if (equip != null) {
      url = isGirl ? equip.extraAssets.masterFigure.female : equip.extraAssets.masterFigure.male;
    }
    return url ?? 'https://static.atlasacademy.io/JP/MasterFigure/equip00332.png';
  }
}

class MasterEquipChangeDialog extends StatefulWidget {
  final ReportDisplayOptions options;
  const MasterEquipChangeDialog({super.key, required this.options});

  @override
  State<MasterEquipChangeDialog> createState() => _MasterEquipChangeDialogState();
}

class _MasterEquipChangeDialogState extends State<MasterEquipChangeDialog> {
  late final options = widget.options;

  @override
  Widget build(BuildContext context) {
    final equip = db.gameData.mysticCodes[options.masterEquipId];
    return SimpleConfirmDialog(
      title: Text(S.current.mystic_code),
      scrollable: true,
      showCancel: false,
      content: ListTileTheme(
        contentPadding: EdgeInsets.zero,
        dense: true,
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            FilterGroup<bool>(
              combined: true,
              padding: .zero,
              options: [false, true],
              values: FilterRadioData.nonnull(options.isGirl),
              optionBuilder: (value) => Text(value ? S.current.guda_female : S.current.guda_male),
              onFilterChanged: (optionData, lastChanged) {
                options.isGirl = optionData.radioValue ?? options.isGirl;
                if (mounted) setState(() {});
              },
            ),
            ListTile(
              leading: equip == null ? null : db.getIconImage(equip.extraAssets.masterFace.female),
              title: Text(S.current.mystic_code),
              subtitle: Text(equip?.lName.l ?? options.masterEquipId.toString()),
              trailing: IconButton(
                onPressed: () {
                  router.pushPage(
                    MysticCodeListPage(
                      onSelected: (mysticCode) {
                        options.masterEquipId = mysticCode.id;
                        if (mounted) setState(() {});
                      },
                    ),
                  );
                },
                icon: Icon(Icons.change_circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
