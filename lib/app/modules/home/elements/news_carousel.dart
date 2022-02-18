import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chaldea/components/git_tool.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/network.dart';
import 'package:chaldea/utils/atlas.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/carousel_util.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/image/image_viewer.dart';
import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
    if (network.unavailable) {
      if (showToast) EasyLoading.showInfo(S.current.error_no_network);
      return;
    }
    final carouselSetting = db2.settings.carousel;
    carouselSetting.needUpdate = false;
    List<CarouselItem> _getImageLinks({
      required dom.Element? element,
      required Uri uri,
      String attr = 'src',
      bool custom = false,
    }) {
      List<CarouselItem> _result = [];
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
            _result.add(CarouselItem(link: link, image: imgUrl));
          }
        } else if (linkNode.text.isNotEmpty && custom) {
          _result.add(CarouselItem(link: link, text: linkNode.text));
        }
      }
      _result.forEach((item) {
        print('img=${item.image}');
        print('  link=${item.link}');
        if (item.text != null) print('  text=${item.text}');
      });
      return _result;
    }

    List<CarouselItem> result = [];
    bool updated = false;
    try {
      // CORS issue
      if (kIsWeb) {
        result.add(CarouselItem(
          image: Atlas.asset('Back/back10111.png'),
          fit: BoxFit.cover,
        ));
        updated = true;
      } else {
        final _dio = Dio();
        Future<List<CarouselItem>>? taskMC, taskJp, taskUs;
        // mc slides
        if (carouselSetting.enableMooncell) {
          const mcUrl = 'https://fgo.wiki/w/模板:自动取值轮播';
          taskMC = _dio.get(mcUrl).then((response) {
            var mcParser = parser.parse(response.data.toString());
            var mcElement = mcParser.getElementById('transImageBox');
            updated = true;
            return _getImageLinks(element: mcElement, uri: Uri.parse(mcUrl));
          }).catchError((e, s) async {
            logger.e('parse mc slides failed', e, s);
            return <CarouselItem>[];
          });
        }

        // jp slides
        if (carouselSetting.enableJp) {
          const jpUrl = 'https://view.fate-go.jp';
          taskJp = _dio.get(jpUrl).then((response) {
            var jpParser = parser.parse(response.data.toString());
            var jpElement =
                jpParser.getElementsByClassName('slide').getOrNull(0);
            updated = true;
            return _getImageLinks(element: jpElement, uri: Uri.parse(jpUrl));
          }).catchError((e, s) async {
            logger.e('parse jp slides failed', e, s);
            return <CarouselItem>[];
          });
        }

        // gitee, always
        // taskGitee = GitTool.giteeWikiPage('Announcement', htmlFmt: true)
        //     .then((String content) {
        //   var announceParser = parser.parse(content);
        //   var announceElement = announceParser.body;
        //   updated = true;
        //   return _getImageLinks(
        //       element: announceElement,
        //       uri: Uri.parse(
        //           'https://gitee.com/chaldea-center/chaldea/wikis/Announcement'),
        //       custom: true);
        // }).catchError((e, s) async {
        //   logger.e('parse gitee announce slides failed', e, s);
        //   return <String, String>{};
        // });

        // NA slides
        if (carouselSetting.enableUs) {
          const usUrl = 'https://webview.fate-go.us';
          taskUs = _dio.get(usUrl).then((response) {
            var usParser = parser.parse(response.data.toString());
            var usElement =
                usParser.getElementsByClassName('slide').getOrNull(0);
            updated = true;
            return _getImageLinks(element: usElement, uri: Uri.parse(usUrl));
          }).catchError((e, s) async {
            logger.e('parse NA slides failed', e, s);
            return <CarouselItem>[];
          });
        }

        await Future.forEach<Future<List<CarouselItem>>?>(
          // [taskUs],
          [taskMC, taskJp, taskUs],
          (e) async {
            if (e != null) result.addAll(await e);
          },
        );
      }

      // key: img url, value: href url
      if (updated) {
        final blockedWiki = await GitTool.giteeWikiPage('blocked_carousel');
        List<String> blocked = blockedWiki
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        result.removeWhere((item) =>
            blocked.any((word) => item.image?.contains(word) == true));
        carouselSetting.items = result;
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

  CarouselSetting get carouselSetting => db2.settings.carousel;

  @override
  void initState() {
    super.initState();
    carouselSetting.needUpdate = carouselSetting.shouldUpdate;
  }

  @override
  Widget build(BuildContext context) {
    final limitOption =
        CarouselUtil.limitHeight(width: widget.maxWidth, maxHeight: 150);

    final pages = getPages();

    _curCarouselIndex =
        Maths.fixValidRange(_curCarouselIndex, 0, pages.length - 1);

    /// No slides, show app logo
    if (pages.isEmpty) {
      final logo = FractionallySizedBox(
        heightFactor: 0.6,
        child: Image.asset('res/img/launcher_icon/app_icon_logo.png'),
      );
      if (limitOption.limited) {
        return SizedBox(
          height: limitOption.height,
          child: logo,
        );
      } else {
        return AspectRatio(
          aspectRatio: 8 / 3,
          child: Container(child: logo),
        );
      }
    }

    CarouselOptions options = CarouselOptions(
        height: limitOption.height,
        aspectRatio: limitOption.aspectRatio,
        autoPlay: pages.length > 1,
        autoPlayInterval: const Duration(seconds: 6),
        viewportFraction: limitOption.viewportFraction,
        enlargeCenterPage: limitOption.enlargeCenterPage,
        enlargeStrategy: limitOption.enlargeStrategy,
        initialPage: _curCarouselIndex,
        onPageChanged: (v, _) {
          setState(() {
            _curCarouselIndex = v;
          });
        });
    // if (useFullWidth) {
    //   options = CarouselOptions(
    //     aspectRatio: 8.0 / 3.0,
    //     autoPlay: pages.length > 1,
    //     autoPlayInterval: const Duration(seconds: 6),
    //     viewportFraction: 1,
    //     initialPage: _curCarouselIndex,
    //     onPageChanged: (v, _) => setState(() {
    //       _curCarouselIndex = v;
    //     }),
    //   );
    // } else {
    //   options = CarouselOptions(
    //     height: criticalWidth * 3 / 8,
    //     autoPlay: pages.length > 1,
    //     autoPlayInterval: const Duration(seconds: 6),
    //     viewportFraction: criticalWidth / widget.maxWidth!,
    //     enlargeCenterPage: true,
    //     enlargeStrategy: CenterPageEnlargeStrategy.height,
    //     initialPage: _curCarouselIndex,
    //     onPageChanged: (v, _) => setState(() {
    //       _curCarouselIndex = v;
    //     }),
    //   );
    // }
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
                    Maths.fixValidRange(v.toInt(), 0, pages.length - 1);
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
    for (final item in carouselSetting.items) {
      Widget? child;
      if (item.image != null && isURL(item.image!)) {
        child = CachedImage(
          imageUrl: item.image,
          aspectRatio: 8 / 3,
          cachedOption: CachedImageOption(
            errorWidget: (context, url, error) => Container(),
            fit: item.fit,
          ),
        );
      } else if (item.text?.isNotEmpty == true) {
        child = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Center(
            child: AutoSizeText(
              item.text!,
              textAlign: TextAlign.center,
              maxFontSize: 20,
              minFontSize: 5,
              maxLines: item.text!.split('\n').length,
            ),
          ),
        );
      }
      if (child == null) continue;
      if (item.link != null) {
        child = GestureDetector(
          onTap: () async {
            final link = item.link!;
            const routePrefix = '/chaldea/route';
            if (link.toLowerCase().startsWith(routePrefix) &&
                link.length > routePrefix.length + 1) {
              Navigator.pushNamed(context, link.substring(routePrefix.length));
            } else if (await canLaunch(link)) {
              jumpToExternalLinkAlert(url: link);
            }
          },
          child: child,
        );
      }
      sliders.add(child);
    }
    return sliders;
  }
}
