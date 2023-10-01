import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:string_validator/string_validator.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/models/userdata/version.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/network.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/utils/wiki.dart';
import 'package:chaldea/widgets/carousel_util.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/image/image_viewer.dart';

class AppNewsCarousel extends StatefulWidget {
  final double? maxWidth;
  final List<Widget>? pages;

  AppNewsCarousel({super.key, this.maxWidth, this.pages});

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
          _result.add(CarouselItem(link: link, content: linkNode.text));
        }
      }
      _result.forEach((item) {
        print('img=${item.image}');
        print('  link=${item.link}');
        if (item.content != null) print('  content=${item.content}');
      });
      return _result;
    }

    List<CarouselItem> result = [];
    bool updated = false;
    try {
      Future<List<CarouselItem>>? taskChaldea, taskMC, taskJP, taskCN, taskTW, taskNA, taskKR;

      final _dio = DioE();

      // app news
      taskChaldea = _dio.get('${HostsX.data.cn}/news.json').then((response) async {
        List<CarouselItem> items = [];
        final newsData = List.from(response.data);
        items.addAll((newsData).map((e) => CarouselItem.fromJson(e)));
        final datVer = (await _dio.get('${HostsX.dataHost}/version.json')).data as Map;
        final minVer = AppVersion.parse(datVer['minimalApp']);
        if (minVer > AppInfo.version) {
          items.add(CarouselItem(
            type: 1,
            title: S.current.update,
            content: '${S.current.dataset_version}: ${datVer["utc"]}\n'
                '${S.current.error_required_app_version(minVer.versionString)}',
            link: ChaldeaUrl.doc('releases'),
          ));
        }

        if (!carouselSetting.enableChaldea) {
          items.removeWhere((item) => item.type != 1);
        }
        return items;
      }).catchError((e, s) async {
        logger.d('parse chaldea news failed', e, s);
        return <CarouselItem>[];
      });

      Future<Response> _getUrl(String url, {Map<String, String>? headers, bool? proxy}) {
        Map<String, String>? queryParameters;
        proxy ??= kIsWeb;
        if (proxy) {
          queryParameters = {'url': url};
          url = '${HostsX.workerHost}/corsproxy/';
        }
        return _dio.get(
          url,
          queryParameters: queryParameters,
          options: headers != null
              ? Options(
                  headers: {
                    if (proxy) ...{
                      'x-cors-headers': jsonEncode(headers),
                      'x-cors-fresh': '1',
                    },
                    if (!proxy) ...headers,
                  },
                )
              : null,
        );
      }

      List<int> _getEvents(bool Function(Event event) test) {
        return db.gameData.events.values.where((e) => test(e)).map((e) => e.id).toList();
      }

      List<int> _getWars(bool Function(NiceWar war) test) {
        return db.gameData.wars.values.where((e) => test(e)).map((e) => e.id).toList();
      }

      List<String> _getSummons(bool Function(LimitedSummon summon) test) {
        return db.gameData.wiki.summons.values.where((e) => test(e)).map((e) => e.id).toList();
      }

      bool isSameUrlPath(String? a, String? b) {
        if (a == null || b == null) return false;
        a = (Uri.tryParse(a)?.path ?? a).trimChar('/');
        b = (Uri.tryParse(b)?.path ?? b).trimChar('/');
        return a == b;
      }

      // mc slides
      if (carouselSetting.enableMooncell) {
        const mcUrl = 'https://fgo.wiki/w/模板:自动取值轮播';
        taskMC = _getUrl(mcUrl).then((response) {
          var doc = parser.parse(response.data.toString());
          var ele = doc.getElementById('transImageBox');
          updated = true;
          final items = _getImageLinks(element: ele, uri: Uri.parse('https://fgo.wiki/'));
          for (final item in items) {
            final fragments = item.link?.split('fgo.wiki/w/');
            if (fragments == null || fragments.length < 2) continue;
            String page = fragments[1];
            item.eventIds = _getEvents((event) => WikiTool.isSamePage(event.extra.mcLink, page));
            item.warIds = _getWars((war) => WikiTool.isSamePage(war.extra.mcLink, page));
            item.summonIds = _getSummons((summon) => WikiTool.isSamePage(summon.mcLink, page));
          }
          return items;
        }).catchError((e, s) async {
          logger.d('parse mc slides failed', e, s);
          return <CarouselItem>[];
        });
      }

      // jp slides
      if (carouselSetting.enableJP) {
        const jpUrl = 'https://view.fate-go.jp';
        taskJP = _getUrl(jpUrl).then((response) {
          var doc = parser.parse(response.data.toString());
          var ele = doc.getElementsByClassName('slide').getOrNull(0);
          updated = true;
          final items = _getImageLinks(element: ele, uri: Uri.parse(jpUrl));
          for (final item in items) {
            final link = item.link;
            if (link == null) continue;
            item.eventIds = _getEvents((event) => isSameUrlPath(event.extra.noticeLink.jp, link));
            item.warIds = _getWars((war) => isSameUrlPath(war.extra.noticeLink.jp, link));
            item.summonIds = _getSummons((summon) => isSameUrlPath(summon.noticeLink.jp, link));
          }
          return items;
        }).catchError((e, s) async {
          logger.d('parse JP slides failed', e, s);
          return <CarouselItem>[];
        });
      }

      if (carouselSetting.enableCN) {
        taskCN = _getUrl(
                'https://api.biligame.com/news/list.action?gameExtensionId=45&positionId=2&pageNum=1&pageSize=6&typeId=1')
            .then((response) async {
          final notices = (response.data as Map)["data"] as List;
          List<CarouselItem> items = [];
          for (final Map notice in notices) {
            final id = notice["id"] as int;
            final title = notice["title"] as String;
            if (id == 1509 || title.contains('维护')) continue;
            final data = (await _getUrl('https://api.biligame.com/news/$id.action')).data["data"];
            final content = data["content"] as String;
            String? img = RegExp(r'^([\s\S]{0,16})<img src="([^"]*)"').firstMatch(content)?.group(2);
            if (img == null) continue;
            img = Uri.https('game.bilibili.com', '/fgo/news.html').resolve(img).toString();
            items.add(CarouselItem(
              image: img,
              title: data['title'],
              link: PlatformU.isTargetMobile
                  ? 'https://game.bilibili.com/fgo/h5/news.html#detailId=$id'
                  : 'https://game.bilibili.com/fgo/news.html#!news/1/1/$id',
              eventIds: _getEvents((event) => event.extra.noticeLink.cn == id.toString()),
              warIds: _getWars((war) => war.extra.noticeLink.cn == id.toString()),
              summonIds: _getSummons((summon) => summon.noticeLink.cn == id.toString()),
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
        // https://www.fate-go.com.tw/newsmng/2026.json
        // https://www.fate-go.com.tw/newsmng/index.json
        taskTW = _getUrl('https://www.fate-go.com.tw/newsmng/index.json').then((response) async {
          final notices = List<Map>.from(response.data as List);
          notices.retainWhere((e) => e["category"] == 1);
          notices.sort2((e) => e["publish_time"] as int, reversed: true);
          List<CarouselItem> items = [];
          for (final Map notice in notices.take(5)) {
            final id = notice["id"] as int;
            final title = notice["title"] as String;
            if (title.contains('維護')) continue;
            final data = (await _getUrl('https://www.fate-go.com.tw/newsmng/$id.json')).data as Map;
            final content = data["content"] as String;
            String? img = RegExp(r'<img src="([^"]*)"').firstMatch(content)?.group(1);
            if (img == null) continue;
            img = Uri.https('www.fate-go.com.tw', '/news.html').resolve(img).toString();
            items.add(CarouselItem(
              image: img,
              title: data['title'],
              link: PlatformU.isTargetMobile
                  ? 'https://www.fate-go.com.tw/h5/news-m.html#detailId=$id'
                  : 'https://www.fate-go.com.tw/news.html#!news/1/1/$id',
              eventIds: _getEvents((event) => event.extra.noticeLink.tw == id.toString()),
              warIds: _getWars((war) => war.extra.noticeLink.tw == id.toString()),
              summonIds: _getSummons((summon) => summon.noticeLink.tw == id.toString()),
            ));
          }
          updated = true;
          return items;
        }).catchError((e, s) async {
          logger.d('parse TW notices failed', e, s);
          return <CarouselItem>[];
        });
      }

      // NA slides
      if (carouselSetting.enableNA) {
        const usUrl = 'https://webview.fate-go.us';
        taskNA = _getUrl(usUrl).then((response) {
          var doc = parser.parse(response.data.toString());
          var ele = doc.getElementsByClassName('slide').getOrNull(0);
          updated = true;
          final items = _getImageLinks(element: ele, uri: Uri.parse(usUrl));
          for (final item in items) {
            final link = item.link;
            if (link == null) continue;
            item.eventIds = _getEvents((event) => isSameUrlPath(event.extra.noticeLink.na, link));
            item.warIds = _getWars((war) => isSameUrlPath(war.extra.noticeLink.na, link));
            item.summonIds = _getSummons((summon) => isSameUrlPath(summon.noticeLink.na, link));
          }
          return items;
        }).catchError((e, s) async {
          logger.d('parse NA slides failed', e, s);
          return <CarouselItem>[];
        });
      }

      if (carouselSetting.enableKR && 1 > 2) {
        const krUrl = 'https://cafe.naver.com/MyCafeIntro.nhn?clubid=29199987';
        taskKR = _getUrl(krUrl, headers: {HttpHeaders.refererHeader: 'https://cafe.naver.com/fategokr'}, proxy: true)
            .then((response) {
          var doc = parser.parse(response.data.toString());
          var ele = doc.getElementsByTagName('table').getOrNull(0);
          updated = true;
          final items = _getImageLinks(element: ele, uri: Uri.parse(krUrl));
          items.retainWhere((e) =>
              e.image != null &&
              e.image!.contains('https://cafeskthumb-phinf.pstatic.net') &&
              !['http://fgo.netmarble.com/', 'https://www.facebook.com/FateGO.KR', 'https://twitter.com/FateGO_KR']
                  .contains(e.link));
          for (final item in items) {
            final link = item.link;
            if (link == null) continue;
            item.eventIds = _getEvents((event) => isSameUrlPath(event.extra.noticeLink.kr, link));
            item.warIds = _getWars((war) => isSameUrlPath(war.extra.noticeLink.kr, link));
            item.summonIds = _getSummons((summon) => isSameUrlPath(summon.noticeLink.kr, link));
          }
          return items;
        }).catchError((e, s) async {
          logger.d('parse KR slides failed', e, s);
          return <CarouselItem>[];
        });
      }

      await Future.forEach<Future<List<CarouselItem>>?>(
        [taskChaldea, taskMC, taskJP, taskCN, taskTW, taskNA, taskKR],
        (e) async {
          if (e != null) result.addAll(await e);
        },
      );
      // key: img url, value: href url
      if (carouselSetting.options.every((e) => !e)) {
        carouselSetting.items.clear();
      }
      if ((result.isNotEmpty || updated)) {
        List<String> blocked = (await CachedApi.remoteConfig())?.blockedCarousels ?? [];
        blocked.removeWhere((e) => e.isEmpty);
        result.removeWhere((item) => blocked.any((word) => item.image?.contains(word) == true));

        carouselSetting.items = result;
        carouselSetting.updateTime = DateTime.now().timestamp;
        if (showToast) {
          EasyLoading.showSuccess(S.current.updated);
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
    final limitOption = CarouselUtil.limitHeight(width: widget.maxWidth, maxHeight: 150);

    final pages = getPages(
        limitOption.height ?? (widget.maxWidth == null ? null : widget.maxWidth! / limitOption.aspectRatio),
        limitOption.aspectRatio);

    if (pages.isEmpty) {
      pages.add(GestureDetector(
        onTap: () {
          launch(ChaldeaUrl.docHome);
        },
        child: const AspectRatio(
          aspectRatio: 8 / 3,
          child: CachedImage(
            imageUrl: 'https://docs.chaldea.center/images/banner.jpg',
            // cachedOption: CachedImageOption(fit: BoxFit.cover),
          ),
        ),
      ));
    }
    _curCarouselIndex = pages.isEmpty ? 0 : _curCarouselIndex.clamp(0, pages.length - 1);

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
        if (pages.length > 1)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: DotsIndicator(
              dotsCount: pages.length,
              position: _curCarouselIndex,
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

  List<Widget> getPages(double? height, double aspectRatio) {
    if (widget.pages != null) return widget.pages!.toList();
    List<Widget> sliders = [];
    if (carouselSetting.needUpdate) {
      AppNewsCarousel.resolveSliderImageUrls().then((_) {
        if (mounted) setState(() {});
      });
      return sliders;
    }
    final items = carouselSetting.items.toList();
    final t = DateTime.now();
    items.removeWhere((item) {
      // if (!carouselSetting.enableChaldea && item.type != 1) return true;
      if (item.startTime.isAfter(t) || item.endTime.isBefore(t)) return true;
      if (item.verMin != null && item.verMin! > AppInfo.version) return true;
      if (item.verMax != null && item.verMax! < AppInfo.version) return true;
      return false;
    });
    items.sort((a, b) {
      if (a.priority != b.priority) return a.priority - b.priority;
      return a.startTime.compareTo(b.startTime);
    });
    for (final item in items) {
      if (item.priority < 0 && !kDebugMode) continue;
      Widget? child;
      final img = item.image;
      if (img != null && isURL(img)) {
        child = CachedImage(
          imageUrl: img,
          aspectRatio: aspectRatio,
          cachedOption: CachedImageOption(
            errorWidget: (context, url, error) => Container(
              child: kDebugMode ? Text(url) : const SizedBox(width: 80, height: 30),
            ),
            fit: item.fit,
          ),
        );
      } else if (item.content?.isNotEmpty == true) {
        if (item.md) {
          child = FittedBox(
            fit: BoxFit.scaleDown,
            child: MarkdownBody(data: item.content!),
          );
        } else {
          child = AutoSizeText(
            item.content!,
            textAlign: TextAlign.center,
            maxFontSize: 20,
            minFontSize: 5,
            maxLines: item.content!.split('\n').length,
          );
        }

        child = Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: child,
          ),
        );
        if (height != null && height > 0) {
          child = SizedBox(
            height: height,
            width: height * aspectRatio,
            child: Card(child: child),
          );
        }
      }
      if (child == null) continue;
      if (item.link != null ||
          item.content != null ||
          item.eventIds.isNotEmpty ||
          item.warIds.isNotEmpty ||
          item.summonIds.isNotEmpty) {
        child = GestureDetector(
          onTap: () => onTap(item),
          child: child,
        );
      }
      sliders.add(child);
    }
    return sliders;
  }

  void onTap(CarouselItem item) {
    final link = item.zhLink != null && Language.isZH ? item.zhLink : item.link;
    if (link != null) {
      const routePrefix = 'chaldea://';
      if (link.toLowerCase().startsWith(routePrefix) && link.length > routePrefix.length + 1) {
        router.push(url: link.substring(routePrefix.length));
        return;
      }
    }
    String? shownLink = link;
    if (link != null) {
      String? safeLink = Uri.tryParse(link)?.toString();
      if (safeLink != null) {
        shownLink = UriX.tryDecodeFull(safeLink);
      }
      shownLink ??= safeLink;
    }

    void openLink(String url) async {
      if (await canLaunch(url)) {
        launch(url);
      } else {
        EasyLoading.showError('Invalid link');
      }
    }

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        Widget _tile(String title, VoidCallback onTap) {
          return ListTile(
            dense: true,
            onTap: () {
              Navigator.pop(context);
              onTap();
            },
            trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
            title: Text(title),
            contentPadding: EdgeInsets.zero,
          );
        }

        return SimpleCancelOkDialog(
          title: Text(
            item.title ?? S.current.jump_to(''),
            maxLines: 2,
            style: Theme.of(context).textTheme.titleSmall,
            overflow: TextOverflow.ellipsis,
          ),
          scrollable: true,
          hideOk: link == null,
          onTapOk: link == null ? null : () => openLink(link),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(TextSpan(children: [
                if (item.content != null) TextSpan(text: item.content!),
                if (item.content != null && shownLink != null) const TextSpan(text: '\n\n'),
                if (shownLink != null)
                  SharedBuilder.textButtonSpan(
                    context: context,
                    text: shownLink,
                    onTap: () {
                      Navigator.pop(context);
                      openLink(shownLink!);
                    },
                  ),
              ])),
              for (final eventId in item.eventIds)
                _tile(
                  db.gameData.events[eventId]?.lName.l.setMaxLines(1) ?? '${S.current.event} $eventId',
                  () => router.push(url: Routes.eventI(eventId)),
                ),
              for (final warId in item.warIds)
                _tile(
                  db.gameData.wars[warId]?.lName.l.setMaxLines(1) ?? '${S.current.war} $warId',
                  () => router.push(url: Routes.warI(warId)),
                ),
              for (final summonId in item.summonIds)
                _tile(
                  db.gameData.wiki.summons[summonId]?.lName.setMaxLines(1) ?? '${S.current.summon} $summonId',
                  () => router.push(url: Routes.summonI(summonId)),
                ),
            ],
          ),
        );
      },
    );
  }
}
