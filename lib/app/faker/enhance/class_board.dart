import 'dart:math' show pi;

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_tables.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../runtime.dart';

enum ClassBoardSquareState { available, unreleased, released, blank }

class ClassBoardRules {
  final ClassBoard board;
  final Set<int> enhancedSquares;
  final Set<int> unlockedSquares;
  final bool Function(ClassBoardLock) isLockOpen;
  late final _squares = {for (final square in board.squares) square.id: square};
  late final _previous = <int, List<int>>{};

  ClassBoardRules({required this.board, UserClassBoardSquareEntity? progress, required this.isLockOpen})
    : enhancedSquares = {...?progress?.classBoardSquareIds},
      unlockedSquares = {...?progress?.classBoardUnlockSquareIds} {
    for (final line in board.lines) {
      _previous.putIfAbsent(line.nextSquareId, () => []).add(line.prevSquareId);
    }
  }

  static bool isBlank(ClassBoardSquare square) => square.flags.contains(ClassBoardSquareFlag.blank);

  bool isReleased(ClassBoardSquare square) =>
      !isBlank(square) && (square.lock == null ? enhancedSquares : unlockedSquares).contains(square.id);

  double get completionProgress {
    final squares = board.squares.where((square) => !isBlank(square));
    final total = squares.length;
    return total == 0 ? 0 : squares.where(isReleased).length / total;
  }

  bool get isComplete => completionProgress == 1;

  bool _isPathOpen(ClassBoardSquare square, Set<int> visiting) {
    if (!visiting.add(square.id)) return false;
    final result = (_previous[square.id] ?? const <int>[]).every((id) {
      final previous = _squares[id];
      if (previous == null) return false;
      return isBlank(previous) ? _isPathOpen(previous, visiting) : isReleased(previous);
    });
    visiting.remove(square.id);
    return result;
  }

  // Material ownership affects submission, not the square's availability group.
  ClassBoardSquareState stateOf(ClassBoardSquare square) {
    if (isBlank(square)) return ClassBoardSquareState.blank;
    if (isReleased(square)) return ClassBoardSquareState.released;
    if (_isPathOpen(square, {}) && (square.lock == null || isLockOpen(square.lock!))) {
      return ClassBoardSquareState.available;
    }
    return ClassBoardSquareState.unreleased;
  }

  static List<ItemAmount> costOf(ClassBoardSquare square) => square.lock?.items ?? square.items;

  bool canRelease(ClassBoardSquare square, int Function(int) stockOf) {
    if (stateOf(square) != ClassBoardSquareState.available) return false;
    final costs = <int, int>{};
    for (final cost in costOf(square)) {
      costs.update(cost.itemId, (value) => value + cost.amount, ifAbsent: () => cost.amount);
    }
    return costs.entries.every((entry) => stockOf(entry.key) >= entry.value);
  }

  List<ClassBoardSquare> get sortedSquares => board.squares.toList()
    ..sort((a, b) {
      final group = stateOf(a).index.compareTo(stateOf(b).index);
      return group == 0 ? a.id.compareTo(b.id) : group;
    });

  ({int released, int total}) count({required bool locks}) {
    final squares = board.squares.where((square) => !isBlank(square) && (square.lock != null) == locks);
    return (released: squares.where(isReleased).length, total: squares.length);
  }
}

class _ClassBoardCompletionIcon extends StatelessWidget {
  final double progress;
  const _ClassBoardCompletionIcon({required this.progress});

