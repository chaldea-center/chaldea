import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/userdata/filter_data.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../state.dart';

class UserStatusFlagSetPage extends StatefulWidget {
  final FakerRuntime runtime;
  const UserStatusFlagSetPage({super.key, required this.runtime});

  @override
  State<UserStatusFlagSetPage> createState() => _UserStatusFlagSetPageState();
}

class _UserStatusFlagSetPageState extends State<UserStatusFlagSetPage> {
  int get curStatusFlag => widget.runtime.mstData.user?.flag ?? 0;
  late final selectedFlags = FilterGroupData<UserStatusFlagKind>(
    options: {
      for (final kind in UserStatusFlagKind.values)
        if (curStatusFlag & kind.mask != 0) kind,
    },
  );

  @override
  Widget build(BuildContext context) {
    UserStatusFlagKind;
    return Scaffold(
      appBar: AppBar(title: Text('User Game Settings')),
      body: ListView(
        children: [
          DividerWithTitle(title: 'Gacha - Auto Sell'),
          buildGroup('种火', UserStatusFlagKind.kGachaSellCombineMaterials),
          buildGroup('芙芙', UserStatusFlagKind.kGachaSellStatusUps),
          buildGroup(S.current.craft_essence_short, UserStatusFlagKind.kGachaSellSvtEquips),
          Center(
            child: Padding(padding: EdgeInsets.all(4), child: gachaSellFlagSetButton),
          ),
        ],
      ),
    );
  }

  Widget buildGroup(String title, List<UserStatusFlagKind> options) {
    Widget child = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: Text(title)),
        Flexible(
          flex: 3,
          child: FilterGroup<UserStatusFlagKind>(
            options: options,
            values: selectedFlags,
            optionBuilder: (v) => Text(switch (v) {
              UserStatusFlagKind.combineMaterialC => '${kStarChar2}1',
              UserStatusFlagKind.combineMaterialUc => '${kStarChar2}2',
              UserStatusFlagKind.combineMaterialR => '${kStarChar2}3',
              UserStatusFlagKind.statusUpC => '${kStarChar2}1',
              UserStatusFlagKind.statusUpUc => '${kStarChar2}2',
              UserStatusFlagKind.statusUpR => '${kStarChar2}3',
              UserStatusFlagKind.svtEquipC => '${kStarChar2}1',
              UserStatusFlagKind.svtEquipUc => '${kStarChar2}2',
              UserStatusFlagKind.svtEquipR => '${kStarChar2}3',
              _ => v.name,
            }),
            onFilterChanged: (v, _) {
              if (mounted) setState(() {});
            },
          ),
        ),
      ],
    );
    child = Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: child);
    return child;
  }

  Widget get gachaSellFlagSetButton {
    final userFlag = curStatusFlag;
    bool changed = UserStatusFlagKind.kGachaSells.any((flag) {
      return (userFlag & flag.mask != 0) != (selectedFlags.options.contains(flag));
    });
    return FilledButton(
      onPressed: changed
          ? () async {
              List<int> onFlagNumbers = [], offFlagNumbers = [];
              for (final flag in UserStatusFlagKind.kGachaSells) {
                if (selectedFlags.options.contains(flag)) {
                  onFlagNumbers.add(flag.value);
                } else {
                  offFlagNumbers.add(flag.value);
                }
              }
              await widget.runtime.runTask(
                () => widget.runtime.agent.userStatusFlagSet(
                  onFlagNumbers: onFlagNumbers,
                  offFlagNumbers: offFlagNumbers,
                ),
              );
              if (mounted) setState(() {});
            }
          : null,
      child: Text('Set Auto Sell Flags'),
    );
  }
}
