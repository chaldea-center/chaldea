import 'package:chaldea/components/components.dart';

class CarouselSettingPage extends StatefulWidget {
  const CarouselSettingPage({Key? key}) : super(key: key);

  @override
  _CarouselSettingPageState createState() => _CarouselSettingPageState();
}

class _CarouselSettingPageState extends State<CarouselSettingPage> {
  CarouselSetting get setting => db.userData.carouselSetting;

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
              value: setting.enableMooncell,
              title: Text('Mooncell News'),
              subtitle: Text('CN/JP'),
              onChanged: (v) {
                setState(() {
                  setting.needUpdate = true;
                  setting.enableMooncell = v ?? setting.enableMooncell;
                });
              },
            ),
            CheckboxListTile(
              value: setting.enableJp,
              title: Text('JP News'),
              subtitle: Text('https://view.fate-go.jp/'),
              onChanged: (v) {
                setState(() {
                  setting.needUpdate = true;
                  setting.enableJp = v ?? setting.enableJp;
                });
              },
            ),
            CheckboxListTile(
              value: setting.enableUs,
              title: Text('NA News'),
              subtitle: Text('https://webview.fate-go.us/'),
              onChanged: (v) {
                setState(() {
                  setting.needUpdate = true;
                  setting.enableUs = v ?? setting.enableUs;
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
