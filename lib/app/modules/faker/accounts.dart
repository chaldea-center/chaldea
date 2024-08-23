import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/faker/cn/agent.dart';
import 'package:chaldea/models/faker/jp/agent.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'account_edit.dart';
import 'faker.dart';

class FakerAccountsJPPage extends StatefulWidget {
  const FakerAccountsJPPage({super.key});

  @override
  State<FakerAccountsJPPage> createState() => _FakerAccountsJPPageState();
}

class _FakerAccountsJPPageState extends State<FakerAccountsJPPage> {
  @override
  Widget build(BuildContext context) {
    final users = db.settings.jpAutoLogins;
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
    final users = db.settings.cnAutoLogins;
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
