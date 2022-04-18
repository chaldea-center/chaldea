import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../app.dart';
import '../home/subpage/account_page.dart';
import '../home/subpage/user_data_page.dart';
import 'import_fgo_simu_material_page.dart';
import 'import_https_page.dart';
import 'v1_backup.dart';

class ImportPageHome extends StatefulWidget {
  ImportPageHome({Key? key}) : super(key: key);

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
        children: divideTiles([
          ListTile(
            title: Center(
                child: Text(S.current.cur_account + ': ' + db.curUser.name)),
            onTap: () {
              SplitRoute.push(context, AccountPage(), popDetail: true)
                  .then((_) {
                if (mounted) setState(() {});
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore),
            title: Text(S.current.chaldea_backup + ' (V2)'),
            subtitle: const Text('userdata.json/*.json'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              router.push(child: UserDataPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore),
            title: Text(S.current.chaldea_backup + ' (V1)'),
            subtitle: const Text('userdata.json/*.json'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              router.push(child: OldVersionDataImport());
            },
          ),
          ListTile(
            leading: const Icon(Icons.http),
            title: Text(S.current.https_sniff),
            subtitle: Text(S.current.import_http_body_hint),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              router.push(child: ImportHttpPage());
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.compare_arrows),
          //   title: Text(LocalizedText.of(
          //       chs: 'Guda数据',
          //       jpn: 'Gudaデータ',
          //       eng: 'Guda Data',
          //       kor: '구다 데이터')),
          //   subtitle: const Text('Guda@iOS'),
          //   trailing: const Icon(Icons.keyboard_arrow_right),
          //   onTap: () {
          //     SplitRoute.push(context, ImportGudaPage(), popDetail: true);
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: const Text('FGO Simulator-Material'),
            subtitle: const Text('https://fgosim.github.io/Material/'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              router.push(child: ImportFgoSimuMaterialPage());
            },
          ),

          const SHeader('Coming soon...'),
          ListTile(
            enabled: false,
            leading: const Icon(Icons.screenshot),
            title: Text(S.current.import_item_screenshots),
            subtitle: Text(S.current.import_item_hint),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {},
          ),
          ListTile(
            enabled: false,
            leading: const Icon(Icons.screenshot),
            title: Text(S.current.import_active_skill_screenshots),
            subtitle: Text(S.current.import_active_skill_hint),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {},
          ),
          ListTile(
            enabled: false,
            leading: const Icon(Icons.screenshot),
            title: Text(S.current.import_append_skill_screenshots),
            subtitle: Text(S.current.import_append_skill_hint),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {},
          ),
        ], bottom: true),
      ),
    );
  }
}
