//@dart=2.12
import 'package:chaldea/components/components.dart';

import 'import_guda_page.dart';
import 'import_screenshot_page.dart';

class ImportDataPage extends StatefulWidget {
  @override
  _ImportDataPageState createState() => _ImportDataPageState();
}

class _ImportDataPageState extends State<ImportDataPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int curTab = 0;

  GlobalKey<ImportScreenshotPageState> key1 = GlobalKey();
  GlobalKey<ImportGudaPageState> key2 = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      curTab = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(S.of(context).import_data),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded),
            onPressed: _importImages,
            tooltip: S.of(context).import_data,
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: S.of(context).item_screenshot),
            Tab(text: S.of(context).import_guda_data)
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveBuilder(
              builder: (context) => ImportScreenshotPage(key: key1)),
          KeepAliveBuilder(builder: (context) => ImportGudaPage(key: key2)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void _importImages() {
    if (curTab == 0) {
      key1.currentState?.importImages();
    } else if (curTab == 1) {
      key2.currentState?.importGudaFile();
    }
  }
}
