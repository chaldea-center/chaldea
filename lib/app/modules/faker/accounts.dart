import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/faker/cn/agent.dart';
import 'package:chaldea/models/faker/jp/agent.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'account_edit.dart';
import 'faker.dart';

class FakerAccountsPage extends StatefulWidget {
  const FakerAccountsPage({super.key});

  @override
  State<FakerAccountsPage> createState() => _FakerAccountsPageState();
}

class _FakerAccountsPageState extends State<FakerAccountsPage> {
  bool sorting = false;
  final fakerSettings = db.settings.fakerSettings;
  @override
  Widget build(BuildContext context) {
    final users = [...fakerSettings.jpAutoLogins, ...fakerSettings.cnAutoLogins];
    users.sort2((e) => e.priority);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fake/Grand Order'),
        centerTitle: false,
        actions: [
          if (!sorting)
            IconButton(
              onPressed: () {
                router.showDialog(
                  builder: (context) => SimpleDialog(
                    title: Text(S.current.game_server),
                    children: [
                      for (final region in [Region.jp, Region.cn, Region.na])
                        SimpleDialogOption(
                          onPressed: () {
                            switch (region) {
                              case Region.jp:
                              case Region.na:
                                fakerSettings.jpAutoLogins.add(AutoLoginDataJP(region: region));
                                break;
                              case Region.cn:
                                fakerSettings.cnAutoLogins.add(AutoLoginDataCN(region: region));
                                break;
                              case Region.tw:
                              case Region.kr:
                                EasyLoading.showError('Not supported');
                                return;
                            }
                            Navigator.pop(context);
                            if (mounted) setState(() {});
                          },
                          child: Text(region.upper),
                        )
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.add),
              tooltip: S.current.add,
            ),
          IconButton(
            onPressed: () {
              setState(() {
                sorting = !sorting;
              });
            },
            icon: Icon(sorting ? Icons.done : Icons.sort),
            tooltip: S.current.sort_order,
          ),
        ],
      ),
      body: sorting
          ? ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = users.removeAt(oldIndex);
                users.insert(newIndex, item);
                for (final (index, user) in users.indexed) {
                  user.priority = index + 1;
                }
                setState(() {});
              },
              children: [
                for (final user in users) itemBuilder(context, user),
              ],
            )
          : ListView.separated(
              itemCount: users.length,
              itemBuilder: (context, index) => itemBuilder(context, users[index]),
              separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16),
            ),
    );
  }

  Widget itemBuilder(BuildContext context, AutoLoginData user) {
    Widget child;
    switch (user) {
      case AutoLoginDataJP():
        child = buildJP(context, user);
      case AutoLoginDataCN():
        child = buildCN(context, user);
    }

    if (!sorting) {
      child = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: child),
          IconButton(
            onPressed: () {
              SimpleCancelOkDialog(
                title: Text(S.current.delete),
                onTapOk: () {
                  if (mounted) {
                    setState(() {
                      switch (user) {
                        case AutoLoginDataJP():
                          fakerSettings.jpAutoLogins.remove(user);
                        case AutoLoginDataCN():
                          fakerSettings.cnAutoLogins.remove(user);
                      }
                    });
                  }
                },
              ).showDialog(context);
            },
            icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            iconSize: 20,
          ),
        ],
      );
    }
    return child;
  }

  Widget buildJP(BuildContext context, AutoLoginDataJP user) {
    return ListTile(
      dense: true,
      key: ObjectKey(user),
      title: Text('[${user.region.upper}] ${user.userGame?.name}'),
      subtitle: Text(user.userGame?.friendCode ?? user.auth?.userId.toString() ?? 'null'),
      trailing: sorting
          ? null
          : IconButton(
              onPressed: () async {
                await router.pushPage(FakerAccountEditPage(user: user));
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.edit),
              iconSize: 20,
            ),
      onTap: () async {
        final top = (await showEasyLoading(AtlasApi.gametopsRaw))?.of(user.region);
        if (top == null) {
          EasyLoading.showError('fetch game data failed');
          return;
        }
        await router.pushPage(FakeGrandOrder(agent: FakerAgentJP.s(gameTop: top, user: user)));
      },
    );
  }

  Widget buildCN(BuildContext context, AutoLoginDataCN user) {
    return ListTile(
      dense: true,
      key: ObjectKey(user),
      title: Text('[${user.region.upper}-${user.gameServer.shownName}] ${user.nickname}'),
      subtitle: Text(user.userGame?.friendCode ?? "UID ${user.uid}"),
      trailing: sorting
          ? null
          : IconButton(
              onPressed: () async {
                await router.pushPage(FakerAccountEditPage(user: user));
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.edit),
              iconSize: 20,
            ),
      onTap: () async {
        final tops = await showEasyLoading(AtlasApi.gametopsRaw);
        if (tops == null) {
          EasyLoading.showError('fetch game data failed');
          return;
        }
        await router.pushPage(FakeGrandOrder(agent: FakerAgentCN.s(gameTop: tops.cn, user: user)));
      },
    );
  }
}

