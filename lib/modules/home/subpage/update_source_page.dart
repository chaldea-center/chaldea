import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/git_tool.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as pathlib;
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
          // TileGroup(
          //   children: [
          //     SwitchListTile.adaptive(
          //       value: false,
          //       onChanged: (v){
          //         // db.userData;
          //       },
          //       title: Text('Auto Update'),
          //       subtitle: Text('only dataset'),
          //       controlAffinity: ListTileControlAffinity.trailing,
          //     ),
          //   ],
          // ),
          TileGroup(
            children: [
              ListTile(
                title: Text(S.current.version),
                subtitle: Text(S.current.gamedata),
                trailing: Text(db.gameData.version),
              )
            ],
          ),
          TileGroup(
            header: 'Git - In-App dataset update',
            children: [
              sourceAccordion(
                source: GitSource.github,
                subtitle: S.current.github_source_hint,
              ),
              sourceAccordion(
                source: GitSource.gitee,
                subtitle: S.current.gitee_source_hint,
              ),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              // ElevatedButton(onPressed: () {}, child: Text('应用更新')),
              ElevatedButton(
                onPressed: downloadGamedata,
                child: Text(S.current.update_dataset),
              ),
            ],
          ),
          TileGroup(
            header: S.of(context).backup,
            footer: 'Installer for Android/Windows/macOS.',
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

  Widget sourceAccordion({required GitSource source, String? subtitle}) {
    final gitTool = GitTool(source);
    return SimpleAccordion(
      canTapOnHeader: false,
      headerBuilder: (BuildContext context, bool expanded) {
        return RadioListTile<int>(
          value: source.toIndex(),
          groupValue: db.userData.updateSource,
          title: Text(source.toTitleString()),
          subtitle: subtitle == null ? null : Text(subtitle),
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
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(source == GitSource.github
                  ? FontAwesomeIcons.github
                  : FontAwesomeIcons.git),
              dense: true,
              contentPadding: EdgeInsets.only(left: 20, right: 8),
              // horizontalTitleGap: 0,
              title: Text('Chaldea app'),
              subtitle: Text(gitTool.appReleaseUrl),
              onTap: () {
                jumpToExternalLinkAlert(url: gitTool.appReleaseUrl);
              },
            ),
            ListTile(
              leading: Icon(source == GitSource.github
                  ? FontAwesomeIcons.github
                  : FontAwesomeIcons.git),
              dense: true,
              contentPadding: EdgeInsets.only(left: 20, right: 8),
              // horizontalTitleGap: 0,
              title: Text('Dataset'),
              subtitle: Text(gitTool.datasetReleaseUrl),
              onTap: () {
                jumpToExternalLinkAlert(url: gitTool.datasetReleaseUrl);
              },
            )
          ],
        );
      },
    );
  }

  void downloadGamedata() {
    final gitTool = GitTool.fromDb();
    void _downloadAsset([bool fullSize = true]) async {
      final release = await gitTool.latestDatasetRelease(fullSize);
      Navigator.of(context).pop();
      String fp = pathlib.join(
          db.paths.tempDir, '${release?.name}-${release?.targetAsset?.name}');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => DownloadDialog(
          url: release?.targetAsset?.browserDownloadUrl ?? '',
          savePath: fp,
          notes: release?.body,
          confirmText: S.of(context).import_data.toUpperCase(),
          onComplete: () async {
            var canceler = showMyProgress(status: 'loading');
            try {
              await db.extractZip(fp: fp, savePath: db.paths.gameDir);
              db.loadGameData();
              Navigator.of(context).pop();
              canceler();
              EasyLoading.showToast(S.of(context).import_data_success);
            } catch (e) {
              canceler();
              EasyLoading.showToast(S.of(context).import_data_error(e));
            } finally {}
          },
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(S.of(context).dataset_type_entire),
              subtitle: Text(S.of(context).dataset_type_entire_hint),
              onTap: () => _downloadAsset(true),
            ),
            ListTile(
              title: Text(S.of(context).dataset_type_text),
              subtitle: Text(S.of(context).dataset_type_text_hint),
              onTap: () => _downloadAsset(false),
            ),
            ListTile(
              title: Text(S.of(context).dataset_goto_download_page),
              subtitle: Text(S.of(context).dataset_goto_download_page_hint),
              onTap: () {
                launch(gitTool.datasetReleaseUrl);
              },
            )
          ],
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
