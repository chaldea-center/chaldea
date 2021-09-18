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
    if (!db.hasNetwork) {
      if (showToast) EasyLoading.showInfo(S.current.error_no_network);
      return;
    }
    final carouselSetting = db.userData.carouselSetting;
    carouselSetting.needUpdate = false;
    Map<String, String> _getImageLinks(
        {required dom.Element? element,
        required Uri uri,
        String attr = 'src',
        bool custom = false}) {
      Map<String, String> _result = {};
      if (element == null) return _result;
      for (var linkNode in element.getElementsByTagName('a')) {
        String? link = linkNode.attributes['href'];
        var imgNodes = linkNode.getElementsByTagName('img');
        if (link == null) continue;
        if (imgNodes.isNotEmpty) {
          String? imgUrl = imgNodes.first.attributes[attr];
          if (!custom) {
            link = uri.resolve(link).toString().trim();
          }
          if (imgUrl != null) {
            imgUrl = uri.resolve(imgUrl).toString().trim();
            _result[imgUrl] = link;
          }
        } else if (linkNode.text.isNotEmpty && custom) {
          _result[linkNode.text.trim()] = link.trim();
        }
      }
      _result.forEach((key, value) {
        print('img=$key');
        print('  link=$value');
      });
      return _result;
    }

    Map<String, String> result = {};
    try {
      final _dio = Dio();
      Future<Map<String, String>>? taskMC, taskJp, taskGitee, taskUs;
      bool updated = false;
      // mc slides
      if (carouselSetting.enableMooncell) {
        const mcUrl = 'https://fgo.wiki/w/模板:自动取值轮播';
        taskMC = _dio.get(mcUrl).then((response) {
          var mcParser = parser.parse(response.data.toString());
          var mcElement = mcParser.getElementById('transImageBox');
          updated = true;
          return _getImageLinks(element: mcElement, uri: Uri.parse(mcUrl));
        }).catchError((e, s) {
          logger.e('parse mc slides failed', e, s);
          return <String, String>{};
        });
      }

      // jp slides
      if (carouselSetting.enableJp) {
        const jpUrl = 'https://view.fate-go.jp';
        taskJp = _dio.get(jpUrl).then((response) {
          var jpParser = parser.parse(response.data.toString());
          var jpElement = jpParser.getElementsByClassName('slide').getOrNull(0);
          updated = true;
          return _getImageLinks(element: jpElement, uri: Uri.parse(jpUrl));
        }).catchError((e, s) {
          logger.e('parse jp slides failed', e, s);
          return <String, String>{};
        });
      }

      // gitee, always
      taskGitee = GitTool.giteeWikiPage('Announcement', htmlFmt: true)
          .then((String content) {
        var announceParser = parser.parse(content);
        var announceElement = announceParser.body;
        updated = true;
        return _getImageLinks(
            element: announceElement,
            uri: Uri.parse(
                'https://gitee.com/chaldea-center/chaldea/wikis/Announcement'),
            custom: true);
      }).catchError((e, s) {
        logger.e('parse gitee announce slides failed', e, s);
        return <String, String>{};
      });

      // jp slides
      if (carouselSetting.enableUs) {
        const usUrl = 'https://webview.fate-go.us';
        taskUs = _dio.get(usUrl).then((response) {
          var usParser = parser.parse(response.data.toString());
          var usElement = usParser.getElementsByClassName('slide').getOrNull(0);
          updated = true;
          return _getImageLinks(element: usElement, uri: Uri.parse(usUrl));
        }).catchError((e, s) {
          logger.e('parse jp slides failed', e, s);
          return <String, String>{};
        });
      }

      await Future.forEach<Future<Map<String, String>>?>(
        // [taskUs],
        [taskGitee, taskMC, taskJp, taskUs],
        (e) async {
          if (e != null) result.addAll(await e);
        },
      );

      // key: img url, value: href url
      if (updated) {
        final blockedWiki = await GitTool.giteeWikiPage('blocked_carousel');
        List<String> blocked = blockedWiki
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        result.removeWhere(
            (key, value) => blocked.any((word) => key.contains(word)));
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
  final CarouselController _carouselController = CarouselController();

  final double criticalWidth = 400;

  CarouselSetting get carouselSetting => db.userData.carouselSetting;

  @override
  void initState() {
    super.initState();
    carouselSetting.needUpdate = carouselSetting.shouldUpdate;
  }

  @override
  Widget build(BuildContext context) {
    if (!carouselSetting.enabled) return Container();
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
        return SizedBox(
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
            decorator: const DotsDecorator(
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
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
          const routePrefix = '/chaldea/route';
          if (link.toLowerCase().startsWith(routePrefix) &&
              link.length > routePrefix.length + 1) {
            Navigator.pushNamed(context, link.substring(routePrefix.length));
          } else if (await canLaunch(link)) {
            jumpToExternalLinkAlert(url: link);
          }
        },
        child: child,
      ));
    });
    return sliders;
  }
}
