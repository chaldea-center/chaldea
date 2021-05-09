import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/cmd_code/cmd_code_list_page.dart';
import 'package:chaldea/modules/craft/craft_list_page.dart';
import 'package:chaldea/modules/event/events_page.dart';
import 'package:chaldea/modules/extras/cv_illustrator_list.dart';
import 'package:chaldea/modules/extras/exp_card_cost_page.dart';
import 'package:chaldea/modules/extras/mystic_code_page.dart';
import 'package:chaldea/modules/extras/updates.dart';
import 'package:chaldea/modules/ffo/ffo_page.dart';
import 'package:chaldea/modules/free_quest_calculator/free_calculator_page.dart';
import 'package:chaldea/modules/home/subpage/bug_page.dart';
import 'package:chaldea/modules/home/subpage/edit_gallery_page.dart';
import 'package:chaldea/modules/home/subpage/game_data_page.dart';
import 'package:chaldea/modules/import_data/import_data_page.dart';
import 'package:chaldea/modules/item/item_list_page.dart';
import 'package:chaldea/modules/master_mission/master_mission_page.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';
import 'package:chaldea/modules/statistics/game_statistics_page.dart';
import 'package:chaldea/modules/summon/summon_list_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/getwidget.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:permission_handler/permission_handler.dart';
import 'package:string_validator/string_validator.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> with AfterLayoutMixin {
  @override
  void afterFirstLayout(BuildContext context) async {
    if (db.userData.slidesUpdateTime == null ||
        db.userData.sliderUrls.isEmpty) {
      resolveSliderImageUrls();
    } else {
      DateTime lastTime = DateTime.fromMillisecondsSinceEpoch(
              db.userData.slidesUpdateTime! * 1000),
          now = DateTime.now();
      if (now.difference(lastTime).inHours > 24) {
        // more than 1 day
        resolveSliderImageUrls();
      }
    }

    _hasPermission = true;
    if (!Platform.isAndroid) return;
    int? sdkInt = AppInfo.androidSdk;
    if (sdkInt == null) return;
    permission =
        sdkInt >= 30 ? Permission.manageExternalStorage : Permission.storage;
    _hasPermission = await permission.isGranted;
    if (mounted) setState(() {});

    Future.delayed(Duration(seconds: 2)).then((_) async {
      if (kDebugMode) return;
      if (db.userData.autoUpdateDataset) {
        await AutoUpdateUtil.patchGameData();
      }
      await Future.delayed(Duration(seconds: 2));
      await AutoUpdateUtil().checkAppUpdate(
          background: true, download: db.userData.autoUpdateApp);
    });
  }

  Widget faIcon(IconData icon) {
    return Padding(
      padding: EdgeInsets.all(2),
      child: FaIcon(
        icon,
        size: 36,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Map<String, GalleryItem> get kAllGalleryItems {
    return {
      GalleryItem.servant: GalleryItem(
        name: GalleryItem.servant,
        title: S.of(context).servant_title,
        icon: Icons.people,
        builder: (context, _) => ServantListPage(),
      ),
      GalleryItem.craft_essence: GalleryItem(
        name: GalleryItem.craft_essence,
        title: S.of(context).craft_essence,
        icon: Icons.extension,
        builder: (context, _) => CraftListPage(),
      ),
      GalleryItem.cmd_code: GalleryItem(
        name: GalleryItem.cmd_code,
        title: S.of(context).cmd_code_title,
        icon: Icons.stars,
        builder: (context, _) => CmdCodeListPage(),
      ),
      GalleryItem.item: GalleryItem(
        name: GalleryItem.item,
        title: S.of(context).item_title,
        icon: Icons.category,
        builder: (context, _) => ItemListPage(),
      ),
      GalleryItem.event: GalleryItem(
        name: GalleryItem.event,
        title: S.of(context).event_title,
        icon: Icons.event_available,
        builder: (context, _) => EventListPage(),
      ),
      GalleryItem.plan: GalleryItem(
        name: GalleryItem.plan,
        title: S.of(context).plan_title,
        icon: Icons.article_outlined,
        builder: (context, _) => ServantListPage(planMode: true),
        isDetail: false,
      ),
      GalleryItem.free_calculator: GalleryItem(
        name: GalleryItem.free_calculator,
        title: S.of(context).free_quest_calculator_short,
        icon: Icons.pin_drop,
        builder: (context, _) => FreeQuestCalculatorPage(),
        isDetail: true,
      ),
      GalleryItem.weekly_mission: GalleryItem(
        name: GalleryItem.weekly_mission,
        title: S.of(context).master_mission,
        child: faIcon(FontAwesomeIcons.tasks),
        builder: (context, _) => MasterMissionPage(),
        isDetail: true,
      ),
      GalleryItem.mystic_code: GalleryItem(
        name: GalleryItem.mystic_code,
        title: S.of(context).mystic_code,
        child: faIcon(FontAwesomeIcons.tshirt),
        builder: (context, _) => MysticCodePage(),
        isDetail: true,
      ),
      // GalleryItem.calculator: GalleryItem(
      //   name: GalleryItem.calculator,
      //   title: S.of(context).calculator,
      //   icon: Icons.keyboard,
      //   builder: (context, _) => DamageCalcPage(),
      //   isDetail: true,
      // ),
      GalleryItem.gacha: GalleryItem(
        name: GalleryItem.gacha,
        title: S.of(context).summon_title,
        child: faIcon(FontAwesomeIcons.chessQueen),
        builder: (context, _) => SummonListPage(),
        isDetail: false,
      ),
      GalleryItem.ffo: GalleryItem(
        name: GalleryItem.ffo,
        title: 'Freedom Order',
        child: faIcon(FontAwesomeIcons.cubes),
        builder: (context, _) => FreedomOrderPage(),
        isDetail: true,
      ),
      GalleryItem.cv_list: GalleryItem(
        name: GalleryItem.cv_list,
        title: S.current.info_cv,
        icon: Icons.keyboard_voice,
        builder: (context, _) => CvListPage(),
        isDetail: true,
      ),
      GalleryItem.illustrator_list: GalleryItem(
        name: GalleryItem.illustrator_list,
        title: S.current.illustrator,
        child: faIcon(FontAwesomeIcons.paintBrush),
        builder: (context, _) => IllustratorListPage(),
        isDetail: true,
      ),
      // if (kDebugMode_)
      //   GalleryItem.ap_cal: GalleryItem(
      //     name: GalleryItem.ap_cal,
      //     title: S.of(context).ap_calc_title,
      //     icon: Icons.directions_run,
      //     builder: (context, _) => APCalcPage(),
      //     isDetail: true,
      //   ),
      GalleryItem.exp_card: GalleryItem(
        name: GalleryItem.exp_card,
        title: S.current.exp_card_title,
        icon: Icons.rice_bowl,
        builder: (context, _) => ExpCardCostPage(),
        isDetail: true,
      ),
      GalleryItem.statistics: GalleryItem(
        name: GalleryItem.statistics,
        title: S.of(context).statistics_title,
        icon: Icons.analytics,
        builder: (context, _) => GameStatisticsPage(),
        isDetail: true,
      ),
      GalleryItem.import_data: GalleryItem(
        name: GalleryItem.import_data,
        title: S.of(context).import_data,
        icon: Icons.cloud_download,
        builder: (context, _) => ImportDataPage(),
        isDetail: true,
      ),
      GalleryItem.bug: GalleryItem(
        name: GalleryItem.bug,
        title: 'BUG',
        icon: Icons.bug_report_outlined,
        builder: (context, _) => BugAnnouncePage(),
        //fail
        isDetail: true,
      ),
      GalleryItem.more: GalleryItem(
        name: GalleryItem.more,
        title: S.of(context).more,
        icon: Icons.add,
        builder: (context, _) => EditGalleryPage(galleries: kAllGalleryItems),
        //fail
        isDetail: true,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kAppName),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: S.of(context).tooltip_refresh_sliders,
            onPressed: () => resolveSliderImageUrls(true),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCarousel(),
                    _buildGalleries(),
                  ],
                ),
              ),
              _buildNotifications(),
              if (kDebugMode) buildTestInfoPad(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGalleries() {
    Widget grid = LayoutBuilder(builder: (context, constraints) {
      int crossCount = max(2, constraints.maxWidth ~/ 75);
      return GridView.count(
        crossAxisCount: crossCount,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        childAspectRatio: 1,
        children: _getShownGalleries(context),
      );
    });
    if (db.gameData.version.length < 2) {
      grid = GestureDetector(
        onTap: () {
          SimpleCancelOkDialog(
            title: Text('Gamedata Error'),
            content: Text(S.current.reload_default_gamedata),
            onTapOk: () async {
              await db.loadZipAssets(kDatasetAssetKey);
              db.loadGameData();
            },
          ).showDialog(context);
        },
        child: AbsorbPointer(
          child: Opacity(
            opacity: 0.5,
            child: grid,
          ),
        ),
      );
    }
    return grid;
  }

  Widget _buildCarousel() {
    final sliderPages = _getSliderPages();
    return sliderPages.isEmpty
        ? AspectRatio(
            aspectRatio: 8 / 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: Divider.createBorderSide(context, width: 0.5),
                ),
              ),
            ),
          )
        : GFCarousel(
            items: sliderPages,
            aspectRatio: 8.0 / 3.0,
            pagination: true,
            autoPlay: sliderPages.length > 1,
            autoPlayInterval: Duration(seconds: 5),
            viewportFraction: 1.0,
          );
  }

  List<Widget> _getShownGalleries(BuildContext context) {
    List<Widget> _galleryItems = [];
    kAllGalleryItems.forEach((name, item) {
      if ((db.userData.galleries[name] ?? true) ||
          name == GalleryItem.more ||
          name == GalleryItem.bug) {
        _galleryItems.add(InkWell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: item.child == null
                      ? Icon(
                          item.icon,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : item.child,
                ),
              ),
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AutoSizeText(
                    item.title,
                    style: TextStyle(fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                    maxFontSize: 14,
                  ),
                ),
              )
            ],
          ),
          onTap: () {
            if (item.builder != null) {
              SplitRoute.push(
                context: context,
                builder: item.builder!,
                detail: item.isDetail,
                popDetail: true,
              ).then((value) => db.saveUserData());
            }
          },
        ));
      }
    });
    return _galleryItems;
  }

  List<Widget> _getSliderPages() {
    List<Widget> sliders = [];
    if (db.userData.sliderUrls.isEmpty) {
      resolveSliderImageUrls();
      return sliders;
    }
    final urls = db.userData.sliderUrls;
    urls.forEach((imgUrl, link) {
      Widget child;
      if (isURL(imgUrl)) {
        child = CachedImage(
          imageUrl: imgUrl,
          connectivity: db.connectivity,
          errorWidget: (context, url, error) => Container(),
        );
      } else {
        child = AspectRatio(
          aspectRatio: 8 / 3,
          child: FittedBox(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Text(imgUrl, textAlign: TextAlign.center),
            ),
          ),
        );
      }
      sliders.add(GestureDetector(
        onTap: () => jumpToExternalLinkAlert(url: link),
        child: child,
      ));
    });
    return sliders;
  }

  Widget buildTestInfoPad() {
    return Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: divideTiles(<Widget>[
            ListTile(
              title: Center(
                child: Text('Test Info Pad', style: TextStyle(fontSize: 18)),
              ),
            ),
            ListTile(
              title: Text('Screen size'),
              trailing: Text(MediaQuery.of(context).size.toString()),
            ),
            ListTile(
              title: Text('Dataset version'),
              trailing: Text(db.gameData.version),
            ),
          ]),
        ));
  }

  Future<Null> resolveSliderImageUrls([bool showToast = false]) async {
    Map<String, String> _getImageLinks(dom.Element? element, Uri uri) {
      Map<String, String> _result = {};
      if (element == null) return _result;
      for (var linkNode in element.getElementsByTagName('a')) {
        String? link = linkNode.attributes['href'];
        var imgNodes = linkNode.getElementsByTagName('img');
        if (link == null) continue;
        print('link=$link');
        if (imgNodes.isNotEmpty) {
          String? imgUrl = imgNodes.first.attributes['src'];
          if (imgUrl != null) {
            imgUrl = uri.resolve(imgUrl).toString();
            link = uri.resolve(link).toString();
            _result[imgUrl] = link;
            // print('imgUrl= "$imgUrl"\nhref  = "$link"');
          }
        } else if (linkNode.text.isNotEmpty) {
          _result[linkNode.text] = link;
        }
      }
      return _result;
    }

    Map<String, String> result = {};
    try {
      final _dio = Dio();
      // mc slides
      final mcUrl = 'https://fgo.wiki/w/模板:自动取值轮播';
      final task1 = _dio.get(mcUrl).then((response) {
        var mcParser = parser.parse(response.data.toString());
        var mcElement = mcParser.getElementById('transImageBox');
        return _getImageLinks(mcElement, Uri.parse(mcUrl));
      }).catchError((e, s) {
        logger.e('parse mc slides failed', e, s);
        return <String, String>{};
      });

      // jp slides
      final jpUrl = 'http://view.fate-go.jp';
      final task2 = _dio.get(jpUrl).then((response) {
        var jpParser = parser.parse(response.data.toString());
        var jpElement = jpParser.getElementsByClassName('slide').getOrNull(0);
        return _getImageLinks(jpElement, Uri.parse(jpUrl));
      }).catchError((e, s) {
        logger.e('parse jp slides failed', e, s);
        return <String, String>{};
      });

      final announceUrl =
          'https://gitee.com/chaldea-center/chaldea/wikis/pages/wiki?wiki_title=Announcement&parent=&version_id=master&sort_id=3819789&info_id=1327454&extname=.md';
      final task3 = _dio.get(announceUrl).then((response) {
        final annContent = response.data;
        // print(annContent.runtimeType);
        // print(annContent['wiki']['content_html']);
        var announceParser = parser.parse(annContent['wiki']['content_html']);
        var announceElement = announceParser.body;
        return _getImageLinks(announceElement, Uri.parse(announceUrl));
      }).catchError((e, s) {
        logger.e('parse gitee announce slides failed', e, s);
        return <String, String>{};
      });
      await Future.forEach<Future<Map<String, String>>>(
          [task1, task3, task2], (e) async => result.addAll(await e));
      if (showToast) {
        EasyLoading.showSuccess('slides updated');
      }
    } catch (e, s) {
      logger.e('Error refresh slides', e, s);
      if (showToast) {
        EasyLoading.showError('update slides failed\n$e');
      }
    } finally {
      if (result.isNotEmpty) {
        db.userData.sliderUrls = result;
        db.userData.slidesUpdateTime =
            DateTime.now().millisecondsSinceEpoch ~/ 1000;
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  double _cachedIconsRatio = -1;

  Widget _buildNotifications() {
    List<Widget> children = [];
    if (!_hasPermission) {
      children.add(ListTile(
        title: Text(S.current.storage_permission_title),
        leading: Icon(Icons.warning_rounded),
        onTap: _setupAndroidPermission,
      ));
    }
    if (_cachedIconsRatio < 0.7) {
      // TODO: why icon folder list error?
      // FileSystemException: Directory listing failed,
      // path = '/storage/emulated/0/Android/data/cc.narumi.chaldea/files/data/icons/'
      // (OS Error: Invalid argument, errno = 22)
      try {
        int total = db.gameData.servants.length +
            db.gameData.crafts.length +
            db.gameData.cmdCodes.length +
            321;
        final iconDir = Directory(db.paths.gameIconDir);
        int cached = 0;
        if (iconDir.existsSync()) cached = iconDir.listSync().length;
        _cachedIconsRatio = cached / total;
      } catch (e, s) {
        logger.e('list icon dir failed', e, s);
      }
    }
    // print('$cached/$total');
    if (_cachedIconsRatio >= 0 && _cachedIconsRatio < 0.8) {
      children.add(ListTile(
        leading: Icon(Icons.image),
        title: Text('Download icons'),
        subtitle: Text(
            'About ${(_cachedIconsRatio * 100).toStringAsFixed(0)}% downloaded'
            '\nGoto ${S.current.download_full_gamedata}'),
        isThreeLine: true,
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          SplitRoute.push(
            context: context,
            builder: (context, _) => GameDataPage(),
            detail: true,
          );
        },
      ));
    }
    if (children.isEmpty) return Container();
    return SimpleAccordion(
      expanded: false,
      headerBuilder: (context, _) => ListTile(
        leading: Icon(Icons.notifications, color: Colors.blue),
        title: Text('Notifications'),
        tileColor: Colors.white,
      ),
      contentBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: divideTiles(children),
      ),
    );
  }

  bool _hasPermission = true;
  Permission permission = Permission.storage;

  Future<void> _setupAndroidPermission() async {
    final String externalBackupDir =
        join('/storage/emulated/0/', AppInfo.packageName);
    var confirmed = await SimpleCancelOkDialog(
      title: Text(S.current.storage_permission_title),
      content: Text(S.current
          .storage_permission_content(db.paths.userDir, externalBackupDir)),
    ).showDialog(kAppKey.currentContext!);
    if (confirmed == true) {
      logger.i('request storage permission');
      await permission.request();
    }
    logger.d(
        'storage permission $permission: ${await Permission.storage.status}');
    _hasPermission = await permission.isGranted;
    if (_hasPermission) {
      db.paths.externalAppPath = externalBackupDir;
      print(db.paths.externalAppPath);
    }
    if (mounted) setState(() {});
  }
}
