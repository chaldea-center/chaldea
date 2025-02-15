import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/packages/sharex.dart';
import 'package:chaldea/utils/url.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';

class ShareAppDialog extends StatefulWidget {
  ShareAppDialog({super.key});

  @override
  _ShareAppDialogState createState() => _ShareAppDialogState();
}

class _ShareAppDialogState extends State<ShareAppDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    String msg = S.current.chaldea_share_msg(ChaldeaUrl.docHome);
    _controller = TextEditingController(text: msg);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: themeData.dialogTheme.backgroundColor ?? const Color(0xFF000000)),
    );
    return SimpleCancelOkDialog(
      title: Text(S.current.share),
      contentPadding: const EdgeInsetsDirectional.fromSTEB(24.0, 10.0, 24.0, 12.0),
      content: TextFormField(
        controller: _controller,
        maxLines: null,
        minLines: 5,
        decoration: InputDecoration(
          filled: true,
          fillColor: themeData.highlightColor,
          focusColor: themeData.highlightColor,
          enabledBorder: border,
          focusedBorder: border,
        ),
      ),
      hideOk: true,
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _controller.text))
                .then((_) {
                  EasyLoading.showSuccess(S.current.copied);
                })
                .catchError((e, s) {
                  logger.e('copy share msg failed', e, s);
                  EasyLoading.showError('Copy failed');
                });
          },
          child: Text(MaterialLocalizations.of(context).copyButtonLabel),
        ),
        if (!PlatformU.isWindows)
          TextButton(
            onPressed: () {
              ShareX.share(_controller.text, context: context);
            },
            child: Text(S.current.share),
          ),
      ],
    );
  }
}
