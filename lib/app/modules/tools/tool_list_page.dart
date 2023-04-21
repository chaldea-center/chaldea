import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'aa_explorer_preview.dart';
import 'combine_image_page.dart';
import 'custom_chara_figure.dart';

class ToolListPage extends StatelessWidget {
  const ToolListPage({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, Widget> pages = {
      if (db.runtimeData.enableDebugTools) 'AA Explorer': const AtlasExplorerPreview(),
      S.current.custom_chara_figure: const CustomCharaFigureIntro(),
      'Combine Images': const CombineImagePage(),
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView(
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
    );
  }
}
