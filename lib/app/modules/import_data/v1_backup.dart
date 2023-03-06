import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/home/subpage/account_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class OldVersionDataImport extends StatefulWidget {
  OldVersionDataImport({super.key});

  @override
  State<OldVersionDataImport> createState() => _OldVersionDataImportState();
}

class _OldVersionDataImportState extends State<OldVersionDataImport> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: users.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${S.current.chaldea_backup} (v1)'),
          bottom: users.isEmpty
              ? null
              : FixedHeight.tabBar(TabBar(
                  tabs: users.map((e) => Tab(text: e.name)).toList(),
                  isScrollable: true,
                )),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(children: List.generate(users.length, (index) => _buildOneUser(users[index]))),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _importFile,
                  child: const Text('v1 userdata.json'),
                ),
                ElevatedButton(
                  onPressed: users.isEmpty
                      ? null
                      : () {
                          for (final user in users) {
                            user.name = db.userData.validUsername(user.name);
                            db.userData.users.add(user);
                          }
                          db.userData.curUserKey = db.userData.users.length - 1;
                          db.itemCenter.init();
                          db.saveUserData();
                          EasyLoading.showSuccess('Appended data to cur app');
                          router.push(child: AccountPage());
                        },
                  child: Text(
                    S.current.import_data,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  List<User> users = [];
  int _curPlanNo = 0;

  Widget _buildOneUser(User user) {
    return ListView(
      children: [
        ListTile(
          title: Text(S.current.game_account),
          trailing: Text(user.name),
        ),
        ListTile(
          title: Text(S.current.game_server),
          trailing: Text(user.region.localName),
        ),
        ListTile(title: Text(S.current.item)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SharedBuilder.itemGrid(context: context, items: user.items.entries, width: 42),
        ),
        ListTile(
          title: Text(S.current.servant),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('${user.servants.values.where((e) => e.favorite).length} favorite   '),
              DropdownButton<int>(
                value: _curPlanNo,
                items: List.generate(
                  user.plans.length,
                  (index) => DropdownMenuItem(value: index, child: Text('${S.current.plan} ${index + 1}')),
                ),
                onChanged: (v) {
                  _curPlanNo = v ?? _curPlanNo;
                  setState(() {});
                },
              )
            ],
          ),
        ),
        for (final id in List.of(user.servants.keys)..sort())
          if (user.servants[id]!.favorite)
            () {
              final svt = db.gameData.servantsNoDup[id];
              final status = user.servants[id]!;
              final cur = status.cur;
              final plan = user.plans.getOrNull(_curPlanNo)?.servants[id];
              return ListTile(
                leading: svt?.iconBuilder(context: context) ?? db.getIconImage(null),
                subtitle: Text('ID $id ${S.current.ascension_short} ${cur.ascension} NP ${cur.npLv}\n'
                    '${S.current.active_skill} ${cur.skills.join("/")} -> ${plan?.skills.join("/")} \n'
                    '${S.current.passive_skill} ${cur.appendSkills.join("/")}  -> ${plan?.appendSkills.join("/")}'),
              );
            }()
      ],
    );
  }

  Future _importFile() async {
    try {
      final result = await FilePickerU.pickFiles();
      final bytes = result?.files.first.bytes;
      if (bytes == null) return;
      users.clear();
      _curPlanNo = 0;
      final oldData = jsonDecode(utf8.decode(bytes));
      users = UserData.fromLegacy(oldData).users;
      if (mounted) setState(() {});
    } catch (e, s) {
      logger.e('import failed', e, s);
      EasyLoading.showError(e.toString());
    }
  }
}
