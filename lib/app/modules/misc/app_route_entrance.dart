import 'package:flutter/services.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/routes/delegate.dart';
import 'package:chaldea/app/routes/root_delegate.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widgets.dart';

class AppRouteEntrancePage extends StatefulWidget {
  const AppRouteEntrancePage({super.key});

  @override
  State<AppRouteEntrancePage> createState() => _AppRouteEntrancePageState();
}

class _AppRouteEntrancePageState extends State<AppRouteEntrancePage> {
  // Routes.shopsPrefix, // enum
  // Routes.script, // string

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routes'),
        actions: [
          IconButton(
            onPressed: () {
              router.pushPage(const RouteHistoryList());
            },
            icon: const Icon(Icons.history),
            tooltip: S.current.history,
          )
        ],
      ),
      body: ListView(
        children: [
          _custom(),
          _int(S.current.servant, Routes.servant),
          _int(S.current.craft_essence, Routes.craftEssence),
          _int(S.current.quest, Routes.quest),
          _int(S.current.skill, Routes.skill),
          _int(S.current.noble_phantasm, Routes.td),
          _int('Function', Routes.func),
          _int('Buff', Routes.buff),
          _int(S.current.command_code, Routes.commandCode),
          _int(S.current.mystic_code, Routes.mysticCode),
          _int(S.current.event, Routes.event),
          _int(S.current.war, Routes.war),
          _int(S.current.enemy, Routes.enemy),
          _int(S.current.item, Routes.item),
          _int(S.current.summon_banner, Routes.summon),
          _int(S.current.costume, Routes.costume),
          _int(S.current.bgm, Routes.bgm),
          _int(S.current.trait, Routes.trait),
          _int("Svt AI", Routes.svtAi),
          _int("Field AI", Routes.fieldAi),
          // _int(S.current.master_mission, Routes.masterMission),
          _int(S.current.shop, Routes.shop),
          _int('Common Release', Routes.commonReleasePrefix),
        ],
      ),
    );
  }

  final Map<String, TextEditingController> _controllers = {};

  Widget _custom() {
    final c = _controllers['/'] ??= TextEditingController();
    String v = c.text.trim().trimCharLeft('/').trim();
    return ListTile(
      dense: true,
      title: TextFormField(
        decoration: InputDecoration(
          hintText: '${S.current.general_custom} e.g. /servant/xxx',
          helperText: 'OR https://chaldea.center/free-calc',
        ),
        controller: c,
        onChanged: (value) {
          setState(() {});
        },
        onFieldSubmitted: (s) => goTo(s),
      ),
      trailing: IconButton(
        onPressed: v.isEmpty ? null : () => goTo(v),
        icon: const Icon(Icons.keyboard_double_arrow_right),
        tooltip: 'GO!',
      ),
    );
  }

  Widget _int(String title, String path) {
    final c = _controllers[path] ??= TextEditingController();
    final v = int.tryParse(c.text);
    return ListTile(
      dense: true,
      title: Text(title),
      subtitle: Text('$path/${v ?? "{id}"}'),
      trailing: Wrap(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: (c.text.length * 12.0).clamp(80, 160)),
            child: TextFormField(
              decoration: const InputDecoration(
                isDense: true,
              ),
              controller: c,
              onChanged: (value) {
                setState(() {});
              },
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              onFieldSubmitted: (s) {
                final v = int.tryParse(s);
                if (v != null) router.push(url: '$path/$v');
              },
            ),
          ),
          IconButton(
            onPressed: v == null ? null : () => router.push(url: '$path/$v'),
            icon: const Icon(Icons.keyboard_double_arrow_right),
            tooltip: 'GO!',
          )
        ],
      ),
    );
  }

  void goTo(String route) {
    route = route.trim();
    if (route.isEmpty || route.trimChar('/').isEmpty) return;
    router.push(url: route);
  }

  @override
  void dispose() {
    super.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
  }
}

class RouteHistoryList extends StatelessWidget {
  const RouteHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.history)),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final url = AppRouterDelegate.urlHistory[AppRouterDelegate.urlHistory.length - 1 - index];
          return ListTile(
            dense: true,
            title: Text(url),
            onTap: () {
              rootRouter.appState.activeRouter.push(url: url);
              rootRouter.appState.windowState = WindowStateEnum.single;
            },
          );
        },
        itemCount: AppRouterDelegate.urlHistory.length,
      ),
    );
  }
}
