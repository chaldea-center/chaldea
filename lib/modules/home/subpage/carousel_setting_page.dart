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
      appBar: AppBar(
        title: Text(S.current.carousel_setting),
      ),
      body: ListView(
        children: divideTiles(
          [
            CheckboxListTile(
              value: carousel.enableMooncell,
              title: const Text('Mooncell News'),
              subtitle: const Text('CN/JP'),
              onChanged: (v) {
                setState(() {
                  carousel.needUpdate = true;
                  carousel.enableMooncell = v ?? carousel.enableMooncell;
                });
              },
            ),
            CheckboxListTile(
              value: carousel.enableJp,
              title: const Text('JP News'),
              subtitle: const Text('https://view.fate-go.jp/'),
              onChanged: (v) {
                setState(() {
                  carousel.needUpdate = true;
                  carousel.enableJp = v ?? carousel.enableJp;
                });
              },
            ),
            CheckboxListTile(
              value: carousel.enableUs,
              title: const Text('NA News'),
              subtitle: const Text('https://webview.fate-go.us/'),
              onChanged: (v) {
                setState(() {
                  carousel.needUpdate = true;
                  carousel.enableUs = v ?? carousel.enableUs;
                });
              },
            ),
          ],
          bottom: true,
        ),
      ),
    );
  }
}
