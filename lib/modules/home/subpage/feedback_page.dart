//@dart=2.12
import 'dart:convert';
import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path/path.dart' as pathlib;

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool attachLog = true;
  late TextEditingController contactController;
  late TextEditingController bodyController;

  @override
  void initState() {
    super.initState();
    contactController = TextEditingController();
    bodyController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    contactController.dispose();
    bodyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).about_feedback),
        leading: BackButton(),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 8),
        children: [
          Padding(padding: EdgeInsets.only(top: 20)),
          TextField(
            controller: contactController,
            decoration: InputDecoration(
                labelText: '联系方式(可选)', border: OutlineInputBorder()
                // prefix: Icon(Icons.mail_outline),
                ),
            maxLines: 1,
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          SizedBox(
            height: 200,
            child: TextField(
              controller: bodyController,
              decoration: InputDecoration(
                labelText: '反馈与建议',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              expands: true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
          CheckboxListTile(
            title: Text('添加崩溃日志'),
            value: attachLog,
            onChanged: (v) {
              setState(() {
                attachLog = v ?? attachLog;
              });
            },
          ),
          ListTile(
            title: Text('添加图像或文件'),
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
          ElevatedButton(onPressed: sendEmail, child: Text('Send'))
        ],
      ),
    );
  }

  Set<String> attachFiles = Set();

  void _addAttachments() {
    FilePickerCross.importMultipleFromStorage(type: FileTypeCross.image)
        .then((filePickers) {
      attachFiles.addAll(filePickers.map((e) => e.path));
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
    if (bodyController.text.trim().isEmpty &&
        attachFiles.isEmpty &&
        !attachLog) {
      EasyLoading.showToast('请填写反馈内容或添加附件');
      return;
    }
    var canceler = showMyProgress(status: 'Sending');
    try {
      final message = Message()
        ..from =
            Address(b64('Y2hhbGRlYS1jbGllbnRAbmFydW1pLmNj'), 'Chaldea Feedback')
        ..recipients.add(kSupportTeamEmailAddress)
        ..subject = 'Chaldea v${AppInfo.fullVersion2} Feedback';

      message.html = _emailBody();
      [db.paths.crashLog, ...attachFiles].forEach((fp) {
        var file = File(fp);
        if (file.existsSync()) message.attachments.add(FileAttachment(file));
      });
      if (!kDebugMode) {
        final result = await send(
            message,
            SmtpServer('smtp.qiye.aliyun.com',
                port: 465,
                ssl: true,
                username: b64('Y2hhbGRlYS1jbGllbnRAbmFydW1pLmNj'),
                password: b64('Q2hhbGRlYUBjbGllbnQ=')));
        logger.i(result.toString());
      } else {
        await Future.delayed(Duration(seconds: 3));
      }
      canceler();
      EasyLoading.showSuccess('Sent');
    } catch (error, stacktrace) {
      print(error.toString());
      print(stacktrace.toString());
      canceler();
      EasyLoading.showError(error.toString());
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
    buffer.write("<h3>Summary:</h3>");
    final dataVerFile = File(db.paths.datasetVersionFile);
    Map<String, dynamic> summary = {
      'appVersion': '${AppInfo.appName} v${AppInfo.fullVersion}',
      'datasetVersion': dataVerFile.existsSync()
          ? dataVerFile.readAsStringSync()
          : "Not detected",
      'os': '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
    };
    for (var entry in summary.entries) {
      buffer.write("<b>${entry.key}</b>: ${escape(entry.value)}<br>");
    }
    buffer.write('<hr>');

    buffer.write("<h3>Device parameters:</h3>");
    for (var entry in AppInfo.deviceParams.entries) {
      buffer.write("<b>${entry.key}</b>: ${escape(entry.value)}<br>");
    }
    buffer.write("<hr>");

    buffer.write("<h3>Application parameters:</h3>");
    for (var entry in AppInfo.appParams.entries) {
      buffer.write("<b>${entry.key}</b>: ${escape(entry.value)}<br>");
    }
    buffer.write("<hr>");

    return buffer.toString();
  }
}
