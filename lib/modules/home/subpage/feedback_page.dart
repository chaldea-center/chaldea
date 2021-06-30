import 'dart:convert';

import 'package:chaldea/components/catcher_util/catcher_email_handler.dart';
import 'package:chaldea/components/components.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path/path.dart' as pathlib;
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool attachLog = true;
  late TextEditingController contactController;
  late TextEditingController subjectController;
  late TextEditingController bodyController;

  final String defaultSubject = 'Chaldea v${AppInfo.fullVersion} Feedback';

  @override
  void initState() {
    super.initState();
    contactController = TextEditingController();
    subjectController = TextEditingController();
    bodyController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    contactController.dispose();
    subjectController.dispose();
    bodyController.dispose();
  }

  Future<bool> _alertPopPage() async {
    if (subjectController.text.trim().isNotEmpty ||
        bodyController.text.trim().isNotEmpty) {
      final r = await SimpleCancelOkDialog(
        title: Text('Warning'),
        content: Text(LocalizedText.of(
            chs: '反馈表未提交，仍然退出?',
            jpn: 'フィードバックフォームは送信されませんが、終了します？',
            eng: 'Feedback form is not empty, still exist?')),
      ).showDialog(context);
      return r == true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _alertPopPage,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).about_feedback),
          leading: BackButton(onPressed: () async {
            if (await _alertPopPage()) Navigator.of(context).pop();
          }),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(vertical: 8),
          children: [
            TileGroup(
              header: 'Contact',
              children: [
                ListTile(
                  title: Text('Github'),
                  subtitle: Text(kProjectHomepage),
                  onTap: () => jumpToExternalLinkAlert(
                    url: '$kProjectHomepage/issues',
                    name: 'Github',
                  ),
                ),
                ListTile(
                  title: Text(S.of(context).nga),
                  subtitle: Text('https://bbs.nga.cn/read.php?tid=24926789'),
                  onTap: () => jumpToExternalLinkAlert(
                    url: 'https://bbs.nga.cn/read.php?tid=24926789',
                    name: S.of(context).nga_fgo,
                  ),
                ),
                ListTile(
                  title: Text('Email'),
                  subtitle: Text(kSupportTeamEmailAddress),
                  onTap: () async {
                    String subject =
                        '$kAppName v${AppInfo.fullVersion} Feedback';
                    String body = "OS: ${Platform.operatingSystem}"
                        " ${Platform.operatingSystemVersion}\n\n"
                        "Please attach crash log(${db.paths.crashLog})";
                    final uri = Uri(
                        scheme: 'mailto',
                        path: kSupportTeamEmailAddress,
                        query: 'subject=$subject&body=$body');
                    print(uri);
                    if (await canLaunch(uri.toString())) {
                      launch(uri.toString());
                    } else {
                      SimpleCancelOkDialog(
                        title: Text('Send email to'),
                        content: Text(kSupportTeamEmailAddress),
                      ).showDialog(context);
                    }
                  },
                ),
                ListTile(
                  title: Text('Discord'),
                  subtitle: Text('https://discord.gg/5M6w5faqjP'),
                  onTap: () {
                    jumpToExternalLinkAlert(
                        url: 'https://discord.gg/5M6w5faqjP', name: 'Discord');
                  },
                )
              ],
            ),
            TileGroup(
              header: S.of(context).about_feedback,
              // divider: Container(),
              innerDivider: false,
              children: [
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: contactController,
                    decoration: InputDecoration(
                        labelText: S.of(context).feedback_contact,
                        border: OutlineInputBorder(),
                        // prefix: Icon(Icons.mail_outline),
                        hintText: LocalizedText.of(
                            chs: '如需回复请填写',
                            jpn: 'Please fill in if reply wanted',
                            eng: 'Please fill in if reply wanted')),
                    maxLines: 1,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: S.current.feedback_subject,
                      border: OutlineInputBorder(),
                      hintText: defaultSubject,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  height: 200,
                  child: TextField(
                    controller: bodyController,
                    decoration: InputDecoration(
                      labelText: S.of(context).feedback_content_hint,
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    expands: true,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
                CheckboxListTile(
                  title: Text(S.of(context).feedback_add_crash_log),
                  value: attachLog,
                  onChanged: (v) {
                    setState(() {
                      attachLog = v ?? attachLog;
                    });
                  },
                ),
                Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
                ListTile(
                  title: Text(S.of(context).feedback_add_attachments),
                  onTap: _addAttachments,
                ),
                for (String fp in attachFiles)
                  ListTile(
                    leading: Icon(Icons.attach_file),
                    title: Text(pathlib.basename(fp)),
                    trailing: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          attachFiles.remove(fp);
                        });
                      },
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: sendEmail,
                      child: Text(S.of(context).feedback_send),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Set<String> attachFiles = Set();

  void _addAttachments() {
    FilePickerCross.importMultipleFromStorage(type: FileTypeCross.image)
        .then((filePickers) {
      attachFiles.addAll(filePickers.map((e) => e.path!));
      if (mounted) {
        setState(() {});
      }
    }).catchError((error, stackTrace) {
      if (!(error is FileSelectionCanceledError)) {
        print(error.toString());
        print(stackTrace.toString());
        EasyLoading.showError(error.toString());
      }
    });
  }

  void sendEmail() async {
    // print('pixelRatio=${MediaQuery.of(context).devicePixelRatio}');
    if (bodyController.text.trim().isEmpty) {
      EasyLoading.showInfo(LocalizedText.of(
          chs: '请填写反馈内容',
          jpn: 'フィードバックの内容を記入してください',
          eng: 'Please add feedback details'));
      return;
    }
    if (contactController.text.trim().isEmpty) {
      final confirmed = await SimpleCancelOkDialog(
        title: Text(LocalizedText.of(
            chs: '联系方式未填写',
            jpn: '連絡先情報が入力されていません',
            eng: 'Contact information is not filled in')),
        content: Text(LocalizedText.of(
            chs: '开发者将无法回复您的问题',
            jpn: '開発者はあなたのフィードバックに応答することができなくなります',
            eng: 'The developer will not be able to respond to your feedback')),
        confirmText:
            LocalizedText.of(chs: '仍然发送', jpn: '送信し続ける', eng: 'Still Send'),
      ).showDialog(context);
      if (confirmed != true) return;
    }
    EasyLoading.show(status: 'Sending', maskType: EasyLoadingMaskType.clear);
    try {
      final message = Message()
        ..from = Address('chaldea-client@narumi.cc', 'Chaldea Feedback')
        ..recipients.add(kSupportTeamEmailAddress);

      String subject = subjectController.text.trim();
      if (subject.isEmpty) subject = defaultSubject;
      message.subject = subject;

      message.html = _emailBody();
      message.attachments
          .add(StringAttachment(bodyController.text, fileName: 'raw_msg.txt'));
      if (attachLog) {
        message.attachments.addAll(EmailAutoHandlerCross.archiveAttachments(
            [File(db.paths.crashLog), File(db.paths.appLog)],
            join(db.paths.tempDir, '.feedback.tmp.zip')));
      }
      attachFiles.forEach((fp) {
        var file = File(fp);
        if (file.existsSync()) {
          message.attachments.add(FileAttachment(file));
        }
      });
      if (!kDebugMode) {
        final result = await send(
          message,
          SmtpServer(
            'smtp.qiye.aliyun.com',
            port: 465,
            ssl: true,
            username: 'chaldea-client@narumi.cc',
            password: b64(
              'Q2hhbGRlYUBjbGllbnQ=',
            ),
          ),
        );
        logger.i(result.toString());
      } else {
        await Future.delayed(Duration(seconds: 3));
      }
      subjectController.text = '';
      bodyController.text = '';
      EasyLoading.showSuccess('Sent');
    } catch (error, stacktrace) {
      print(error.toString());
      print(stacktrace.toString());
      EasyLoading.showError(error.toString());
    } finally {
      EasyLoadingUtil.dismiss();
    }
  }

  String _emailBody() {
    final escape = HtmlEscape().convert;
    StringBuffer buffer = StringBuffer("");
    buffer.write('<style>h3{margin:0.2em 0;}</style>');

    if (contactController.text.isNotEmpty == true) {
      buffer.write("<h3>Contact:</h3>");
      buffer.write("${escape(contactController.text)}<br>");
    }
    buffer.write("<h3>Body:</h3>");
    buffer
        .write("${escape(bodyController.text).replaceAll('\n', '<br>\n')}<br>");
    buffer.write("<h3>Summary:</h3>");
    Map<String, dynamic> summary = {
      'app': '${AppInfo.appName} v${AppInfo.fullVersion2}',
      'dataset': db.gameData.version,
      'os': '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      'lang': Language.current.code,
      'uuid': AppInfo.uuid,
    };
    for (var entry in summary.entries) {
      buffer
          .write("<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
    }
    buffer.write('<hr>');

    buffer.write("<h3>Device parameters:</h3>");
    for (var entry in AppInfo.deviceParams.entries) {
      buffer
          .write("<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
    }
    buffer.write("<hr>");

    buffer.write("<h3>Application parameters:</h3>");
    for (var entry in AppInfo.appParams.entries) {
      buffer
          .write("<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
    }
    buffer.write("<hr>");

    return buffer.toString();
  }
}
