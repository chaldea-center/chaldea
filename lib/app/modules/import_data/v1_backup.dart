import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/home/subpage/account_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';

class OldVersionDataImport extends StatefulWidget {
  OldVersionDataImport({Key? key}) : super(key: key);

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
          title: const Text('Backup from V1'),
          actions: [
            IconButton(
              onPressed: _importFile,
              icon: const FaIcon(FontAwesomeIcons.fileImport),
              tooltip: S.current.import_source_file,
            ),
          ],
          bottom: users.isEmpty
              ? null
              : TabBar(
                  tabs: users.map((e) => Tab(text: e.name)).toList(),
                  isScrollable: true,
                ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                  children: List.generate(
                      users.length, (index) => _buildOneUser(users[index]))),
            ),
            if (users.isNotEmpty)
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      for (final user in users) {
                        user.name = db.userData.validUsername(user.name);
                        db.userData.users.add(user);
                      }
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
          title: const Text('Name'),
          trailing: Text(user.name),
        ),
        ListTile(
          title: const Text('Region'),
          trailing: Text(user.region.localName),
        ),
        ListTile(title: Text(S.current.item)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SharedBuilder.itemGrid(
              context: context, items: user.items.entries, width: 42),
        ),
        ListTile(
          title: Text(S.current.servant),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                  '${user.servants.values.where((e) => e.favorite).length} favorite   '),
              DropdownButton<int>(
                value: _curPlanNo,
                items: List.generate(
                  user.svtPlanGroups.length,
                  (index) => DropdownMenuItem(
                      value: index, child: Text('Plan ${index + 1}')),
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
              final svt = db.gameData.servants[id];
              final status = user.servants[id]!;
              final cur = status.cur;
              final plan = user.svtPlanGroups.getOrNull(_curPlanNo)?[id];
              return ListTile(
                leading:
                    svt?.iconBuilder(context: context) ?? db.getIconImage(null),
                subtitle: Text(
                    'ID $id ${S.current.ascension_short} ${cur.ascension} NP ${cur.npLv}\n'
                    '${S.current.active_skill} ${cur.skills.join("/")} -> ${plan?.skills.join("/")} \n'
                    '${S.current.passive_skill} ${cur.appendSkills.join("/")}  -> ${plan?.appendSkills.join("/")}'),
              );
            }()
      ],
    );
  }

  Future _importFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(withData: true);
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
