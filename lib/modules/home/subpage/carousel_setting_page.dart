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
              title: Text('Mooncell'),
              subtitle: Text('CN/JP'),
              onChanged: (v) {
                setState(() {
                  setting.enableMooncell = v ?? setting.enableMooncell;
                });
              },
            ),
            CheckboxListTile(
              value: setting.enableJp,
              title: Text('JP News'),
              onChanged: (v) {
                setState(() {
                  setting.enableJp = v ?? setting.enableJp;
                });
              },
            ),
            CheckboxListTile(
              value: setting.enableUs,
              title: Text('US News'),
              onChanged: (v) {
                setState(() {
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
