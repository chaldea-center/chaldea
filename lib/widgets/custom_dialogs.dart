import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';

class InputCancelOkDialog extends StatefulWidget {
  final String? title;
  final String? initValue;
  final int? maxLines;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool Function(String s)? validate;
  final ValueChanged<String>? onSubmit;
  final TextInputType? keyboardType;
  final bool autofocus;
  final bool showNumButton;

  const InputCancelOkDialog({
    super.key,
    this.title,
    this.initValue,
    this.maxLines,
    this.hintText,
    this.helperText,
    this.errorText,
    this.validate,
    this.onSubmit,
    this.keyboardType,
    this.autofocus = true,
  }) : showNumButton = false;

  InputCancelOkDialog.number({
    super.key,
    this.title,
    int? initValue,
    this.maxLines,
    this.hintText,
    this.helperText,
    this.errorText,
    bool Function(int v)? validate,
    ValueChanged<int>? onSubmit,
    this.keyboardType = TextInputType.number,
    this.autofocus = true,
    this.showNumButton = true,
  }) : initValue = initValue?.toString(),
       validate = ((String s) {
         final v = int.parse(s);
         if (validate != null) return validate(v);
         return true;
       }),
       onSubmit = (onSubmit == null ? null : (String s) => onSubmit(int.parse(s)));

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
  late TextEditingController _controller;
  bool validation = true;

  bool _validate(String v) {
    try {
      if (widget.validate != null) {
        return widget.validate!(v);
      }
    } catch (_) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    final text = widget.initValue ?? '';
    _controller = TextEditingController.fromValue(
      TextEditingValue(
        text: text,
        selection: text.isEmpty
            ? const TextSelection.collapsed(offset: -1)
            : TextSelection(baseOffset: 0, extentOffset: text.length),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    validation = _validate(_controller.text);
    Widget field = TextFormField(
      controller: _controller,
      autofocus: widget.autofocus,
      autocorrect: false,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines ?? 1,
      decoration: InputDecoration(
        hintText: widget.hintText,
        helperText: widget.helperText,
        errorText: validation || _controller.text.isEmpty ? null : S.current.invalid_input,
      ),
      onChanged: (v) {
        if (widget.validate != null) {
          setState(() {
            validation = _validate(v);
          });
        }
      },
      onFieldSubmitted: (v) {
        if (!_validate(v)) {
          return;
        }
        FocusScope.of(context).unfocus();
        Navigator.pop(context, v);
        if (widget.onSubmit != null) {
          widget.onSubmit!(v);
        }
      },
    );
    if (widget.showNumButton) {
      field = Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: field),
          Column(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  try {
                    _controller.text = (double.parse(_controller.text).floor() + 1).toString();
                  } catch (e) {
                    //do nothing
                  }
                  setState(() {});
                },
                child: Icon(Icons.add_circle_outline, size: 16),
              ),
              InkWell(
                onTap: () {
                  try {
                    _controller.text = (double.parse(_controller.text).ceil() - 1).toString();
                  } catch (e) {
                    //do nothing
                  }
                  setState(() {});
                },
                child: Icon(Icons.remove_circle_outline, size: 16),
              ),
            ],
          ),
        ],
      );
    }
    return AlertDialog(
      title: widget.title == null ? null : Text(widget.title!),
      content: field,
      actions: <Widget>[
        TextButton(child: Text(S.current.cancel), onPressed: () => Navigator.pop(context)),
        TextButton(
          onPressed: validation
              ? () {
                  String _value = _controller.text;
                  validation = _validate(_value);
                  setState(() {
                    if (validation) {
                      Navigator.pop(context, _value);
                      if (widget.onSubmit != null) {
                        widget.onSubmit!(_value);
                      }
                    }
                  });
                }
              : null,
          child: Text(S.current.ok),
        ),
      ],
    );
  }
}

class SimpleConfirmDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final EdgeInsetsGeometry contentPadding;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onTapOk;
  final VoidCallback? onTapCancel;

  /// ignore if onTapCancel is not null
  final bool showOk;
  final bool showCancel;
  final List<Widget> actions;
  final bool scrollable;
  final bool wrapActionsInRow;
  final EdgeInsets insetPadding;

  const SimpleConfirmDialog({
    super.key,
    this.title,
    this.content,
    this.contentPadding = const EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 24.0),
    this.confirmText,
    this.cancelText,
    this.onTapOk,
    this.onTapCancel,
    this.showOk = true,
    this.showCancel = true,
    this.actions = const [],
    this.scrollable = false,
    this.wrapActionsInRow = false,
    this.insetPadding = const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[
      if (showCancel)
        TextButton(
          child: Text(cancelText ?? S.current.cancel),
          onPressed: () {
            Navigator.of(context).pop(false);
            if (onTapCancel != null) {
              onTapCancel!();
            }
          },
        ),
      ...actions,
      if (showOk)
        TextButton(
          child: Text(confirmText ?? S.current.confirm),
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
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: children),
        ),
      ];
    }
    return AlertDialog(
      title: title,
      content: content,
      contentPadding: contentPadding,
      scrollable: scrollable,
      actions: children,
      insetPadding: insetPadding,
    );
  }
}

Future<void> jumpToExternalLinkAlert({required String url, String? name, String? content}) async {
  String shownLink = url;
  String? safeLink = Uri.tryParse(url)?.toString();
  if (safeLink != null) {
    shownLink = UriX.tryDecodeFull(safeLink) ?? safeLink;
  }
  safeLink ??= url;

  bool valid = await canLaunch(safeLink);

  return showDialog(
    context: kAppKey.currentContext!,
    useRootNavigator: false,
    builder: (context) => SimpleConfirmDialog(
      title: Text(S.current.jump_to(name ?? S.current.link)),
      content: Text.rich(
        TextSpan(
          children: [
            if (content != null) TextSpan(text: '$content\n\n'),
            TextSpan(
              text: shownLink,
              style: const TextStyle(decoration: TextDecoration.underline),
            ),
          ],
        ),
      ),
      showOk: valid,
      onTapOk: () async {
        String link = safeLink ?? url;
        if (await canLaunch(link)) {
          launch(link);
        } else {
          EasyLoading.showToast('Could not launch url:\n$link');
        }
      },
    ),
  );
}
