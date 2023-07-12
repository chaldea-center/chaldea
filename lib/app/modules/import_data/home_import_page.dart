import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/import_data/autologin/login_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import '../../app.dart';
import '../home/subpage/account_page.dart';
import '../home/subpage/user_data_page.dart';
import 'import_fgo_simu_material_page.dart';
import 'import_https_page.dart';
import 'item_screenshots.dart';
import 'sheet/import_csv.dart';
import 'skill_screenshots.dart';
import 'v1_backup.dart';

class ImportPageHome extends StatefulWidget {
  ImportPageHome({super.key});

  @override
  _ImportPageHomeState createState() => _ImportPageHomeState();
}

class _ImportPageHomeState extends State<ImportPageHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: Text(S.current.import_data),
      ),
      body: ListView(
        children: [
          ListTile(
            dense: true,
            title: db.onUserData((context, snapshot) => Text(
                  '${S.current.cur_account}: ${db.curUser.name}',
                  textAlign: TextAlign.center,
                )),
            onTap: () {
              router.pushPage(AccountPage(), popDetail: true);
            },
          ),
          const Divider(indent: 48, endIndent: 48, height: 2),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore),
            title: Text('${S.current.chaldea_backup} (v2)'),
            subtitle: const Text('userdata.json/*.json'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              router.popDetailAndPush(child: UserDataPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore),
            title: Text('${S.current.chaldea_backup} (v1)'),
            subtitle: const Text('userdata.json/*.json'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              router.popDetailAndPush(child: OldVersionDataImport());
            },
          ),
          ListTile(
            leading: const Icon(Icons.http),
            title: Text(S.current.https_sniff),
            subtitle: Text(S.current.http_sniff_hint),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              router.popDetailAndPush(child: ImportHttpPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts),
            title: Text(S.current.import_auth_file),
            trailing: const Icon(Icons.keyboard_arrow_right),
            subtitle:
                Text(['${Region.jp.localName}/${Region.na.localName}', if (kIsWeb) 'web is not supported'].join(', ')),
            enabled: !kIsWeb,
            onTap: kIsWeb
                ? null
                : () {
                    router.pushPage(const AutoLoginPage());
                  },
          ),
          // SHeader(S.current.testing),
          ListTile(
            leading: const Icon(Icons.screenshot),
            title: Text(S.current.import_item_screenshots),
            subtitle: Text(S.current.import_item_hint),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              router.pushPage(ImportItemScreenshotPage(), popDetail: true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.screenshot),
            title: Text(S.current.import_active_skill_screenshots),
            subtitle: Text(S.current.import_active_skill_hint),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              router.pushPage(ImportSkillScreenshotPage(isAppend: false), popDetail: true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.screenshot),
            title: Text(S.current.import_append_skill_screenshots),
            subtitle: Text(S.current.import_append_skill_hint),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              router.pushPage(ImportSkillScreenshotPage(isAppend: true), popDetail: true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: const Text('FGO Simulator-Material'),
            subtitle: const Text('https://fgosim.github.io/Material/'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              router.popDetailAndPush(child: ImportFgoSimuMaterialPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_view),
            title: Text(S.current.import_csv_title),
            subtitle: const Text('Edit in Excel/Google Sheet'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              router.pushPage(const ImportCSVPage(), popDetail: true);
            },
          ),
        ],
      ),
    );
  }
}
