import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/git_tool.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final references = const {
    'TYPE-MOON/FGO PROJECT': 'https://www.fate-go.jp',
    'Mooncell': 'https://fgo.wiki',
    'NGA-FGO版块': 'https://bbs.nga.cn/thread.php?fid=540',
    '效率剧场': 'https://sites.google.com/view/fgo-domus-aurea'
  };

  final crashFile = File(db.paths.crashLog);
  String crashLog;

  @override
  void initState() {
    super.initState();
    loadLog();
    if (AppInfo.info == null) {
      AppInfo.resolve().then((value) {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {});
        });
      });
    }
  }

  void loadLog() {
    if (crashFile.existsSync()) {
      crashLog = 'loading...';
      crashFile.readAsLines().then((lines) {
        crashLog =
            lines.sublist(max(0, lines.length - 500), lines.length).join('\n');
        setState(() {});
      });
    } else {
      crashLog = 'no crash log found.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: Text('关于Chaldea')),
      body: ListView(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(0),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'res/img/launcher_icon/app_icon_logo.png',
                    width: 120,
                  ),
                  Text(
                    AppInfo.appName,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      if (AppInfo.fullVersion.isNotEmpty)
                        Text('Version: ${AppInfo.fullVersion}'),
                      ElevatedButton(
                        onPressed: checkAppUpdate,
                        child: Text('检查更新'),
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 12),
                          minimumSize: Size(10, 30),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          ListTile(
            title: Text('　本应用所使用数据均来源于游戏及以下网站，游戏图片文本原文等版权属于'
                'TYPE MOON/FGO PROJECT。\n　程序功能与界面设计参考微信小程序"素材规划"以及iOS版Guda。'),
          ),
          TileGroup(
            header: '数据来源',
            footer: '若存在未标注的来源或侵权敬请告知',
            children: <Widget>[
              for (var ref in references.entries)
                ListTile(
                  title: Text(ref.key),
                  subtitle: AutoSizeText(ref.value, maxLines: 1),
                  onTap: () => jumpToLink(context, ref.key, ref.value),
                ),
            ],
          ),
          TileGroup(
            header: '反馈',
            children: <Widget>[
              ListTile(
                title: Text('Email'),
                subtitle: AutoSizeText('请附上出错页面截图和日志', maxLines: 1),
                onTap: () async {
                  if (Platform.isAndroid || Platform.isIOS) {
                    final Email email = Email(
                        subject: '${AppInfo.appName} '
                            'v${AppInfo.fullVersion} Feedback',
                        body: '请附上出错页面截图和日志.\n\n',
                        recipients: [kSupportTeamEmailAddress],
                        isHTML: true,
                        attachmentPaths: [
                          if (crashFile.existsSync()) crashFile.path,
                        ]);
                    FlutterEmailSender.send(email);
                  } else {
                    SimpleCancelOkDialog(
                      title: Text('Send Feedback'),
                      content: Text('请将出错页面的截图以及日志文件发送到以下邮箱:\n'
                          '$kSupportTeamEmailAddress\n'
                          '日志文件路径:\n${db.paths.crashLog}'),
                    ).show(context);
                  }
                },
              ),
              ListTile(
                title: Text('NGA'),
                onTap: () => jumpToLink(context, 'NGA-FGO',
                    'https://bbs.nga.cn/read.php?tid=24926789'),
              ),
              if (Platform.isIOS || Platform.isMacOS)
                ListTile(
                  title: Text('App Store评分'),
                  onTap: () {
                    launch('itms-apps://itunes.apple.com/app/id1548713491');
                  },
                )
            ],
          ),
          if (kDebugMode_)
            TileGroup(
              header: 'Crash log (${crashFile.statSync().size ~/ 1000} KB)',
              children: <Widget>[
                ListTile(
                  title: Text('Delete crash logs'),
                  onTap: () {
                    if (crashFile.existsSync()) {
                      crashFile.delete().then((_) {
                        EasyLoading.showToast('crash logs has been deleted.');
                        loadLog();
                        setState(() {});
                      });
                    }
                  },
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 500),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[CustomTile(subtitle: Text(crashLog))],
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }

  void jumpToLink(BuildContext context, String name, String link) {
    SimpleCancelOkDialog(
      title: Text('跳转到 $name'),
      content:
          Text(link, style: TextStyle(decoration: TextDecoration.underline)),
      onTapOk: () async {
        if (await canLaunch(link)) {
          launch(link);
        } else {
          EasyLoading.showToast('Could not launch uri: $link');
        }
      },
    ).show(context);
  }

  Future<void> checkAppUpdate() async {
    // android, windows: download github releases
    if (Platform.isAndroid || Platform.isWindows) {
      try {
        GitTool gitTool = GitTool.fromIndex(db.userData.appDatasetUpdateSource);
        final release = await gitTool.latestAppRelease();
        String curVersion =
            AppInfo.fullVersion.isEmpty ? 'Unknown' : AppInfo.fullVersion;
        SimpleCancelOkDialog(
          title: Text('应用更新'),
          content: Text('当前版本: $curVersion\n'
              '最新版本: ${release.name ?? "查询失败"}\n'
              '跳转到浏览器下载'),
          onTapOk: () {
            if (release.targetAsset?.browserDownloadUrl?.isNotEmpty == true) {
              launch(release.targetAsset.browserDownloadUrl);
            } else {
              launch(GitTool.getReleasePageUrl(
                  db.userData.appDatasetUpdateSource, true));
            }
          },
        ).show(context);
      } catch (e) {
        EasyLoading.showToast('Check update failed: $e');
      }
    } else if (Platform.isIOS || Platform.isMacOS) {
      // to App Store
      SimpleCancelOkDialog(
        title: Text('应用更新'),
        content: Text('请在App Store检查版本更新'),
        onTapOk: () {
          launch('itms-apps://itunes.apple.com/app/id1548713491');
        },
      ).show(context);
    }
  }
}
