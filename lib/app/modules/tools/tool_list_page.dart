import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../exp/master_exp_page.dart';
import '_hidden.dart';
import 'aa_explorer_preview.dart';
import 'bond_table.dart';
import 'chara_figure_marker.dart';
import 'combine_image_page.dart';
import 'custom_chara_figure.dart';

class ToolListPage extends StatelessWidget {
  const ToolListPage({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, Widget>> groups = {
      "Tools": {
        S.current.custom_chara_figure: const CustomCharaFigureIntro(),
        'Combine Images': const CombineImagePage(),
        'Master Level': const MasterExpPage(),
        '${S.current.bond} (${S.current.total})': const BondTotalTable(),
      },
      "Dev Tools": {
        'Extra CharaFigure Marker': CharaFigureMarker.figure(),
        'Extra CharaImage Marker': CharaFigureMarker.image(),
        'AA Explorer': const AtlasExplorerPreview(),
        if (AppInfo.isDebugDevice) 'Y(^o^)Y': const HiddenToolsPage(),
      }
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView(
        children: [
          for (final (title, pages) in groups.items)
            TileGroup(
              header: title,
              children: [
                for (final entry in pages.entries)
                  ListTile(
                    title: Text(entry.key),
                    trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                    onTap: () {
                      router.pushPage(entry.value);
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
