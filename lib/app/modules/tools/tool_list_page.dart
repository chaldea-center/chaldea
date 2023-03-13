import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../misc/aa_explorer_preview.dart';
import 'combine_image_page.dart';

class ToolListPage extends StatelessWidget {
  const ToolListPage({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, Widget> pages = {
      'Combine Images': const CombineImagePage(),
      if (db.runtimeData.enableDebugTools) 'AA Explorer': const AtlasExplorerPreview(),
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
