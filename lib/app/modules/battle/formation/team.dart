import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'svt_selector.dart';

class TeamSetupCard extends StatefulWidget {
  final List<PlayerSvtData> onFieldSvts;
  final List<PlayerSvtData> backupSvts;
  final BattleTeamSetup team;
  final QuestPhase? quest;
  final bool enableEdit;
  final bool showEmptyBackup;

  const TeamSetupCard({
    super.key,
    required this.onFieldSvts,
    required this.backupSvts,
    required this.team,
    required this.quest,
    this.enableEdit = true,
    this.showEmptyBackup = true,
  });

  @override
  State<TeamSetupCard> createState() => _TeamSetupCardState();
}

class _TeamSetupCardState extends State<TeamSetupCard> {
  List<PlayerSvtData> get onFieldSvts => widget.onFieldSvts;
  List<PlayerSvtData> get backupSvts => widget.backupSvts;
  BattleTeamSetup get team => widget.team;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      horizontalDivider: kIndentDivider,
      children: [
        partyOrganization(onFieldSvts, S.current.team_starting_member),
        if (widget.showEmptyBackup || backupSvts.any((e) => e.svt != null))
          partyOrganization(backupSvts, S.current.team_backup_member),
      ],
    );
  }

  Responsive partyOrganization(List<PlayerSvtData> svts, String title) {
    return Responsive(
      small: 12,
      middle: 6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          Row(
            children: [
              for (final svt in svts)
                Expanded(
                  child: ServantSelector(
                    playerSvtData: svt,
                    playerRegion: team.playerRegion,
                    questPhase: widget.quest,
                    onChange: () {
                      if (mounted) setState(() {});
                    },
                    onDragSvt: widget.enableEdit ? (svtFrom) => onDrag(svtFrom, svt, false) : null,
                    onDragCE: widget.enableEdit ? (svtFrom) => onDrag(svtFrom, svt, true) : null,
                    enableEdit: widget.enableEdit,
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }

  void onDrag(PlayerSvtData from, PlayerSvtData to, bool isCE) {
    final allSvts = team.allSvts.toList();
    final fromIndex = allSvts.indexOf(from), toIndex = allSvts.indexOf(to);
    if (fromIndex < 0 || toIndex < 0 || fromIndex == toIndex) return;
    if (isCE) {
      final ce = from.ce, ceLv = from.ceLv, ceLimitBreak = from.ceLimitBreak;
      from
        ..ce = to.ce
        ..ceLv = to.ceLv
        ..ceLimitBreak = to.ceLimitBreak;
      to
        ..ce = ce
        ..ceLv = ceLv
        ..ceLimitBreak = ceLimitBreak;
    } else {
      allSvts[fromIndex] = to;
      allSvts[toIndex] = from;
      onFieldSvts.setAll(0, allSvts.sublist(0, onFieldSvts.length));
      backupSvts.setAll(0, allSvts.sublist(onFieldSvts.length));
    }

    if (mounted) setState(() {});
  }
}
