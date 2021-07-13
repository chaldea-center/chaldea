import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chaldea/components/components.dart';
import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher.dart';

class AppNewsCarousel extends StatefulWidget {
  final double? maxWidth;

  const AppNewsCarousel({Key? key, this.maxWidth}) : super(key: key);

  @override
  _AppNewsCarouselState createState() => _AppNewsCarouselState();

  static Future<void> resolveSliderImageUrls([bool showToast = false]) async {
    final carouselSetting = db.userData.carouselSetting;
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
    }
  }
}

class _AppNewsCarouselState extends State<AppNewsCarousel> {
  int _curCarouselIndex = 0;
  CarouselController _carouselController = CarouselController();

  final double criticalWidth = 400;

  CarouselSetting get carouselSetting => db.userData.carouselSetting;

  @override
  void initState() {
    super.initState();
    carouselSetting.needUpdate = carouselSetting.shouldUpdate;
  }

  @override
  Widget build(BuildContext context) {
    bool useFullWidth = widget.maxWidth != null &&
        widget.maxWidth! > 0 &&
        widget.maxWidth != double.infinity &&
        widget.maxWidth! < criticalWidth * 1.2;

    final pages = getPages();

    _curCarouselIndex = fixValidRange(_curCarouselIndex, 0, pages.length - 1);

    /// No slides, show app logo
    if (pages.isEmpty) {
      final logo = FractionallySizedBox(
        heightFactor: 0.6,
        child: Image.asset('res/img/launcher_icon/app_icon_logo.png'),
      );
      if (useFullWidth) {
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
    if (useFullWidth) {
      options = CarouselOptions(
        aspectRatio: 8.0 / 3.0,
        autoPlay: pages.length > 1,
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
        autoPlay: pages.length > 1,
        autoPlayInterval: const Duration(seconds: 6),
        viewportFraction: criticalWidth / widget.maxWidth!,
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
          items: pages,
          options: options,
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: DotsIndicator(
            dotsCount: pages.length,
            position: _curCarouselIndex.toDouble(),
            decorator: DotsDecorator(
              color: Colors.white70,
              spacing: EdgeInsets.symmetric(vertical: 6, horizontal: 3),
            ),
            onTap: (v) {
              setState(() {
                _curCarouselIndex =
                    fixValidRange(v.toInt(), 0, pages.length - 1);
                _carouselController.animateToPage(_curCarouselIndex);
              });
            },
          ),
        ),
      ],
    );
  }

  List<Widget> getPages() {
    List<Widget> sliders = [];
    if (carouselSetting.needUpdate) {
      AppNewsCarousel.resolveSliderImageUrls().then((_) {
        if (mounted) setState(() {});
      });
      return sliders;
    }
    carouselSetting.urls.forEach((imgUrl, link) {
      Widget child;
      if (isURL(imgUrl)) {
        child = CachedImage(
          imageUrl: imgUrl,
          aspectRatio: 8 / 3,
          cachedOption: CachedImageOption(
              errorWidget: (context, url, error) => Container()),
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
}
