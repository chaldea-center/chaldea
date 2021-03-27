import 'package:chaldea/generated/l10n.dart';
import 'package:flutter/material.dart';

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
          if (widget.onSubmit != null) {
            widget.onSubmit!(v);
          }
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        TextButton(
          child: Text(S.of(context).cancel),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(S.of(context).ok),
          onPressed: () {
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
          },
        )
      ],
    );
  }
}

class SimpleCancelOkDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
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
          child: Text(S.of(context).confirm),
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
      scrollable: scrollable,
      actions: children,
    );
  }

  /// pop true when click ok, and false when click cancel,
  /// other values can also be popped by actions
  Future<T?> show<T>(BuildContext context) {
    return showDialog<T>(context: context, builder: (_) => this);
  }
}