class FakerAccountsJPPage extends StatefulWidget {
  const FakerAccountsJPPage({super.key});

  @override
  State<FakerAccountsJPPage> createState() => _FakerAccountsJPPageState();
}

class _FakerAccountsJPPageState extends State<FakerAccountsJPPage> {
  @override
  Widget build(BuildContext context) {
    final users = db.settings.fakerSettings.jpAutoLogins;
    return ReorderableListPage(
      title: const Text('Fake/Grand Order'),
      items: users,
      onCreate: () => AutoLoginDataJP(),
      itemBuilder: (context, user, sorting) {
        return ListTile(
          dense: true,
          key: ObjectKey(user),
          title: Text('[${user.region.upper}] ${user.userGame?.name}'),
          subtitle: Text(user.userGame?.friendCode ?? user.auth?.userId.toString() ?? 'null'),
          trailing: sorting
              ? null
              : IconButton(
                  onPressed: () async {
                    await router.pushPage(FakerAccountEditPage(user: user));
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(Icons.edit),
                  iconSize: 20,
                ),
          onTap: () async {
            final top = (await showEasyLoading(AtlasApi.gametopsRaw))?.of(user.region);
            if (top == null) {
              EasyLoading.showError('fetch game data failed');
              return;
            }
            await router.pushPage(FakeGrandOrder(agent: FakerAgentJP.s(gameTop: top, user: user)));
          },
        );
      },
    );
  }
}

class FakerAccountsCNPage extends StatefulWidget {
  const FakerAccountsCNPage({super.key});

  @override
  State<FakerAccountsCNPage> createState() => _FakerAccountsCNPageState();
}

class _FakerAccountsCNPageState extends State<FakerAccountsCNPage> {
  @override
  Widget build(BuildContext context) {
    final users = db.settings.fakerSettings.cnAutoLogins;
    return ReorderableListPage(
      title: const Text('Fake/Bilili Order'),
      items: users,
      onCreate: () => AutoLoginDataCN(),
      itemBuilder: (context, user, sorting) {
        return ListTile(
          dense: true,
          key: ObjectKey(user),
          title: Text('[${user.gameServer.shownName}] ${user.nickname}'),
          subtitle: Text(user.userGame?.friendCode ?? "UID ${user.uid}"),
          trailing: sorting
              ? null
              : IconButton(
                  onPressed: () async {
                    await router.pushPage(FakerAccountEditPage(user: user));
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(Icons.edit),
                  iconSize: 20,
                ),
          onTap: () async {
            final tops = await showEasyLoading(AtlasApi.gametopsRaw);
            if (tops == null) {
              EasyLoading.showError('fetch game data failed');
              return;
            }
            await router.pushPage(FakeGrandOrder(agent: FakerAgentCN.s(gameTop: tops.cn, user: user)));
          },
        );
      },
    );
  }
}
