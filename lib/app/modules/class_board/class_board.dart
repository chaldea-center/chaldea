import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/descriptors/func/func.dart';
import 'package:chaldea/app/descriptors/mission_conds.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../descriptors/misc.dart';
import '../common/not_found.dart';
import 'map.dart';

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

  late final _tabController = TabController(length: 3, vsync: this);

  @override
  void initState() {
    super.initState();
    _board = widget.board ?? db.gameData.classBoards[widget.id];
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
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
          const Tab(text: 'Map'),
        ])),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: _tabController.index == 2 ? const NeverScrollableScrollPhysics() : null,
        children: [
          db.onUserData((context, snapshot) => infoTab),
          squareTab,
          mapTab,
        ],
      ),
    );
  }

  Widget get infoTab {
    final spells = <int, ClassBoardCommandSpell>{}, skills = <int, NiceSkill>{};
    final spellLvs = <int, int>{}, skillLvs = <int, int>{};
    final Map<int, int> unlockItems = {}, enhanceItems = {};
    final Map<int, int> planUnlockItems = {}, planEnhanceItems = {};
    int totalBond = 0;

    for (final square in board.squares) {
      final unlocked = db.curPlan_.classBoardSquare[square.id] == LockPlan.full;
      if (square.targetCommandSpell != null) {
        spells.putIfAbsent(square.targetCommandSpell!.id, () => square.targetCommandSpell!);
        if (unlocked) spellLvs.addNum(square.targetCommandSpell!.id, square.upSkillLv);
      } else if (square.targetSkill != null) {
        skills.putIfAbsent(square.targetSkill!.id, () => square.targetSkill!);
        if (unlocked) skillLvs.addNum(square.targetSkill!.id, square.upSkillLv);
      }
      if (square.lock != null) {
        final lockItems = {for (final itemAmount in square.lock!.items) itemAmount.itemId: itemAmount.amount};
        unlockItems.addDict(lockItems);
        if (db.curPlan_.classBoardLock[square.lock!.id] == LockPlan.planned) {
          planUnlockItems.addDict(lockItems);
        }
      }
      final squareItems = {for (final itemAmount in square.items) itemAmount.itemId: itemAmount.amount};
      enhanceItems.addDict(squareItems);
      if (db.curPlan_.classBoardSquare[square.id] == LockPlan.planned) {
        planEnhanceItems.addDict(squareItems);
      }
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
      CustomTableRow.fromTexts(texts: ['${S.current.item}(${S.current.plan})'], isHeader: true),
      for (final items in [planUnlockItems, planEnhanceItems])
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
        for (final cs in spells.values)
          SkillDescriptor(
            skill: cs.toSkill(),
            level: spellLvs[cs.id],
            jumpToDetail: false,
          ),
      ],
      if (skills.isNotEmpty) ...[
        CustomTableRow.fromTexts(texts: [S.current.skill], isHeader: true),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final skill in skills.values)
              ...FuncsDescriptor.describe(
                funcs: skill.functions,
                script: skill.script,
                level: skillLvs[skill.id],
                showPlayer: true,
                showEnemy: false,
              ),
          ],
        )
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
          trailing: db.onUserData((context, snapshot) {
            List<InlineSpan> status = [];
            if (square.lock != null) {
              final lockPlan = db.curPlan_.classBoardLock[square.lock!.id] ?? LockPlan.none;
              if (lockPlan != LockPlan.none) {
                status.add(TextSpan(children: [
                  const CenterWidgetSpan(child: Icon(Icons.lock, size: 16)),
                  TextSpan(text: lockPlan.dispPlan),
                ]));
              }
            }
            final enhancePlan = db.curPlan_.classBoardSquare[square.id] ?? LockPlan.none;
            if (enhancePlan != LockPlan.none) {
              status.add(TextSpan(text: enhancePlan.dispPlan));
            }
            status = divideList(status, const TextSpan(text: '\n'));
            return Text.rich(
              TextSpan(children: status),
              textAlign: TextAlign.end,
              textScaleFactor: 0.9,
            );
          }),
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
      contentBuilder: (context) => ClassBoardSquareDetail(board: board, square: square),
    );
  }

  bool showPlannedMap = false;
  Widget get mapTab {
    return Column(
      children: [
        Expanded(child: ClassBoardMap(board: board, showPlanned: showPlannedMap)),
        kDefaultDivider,
        SwitchListTile(
          dense: true,
          title: Text(S.current.plan),
          value: showPlannedMap,
          onChanged: (v) {
            setState(() {
              showPlannedMap = !showPlannedMap;
            });
          },
        ),
        const SafeArea(child: SizedBox.shrink()),
      ],
    );
  }
}

