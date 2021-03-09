//@dart=2.12
import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/git_tool.dart';
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
      body: TileGroup(
        children: List.generate(GitSource.values.length, (index) {
          final bool _isCur = index == db.userData.updateSource;
          String source = GitSource.values[index].toTitleString();
          return ListTile(
            leading: Icon(
              Icons.check,
              // size: 18.0,
              color:
                  _isCur ? Theme.of(context).primaryColor : Colors.transparent,
            ),
            title: Text(source),
            selected: _isCur,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    launch(GitTool.getReleasePageUrl(index, false));
                  },
                  child: Text('DATA'),
                ),
                TextButton(
                  onPressed: () {
                    // macOS has App Store version and Developer distribution
                    if (Platform.isIOS) {
                      launch(kAppStoreLink);
                    } else {
                      launch(GitTool.getReleasePageUrl(index, true));
                    }
                  },
                  child: Text('APP'),
                )
              ],
            ),
            onTap: () {
              db.userData.updateSource = index;
              db.notifyAppUpdate();
            },
            horizontalTitleGap: 0,
          );
        }).toList(),
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    db.saveUserData();
  }
}
