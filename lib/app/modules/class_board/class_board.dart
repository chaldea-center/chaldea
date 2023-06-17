import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/descriptors/mission_conds.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../descriptors/misc.dart';
import '../common/not_found.dart';

class ClassBoardDetailPage extends StatefulWidget {
  final int? id;
  final ClassBoard? board;
  const ClassBoardDetailPage({super.key, this.id, this.board});

  @override
  State<ClassBoardDetailPage> createState() => _ClassBoardDetailPageState();
}

class _ClassBoardDetailPageState extends State<ClassBoardDetailPage> with SingleTickerProviderStateMixin {
  ClassBoard? _board;
  ClassBoard get board => _board!;

  late final _tabController = TabController(length: 2, vsync: this);

  List<EventMission> get extraMissions => db.gameData.extraMasterMission[10001]?.missions ?? [];
  Map<int, EventMission> _missionMap = {};

  @override
  void initState() {
    super.initState();
    _board = widget.board ?? db.gameData.classBoards[widget.id];
    _missionMap = {for (final mission in extraMissions) mission.id: mission};
  }

  @override
  Widget build(BuildContext context) {
    if (_board == null) {
      return NotFoundPage(
        title: S.current.class_score,
        url: Routes.commandCodeI(widget.id ?? 0),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${S.current.class_score} ${board.dispName}'),
        bottom: FixedHeight.tabBar(TabBar(controller: _tabController, tabs: [
          const Tab(text: 'Info'),
          Tab(text: S.current.class_board_square),
        ])),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          infoTab,
          squareTab,
        ],
      ),
    );
  }

  Widget get infoTab {
    final spells = <int, ClassBoardCommandSpell>{}, skills = <int, NiceSkill>{};
    final Map<int, int> unlockItems = {}, enhanceItems = {};
    int totalBond = 0;

    for (final square in board.squares) {
      if (square.targetCommandSpell != null) {
        spells.putIfAbsent(square.targetCommandSpell!.id, () => square.targetCommandSpell!);
      } else if (square.targetSkill != null) {
        skills.putIfAbsent(square.targetSkill!.id, () => square.targetSkill!);
      }
      if (square.lock != null) {
        unlockItems.addDict({for (final itemAmount in square.lock!.items) itemAmount.itemId: itemAmount.amount});
      }
      enhanceItems.addDict({for (final itemAmount in square.items) itemAmount.itemId: itemAmount.amount});
    }

    final clsIds = board.classes.map((e) => e.classId).toSet();

    for (final svt in db.gameData.servantsNoDup.values) {
      if (clsIds.contains(svt.classId) && svt.isUserSvt && svt.status.favorite) {
        totalBond += svt.status.bond;
      }
    }

    List<Widget> rows = [
      CustomTableRow.fromTexts(texts: ['No.${board.id}'], isHeader: true),
      CustomTableRow.fromTexts(texts: [board.dispName]),
      if (board.condType != CondType.none) ...[
        CustomTableRow.fromTexts(texts: [S.current.condition], isHeader: true),
        CustomTableRow.fromChildren(children: [
          CondTargetValueDescriptor(
            condType: board.condType,
            target: board.condTargetId,
            value: board.condNum,
            missions: extraMissions,
          )
        ]),
      ],
      CustomTableRow.fromTexts(texts: [S.current.svt_class], isHeader: true),
      for (final boardClass in board.classes) CustomTableRow.fromChildren(children: [_buildBoardClass(boardClass)]),
      CustomTableRow.fromTexts(texts: ['${S.current.bond}(${S.current.total}, ${db.curUser.name})'], isHeader: true),
      CustomTableRow.fromTexts(texts: [totalBond.toString()]),
      CustomTableRow.fromTexts(texts: [S.current.item], isHeader: true),
      for (final items in [unlockItems, enhanceItems])
        if (items.isNotEmpty)
          CustomTableRow.fromChildren(children: [
            Wrap(
              // alignment: WrapAlignment.center,
              children: [
                for (final entry in items.entries)
                  Item.iconBuilder(
                    context: context,
                    item: null,
                    itemId: entry.key,
                    text: entry.value.format(),
                    width: 32,
                  )
              ],
            )
          ]),
      if (spells.isNotEmpty) ...[
        CustomTableRow.fromTexts(texts: [S.current.command_spell], isHeader: true),
        for (final cs in spells.values) SkillDescriptor(skill: cs.toSkill(), jumpToDetail: false),
      ],
      if (skills.isNotEmpty) ...[
        CustomTableRow.fromTexts(texts: [S.current.skill], isHeader: true),
        for (final skill in skills.values) SkillDescriptor(skill: skill),
      ],
    ];

    return SingleChildScrollView(child: CustomTable(children: rows));
  }

  Widget _buildBoardClass(ClassBoardClass boardClass) {
    if (boardClass.condType == CondType.none) {
      return SvtClassWidget(classId: boardClass.classId);
    }
    return CondTargetValueDescriptor(
      condType: boardClass.condType,
      target: boardClass.condTargetId,
      value: boardClass.condNum,
      leading: TextSpan(children: [
        SvtClassWidget.rich(context: context, classId: boardClass.classId),
        const TextSpan(text: ': '),
      ]),
    );
  }

  Widget get squareTab {
    final squares = board.squares.toList();
    squares.sort2((e) => e.id);
    return ListView.separated(
      itemBuilder: (context, index) => _buildSquareDetail(squares[index]),
      separatorBuilder: (context, index) => kDefaultDivider,
      itemCount: squares.length,
    );
  }

  Widget _buildSquareDetail(ClassBoardSquare square) {
    final name = square.targetSkill?.name ?? square.targetCommandSpell?.name;
    return SimpleAccordion(
      key: Key('square-${square.id}'),
      headerBuilder: (context, _) {
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
          leading: db.getIconImage(square.dispIcon ?? Atlas.common.unknownSkillIcon, width: 24),
          minLeadingWidth: 24,
          title: Text(Transl.skillNames(name ?? "").l),
          subtitle: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('No.${square.id} '),
              if (square.lock != null) ...[
                for (final itemAmount in square.lock!.items)
                  Item.iconBuilder(
                    context: context,
                    item: itemAmount.item,
                    width: 24,
                    text: itemAmount.amount.format(),
                  ),
                const Text(' + '),
              ],
              for (final itemAmount in square.items)
                Item.iconBuilder(
                  context: context,
                  item: itemAmount.item,
                  width: 24,
                  text: itemAmount.amount.format(),
                ),
            ],
          ),
        );
      },
      contentBuilder: (context) {
        final lock = square.lock;
        final prevs = board.lines.where((e) => e.nextSquareId == square.id).map((e) => e.prevSquareId).toList();
        final nexts = board.lines.where((e) => e.prevSquareId == square.id).map((e) => e.nextSquareId).toList();
        final mission = _missionMap[lock?.condTargetId];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lock != null)
              TileGroup(
                header: "Unlock",
                children: [
                  ListTile(
                    dense: true,
                    title: const Text('Unlock Items'),
                    leading: const Icon(Icons.lock, size: 18),
                    minLeadingWidth: 24,
                    horizontalTitleGap: 8,
                    trailing: Wrap(
                      children: [
                        for (final itemAmount in lock.items)
                          Item.iconBuilder(
                            context: context,
                            item: itemAmount.item,
                            text: itemAmount.amount.format(),
                            width: 28,
                          ),
                      ],
                    ),
                  ),
                  if (lock.condType != CondType.none)
                    ListTile(
                      dense: true,
                      title: Text(S.current.condition),
                      subtitle: CondTargetValueDescriptor(
                        condType: lock.condType,
                        target: lock.condTargetId,
                        value: lock.condNum,
                        missions: extraMissions,
                      ),
                    ),
                  if (mission != null &&
                      (lock.condType == CondType.eventMissionClear || lock.condType == CondType.eventMissionAchieve))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: MissionCondsDescriptor(mission: mission, onlyShowClear: true),
                    )
                ],
              ),
            TileGroup(
              header: square.skillTypeStr,
              children: [
                ListTile(
                  dense: true,
                  title: Text(square.skillTypeStr),
                  subtitle: square.flags.isEmpty ? null : Text(square.flags.map((e) => e.name).join(" / ")),
                  trailing: Text('Lv.+${square.upSkillLv}'),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Enhance Items'),
                  minLeadingWidth: 24,
                  horizontalTitleGap: 8,
                  trailing: Wrap(
                    children: [
                      for (final itemAmount in square.items)
                        Item.iconBuilder(
                          context: context,
                          item: itemAmount.item,
                          text: itemAmount.amount.format(),
                          width: 28,
                        ),
                    ],
                  ),
                ),
                if (square.targetSkill != null) SkillDescriptor(skill: square.targetSkill!),
                if (square.targetCommandSpell != null)
                  SkillDescriptor(
                    skill: square.targetCommandSpell!.toSkill(),
                    jumpToDetail: false,
                  )
              ],
            ),
            if (prevs.isNotEmpty || nexts.isNotEmpty)
              TileGroup(
                header: 'Line',
                children: [
                  ListTile(
                    dense: true,
                    title: Text("Previous ${S.current.class_board_square}"),
                    trailing: Text(prevs.isEmpty ? '-' : prevs.join("/")),
                  ),
                  ListTile(
                    dense: true,
                    title: Text("Next ${S.current.class_board_square}"),
                    trailing: Text(nexts.isEmpty ? '-' : nexts.join("/")),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
