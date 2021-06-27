import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:chaldea/modules/import_data/home_import_page.dart';
import 'package:chaldea/modules/item/item_list_page.dart';
import 'package:chaldea/modules/master_mission/master_mission_page.dart';
import 'package:chaldea/modules/servant/costume_list_page.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';
import 'package:chaldea/modules/statistics/game_statistics_page.dart';
import 'package:chaldea/modules/summon/summon_list_page.dart';
import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:rate_my_app/rate_my_app.dart';
import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  CarouselSetting get carouselSetting => db.userData.carouselSetting;
  final RateMyApp rateMyApp = RateMyApp(
    minDays: 7,
    minLaunches: 20,
    remindDays: 14,
    remindLaunches: 40,
    appStoreIdentifier: '1548713491',
    googlePlayIdentifier: 'cc.narumi.chaldea',
  );

  @override
  void initState() {
    super.initState();
    carouselSetting.needUpdate = carouselSetting.shouldUpdate;

    Future.delayed(Duration(seconds: 2)).then((_) async {
      if (AppInfo.isMobile) {
        await rateMyApp.init();
        if (rateMyApp.shouldOpenDialog) {
          await rateMyApp.showRateDialog(
            context,
            title: 'Enjoy Chaldea?',
            message:
                'If you like this app, please take a little bit of your time to review it!',
          );
        }
      }
      if (kDebugMode) return;
      if (db.userData.autoUpdateDataset) {
        await AutoUpdateUtil.patchGameData();
      }
      await Future.delayed(Duration(seconds: 2));
      await AutoUpdateUtil.checkAppUpdate(
          background: true, download: db.userData.autoUpdateApp);
    }).onError((e, s) {
      logger.e('init app extras', e, s);
    });
  }

  Color? get _iconColor {
    return Utils.isDarkMode(context)
        ? Theme.of(context).colorScheme.secondaryVariant
        : Theme.of(context).colorScheme.secondary;
  }

  Widget faIcon(IconData icon) {
    return Padding(
      padding: EdgeInsets.all(2),
      child: FaIcon(
        icon,
        size: 36,
        color: _iconColor,
      ),
    );
  }

  Map<String, GalleryItem> get kAllGalleryItems {
    return {
      GalleryItem.servant: GalleryItem(
        name: GalleryItem.servant,
        title: S.of(context).servant_title,
        // icon: Icons.people,
        child: faIcon(FontAwesomeIcons.users),
        builder: (context, _) => ServantListPage(),
      ),
      GalleryItem.craft_essence: GalleryItem(
        name: GalleryItem.craft_essence,
        title: S.of(context).craft_essence,
        // icon: Icons.extension,
        child: faIcon(FontAwesomeIcons.streetView),
        builder: (context, _) => CraftListPage(),
      ),
      GalleryItem.cmd_code: GalleryItem(
        name: GalleryItem.cmd_code,
        title: S.of(context).cmd_code_title,
        // icon: Icons.stars,
        child: faIcon(FontAwesomeIcons.expand),
        builder: (context, _) => CmdCodeListPage(),
      ),
      GalleryItem.item: GalleryItem(
        name: GalleryItem.item,
        title: S.of(context).item_title,
        icon: Icons.category,
        // child: faIcon(FontAwesomeIcons.cubes),
        builder: (context, _) => ItemListPage(),
      ),
      GalleryItem.event: GalleryItem(
        name: GalleryItem.event,
        title: S.of(context).event_title,
        icon: Icons.flag,
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
        // icon: Icons.pin_drop,
        child: faIcon(FontAwesomeIcons.mapMarked),
        builder: (context, _) => FreeQuestCalculatorPage(),
        isDetail: true,
      ),
      GalleryItem.master_mission: GalleryItem(
        name: GalleryItem.master_mission,
        title: S.of(context).master_mission,
        child: faIcon(FontAwesomeIcons.tasks),
        builder: (context, _) => MasterMissionPage(),
        isDetail: true,
      ),
      GalleryItem.mystic_code: GalleryItem(
        name: GalleryItem.mystic_code,
        title: S.of(context).mystic_code,
        child: faIcon(FontAwesomeIcons.diagnoses),
        builder: (context, _) => MysticCodePage(),
        isDetail: true,
      ),
      GalleryItem.costume: GalleryItem(
        name: GalleryItem.costume,
        title: S.of(context).costume,
        child: faIcon(FontAwesomeIcons.tshirt),
        builder: (context, _) => CostumeListPage(),
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
        child: faIcon(FontAwesomeIcons.dice),
        builder: (context, _) => SummonListPage(),
        isDetail: false,
      ),
      GalleryItem.ffo: GalleryItem(
        name: GalleryItem.ffo,
        title: 'Freedom Order',
        child: faIcon(FontAwesomeIcons.layerGroup),
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
        // icon: Icons.rice_bowl,
        child: faIcon(FontAwesomeIcons.breadSlice),
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
        builder: (context, _) => ImportPageHome(),
        isDetail: false,
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
                    _buildCarousel(constraints),
                    _buildGalleries(constraints),
                  ],
                ),
              ),
              Card(
                child: _buildNotifications(),
              ),
              if (kDebugMode) buildTestInfoPad(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGalleries(BoxConstraints constraints) {
    int crossCount = max(2, constraints.maxWidth ~/ 75);
    crossCount = min(8, crossCount);
    Widget grid = GridView.count(
      padding: EdgeInsets.all(8),
      crossAxisCount: crossCount,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      childAspectRatio: 1,
      children: _getShownGalleries(context),
    );
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

  int _curCarouselIndex = 0;
  CarouselController _carouselController = CarouselController();

  Widget _buildCarousel(BoxConstraints constraints) {
    final sliderPages = _getSliderPages();
    _curCarouselIndex =
        fixValidRange(_curCarouselIndex, 0, sliderPages.length - 1);
    final double criticalWidth = 400;
    if (sliderPages.isEmpty) {
      final logo = FractionallySizedBox(
        heightFactor: 0.6,
        child: Image.asset('res/img/launcher_icon/app_icon_logo.png'),
      );
      if (constraints.maxWidth < criticalWidth * 1.2) {
        return AspectRatio(
          aspectRatio: 8 / 3,
          child: Container(child: logo),
        );
      } else {
        return Container(
          height: criticalWidth * 3 / 8,
          child: logo,
        );
      }
    }
    CarouselOptions options;
    if (constraints.maxWidth < criticalWidth * 1.2) {
      options = CarouselOptions(
        aspectRatio: 8.0 / 3.0,
        autoPlay: sliderPages.length > 1,
        autoPlayInterval: const Duration(seconds: 6),
        viewportFraction: 1,
        initialPage: _curCarouselIndex,
        onPageChanged: (v, _) => setState(() {
          _curCarouselIndex = v;
        }),
      );
    } else {
      options = CarouselOptions(
        height: criticalWidth * 3 / 8,
        autoPlay: sliderPages.length > 1,
        autoPlayInterval: const Duration(seconds: 6),
        viewportFraction: criticalWidth / constraints.maxWidth,
        enlargeCenterPage: true,
        enlargeStrategy: CenterPageEnlargeStrategy.height,
        initialPage: _curCarouselIndex,
        onPageChanged: (v, _) => setState(() {
          _curCarouselIndex = v;
        }),
      );
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          items: sliderPages,
          options: options,
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: DotsIndicator(
            dotsCount: sliderPages.length,
            position: _curCarouselIndex.toDouble(),
            decorator: DotsDecorator(
              color: Colors.white70,
              spacing: EdgeInsets.symmetric(vertical: 6, horizontal: 3),
            ),
            onTap: (v) {
              setState(() {
                _curCarouselIndex =
                    fixValidRange(v.toInt(), 0, sliderPages.length - 1);
                _carouselController.animateToPage(_curCarouselIndex);
              });
            },
          ),
        ),
      ],
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
                          color: _iconColor,
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
    if (carouselSetting.needUpdate) {
      resolveSliderImageUrls();
      return sliders;
    }
    carouselSetting.urls.forEach((imgUrl, link) {
      Widget child;
      if (isURL(imgUrl)) {
        child = CachedImage(
          imageUrl: imgUrl,
          errorWidget: (context, url, error) => Container(),
          aspectRatio: 8 / 3,
        );
      } else {
        child = Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Center(
            child: AutoSizeText(
              imgUrl,
              textAlign: TextAlign.center,
              maxFontSize: 20,
              minFontSize: 5,
              maxLines: imgUrl.split('\n').length,
            ),
          ),
        );
      }
      sliders.add(GestureDetector(
        onTap: () async {
          if (await canLaunch(link)) {
            jumpToExternalLinkAlert(url: link);
          }
        },
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
      ),
    );
  }

  Future<void> resolveSliderImageUrls([bool showToast = false]) async {
    carouselSetting.needUpdate = false;
    Map<String, String> _getImageLinks(
        {required dom.Element? element,
        required Uri uri,
        String attr = 'src',
        bool imgOnly = true}) {
      Map<String, String> _result = {};
      if (element == null) return _result;
      for (var linkNode in element.getElementsByTagName('a')) {
        String? link = linkNode.attributes['href'];
        var imgNodes = linkNode.getElementsByTagName('img');
        if (link == null) continue;
        print('link=$link');
        if (imgNodes.isNotEmpty) {
          String? imgUrl = imgNodes.first.attributes[attr];
          if (imgUrl != null) {
            imgUrl = uri.resolve(imgUrl).toString().trim();
            print('imgUrl=$imgUrl');
            link = uri.resolve(link).toString().trim();
            _result[imgUrl] = link;
            // print('imgUrl= "$imgUrl"\nhref  = "$link"');
          }
        } else if (linkNode.text.isNotEmpty && !imgOnly) {
          _result[linkNode.text.trim()] = link.trim();
        }
      }
      return _result;
    }

    Map<String, String> result = {};
    try {
      final _dio = Dio();
      Future<Map<String, String>>? taskMC, taskJp, taskGitee, taskUs;
      // mc slides
      if (carouselSetting.enableMooncell) {
        final mcUrl = 'https://fgo.wiki/w/模板:自动取值轮播';
        taskMC = _dio.get(mcUrl).then((response) {
          var mcParser = parser.parse(response.data.toString());
          var mcElement = mcParser.getElementById('transImageBox');
          return _getImageLinks(element: mcElement, uri: Uri.parse(mcUrl));
        }).catchError((e, s) {
          logger.e('parse mc slides failed', e, s);
          return <String, String>{};
        });
      }

      // jp slides
      if (carouselSetting.enableJp) {
        final jpUrl = 'https://view.fate-go.jp';
        taskJp = _dio.get(jpUrl).then((response) {
          var jpParser = parser.parse(response.data.toString());
          var jpElement = jpParser.getElementsByClassName('slide').getOrNull(0);
          return _getImageLinks(element: jpElement, uri: Uri.parse(jpUrl))
            ..removeWhere((key, value) =>
            key.endsWith('2019/tips_qavwi/top_banner.png') ||
                key.endsWith('2017/02/banner_10009.png'));
        }).catchError((e, s) {
          logger.e('parse jp slides failed', e, s);
          return <String, String>{};
        });
      }

      // gitee, always
      final announceUrl =
          'https://gitee.com/chaldea-center/chaldea/wikis/pages/wiki?wiki_title=Announcement&parent=&version_id=master&sort_id=3819789&info_id=1327454&extname=.md';
      taskGitee = _dio.get(announceUrl).then((response) {
        final annContent = response.data;
        // print(annContent.runtimeType);
        // print(annContent['wiki']['content_html']);
        var announceParser = parser.parse(annContent['wiki']['content_html']);
        var announceElement = announceParser.body;
        return _getImageLinks(
            element: announceElement,
            uri: Uri.parse(announceUrl),
            imgOnly: false);
      }).catchError((e, s) {
        logger.e('parse gitee announce slides failed', e, s);
        return <String, String>{};
      });

      // jp slides
      if (carouselSetting.enableUs) {
        final usUrl = 'https://webview.fate-go.us';
        taskUs = _dio.get(usUrl).then((response) {
          var usParser = parser.parse(response.data.toString());
          var usElement = usParser.getElementsByClassName('slide').getOrNull(0);
          return _getImageLinks(element: usElement, uri: Uri.parse(usUrl))
            ..removeWhere((key, value) => [
                  'top_banner.png',
                  'banner_sns_20181120.png',
                  '0215_evenmoremanwaka/banner_20210215.png',
                  'banner_tips_k5dz8.png',
                  '0707_start_dash_campaign/banner_20200707_h1wb3.png'
                ].any((e) => key.endsWith(e)));
        }).catchError((e, s) {
          logger.e('parse jp slides failed', e, s);
          return <String, String>{};
        });
      }

      await Future.forEach<Future<Map<String, String>>?>(
        // [taskUs],
        [taskMC, taskGitee, taskJp, taskUs],
            (e) async {
          if (e != null) result.addAll(await e);
        },
      );

      if (result.isNotEmpty) {
        carouselSetting.urls = result;
        carouselSetting.updateTime =
            DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (showToast) {
          EasyLoading.showSuccess('slides updated');
        }
      } else {
        if (showToast) {
          EasyLoading.showInfo('Not updated');
        }
      }
    } catch (e, s) {
      logger.e('Error refresh slides', e, s);
      if (showToast) {
        EasyLoading.showError('update slides failed\n$e');
      }
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  double _cachedIconsRatio = -1;

  Widget _buildNotifications() {
    List<Widget> children = [];
    if (_cachedIconsRatio < 0.7 && !kReleaseMode) {
      // TODO: why icon folder list error? Currently disabled it
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
    if (!kReleaseMode) children.add(ListTile(title: Text('Test')));
    if (children.isEmpty) return Container();
    return SimpleAccordion(
      expanded: false,
      expandElevation: 0.0,
      headerBuilder: (context, _) => ListTile(
        leading: Icon(Icons.notifications,
            color: Theme.of(context).colorScheme.secondary),
        title: Text('Notifications'),
        // tileColor: Theme.of(context).cardColor,
      ),
      contentBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: divideTiles(children),
      ),
    );
  }
}