class ClassBoardSquareDetail extends StatelessWidget {
  final ClassBoard board;
  final ClassBoardSquare square;
  const ClassBoardSquareDetail({super.key, required this.board, required this.square});

  @override
  Widget build(BuildContext context) {
    final lock = square.lock;
    final prevs = board.lines.where((e) => e.nextSquareId == square.id).map((e) => e.prevSquareId).toList();
    final nexts = board.lines.where((e) => e.prevSquareId == square.id).map((e) => e.nextSquareId).toList();
    List<Widget> children = [];
    if (lock != null) {
      EventMission? mission;
      if (lock.condType == CondType.eventMissionClear || lock.condType == CondType.eventMissionAchieve) {
        mission = db.gameData.others.eventMissions[lock.condTargetId];
      }
      children.add(TileGroup(
        header: S.current.unlock,
        children: [
          if (lock.items.isNotEmpty)
            ListTile(
              dense: true,
              title: Text(S.current.plan),
              trailing: db.onUserData(
                (context, snapshot) => FilterGroup<LockPlan>(
                  combined: true,
                  padding: EdgeInsets.zero,
                  options: LockPlan.values,
                  values: FilterRadioData.nonnull(db.curPlan_.classBoardLock[lock.id] ?? LockPlan.none),
                  optionBuilder: (value) => Text(value.dispPlan),
                  onFilterChanged: (v, _) {
                    db.curPlan_.classBoardLock[lock.id] = v.radioValue!;
                    db.itemCenter.updateClassBoard();
                  },
                ),
              ),
            ),
          ListTile(
            dense: true,
            title: Text('${S.current.item}(${S.current.unlock})'),
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
              ),
            ),
          if (mission != null &&
              (lock.condType == CondType.eventMissionClear || lock.condType == CondType.eventMissionAchieve))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: MissionCondsDescriptor(mission: mission, onlyShowClear: true),
            )
        ],
      ));
    }
    children.add(TileGroup(
      header: square.skillTypeStr,
      children: [
        if (square.items.isNotEmpty)
          ListTile(
            dense: true,
            title: Text(S.current.plan),
            trailing: db.onUserData(
              (context, snapshot) => FilterGroup<LockPlan>(
                combined: true,
                padding: EdgeInsets.zero,
                options: LockPlan.values,
                values: FilterRadioData.nonnull(db.curPlan_.classBoardSquare[square.id] ?? LockPlan.none),
                optionBuilder: (value) => Text(value.dispPlan),
                onFilterChanged: (v, _) {
                  db.curPlan_.classBoardSquare[square.id] = v.radioValue!;
                  db.itemCenter.updateClassBoard();
                },
              ),
            ),
          ),
        ListTile(
          dense: true,
          title: Text(square.skillTypeStr),
          subtitle: square.flags.isEmpty ? null : Text(square.flags.map((e) => e.name).join(" / ")),
          trailing: Text('Lv.+${square.upSkillLv}'),
        ),
        ListTile(
          dense: true,
          title: Text('${S.current.item}(${S.current.enhance})'),
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
    ));
    if (prevs.isNotEmpty || nexts.isNotEmpty) {
      children.add(TileGroup(
        header: 'Line',
        children: [
          ListTile(
            dense: true,
            title: Text(S.current.general_previous),
            trailing: Text(prevs.isEmpty ? '-' : '${S.current.class_board_square} ${prevs.join("/")}'),
          ),
          ListTile(
            dense: true,
            title: Text(S.current.general_next),
            trailing: Text(nexts.isEmpty ? '-' : '${S.current.class_board_square} ${nexts.join("/")}'),
          ),
        ],
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
