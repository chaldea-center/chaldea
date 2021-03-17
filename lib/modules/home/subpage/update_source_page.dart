import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/git_tool.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateSourcePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UpdateSourcePageState();
}

class _UpdateSourcePageState extends State<UpdateSourcePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).download_source),
        leading: BackButton(),
      ),
      body: ListView(
        children: [
          TileGroup(
            header: 'Git - In-App dataset upgrade',
            children: [
              choice(0),
              choice(1),
            ],
          ),
          TileGroup(
            header: 'Temporary',
            footer: '',
            children: [
              ListTile(
                leading: Icon(Icons.cloud_circle, size: 28),
                title: Text('Lanzou/woozooo'),
                subtitle: RichText(
                  text: TextSpan(
                    text: 'https://wws.lanzous.com/b01tuahmf\n',
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: 'password: chaldea',
                        style: TextStyle(color: Colors.redAccent[100]),
                      )
                    ],
                  ),
                ),
                horizontalTitleGap: 0,
                onTap: () {
                  jumpToExternalLinkAlert(
                      url: 'https://wws.lanzous.com/b01tuahmf');
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget choice(int index) {
    final gitTool = GitTool.fromIndex(index);
    return SimpleAccordion(
      canTapOnHeader: false,
      headerBuilder: (BuildContext context, bool expanded) {
        return RadioListTile<int>(
          value: index,
          groupValue: db.userData.updateSource,
          title: Text(gitTool.source.toTitleString()),
          subtitle: Text(gitTool.source == GitSource.github
              ? 'Github may be blocked sometimes'
              : 'May be outdated'),
          onChanged: (v) {
            setState(() {
              if (v != null) {
                db.userData.updateSource = v;
                db.notifyDbUpdate();
              }
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        );
      },
      contentBuilder: (BuildContext context) {
        List<Widget> children = [];
        for (String repo in ['chaldea', 'chaldea-dataset']) {
          final url = gitTool.releasesPage(repo);
          children.add(ListTile(
            leading: Icon(gitTool.source == GitSource.github
                ? FontAwesomeIcons.github
                : FontAwesomeIcons.git),
            dense: true,
            contentPadding: EdgeInsets.only(left: 20, right: 8),
            // horizontalTitleGap: 0,
            title: Text(repo),
            subtitle: Text(url),
            onTap: () {
              launch(url);
            },
          ));
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      },
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    db.saveUserData();
  }
}
