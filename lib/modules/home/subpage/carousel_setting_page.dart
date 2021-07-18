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
        leading: BackButton(),
        title: Text(S.current.carousel_setting),
      ),
      body: ListView(
        children: divideTiles(
          [
            CheckboxListTile(
              value: carousel.enableMooncell,
              title: Text('Mooncell News'),
              subtitle: Text('CN/JP'),
              onChanged: (v) {
                setState(() {
                  carousel.needUpdate = true;
                  carousel.enableMooncell = v ?? carousel.enableMooncell;
                });
              },
            ),
            CheckboxListTile(
              value: carousel.enableJp,
              title: Text('JP News'),
              subtitle: Text('https://view.fate-go.jp/'),
              onChanged: (v) {
                setState(() {
                  carousel.needUpdate = true;
                  carousel.enableJp = v ?? carousel.enableJp;
                });
              },
            ),
            CheckboxListTile(
              value: carousel.enableUs,
              title: Text('NA News'),
              subtitle: Text('https://webview.fate-go.us/'),
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
