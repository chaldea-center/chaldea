import 'package:flutter/foundation.dart';

import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/network.dart';
import 'package:chaldea/utils/img_util.dart';
import 'package:chaldea/widgets/widgets.dart';

class StartupLoadingPage extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onFailed;
  StartupLoadingPage({super.key, required this.onSuccess, required this.onFailed});

  @override
  State<StartupLoadingPage> createState() => _StartupLoadingPageState();
}

class _StartupLoadingPageState extends State<StartupLoadingPage> {
  final _loader = GameDataLoader.instance;
  String? hint;
  DateTime startTime = DateTime.now();

  bool onlineUpdate =
      network.available && !kDebugMode && db.settings.autoUpdateData && (db.settings.updateDataBeforeStart || kIsWeb);
  bool needBackgroundUpdate = !kIsWeb && db.settings.autoUpdateData;

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  Future _updateData() async {
    startTime = DateTime.now();
    Future.delayed(const Duration(seconds: 32), () {
      if (mounted) setState(() {});
    });
    GameData? data = await _loader.reload(
      offline: !onlineUpdate,
      silent: true,
      connectTimeout: onlineUpdate ? const Duration(seconds: 5) : null,
    );
    if (onlineUpdate && data == null) {
      hint = 'Loading local cache...';
      needBackgroundUpdate = false;
      if (mounted) setState(() {});
      data = await _loader.reload(offline: true, silent: true);
    }
    if (data != null) {
      db.gameData = data;
      widget.onSuccess.call();
      // rootRouter.appState.dataReady = true;
      if (needBackgroundUpdate && network.available && kReleaseMode) {
        await Future.delayed(const Duration(seconds: 3));
        await _loader.reload(silent: true);
      }
    } else {
      widget.onFailed.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget img = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ImageUtil.getChaldeaBackground(context),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Center(child: img)),
        const SizedBox(height: 12),
        ValueListenableBuilder<int>(
          valueListenable: _loader.downloading,
          builder: ((context, value, child) {
            bool showHint = onlineUpdate && value > 0 && DateTime.now().difference(startTime).inSeconds > 30;
            showHint = showHint || hint != null;
            return Text.rich(
              TextSpan(
                children:
                    showHint
                        ? [
                          TextSpan(text: hint ?? 'Updating '),
                          CenterWidgetSpan(
                            child: IconButton(
                              onPressed: () {
                                _loader.interrupt();
                                setState(() {});
                              },
                              color: Theme.of(context).colorScheme.primaryContainer,
                              icon: const Icon(Icons.clear),
                              iconSize: 12,
                            ),
                          ),
                        ]
                        : [const TextSpan(text: '  ')],
              ),
              textAlign: TextAlign.center,
            );
          }),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<double?>(
          valueListenable: _loader.progress,
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value ?? 0,
              color: Theme.of(context).primaryColorLight,
              backgroundColor: Colors.transparent,
            );
          },
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}
