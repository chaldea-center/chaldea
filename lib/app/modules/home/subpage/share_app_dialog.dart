import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/packages/sharex.dart';
import 'package:chaldea/utils/constants.dart';
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
    String msg = S.current.chaldea_share_msg(
        Language.isZH ? '$kProjectDocRoot/zh/' : kProjectDocRoot);
    _controller = TextEditingController(text: msg);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleCancelOkDialog(
      title: Text(S.current.share),
      contentPadding:
          const EdgeInsetsDirectional.fromSTEB(24.0, 10.0, 24.0, 12.0),
      content: TextFormField(
        controller: _controller,
        maxLines: null,
        minLines: 5,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).highlightColor,
          focusColor: Theme.of(context).highlightColor,
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).dialogBackgroundColor)),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).dialogBackgroundColor)),
        ),
      ),
      hideOk: true,
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _controller.text)).then((_) {
              EasyLoading.showSuccess(S.current.copied);
            }).catchError((e, s) async {
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
