import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'svt_selector.dart';

class TeamSetupCard extends StatefulWidget {
  final BattleTeamSetup formation;
  final QuestPhase? quest;
  final Region? playerRegion;
  final bool enableEdit;
  final bool showEmptyBackup;
  final VoidCallback? onChanged;

  const TeamSetupCard({
    super.key,
    required this.formation,
    required this.quest,
    this.playerRegion,
    this.enableEdit = true,
    this.showEmptyBackup = true,
    this.onChanged,
  });

  @override
  State<TeamSetupCard> createState() => _TeamSetupCardState();
}

class _TeamSetupCardState extends State<TeamSetupCard> {
  List<PlayerSvtData> get onFieldSvts => formation.onFieldSvtDataList;
  List<PlayerSvtData> get backupSvts => formation.backupSvtDataList;
  BattleTeamSetup get formation => widget.formation;

  final hovered = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: hovered,
      builder:
          (context, _, __) => ResponsiveLayout(
            horizontalDivider: kIndentDivider,
            children: [
              partyOrganization(onFieldSvts, S.current.team_starting_member),
              if (widget.showEmptyBackup || backupSvts.any((e) => e.svt != null))
                partyOrganization(backupSvts, S.current.team_backup_member),
            ],
          ),
    );
  }

  Responsive partyOrganization(List<PlayerSvtData> svts, String title) {
    return Responsive(
      small: 6,
      middle: 6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final svt in svts)
                Expanded(
                  child: ServantSelector(
                    hovered: hovered,
                    playerSvtData: svt,
                    playerRegion: widget.playerRegion,
                    questPhase: widget.quest,
                    onChanged: () {
                      if (mounted) setState(() {});
                      widget.onChanged?.call();
                    },
                    onDragSvt: widget.enableEdit ? (svtFrom) => onDrag(svtFrom, svt, false) : null,
                    onDragCE: widget.enableEdit ? (svtFrom) => onDrag(svtFrom, svt, true) : null,
                    enableEdit: widget.enableEdit,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void onDrag(PlayerSvtData from, PlayerSvtData to, bool isCE) {
    final allSvts = formation.allSvts.toList();
    final fromIndex = allSvts.indexOf(from), toIndex = allSvts.indexOf(to);
    if (fromIndex < 0 || toIndex < 0 || fromIndex == toIndex) return;
    if (isCE) {
      final tmp = from.equip1.copy();
      from.equip1 = to.equip1.copy();
      to.equip1 = tmp;
    } else {
      allSvts[fromIndex] = to;
      allSvts[toIndex] = from;
      onFieldSvts.setAll(0, allSvts.sublist(0, onFieldSvts.length));
      backupSvts.setAll(0, allSvts.sublist(onFieldSvts.length));
    }

    if (mounted) setState(() {});
    widget.onChanged?.call();
  }
}
