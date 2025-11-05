import 'dart:math';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/api/cache.dart' show kExpireCacheOnly;
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/routes/delegate.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/faker/faker.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '_shared/history.dart';
import '_shared/menu_button.dart';
import 'runtimes/battle.dart';
import 'runtimes/combine.dart';
import 'runtimes/event.dart';
import 'runtimes/gacha.dart';

part '_shared/cond.dart';

class FakerRuntime {
  static final Map<AutoLoginData, FakerRuntime> runtimes = {};
  static final Set<Object> _awakeTasks = {};

  final FakerAgent agent;
  final _FakerGameData gameData;
  FakerRuntime._(this.agent) : gameData = _FakerGameData(agent.user.region);

  final runningTask = ValueNotifier<bool>(false);
  final activeToast = ValueNotifier<String?>(null);
  // common
  late final mstData = agent.network.mstData;
  late final agentData = agent.network.agentData;
  late final condCheck = FakerCondCheck(this);
  // runtimes
  late final battle = FakerRuntimeBattle(this);
  late final combine = FakerRuntimeCombine(this);
  late final gacha = FakerRuntimeGacha(this);
  late final event = FakerRuntimeEvent(this);

  Region get region => agent.user.region;

  final Map<State, bool> _dependencies = {}; // <state, isRoot>

  BuildContext? get context => _dependencies.keys.firstWhereOrNull((e) => e.mounted)?.context;
  bool get mounted => context != null;
  bool get hasMultiRoots => _dependencies.values.where((e) => e).length > 1;

  void addDependency(State s) {
    if (!_dependencies.containsKey(s)) _dependencies[s] = false;
  }

  void removeDependency(State s) {
    _dependencies.remove(s);
  }

  void update() async {
    await null; // in case called during parent build?
    for (final s in _dependencies.keys) {
      if (s.mounted) {
        // ignore: invalid_use_of_protected_member
        s.setState(() {});
      }
    }
  }

  // builders

  void displayToast(String? msg, {double? progress}) {
    activeToast.value = msg;
    if (db.settings.fakerSettings.showProgressToast) {
      if (progress == null) {
        EasyLoading.show(status: msg);
      } else {
        EasyLoading.showProgress(progress, status: msg);
      }
    }
  }

  void dismissToast() {
    activeToast.value = null;
    EasyLoading.dismiss();
  }

  Future<T?> showLocalDialog<T>(Widget child, {bool barrierDismissible = true}) async {
    BuildContext? ctx;
    for (final state in _dependencies.keys) {
      if (state.mounted && AppRouter.of(state.context) == router) {
        ctx = state.context;
      }
    }
    if (ctx == null) {
      for (final state in _dependencies.keys) {
        if (state.mounted) {
          ctx = state.context;
        }
      }
    }
    if (ctx == null) return null;
    return child.showDialog(ctx, barrierDismissible: barrierDismissible);
  }

