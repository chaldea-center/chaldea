import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:string_validator/string_validator.dart';

import 'package:chaldea/app/tools/git_tool.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/network.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/carousel_util.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/image/image_viewer.dart';

class AppNewsCarousel extends StatefulWidget {
  final double? maxWidth;

  const AppNewsCarousel({Key? key, this.maxWidth}) : super(key: key);

  @override
  _AppNewsCarouselState createState() => _AppNewsCarouselState();

  static Future<void> resolveSliderImageUrls([bool showToast = false]) async {
    if (network.unavailable) {
      if (showToast) EasyLoading.showInfo(S.current.error_no_internet);
      return;
    }
    final carouselSetting = db.settings.carousel;
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
        updated = true;
      } else {
        final _dio = Dio();
        Future<List<CarouselItem>>? taskMC,
            taskJP,
            taskCN,
            taskTW,
            taskNA,
            taskKR;
        // mc slides
        if (carouselSetting.enableMooncell) {
          const mcUrl = 'https://fgo.wiki/w/模板:自动取值轮播';
          taskMC = _dio.get(mcUrl).then((response) {
            var doc = parser.parse(response.data.toString());
            var ele = doc.getElementById('transImageBox');
            updated = true;
            return _getImageLinks(element: ele, uri: Uri.parse(mcUrl));
          }).catchError((e, s) async {
            logger.d('parse mc slides failed', e, s);
            return <CarouselItem>[];
          });
        }

        // jp slides
        if (carouselSetting.enableJP) {
          const jpUrl = 'https://view.fate-go.jp';
          taskJP = _dio.get(jpUrl).then((response) {
            var doc = parser.parse(response.data.toString());
            var ele = doc.getElementsByClassName('slide').getOrNull(0);
            updated = true;
            return _getImageLinks(element: ele, uri: Uri.parse(jpUrl));
          }).catchError((e, s) async {
            logger.d('parse JP slides failed', e, s);
            return <CarouselItem>[];
          });
        }

        if (carouselSetting.enableCN) {
          final _dio = Dio(BaseOptions(baseUrl: 'https://api.biligame.com'));
          taskCN = _dio
              .get(
                  '/news/list.action?gameExtensionId=45&positionId=2&pageNum=1&pageSize=6&typeId=1')
              .then((response) async {
            final notices = (response.data as Map)["data"] as List;
            List<CarouselItem> items = [];
            for (final Map notice in notices) {
              final id = notice["id"] as int;
              final title = notice["title"] as String;
              if (id == 1509 || title.contains('维护')) continue;
              final data = (await _dio.get('/news/$id.action')).data["data"];
              final content = data["content"] as String;
              String? img = RegExp(r'^([\s\S]{0,16})<img src="([^"]*)"')
                  .firstMatch(content)
                  ?.group(2);
              if (img == null) continue;
              img = Uri.https('game.bilibili.com', '/fgo/news.html')
                  .resolve(img)
                  .toString();
              items.add(CarouselItem(
                image: img,
                text: data['title'],
                link: PlatformU.isTargetMobile
                    ? 'https://game.bilibili.com/fgo/h5/news.html#detailId=$id'
                    : 'https://game.bilibili.com/fgo/news.html#!news/1/1/$id',
              ));
            }
            updated = true;
            return items;
          }).catchError((e, s) async {
            logger.d('parse CN notices failed', e, s);
            return <CarouselItem>[];
          });
        }

        if (carouselSetting.enableTW) {
          final _dio = Dio(BaseOptions(baseUrl: 'https://www.fate-go.com.tw'));
          // https://www.fate-go.com.tw/newsmng/2026.json
          // https://www.fate-go.com.tw/newsmng/index.json
          taskTW = _dio.get('/newsmng/index.json').then((response) async {
            final notices = List<Map>.from(response.data as List);
            notices.retainWhere((e) => e["category"] == 1);
            notices.sort2((e) => e["publish_time"] as int, reversed: true);
            List<CarouselItem> items = [];
            for (final Map notice in notices.take(5)) {
              final id = notice["id"] as int;
              final title = notice["title"] as String;
              if (title.contains('維護')) continue;
              final data = (await _dio.get('/newsmng/$id.json')).data as Map;
              final content = data["content"] as String;
              String? img =
                  RegExp(r'<img src="([^"]*)"').firstMatch(content)?.group(1);
              if (img == null) continue;
              img = Uri.https('www.fate-go.com.tw', '/news.html')
                  .resolve(img)
                  .toString();
              items.add(CarouselItem(
                image: img,
                text: data['title'],
                link: PlatformU.isTargetMobile
                    ? 'https://www.fate-go.com.tw/h5/news-m.html#detailId=$id'
                    : 'https://www.fate-go.com.tw/news.html#!news/1/1/$id',
              ));
            }
            updated = true;
            return items;
          }).catchError((e, s) async {
            logger.d('parse TW notices failed', e, s);
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
        if (carouselSetting.enableNA) {
          const usUrl = 'https://webview.fate-go.us';
          taskNA = _dio.get(usUrl).then((response) {
            var doc = parser.parse(response.data.toString());
            var ele = doc.getElementsByClassName('slide').getOrNull(0);
            updated = true;
            return _getImageLinks(element: ele, uri: Uri.parse(usUrl));
          }).catchError((e, s) async {
            logger.d('parse NA slides failed', e, s);
            return <CarouselItem>[];
          });
        }

        if (carouselSetting.enableKR) {
          const krUrl =
              'https://cafe.naver.com/MyCafeIntro.nhn?clubid=29199987';
          final options = Options(headers: {
            HttpHeaders.refererHeader: 'https://cafe.naver.com/fategokr'
          });
          taskKR = _dio.get(krUrl, options: options).then((response) {
            var doc = parser.parse(response.data.toString());
            var ele = doc.getElementsByTagName('table').getOrNull(0);
            updated = true;
            final items = _getImageLinks(element: ele, uri: Uri.parse(krUrl));
            items.removeWhere((element) => {
                  'http://fgo.netmarble.com/',
                  'https://www.facebook.com/FateGO.KR',
                  'https://twitter.com/FateGO_KR'
                }.contains(element.link));
            return items;
          }).catchError((e, s) async {
            logger.d('parse KR slides failed', e, s);
            return <CarouselItem>[];
          });
        }

        await Future.forEach<Future<List<CarouselItem>>?>(
          [taskMC, taskJP, taskCN, taskTW, taskNA, taskKR],
          (e) async {
            if (e != null) result.addAll(await e);
          },
        );
      }

      // key: img url, value: href url
      if (carouselSetting.options.every((e) => !e)) {
        carouselSetting.items.clear();
      }
      if ((result.isNotEmpty || updated) && !kIsWeb) {
        final blockedWiki = await GitTool.giteeWikiPage('blocked_carousel');
        List<String> blocked = blockedWiki
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        result.removeWhere((item) =>
            blocked.any((word) => item.image?.contains(word) == true));
        carouselSetting.items = result;
        carouselSetting.updateTime = DateTime.now().timestamp;
        if (showToast) {
          EasyLoading.showSuccess(S.current.update_msg_succuss);
        }
      } else {
        if (showToast) {
          EasyLoading.showInfo(S.current.update_msg_no_update);
        }
      }
    } catch (e, s) {
      logger.e('Error refresh slides', e, s);
      if (showToast) {
        EasyLoading.showError(S.current.update_msg_error);
      }
    }
  }
}

class _AppNewsCarouselState extends State<AppNewsCarousel> {
  int _curCarouselIndex = 0;
  final CarouselController _carouselController = CarouselController();

  CarouselSetting get carouselSetting => db.settings.carousel;

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

    if (pages.isEmpty) {
      pages.add(GestureDetector(
        onTap: () {
          launch(kProjectDocRoot);
        },
        child: AspectRatio(
          aspectRatio: 8 / 3,
          child: CachedImage(
            imageUrl: Atlas.asset('Back/back10111.png'),
            cachedOption: const CachedImageOption(fit: BoxFit.cover),
          ),
        ),
      ));
    }
    _curCarouselIndex =
        pages.isEmpty ? 0 : _curCarouselIndex.clamp(0, pages.length - 1);

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
                _curCarouselIndex = v.toInt().clamp(0, pages.length - 1);
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
              jumpToExternalLinkAlert(url: link, content: item.text);
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
