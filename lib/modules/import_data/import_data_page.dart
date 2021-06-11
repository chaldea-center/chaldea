import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/import_data/import_http_response.dart';
import 'package:chaldea/modules/import_data/import_svt_screenshot_page.dart';

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

  GlobalKey<ImportHttpResponseState> keyHttp = GlobalKey();
  GlobalKey<ImportScreenshotPageState> keyScreenshot = GlobalKey();
  GlobalKey<ImportSvtScreenshotPageState> keySvtScreenshot = GlobalKey();
  GlobalKey<ImportGudaPageState> keyGuda = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          isScrollable: !Language.isCN,
          tabs: [
            Tab(text: 'HTTP'),
            Tab(text: S.current.item_screenshot),
            Tab(text: S.current.skill),
            Tab(text: S.current.import_guda_data)
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveBuilder(
              builder: (context) => ImportHttpResponse(key: keyHttp)),
          KeepAliveBuilder(
              builder: (context) => ImportScreenshotPage(key: keyScreenshot)),
          KeepAliveBuilder(
              builder: (context) =>
                  ImportSvtScreenshotPage(key: keySvtScreenshot)),
          KeepAliveBuilder(builder: (context) => ImportGudaPage(key: keyGuda)),
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
    switch (curTab) {
      case 0:
        keyHttp.currentState?.importResponseBody();
        break;
      case 1:
        keyScreenshot.currentState?.importImages();
        break;
      case 2:
        keySvtScreenshot.currentState?.importImages();
        break;
      case 3:
        keyGuda.currentState?.importGudaFile();
        break;
      default:
        break;
    }
  }
}