  Widget buildHistoryButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        router.pushPage(FakerHistoryViewer(agent: agent));
      },
      icon: const Icon(Icons.history),
      tooltip: S.current.history,
    );
  }

  Widget buildMenuButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        router.showDialog(builder: (context) => FakerMenuButton(runtime: this));
      },
      icon: Icon(Icons.grid_view_rounded),
      tooltip: 'Menu',
    );
  }

  Widget buildCircularProgress({
    required BuildContext context,
    double size = 16,
    bool showElapsed = false,
    Color? activeColor,
    Color? inactiveColor,
    EdgeInsetsGeometry? padding,
  }) {
    return ValueListenableBuilder(
      valueListenable: runningTask,
      builder: (context, running, _) {
        double? value;
        if (running) {
          final offstageParent = context.findAncestorWidgetOfExactType<Offstage>();
          if (offstageParent != null && offstageParent.offstage) {
            value = 0.5;
          }
        } else {
          value = 1.0;
        }
        Widget child = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: size, maxHeight: size),
          child: CircularProgressIndicator(
            value: value,
            color: running ? (activeColor ?? Colors.red) : (inactiveColor ?? Colors.green),
          ),
        );
        if (showElapsed) {
          child = Stack(
            alignment: Alignment.center,
            children: [
              child,
              if (running)
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: size, maxHeight: size),
                  child: TimerUpdate(
                    builder: (context, t) {
                      final startedAt = agent.network.lastTaskStartedAt;
                      final dt = min(99, t.timestamp - startedAt);
                      if (startedAt <= 0 || dt < 0) return const SizedBox.shrink();
                      return Text(dt.toString(), style: TextStyle(fontSize: 10), textAlign: TextAlign.center);
                    },
                  ),
                ),
            ],
          );
        }
        if (padding != null) child = Padding(padding: padding, child: child);
        return child;
      },
    );
  }

  // init

  static Future<FakerRuntime> init(AutoLoginData user, State state) async {
    final top = (await showEasyLoading(AtlasApi.gametopsRaw))?.of(user.region);
    if (top == null) {
      throw SilentException('fetch game data failed');
    }

    if (!state.mounted) {
      throw SilentException('Context already disposed');
    }

    FakerRuntime runtime = runtimes.putIfAbsent(user, () {
      final FakerAgent agent = switch (user) {
        AutoLoginDataJP() => FakerAgentJP.s(gameTop: top, user: user),
        AutoLoginDataCN() => FakerAgentCN.s(gameTop: top, user: user),
      };
      return FakerRuntime._(agent);
    });
    runtime.agent.network.addListener(runtime.update);
    runtime._dependencies[state] = true;
    return runtime;
  }

  Future<void> loadInitData() async {
    await gameData.init(gameTop: agent.network.gameTop);
    update();
  }

  // task

  void lockTask(VoidCallback callback) {
    if (runningTask.value) {
      showLocalDialog(
        SimpleConfirmDialog(
          title: Text(S.current.error),
          content: const Text("task is till running"),
          showCancel: false,
        ),
      );
      return;
    }
    callback();
    update();
  }

  Future<void> runTask(Future Function() task, {bool check = true}) async {
    if (check && runningTask.value) {
      showLocalDialog(
        SimpleConfirmDialog(
          title: Text(S.current.error),
          content: const Text("previous task is till running"),
          showCancel: false,
        ),
      );
      return;
    }
    try {
      if (isBuildingWidget) {
        await null;
      }
      if (check) runningTask.value = true;
      displayToast('running task...');
      update();
      await task();
      dismissToast();
    } catch (e, s) {
      logger.e('task failed', e, s);
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        dismissToast();
        showLocalDialog(
          SimpleConfirmDialog(
            title: Text(S.current.error),
            scrollable: true,
            content: Text(e is SilentException ? e.message.toString() : e.toString()),
            showCancel: false,
          ),
          barrierDismissible: false,
        );
      } else {
        EasyLoading.showError(e.toString());
      }
    } finally {
      if (check) runningTask.value = false;
    }
    update();
  }

  Future<T> withWakeLock<T>(Object tag, Future<T> Function() task) async {
    try {
      WakelockPlus.enable();
      _awakeTasks.add(tag);
      return await task();
    } finally {
      _awakeTasks.remove(tag);
      if (_awakeTasks.isEmpty) {
        WakelockPlus.disable();
      }
    }
  }

  // agents

  // helpers

  void checkStop() {
    if (agent.network.stopFlag) {
      agent.network.stopFlag = false;
      throw SilentException('Manual Stop');
    }
  }

  void checkSvtKeep() {
    final counts = mstData.countSvtKeep();
    final user = mstData.user!;
    if (counts.svtCount >= user.svtKeep) {
      throw SilentException('${S.current.servant}: ${counts.svtCount}>=${user.svtKeep}');
    }
    if (counts.svtEquipCount >= user.svtEquipKeep) {
      throw SilentException('${S.current.craft_essence}: ${counts.svtEquipCount}>=${user.svtEquipKeep}');
    }
    if (counts.ccCount >= gameData.timerData.constants.maxUserCommandCode) {
      throw SilentException(
        '${S.current.command_code}: ${counts.ccCount}>=${gameData.timerData.constants.maxUserCommandCode}',
      );
    }
  }
}

mixin FakerRuntimeStateMixin<T extends StatefulWidget> on State<T> {
  FakerRuntime get runtime;
  FakerAgent get agent => runtime.agent;
  MasterDataManager get mstData => runtime.mstData;

  @override
  void initState() {
    super.initState();
    runtime.addDependency(this);
  }

  @override
  void dispose() {
    super.dispose();
    runtime.removeDependency(this);
  }
}

class _FakerGameData {
  final Region region;
  _FakerGameData(this.region);

  GameTimerData timerData = GameTimerData();

  Map<int, Item> get teapots {
    final now = DateTime.now().timestamp;
    return {
      for (final item in timerData.items.values)
        if (item.type == ItemType.friendshipUpItem && item.endedAt > now) item.id: item,
    };
  }

  Future<void> init({GameTop? gameTop, bool refresh = false}) async {
    GameTimerData? _timerData;
    if (gameTop != null && !refresh) {
      final localTimerData = await AtlasApi.timerData(region, expireAfter: kExpireCacheOnly);
      if (localTimerData != null && localTimerData.updatedAt > DateTime.now().timestamp - 3 * kSecsPerDay) {
        if (localTimerData.hash != null && localTimerData.hash == gameTop.hash) {
          _timerData = localTimerData;
        }
      }
    }
    _timerData ??= await AtlasApi.timerData(region, expireAfter: refresh ? Duration.zero : null);
    timerData = _timerData ?? timerData;
  }
}
