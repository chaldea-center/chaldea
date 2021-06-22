import 'package:chaldea/components/components.dart';
import 'package:url_launcher/url_launcher.dart';

import 'about_page.dart';
import 'feedback_page.dart';
import 'share_app_dialog.dart';

class AboutAppPage extends StatefulWidget {
  const AboutAppPage({Key? key}) : super(key: key);

  @override
  _AboutAppPageState createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(S.current.about_app),
      ),
      body: ListView(
        children: [
          TileGroup(
            header: S.of(context).about_app,
            children: <Widget>[
              ListTile(
                title: Text(MaterialLocalizations.of(context)
                    .aboutListTileTitle(AppInfo.appName)),
                trailing: db.runtimeData.upgradableVersion == null
                    ? null
                    : Text(
                        db.runtimeData.upgradableVersion!.version + ' ↑',
                        style: TextStyle(),
                      ),
                onTap: () => SplitRoute.push(
                  context: context,
                  builder: (context, _) => AboutPage(),
                  popDetail: true,
                ),
              ),
              if (!kReleaseMode)
                ListTile(
                  title: Text(S.of(context).settings_tutorial),
                  onTap: () {
                    EasyLoading.showToast(
                        Language.isCN ? '咕咕咕咕咕咕' : "Not implemented");
                  },
                ),
              ListTile(
                title: Text(S.of(context).about_feedback),
                onTap: () {
                  SplitRoute.push(
                    context: context,
                    builder: (context, _) => FeedbackPage(),
                    detail: true,
                    popDetail: true,
                  );
                },
              ),
              if (Platform.isIOS || Platform.isMacOS)
                ListTile(
                  title: Text(LocalizedText.of(
                      chs: 'App Store评分',
                      jpn: 'App Storeでのレート ',
                      eng: 'Rate on App Store')),
                  onTap: () {
                    launch(kAppStoreLink);
                  },
                ),
              if (Platform.isAndroid)
                ListTile(
                  title: Text(LocalizedText.of(
                      chs: 'Google Play评分',
                      jpn: 'Google Playでのレート ',
                      eng: 'Rate on Google Play')),
                  onTap: () {
                    launch(kGooglePlayLink);
                  },
                ),
              ListTile(
                title: Text(S.current.share),
                onTap: () => ShareAppDialog().showDialog(context),
              )
            ],
          ),
          TileGroup(
            header: 'Support Chaldea',
            children: [
              ListTile(
                title: Text(S.current.support_chaldea),
                onTap: () {
                  launch(kProjectHomepage + '/wiki/Support');
                },
              ),
              ListTile(
                title: Text('Starring on Github'),
                subtitle: Text(kProjectHomepage),
                onTap: () {
                  launch(kProjectHomepage);
                },
              ),
              ListTile(
                title: Text('Contribution/Collaboration'),
                subtitle: Text('e.g. Translation'),
                onTap: () {
                  SimpleCancelOkDialog(
                    title: Text('Contribute to Chaldea'),
                    content: Text(
                        'Collaboration is welcomed, please contact us through email:\n'
                        '$kSupportTeamEmailAddress'),
                    scrollable: true,
                  ).showDialog(context);
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
