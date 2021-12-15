import 'package:chaldea/components/components.dart';

class CarouselSettingPage extends StatefulWidget {
  const CarouselSettingPage({Key? key}) : super(key: key);

  @override
  _CarouselSettingPageState createState() => _CarouselSettingPageState();
}

class _CarouselSettingPageState extends State<CarouselSettingPage> {
  CarouselSetting get carousel => db.userData.carouselSetting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.carousel_setting)),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            value: carousel.enabled,
            title: Text(LocalizedText.of(
                chs: '显示轮播图',
                jpn: 'カルーセルを表示',
                eng: 'Show Carousel',
                kor: '배너 표시')),
            onChanged: (v) {
              setState(() {
                carousel.enabled = v;
                carousel.needUpdate = true;
                db.notifyAppUpdate();
              });
            },
          ),
          kIndentDivider,
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
            value: carousel.enableJp,
            title: const Text('JP News'),
            subtitle: const Text('https://view.fate-go.jp/'),
            onChanged: carousel.enabled
                ? (v) => setState(() {
                      carousel.needUpdate = true;
                      carousel.enableJp = v ?? carousel.enableJp;
                      updateHome();
                    })
                : null,
          ),
          CheckboxListTile(
            value: carousel.enableUs,
            title: const Text('NA News'),
            subtitle: Text(
                (PlatformU.isWindows ? 'BUG on Windows for NA\n' : '') +
                    'https://webview.fate-go.us/'),
            onChanged: carousel.enabled && !PlatformU.isWindows
                ? (v) => setState(() {
                      carousel.needUpdate = true;
                      carousel.enableUs = v ?? carousel.enableUs;
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
      db.notifyAppUpdate();
    }
  }
}
