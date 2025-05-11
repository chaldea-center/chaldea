import 'package:flutter/foundation.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../exp/master_exp_page.dart';
import '_hidden.dart';
import 'aa_explorer_preview.dart';
import 'admin_tools.dart';
import 'bond_table.dart';
import 'chara_figure_marker.dart';
import 'cipher_test.dart';
import 'combine_image_page.dart';
import 'custom_chara_figure.dart';
import 'event_fatigue.dart';
import 'realtime_svt_filter.dart';
import 'skipped_svt_id.dart';
import 'tree_size.dart';

class ToolListPage extends StatelessWidget {
  const ToolListPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildOne(String title, Widget page, {bool supportWeb = true}) {
      bool enabled = supportWeb || !kIsWeb;
      return ListTile(
        title: Text(title),
        subtitle: enabled ? null : const Text("Web is not supported"),
        trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
        enabled: enabled,
        onTap: () {
          router.pushPage(page);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView(
        children: [
          TileGroup(
            header: 'Tools',
            children: [
              buildOne('Master Level', const MasterExpPage()),
              buildOne('${S.current.bond} (${S.current.total})', const BondTotalTable()),
              buildOne(S.current.custom_chara_figure, const CustomCharaFigureIntro()),
              buildOne('Event Servant Filter', const RealtimeSvtFilterPage()),
              buildOne('Event Fatigues', const EventFatigueListPage()),
            ],
          ),
          TileGroup(
            header: 'Dev Tools',
            children: [
              buildOne('Extra CharaFigure Marker', CharaFigureMarker.figure(), supportWeb: false),
              buildOne('Extra CharaImage Marker', CharaFigureMarker.image(), supportWeb: false),
              buildOne('AA Explorer', const AtlasExplorerPreview(), supportWeb: false),
              buildOne('Ciphers', const CipherTestPage()),
              buildOne('Skipped Svt ID', const SkippedSvtIdPage()),
              buildOne('Combine Images', const CombineImagePage()),
              if (db.settings.secrets.user?.isAdmin == true)
                buildOne('Admin Tools', AdminToolsPage(), supportWeb: false),
              if (!kIsWeb) buildOne('TreeSize', const TreeSizePage()),
              if (AppInfo.isDebugOn) buildOne('Y(^o^)Y', const HiddenToolsPage()),
            ],
          ),
        ],
      ),
    );
  }
}