  @override
  Widget build(BuildContext context) {
    if (progress >= 1) {
      return Icon(
        Icons.check_circle,
        size: 20,
        color: ExtraThemeData.of(context).stateSuccess,
        semanticLabel: S.current.done,
      );
    }
    return Semantics(
      label: S.current.progress,
      value: '${(progress * 100).format(precision: 1)}%',
      child: CustomPaint(
        size: const Size.square(20),
        painter: _ClassBoardProgressPainter(progress: progress, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _ClassBoardProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _ClassBoardProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    canvas.drawCircle(
      center,
      radius * 0.82,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.16,
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.62),
        -pi / 2,
        2 * pi * progress,
        true,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_ClassBoardProgressPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

class _ClassBoardProgress extends StatelessWidget {
  final ClassBoardRules rules;
  const _ClassBoardProgress({required this.rules});

  @override
  Widget build(BuildContext context) {
    final skills = rules.count(locks: false), locks = rules.count(locks: true);
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _ClassBoardCompletionIcon(progress: rules.completionProgress),
        Text('${S.current.skill}: ${skills.released}/${skills.total}'),
        if (locks.total > 0) ...[const Text('·'), Text('${S.current.unlock}: ${locks.released}/${locks.total}')],
      ],
    );
  }
}

class FakerClassBoardListPage extends StatefulWidget {
  final FakerRuntime runtime;
  const FakerClassBoardListPage({super.key, required this.runtime});

  @override
  State<FakerClassBoardListPage> createState() => _FakerClassBoardListPageState();
}

class _FakerClassBoardListPageState extends State<FakerClassBoardListPage> with FakerRuntimeStateMixin {
  @override
  late final runtime = widget.runtime;

  @override
  Widget build(BuildContext context) {
    final boards = db.gameData.classBoards.values.toList()
      ..sort((a, b) {
        if (a.isGrand != b.isGrand) return a.isGrand ? 1 : -1;
        return a.id.compareTo(b.id);
      });
    return Scaffold(
      appBar: AppBar(title: Text(S.current.class_board), actions: [runtime.buildMenuButton(context)]),
      body: ListView.separated(
        itemCount: boards.length,
        separatorBuilder: (_, _) => kDefaultDivider,
        itemBuilder: (context, index) {
          final board = boards[index];
          final rules = ClassBoardRules(
            board: board,
            progress: mstData.userClassBoardSquare[board.id],
            isLockOpen: (_) => false,
          );
          return ListTile(
            leading: db.getIconImage(board.btnIcon, width: 40, aspectRatio: 1),
            title: Text(board.dispName),
            subtitle: _ClassBoardProgress(rules: rules),
            trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
            onTap: () => router.pushPage(FakerClassBoardDetailPage(runtime: runtime, board: board)),
          );
        },
      ),
    );
  }
}

class FakerClassBoardDetailPage extends StatefulWidget {
  final FakerRuntime runtime;
  final ClassBoard board;
  const FakerClassBoardDetailPage({super.key, required this.runtime, required this.board});

  @override
  State<FakerClassBoardDetailPage> createState() => _FakerClassBoardDetailPageState();
}

class _FakerClassBoardDetailPageState extends State<FakerClassBoardDetailPage> with FakerRuntimeStateMixin {
  @override
  late final runtime = widget.runtime;
  ClassBoard get board => widget.board;

  ClassBoardRules get _rules => ClassBoardRules(
    board: board,
    progress: mstData.userClassBoardSquare[board.id],
    isLockOpen: (lock) => runtime.condCheck.isCondOpen(lock.condType, lock.condTargetId, lock.condNum) == true,
  );

  String _squareName(ClassBoardSquare square) {
    final name = square.targetSkill?.name ?? square.targetCommandSpell?.name;
    if (name != null) return Transl.skillNames(name).l;
    if (square.lock != null) return S.current.unlock;
    return '—';
  }

  Widget _cost(ClassBoardSquare square) => Wrap(
    spacing: 8,
    runSpacing: 4,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      for (final cost in ClassBoardRules.costOf(square))
        Item.iconBuilder(
          context: context,
          item: cost.item,
          itemId: cost.itemId,
          width: 36,
          text: '${cost.amount.format()}\n${mstData.getItemOrSvtNum(cost.itemId).format()}',
          option: mstData.getItemOrSvtNum(cost.itemId) < cost.amount
              ? ImageWithTextOption(textStyle: TextStyle(color: Theme.of(context).colorScheme.error))
              : null,
        ),
    ],
  );

  Future<void> _release(ClassBoardSquare square) async {
    if (runtime.runningTask.value || !_rules.canRelease(square, mstData.getItemOrSvtNum)) return;
    if (square.lock != null) {
      final confirmed = await SimpleConfirmDialog(
        title: Text('${S.current.unlock} · ${board.dispName} · No.${square.id}'),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(S.current.enhance_warning), const SizedBox(height: 8), _cost(square)],
        ),
      ).showDialog(context);
      if (confirmed != true || !mounted || runtime.runningTask.value) return;
    }
    await runtime.runTask(() async {
      // Confirmation may outlive a stock or progress update from another Faker task.
      if (!_rules.canRelease(square, mstData.getItemOrSvtNum)) return;
      if (square.lock != null) {
        await agent.classBoardReleaseLock(classBoardBaseId: board.id, squareId: square.id);
      } else {
        await agent.classBoardReleaseSquare(classBoardBaseId: board.id, squareId: square.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rules = _rules;
    final squares = rules.sortedSquares;
    return Scaffold(
      appBar: AppBar(
        title: Text(board.dispName),
        actions: [
          runtime.buildCircularProgress(context: context, padding: const EdgeInsets.all(12)),
          runtime.buildMenuButton(context),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: _ClassBoardProgress(rules: rules),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: squares.length,
              separatorBuilder: (_, _) => kDefaultDivider,
              itemBuilder: (context, index) {
                final square = squares[index];
                final state = rules.stateOf(square);
                final lock = square.lock;
                return ListTile(
                  key: ValueKey(square.id),
                  contentPadding: const .directional(start: 16, end: 8),
                  leading: square.dispIcon == null
                      ? const SizedBox(width: 32)
                      : db.getIconImage(square.dispIcon, width: 32, aspectRatio: 1),
                  title: Text('${square.id}. ${_squareName(square)}'),
                  subtitle: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cost(square),
                      if (lock != null && !rules.isReleased(square) && !rules.isLockOpen(lock))
                        CondTargetValueDescriptor(
                          condType: lock.condType,
                          target: lock.condTargetId,
                          value: lock.condNum,
                        ),
                    ],
                  ),
                  trailing: SizedBox(
                    width: kMinInteractiveDimension,
                    child: Center(
                      heightFactor: 1,
                      child: switch (state) {
                        ClassBoardSquareState.released => const _ClassBoardCompletionIcon(progress: 1),
                        ClassBoardSquareState.blank => null,
                        _ => IconButton(
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: !runtime.runningTask.value && rules.canRelease(square, mstData.getItemOrSvtNum)
                              ? () => _release(square)
                              : null,
                          tooltip: lock == null ? S.current.enhance : S.current.unlock,
                          icon: Icon(lock == null ? Icons.auto_awesome_outlined : Icons.key_outlined),
                        ),
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
