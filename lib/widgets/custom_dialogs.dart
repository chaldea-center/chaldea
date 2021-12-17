import 'dart:io';

import 'package:chaldea/components/config.dart';
import 'package:chaldea/components/extensions.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/platform_interface/platform/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:open_file/open_file.dart';

class InputCancelOkDialog extends StatefulWidget {
  final String? title;
  final String? text;
  final String? hintText;
  final String? errorText;
  final bool Function(String)? validate;
  final ValueChanged<String>? onSubmit;

  const InputCancelOkDialog(
      {Key? key,
      this.title,
      this.text,
      this.hintText,
      this.errorText,
      this.validate,
      this.onSubmit})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _InputCancelOkDialogState();
}

/// debug warnings:
/// W/IInputConnectionWrapper(31507): beginBatchEdit on inactive InputConnection
/// W/IInputConnectionWrapper(31507): getTextBeforeCursor on inactive InputConnection
/// W/IInputConnectionWrapper(31507): getTextAfterCursor on inactive InputConnection
/// W/IInputConnectionWrapper(31507): getSelectedText on inactive InputConnection
/// W/IInputConnectionWrapper(31507): endBatchEdit on inactive InputConnection
class _InputCancelOkDialogState extends State<InputCancelOkDialog> {
  TextEditingController? _controller;
  bool validation = true;

  bool _validate(String v) {
    if (widget.validate != null) {
      return widget.validate!(v);
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    validation = _validate(_controller!.text);
    return AlertDialog(
      title: widget.title == null ? null : Text(widget.title!),
      content: TextField(
        controller: _controller,
        autofocus: true,
        autocorrect: false,
        decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: validation ? null : "Invalid input."),
        onChanged: (v) {
          if (widget.validate != null) {
            setState(() {
              validation = _validate(v);
            });
          }
        },
        onSubmitted: (v) {
          FocusScope.of(context).unfocus();
          Navigator.pop(context);
          if (widget.onSubmit != null) {
            widget.onSubmit!(v);
          }
        },
      ),
      actions: <Widget>[
        TextButton(
          child: Text(S.of(context).cancel),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(S.of(context).ok),
          onPressed: validation
              ? () {
                  String _value = _controller!.text;
                  validation = _validate(_value);
                  setState(() {
                    if (validation) {
                      if (widget.onSubmit != null) {
                        widget.onSubmit!(_value);
                      }
                      Navigator.pop(context);
                    }
                  });
                }
              : null,
        )
      ],
    );
  }
}

class SimpleCancelOkDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final EdgeInsetsGeometry contentPadding;
  final String? confirmText;
  final VoidCallback? onTapOk;
  final VoidCallback? onTapCancel;

  /// ignore if onTapCancel is not null
  final bool hideOk;
  final bool hideCancel;
  final List<Widget> actions;
  final bool scrollable;
  final bool wrapActionsInRow;

  const SimpleCancelOkDialog({
    Key? key,
    this.title,
    this.content,
    this.contentPadding = const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
    this.confirmText,
    this.onTapOk,
    this.onTapCancel,
    this.hideOk = false,
    this.hideCancel = false,
    this.actions = const [],
    this.scrollable = false,
    this.wrapActionsInRow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[
      if (onTapCancel != null || !hideCancel)
        TextButton(
          child: Text(S.of(context).cancel),
          onPressed: () {
            Navigator.of(context).pop(false);
            if (onTapCancel != null) {
              onTapCancel!();
            }
          },
        ),
      ...actions,
      if (onTapOk != null || !hideOk)
        TextButton(
          child: Text(confirmText ?? S.of(context).confirm),
          onPressed: () {
            Navigator.of(context).pop(true);
            if (onTapOk != null) {
              onTapOk!();
            }
          },
        ),
    ];
    if (wrapActionsInRow) {
      children = [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: children,
          ),
        ),
      ];
    }
    return AlertDialog(
      title: title,
      content: content,
      contentPadding: contentPadding,
      scrollable: scrollable,
      actions: children,
    );
  }

  static Future showSave({
    required BuildContext context,
    required File srcFile,
    required String savePath,
  }) async {
    return SimpleCancelOkDialog(
      title: Text(S.current.save),
      content: Text(db.paths.convertIosPath(savePath)),
      actions: [
        if (PlatformU.isDesktop)
          TextButton(
            onPressed: () {
              OpenFile.open(db.paths.downloadDir);
            },
            child: Text(S.current.open),
          )
      ],
      onTapOk: () {
        if (PlatformU.isWeb) {
          EasyLoading.showError('Not support on web');
          return;
        }
        File(savePath).createSync(recursive: true);
        srcFile.copySync(savePath);
        EasyLoading.showSuccess(S.current.saved);
      },
    ).showDialog(context);
  }
}
