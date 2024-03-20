import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/material.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../feedback_page.dart';

class AdSettingPage extends StatefulWidget {
  const AdSettingPage({super.key});

  @override
  State<AdSettingPage> createState() => _AdSettingPageState();
}

class _AdSettingPageState extends State<AdSettingPage> {
  AdSetting get setting => db.settings.display.ad;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.ad)),
      body: ListView(
        children: [
          TileGroup(
            header: 'Ads',
            footer: "Will try not to affect normal use as much as possible",
            children: [
              CheckboxListTile.adaptive(
                tristate: true,
                value: setting.banner,
                title: const Text("Banner AD"),
                subtitle: Text('e.g. ${S.current.carousel}'),
                onChanged: (v) {
                  setState(() {
                    setting.banner = v;
                  });
                },
              ),
              CheckboxListTile.adaptive(
                tristate: true,
                value: setting.appOpen,
                title: const Text("App Open"),
                onChanged: (v) {
                  setState(() {
                    setting.appOpen = v;
                  });
                },
              ),
            ],
          ),
          TileGroup(
            header: S.current.about_feedback,
            footer: "If there is any inappropriate ad, please send feedback with info like screenshot/country/time.",
            children: [
              ListTile(
                title: Text(S.current.about_feedback),
                trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () {
                  router.pushPage(FeedbackPage());
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
