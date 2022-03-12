import 'dart:convert';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/home/subpage/account_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/models/models.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
              : TabBar(tabs: users.map((e) => Tab(text: e.name)).toList()),
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
                      db2.userData.users.addAll(users);
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
          trailing: Text(user.region.toUpper()),
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
              final svt = db2.gameData.servants[id];
              final status = user.servants[id]!;
              final cur = status.cur;
              final plan = user.svtPlanGroups.getOrNull(_curPlanNo)?[id];
              return ListTile(
                leading: svt?.iconBuilder(context: context) ??
                    db2.getIconImage(null),
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
      Map<String, int> itemNameMap = {};
      for (final item in db2.gameData.items.values) {
        itemNameMap[item.lName.cn] = item.id;
      }
      for (final oldUser
          in Map<String, Map<String, dynamic>>.from(oldData['users']!).values) {
        Map<int, SvtStatus> statuses = {};
        List<Map<int, SvtPlan>> svtPlanGroups = [];
        for (final String idStr in Map.from(oldUser['servants'] ?? {}).keys) {
          final id = int.parse(idStr);
          final oldStatus =
              Map<String, dynamic>.from(oldUser['servants']?[idStr]);
          statuses[id] = SvtStatus(
            cur: _convertPlan(oldStatus['curVal'], oldStatus['npLv']),
            coin: (oldStatus['coin'] as int?) ?? 0,
            priority: (oldStatus['priority'] as int?) ?? 1,
            equipCmdCodes:
                List.from((oldStatus['equipCmdCodes'] as List?) ?? []),
          );
        }
        print(
            'user ${oldUser['name']}: ${oldUser['servantPlans']?.length} plans');
        for (final svtPlans in List<Map<String, dynamic>>.from(
            (oldUser['servantPlans'] ?? []))) {
          svtPlanGroups.add(svtPlans.map((key, value) =>
              MapEntry(int.parse(key), _convertPlan(value, null))));
        }
        final user = User(
          name: oldUser['name'] ?? 'unknown',
          isGirl: (oldUser['isMasterGirl'] as bool?) ?? true,
          use6thDrops: (oldUser['use6thDropRate'] as bool?) ?? true,
          region: {
                'jp': Region.jp,
                'cn': Region.cn,
                'tw': Region.tw,
                'en': Region.na
              }[oldUser['server']] ??
              Region.jp,
          servants: statuses,
          svtPlanGroups: svtPlanGroups,
          curSvtPlanNo: 0,
          planNames: null,
          items: {},
          events: null,
          mainStories: null,
          exchangeTickets: null,
          craftEssences: null,
          mysticCodes: null,
          summons: null,
          freeLPParams: null,
        );
        for (final entry
            in Map<String, int>.from(oldUser['items'] ?? {}).entries) {
          if (itemNameMap.containsKey(entry.key)) {
            user.items[itemNameMap[entry.key]!] = entry.value;
          }
        }
        user.validate();
        users.add(user);
      }
      if (mounted) setState(() {});
    } catch (e, s) {
      logger.e('import failed', e, s);
      EasyLoading.showError(e.toString());
    }
  }

  SvtPlan _convertPlan(Map<String, dynamic>? oldPlan, int? npLv) {
    if (oldPlan == null) return SvtPlan();
    return SvtPlan(
      favorite: (oldPlan['favorite'] as bool?) ?? false,
      ascension: (oldPlan['ascension'] as int?) ?? 0,
      skills: List.generate(
          3, (index) => (oldPlan['skills'] as List?)?.getOrNull(index) ?? 0),
      appendSkills: List.generate(3,
          (index) => (oldPlan['appendSkills'] as List?)?.getOrNull(index) ?? 0),
      costumes: null,
      grail: (oldPlan['grail'] as int?) ?? 0,
      fouHp: (oldPlan['fouHp'] as int?) ?? 0,
      fouAtk: (oldPlan['fouAtk'] as int?) ?? 0,
      bondLimit: (oldPlan['bondLimit'] as int?) ?? 0,
      npLv: npLv,
    );
  }
}
