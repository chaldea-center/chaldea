import 'package:chaldea/generated/l10n.dart';
import 'package:flutter/material.dart';

class InputCancelOkDialog extends StatefulWidget {
  final String title;
  final String text;
  final String hintText;
  final String errorText;
  final bool Function(String) validate;
  final void Function(String) onSubmit;

  const InputCancelOkDialog(
      {Key key,
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
  TextEditingController _controller;
  bool validation = true;

  bool _validate(String v) {
    return widget.validate == null ? true : widget.validate(v);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  Widget build(BuildContext context) {
    validation = _validate(_controller.text);
    return AlertDialog(
      title: Text(widget.title),
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
          widget.onSubmit(v);
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
            String _value = _controller.text;
            validation = _validate(_value);
            setState(() {
              if (validation && widget.onSubmit != null) {
                widget.onSubmit(_value);
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
  final Widget title;
  final Widget content;
  final VoidCallback onTapOk;
  final VoidCallback onTapCancel;

  /// ignore if onTapCancel is not null
  final bool hideCancel;

  const SimpleCancelOkDialog(
      {Key key,
      this.title,
      this.content,
      this.onTapOk,
      this.onTapCancel,
      this.hideCancel = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: <Widget>[
        if (onTapCancel != null || !hideCancel)
          TextButton(
            child: Text(S.of(context).cancel),
            onPressed: () {
              Navigator.pop(context);
              if (onTapCancel != null) {
                onTapCancel();
              }
            },
          ),
        if (onTapOk != null)
          TextButton(
            child: Text(S.of(context).ok),
            onPressed: () {
              Navigator.of(context).pop();
              onTapOk();
            },
          )
      ],
    );
  }

  Future show(BuildContext context) {
    return showDialog(context: context, builder: (_) => this);
  }
}
