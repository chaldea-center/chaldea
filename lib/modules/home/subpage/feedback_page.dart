import 'dart:convert';

import 'package:chaldea/components/catcher_util/catcher_email_handler.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/extras/faq_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl_standalone.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path/path.dart' as pathlib;
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatefulWidget {
  FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final bool attachLog = true;
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
        title: const Text('Warning'),
        content: Text(LocalizedText.of(
            chs: '反馈表未提交，仍然退出?',
            jpn: 'フィードバックフォームは送信されませんが、終了します？',
            eng: 'Feedback form is not empty, still exist?',
            kor: '피드백은 전송되지 않습니다만, 종료하시겠습니까?')),
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // if (Language.isCN)
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: MarkdownBody(
                    data: LocalizedText.of(
                        chs: '''提交反馈前，请先查阅<**FAQ**>。反馈时请详细描述:
- 如何复现/期望表现
- 应用/数据版本、使用设备系统及版本
- 附加截图日志
- 以及最好能够提供联系方式(邮箱等)''',
                        jpn:
                            """フィードバックを送信する前に、<**FAQ**>を確認してください。 フィードバックを提供する際は、詳細に説明してください。
- 再現方法/期待されるパフォーマンス
- アプリ/データのバージョン、デバイスシステム/バージョン
- スクリーンショットとログを添付する
- そして、連絡先情報（電子メールなど）を提供するのが良いです """,
                        eng:
                            '''Please check <**FAQ**> first before sending feedback. And following detail is desired:
- How to reproduce, expected behaviour
- App/dataset version, device system and version
- Attach screenshots and logs
- It's better to provide contact info (e.g. Email) 
''',
                        kor:
                            '''피드백을 전송하기 전에, <**FAQ**>를 확인해주세요. 피드백을 적을 때에는 상세하게 적어주시길 바랍니다.
- 재현 방법/기대하고 있는 퍼포먼스
- 앱/데이터의 버전, 디바이스 시스템/버전
- 스크린샷과 로그를 첨부한다
- 마지막으로, 연락처 정보(전자메일 등)을 적어주시는 것이 좋습니다 ''')),
              ),
            ),
            TileGroup(
              children: [
                ListTile(
                  title: const Text('FAQ'),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    SplitRoute.push(context, FAQPage());
                  },
                ),
              ],
            ),
            TileGroup(
              header: 'Contact',
              children: [
                ListTile(
                  title: const Text('Github'),
                  subtitle: const Text(kProjectHomepage),
                  onTap: () => jumpToExternalLinkAlert(
                    url: '$kProjectHomepage/issues',
                    name: 'Github',
                  ),
                ),
                ListTile(
                  title: Text(S.current.nga),
                  subtitle:
                      const Text('https://bbs.nga.cn/read.php?tid=24926789'),
                  onTap: () => jumpToExternalLinkAlert(
                    url: 'https://bbs.nga.cn/read.php?tid=24926789',
                    name: S.of(context).nga_fgo,
                  ),
                ),
                ListTile(
                  title: const Text('Email'),
                  subtitle: const Text(kSupportTeamEmailAddress),
                  onTap: () async {
                    String subject =
                        '$kAppName v${AppInfo.fullVersion} Feedback';
                    String body = "OS: ${PlatformU.operatingSystem}"
                        " ${PlatformU.operatingSystemVersion}\n\n"
                        "Please attach logs(${db.paths.logDir})";
                    final uri = Uri(
                        scheme: 'mailto',
                        path: kSupportTeamEmailAddress,
                        query: 'subject=$subject&body=$body');
                    print(uri);
                    if (await canLaunch(uri.toString())) {
                      launch(uri.toString());
                    } else {
                      const SimpleCancelOkDialog(
                        title: Text('Send email to'),
                        content: Text(kSupportTeamEmailAddress),
                      ).showDialog(context);
                    }
                  },
                ),
                ListTile(
                  title: const Text('NokNok'),
                  subtitle: const Text('118835'),
                  onTap: () async {
                    await Clipboard.setData(const ClipboardData(text: '118835'))
                        .then((_) => EasyLoading.showToast(S.current.copied));
                    launch(
                        'https://www.noknok.cn/act/share_group_20210625/index.html?uid=100164675&gid=118835');
                  },
                ),
                ListTile(
                  title: const Text('Discord'),
                  subtitle: const Text('https://discord.gg/5M6w5faqjP'),
                  onTap: () {
                    jumpToExternalLinkAlert(
                        url: 'https://discord.gg/5M6w5faqjP', name: 'Discord');
                  },
                ),
              ],
            ),
            TileGroup(
              header: S.current.about_feedback,
              // divider: Container(),
              innerDivider: false,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: contactController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.mail_outline),
                      hintText:
                          LocalizedText.of(chs: '邮箱', jpn: 'メール', eng: 'Email'),
                      helperText: LocalizedText.of(
                          chs: '建议填写邮件联系方式，否则将无法得到回复！！！请勿填写QQ/微信/手机号！',
                          jpn: '連絡先情報ないと、返信ができません。',
                          eng:
                              'Please fill in email address. Otherwise NO reply.',
                          kor: '연락처 정보가 없다면 답장이 불가능합니다.'),
                      helperMaxLines: 3,
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: S.current.feedback_subject,
                      border: const OutlineInputBorder(),
                      hintText: defaultSubject,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  height: 200,
                  child: TextField(
                    controller: bodyController,
                    decoration: InputDecoration(
                      labelText: S.of(context).feedback_content_hint,
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    expands: true,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
                ListTile(
                  title: Text(S.current.attachment),
                  subtitle: Text(LocalizedText.of(
                      chs: 'e.g. 截图等文件',
                      jpn: 'e.g. スクリーンショットとその他のファイル',
                      eng: 'e.g. screenshots, files.',
                      kor: 'e.g. 스크린샷, 기타 파일')),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: S.current.add,
                    onPressed: _addAttachments,
                  ),
                ),
                for (String fp in attachFiles)
                  ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(pathlib.basename(fp)),
                    trailing: IconButton(
                      icon: const Icon(Icons.clear),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Set<String> attachFiles = {};

  void _addAttachments() {
    FilePicker.platform.pickFiles(allowMultiple: true).then((result) {
      final paths = result?.paths.whereType<String>();
      if (paths != null) {
        attachFiles.addAll(paths);
      }
      if (mounted) {
        setState(() {});
      }
    }).catchError((e, s) async {
      logger.e('pick attachment failed', e, s);
      EasyLoading.showError(e.toString());
    });
  }

  void sendEmail() async {
    // print('pixelRatio=${MediaQuery.of(context).devicePixelRatio}');
    if (bodyController.text.trim().isEmpty) {
      EasyLoading.showInfo(LocalizedText.of(
          chs: '请填写反馈内容',
          jpn: 'フィードバックの内容を記入してください',
          eng: 'Please add feedback details',
          kor: '피드백 내용을 작성해주세요 '));
      return;
    }
    if (contactController.text.trim().isEmpty) {
      final confirmed = await SimpleCancelOkDialog(
        title: Text(LocalizedText.of(
            chs: '联系方式未填写',
            jpn: '連絡先情報が入力されていません',
            eng: 'Contact information is not filled in',
            kor: '연락처 정보가 입력되어있지 않습니다')),
        content: Text(LocalizedText.of(
            chs: '将无法无法无法无法无法回复您的问题',
            jpn: '開発者はあなたのフィードバックに応答することができなくなります',
            eng: 'The developer will not be able to respond to your feedback',
            kor: '개발자는 당신의 피드백에 응답할 수 없게 됩니다')),
        confirmText: LocalizedText.of(
            chs: '仍然发送', jpn: '送信し続ける', eng: 'Still Send', kor: '계속 보내기'),
      ).showDialog(context);
      if (confirmed != true) return;
    }
    EasyLoading.show(status: 'Sending', maskType: EasyLoadingMaskType.clear);
    try {
      final message = Message()
        ..from = const Address('chaldea-client@narumi.cc', 'Chaldea Feedback')
        ..recipients.add(kSupportTeamEmailAddress);

      String subject = subjectController.text.trim();
      if (subject.isEmpty) subject = defaultSubject;
      message.subject = subject;

      message.html = await _emailBody();
      message.attachments
          .add(StringAttachment(bodyController.text, fileName: 'raw_msg.txt'));
      if (!PlatformU.isWeb) {
        if (attachLog) {
          message.attachments.addAll(EmailAutoHandlerCross.archiveAttachments([
            File(db.paths.crashLog),
            File(db.paths.appLog),
            File(db.paths.userDataPath)
          ], join(db.paths.tempDir, '.feedback.tmp.zip')));
        }
        attachFiles.forEach((fp) {
          var file = File(fp);
          if (file.existsSync()) {
            message.attachments.add(FileAttachment(File(file.path)));
          }
        });
      }
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
        await Future.delayed(const Duration(seconds: 3));
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

  Future<String> _emailBody() async {
    final escape = const HtmlEscape().convert;
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
      'os': '${PlatformU.operatingSystem} ${PlatformU.operatingSystemVersion}',
      'lang': Language.current.code,
      'locale': await findSystemLocale(),
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
