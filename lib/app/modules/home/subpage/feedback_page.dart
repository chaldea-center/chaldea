import 'dart:typed_data';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/catcher/server_feedback_handler.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path/path.dart' as pathlib;
import 'package:url_launcher/url_launcher.dart';

import '../../misc/faq_page.dart';

class FeedbackPage extends StatefulWidget {
  FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
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
        title: Text(S.current.warning),
        content: Text(S.current.feedback_form_alert),
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
                child: MarkdownBody(data: S.current.feedback_info),
              ),
            ),
            TileGroup(
              children: [
                ListTile(
                  title: Text(S.current.faq),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    SplitRoute.push(context, FAQPage());
                  },
                ),
              ],
            ),
            TileGroup(
              header: S.current.feedback_contact,
              children: [
                ListTile(
                  title: const Text('Github'),
                  subtitle: const Text(kProjectHomepage),
                  onTap: () => launch('$kProjectHomepage/issues'),
                ),
                ListTile(
                  title: const Text('NGA'),
                  subtitle:
                      const Text('https://bbs.nga.cn/read.php?tid=24926789'),
                  onTap: () =>
                      launch('https://bbs.nga.cn/read.php?tid=24926789'),
                ),
                ListTile(
                  title: Text(S.current.email),
                  subtitle: const Text(kSupportTeamEmailAddress),
                  onTap: () async {
                    String subject =
                        '$kAppName v${AppInfo.fullVersion} Feedback';
                    String body = "OS: ${PlatformU.operatingSystem}"
                        " ${PlatformU.operatingSystemVersion}\n\n"
                        "Please attach logs(${db2.paths.logDir})";
                    final uri = Uri(
                        scheme: 'mailto',
                        path: kSupportTeamEmailAddress,
                        query: 'subject=$subject&body=$body');
                    print(uri);
                    if (await canLaunch(uri.toString())) {
                      launch(uri.toString());
                    } else {
                      SimpleCancelOkDialog(
                        title: Text(S.current.send_email_to),
                        content: const Text(kSupportTeamEmailAddress),
                      ).showDialog(context);
                    }
                  },
                ),
                ListTile(
                  title: const Text('QQ频道'),
                  onTap: () {
                    launch(
                        'https://qun.qq.com/qqweb/qunpro/share?_wv=3&_wwv=128&inviteCode=1bVHFW&from=181074&biz=ka&shareSource=5');
                  },
                ),
                ListTile(
                  title: const Text('Discord'),
                  subtitle: const Text('https://discord.gg/5M6w5faqjP'),
                  onTap: () {
                    launch('https://discord.gg/5M6w5faqjP');
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
                      labelText: S.current.email,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.mail_outline),
                      hintText: S.current.email,
                      helperText: S.current.fill_email_warning,
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
                  subtitle: Text(S.current.feedback_add_attachments),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: S.current.add,
                    onPressed: _addAttachments,
                  ),
                ),
                for (String fn in attachFiles.keys)
                  ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(pathlib.basename(fn)),
                    trailing: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          attachFiles.remove(fn);
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
                ),
              ],
            ),
            const SafeArea(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  Map<String, Uint8List> attachFiles = {};

  void _addAttachments() async {
    final result = await SharedBuilder.pickImageOrFiles(
            context: context, allowMultiple: true, withData: true)
        .catchError((e, s) async {
      logger.e('pick attachment failed', e, s);
      EasyLoading.showError(e.toString());
    });

    if (result != null) {
      for (final file in result.files) {
        if (file.bytes != null) {
          attachFiles[file.name] = file.bytes!;
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  void sendEmail() async {
    // print('pixelRatio=${MediaQuery.of(context).devicePixelRatio}');
    if (bodyController.text.trim().isEmpty) {
      EasyLoading.showInfo(S.current.add_feedback_details_warning);
      return;
    }
    if (contactController.text.trim().isEmpty) {
      final confirmed = await SimpleCancelOkDialog(
        title: Text(S.current.contact_information_not_filled),
        content: Text(S.current.contact_information_not_filled_warning),
        confirmText: S.current.still_send,
      ).showDialog(context);
      if (confirmed != true) return;
    }
    EasyLoading.show(
        status: S.current.sending, maskType: EasyLoadingMaskType.clear);
    try {
      String subject = subjectController.text.trim();
      if (subject.isEmpty) subject = defaultSubject;

      final handler = ServerFeedbackHandler(
        attachments: [
          db2.paths.crashLog,
          db2.paths.appLog,
          db2.paths.userDataPath,
        ],
        emailTitle: subject,
        senderName: 'Chaldea Feedback',
        screenshotController: db2.runtimeData.screenshotController,
        extraAttachments: Map.of(attachFiles),
      );

      if (!kDebugMode) {
        final result = await handler.handle(
            FeedbackReport(contactController.text, bodyController.text), null);
        if (!result) {
          throw S.current.sending_failed;
        }
      } else {
        await Future.delayed(const Duration(seconds: 3));
      }
      subjectController.text = '';
      bodyController.text = '';
      EasyLoading.showSuccess(S.current.sent);
    } catch (error, stacktrace) {
      print(error.toString());
      print(stacktrace.toString());
      EasyLoading.showError(error.toString());
    }
  }
}
