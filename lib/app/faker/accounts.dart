import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/home_widget.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'account_edit.dart';
import 'faker.dart';
import 'runtime.dart';

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
                        ),
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
          PopupMenuButton(
            itemBuilder: (context) => [
              if (HomeWidgetX.isSupported)
                PopupMenuItem(
                  child: Text("Update Widgets"),
                  onTap: () async {
                    try {
                      final result = await HomeWidgetX.saveFakerStatus();
                      final result2 = await HomeWidgetX.updateFakerStatus();
                      EasyLoading.showToast('save: $result\nupdate: $result2');
                    } catch (e, s) {
                      logger.e('save and update faker widgets failed', e, s);
                      EasyLoading.showError(e.toString());
                    }
                  },
                ),
              PopupMenuItem(
                child: Text('Clear ${FakerRuntime.runtimes.length} Runtimes'),
                onTap: () {
                  FakerRuntime.runtimes.clear();
                },
              ),
            ],
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
              children: [for (final user in users) itemBuilder(context, user)],
            )
          : ListView.separated(
              itemCount: users.length + 1,
              itemBuilder: (context, index) {
                if (index < users.length) {
                  return itemBuilder(context, users[index]);
                }
                return buildButtons(users);
              },
              separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16),
            ),
    );
  }

  Widget itemBuilder(BuildContext context, AutoLoginData user) {
    Widget child = buildOne(context: context, user: user);

    if (!sorting) {
      child = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: child),
          IconButton(
            onPressed: () {
              SimpleConfirmDialog(
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

  Widget buildOne({required BuildContext context, required AutoLoginData user}) {
    return ListTile(
      dense: true,
      key: ObjectKey(user),
      title: Text('[${user.serverName}] ${user.userGame?.name}'),
      subtitle: Text(user.userGame?.friendCode ?? 'null'),
      contentPadding: const EdgeInsetsDirectional.only(start: 16),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TimerUpdate(
            duration: Duration(seconds: 60),
            builder: (context, _) => user.userGame == null
                ? SizedBox.shrink()
                : Text(
                    '${user.userGame?.calCurAp()}/${user.userGame?.actMax}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
          ),
          if (!sorting)
            IconButton(
              onPressed: () async {
                await router.pushPage(
                  FakerAccountEditPage(
                    user: user,
                    onImportJson: (data) {
                      AutoLoginData newUser;
                      List<AutoLoginData> userList;
                      switch (user) {
                        case AutoLoginDataJP():
                          userList = fakerSettings.jpAutoLogins;
                          newUser = AutoLoginDataJP.fromJson(data);
                        case AutoLoginDataCN():
                          userList = fakerSettings.cnAutoLogins;
                          newUser = AutoLoginDataCN.fromJson(data);
                      }
                      userList[userList.indexOf(user)] = newUser;
                      return newUser;
                    },
                  ),
                );
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.edit),
              iconSize: 20,
            ),
        ],
      ),
      onTap: sorting
          ? null
          : () async {
              router.pushPage(FakeGrandOrder(user: user));
            },
    );
  }

  Widget buildButtons(List<AutoLoginData> users) {
    List<Widget> buttons = [
      FilledButton.icon(
        onPressed: users.length <= 1
            ? null
            : () async {
                await showEasyLoading(AtlasApi.gametopsRaw);
                for (final (index, user) in users.indexed) {
                  if (index != 0) {
                    rootRouter.appState.addWindow();
                    await Future.delayed(const Duration(milliseconds: 100));
                  }
                  router.pushPage(FakeGrandOrder(user: user));
                  await Future.delayed(const Duration(milliseconds: 400));
                }
              },
        label: const Text('Open All'),
        icon: const Icon(Icons.select_all),
      ),
    ];
    return Column(mainAxisSize: MainAxisSize.min, spacing: 4, children: buttons);
  }
}
