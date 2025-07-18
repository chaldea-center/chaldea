import 'dart:math';

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
  ClassBoardPlan get status => db.curUser.classBoardStatusOf(board.id);
  ClassBoardPlan get plan_ => db.curPlan_.classBoardPlan(board.id);

  late final _tabController = TabController(length: board.isGrand ? 3 : 4, vsync: this);

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
      return NotFoundPage(title: S.current.class_board, url: Routes.classBoardI(widget.id ?? 0));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${S.current.class_board} ${board.dispName}'),
        bottom: FixedHeight.tabBar(
          TabBar(
            controller: _tabController,
            tabs: [
              const Tab(text: 'Info'),
              Tab(text: S.current.class_board_square),
              const Tab(text: 'Map'),
              if (!board.isGrand) Tab(text: S.current.mission),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: _tabController.index == 2 ? const NeverScrollableScrollPhysics() : null,
        children: [db.onUserData((context, snapshot) => infoTab), squareTab, mapTab, if (!board.isGrand) missionTab],
      ),
    );
  }

  List<NiceFunction> _limitMaxLv(List<NiceFunction> functions, int? maxLv) {
    if (maxLv == null || functions.isEmpty || maxLv >= functions.first.svals.length) return functions;
    functions = [for (final func in functions) NiceFunction.fromJson(func.toJson())];
    for (final func in functions) {
      func.svals = func.svals.sublist(0, min(func.svals.length, maxLv));
    }
    return functions;
  }

  Widget get infoTab {
    final spells = <int, ClassBoardCommandSpell>{}, skills = <int, NiceSkill>{};
    final spellLvs = <int, int>{}, skillLvs = <int, int>{};
    final maxSpellLvs = <int, int>{}, maxSkillLvs = <int, int>{};
    final Map<int, int> unlockItems = {}, enhanceItems = {};
    final Map<int, int> planUnlockItems = {}, planEnhanceItems = {};
    int totalBond = 0;

    for (final square in board.squares) {
      final enhanced = status.enhancedSquares.contains(square.id);
      if (square.targetCommandSpell != null) {
        spells.putIfAbsent(square.targetCommandSpell!.id, () => square.targetCommandSpell!);
        if (enhanced) spellLvs.addNum(square.targetCommandSpell!.id, square.upSkillLv);
        maxSpellLvs.addNum(square.targetCommandSpell!.id, square.upSkillLv);
      } else if (square.targetSkill != null) {
        skills.putIfAbsent(square.targetSkill!.id, () => square.targetSkill!);
        if (enhanced) skillLvs.addNum(square.targetSkill!.id, square.upSkillLv);
        maxSkillLvs.addNum(square.targetSkill!.id, square.upSkillLv);
      }
      if (square.lock != null) {
        final lockItems = {for (final itemAmount in square.lock!.items) itemAmount.itemId: itemAmount.amount};
        unlockItems.addDict(lockItems);
        if (!status.unlockedSquares.contains(square.id) && plan_.unlockedSquares.contains(square.id)) {
          planUnlockItems.addDict(lockItems);
        }
      }
      final squareItems = {for (final itemAmount in square.items) itemAmount.itemId: itemAmount.amount};
      enhanceItems.addDict(squareItems);
      if (!status.enhancedSquares.contains(square.id) && plan_.enhancedSquares.contains(square.id)) {
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
      CustomTableRow.fromChildren(
        children: [
          Text.rich(
            TextSpan(
              children: [
                CenterWidgetSpan(child: db.getIconImage(board.btnIcon, width: 24, aspectRatio: 1)),
                const TextSpan(text: ' '),
                TextSpan(text: board.dispName),
              ],
            ),
          ),
        ],
      ),
      if (board.condType != CondType.none) ...[
        CustomTableRow.fromTexts(texts: [S.current.condition], isHeader: true),
        CustomTableRow.fromChildren(
          children: [
            CondTargetValueDescriptor(condType: board.condType, target: board.condTargetId, value: board.condNum),
          ],
        ),
      ],
      CustomTableRow.fromTexts(texts: [S.current.svt_class], isHeader: true),
      for (final boardClass in board.classes) CustomTableRow.fromChildren(children: [_buildBoardClass(boardClass)]),
      CustomTableRow.fromTexts(texts: ['${S.current.bond}(${S.current.total}, ${db.curUser.name})'], isHeader: true),
      CustomTableRow.fromTexts(texts: [totalBond.toString()]),
      CustomTableRow.fromTexts(texts: [S.current.item], isHeader: true),
      for (final items in [unlockItems, enhanceItems])
        if (items.isNotEmpty)
          CustomTableRow.fromChildren(
            children: [
              Wrap(
                // alignment: WrapAlignment.center,
                children: [
                  for (final itemId in items.keys.toList()..sort(Item.compare2))
                    Item.iconBuilder(
                      context: context,
                      item: null,
                      itemId: itemId,
                      text: items[itemId]?.format(),
                      width: 32,
                    ),
                ],
              ),
            ],
          ),
      CustomTableRow.fromTexts(texts: ['${S.current.item}(${S.current.plan})'], isHeader: true),
      if (planUnlockItems.isEmpty && planEnhanceItems.isEmpty) CustomTableRow.fromTexts(texts: const ['-']),
      for (final items in [planUnlockItems, planEnhanceItems])
        if (items.isNotEmpty)
          CustomTableRow.fromChildren(
            children: [
              Wrap(
                // alignment: WrapAlignment.center,
                children: [
                  for (final itemId in items.keys.toList()..sort(Item.compare2))
                    Item.iconBuilder(
                      context: context,
                      item: null,
                      itemId: itemId,
                      text: items[itemId]?.format(),
                      width: 32,
                    ),
                ],
              ),
            ],
          ),
      if (spells.isNotEmpty) ...[
        CustomTableRow.fromTexts(texts: [S.current.command_spell], isHeader: true),
        for (final cs in spells.values)
          SkillDescriptor(
            skill: () {
              final skill = cs.toSkill();
              skill.functions = _limitMaxLv(skill.functions, maxSpellLvs[cs.id]);
              return skill;
            }(),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: FuncsDescriptor.describe(
                        funcs: _limitMaxLv(skill.functions, maxSkillLvs[skill.id]),
                        script: skill.script,
                        level: skillLvs[skill.id],
                        showPlayer: true,
                        showEnemy: false,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: skill.routeTo,
                    icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ],
              ),
          ],
        ),
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
      leading: TextSpan(
        children: [
          SvtClassWidget.rich(context: context, classId: boardClass.classId),
          const TextSpan(text: ': '),
        ],
      ),
    );
  }

  Widget get squareTab {
    final squares = board.squares.toList();
    squares.sort2((e) => e.id);
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) => _buildSquareDetail(squares[index]),
            separatorBuilder: (context, index) => kDefaultDivider,
            itemCount: squares.length,
          ),
        ),
        kDefaultDivider,
        SafeArea(
          child: OverflowBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(context: context, useRootNavigator: false, builder: setAllDialog);
                },
                child: Text(S.current.set_all),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSquareDetail(ClassBoardSquare square) {
    String? name = square.targetSkill?.name ?? square.targetCommandSpell?.name;
    String? icon = square.dispIcon;
    if (square.flags.contains(ClassBoardSquareFlag.blank)) {
      name ??= "blank";
      icon ??=
          "https://static.atlasacademy.io/file/aa-fgo-extract-jp/ClassBoard/Main/DownloadClassBoardSquareLineAtlas1/point_on.png";
    }
    double iconSize = square.skillType == ClassBoardSkillType.none ? 40 : 24;
    return SimpleAccordion(
      key: Key('square-${square.id}'),
      headerBuilder: (context, _) {
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
          leading: db.getIconImage(icon ?? Atlas.common.unknownSkillIcon, width: iconSize),
          minLeadingWidth: iconSize,
          title: Text(Transl.skillNames(name ?? "").l),
          trailing: db.onUserData((context, snapshot) {
            List<InlineSpan> status = [];
            if (square.lock != null) {
              final lockPlan = db.curUser.classBoardUnlockedOf(board.id, square.id);
              if (lockPlan != LockPlan.none) {
                status.add(
                  TextSpan(
                    children: [
                      const CenterWidgetSpan(child: Icon(Icons.lock, size: 16)),
                      TextSpan(text: lockPlan.dispPlan),
                    ],
                  ),
                );
              }
            }
            final enhancePlan = db.curUser.classBoardEnhancedOf(board.id, square.id);
            if (enhancePlan != LockPlan.none) {
              status.add(TextSpan(text: enhancePlan.dispPlan));
            }
            status = divideList(status, const TextSpan(text: '\n'));
            return Text.rich(
              TextSpan(children: status),
              textAlign: TextAlign.end,
              textScaler: const TextScaler.linear(0.9),
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
                const Text('  '),
              ],
              for (final itemAmount in square.items)
                Item.iconBuilder(context: context, item: itemAmount.item, width: 24, text: itemAmount.amount.format()),
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
        Expanded(
          child: ClassBoardMap(board: board, showPlanned: showPlannedMap),
        ),
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

  Widget get missionTab {
    List<ClassBoardLock> locks = [];
    for (final square in board.squares) {
      final lock = square.lock;
      if (lock == null || lock.condType != CondType.eventMissionClear) continue;
      locks.add(lock);
    }
    locks.sort2((e) => e.id);
    final missions = db.gameData.extraMasterMission[MasterMission.kExtraMasterMissionId]?.missions ?? [];
    final missionMap = {for (final m in missions) m.id: m};
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final lock = locks[index];
        final mission = missionMap[lock.condTargetId];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CondTargetValueDescriptor(
              condType: lock.condType,
              target: lock.condTargetId,
              value: lock.condNum,
              textScaleFactor: 0.8,
            ),
            if (mission != null) MissionCondsDescriptor(mission: mission, onlyShowClear: true),
          ],
        );
      },
      separatorBuilder: (_, _) => const Divider(),
      itemCount: locks.length,
    );
  }

  Widget setAllDialog(BuildContext context) {
    return SimpleDialog(
      title: Text(S.current.set_all),
      children: [
        for (final isCur in [true, false]) ...[
          SimpleDialogOption(
            child: Text(isCur ? S.current.current_ : S.current.target, style: Theme.of(context).textTheme.bodySmall),
          ),
          for (final value in [false, true])
            SimpleDialogOption(
              child: Text(value ? '1' : '0'),
              onPressed: () {
                Navigator.pop(context);
                final target = isCur ? status : plan_;
                if (value) {
                  final lockSquareIds = board.squares
                      .where((e) => e.lock != null && e.lock!.items.isNotEmpty)
                      .map((e) => e.id)
                      .toSet();
                  final enhanceSquareIds = board.squares.where((e) => e.items.isNotEmpty).map((e) => e.id).toSet();
                  target.unlockedSquares = lockSquareIds.toSet();
                  target.enhancedSquares = enhanceSquareIds.toSet();
                } else {
                  target.unlockedSquares.clear();
                  target.enhancedSquares.clear();
                }
                if (mounted) setState(() {});
                db.itemCenter.updateClassBoard();
              },
            ),
        ],
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
      children.add(
        TileGroup(
          header: S.current.unlock,
          children: [
            if (lock.items.isNotEmpty)
              ListTile(
                dense: true,
                title: Text(S.current.plan),
                contentPadding: const EdgeInsetsDirectional.only(start: 16),
                trailing: db.onUserData(
                  (context, snapshot) => Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilterGroup<LockPlan>(
                        combined: true,
                        padding: EdgeInsets.zero,
                        options: LockPlan.values,
                        values: FilterRadioData.nonnull(board.unlockedOf(square.id)),
                        optionBuilder: (value) => Text(value.dispPlan),
                        onFilterChanged: (v, _) {
                          board.status.unlockedSquares.toggle(square.id, v.radioValue!.current);
                          board.plan_.unlockedSquares.toggle(square.id, v.radioValue!.target);
                          db.itemCenter.updateClassBoard();
                        },
                      ),
                      buildEnhanceButton(
                        context: context,
                        title: S.current.unlock,
                        enabled: board.unlockedOf(square.id) != LockPlan.full,
                        items: lock.items,
                        onEnhance: () {
                          for (final amount in lock.items) {
                            db.curUser.items.addNum(amount.itemId, amount.amount * -1);
                          }
                          board.status.unlockedSquares.toggle(square.id, true);
                          board.plan_.unlockedSquares.toggle(square.id, true);
                          db.itemCenter.updateClassBoard();
                        },
                      ),
                    ],
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
              ),
          ],
        ),
      );
    }
    children.add(
      TileGroup(
        header: square.skillTypeStr,
        children: [
          if (square.items.isNotEmpty)
            ListTile(
              dense: true,
              contentPadding: const EdgeInsetsDirectional.only(start: 16),
              title: Text(S.current.plan),
              trailing: db.onUserData(
                (context, snapshot) => Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilterGroup<LockPlan>(
                      combined: true,
                      padding: EdgeInsets.zero,
                      options: LockPlan.values,
                      values: FilterRadioData.nonnull(board.enhancedOf(square.id)),
                      optionBuilder: (value) => Text(value.dispPlan),
                      onFilterChanged: (v, _) {
                        board.status.enhancedSquares.toggle(square.id, v.radioValue!.current);
                        board.plan_.enhancedSquares.toggle(square.id, v.radioValue!.target);
                        db.itemCenter.updateClassBoard();
                      },
                    ),
                    buildEnhanceButton(
                      context: context,
                      title: S.current.enhance,
                      enabled: board.enhancedOf(square.id) != LockPlan.full,
                      items: square.items,
                      onEnhance: () {
                        for (final amount in square.items) {
                          db.curUser.items.addNum(amount.itemId, amount.amount * -1);
                        }
                        board.status.enhancedSquares.toggle(square.id, true);
                        board.plan_.enhancedSquares.toggle(square.id, true);
                        db.itemCenter.updateClassBoard();
                      },
                    ),
                  ],
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
            SkillDescriptor(skill: square.targetCommandSpell!.toSkill(), jumpToDetail: false),
        ],
      ),
    );
    if (prevs.isNotEmpty || nexts.isNotEmpty) {
      children.add(
        TileGroup(
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
        ),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget buildEnhanceButton({
    required BuildContext context,
    required String title,
    required bool enabled,
    required List<ItemAmount> items,
    required VoidCallback onEnhance,
  }) {
    return IconButton(
      onPressed: !enabled
          ? null
          : () {
              SimpleConfirmDialog(
                title: Text(title),
                onTapOk: onEnhance,
                content: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: [
                      for (final amount in items)
                        Item.iconBuilder(
                          context: context,
                          item: null,
                          itemId: amount.itemId,
                          text: amount.amount.format(),
                          width: 48,
                        ),
                    ],
                  ),
                ),
              ).showDialog(context);
            },
      icon: const Icon(Icons.upgrade),
      tooltip: title,
    );
  }
}
