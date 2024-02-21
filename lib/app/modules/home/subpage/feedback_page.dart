import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path/path.dart' as pathlib;

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/catcher/server_feedback_handler.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/tile_items.dart';

const _kDiscordLink = 'https://discord.gg/5M6w5faqjP';

class FeedbackPage extends StatefulWidget {
  FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  late TextEditingController contactController;
  late TextEditingController subjectController;
  late TextEditingController bodyController;

  bool _changed = false;

  void _onTextFieldChanged() {
    if (_changed) return;
    _changed = true;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    contactController = TextEditingController();
    subjectController = TextEditingController();
    bodyController = TextEditingController();
    contactController.addListener(_onTextFieldChanged);
    subjectController.addListener(_onTextFieldChanged);
    bodyController.addListener(_onTextFieldChanged);
  }

  @override
  void dispose() {
    super.dispose();
    contactController.dispose();
    subjectController.dispose();
    bodyController.dispose();
  }

  Future<bool> _alertPopPage() async {
    if (subjectController.text.trim().isNotEmpty || bodyController.text.trim().isNotEmpty) {
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
    Widget child = Scaffold(
      appBar: AppBar(
        title: Text(S.current.about_feedback),
        leading: BackButton(onPressed: () async {
          if (await _alertPopPage()) {
            if (context.mounted) Navigator.of(context).pop();
          }
        }),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
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
                title: Text('${S.current.faq} (Chaldea)'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  launch(ChaldeaUrl.doc('faq'));
                },
              ),
              ListTile(
                title: Text('${S.current.faq} (Laplace)'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  launch(ChaldeaUrl.laplace('faq'));
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
                onLongPress: () {
                  copyToClipboard('$kProjectHomepage/issues', toast: true);
                },
              ),
              // ListTile(
              //   title: const Text('NGA'),
              //   subtitle:
              //       const Text('https://bbs.nga.cn/read.php?tid=24926789'),
              //   onTap: () => launch('https://bbs.nga.cn/read.php?tid=24926789'),
              // ),
              ListTile(
                title: Text(S.current.email),
                subtitle: const Text(kSupportTeamEmailAddress),
                onTap: () async {
                  String subject = '$kAppName v${AppInfo.fullVersion} Feedback';
                  String body = "OS: ${PlatformU.operatingSystem}"
                      " ${PlatformU.operatingSystemVersion}\n\n"
                      "Please attach logs(${db.paths.convertIosPath(db.paths.logDir)})";
                  final uri =
                      Uri(scheme: 'mailto', path: kSupportTeamEmailAddress, query: 'subject=$subject&body=$body');
                  print(uri);
                  if (await canLaunch(uri.toString())) {
                    launch(uri.toString());
                  } else {
                    if (context.mounted) {
                      SimpleCancelOkDialog(
                        title: Text(S.current.send_email_to),
                        content: const Text(kSupportTeamEmailAddress),
                      ).showDialog(context);
                    }
                  }
                },
                onLongPress: () {
                  copyToClipboard(kSupportTeamEmailAddress, toast: true);
                },
              ),
              ListTile(
                title: const Text('Discord'),
                subtitle: const Text(_kDiscordLink),
                onTap: () {
                  launch(_kDiscordLink);
                },
                onLongPress: () {
                  copyToClipboard(_kDiscordLink, toast: true);
                },
              ),
              // ListTile(
              //   title: const Text('QQ频道'),
              //   onTap: () {
              //     // https://qun.qq.com/qqweb/qunpro/share?_wv=3&_wwv=128&inviteCode=1bVHFW&from=181074&biz=ka&shareSource=5
              //     launch('https://jq.qq.com/?_wv=1027&k=kvHMMxGn');
              //   },
              // ),
            ],
          ),
          TileGroup(
            header: S.current.about_feedback,
            // divider: Container(),
            innerDivider: false,
            children: [
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextFormField(
                  controller: contactController,
                  decoration: InputDecoration(
                    labelText: '${S.current.email}*',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.mail_outline),
                    hintText: S.current.email,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextFormField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    labelText: '${S.current.feedback_subject}*',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                height: 200,
                child: TextFormField(
                  controller: bodyController,
                  decoration: InputDecoration(
                    labelText: S.current.feedback_content_hint,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton(
                    onPressed: sendEmail,
                    child: Text(S.current.feedback_send),
                  ),
                ),
              ),
            ],
          ),
          const SafeArea(child: SizedBox()),
        ],
      ),
    );
    return child;
  }

  Map<String, Uint8List> attachFiles = {};

  void _addAttachments() async {
    final result = await SharedBuilder.pickImageOrFiles(context: context, allowMultiple: true).catchError((e, s) async {
      logger.e('pick attachment failed', e, s);
      EasyLoading.showError(e.toString());
      return null;
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
      EasyLoading.showInfo(S.current.contact_information_not_filled);
      return;
    }
    if (subjectController.text.trim().isEmpty) {
      EasyLoading.showInfo('${S.current.feedback_subject}: ${S.current.empty_hint}');
      return;
    }
    try {
      String subject = '[Feedback] ${subjectController.text.trim()}';

      final handler = ServerFeedbackHandler(
        attachments: [
          db.paths.crashLog,
          db.paths.appLog,
          db.paths.userDataPath,
        ],
        emailTitle: subject,
        senderName: 'Chaldea Feedback',
        // screenshotController: db.runtimeData.screenshotController,
        extraAttachments: Map.of(attachFiles),
      );

      final result = await showEasyLoading(
          () => handler.handle(FeedbackReport(contactController.text, bodyController.text), null));
      if (!result) {
        throw S.current.sending_failed;
      }
      subjectController.text = '';
      bodyController.text = '';
      EasyLoading.showSuccess(S.current.sent);
    } catch (e, s) {
      logger.e('send feedback failed', e, s);
      EasyLoading.showError(escapeDioException(e));
    }
  }
}
