import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/constants.dart';

class CarouselSettingPage extends StatefulWidget {
  const CarouselSettingPage({super.key});

  @override
  _CarouselSettingPageState createState() => _CarouselSettingPageState();
}

class _CarouselSettingPageState extends State<CarouselSettingPage> {
  CarouselSetting get carousel => db.settings.carousel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.carousel_setting)),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            value: carousel.enabled,
            title: Text(S.current.show_carousel),
            onChanged: (v) {
              setState(() {
                carousel.enabled = v;
                carousel.needUpdate = true;
                db.notifySettings();
              });
            },
          ),
          kIndentDivider,
          CheckboxListTile(
            value: carousel.enableChaldea,
            title: const Text('Chaldea Announcements'),
            subtitle: const Text('https://docs.chaldea.center'),
            onChanged: carousel.enabled
                ? (v) => setState(() {
                      carousel.needUpdate = true;
                      carousel.enableChaldea = v ?? carousel.enableChaldea;
                      updateHome();
                    })
                : null,
          ),
          CheckboxListTile(
            value: carousel.enableMooncell,
            title: const Text('Mooncell News'),
            subtitle: const Text('CN/JP'),
            onChanged: carousel.enabled
                ? (v) => setState(() {
                      carousel.needUpdate = true;
                      carousel.enableMooncell = v ?? carousel.enableMooncell;
                      updateHome();
                    })
                : null,
          ),
          CheckboxListTile(
            value: carousel.enableJP,
            title: const Text('JP News'),
            subtitle: const Text('https://view.fate-go.jp/'),
            onChanged: carousel.enabled
                ? (v) => setState(() {
                      carousel.needUpdate = true;
                      carousel.enableJP = v ?? carousel.enableJP;
                      updateHome();
                    })
                : null,
          ),
          CheckboxListTile(
            value: carousel.enableCN,
            title: const Text('CN News'),
            subtitle: const Text('https://game.bilibili.com/fgo/news.html'),
            onChanged: carousel.enabled
                ? (v) => setState(() {
                      carousel.needUpdate = true;
                      carousel.enableCN = v ?? carousel.enableCN;
                      updateHome();
                    })
                : null,
          ),
          CheckboxListTile(
            value: carousel.enableTW,
            title: const Text('TW News'),
            subtitle: const Text('https://www.fate-go.com.tw/news.html'),
            onChanged: carousel.enabled
                ? (v) => setState(() {
                      carousel.needUpdate = true;
                      carousel.enableTW = v ?? carousel.enableTW;
                      updateHome();
                    })
                : null,
          ),
          CheckboxListTile(
            value: carousel.enableNA,
            title: const Text('NA News'),
            subtitle: const Text('https://webview.fate-go.us/'),
            onChanged: carousel.enabled && !PlatformU.isWindows
                ? (v) => setState(() {
                      carousel.needUpdate = true;
                      carousel.enableNA = v ?? carousel.enableNA;
                      updateHome();
                    })
                : null,
          ),
          CheckboxListTile(
            value: carousel.enableKR,
            title: const Text('KR News'),
            subtitle: const Text('https://cafe.naver.com/fategokr'),
            onChanged: carousel.enabled && !PlatformU.isWindows
                ? (v) => setState(() {
                      carousel.needUpdate = true;
                      carousel.enableKR = v ?? carousel.enableKR;
                      updateHome();
                    })
                : null,
          ),
        ],
      ),
    );
  }

  void updateHome() {
    if (SplitRoute.isSplit(context)) {
      db.notifySettings();
    }
  }
}
